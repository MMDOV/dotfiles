import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Notifications

// Notification daemon. Cards stack at the top right under the bar.
//   click a card         dismiss it          action buttons   invoke and dismiss
//   hover                pauses its timer    critical         stays until dismissed
// Everything that arrives is also kept in a history list (even what do-not-disturb hides).
// qs -p ~/.config/quickshell/notifd ipc call notifd toggleDnd | dismissAll | toggleHistory | clearHistory | status
ShellRoot {
    id: root

    property bool dnd: false
    property bool historyOpen: false
    readonly property int historyLimit: 100
    ListModel { id: history }

    function pictureOf(n) {
        return n.image !== "" ? n.image : n.appIcon !== "" ? Quickshell.iconPath(n.appIcon, true) : ""
    }
    function record(n) {
        history.insert(0, {
            app: n.appName, summary: n.summary, body: n.body, picture: pictureOf(n),
            critical: n.urgency === NotificationUrgency.Critical, stamp: Date.now()
        })
        while (history.count > historyLimit) history.remove(history.count - 1)
    }
    function ago(ms) {
        const m = Math.floor((Date.now() - ms) / 60000)
        if (m < 1) return "now"
        if (m < 60) return m + "m"
        const h = Math.floor(m / 60)
        return h < 24 ? h + "h" : Qt.formatDateTime(new Date(ms), "d MMM")
    }
    readonly property int defaultTimeout: 5000
    readonly property int cardWidth: 360
    // Mostly opaque; the compositor blurs whatever shows through (layer rule on "notifd").
    readonly property real panelAlpha: 0.85

    NotificationServer {
        id: server
        keepOnReload: false
        actionsSupported: true
        bodyMarkupSupported: true
        bodyImagesSupported: false
        imageSupported: true
        persistenceSupported: false
        onNotification: n => {
            n.tracked = true
            root.record(n)
            // Do not disturb: keep critical ones, drop the rest quietly.
            if (root.dnd && n.urgency !== NotificationUrgency.Critical) n.expire()
        }
    }

    IpcHandler {
        target: "notifd"
        function toggleDnd(): string { root.dnd = !root.dnd; return root.dnd ? "dnd on" : "dnd off" }
        function dismissAll(): void {
            const all = server.trackedNotifications.values.slice()
            for (const n of all) n.dismiss()
        }
        function toggleHistory(): void { root.historyOpen = !root.historyOpen }
        function clearHistory(): void { history.clear() }
        function status(): string { return (root.dnd ? "dnd on" : "dnd off") + ", " + server.trackedNotifications.values.length + " shown, " + history.count + " in history" }
    }

    PanelWindow {
        id: win
        screen: {
            const m = Hyprland.focusedMonitor
            const s = m ? Quickshell.screens.find(x => x.name === m.name) : null
            return s || Quickshell.screens[0]
        }
        anchors { top: true; right: true }
        margins { top: 36; right: 8 }
        implicitWidth: root.cardWidth
        implicitHeight: Math.max(1, stack.implicitHeight)
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        visible: server.trackedNotifications.values.length > 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "notifd"

        Column {
            id: stack
            width: parent.width
            spacing: 6

            Repeater {
                model: server.trackedNotifications

                delegate: Rectangle {
                    id: card
                    required property var modelData
                    readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
                    readonly property bool hovered: hover.hovered
                    readonly property string picture: modelData.image !== "" ? modelData.image
                                                  : modelData.appIcon !== "" ? Quickshell.iconPath(modelData.appIcon, true) : ""

                    width: stack.width
                    implicitHeight: body.implicitHeight + 24
                    radius: Theme.radius + 2
                    color: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, root.panelAlpha)
                    border.width: 1
                    border.color: critical ? Theme.danger : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35)
                    clip: true
                    opacity: 0
                    x: 24
                    Component.onCompleted: { opacity = 1; x = 0 }
                    Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                    Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                    // expire after the sender's timeout, a default, or never for critical
                    Timer {
                        interval: card.modelData.expireTimeout > 0 ? card.modelData.expireTimeout * 1000 : root.defaultTimeout
                        running: !card.critical && !card.hovered
                        repeat: false
                        onTriggered: card.modelData.expire()
                    }


                    HoverHandler { id: hover }
                    TapHandler { onTapped: card.modelData.dismiss() }

                    RowLayout {
                        id: body
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                        spacing: 10

                        Image {
                            visible: card.picture !== ""
                            source: card.picture
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            Layout.alignment: Qt.AlignTop
                            sourceSize.width: 72
                            sourceSize.height: 72
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.appName
                                visible: text !== ""
                                color: card.critical ? Theme.danger : Theme.accent
                                font.pixelSize: 11
                                font.family: "JetBrains Mono"
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.summary
                                visible: text !== ""
                                color: card.critical ? Theme.danger : Theme.fg
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "JetBrains Mono"
                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.body
                                visible: text !== ""
                                color: Theme.fgDim
                                textFormat: Text.StyledText
                                font.pixelSize: 12
                                font.family: "JetBrains Mono"
                                wrapMode: Text.Wrap
                                maximumLineCount: 5
                                elide: Text.ElideRight
                            }

                            Flow {
                                Layout.fillWidth: true
                                Layout.topMargin: 4
                                spacing: 6
                                visible: card.modelData.actions.length > 0

                                Repeater {
                                    model: card.modelData.actions
                                    delegate: Rectangle {
                                        id: btn
                                        required property var modelData
                                        width: label.implicitWidth + 20
                                        height: 24
                                        radius: Theme.radius
                                        color: btnHover.hovered ? Theme.accent : Theme.surface
                                        Behavior on color { ColorAnimation { duration: 100 } }
                                        Text {
                                            id: label
                                            anchors.centerIn: parent
                                            text: btn.modelData.text
                                            color: btnHover.hovered ? Theme.bg : Theme.fg
                                            font.pixelSize: 11
                                            font.family: "JetBrains Mono"
                                        }
                                        HoverHandler { id: btnHover }
                                        TapHandler { onTapped: { btn.modelData.invoke(); card.modelData.dismiss() } }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    PanelWindow {
        id: histWin
        screen: win.screen
        anchors { top: true; right: true; bottom: true }
        margins { top: 36; right: 8; bottom: 8 }
        implicitWidth: root.cardWidth + 20
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        visible: root.historyOpen
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.namespace: "notifd-history"

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 10
            radius: Theme.radius + 4
            color: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, 0.45)
            border.width: 1
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35)
            focus: true
            Keys.onEscapePressed: root.historyOpen = false

            ColumnLayout {
                anchors { fill: parent; margins: 12 }
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Notifications"
                        color: Theme.fg
                        font { pixelSize: 14; bold: true; family: "JetBrains Mono" }
                    }
                    Text {
                        text: history.count > 0 ? history.count : ""
                        color: Theme.fgFaint
                        font { pixelSize: 12; family: "JetBrains Mono" }
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: dndLabel.implicitWidth + 16; height: 22; radius: Theme.radius
                        color: root.dnd ? Theme.accent : Theme.surface
                        Text {
                            id: dndLabel; anchors.centerIn: parent
                            text: root.dnd ? "dnd on" : "dnd off"
                            color: root.dnd ? Theme.bg : Theme.fgDim
                            font { pixelSize: 11; family: "JetBrains Mono" }
                        }
                        TapHandler { onTapped: root.dnd = !root.dnd }
                    }
                    Rectangle {
                        width: clearLabel.implicitWidth + 16; height: 22; radius: Theme.radius
                        color: clearHover.hovered ? Theme.accent : Theme.surface
                        Text {
                            id: clearLabel; anchors.centerIn: parent
                            text: "clear"
                            color: clearHover.hovered ? Theme.bg : Theme.fgDim
                            font { pixelSize: 11; family: "JetBrains Mono" }
                        }
                        HoverHandler { id: clearHover }
                        TapHandler { onTapped: history.clear() }
                    }
                }

                Text {
                    visible: history.count === 0
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 24
                    text: "nothing missed"
                    color: Theme.fgFaint
                    font { pixelSize: 12; family: "JetBrains Mono" }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 6
                    model: history
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        id: item
                        required property int index
                        required property string app
                        required property string summary
                        required property string body
                        required property string picture
                        required property bool critical
                        required property double stamp
                        width: ListView.view.width
                        implicitHeight: row.implicitHeight + 20
                        height: implicitHeight
                        radius: Theme.radius
                        color: itemHover.hovered ? Theme.surface : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.38)
                        clip: true
                        Behavior on color { ColorAnimation { duration: 100 } }

                        HoverHandler { id: itemHover }
                        TapHandler { onTapped: history.remove(item.index) }

                        RowLayout {
                            id: row
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
                            spacing: 10
                            Image {
                                visible: item.picture !== ""
                                source: item.picture
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                Layout.alignment: Qt.AlignTop
                                sourceSize.width: 56
                                sourceSize.height: 56
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        Layout.fillWidth: true
                                        text: item.app
                                        color: item.critical ? Theme.danger : Theme.accent
                                        font { pixelSize: 11; family: "JetBrains Mono" }
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: root.ago(item.stamp)
                                        color: Theme.fgFaint
                                        font { pixelSize: 11; family: "JetBrains Mono" }
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                    text: item.summary
                                    color: Theme.fg
                                    font { pixelSize: 12; bold: true; family: "JetBrains Mono" }
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                    text: item.body
                                    color: Theme.fgDim
                                    textFormat: Text.StyledText
                                    font { pixelSize: 11; family: "JetBrains Mono" }
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 4
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
