pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Colors come from the active look, so the picker recolors with everything else.
Singleton {
    id: root

    readonly property string statePath: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/look/palette.json"
    property var p: ({})

    function pick(key, fallback) { return p[key] || fallback }

    readonly property color bg: pick("bg", "#1a1b26")
    readonly property color surface: pick("surface", "#292e42")
    readonly property color border: pick("border", "#3b4261")
    readonly property color fg: pick("fg", "#c0caf5")
    readonly property color fgDim: pick("fg_dim", "#a9b1d6")
    readonly property color fgFaint: pick("fg_faint", "#565f89")
    readonly property color accent: pick("accent", "#7aa2f7")

    readonly property int radius: 6
    readonly property int animFast: 140

    FileView {
        path: root.statePath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            try { root.p = JSON.parse(text()) } catch (e) { console.warn("wallpicker: bad palette: " + e) }
        }
    }
}
