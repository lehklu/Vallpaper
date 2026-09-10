import QtQuick as QTQ
import QtQuick.Controls as QTQ_C
import QtQuick.Dialogs as QTQ_D
import QtQuick.Layouts as QTQ_L
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid as KDE_plasmoid
import org.kde.taskmanager as KDE_taskmanager

QTQ.Item {
  id: _Root

  readonly property var _DEFAULT_COLORS_DARK: ["#071169"]
  readonly property var _DEFAULT_COLORS_LIGHT: ["#ffffff"]

  property var title // for KDE Settings page

  property int selectedDesktop: desktopBox.currentIndex + 1

  property string cfg_sectionOrder: "date,desktopName,desktopNumber"
  onCfg_sectionOrderChanged: loadSectionOrder()

  property int cfg_heightWidthRatio: 50

  property int sectionDateOrderIdx: 0
  property int cfg_sectionDateWidthWeight: 50

  property int sectionDesktopNameOrderIdx: 1
  property int cfg_sectionDesktopNameWidthWeight: 50

  property int sectionDesktopNumberOrderIdx: 2
  property int cfg_sectionDesktopNumberWidthWeight: 50

  property string cfg_dateBackgroundColors: "[]"
  property string cfg_dayNameFonts: "[]"
  property string cfg_dayNameColors: "[]"
  property string cfg_dayNameScales: "[]"
  property string cfg_dayDateFonts: "[]"
  property string cfg_dayDateColors: "[]"
  property string cfg_dayDateScales: "[]"
  property var dateBackgroundColors: _DEFAULT_COLORS_LIGHT
  property var dayNameColors: _DEFAULT_COLORS_DARK
  property var dayDateColors: _DEFAULT_COLORS_DARK
  property var dayNameFonts: ["SansSerif"]
  property var dayDateFonts: ["Serif"]
  property var dayNameScales: [50]
  property var dayDateScales: [50]
  onCfg_dateBackgroundColorsChanged: syncListFromConfig("dateBackgroundColors", cfg_dateBackgroundColors)
  onCfg_dayNameColorsChanged: syncListFromConfig("dayNameColors", cfg_dayNameColors)
  onCfg_dayDateColorsChanged: syncListFromConfig("dayDateColors", cfg_dayDateColors)
  onCfg_dayNameFontsChanged: syncListFromConfig("dayNameFonts", cfg_dayNameFonts)
  onCfg_dayDateFontsChanged: syncListFromConfig("dayDateFonts", cfg_dayDateFonts)
  onCfg_dayNameScalesChanged: syncListFromConfig("dayNameScales", cfg_dayNameScales)
  onCfg_dayDateScalesChanged: syncListFromConfig("dayDateScales", cfg_dayDateScales)

  property string cfg_desktopNameBackgroundColors: "[]"
  property string cfg_desktopNameFonts: "[]"
  property string cfg_desktopNameColors: "[]"
  property string cfg_desktopNameScales: "[]"
  property var desktopNameBackgroundColors: _DEFAULT_COLORS_LIGHT
  property var desktopNameColors: _DEFAULT_COLORS_DARK
  property var desktopNameFonts: ["SansSerif"]
  property var desktopNameScales: [50]
  onCfg_desktopNameBackgroundColorsChanged: syncListFromConfig("desktopNameBackgroundColors", cfg_desktopNameBackgroundColors)
  onCfg_desktopNameColorsChanged: syncListFromConfig("desktopNameColors", cfg_desktopNameColors)
  onCfg_desktopNameFontsChanged: syncListFromConfig("desktopNameFonts", cfg_desktopNameFonts)
  onCfg_desktopNameScalesChanged: syncListFromConfig("desktopNameScales", cfg_desktopNameScales)

  property string cfg_desktopNumberBackgroundColors: "[]"
  property string cfg_desktopNumberFonts: "[]"
  property string cfg_desktopNumberColors: "[]"
  property string cfg_desktopNumberScales: "[]"
  property var desktopNumberBackgroundColors: _DEFAULT_COLORS_DARK
  property var desktopNumberColors: _DEFAULT_COLORS_LIGHT
  property var desktopNumberFonts: ["Serif"]
  property var desktopNumberScales: [50]
  onCfg_desktopNumberBackgroundColorsChanged: syncListFromConfig("desktopNumberBackgroundColors", cfg_desktopNumberBackgroundColors)
  onCfg_desktopNumberColorsChanged: syncListFromConfig("desktopNumberColors", cfg_desktopNumberColors)
  onCfg_desktopNumberFontsChanged: syncListFromConfig("desktopNumberFonts", cfg_desktopNumberFonts)
  onCfg_desktopNumberScalesChanged: syncListFromConfig("desktopNumberScales", cfg_desktopNumberScales)

  function syncListFromConfig(propName, jsonStr) {
    if (jsonStr)
    {
      try
      {
        var parsed = JSON.parse(jsonStr)
        if (Array.isArray(parsed) && parsed.length > 0)
        {
          _Root[propName] = parsed
        }
      }
      catch (e)
      {}
    }
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
    return key === "date" ? cfg_sectionDateWidthWeight : key === "desktopName" ? cfg_sectionDesktopNameWidthWeight : cfg_sectionDesktopNumberWidthWeight
  }

  function setSectionWidth(key, value) {
    if (key === "date")
    {
      cfg_sectionDateWidthWeight = value
    }
    else if (key === "desktopName")
    {
      cfg_sectionDesktopNameWidthWeight = value
    }
    else
    {
      cfg_sectionDesktopNumberWidthWeight = value
    }
  }

  function updateSectionOrder() {
    var order = []
    for (var i = 0; i < sectionModel.count; ++i)
    {
      order.push(sectionModel.get(i).key)
    }
    cfg_sectionOrder = order.join(",")
    saveSectionOrderProperties()
  }

  function loadSectionOrder() {
    var savedOrder = String(cfg_sectionOrder || (KDE_plasmoid.Plasmoid.configuration && KDE_plasmoid.Plasmoid.configuration.sectionOrder) || "date,desktopName,desktopNumber").split(",")
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

  function loadSettings() {
    var listNames = [
      "dateBackgroundColors", "desktopNumberBackgroundColors",
      "dayNameColors", "dayDateColors", "desktopNumberColors",
      "desktopNameColors", "desktopNameBackgroundColors",
      "dayNameFonts", "dayDateFonts", "desktopNumberFonts", "desktopNameFonts",
      "dayNameScales", "dayDateScales", "desktopNameScales", "desktopNumberScales"
    ]
    for (var l = 0; l < listNames.length; ++l)
    {
      var cfgKey = "cfg_" + listNames[l]
      var stored = _Root[cfgKey] || (KDE_plasmoid.Plasmoid.configuration && KDE_plasmoid.Plasmoid.configuration[listNames[l]])
      if (stored)
      {
        try
        {
          var parsed = JSON.parse(stored)
          if (Array.isArray(parsed) && parsed.length > 0)
          {
            _Root[listNames[l]] = parsed
          }
        }
        catch (e)
        {}
      }
    }
  }

  function setAt(list, index, value) {
    var copy = (list && list.slice) ? list.slice() : []
    while (copy.length <= index)
    {
      copy.push(copy[0] !== undefined ? copy[0] : value)
    }
    copy[index] = value
    return copy
  }

  function updateStyleProperty(propName, value) {
    if (linkToggle.checked)
    {
      var count = Math.max(desktopModel.count || 0, (_Root[propName] && _Root[propName].length) || 0, 1)
      var arr = []
      for (var i = 0; i < count; ++i)
      {
        arr.push(value)
      }
      _Root[propName] = arr
      _Root["cfg_" + propName] = JSON.stringify(arr)
    }
    else
    {
      _Root[propName] = setAt(_Root[propName], selectedDesktop - 1, value)
      _Root["cfg_" + propName] = JSON.stringify(_Root[propName])
    }
  }

  function getDesktopStyle(idx) {
    var deskIdx = Math.max(0, idx)
    return {
      type: "DesktopIndicatorStyle",
      dateBackgroundColor: (dateBackgroundColors && dateBackgroundColors[deskIdx]) || _DEFAULT_COLORS_LIGHT[0],
      dayNameColor: (dayNameColors && dayNameColors[deskIdx]) || _DEFAULT_COLORS_DARK[0],
      dayDateColor: (dayDateColors && dayDateColors[deskIdx]) || _DEFAULT_COLORS_DARK[0],
      dayNameFont: (dayNameFonts && dayNameFonts[deskIdx]) || "SansSerif",
      dayDateFont: (dayDateFonts && dayDateFonts[deskIdx]) || "Serif",
      dayNameScale: Number((dayNameScales && dayNameScales[deskIdx]) || 50),
      dayDateScale: Number((dayDateScales && dayDateScales[deskIdx]) || 50),
      desktopNameBackgroundColor: (desktopNameBackgroundColors && desktopNameBackgroundColors[deskIdx]) || _DEFAULT_COLORS_LIGHT[0],
      desktopNameColor: (desktopNameColors && desktopNameColors[deskIdx]) || _DEFAULT_COLORS_DARK[0],
      desktopNameFont: (desktopNameFonts && desktopNameFonts[deskIdx]) || "SansSerif",
      desktopNameScale: Number((desktopNameScales && desktopNameScales[deskIdx]) || 50),
      desktopNumberBackgroundColor: (desktopNumberBackgroundColors && desktopNumberBackgroundColors[deskIdx]) || _DEFAULT_COLORS_DARK[0],
      desktopNumberColor: (desktopNumberColors && desktopNumberColors[deskIdx]) || _DEFAULT_COLORS_LIGHT[0],
      desktopNumberFont: (desktopNumberFonts && desktopNumberFonts[deskIdx]) || "Serif",
      desktopNumberScale: Number((desktopNumberScales && desktopNumberScales[deskIdx]) || 50)
    }
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

    var mapping = [
      { prop: "dateBackgroundColors", val: style.dateBackgroundColor },
      { prop: "dayNameColors", val: style.dayNameColor },
      { prop: "dayDateColors", val: style.dayDateColor },
      { prop: "dayNameFonts", val: style.dayNameFont },
      { prop: "dayDateFonts", val: style.dayDateFont },
      { prop: "dayNameScales", val: style.dayNameScale },
      { prop: "dayDateScales", val: style.dayDateScale },
      { prop: "desktopNameBackgroundColors", val: style.desktopNameBackgroundColor },
      { prop: "desktopNameColors", val: style.desktopNameColor },
      { prop: "desktopNameFonts", val: style.desktopNameFont },
      { prop: "desktopNameScales", val: style.desktopNameScale },
      { prop: "desktopNumberBackgroundColors", val: style.desktopNumberBackgroundColor },
      { prop: "desktopNumberColors", val: style.desktopNumberColor },
      { prop: "desktopNumberFonts", val: style.desktopNumberFont },
      { prop: "desktopNumberScales", val: style.desktopNumberScale }
    ]

    for (var i = 0; i < mapping.length; ++i)
    {
      var m = mapping[i]
      if (m.val !== undefined)
      {
        _Root[m.prop] = setAt(_Root[m.prop], deskIdx, m.val)
        _Root["cfg_" + m.prop] = JSON.stringify(_Root[m.prop])
      }
    }
  }

  function applyStyleToAllDesktops(style) {
    if (!style)
    {
      return
    }
    var count = Math.max(desktopModel.count || 0, 1)
    var mapping = [
      { prop: "dateBackgroundColors", val: style.dateBackgroundColor },
      { prop: "dayNameColors", val: style.dayNameColor },
      { prop: "dayDateColors", val: style.dayDateColor },
      { prop: "dayNameFonts", val: style.dayNameFont },
      { prop: "dayDateFonts", val: style.dayDateFont },
      { prop: "dayNameScales", val: style.dayNameScale },
      { prop: "dayDateScales", val: style.dayDateScale },
      { prop: "desktopNameBackgroundColors", val: style.desktopNameBackgroundColor },
      { prop: "desktopNameColors", val: style.desktopNameColor },
      { prop: "desktopNameFonts", val: style.desktopNameFont },
      { prop: "desktopNameScales", val: style.desktopNameScale },
      { prop: "desktopNumberBackgroundColors", val: style.desktopNumberBackgroundColor },
      { prop: "desktopNumberColors", val: style.desktopNumberColor },
      { prop: "desktopNumberFonts", val: style.desktopNumberFont },
      { prop: "desktopNumberScales", val: style.desktopNumberScale }
    ]

    for (var i = 0; i < mapping.length; ++i)
    {
      var m = mapping[i]
      if (m.val !== undefined)
      {
        var arr = []
        for (var d = 0; d < count; ++d)
        {
          arr.push(m.val)
        }
        _Root[m.prop] = arr
        _Root["cfg_" + m.prop] = JSON.stringify(arr)
      }
    }
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
    var style = getDesktopStyle(selectedDesktop - 1)
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
      applyStyleToDesktop(style, selectedDesktop - 1)
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
    // Use every available source: Plasma versions differ in when these
    // properties become populated while the configuration page starts.
    var ids = desktopInfo.desktopIds || []
    var names = desktopInfo.desktopNames || []
    var count = Math.max(desktopInfo.numberOfDesktops || 0,
        ids.length || 0, names.length || 0, 1)
    for (var i = 0; i < count; ++i)
    {
      var desktopName = desktopInfo.desktopNames && desktopInfo.desktopNames[i]
          ? desktopInfo.desktopNames[i] : qsTr("Desktop %1").arg(i + 1)
      desktopModel.append({name: desktopName, number: i + 1})
    }
    desktopBox.currentIndex = Math.min(Math.max(previousIndex, 0), count - 1)
  }

  QTQ.ListModel { id: desktopModel }

  QTQ_L.ColumnLayout {
    anchors.fill: parent
    anchors.margins: Kirigami.Units.largeSpacing
    spacing: Kirigami.Units.largeSpacing

    QTQ_C.Label {
      text: qsTr("Global")
      font.bold: true
      QTQ_L.Layout.topMargin: Kirigami.Units.smallSpacing
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
        value: _Root.cfg_heightWidthRatio
        onValueModified: {
          _Root.cfg_heightWidthRatio = value
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
        text: qsTr("Link")
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
      QTQ_L.Layout.preferredWidth: QTQ_L.Layout.preferredHeight * (_Root.cfg_heightWidthRatio / 10)
      QTQ_L.Layout.maximumWidth: _Root.width - Kirigami.Units.largeSpacing * 2
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
          QTQ_L.Layout.preferredWidth: Kirigami.Units.gridUnit * 2 * (_Root.cfg_heightWidthRatio / 10)
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
      heightWidthRatio: _Root.cfg_heightWidthRatio
      sectionDateWidthWeight: _Root.cfg_sectionDateWidthWeight
      sectionDesktopNameWidthWeight: _Root.cfg_sectionDesktopNameWidthWeight
      sectionDesktopNumberWidthWeight: _Root.cfg_sectionDesktopNumberWidthWeight
      dateSectionOrder: _Root.sectionDateOrderIdx
      nameSectionOrder: _Root.sectionDesktopNameOrderIdx
      sectionDesktopNumberOrder: _Root.sectionDesktopNumberOrderIdx

      dateBackgroundColor: (_Root.dateBackgroundColors && _Root.dateBackgroundColors[desktopNo - 1]) || _Root._DEFAULT_COLORS_LIGHT[0]
      dayNameColor: (_Root.dayNameColors && _Root.dayNameColors[desktopNo - 1]) || _Root._DEFAULT_COLORS_DARK[0]
      dayDateColor: (_Root.dayDateColors && _Root.dayDateColors[desktopNo - 1]) || _Root._DEFAULT_COLORS_DARK[0]
      dayNameFont: (_Root.dayNameFonts && _Root.dayNameFonts[desktopNo - 1]) || "SansSerif"
      dayDateFont: (_Root.dayDateFonts && _Root.dayDateFonts[desktopNo - 1]) || "Serif"
      dayNameScale: Number((_Root.dayNameScales && _Root.dayNameScales[desktopNo - 1]) || 50)
      dayDateScale: Number((_Root.dayDateScales && _Root.dayDateScales[desktopNo - 1]) || 50)

      desktopNameBackgroundColor: (_Root.desktopNameBackgroundColors && _Root.desktopNameBackgroundColors[desktopNo - 1]) || _Root._DEFAULT_COLORS_LIGHT[0]
      desktopNameColor: (_Root.desktopNameColors && _Root.desktopNameColors[desktopNo - 1]) || _Root._DEFAULT_COLORS_DARK[0]
      desktopNameFont: (_Root.desktopNameFonts && _Root.desktopNameFonts[desktopNo - 1]) || "SansSerif"
      desktopNameScale: Number((_Root.desktopNameScales && _Root.desktopNameScales[desktopNo - 1]) || 50)

      numberBackgroundColor: (_Root.desktopNumberBackgroundColors && _Root.desktopNumberBackgroundColors[desktopNo - 1]) || _Root._DEFAULT_COLORS_DARK[0]
      numberTextColor: (_Root.desktopNumberColors && _Root.desktopNumberColors[desktopNo - 1]) || _Root._DEFAULT_COLORS_LIGHT[0]
      numberFont: (_Root.desktopNumberFonts && _Root.desktopNumberFonts[desktopNo - 1]) || "Serif"
      numberScale: Number((_Root.desktopNumberScales && _Root.desktopNumberScales[desktopNo - 1]) || 50)

      onColorRequested: (target, currentColor) => _Root.openColor(target, currentColor)
      onStyleRequested: (target) => _Root.openStyle(target)
    }
  }

  function openStyle(target) {
    styleDialog.target = target
    styleDialog.fontName = (target === "dayName" ? dayNameFonts[selectedDesktop - 1]
            : target === "dayDate" ? dayDateFonts[selectedDesktop - 1]
                : target === "desktopName" ? desktopNameFonts[selectedDesktop - 1] : desktopNumberFonts[selectedDesktop - 1])
        || (target === "dayName" ? "SansSerif" : "Serif")
    styleDialog.selectedTextColor = (target === "dayName" ? dayNameColors[selectedDesktop - 1]
            : target === "dayDate" ? dayDateColors[selectedDesktop - 1]
                : target === "desktopName" ? desktopNameColors[selectedDesktop - 1] : desktopNumberColors[selectedDesktop - 1])
        || _DEFAULT_COLORS_DARK[0]
    styleDialog.scaleValue = Number((target === "dayName" ? dayNameScales[selectedDesktop - 1]
            : target === "dayDate" ? dayDateScales[selectedDesktop - 1]
                : target === "desktopName" ? desktopNameScales[selectedDesktop - 1] : desktopNumberScales[selectedDesktop - 1])
        || 50)
    styleDialog.open()
  }

  QTQ_C.Dialog {
    id: styleDialog
    parent: largePreview
    anchors.centerIn: undefined
    x: Math.round((largePreview.width - width) / 2)
    y: -height - Kirigami.Units.smallSpacing
    title: target === "dayName" ? qsTr("Day name") : target === "dayDate" ? qsTr("Day date")
        : target === "desktopName" ? qsTr("Desktop name") : qsTr("Desktop number")
    standardButtons: QTQ_C.DialogButtonBox.Close
    property string target: ""
    property string fontName: "Serif"
    property var selectedTextColor: _DEFAULT_COLORS_DARK[0]
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
            if (styleDialog.target === "dayName")
            {
              _Root.updateStyleProperty("dayNameScales", value)
            }
            else if (styleDialog.target === "dayDate")
            {
              _Root.updateStyleProperty("dayDateScales", value)
            }
            else if (styleDialog.target === "desktopName")
            {
              _Root.updateStyleProperty("desktopNameScales", value)
            }
            else
            {
              _Root.updateStyleProperty("desktopNumberScales", value)
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
      if (target === "date")
      {
        _Root.updateStyleProperty("dateBackgroundColors", selectedColor)
      }
      else if (target === "desktopNumber" || target === "number")
      {
        _Root.updateStyleProperty("desktopNumberBackgroundColors", selectedColor)
      }
      else if (target === "desktopNameBackground")
      {
        _Root.updateStyleProperty("desktopNameBackgroundColors", selectedColor)
      }
      else
      {
        styleDialog.selectedTextColor = selectedColor
        if (styleDialog.target === "dayName")
        {
          _Root.updateStyleProperty("dayNameColors", selectedColor)
        }
        else if (styleDialog.target === "dayDate")
        {
          _Root.updateStyleProperty("dayDateColors", selectedColor)
        }
        else if (styleDialog.target === "desktopName")
        {
          _Root.updateStyleProperty("desktopNameColors", selectedColor)
        }
        else
        {
          _Root.updateStyleProperty("desktopNumberColors", selectedColor)
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
    onOpened: fontFamilyBox.currentIndex = fontFamilyBox.model.indexOf(selectedFamily)
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
      if (target === "dayName")
      {
        _Root.updateStyleProperty("dayNameFonts", family)
      }
      else if (target === "dayDate")
      {
        _Root.updateStyleProperty("dayDateFonts", family)
      }
      else if (target === "desktopName")
      {
        _Root.updateStyleProperty("desktopNameFonts", family)
      }
      else if (target === "numberText")
      {
        _Root.updateStyleProperty("desktopNumberFonts", family)
      }
      else if (target === "styleFont")
      {
        if (styleDialog.target === "dayName")
        {
          _Root.updateStyleProperty("dayNameFonts", family)
        }
        else if (styleDialog.target === "dayDate")
        {
          _Root.updateStyleProperty("dayDateFonts", family)
        }
        else if (styleDialog.target === "desktopName")
        {
          _Root.updateStyleProperty("desktopNameFonts", family)
        }
        else
        {
          _Root.updateStyleProperty("desktopNumberFonts", family)
        }
      }
    }
  }
}