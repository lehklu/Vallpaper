/*
 *  Copyright 2026  Werner Lechner <werner.lechner@lehklu.at>
 */
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

QTQ.Item { id: _Root

  property var title // for KDE Settings page

  property int selectedDesktop: desktopBox.currentIndex + 1

  property string cfg_desktopindikator601: "{}"
  property bool _isSaving: false
  onCfg_desktopindikator601Changed: {
    if (!_isSaving)
    {
      loadConfiguration(cfg_desktopindikator601)
    }
  }

  property string sectionOrder: "date,desktopName,desktopNumber"
  onSectionOrderChanged: loadSectionOrder()

  property int heightWidthRatio: 50

  property int sectionDateOrderIdx: 0
  property int sectionDateWidthWeight: 50

  property int sectionDesktopNameOrderIdx: 1
  property int sectionDesktopNameWidthWeight: 50

  property int sectionDesktopNumberOrderIdx: 2
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
        var idx = _Root.selectedDesktop - 1
        return (idx >= 0 && idx < desktopModel.count && desktopModel.get(idx))
            ? desktopModel.get(idx).name : qsTr("Desktop %1").arg(_Root.selectedDesktop)
      }
    },
    "desktopNumber": {
      title: qsTr("Desktop number"),
      fontProp: "desktopNumberFonts",
      colorProp: "desktopNumberColors",
      scaleProp: "desktopNumberScales",
      defaultFont: "Serif",
      defaultColor: "#ffffff",
      previewText: () => String(_Root.selectedDesktop)
    }
  })

  readonly property var _BG_TARGET_PROPS: ({
    "date": "dateBackgroundColors",
    "desktopNameBackground": "desktopNameBackgroundColors",
    "number": "desktopNumberBackgroundColors",
    "desktopNumber": "desktopNumberBackgroundColors"
  })

  function syncListFromConfig(propName, jsonStrOrArray) {
    if (jsonStrOrArray === undefined || jsonStrOrArray === null || jsonStrOrArray === "")
    {
      return
    }
    if (Array.isArray(jsonStrOrArray))
    {
      if (jsonStrOrArray.length > 0)
      {
        _Root[propName] = jsonStrOrArray.slice()
      }
      return
    }
    if (typeof jsonStrOrArray === "string")
    {
      try
      {
        var parsed = JSON.parse(jsonStrOrArray)
        if (Array.isArray(parsed) && parsed.length > 0)
        {
          _Root[propName] = parsed
          return
        }
      }
      catch (e)
      {}
      _Root[propName] = [jsonStrOrArray]
      return
    }
    _Root[propName] = [jsonStrOrArray]
  }

  function ensureDesktopValue(list, desktopNo) {
    var idx = desktopNo
    if (list && idx > 0 && idx < list.length && list[idx] !== undefined && list[idx] !== null && list[idx] !== "")
    {
      return list[idx]
    }
    return (list && list.length > 0) ? list[0] : undefined
  }

  function ensureDesktopProperty(propName, desktopNo) {
    return ensureDesktopValue(_Root[propName], desktopNo)
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
    QTQ_C.Label { text: parent.label; QTQ_L.Layout.fillWidth: true }
    QTQ_C.Label { text: qsTr("Width weight") }
    QTQ_C.SpinBox {
      from: 0
      to: 100
      value: parent.widthValue
      onValueModified: {
        parent.widthValue = value
        parent.widthSettingChanged(value)
      }
      QTQ_L.Layout.preferredWidth: Kirigami.Units.gridUnit * 5
    }
  }

  QTQ.ListModel {
    id: sectionModel
    QTQ.ListElement { key: "date"; label: qsTr("Date") }
    QTQ.ListElement { key: "desktopName"; label: qsTr("Desktop name") }
    QTQ.ListElement { key: "desktopNumber"; label: qsTr("Desktop number") }
  }

  function sectionWidthValue(key) {
    if (key === "date")
    {
      return sectionDateWidthWeight
    }
    if (key === "desktopName")
    {
      return sectionDesktopNameWidthWeight
    }
    return sectionDesktopNumberWidthWeight
  }

  function setSectionWidth(key, value) {
    if (key === "date")
    {
      sectionDateWidthWeight = value
    }
    else if (key === "desktopName")
    {
      sectionDesktopNameWidthWeight = value
    }
    else
    {
      sectionDesktopNumberWidthWeight = value
    }
    saveConfiguration()
  }

  function updateSectionOrder() {
    var order = []
    for (var i = 0; i < sectionModel.count; ++i)
    {
      order.push(sectionModel.get(i).key)
    }
    sectionOrder = order.join(",")
    saveSectionOrderProperties()
    saveConfiguration()
  }

  function loadSectionOrder() {
    var savedOrder = String(sectionOrder || "date,desktopName,desktopNumber").split(",")
    var valid = ["date", "desktopName", "desktopNumber"]
    var ordered = []
    for (var i = 0; i < savedOrder.length; ++i)
    {
      if (valid.indexOf(savedOrder[i]) >= 0 && ordered.indexOf(savedOrder[i]) < 0)
      {
        ordered.push(savedOrder[i])
      }
    }
    for (var j = 0; j < valid.length; ++j)
    {
      if (ordered.indexOf(valid[j]) < 0)
      {
        ordered.push(valid[j])
      }
    }
    for (var k = 0; k < ordered.length; ++k)
    {
      var currentIndex = -1
      for (var n = 0; n < sectionModel.count; ++n)
      {
        if (sectionModel.get(n).key === ordered[k])
        {
          currentIndex = n
          break
        }
      }
      if (currentIndex >= 0 && currentIndex !== k)
      {
        sectionModel.move(currentIndex, k, 1)
      }
    }
    saveSectionOrderProperties()
  }

  function saveSectionOrderProperties() {
    var dateIdx = -1, nameIdx = -1, numIdx = -1
    for (var i = 0; i < sectionModel.count; ++i)
    {
      if (sectionModel.get(i).key === "date")
      {
        dateIdx = i
      }
      else if (sectionModel.get(i).key === "desktopName")
      {
        nameIdx = i
      }
      else if (sectionModel.get(i).key === "desktopNumber")
      {
        numIdx = i
      }
    }
    sectionDateOrderIdx = dateIdx >= 0 ? dateIdx : 0
    sectionDesktopNameOrderIdx = nameIdx >= 0 ? nameIdx : 1
    sectionDesktopNumberOrderIdx = numIdx >= 0 ? numIdx : 2
  }

  function loadConfiguration(jsonStr) {
    var raw = jsonStr || cfg_desktopindikator601 || (KDE_plasmoid.Plasmoid.configuration && KDE_plasmoid.Plasmoid.configuration.desktopindikator601) || ""
    var configObj = {}
    if (raw)
    {
      try
      {
        configObj = JSON.parse(raw) || {}
      }
      catch (e)
      {}
    }

    if (configObj.heightWidthRatio !== undefined)
    {
      _Root.heightWidthRatio = configObj.heightWidthRatio
    }
    else if (KDE_plasmoid.Plasmoid.configuration && KDE_plasmoid.Plasmoid.configuration.heightWidthRatio !== undefined)
    {
      _Root.heightWidthRatio = KDE_plasmoid.Plasmoid.configuration.heightWidthRatio
    }

    if (configObj.sectionOrder !== undefined)
    {
      _Root.sectionOrder = configObj.sectionOrder
    }
    else if (KDE_plasmoid.Plasmoid.configuration && KDE_plasmoid.Plasmoid.configuration.sectionOrder !== undefined)
    {
      _Root.sectionOrder = KDE_plasmoid.Plasmoid.configuration.sectionOrder
    }

    if (configObj.sectionDateWidthWeight !== undefined)
    {
      _Root.sectionDateWidthWeight = configObj.sectionDateWidthWeight
    }
    else if (KDE_plasmoid.Plasmoid.configuration && KDE_plasmoid.Plasmoid.configuration.sectionDateWidthWeight !== undefined)
    {
      _Root.sectionDateWidthWeight = KDE_plasmoid.Plasmoid.configuration.sectionDateWidthWeight
    }

    if (configObj.sectionDesktopNameWidthWeight !== undefined)
    {
      _Root.sectionDesktopNameWidthWeight = configObj.sectionDesktopNameWidthWeight
    }
    else if (KDE_plasmoid.Plasmoid.configuration && KDE_plasmoid.Plasmoid.configuration.sectionDesktopNameWidthWeight !== undefined)
    {
      _Root.sectionDesktopNameWidthWeight = KDE_plasmoid.Plasmoid.configuration.sectionDesktopNameWidthWeight
    }

    if (configObj.sectionDesktopNumberWidthWeight !== undefined)
    {
      _Root.sectionDesktopNumberWidthWeight = configObj.sectionDesktopNumberWidthWeight
    }
    else if (KDE_plasmoid.Plasmoid.configuration && KDE_plasmoid.Plasmoid.configuration.sectionDesktopNumberWidthWeight !== undefined)
    {
      _Root.sectionDesktopNumberWidthWeight = KDE_plasmoid.Plasmoid.configuration.sectionDesktopNumberWidthWeight
    }

    for (var l = 0; l < _STYLE_PROPERTIES.length; ++l)
    {
      var propName = _STYLE_PROPERTIES[l].prop
      if (configObj[propName] !== undefined)
      {
        syncListFromConfig(propName, configObj[propName])
      }
      else if (KDE_plasmoid.Plasmoid.configuration && KDE_plasmoid.Plasmoid.configuration[propName] !== undefined)
      {
        syncListFromConfig(propName, KDE_plasmoid.Plasmoid.configuration[propName])
      }
    }

    loadSectionOrder()
  }

  function saveConfiguration() {
    var configObj = {
      heightWidthRatio: _Root.heightWidthRatio,
      sectionOrder: _Root.sectionOrder,
      sectionDateWidthWeight: _Root.sectionDateWidthWeight,
      sectionDesktopNameWidthWeight: _Root.sectionDesktopNameWidthWeight,
      sectionDesktopNumberWidthWeight: _Root.sectionDesktopNumberWidthWeight
    }
    for (var l = 0; l < _STYLE_PROPERTIES.length; ++l)
    {
      var propName = _STYLE_PROPERTIES[l].prop
      var valList = _Root[propName]
      if (Array.isArray(valList))
      {
        configObj[propName] = valList.map(v => (v && typeof v === "object" && v.toString) ? v.toString() : v)
      }
      else
      {
        configObj[propName] = valList
      }
    }
    var jsonStr = JSON.stringify(configObj)
    if (_Root.cfg_desktopindikator601 !== jsonStr)
    {
      _isSaving = true
      _Root.cfg_desktopindikator601 = jsonStr
      _isSaving = false
    }
  }

  function setAt(list, index, value) {
    var copy = (list && Array.isArray(list)) ? list.slice() : []
    var defaultVal = (copy.length > 0 && copy[0] !== undefined) ? copy[0] : value
    while (copy.length <= index)
    {
      copy.push(defaultVal)
    }
    copy[index] = value
    return copy
  }

  function updateStyleProperty(propName, value) {
    var stringVal = (value && typeof value === "object" && value.toString) ? value.toString() : value
    if (linkToggle.checked)
    {
      var count = Math.max(desktopModel.count || 0, (_Root[propName] && _Root[propName].length ? _Root[propName].length - 1 : 0), 1)
      var arr = []
      for (var i = 0; i <= count; ++i)
      {
        arr.push(stringVal)
      }
      _Root[propName] = arr
    }
    else
    {
      _Root[propName] = setAt(_Root[propName], selectedDesktop, stringVal)
    }
    saveConfiguration()
  }

  function getDesktopStyle(idx) {
    var deskIdx = Math.max(0, idx)
    var result = { type: "DesktopIndicatorStyle" }
    for (var i = 0; i < _STYLE_PROPERTIES.length; ++i)
    {
      var item = _STYLE_PROPERTIES[i]
      var val = ensureDesktopProperty(item.prop, deskIdx)
      result[item.key] = (val && typeof val === "object" && val.toString) ? val.toString() : val
    }
    return result
  }

  function applyStyleToDesktop(style, deskIdx) {
    if (!style)
    {
      return
    }
    if (linkToggle.checked)
    {
      applyStyleToAllDesktops(style)
      return
    }
    for (var i = 0; i < _STYLE_PROPERTIES.length; ++i)
    {
      var item = _STYLE_PROPERTIES[i]
      var val = style[item.key]
      if (val !== undefined)
      {
        var stringVal = (val && typeof val === "object" && val.toString) ? val.toString() : val
        _Root[item.prop] = setAt(_Root[item.prop], deskIdx, stringVal)
      }
    }
    saveConfiguration()
  }

  function applyStyleToAllDesktops(style) {
    if (!style)
    {
      return
    }
    var count = Math.max(desktopModel.count || 0, 1)
    for (var i = 0; i < _STYLE_PROPERTIES.length; ++i)
    {
      var item = _STYLE_PROPERTIES[i]
      var val = style[item.key]
      if (val !== undefined)
      {
        var stringVal = (val && typeof val === "object" && val.toString) ? val.toString() : val
        var arr = []
        for (var d = 0; d <= count; ++d)
        {
          arr.push(stringVal)
        }
        _Root[item.prop] = arr
      }
    }
    saveConfiguration()
  }

  QTQ.TextEdit {
    id: clipboardHelper
    visible: false
    activeFocusOnPress: false
  }

  property bool hasValidClipboardContent: false
  property var lastCopiedStyle: null

  function getClipboardText() {
    clipboardHelper.text = ""
    clipboardHelper.selectAll()
    clipboardHelper.paste()
    return clipboardHelper.text
  }

  function parseStyleFromText(str) {
    if (!str || typeof str !== "string")
    {
      return null
    }
    try
    {
      var obj = JSON.parse(str)
      if (obj && typeof obj === "object")
      {
        if (obj.type === "DesktopIndicatorStyle")
        {
          return obj
        }
        if (obj.dateBackgroundColor !== undefined ||
            obj.dayNameColor !== undefined ||
            obj.desktopNumberBackgroundColor !== undefined ||
            obj.desktopNameColor !== undefined)
        {
          return obj
        }
      }
    }
    catch (e)
    {}
    return null
  }

  function checkClipboard() {
    var text = getClipboardText()
    hasValidClipboardContent = parseStyleFromText(text) !== null
  }

  function copySelectedDesktopStyle() {
    var style = getDesktopStyle(selectedDesktop)
    clipboardHelper.text = JSON.stringify(style)
    clipboardHelper.selectAll()
    clipboardHelper.copy()
    lastCopiedStyle = style
    checkClipboard()
  }

  function pasteDesktopStyle() {
    var text = getClipboardText()
    var style = parseStyleFromText(text) || lastCopiedStyle
    if (style)
    {
      applyStyleToDesktop(style, selectedDesktop)
    }
  }

  QTQ.Timer {
    id: clipboardCheckTimer
    interval: 1000
    running: true
    repeat: true
    onTriggered: checkClipboard()
  }

  function openColor(target, current) {
    colorDialog.target = target
    colorDialog.selectedColor = current
    colorDialog.open()
  }

  function openFont(target, current) {
    fontDialog.target = target
    fontDialog.selectedFamily = current
    var styleTarget = target === "styleFont" ? styleDialog.target : target
    var targetKey = styleTarget === "numberText" ? "desktopNumber" : styleTarget
    var info = _STYLE_TARGETS[targetKey]
    fontDialog.previewText = info ? info.previewText() : String(selectedDesktop)
    fontDialog.open()
  }

  QTQ.Component.onCompleted: {
    loadConfiguration()
    checkClipboard()
  }

  onSelectedDesktopChanged: {
    if (largePreview.item)
    {
      largePreview.item.interactive = true
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
    var ids = desktopInfo.desktopIds || []
    var names = desktopInfo.desktopNames || []
    var count = Math.max(desktopInfo.numberOfDesktops || 0,
        ids.length || 0, names.length || 0, 1)
    for (var i = 0; i < count; ++i)
    {
      var desktopName = (names && names[i])
          ? names[i] : qsTr("Desktop %1").arg(i + 1)
      desktopModel.append({name: desktopName, number: i + 1})
    }
    desktopBox.currentIndex = Math.min(Math.max(previousIndex, 0), count - 1)
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
        QTQ_L.Layout.topMargin: Kirigami.Units.smallSpacing
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

    QTQ_C.GroupBox {
      QTQ_L.Layout.fillWidth: true
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
      QTQ_C.Label {
        text: qsTr("Height/width ratio")
        QTQ_L.Layout.fillWidth: true
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
        QTQ_L.Layout.preferredWidth: Kirigami.Units.gridUnit * 5
      }
    }

    QTQ_C.Label {
      text: qsTr("Per desktop")
      QTQ_L.Layout.fillWidth: true
      font.bold: true
    }

    QTQ_L.RowLayout {
      QTQ_L.Layout.fillWidth: true
      spacing: Kirigami.Units.smallSpacing

      QTQ_C.ComboBox {
        id: desktopBox
        model: desktopModel
        textRole: "name"
        QTQ_L.Layout.fillWidth: true
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

      QTQ_C.Switch {
        id: linkToggle
        text: qsTr("Linked")
        QTQ_L.Layout.alignment: Qt.AlignVCenter
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
      QTQ_L.Layout.preferredHeight: Kirigami.Units.gridUnit * 6
      QTQ_L.Layout.preferredWidth: QTQ_L.Layout.preferredHeight * (_Root.heightWidthRatio / 10)
      QTQ_L.Layout.maximumWidth: _Root.width - Kirigami.Units.largeSpacing * 2
      QTQ_L.Layout.margins: Kirigami.Units.largeSpacing * 2
      sourceComponent: widgetPreview
      onLoaded: {
        item.interactive = true
        item.desktopNo = Qt.binding(function() { return _Root.selectedDesktop })
        item.desktopName = Qt.binding(function() {
          var idx = _Root.selectedDesktop - 1
          return (idx >= 0 && idx < desktopModel.count && desktopModel.get(idx))
              ? desktopModel.get(idx).name : qsTr("Desktop %1").arg(_Root.selectedDesktop)
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
      dateSectionOrder: _Root.sectionDateOrderIdx
      nameSectionOrder: _Root.sectionDesktopNameOrderIdx
      sectionDesktopNumberOrder: _Root.sectionDesktopNumberOrderIdx

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
    var targetKey = target === "numberText" ? "desktopNumber" : target
    var info = _STYLE_TARGETS[targetKey]
    var deskIdx = selectedDesktop
    styleDialog.target = target
    styleDialog.title = info ? info.title : qsTr("Style")
    styleDialog.fontName = (_Root.ensureDesktopProperty(info.fontProp, deskIdx)) || (info ? info.defaultFont : "Sans Serif")
    styleDialog.selectedTextColor = (_Root.ensureDesktopProperty(info.colorProp, deskIdx)) || (info ? info.defaultColor : "#071169")
    styleDialog.scaleValue = Number((_Root.ensureDesktopProperty(info.scaleProp, deskIdx)) || 50)
    styleDialog.open()
  }

  QTQ_C.Dialog {
    id: styleDialog
    parent: largePreview
    anchors.centerIn: undefined
    x: Math.round((largePreview.width - width) / 2)
    y: -height - Kirigami.Units.smallSpacing
    standardButtons: QTQ_C.DialogButtonBox.Close
    property string target: ""
    property string fontName: "Serif"
    property var selectedTextColor
    property int scaleValue: 50
    contentItem: QTQ_L.ColumnLayout
    {
      implicitWidth: Kirigami.Units.gridUnit * 18
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