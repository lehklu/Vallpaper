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

  property int sectionDateOrderIdx: 0
  property int cfg_sectionDateWidthWeight: 2
  property bool cfg_sectionDateVisible: true

  property int sectionDesktopNameOrderIdx: 1
  property int cfg_sectionDesktopNameWidthWeight: 3
  property bool cfg_sectionDesktopNameVisible: true

  property int sectionDesktopNumberOrderIdx: 2
  property int cfg_sectionDesktopNumberWidthWeight: 1
  property bool cfg_sectionDesktopNumberVisible: true

  property string cfg_dateBackgroundColors: "[]"
  property string cfg_dayNameFonts: "[]"
  property string cfg_dayNameColors: "[]"
  property string cfg_dayDateFonts: "[]"
  property string cfg_dayDateColors: "[]"
  property var dateBackgroundColors: _DEFAULT_COLORS_LIGHT
  property var dayNameColors: _DEFAULT_COLORS_DARK
  property var dayDateColors: _DEFAULT_COLORS_DARK
  property var dayNameFonts: ["SansSerif"]
  property var dayDateFonts: ["Serif"]
  onCfg_dateBackgroundColorsChanged: syncListFromConfig("dateBackgroundColors", cfg_dateBackgroundColors)
  onCfg_dayNameColorsChanged: syncListFromConfig("dayNameColors", cfg_dayNameColors)
  onCfg_dayDateColorsChanged: syncListFromConfig("dayDateColors", cfg_dayDateColors)
  onCfg_dayNameFontsChanged: syncListFromConfig("dayNameFonts", cfg_dayNameFonts)
  onCfg_dayDateFontsChanged: syncListFromConfig("dayDateFonts", cfg_dayDateFonts)

  property string cfg_desktopNameBackgroundColors: "[]"
  property string cfg_desktopNameFonts: "[]"
  property string cfg_desktopNameColors: "[]"
  property var desktopNameBackgroundColors: _DEFAULT_COLORS_LIGHT
  property var desktopNameColors: _DEFAULT_COLORS_DARK
  property var desktopNameFonts: ["SansSerif"]
  onCfg_desktopNameBackgroundColorsChanged: syncListFromConfig("desktopNameBackgroundColors", cfg_desktopNameBackgroundColors)
  onCfg_desktopNameColorsChanged: syncListFromConfig("desktopNameColors", cfg_desktopNameColors)
  onCfg_desktopNameFontsChanged: syncListFromConfig("desktopNameFonts", cfg_desktopNameFonts)

  property string cfg_desktopNumberBackgroundColors: "[]"
  property string cfg_desktopNumberFonts: "[]"
  property string cfg_desktopNumberColors: "[]"
  property var desktopNumberBackgroundColors: _DEFAULT_COLORS_DARK
  property var desktopNumberColors: _DEFAULT_COLORS_LIGHT
  property var desktopNumberFonts: ["Serif"]
  onCfg_desktopNumberBackgroundColorsChanged: syncListFromConfig("desktopNumberBackgroundColors", cfg_desktopNumberBackgroundColors)
  onCfg_desktopNumberColorsChanged: syncListFromConfig("desktopNumberColors", cfg_desktopNumberColors)
  onCfg_desktopNumberFontsChanged: syncListFromConfig("desktopNumberFonts", cfg_desktopNumberFonts)


  function totalSectionsWeigth() {

    return  (cfg_sectionDateVisible ? cfg_sectionDateWidthWeight : 0)
        +   (cfg_sectionDesktopNameVisible ? cfg_sectionDesktopNameWidthWeight : 0)
        +   (cfg_sectionDesktopNumberVisible ? cfg_sectionDesktopNumberWidthWeight : 0)
  }

  function sectionWidth(weight, visible, totalWidth) {

    const totalWeight = totalSectionsWeigth()
    return visible && totalWeight > 0 ? totalWidth * weight / totalWeight : 0
  }

  function sectionOffset(orderIdx, totalWidth) {

    var totalWeight = totalSectionsWeigth()
    if (totalWeight == 0) { return 0 }
    //<--


    var offsetWeight = 0
    if (cfg_sectionDateVisible && sectionDateOrderIdx < orderIdx)
    {
      offsetWeight += cfg_sectionDateWidthWeight;
    }
    if (cfg_sectionDesktopNameVisible && sectionDesktopNameOrderIdx < orderIdx)
    {
      offsetWeight += cfg_sectionDesktopNameWidthWeight;
    }
    if (cfg_sectionDesktopNumberVisible && sectionDesktopNumberOrderIdx < orderIdx)
    {
      offsetWeight += cfg_sectionDesktopNumberWidthWeight;
    }

    return totalWidth * offsetWeight / totalWeight
  }

  component SectionSettingsRow: QTQ_L.RowLayout
  {
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
    QTQ.ListElement { key: "desktopNumber"; label: qsTr("Desktop number") }
  }

  function sectionWidthValue(key) {
    return key === "date" ? cfg_sectionDateWidthWeight : key === "desktopName" ? cfg_sectionDesktopNameWidthWeight : cfg_sectionDesktopNumberWidthWeight
  }

  function sectionVisibleValue(key) {
    return key === "date" ? cfg_sectionDateVisible : key === "desktopName" ? cfg_sectionDesktopNameVisible : cfg_sectionDesktopNumberVisible
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

  function setSectionVisible(key, value) {
    if (key === "date")
    {
      cfg_sectionDateVisible = value
    }
    else if (key === "desktopName")
    {
      cfg_sectionDesktopNameVisible = value
    }
    else
    {
      cfg_sectionDesktopNumberVisible = value
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
      "dayNameFonts", "dayDateFonts", "desktopNumberFonts", "desktopNameFonts"
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
    copy[index] = String(value)
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
    if (largePreview.item)
    {
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
    for (var i = 0; i < count; ++i)
    {
      var desktopName = desktopInfo.desktopNames && desktopInfo.desktopNames[i]
          ? desktopInfo.desktopNames[i] : qsTr("Desktop %1").arg(i + 1)
      desktopModel.append({name: desktopName, number: i + 1})
    }
    desktopBox.currentIndex = Math.min(Math.max(previousIndex, 0), count - 1)
    if (largePreview.item)
    {
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
              visibleValue: _Root.sectionVisibleValue(model.key)
              canMoveUp: index > 0
              canMoveDown: index < sectionModel.count - 1
              onWidthSettingChanged: _Root.setSectionWidth(sectionKey, value)
              onVisibleSettingChanged: _Root.setSectionVisible(sectionKey, value)
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
      popup: QTQ_C.Popup
      {
        id: desktopPopup
        y: desktopBox.height
        width: desktopBox.width
        padding: 0
        height: Math.min(desktopModel.count * Kirigami.Units.gridUnit * 3,
            Kirigami.Units.gridUnit * 20)
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
        x: _Root.sectionOffset(_Root.sectionDateOrderIdx, parent.width)
        width: _Root.sectionWidth(_Root.cfg_sectionDateWidthWeight, _Root.cfg_sectionDateVisible, parent.width)
        height: parent.height
        visible: _Root.cfg_sectionDateVisible
        color: _Root.dateBackgroundColors[preview.desktopNo - 1] || _DEFAULT_COLORS_LIGHT[0]
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
          color: _Root.dayNameColors[preview.desktopNo - 1] || _DEFAULT_COLORS_DARK[0]
          font.family: _Root.dayNameFonts[preview.desktopNo - 1] || "SansSerif"
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
          color: _Root.dayDateColors[preview.desktopNo - 1] || _DEFAULT_COLORS_DARK[0]
          font.family: _Root.dayDateFonts[preview.desktopNo - 1] || "Serif"
          font.pixelSize: parent.height * 0.42; font.weight: 600
          QTQ.MouseArea {
            id:
                dayDateMouse; anchors.fill: parent; hoverEnabled: true; enabled: preview.interactive; onClicked: _Root.openStyle("dayDate")
          }
          QTQ.Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: dayDateMouse.containsMouse ? Kirigami.Theme.highlightColor : "transparent"
            border.width: 2
          }
        }
        QTQ.MouseArea {
          id:
              dayNameMouse; anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: parent.height / 2; hoverEnabled: true; enabled: preview.interactive; onClicked: _Root.openStyle("dayName")
        }
      }
      QTQ.Rectangle {
        id: nameBlock
        x: _Root.sectionOffset(_Root.sectionDesktopNameOrderIdx, parent.width)
        width: _Root.sectionWidth(_Root.cfg_sectionDesktopNameWidthWeight, _Root.cfg_sectionDesktopNameVisible, parent.width)
        height: parent.height
        visible: _Root.cfg_sectionDesktopNameVisible
        color: _Root.desktopNameBackgroundColors[preview.desktopNo - 1] || _DEFAULT_COLORS_LIGHT[0]
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
          color: _Root.desktopNameColors[preview.desktopNo - 1] || _DEFAULT_COLORS_DARK[0]
          font.family: _Root.desktopNameFonts[preview.desktopNo - 1] || "SansSerif"
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
        x: _Root.sectionOffset(_Root.sectionDesktopNumberOrderIdx, parent.width)
        width: _Root.sectionWidth(_Root.cfg_sectionDesktopNumberWidthWeight, _Root.cfg_sectionDesktopNumberVisible, parent.width)
        height: parent.height
        visible: _Root.cfg_sectionDesktopNumberVisible
        color: _Root.desktopNumberBackgroundColors[preview.desktopNo - 1] || _DEFAULT_COLORS_DARK[0]
        border.color: numberMouse.containsMouse && !numberTextMouse.containsMouse
            ? Kirigami.Theme.highlightColor : "transparent"; border.width: 2
        QTQ.MouseArea {
          id:
              numberMouse; anchors.fill: parent; hoverEnabled: true; enabled: preview.interactive; onClicked: _Root.openColor("number", numberBlock.color)
        }
        QTQ.Text {
          anchors.centerIn: parent; text: preview.desktopNo
          color: _Root.desktopNumberColors[preview.desktopNo - 1] || _DEFAULT_COLORS_LIGHT[0]
          font.family: _Root.desktopNumberFonts[preview.desktopNo - 1] || "Serif"
          font.pixelSize: parent.height * 0.68; font.weight: 700
          QTQ.MouseArea {
            id:
                numberTextMouse; anchors.fill: parent; hoverEnabled: true; enabled: preview.interactive; onClicked: _Root.openStyle("numberText")
          }
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
                : target === "desktopName" ? desktopNameFonts[selectedDesktop - 1] : desktopNumberFonts[selectedDesktop - 1])
        || (target === "dayName" ? "SansSerif" : "Serif")
    styleDialog.selectedTextColor = (target === "dayName" ? dayNameColors[selectedDesktop - 1]
            : target === "dayDate" ? dayDateColors[selectedDesktop - 1]
                : target === "desktopName" ? desktopNameColors[selectedDesktop - 1] : desktopNumberColors[selectedDesktop - 1])
        || _DEFAULT_COLORS_DARK[0]
    styleDialog.open()
  }

  QTQ_C.Dialog {
    id: styleDialog
    title: target === "dayName" ? qsTr("Day name") : target === "dayDate" ? qsTr("Day date")
        : target === "desktopName" ? qsTr("Desktop name") : qsTr("Desktop number")
    standardButtons: QTQ_C.DialogButtonBox.Close
    property string target: ""
    property string fontName: "Serif"
    property var selectedTextColor: _DEFAULT_COLORS_DARK[0]
    contentItem: QTQ_L.ColumnLayout
    {
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
      if (target === "date")
      {
        _Root.dateBackgroundColors = _Root.setAt(_Root.dateBackgroundColors, _Root.selectedDesktop - 1, selectedColor);
        _Root.cfg_dateBackgroundColors = JSON.stringify(_Root.dateBackgroundColors)
      }
      else if (target === "desktopNumber" || target === "number")
      {
        _Root.desktopNumberBackgroundColors = _Root.setAt(_Root.desktopNumberBackgroundColors, _Root.selectedDesktop - 1, selectedColor);
        _Root.cfg_desktopNumberBackgroundColors = JSON.stringify(_Root.desktopNumberBackgroundColors)
      }
      else if (target === "desktopNameBackground")
      {
        _Root.desktopNameBackgroundColors = _Root.setAt(_Root.desktopNameBackgroundColors, _Root.selectedDesktop - 1, selectedColor);
        _Root.cfg_desktopNameBackgroundColors = JSON.stringify(_Root.desktopNameBackgroundColors)
      }
      else
      {
        styleDialog.selectedTextColor = selectedColor
        if (styleDialog.target === "dayName")
        {
          _Root.dayNameColors = _Root.setAt(_Root.dayNameColors, _Root.selectedDesktop - 1, selectedColor);
          _Root.cfg_dayNameColors = JSON.stringify(_Root.dayNameColors)
        }
        else if (styleDialog.target === "dayDate")
        {
          _Root.dayDateColors = _Root.setAt(_Root.dayDateColors, _Root.selectedDesktop - 1, selectedColor);
          _Root.cfg_dayDateColors = JSON.stringify(_Root.dayDateColors)
        }
        else if (styleDialog.target === "desktopName")
        {
          _Root.desktopNameColors = _Root.setAt(_Root.desktopNameColors, _Root.selectedDesktop - 1, selectedColor);
          _Root.cfg_desktopNameColors = JSON.stringify(_Root.desktopNameColors)
        }
        else
        {
          _Root.desktopNumberColors = _Root.setAt(_Root.desktopNumberColors, _Root.selectedDesktop - 1, selectedColor);
          _Root.cfg_desktopNumberColors = JSON.stringify(_Root.desktopNumberColors)
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
        _Root.dayNameFonts = _Root.setAt(_Root.dayNameFonts, _Root.selectedDesktop - 1, family);
        _Root.cfg_dayNameFonts = JSON.stringify(_Root.dayNameFonts)
      }
      else if (target === "dayDate")
      {
        _Root.dayDateFonts = _Root.setAt(_Root.dayDateFonts, _Root.selectedDesktop - 1, family);
        _Root.cfg_dayDateFonts = JSON.stringify(_Root.dayDateFonts)
      }
      else if (target === "desktopName")
      {
        _Root.desktopNameFonts = _Root.setAt(_Root.desktopNameFonts, _Root.selectedDesktop - 1, family);
        _Root.cfg_desktopNameFonts = JSON.stringify(_Root.desktopNameFonts)
      }
      else if (target === "numberText")
      {
        _Root.desktopNumberFonts = _Root.setAt(_Root.desktopNumberFonts, _Root.selectedDesktop - 1, family);
        _Root.cfg_desktopNumberFonts = JSON.stringify(_Root.desktopNumberFonts)
      }
      else if (target === "styleFont")
      {
        if (styleDialog.target === "dayName")
        {
          _Root.dayNameFonts = _Root.setAt(_Root.dayNameFonts, _Root.selectedDesktop - 1, family);
          _Root.cfg_dayNameFonts = JSON.stringify(_Root.dayNameFonts)
        }
        else if (styleDialog.target === "dayDate")
        {
          _Root.dayDateFonts = _Root.setAt(_Root.dayDateFonts, _Root.selectedDesktop - 1, family);
          _Root.cfg_dayDateFonts = JSON.stringify(_Root.dayDateFonts)
        }
        else if (styleDialog.target === "desktopName")
        {
          _Root.desktopNameFonts = _Root.setAt(_Root.desktopNameFonts, _Root.selectedDesktop - 1, family);
          _Root.cfg_desktopNameFonts = JSON.stringify(_Root.desktopNameFonts)
        }
        else
        {
          _Root.desktopNumberFonts = _Root.setAt(_Root.desktopNumberFonts, _Root.selectedDesktop - 1, family);
          _Root.cfg_desktopNumberFonts = JSON.stringify(_Root.desktopNumberFonts)
        }
      }
    }
  }
}