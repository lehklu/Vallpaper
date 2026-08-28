import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager

Item {
    id: root

    implicitWidth: Kirigami.Units.gridUnit * 34
    implicitHeight: Kirigami.Units.gridUnit * 32

    property int selectedDesktop: desktopBox.currentIndex + 1
    property var dateColors: ["#a0ffa0", "#a8a8ff", "#ff97ff", "#ffff8f", "#ffffff", "#41f2f2"]
    property var numberColors: ["#000000", "#000000", "#000000", "#000000", "#000000", "#000000"]
    property var dayNameColors: ["#000000", "#000000", "#000000", "#000000", "#000000", "#000000"]
    property var dayDateColors: ["#000000", "#000000", "#000000", "#000000", "#000000", "#000000"]
    property var numberTextColors: ["#a0ffa0", "#a8a8ff", "#ff97ff", "#ffff8f", "#ffffff", "#41f2f2"]
    property var desktopNameColors: ["#000000", "#000000", "#000000", "#000000", "#000000", "#000000"]
    property var desktopNameBackgroundColors: ["#a0ffa0", "#a8a8ff", "#ff97ff", "#ffff8f", "#ffffff", "#41f2f2"]
    property var dayNameFonts: ["Inconsolata", "Inconsolata", "Inconsolata", "Inconsolata", "Inconsolata", "Inconsolata"]
    property var dayDateFonts: ["Cantarell", "Cantarell", "Cantarell", "Cantarell", "Cantarell", "Cantarell"]
    property var numberFonts: ["Cantarell", "Cantarell", "Cantarell", "Cantarell", "Cantarell", "Cantarell"]
    property var desktopNameFonts: ["Cantarell", "Cantarell", "Cantarell", "Cantarell", "Cantarell", "Cantarell"]

    function save(key, value) {
        plasmoid.configuration[key + selectedDesktop] = value
        plasmoid.configuration.writeConfig()
    }

    function loadSettings() {
        var desktopCount = Math.max(6, desktopInfo.numberOfDesktops || 0)
        var keys = plasmoid.configuration.keys()
        for (var k = 0; k < keys.length; ++k) {
            var suffix = keys[k].match(/(?:dateColor|numberColor|dayNameColor|dayDateColor|numberTextColor|desktopNameColor|desktopNameBackgroundColor|dayNameFont|dayDateFont|numberFont|desktopNameFont)([0-9]+)$/)
            if (suffix)
                desktopCount = Math.max(desktopCount, Number(suffix[1]))
        }
        for (var i = 0; i < desktopCount; ++i) {
            var n = i + 1
            if (plasmoid.configuration["dateColor" + n]) dateColors[i] = plasmoid.configuration["dateColor" + n]
            if (plasmoid.configuration["numberColor" + n]) numberColors[i] = plasmoid.configuration["numberColor" + n]
            if (plasmoid.configuration["dayNameColor" + n]) dayNameColors[i] = plasmoid.configuration["dayNameColor" + n]
            if (plasmoid.configuration["dayDateColor" + n]) dayDateColors[i] = plasmoid.configuration["dayDateColor" + n]
            if (plasmoid.configuration["numberTextColor" + n]) numberTextColors[i] = plasmoid.configuration["numberTextColor" + n]
            if (plasmoid.configuration["desktopNameColor" + n]) desktopNameColors[i] = plasmoid.configuration["desktopNameColor" + n]
            if (plasmoid.configuration["desktopNameBackgroundColor" + n]) desktopNameBackgroundColors[i] = plasmoid.configuration["desktopNameBackgroundColor" + n]
            if (plasmoid.configuration["dayNameFont" + n]) dayNameFonts[i] = plasmoid.configuration["dayNameFont" + n]
            if (plasmoid.configuration["dayDateFont" + n]) dayDateFonts[i] = plasmoid.configuration["dayDateFont" + n]
            if (plasmoid.configuration["numberFont" + n]) numberFonts[i] = plasmoid.configuration["numberFont" + n]
            if (plasmoid.configuration["desktopNameFont" + n]) desktopNameFonts[i] = plasmoid.configuration["desktopNameFont" + n]
        }
    }

    function setAt(list, index, value) {
        var copy = list.slice()
        copy[index] = value
        return copy
    }

    function openColor(target, current) {
        colorDialog.target = target
        colorDialog.selectedColor = current
        colorDialog.open()
    }

    function openFont(target, current) {
        fontDialog.target = target
        fontDialog.selectedFamily = current
        fontDialog.previewText = target === "styleFont"
                ? styleDialog.target === "dayName" ? Qt.locale().toString(new Date(), "dddd")
                : styleDialog.target === "dayDate" ? Qt.locale().toString(new Date(), "dd.MM")
                : styleDialog.target === "desktopName" ? desktopModel.get(selectedDesktop - 1).name
                : String(selectedDesktop)
                : String(selectedDesktop)
        fontDialog.open()
    }

    Component.onCompleted: loadSettings()

    onSelectedDesktopChanged: {
        if (largePreview.item) {
            largePreview.item.desktopNo = selectedDesktop
            largePreview.item.desktopName = desktopModel.count > selectedDesktop - 1
                    ? desktopModel.get(selectedDesktop - 1).name : qsTr("Desktop %1").arg(selectedDesktop)
        }
    }

    TaskManager.VirtualDesktopInfo {
        id: desktopInfo
        onNumberOfDesktopsChanged: scheduleDesktopRebuild()
        onDesktopIdsChanged: scheduleDesktopRebuild()
        onDesktopNamesChanged: scheduleDesktopRebuild()
        Component.onCompleted: scheduleDesktopRebuild()
    }

    Timer {
        id: desktopRebuildTimer
        interval: 0
        onTriggered: rebuildDesktops()
    }

    function scheduleDesktopRebuild() {
        desktopRebuildTimer.restart()
    }

    function rebuildDesktops() {
        var previousIndex = desktopBox.currentIndex
        desktopModel.clear()
        // Use every available source: Plasma versions differ in when these
        // properties become populated while the configuration page starts.
        var ids = desktopInfo.desktopIds || []
        var names = desktopInfo.desktopNames || []
        var count = Math.max(desktopInfo.numberOfDesktops || 0,
                ids.length || 0, names.length || 0, 1)
        for (var i = 0; i < count; ++i) {
            var desktopName = desktopInfo.desktopNames && desktopInfo.desktopNames[i]
                    ? desktopInfo.desktopNames[i] : qsTr("Desktop %1").arg(i + 1)
            desktopModel.append({ name: desktopName, number: i + 1 })
        }
        desktopBox.currentIndex = Math.min(Math.max(previousIndex, 0), count - 1)
        if (largePreview.item) {
            largePreview.item.desktopNo = desktopBox.currentIndex + 1
            largePreview.item.desktopName = desktopModel.get(desktopBox.currentIndex).name
        }
    }

    ListModel { id: desktopModel }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        Controls.Label {
            text: qsTr("Virtual desktop")
            Layout.fillWidth: true
            font.bold: true
        }

        Controls.ComboBox {
            id: desktopBox
            model: desktopModel
            textRole: "name"
            Layout.fillWidth: true
            implicitHeight: Kirigami.Units.gridUnit * 3
            delegate: desktopDelegate
            popup: Controls.Popup {
                id: desktopPopup
                y: desktopBox.height
                width: desktopBox.width
                padding: 0
                height: Math.min(desktopModel.count * Kirigami.Units.gridUnit * 3,
                        Kirigami.Units.gridUnit * 20)
                contentItem: ListView {
                    anchors.fill: parent
                    clip: true
                    model: desktopModel
                    currentIndex: desktopBox.highlightedIndex
                    delegate: desktopDelegate
                }
            }
        }

        Controls.Label {
            text: qsTr("Widget appearance")
            font.bold: true
            Layout.topMargin: Kirigami.Units.smallSpacing
        }

        Loader {
            id: largePreview
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 13
            sourceComponent: widgetPreview
            onLoaded: {
                item.desktopNo = root.selectedDesktop
                item.desktopName = desktopModel.count > root.selectedDesktop - 1
                        ? desktopModel.get(root.selectedDesktop - 1).name
                        : qsTr("Desktop %1").arg(root.selectedDesktop)
                item.interactive = true
            }
        }

        Controls.Label {
            text: qsTr("Click an element in the preview to customize it.")
            opacity: 0.7
            Layout.fillWidth: true
        }
        Item { Layout.fillHeight: true }
    }

    Component {
        id: desktopDelegate
        Controls.ItemDelegate {
            width: desktopBox.width
            implicitHeight: Kirigami.Units.gridUnit * 3
            highlighted: desktopBox.highlightedIndex === index
            contentItem: RowLayout {
                spacing: Kirigami.Units.largeSpacing
                Controls.Label {
                    text: name
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    elide: Text.ElideRight
                }
                Loader {
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 9
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                    sourceComponent: widgetPreview
                    onLoaded: {
                        item.desktopNo = number
                        item.desktopName = name
                        item.interactive = false
                    }
                }
            }
            onClicked: {
                desktopBox.currentIndex = index
                desktopPopup.close()
            }
        }
    }

    Component {
        id: widgetPreview
        Item {
            id: preview
            property int desktopNo: root.selectedDesktop
            property string desktopName: qsTr("Desktop")
            property bool interactive: true
            property real scaleFactor: Math.min(width / 320, height / 120)
            Rectangle {
                id: dateBlock
                width: parent.width * 0.6
                height: parent.height
                color: root.dateColors[preview.desktopNo - 1] || "#a0ffa0"
                border.color: dateMouse.containsMouse ? Kirigami.Theme.highlightColor : "transparent"
                border.width: 2
                MouseArea {
                    id: dateMouse; anchors.fill: parent; hoverEnabled: true
                    enabled: preview.interactive
                    onClicked: root.openColor("date", dateBlock.color)
                }
                Text {
                    anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.locale().toString(new Date(), "dddd")
                    color: root.dayNameColors[preview.desktopNo - 1] || "#000000"
                    font.family: root.dayNameFonts[preview.desktopNo - 1] || "Inconsolata"
                    font.pixelSize: parent.height * 0.42; font.weight: 400
                }
                Text {
                    anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.locale().toString(new Date(), "dd.MM")
                    color: root.dayDateColors[preview.desktopNo - 1] || "#000000"
                    font.family: root.dayDateFonts[preview.desktopNo - 1] || "Cantarell"
                    font.pixelSize: parent.height * 0.42; font.weight: 600
                    MouseArea { anchors.fill: parent; enabled: preview.interactive; onClicked: root.openStyle("dayDate") }
                }
                MouseArea { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: parent.height / 2; enabled: preview.interactive; onClicked: root.openStyle("dayName") }
            }
            Rectangle {
                id: nameBlock
                anchors.left: dateBlock.right
                width: parent.width * 0.2
                height: parent.height
                color: root.desktopNameBackgroundColors[preview.desktopNo - 1] || "#a0ffa0"
                MouseArea {
                    anchors.fill: parent
                    enabled: preview.interactive
                    onClicked: root.openColor("desktopNameBackground", nameBlock.color)
                }
                Controls.Label {
                    anchors.centerIn: parent
                    width: parent.width - Kirigami.Units.smallSpacing * 2
                    text: preview.desktopName
                    color: root.desktopNameColors[preview.desktopNo - 1] || "#000000"
                    font.family: root.desktopNameFonts[preview.desktopNo - 1] || "Cantarell"
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    MouseArea {
                        anchors.fill: parent
                        enabled: preview.interactive
                        onClicked: root.openStyle("desktopName")
                    }
                }
            }
            Rectangle {
                id: numberBlock
                anchors.right: parent.right; width: parent.width * 0.2; height: parent.height
                color: root.numberColors[preview.desktopNo - 1] || "#000000"
                border.color: numberMouse.containsMouse ? Kirigami.Theme.highlightColor : "transparent"; border.width: 2
                MouseArea { id: numberMouse; anchors.fill: parent; hoverEnabled: true; enabled: preview.interactive; onClicked: root.openColor("number", numberBlock.color) }
                Text {
                    anchors.centerIn: parent; text: preview.desktopNo
                    color: root.numberTextColors[preview.desktopNo - 1] || "#a0ffa0"
                    font.family: root.numberFonts[preview.desktopNo - 1] || "Cantarell"
                    font.pixelSize: parent.height * 0.68; font.weight: 700
                    MouseArea { anchors.fill: parent; enabled: preview.interactive; onClicked: root.openStyle("numberText") }
                }
            }
        }
    }

    function openStyle(target) {
        styleDialog.target = target
        styleDialog.fontName = (target === "dayName" ? dayNameFonts[selectedDesktop - 1]
                : target === "dayDate" ? dayDateFonts[selectedDesktop - 1]
                : target === "desktopName" ? desktopNameFonts[selectedDesktop - 1] : numberFonts[selectedDesktop - 1])
                || (target === "dayName" ? "Inconsolata" : "Cantarell")
        styleDialog.selectedTextColor = (target === "dayName" ? dayNameColors[selectedDesktop - 1]
                : target === "dayDate" ? dayDateColors[selectedDesktop - 1]
                : target === "desktopName" ? desktopNameColors[selectedDesktop - 1] : numberTextColors[selectedDesktop - 1])
                || "#000000"
        styleDialog.open()
    }

    Controls.Dialog {
        id: styleDialog
        title: target === "dayName" ? qsTr("Day name") : target === "dayDate" ? qsTr("Day date")
                : target === "desktopName" ? qsTr("Desktop name") : qsTr("Desktop number")
        standardButtons: Controls.DialogButtonBox.Close
        property string target: ""
        property string fontName: "Cantarell"
        property color selectedTextColor: "#000000"
        contentItem: ColumnLayout {
            spacing: Kirigami.Units.largeSpacing
            Controls.Label { text: qsTr("Text appearance"); Layout.fillWidth: true }
            Controls.Button {
                text: qsTr("Choose font…")
                Layout.fillWidth: true
                onClicked: root.openFont("styleFont", styleDialog.fontName)
            }
            Controls.Button {
                text: qsTr("Choose text color…")
                Layout.fillWidth: true
                onClicked: {
                    colorDialog.target = "text"
                    colorDialog.selectedColor = styleDialog.selectedTextColor
                    colorDialog.open()
                }
            }
        }
    }

    ColorDialog {
        id: colorDialog
        property string target: ""
        onAccepted: {
                if (target === "date") { root.dateColors = root.setAt(root.dateColors, root.selectedDesktop - 1, selectedColor); root.save("dateColor", selectedColor) }
            else if (target === "number") { root.numberColors = root.setAt(root.numberColors, root.selectedDesktop - 1, selectedColor); root.save("numberColor", selectedColor) }
            else if (target === "desktopNameBackground") { root.desktopNameBackgroundColors = root.setAt(root.desktopNameBackgroundColors, root.selectedDesktop - 1, selectedColor); root.save("desktopNameBackgroundColor", selectedColor) }
            else {
                styleDialog.selectedTextColor = selectedColor
                if (styleDialog.target === "dayName") { root.dayNameColors = root.setAt(root.dayNameColors, root.selectedDesktop - 1, selectedColor); root.save("dayNameColor", selectedColor) }
                else if (styleDialog.target === "dayDate") { root.dayDateColors = root.setAt(root.dayDateColors, root.selectedDesktop - 1, selectedColor); root.save("dayDateColor", selectedColor) }
                else if (styleDialog.target === "desktopName") { root.desktopNameColors = root.setAt(root.desktopNameColors, root.selectedDesktop - 1, selectedColor); root.save("desktopNameColor", selectedColor) }
                else { root.numberTextColors = root.setAt(root.numberTextColors, root.selectedDesktop - 1, selectedColor); root.save("numberTextColor", selectedColor) }
            }
        }
    }

    Controls.Dialog {
        id: fontDialog
        title: qsTr("Choose font")
        standardButtons: Controls.DialogButtonBox.Ok | Controls.DialogButtonBox.Cancel
        property string target: ""
        property string selectedFamily: "Cantarell"
        property string previewText: "Aa"
        onOpened: fontFamilyBox.currentIndex = fontFamilyBox.model.indexOf(selectedFamily)
        contentItem: ColumnLayout {
            spacing: Kirigami.Units.largeSpacing
            Controls.Label {
                text: fontDialog.previewText
                font.family: fontFamilyBox.currentText || fontDialog.selectedFamily
                font.pixelSize: Kirigami.Units.gridUnit * 1.5
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            Controls.ComboBox {
                id: fontFamilyBox
                model: Qt.fontFamilies()
                currentIndex: -1
                Layout.fillWidth: true
            }
        }
        onAccepted: {
            var family = fontFamilyBox.currentText
            if (target === "dayName") { root.dayNameFonts = root.setAt(root.dayNameFonts, root.selectedDesktop - 1, family); root.save("dayNameFont", family) }
            else if (target === "dayDate") { root.dayDateFonts = root.setAt(root.dayDateFonts, root.selectedDesktop - 1, family); root.save("dayDateFont", family) }
            else if (target === "desktopName") { root.desktopNameFonts = root.setAt(root.desktopNameFonts, root.selectedDesktop - 1, family); root.save("desktopNameFont", family) }
            else if (target === "numberText") { root.numberFonts = root.setAt(root.numberFonts, root.selectedDesktop - 1, family); root.save("numberFont", family) }
            else if (target === "styleFont") {
                if (styleDialog.target === "dayName") { root.dayNameFonts = root.setAt(root.dayNameFonts, root.selectedDesktop - 1, family); root.save("dayNameFont", family) }
                else if (styleDialog.target === "dayDate") { root.dayDateFonts = root.setAt(root.dayDateFonts, root.selectedDesktop - 1, family); root.save("dayDateFont", family) }
                else if (styleDialog.target === "desktopName") { root.desktopNameFonts = root.setAt(root.desktopNameFonts, root.selectedDesktop - 1, family); root.save("desktopNameFont", family) }
                else { root.numberFonts = root.setAt(root.numberFonts, root.selectedDesktop - 1, family); root.save("numberFont", family) }
            }
        }
    }
}
