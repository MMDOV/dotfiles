import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Qt.labs.folderlistmodel

// Wallpaper picker. Subfolders of the wallpaper directory are collections.
//   left/right, h/l   browse        tab, shift+tab   next/previous collection
//   enter             apply, close  space            apply, keep browsing
//   g / G             first / last  esc, q           close
ShellRoot {
    id: root

    readonly property string lookCommand: Quickshell.env("HOME") + "/.local/bin/look"
    property var cfg: ({ dir: "", wallpaper: "", thumbs: "" })
    property bool cfgReady: false
    property int collection: 0
    property string wantedFile: ""      // wallpaper to land on once its folder is listed
    property bool placed: false         // false until the first positioning, so opening doesn't animate a scroll

    readonly property url rootUrl: "file://" + cfg.dir
    readonly property var names: {
        const n = []
        for (let i = 0; i < dirs.count; i++) n.push(dirs.get(i, "fileName"))
        return n
    }
    readonly property bool flat: dirs.status === FolderListModel.Ready && dirs.count === 0
    readonly property string collectionName: flat ? "all" : (names[collection] || "")

    function applyAt(index, closeAfter) {
        if (index < 0 || index >= files.count) return
        Quickshell.execDetached([lookCommand, "wallpaper", files.get(index, "filePath")])
        if (closeAfter) Qt.quit()
    }

    function stepCollection(delta) {
        if (names.length < 2) return
        placed = false
        wantedFile = ""
        collection = (collection + delta + names.length) % names.length
    }

    Process {
        command: [root.lookCommand, "info"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.cfg = JSON.parse(text)
                    // start in the collection holding the current wallpaper
                    const w = root.cfg.wallpaper
                    if (w.startsWith(root.cfg.dir + "/")) {
                        const rel = w.substring(root.cfg.dir.length + 1).split("/")
                        root.wantedFile = rel[rel.length - 1]
                        root.wantedCollection = rel.length > 1 ? rel[0] : ""
                    }
                } catch (e) { console.warn("wallpicker: look info failed: " + e) }
                root.cfgReady = true
            }
        }
    }
    property string wantedCollection: ""

    // Small copies of the wallpapers (look makes them): decoding a 15 MB original for a
    // 320 px card is what made the strip fill in slowly. Anything without one yet shows the
    // original, and this makes the missing ones for next time.
    Process {
        command: [root.lookCommand, "thumbs"]
        running: true
    }
    function thumbFor(fileUrl) {
        const p = fileUrl.toString().replace("file://", "")
        return cfg.thumbs && p.startsWith(cfg.dir + "/") ? "file://" + cfg.thumbs + p.substring(cfg.dir.length) + ".jpg" : fileUrl
    }

    FolderListModel {
        id: dirs
        folder: root.cfgReady ? root.rootUrl : ""
        showFiles: false
        showDirs: true
        showDotAndDotDot: false
        onStatusChanged: {
            if (status !== FolderListModel.Ready) return
            const i = root.names.indexOf(root.wantedCollection)
            if (i >= 0) root.collection = i
        }
    }

    FolderListModel {
        id: files
        folder: !root.cfgReady || dirs.status !== FolderListModel.Ready ? ""
              : root.flat ? root.rootUrl
              : (dirs.count > 0 ? dirs.get(Math.min(root.collection, dirs.count - 1), "fileUrl") : "")
        showDirs: false
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.JPG", "*.PNG"]
        onCountChanged: {
            if (count === 0) return
            let at = 0
            if (root.wantedFile !== "") {
                for (let i = 0; i < count; i++) if (get(i, "fileName") === root.wantedFile) { at = i; break }
            }
            list.currentIndex = at
            list.positionViewAtIndex(at, ListView.Center)
            root.placed = true
        }
    }

    PanelWindow {
        id: win
        screen: {
            const m = Hyprland.focusedMonitor
            const s = m ? Quickshell.screens.find(x => x.name === m.name) : null
            return s || Quickshell.screens[0]
        }
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "wallpicker"

        FocusScope {
            id: scope
            anchors.fill: parent
            focus: true
            opacity: 0
            Component.onCompleted: opacity = 1
            Behavior on opacity { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

            Rectangle {   // scrim; a click outside the strip closes
                anchors.fill: parent
                color: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, 0.82)
                MouseArea { anchors.fill: parent; onClicked: Qt.quit() }
            }

            Column {
                anchors.centerIn: parent
                spacing: 28
                width: parent.width

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.fgDim
                    font.pixelSize: 15
                    font.family: "JetBrains Mono"
                    text: root.collectionName + "   " + (files.count ? (list.currentIndex + 1) + " / " + files.count : "empty")
                }

                ListView {
                    id: list
                    width: parent.width
                    height: 240
                    orientation: ListView.Horizontal
                    spacing: 28
                    model: files
                    clip: false
                    cacheBuffer: 1600
                    highlightRangeMode: ListView.StrictlyEnforceRange
                    preferredHighlightBegin: width / 2 - 160
                    preferredHighlightEnd: width / 2 + 160
                    highlightMoveDuration: root.placed ? 180 : 0
                    boundsBehavior: Flickable.StopAtBounds
                    interactive: false

                    MouseArea {   // wheel steps the selection instead of flicking
                        anchors.fill: parent
                        z: -1
                        onWheel: wheel => wheel.angleDelta.y > 0 || wheel.angleDelta.x > 0
                                          ? list.decrementCurrentIndex() : list.incrementCurrentIndex()
                        onClicked: Qt.quit()
                    }

                    delegate: Item {
                        id: card
                        required property int index
                        required property string fileName
                        required property url fileUrl
                        readonly property bool current: ListView.isCurrentItem
                        width: 320
                        height: 180
                        anchors.verticalCenter: parent ? parent.verticalCenter : undefined

                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            color: Theme.surface
                            border.width: 2
                            border.color: card.current ? Theme.accent : "transparent"
                            scale: card.current ? 1.12 : 1
                            opacity: card.current ? 1 : 0.7
                            Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
                            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                            Image {
                                anchors.fill: parent
                                anchors.margins: 2
                                source: root.thumbFor(card.fileUrl)
                                sourceSize.width: 640
                                sourceSize.height: 360
                                onStatusChanged: if (status === Image.Error && source != card.fileUrl) source = card.fileUrl
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: card.current ? root.applyAt(card.index, true) : list.currentIndex = card.index
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.fgFaint
                    font.pixelSize: 12
                    font.family: "JetBrains Mono"
                    text: "←/→ browse    tab collection    enter apply    space preview    esc close"
                }
            }

            Keys.onPressed: event => {
                const shift = (event.modifiers & Qt.ShiftModifier) !== 0
                switch (event.key) {
                case Qt.Key_Left: case Qt.Key_H: case Qt.Key_Up: case Qt.Key_K:
                    list.decrementCurrentIndex(); break
                case Qt.Key_Right: case Qt.Key_L: case Qt.Key_Down: case Qt.Key_J:
                    list.incrementCurrentIndex(); break
                case Qt.Key_PageUp:   list.currentIndex = Math.max(0, list.currentIndex - 5); break
                case Qt.Key_PageDown: list.currentIndex = Math.min(files.count - 1, list.currentIndex + 5); break
                case Qt.Key_Home: list.currentIndex = 0; break
                case Qt.Key_End:  list.currentIndex = files.count - 1; break
                case Qt.Key_G:    list.currentIndex = shift ? files.count - 1 : 0; break
                case Qt.Key_Tab: case Qt.Key_BracketRight: root.stepCollection(1); break
                case Qt.Key_Backtab: case Qt.Key_BracketLeft: root.stepCollection(-1); break
                case Qt.Key_Return: case Qt.Key_Enter: root.applyAt(list.currentIndex, true); break
                case Qt.Key_Space: root.applyAt(list.currentIndex, false); break
                case Qt.Key_Escape: case Qt.Key_Q: Qt.quit(); break
                default: return
                }
                event.accepted = true
            }
        }
    }
}
