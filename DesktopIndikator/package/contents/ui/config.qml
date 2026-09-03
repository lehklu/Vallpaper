import QtQuick as QTQ
import QtQuick.Controls as QTQ_C
import QtQuick.Dialogs as QTQ_D
import QtQuick.Layouts as QTQ_L
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid as KDE_plasmoid
import org.kde.taskmanager as KDE_taskmanager

QTQ.Item { id: _Root

  property var title // for KDE Settings page

    implicitWidth: Kirigami.Units.gridUnit * 34
    implicitHeight: Kirigami.Units.gridUnit * 32

    property int selectedDesktop: desktopBox.currentIndex + 1
    property int sectionDateWidth: 3
    property int sectionDesktopNameWidth: 1
    property int sectionDesktopNumberWidth: 1
    property bool sectionDateVisible: true
    property bool sectionDesktopNameVisible: true
    property bool sectionDesktopNumberVisible: true
    property int dateSectionOrder: 0
    property int sectionDesktopNameOrder: 1
    property int sectionDesktopNumberOrder: 2
    property var dateBackgroundColors: ["#a0ffa0", "#a8a8ff", "#ff97ff", "#ffff8f", "#ffffff", "#41f2f2"]
    property var numberBackgroundColors: ["#000000", "#000000", "#000000", "#000000", "#000000", "#000000"]
    property var dayNameColors: ["#000000", "#000000", "#000000", "#000000", "#000000", "#000000"]
    property var daydateBackgroundColors: ["#000000", "#000000", "#000000", "#000000", "#000000", "#000000"]
    property var numberColors: ["#a0ffa0", "#a8a8ff", "#ff97ff", "#ffff8f", "#ffffff", "#41f2f2"]
    property var desktopNameColors: ["#000000", "#000000", "#000000", "#000000", "#000000", "#000000"]
    property var desktopNameBackgroundColors: ["#a0ffa0", "#a8a8ff", "#ff97ff", "#ffff8f", "#ffffff", "#41f2f2"]
    property var dayNameFonts: ["Inconsolata", "Inconsolata", "Inconsolata", "Inconsolata", "Inconsolata", "Inconsolata"]
    property var dayDateFonts: ["Cantarell", "Cantarell", "Cantarell", "Cantarell", "Cantarell", "Cantarell"]
    property var numberFonts: ["Cantarell", "Cantarell", "Cantarell", "Cantarell", "Cantarell", "Cantarell"]
    property var desktopNameFonts: ["Cantarell", "Cantarell", "Cantarell", "Cantarell", "Cantarell", "Cantarell"]

    function save(key, value) {
        var listKey = key + "s"
        var values = _Root[listKey].slice()
        values[selectedDesktop - 1] = value
        KDE_plasmoid.Plasmoid.configuration[listKey] = JSON.stringify(values)
        KDE_plasmoid.Plasmoid.configuration.writeConfig()
    }

    function saveLayout(key, value) {
        KDE_plasmoid.Plasmoid.configuration[key] = value
        KDE_plasmoid.Plasmoid.configuration.writeConfig()
    }

    function sectionTotalWidth() {
        return (sectionDateVisible ? sectionDateWidth : 0)
                + (sectionDesktopNameVisible ? sectionDesktopNameWidth : 0)
                + (sectionDesktopNumberVisible ? sectionDesktopNumberWidth : 0)
    }

    function sectionWidth(weight, visible, totalWidth) {
        var total = sectionTotalWidth()
        return visible && total > 0 ? totalWidth * weight / total : 0
    }

    function sectionOffset(order, totalWidth) {
        var total = sectionTotalWidth()
        if (total <= 0)
            return 0
        var offset = 0
        if (sectionDateVisible && dateSectionOrder < order)
            offset += totalWidth * sectionDateWidth / total
        if (sectionDesktopNameVisible && sectionDesktopNameOrder < order)
            offset += totalWidth * sectionDesktopNameWidth / total
        if (sectionDesktopNumberVisible && sectionDesktopNumberOrder < order)
            offset += totalWidth * sectionDesktopNumberWidth / total
        return offset
    }

    component SectionSettingsRow: QTQ_L.RowLayout {
        property string label
        property string sectionKey
        property int widthValue: 1
        property bool visibleValue: true
        property bool canMoveUp: false
        property bool canMoveDown: false
        signal widthSettingChanged(int value)
        signal visibleSettingChanged(bool value)
        signal moveUpRequested
        signal moveDownRequested

        QTQ_C.Button {
            icon.source: Qt.resolvedUrl("../icons/rounded-triangle-down.svg")
            rotation: 180
            display: QTQ_C.AbstractButton.IconOnly
            enabled: parent.canMoveUp
            opacity: parent.canMoveUp ? 1 : 0
            horizontalPadding: 0
            QTQ_L.Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5
            onClicked: parent.moveUpRequested()
        }
        QTQ_C.Button {
            icon.source: Qt.resolvedUrl("../icons/rounded-triangle-down.svg")
            display: QTQ_C.AbstractButton.IconOnly
            enabled: parent.canMoveDown
            opacity: parent.canMoveDown ? 1 : 0
            horizontalPadding: 0
            QTQ_L.Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5
            onClicked: parent.moveDownRequested()
        }
        QTQ_C.Label { text: parent.label; QTQ_L.Layout.fillWidth: true }
        QTQ_C.Label { text: qsTr("Width") }
        QTQ_C.SpinBox {
            from: 1
            to: 10
            value: parent.widthValue
            onValueModified: {
                parent.widthValue = value
                parent.widthSettingChanged(value)
            }
            QTQ_L.Layout.preferredWidth: Kirigami.Units.gridUnit * 5
        }
        QTQ_C.CheckBox {
            checked: parent.visibleValue
            text: qsTr("Visible")
            onClicked: {
                parent.visibleValue = checked
                parent.visibleSettingChanged(checked)
            }
        }
    }

    QTQ.ListModel {
        id: sectionModel
        QTQ.ListElement { key: "date"; label: qsTr("Date") }
        QTQ.ListElement { key: "desktopName"; label: qsTr("Desktop name") }
        QTQ.ListElement { key: "number"; label: qsTr("Desktop number") }
    }

    function sectionWidthValue(key) {
        return key === "date" ? sectionDateWidth : key === "desktopName" ? sectionDesktopNameWidth : sectionDesktopNumberWidth
    }

    function sectionVisibleValue(key) {
        return key === "date" ? sectionDateVisible : key === "desktopName" ? sectionDesktopNameVisible : sectionDesktopNumberVisible
    }

    function setSectionWidth(key, value) {
        if (key === "date") sectionDateWidth = value
        else if (key === "desktopName") sectionDesktopNameWidth = value
        else sectionDesktopNumberWidth = value
        saveLayout(key + "SectionWidth", value)
    }

    function setSectionVisible(key, value) {
        if (key === "date") sectionDateVisible = value
        else if (key === "desktopName") sectionDesktopNameVisible = value
        else sectionDesktopNumberVisible = value
        saveLayout(key + "SectionVisible", value)
    }

    function saveSectionOrder() {
        var order = []
        for (var i = 0; i < sectionModel.count; ++i)
            order.push(sectionModel.get(i).key)
        saveLayout("sectionOrder", order.join(","))
        dateSectionOrder = order.indexOf("date")
        sectionDesktopNameOrder = order.indexOf("desktopName")
        sectionDesktopNumberOrder = order.indexOf("number")
    }

    function loadSectionOrder() {
        var savedOrder = String(KDE_plasmoid.Plasmoid.configuration.sectionOrder || "date,desktopName,number").split(",")
        var valid = ["date", "desktopName", "number"]
        var ordered = []
        for (var i = 0; i < savedOrder.length; ++i)
            if (valid.indexOf(savedOrder[i]) >= 0 && ordered.indexOf(savedOrder[i]) < 0)
                ordered.push(savedOrder[i])
        for (var j = 0; j < valid.length; ++j)
            if (ordered.indexOf(valid[j]) < 0)
                ordered.push(valid[j])
        for (var k = 0; k < ordered.length; ++k) {
            var row = sectionModel.get(k)
            var currentIndex = -1
            for (var n = 0; n < sectionModel.count; ++n)
                if (sectionModel.get(n).key === ordered[k]) currentIndex = n
            if (currentIndex >= 0 && currentIndex !== k) sectionModel.move(currentIndex, k, 1)
        }
        saveSectionOrderProperties()
    }

    function saveSectionOrderProperties() {
        dateSectionOrder = sectionModel.get(0).key === "date" ? 0 : sectionModel.get(1).key === "date" ? 1 : 2
        sectionDesktopNameOrder = sectionModel.get(0).key === "desktopName" ? 0 : sectionModel.get(1).key === "desktopName" ? 1 : 2
        sectionDesktopNumberOrder = sectionModel.get(0).key === "number" ? 0 : sectionModel.get(1).key === "number" ? 1 : 2
    }

    function loadSettings() {
        sectionDateWidth = Number(KDE_plasmoid.Plasmoid.configuration.sectionDateWidth || 3)
        sectionDesktopNameWidth = Number(KDE_plasmoid.Plasmoid.configuration.sectionDesktopNameWidth || 1)
        sectionDesktopNumberWidth = Number(KDE_plasmoid.Plasmoid.configuration.sectionDesktopNumberWidth || 1)
        sectionDateVisible = KDE_plasmoid.Plasmoid.configuration.sectionDateVisible !== false && KDE_plasmoid.Plasmoid.configuration.sectionDateVisible !== "false"
        sectionDesktopNameVisible = KDE_plasmoid.Plasmoid.configuration.sectionDesktopNameVisible !== false && KDE_plasmoid.Plasmoid.configuration.sectionDesktopNameVisible !== "false"
        sectionDesktopNumberVisible = KDE_plasmoid.Plasmoid.configuration.sectionDesktopNumberVisible !== false && KDE_plasmoid.Plasmoid.configuration.sectionDesktopNumberVisible !== "false"
        dateSectionOrder = Number(KDE_plasmoid.Plasmoid.configuration.dateSectionOrder || 0)
        sectionDesktopNameOrder = Number(KDE_plasmoid.Plasmoid.configuration.sectionDesktopNameOrder || 1)
        sectionDesktopNumberOrder = Number(KDE_plasmoid.Plasmoid.configuration.sectionDesktopNumberOrder || 2)
        var listNames = ["dateBackgroundColors", "numberBackgroundColors", "dayNameColors", "daydateBackgroundColors", "numberColors", "desktopNameColors", "desktopNameBackgroundColors", "dayNameFonts", "dayDateFonts", "numberFonts", "desktopNameFonts"]
        for (var l = 0; l < listNames.length; ++l) {
            var stored = KDE_plasmoid.Plasmoid.configuration[listNames[l]]
            if (stored) {
                try { _Root[listNames[l]] = JSON.parse(stored) } catch (e) {}
            }
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

    QTQ.Component.onCompleted: {
        loadSettings()
        loadSectionOrder()
    }

    onSelectedDesktopChanged: {
        if (largePreview.item) {
            largePreview.item.desktopNo = selectedDesktop
            largePreview.item.desktopName = desktopModel.count > selectedDesktop - 1
                    ? desktopModel.get(selectedDesktop - 1).name : qsTr("Desktop %1").arg(selectedDesktop)
        }
    }

    KDE_taskmanager.VirtualDesktopInfo {
        id: desktopInfo
        onNumberOfDesktopsChanged: scheduleDesktopRebuild()
        onDesktopIdsChanged: scheduleDesktopRebuild()
        onDesktopNamesChanged: scheduleDesktopRebuild()
        QTQ.Component.onCompleted: scheduleDesktopRebuild()
    }

    QTQ.Timer {
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

    QTQ.ListModel { id: desktopModel }

    QTQ_L.ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        QTQ_C.Label {
            text: qsTr("Widget sections")
            font.bold: true
            QTQ_L.Layout.topMargin: Kirigami.Units.smallSpacing
        }

        QTQ_C.GroupBox {
            QTQ_L.Layout.fillWidth: true
            contentItem: QTQ_L.ColumnLayout {
                QTQ.ListView {
                    id: sectionList
                    QTQ_L.Layout.fillWidth: true
                    implicitHeight: contentHeight
                    interactive: false
                    model: sectionModel
                    delegate: QTQ.Item {
                        id: sectionDelegate
                        width: sectionList.width
                        height: sectionRow.implicitHeight + Kirigami.Units.smallSpacing

                        SectionSettingsRow {
                            id: sectionRow
                            width: parent.width
                            label: model.label
                            sectionKey: model.key
                            widthValue: _Root.sectionWidthValue(model.key)
                            visibleValue: _Root.sectionVisibleValue(model.key)
                            canMoveUp: index > 0
                            canMoveDown: index < sectionModel.count - 1
                            onWidthSettingChanged: _Root.setSectionWidth(sectionKey, value)
                            onVisibleSettingChanged: _Root.setSectionVisible(sectionKey, value)
                            onMoveUpRequested: {
                                sectionModel.move(index, index - 1, 1)
                                _Root.saveSectionOrder()
                            }
                            onMoveDownRequested: {
                                sectionModel.move(index, index + 1, 1)
                                _Root.saveSectionOrder()
                            }
                        }
                    }
                }
            }
        }

        QTQ_C.Label {
            text: qsTr("Appearance")
            QTQ_L.Layout.fillWidth: true
            font.bold: true
        }

        QTQ_C.ComboBox {
            id: desktopBox
            model: desktopModel
            textRole: "name"
            QTQ_L.Layout.fillWidth: true
            implicitHeight: Kirigami.Units.gridUnit * 3
            delegate: desktopDelegate
            popup: QTQ_C.Popup {
                id: desktopPopup
                y: desktopBox.height
                width: desktopBox.width
                padding: 0
                height: Math.min(desktopModel.count * Kirigami.Units.gridUnit * 3,
                    Kirigami.Units.gridUnit * 20)
                contentItem: QTQ.ListView {
                    anchors.fill: parent
                    clip: true
                    model: desktopModel
                    currentIndex: desktopBox.highlightedIndex
                    delegate: desktopDelegate
                }
            }
        }

        QTQ.Loader {
            id: largePreview
            QTQ_L.Layout.fillWidth: true
            QTQ_L.Layout.preferredHeight: Kirigami.Units.gridUnit * 13
            sourceComponent: widgetPreview
            onLoaded: {
                item.desktopNo = _Root.selectedDesktop
                item.desktopName = desktopModel.count > _Root.selectedDesktop - 1
                        ? desktopModel.get(_Root.selectedDesktop - 1).name
                        : qsTr("Desktop %1").arg(_Root.selectedDesktop)
                item.interactive = true
            }
        }

        QTQ_C.Label {
            text: qsTr("Click an element in the preview to customize it.")
            opacity: 0.7
            QTQ_L.Layout.fillWidth: true
        }
        QTQ.Item { QTQ_L.Layout.fillHeight: true }
    }

    QTQ.Component {
        id: desktopDelegate
        QTQ_C.ItemDelegate {
            width: desktopBox.width
            implicitHeight: Kirigami.Units.gridUnit * 3
            highlighted: desktopBox.highlightedIndex === index
            contentItem: QTQ_L.RowLayout {
                spacing: Kirigami.Units.largeSpacing
                QTQ_C.Label {
                    text: name
                    QTQ_L.Layout.fillWidth: true
                    QTQ_L.Layout.alignment: Qt.AlignVCenter
                    elide: QTQ.Text.ElideRight
                }
                QTQ.Loader {
                    QTQ_L.Layout.preferredWidth: Kirigami.Units.gridUnit * 9
                    QTQ_L.Layout.preferredHeight: Kirigami.Units.gridUnit * 2
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

    QTQ.Component {
        id: widgetPreview
        QTQ.Item {
            id: preview
            property int desktopNo: _Root.selectedDesktop
            property string desktopName: qsTr("Desktop")
            property bool interactive: true
            property real scaleFactor: Math.min(width / 320, height / 120)
            QTQ.Rectangle {
                id: dateBlock
                x: _Root.sectionOffset(_Root.dateSectionOrder, parent.width)
                width: _Root.sectionWidth(_Root.sectionDateWidth, _Root.sectionDateVisible, parent.width)
                height: parent.height
                visible: _Root.sectionDateVisible
                color: _Root.dateBackgroundColors[preview.desktopNo - 1] || "#a0ffa0"
                border.color: dateMouse.containsMouse && !dayNameMouse.containsMouse && !dayDateMouse.containsMouse
                        ? Kirigami.Theme.highlightColor : "transparent"
                border.width: 2
                QTQ.MouseArea {
                    id: dateMouse; anchors.fill: parent; hoverEnabled: true
                    enabled: preview.interactive
                    onClicked: _Root.openColor("date", dateBlock.color)
                }
                QTQ.Text {
                    id: dayNameText
                    anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.locale().toString(new Date(), "dddd")
                    color: _Root.dayNameColors[preview.desktopNo - 1] || "#000000"
                    font.family: _Root.dayNameFonts[preview.desktopNo - 1] || "Inconsolata"
                    font.pixelSize: parent.height * 0.42; font.weight: 400
                    QTQ.Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: dayNameMouse.containsMouse ? Kirigami.Theme.highlightColor : "transparent"
                        border.width: 2
                    }
                }
                QTQ.Text {
                    id: dayDateText
                    anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.locale().toString(new Date(), "dd.MM")
                    color: _Root.daydateBackgroundColors[preview.desktopNo - 1] || "#000000"
                    font.family: _Root.dayDateFonts[preview.desktopNo - 1] || "Cantarell"
                    font.pixelSize: parent.height * 0.42; font.weight: 600
                    QTQ.MouseArea { id: dayDateMouse; anchors.fill: parent; hoverEnabled: true; enabled: preview.interactive; onClicked: _Root.openStyle("dayDate") }
                    QTQ.Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: dayDateMouse.containsMouse ? Kirigami.Theme.highlightColor : "transparent"
                        border.width: 2
                    }
                }
                QTQ.MouseArea { id: dayNameMouse; anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: parent.height / 2; hoverEnabled: true; enabled: preview.interactive; onClicked: _Root.openStyle("dayName") }
            }
            QTQ.Rectangle {
                id: nameBlock
                x: _Root.sectionOffset(_Root.sectionDesktopNameOrder, parent.width)
                width: _Root.sectionWidth(_Root.sectionDesktopNameWidth, _Root.sectionDesktopNameVisible, parent.width)
                height: parent.height
                visible: _Root.sectionDesktopNameVisible
                color: _Root.desktopNameBackgroundColors[preview.desktopNo - 1] || "#a0ffa0"
                border.color: nameMouse.containsMouse && !desktopNameTextMouse.containsMouse
                        ? Kirigami.Theme.highlightColor : "transparent"
                border.width: 2
                QTQ.MouseArea {
                    id: nameMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: preview.interactive
                    onClicked: _Root.openColor("desktopNameBackground", nameBlock.color)
                }
                QTQ_C.Label {
                    anchors.centerIn: parent
                    width: parent.width - Kirigami.Units.smallSpacing * 2
                    text: preview.desktopName
                    color: _Root.desktopNameColors[preview.desktopNo - 1] || "#000000"
                    font.family: _Root.desktopNameFonts[preview.desktopNo - 1] || "Cantarell"
                    horizontalAlignment: QTQ.Text.AlignHCenter
                    elide: QTQ.Text.ElideRight
                    QTQ.MouseArea {
                        id: desktopNameTextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: preview.interactive
                        onClicked: _Root.openStyle("desktopName")
                    }
                    QTQ.Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: desktopNameTextMouse.containsMouse ? Kirigami.Theme.highlightColor : "transparent"
                        border.width: 2
                    }
                }
            }
            QTQ.Rectangle {
                id: numberBlock
                x: _Root.sectionOffset(_Root.sectionDesktopNumberOrder, parent.width)
                width: _Root.sectionWidth(_Root.sectionDesktopNumberWidth, _Root.sectionDesktopNumberVisible, parent.width)
                height: parent.height
                visible: _Root.sectionDesktopNumberVisible
                color: _Root.numberBackgroundColors[preview.desktopNo - 1] || "#000000"
                border.color: numberMouse.containsMouse && !numberTextMouse.containsMouse
                        ? Kirigami.Theme.highlightColor : "transparent"; border.width: 2
                QTQ.MouseArea { id: numberMouse; anchors.fill: parent; hoverEnabled: true; enabled: preview.interactive; onClicked: _Root.openColor("number", numberBlock.color) }
                QTQ.Text {
                    anchors.centerIn: parent; text: preview.desktopNo
                    color: _Root.numberColors[preview.desktopNo - 1] || "#a0ffa0"
                    font.family: _Root.numberFonts[preview.desktopNo - 1] || "Cantarell"
                    font.pixelSize: parent.height * 0.68; font.weight: 700
                    QTQ.MouseArea { id: numberTextMouse; anchors.fill: parent; hoverEnabled: true; enabled: preview.interactive; onClicked: _Root.openStyle("numberText") }
                    QTQ.Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: numberTextMouse.containsMouse ? Kirigami.Theme.highlightColor : "transparent"
                        border.width: 2
                    }
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
                : target === "dayDate" ? daydateBackgroundColors[selectedDesktop - 1]
                : target === "desktopName" ? desktopNameColors[selectedDesktop - 1] : numberColors[selectedDesktop - 1])
                || "#000000"
        styleDialog.open()
    }

    QTQ_C.Dialog {
        id: styleDialog
        title: target === "dayName" ? qsTr("Day name") : target === "dayDate" ? qsTr("Day date")
                : target === "desktopName" ? qsTr("Desktop name") : qsTr("Desktop number")
        standardButtons: QTQ_C.DialogButtonBox.Close
        property string target: ""
        property string fontName: "Cantarell"
        property QTQ.color selectedTextColor: "#000000"
        contentItem: QTQ_L.ColumnLayout {
            spacing: Kirigami.Units.largeSpacing
            QTQ_C.Label { text: qsTr("Text appearance"); QTQ_L.Layout.fillWidth: true }
            QTQ_C.Button {
                text: qsTr("Choose font…")
                QTQ_L.Layout.fillWidth: true
                onClicked: _Root.openFont("styleFont", styleDialog.fontName)
            }
            QTQ_C.Button {
                text: qsTr("Choose text color…")
                QTQ_L.Layout.fillWidth: true
                onClicked: {
                    colorDialog.target = "text"
                    colorDialog.selectedColor = styleDialog.selectedTextColor
                    colorDialog.open()
                }
            }
        }
    }

    QTQ_D.ColorDialog {
        id: colorDialog
        property string target: ""
        onAccepted: {
                if (target === "date") { _Root.dateBackgroundColors = _Root.setAt(_Root.dateBackgroundColors, _Root.selectedDesktop - 1, selectedColor); _Root.save("dateColor", selectedColor) }
            else if (target === "number") { _Root.numberBackgroundColors = _Root.setAt(_Root.numberBackgroundColors, _Root.selectedDesktop - 1, selectedColor); _Root.save("numberColor", selectedColor) }
            else if (target === "desktopNameBackground") { _Root.desktopNameBackgroundColors = _Root.setAt(_Root.desktopNameBackgroundColors, _Root.selectedDesktop - 1, selectedColor); _Root.save("desktopNameBackgroundColor", selectedColor) }
            else {
                styleDialog.selectedTextColor = selectedColor
                if (styleDialog.target === "dayName") { _Root.dayNameColors = _Root.setAt(_Root.dayNameColors, _Root.selectedDesktop - 1, selectedColor); _Root.save("dayNameColor", selectedColor) }
                else if (styleDialog.target === "dayDate") { _Root.daydateBackgroundColors = _Root.setAt(_Root.daydateBackgroundColors, _Root.selectedDesktop - 1, selectedColor); _Root.save("dayDateColor", selectedColor) }
                else if (styleDialog.target === "desktopName") { _Root.desktopNameColors = _Root.setAt(_Root.desktopNameColors, _Root.selectedDesktop - 1, selectedColor); _Root.save("desktopNameColor", selectedColor) }
                else { _Root.numberColors = _Root.setAt(_Root.numberColors, _Root.selectedDesktop - 1, selectedColor); _Root.save("numberTextColor", selectedColor) }
            }
        }
    }

    QTQ_C.Dialog {
        id: fontDialog
        title: qsTr("Choose font")
        standardButtons: QTQ_C.DialogButtonBox.Ok | QTQ_C.DialogButtonBox.Cancel
        property string target: ""
        property string selectedFamily: "Cantarell"
        property string previewText: "Aa"
        onOpened: fontFamilyBox.currentIndex = fontFamilyBox.model.indexOf(selectedFamily)
        contentItem: QTQ_L.ColumnLayout {
            spacing: Kirigami.Units.largeSpacing
            QTQ_C.Label {
                text: fontDialog.previewText
                font.family: fontFamilyBox.currentText || fontDialog.selectedFamily
                font.pixelSize: Kirigami.Units.gridUnit * 1.5
                horizontalAlignment: QTQ.Text.AlignHCenter
                QTQ_L.Layout.fillWidth: true
                wrapMode: QTQ.Text.WordWrap
            }
            QTQ_C.ComboBox {
                id: fontFamilyBox
                model: Qt.fontFamilies()
                currentIndex: -1
                QTQ_L.Layout.fillWidth: true
            }
        }
        onAccepted: {
            var family = fontFamilyBox.currentText
            if (target === "dayName") { _Root.dayNameFonts = _Root.setAt(_Root.dayNameFonts, _Root.selectedDesktop - 1, family); _Root.save("dayNameFont", family) }
            else if (target === "dayDate") { _Root.dayDateFonts = _Root.setAt(_Root.dayDateFonts, _Root.selectedDesktop - 1, family); _Root.save("dayDateFont", family) }
            else if (target === "desktopName") { _Root.desktopNameFonts = _Root.setAt(_Root.desktopNameFonts, _Root.selectedDesktop - 1, family); _Root.save("desktopNameFont", family) }
            else if (target === "numberText") { _Root.numberFonts = _Root.setAt(_Root.numberFonts, _Root.selectedDesktop - 1, family); _Root.save("numberFont", family) }
            else if (target === "styleFont") {
                if (styleDialog.target === "dayName") { _Root.dayNameFonts = _Root.setAt(_Root.dayNameFonts, _Root.selectedDesktop - 1, family); _Root.save("dayNameFont", family) }
                else if (styleDialog.target === "dayDate") { _Root.dayDateFonts = _Root.setAt(_Root.dayDateFonts, _Root.selectedDesktop - 1, family); _Root.save("dayDateFont", family) }
                else if (styleDialog.target === "desktopName") { _Root.desktopNameFonts = _Root.setAt(_Root.desktopNameFonts, _Root.selectedDesktop - 1, family); _Root.save("desktopNameFont", family) }
                else { _Root.numberFonts = _Root.setAt(_Root.numberFonts, _Root.selectedDesktop - 1, family); _Root.save("numberFont", family) }
            }
        }
    }
}