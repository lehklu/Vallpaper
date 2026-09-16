/*
 *  Copyright 2026  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick as QTQ
import QtQuick.Controls as QTQ_C
import QtQuick.Dialogs as QTQ_D
import QtQuick.Layouts as QTQ_L
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid as KDE_plasmoid
import org.kde.taskmanager as KDE_taskmanager

import "../js/v.js" as VJS

QTQ.Item { id: _Root

  property var title // for KDE Settings page

  property string cfg_desktopindikator601
  onCfg_desktopindikator601Changed: {

    if(_isSaving) { return; }
    //<--

    loadConfiguration(cfg_desktopindikator601)
  }

  property bool _isSaving: false
  property int _selectedDesktopNo: desktopBox.currentIndex + 1

  property string _sectionOrder
  on_SectionOrderChanged: loadSectionOrder()

  property int heightWidthRatio: 50

  property int sectionDateWidthWeight: 50
  property int sectionDesktopNameWidthWeight: 50
  property int sectionDesktopNumberWidthWeight: 50

  readonly property var _DEFAULT_COLORS_LIGHT: ["#ffffff"]
  readonly property var _DEFAULT_COLORS_DARK: ["#071169"]

  property var dateBackgroundColors: ["#ffffff"]
  property var dayNameColors: ["#071169"]
  property var dayDateColors: ["#071169"]
  property var dayNameFonts: ["Sans Serif"]
  property var dayDateFonts: ["Serif"]
  property var dayNameScales: [50]
  property var dayDateScales: [50]

  property var desktopNameBackgroundColors: ["#ffffff"]
  property var desktopNameColors: ["#071169"]
  property var desktopNameFonts: ["Sans Serif"]
  property var desktopNameScales: [50]

  property var desktopNumberBackgroundColors: ["#071169"]
  property var desktopNumberColors: ["#ffffff"]
  property var desktopNumberFonts: ["Serif"]
  property var desktopNumberScales: [50]

  readonly property var _STYLE_PROPERTIES: [
    { prop: "dateBackgroundColors", key: "dateBackgroundColor" },
    { prop: "dayNameColors", key: "dayNameColor" },
    { prop: "dayDateColors", key: "dayDateColor" },
    { prop: "dayNameFonts", key: "dayNameFont" },
    { prop: "dayDateFonts", key: "dayDateFont" },
    { prop: "dayNameScales", key: "dayNameScale" },
    { prop: "dayDateScales", key: "dayDateScale" },
    { prop: "desktopNameBackgroundColors", key: "desktopNameBackgroundColor" },
    { prop: "desktopNameColors", key: "desktopNameColor" },
    { prop: "desktopNameFonts", key: "desktopNameFont" },
    { prop: "desktopNameScales", key: "desktopNameScale" },
    { prop: "desktopNumberBackgroundColors", key: "desktopNumberBackgroundColor" },
    { prop: "desktopNumberColors", key: "desktopNumberColor" },
    { prop: "desktopNumberFonts", key: "desktopNumberFont" },
    { prop: "desktopNumberScales", key: "desktopNumberScale" }
  ]

  readonly property var _STYLE_TARGETS: ({
    "dayName": {
      title: qsTr("Day name"),
      fontProp: "dayNameFonts",
      colorProp: "dayNameColors",
      scaleProp: "dayNameScales",
      defaultFont: "Sans Serif",
      defaultColor: "#071169",
      previewText: () => Qt.locale().toString(new Date(), "dddd")
    },
    "dayDate": {
      title: qsTr("Day date"),
      fontProp: "dayDateFonts",
      colorProp: "dayDateColors",
      scaleProp: "dayDateScales",
      defaultFont: "Serif",
      defaultColor: "#071169",
      previewText: () => Qt.locale().toString(new Date(), "dd.MM")
    },
    "desktopName": {
      title: qsTr("Desktop name"),
      fontProp: "desktopNameFonts",
      colorProp: "desktopNameColors",
      scaleProp: "desktopNameScales",
      defaultFont: "Sans Serif",
      defaultColor: "#071169",
      previewText: () => {
        var idx = _Root._selectedDesktopNo - 1
        return (idx >= 0 && idx < desktopModel.count && desktopModel.get(idx))
            ? desktopModel.get(idx).name : qsTr("Desktop %1").arg(_Root._selectedDesktopNo)
      }
    },
    "desktopNumber": {
      title: qsTr("Desktop number"),
      fontProp: "desktopNumberFonts",
      colorProp: "desktopNumberColors",
      scaleProp: "desktopNumberScales",
      defaultFont: "Serif",
      defaultColor: "#ffffff",
      previewText: () => String(_Root._selectedDesktopNo)
    }
  })

  readonly property var _BG_TARGET_PROPS: ({
    "date": "dateBackgroundColors",
    "desktopNameBackground": "desktopNameBackgroundColors",
    "number": "desktopNumberBackgroundColors",
    "desktopNumber": "desktopNumberBackgroundColors"
  })

  function syncListFromConfig(propName, jsonStrOrArray) {
    VJS.syncListFromConfig(_Root, propName, jsonStrOrArray)
  }

  function ensureDesktopValue(list, desktopNo) {
    return VJS.ensureDesktopValue(list, desktopNo)
  }

  function ensureDesktopProperty(propName, desktopNo) {
    return VJS.ensureDesktopProperty(_Root, propName, desktopNo)
  }

  component SectionSettingsRow: QTQ_L.RowLayout
  {
    property string label
    property string sectionKey
    property int widthValue: 50
    property bool canMoveUp: false
    property bool canMoveDown: false

    signal widthSettingChanged(int value)
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
    QTQ_C.Label { text: parent.label; font.family: 'monospace'; QTQ_L.Layout.fillWidth: true }
    QTQ_C.Label { text: qsTr("Width weight") }
    QTQ_C.SpinBox {
      from: 0
      to: 100
      value: parent.widthValue
      onValueModified: {
        parent.widthValue = value
        parent.widthSettingChanged(value)
      }
    }
  }

  QTQ.ListModel {
    id: sectionModel
    QTQ.ListElement { key: "date"; label: qsTr("Date") }
    QTQ.ListElement { key: "desktopName"; label: qsTr("Desktop name") }
    QTQ.ListElement { key: "desktopNumber"; label: qsTr("Desktop number") }
  }

  function sectionWidthValue(key) {
    return VJS.sectionWidthValue(_Root, key)
  }

  function setSectionWidth(key, value) {
    VJS.setSectionWidth(_Root, key, value)
  }

  function updateSectionOrder() {
    VJS.updateSectionOrder(sectionModel, _Root)
  }

  function loadSectionOrder() {
    VJS.loadSectionOrder(_Root, sectionModel)
  }

  function loadConfiguration(jsonStr) {
    VJS.loadConfiguration(_Root, jsonStr, KDE_plasmoid.Plasmoid.configuration)
  }

  function saveConfiguration() {
    VJS.saveConfiguration(_Root)
  }

  function setAt(list, index, value) {
    return VJS.setAt(list, index, value)
  }

  function updateStyleProperty(propName, value) {
    VJS.updateStyleProperty(_Root, linkToggle.checked, desktopModel.count, _selectedDesktopNo, propName, value)
  }

  function getDesktopStyle(idx) {
    return VJS.getDesktopStyle(_Root, idx)
  }

  function applyStyleToDesktop(style, deskIdx) {
    VJS.applyStyleToDesktop(_Root, linkToggle.checked, desktopModel.count, style, deskIdx)
  }

  function applyStyleToAllDesktops(style) {
    VJS.applyStyleToAllDesktops(_Root, desktopModel.count, style)
  }

  QTQ.TextEdit {
    id: clipboardHelper
    visible: false
    activeFocusOnPress: false
  }

  property bool hasValidClipboardContent: false
  property var lastCopiedStyle: null

  function getClipboardText() {
    return VJS.getClipboardText(clipboardHelper)
  }

  function parseStyleFromText(str) {
    return VJS.parseStyleFromText(str)
  }

  function checkClipboard() {
    VJS.checkClipboard(clipboardHelper, _Root)
  }

  function copySelectedDesktopStyle() {
    VJS.copySelectedDesktopStyle(_Root, clipboardHelper, _selectedDesktopNo)
  }

  function pasteDesktopStyle() {
    VJS.pasteDesktopStyle(_Root, clipboardHelper, _selectedDesktopNo, lastCopiedStyle)
  }

  QTQ.Timer {
    id: clipboardCheckTimer
    interval: 1000
    running: true
    repeat: true
    onTriggered: checkClipboard()
  }

  function openColor(target, current) {
    VJS.openColor(colorDialog, target, current)
  }

  function openFont(target, current) {
    VJS.openFont(fontDialog, styleDialog, _STYLE_TARGETS, target, current, _selectedDesktopNo)
  }

  QTQ.Component.onCompleted: {
    loadConfiguration()
    checkClipboard()
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
    VJS.rebuildDesktops(desktopBox, desktopModel, desktopInfo)
  }

  QTQ.ListModel { id: desktopModel }

  QTQ_L.ColumnLayout {
    anchors.fill: parent
    anchors.margins: Kirigami.Units.largeSpacing
    spacing: Kirigami.Units.largeSpacing

    QTQ_L.RowLayout {

      QTQ_C.Label {
        text: qsTr("Global")
        font.bold: true
        QTQ_L.Layout.fillWidth: true
      }

      QTQ_C.Button { id: _BtnDonate

        text: 'Donate with PayPal'
        leftPadding: 14
        rightPadding: 14
        topPadding: 8
        bottomPadding: 8
        contentItem: QTQ_C.Label {
          text: _BtnDonate.text
          font.pointSize: parent.font.pointSize * 0.8
          font.bold: true
          color: '#ffffff'
          horizontalAlignment: QTQ.Text.AlignHCenter
          verticalAlignment: QTQ.Text.AlignVCenter
        }
        background: QTQ.Rectangle {
          radius: 4
          color: _BtnDonate.pressed ? '#005a94' : (_BtnDonate.hovered ? '#005ea6' : '#0070ba')
        }
        onClicked: Qt.openUrlExternally('https://www.paypal.com/donate/?hosted_button_id=HCRS5TNRLE4QQ')
      }
    }

    QTQ_L.RowLayout {
      QTQ_L.Layout.alignment: Qt.AlignHCenter

      QTQ_C.Label {
        text: qsTr("Height/width ratio")
      }
      QTQ_C.Label {
        text: "10 :"
      }
      QTQ_C.SpinBox {
        from: 1
        to: 100
        value: _Root.heightWidthRatio
        onValueModified: {
          _Root.heightWidthRatio = value
          _Root.saveConfiguration()
        }
      }
    }

    QTQ_C.GroupBox {
      QTQ_L.Layout.preferredWidth: Kirigami.Units.gridUnit * 25
      QTQ_L.Layout.alignment: Qt.AlignHCenter
      contentItem: QTQ_L.ColumnLayout
      {
        QTQ.ListView {
          id: sectionList
          QTQ_L.Layout.fillWidth: true
          implicitHeight: contentHeight
          interactive: false
          model: sectionModel
          delegate: QTQ.Item
          {
            id: sectionDelegate
            width: sectionList.width
            height: sectionRow.implicitHeight + Kirigami.Units.smallSpacing

            SectionSettingsRow {
              id: sectionRow
              width: parent.width
              label: model.label
              sectionKey: model.key
              widthValue: _Root.sectionWidthValue(model.key)
              canMoveUp: index > 0
              canMoveDown: index < sectionModel.count - 1
              onWidthSettingChanged: _Root.setSectionWidth(sectionKey, value)
              onMoveUpRequested: {
                sectionModel.move(index, index - 1, 1)
                _Root.updateSectionOrder()
              }
              onMoveDownRequested: {
                sectionModel.move(index, index + 1, 1)
                _Root.updateSectionOrder()
              }
            }
          }
        }
      }
    }

    QTQ_L.RowLayout {
      QTQ_L.Layout.fillWidth: true
      QTQ_L.Layout.topMargin: Kirigami.Units.largeSpacing
      spacing: Kirigami.Units.smallSpacing

      QTQ_C.Label {
        text: qsTr("Per desktop")
        font.bold: !linkToggle.checked

        QTQ.MouseArea {
          anchors.fill: parent
          onClicked: linkToggle.checked = false
        }
      }

      QTQ_C.Switch {
        id: linkToggle
        font.bold: checked
        text: qsTr("Linked")
        QTQ_L.Layout.alignment: Qt.AlignVCenter
      }
    }



      QTQ_C.ComboBox {
        id: desktopBox
        model: desktopModel
        textRole: "name"
        QTQ_L.Layout.fillWidth: true
        QTQ_L.Layout.leftMargin: Kirigami.Units.largeSpacing
        QTQ_L.Layout.rightMargin: Kirigami.Units.largeSpacing
        enabled: !linkToggle.checked
        implicitHeight: Kirigami.Units.gridUnit * 3
        delegate: desktopDelegate
        popup: QTQ_C.Popup
        {
          id: desktopPopup
          y: desktopBox.height
          width: desktopBox.width
          padding: 0
          height: Math.min(desktopModel.count * Kirigami.Units.gridUnit * 3, _Root.height - largePreview.y)
          contentItem: QTQ.ListView
          {
            anchors.fill: parent
            clip: true
            model: desktopModel
            currentIndex: desktopBox.highlightedIndex
            delegate: desktopDelegate
          }
        }
      }

    QTQ_L.RowLayout {
      QTQ_L.Layout.alignment: Qt.AlignHCenter
      spacing: Kirigami.Units.largeSpacing

      QTQ_C.Button {
        id: copyButton
        text: qsTr("Copy")
        onClicked: _Root.copySelectedDesktopStyle()
      }

      QTQ_C.Button {
        id: pasteButton
        text: qsTr("Paste")
        enabled: _Root.hasValidClipboardContent
        onClicked: _Root.pasteDesktopStyle()
      }
    }

    QTQ.Loader {
      id: largePreview
      QTQ_L.Layout.alignment: Qt.AlignHCenter
      QTQ_L.Layout.preferredHeight: QTQ_L.Layout.preferredWidth / (_Root.heightWidthRatio / 10)
      QTQ_L.Layout.preferredWidth: _Root.width / 6 * 5
      QTQ_L.Layout.maximumWidth: _Root.width - Kirigami.Units.largeSpacing * 2
      QTQ_L.Layout.margins: Kirigami.Units.largeSpacing * 2
      sourceComponent: widgetPreview
      onLoaded: {
        item.interactive = true
        item.desktopNo = Qt.binding(function() { return _Root._selectedDesktopNo })
        item.desktopName = Qt.binding(function() {
          var idx = _Root._selectedDesktopNo - 1
          return (idx >= 0 && idx < desktopModel.count && desktopModel.get(idx))
              ? desktopModel.get(idx).name : qsTr("Desktop %1").arg(_Root._selectedDesktopNo)
        })
      }

      QTQ.Rectangle {
        visible: linkToggle.checked
        anchors.fill: parent
        anchors.margins: - Kirigami.Units.largeSpacing * 2
        color: "transparent"
        border.color: Kirigami.Theme.highlightColor
        border.width: Kirigami.Units.largeSpacing
        radius: Kirigami.Units.largeSpacing
      }
    }

    QTQ.Item { QTQ_L.Layout.fillHeight: true }
  }

  QTQ.Component {
    id: desktopDelegate
    QTQ_C.ItemDelegate {
      width: desktopBox.width
      implicitHeight: Kirigami.Units.gridUnit * 3
      highlighted: desktopBox.highlightedIndex === index
      contentItem: QTQ_L.RowLayout
      {
        spacing: Kirigami.Units.largeSpacing
        QTQ_C.Label {
          text: name
          QTQ_L.Layout.fillWidth: true
          QTQ_L.Layout.alignment: Qt.AlignVCenter
          elide: QTQ.Text.ElideRight
        }
        QTQ.Loader {
          QTQ_L.Layout.preferredWidth: Kirigami.Units.gridUnit * 2 * (_Root.heightWidthRatio / 10)
          QTQ_L.Layout.preferredHeight: Kirigami.Units.gridUnit * 2
          sourceComponent: widgetPreview
          onLoaded: {
            item.desktopNo = Qt.binding(function() { return number })
            item.desktopName = Qt.binding(function() { return name })
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
    DesktopIndicator {
      anchors.fill: parent
      heightWidthRatio: _Root.heightWidthRatio
      sectionDateWidthWeight: _Root.sectionDateWidthWeight
      sectionDesktopNameWidthWeight: _Root.sectionDesktopNameWidthWeight
      sectionDesktopNumberWidthWeight: _Root.sectionDesktopNumberWidthWeight
      sectionOrder: _Root._sectionOrder

      dateBackgroundColor: _Root.ensureDesktopValue(_Root.dateBackgroundColors, desktopNo)
      dayNameColor: _Root.ensureDesktopValue(_Root.dayNameColors, desktopNo)
      dayDateColor: _Root.ensureDesktopValue(_Root.dayDateColors, desktopNo)
      dayNameFont: _Root.ensureDesktopValue(_Root.dayNameFonts, desktopNo) || "Sans Serif"
      dayDateFont: _Root.ensureDesktopValue(_Root.dayDateFonts, desktopNo) || "Serif"
      dayNameScale: Number(_Root.ensureDesktopValue(_Root.dayNameScales, desktopNo) || 50)
      dayDateScale: Number(_Root.ensureDesktopValue(_Root.dayDateScales, desktopNo) || 50)

      desktopNameBackgroundColor: _Root.ensureDesktopValue(_Root.desktopNameBackgroundColors, desktopNo)
      desktopNameColor: _Root.ensureDesktopValue(_Root.desktopNameColors, desktopNo)
      desktopNameFont: _Root.ensureDesktopValue(_Root.desktopNameFonts, desktopNo) || "Sans Serif"
      desktopNameScale: Number(_Root.ensureDesktopValue(_Root.desktopNameScales, desktopNo) || 50)

      numberBackgroundColor: _Root.ensureDesktopValue(_Root.desktopNumberBackgroundColors, desktopNo)
      numberTextColor: _Root.ensureDesktopValue(_Root.desktopNumberColors, desktopNo)
      numberFont: _Root.ensureDesktopValue(_Root.desktopNumberFonts, desktopNo) || "Serif"
      numberScale: Number(_Root.ensureDesktopValue(_Root.desktopNumberScales, desktopNo) || 50)

      onColorRequested: (target, currentColor) => _Root.openColor(target, currentColor)
      onStyleRequested: (target) => _Root.openStyle(target)
    }
  }

  function openStyle(target) {
    VJS.openStyle(styleDialog, _Root, _STYLE_TARGETS, _selectedDesktopNo, target)
  }

  QTQ_C.Dialog {
    id: styleDialog
    parent: largePreview
    anchors.centerIn: undefined
    x: Math.round((largePreview.width - width) / 2)
    y: -height - Kirigami.Units.smallSpacing
    property string target: ""
    property string fontName: "Serif"
    property var selectedTextColor
    property int scaleValue: 50
    contentItem: QTQ_L.ColumnLayout
    {
      implicitWidth: Kirigami.Units.gridUnit * 18
      spacing: Kirigami.Units.largeSpacing
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
      QTQ_L.RowLayout {
        QTQ_L.Layout.fillWidth: true
        QTQ_C.Label {
          text: qsTr("Scale relative to parent height")
          QTQ_L.Layout.fillWidth: true
        }
        QTQ_C.SpinBox {
          from: 1
          to: 200
          value: styleDialog.scaleValue
          onValueModified: {
            styleDialog.scaleValue = value
            var targetKey = styleDialog.target === "numberText" ? "desktopNumber" : styleDialog.target
            var info = _STYLE_TARGETS[targetKey]
            if (info)
            {
              _Root.updateStyleProperty(info.scaleProp, value)
            }
          }
          QTQ_L.Layout.preferredWidth: Kirigami.Units.gridUnit * 5
        }
      }
    }
  }

  QTQ_D.ColorDialog {
    id: colorDialog
    property string target: ""
    onAccepted: {
      var bgProp = _BG_TARGET_PROPS[target]
      if (bgProp)
      {
        _Root.updateStyleProperty(bgProp, selectedColor)
      }
      else
      {
        styleDialog.selectedTextColor = selectedColor
        var targetKey = styleDialog.target === "numberText" ? "desktopNumber" : styleDialog.target
        var info = _STYLE_TARGETS[targetKey]
        if (info)
        {
          _Root.updateStyleProperty(info.colorProp, selectedColor)
        }
      }
    }
  }

  QTQ_C.Dialog {
    id: fontDialog
    title: qsTr("Choose font")
    standardButtons: QTQ_C.DialogButtonBox.Ok | QTQ_C.DialogButtonBox.Cancel
    property string target: ""
    property string selectedFamily: "Serif"
    property string previewText: "Aa"
    onOpened: {
      var families = fontFamilyBox.model || []
      fontFamilyBox.currentIndex = families.indexOf(selectedFamily)
    }
    contentItem: QTQ_L.ColumnLayout
    {
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
      if (!family)
      {
        return
      }
      var targetKey = target === "styleFont" ? styleDialog.target : target
      if (targetKey === "numberText")
      {
        targetKey = "desktopNumber"
      }
      var info = _STYLE_TARGETS[targetKey]
      if (info)
      {
        _Root.updateStyleProperty(info.fontProp, family)
        styleDialog.fontName = family
      }
    }
  }
}