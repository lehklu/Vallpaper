/*
 *  Copyright 2026  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick as QTQ
import QtQml as QML
import QtQuick.Layouts as QTQ_L
import org.kde.plasma.plasmoid as KDE_plasmoid
import org.kde.taskmanager as KDE_taskmanager

KDE_plasmoid.PlasmoidItem {
  id: _Root

  clip: true

  readonly property var _DEFAULT_COLORS_DARK: ["#071169"]
  readonly property var _DEFAULT_COLORS_LIGHT: ["#ffffff"]
  readonly property string _DEFAULT_DARK_COLOR: "#071169"
  readonly property string _DEFAULT_LIGHT_COLOR: "#ffffff"
  readonly property string _DEFAULT_SANS_FONT: "SansSerif"
  readonly property string _DEFAULT_SERIF_FONT: "Serif"
  readonly property real _DEFAULT_SCALE: 50

  property int _configurationRevision: 0

  function getConfig(key, fallback) {
    var _rev = _configurationRevision
    var val = KDE_plasmoid.Plasmoid.configuration[key]
    return val !== undefined && val !== null ? val : fallback
  }

  function getDesktopConfig(listName, deskIndex, fallback) {
    var _rev = _configurationRevision
    var stored = KDE_plasmoid.Plasmoid.configuration[listName]
    if (stored)
    {
      try
      {
        var values = JSON.parse(stored)
        if (Array.isArray(values) && deskIndex >= 0 && deskIndex < values.length &&
            values[deskIndex] !== undefined && values[deskIndex] !== null && values[deskIndex] !== "")
        {
          return values[deskIndex]
        }
      }
      catch (e)
      {}
    }
    return fallback
  }

  function sectionOrderIndex(section, fallback) {
    var order = String(getConfig("sectionOrder", "date,desktopName,desktopNumber")).split(",")
    var index = order.indexOf(section)
    return index >= 0 ? index : fallback
  }

  property real _heightWidthRatio: Number(getConfig("heightWidthRatio", 50))
  property int _fullWidth: Math.round(height * _heightWidthRatio / 10)
  property real _sectionDateWidthWeight: Number(getConfig("sectionDateWidthWeight", 50))
  property real _sectionDesktopNameWidthWeight: Number(getConfig("sectionDesktopNameWidthWeight", 50))
  property real _sectionDesktopNumberWidthWeight: Number(getConfig("sectionDesktopNumberWidthWeight", 50))
  property int _dateSectionOrder: sectionOrderIndex("date", 0)
  property int _nameSectionOrder: sectionOrderIndex("desktopName", 1)
  property int _sectionDesktopNumberOrder: sectionOrderIndex("desktopNumber", 2)

  property date _currentDate: new Date()
  property int _currentDesktopNo: 0
  property string _currentDesktopName: ""

  readonly property int _currentDeskIndex: _currentDesktopNo - 1

  property var _currentDeskColor: getDesktopConfig("dateBackgroundColors", _currentDeskIndex, _DEFAULT_LIGHT_COLOR)
  property var _currentNumberColor: getDesktopConfig("desktopNumberBackgroundColors", _currentDeskIndex, _DEFAULT_DARK_COLOR)
  property var _currentDayNameColor: getDesktopConfig("dayNameColors", _currentDeskIndex, _DEFAULT_DARK_COLOR)
  property var _currentDayDateColor: getDesktopConfig("dayDateColors", _currentDeskIndex, _DEFAULT_DARK_COLOR)
  property var _currentDesktopNameColor: getDesktopConfig("desktopNameColors", _currentDeskIndex, _DEFAULT_DARK_COLOR)
  property var _currentDesktopNameBackgroundColor: getDesktopConfig("desktopNameBackgroundColors", _currentDeskIndex, _DEFAULT_LIGHT_COLOR)
  property var _currentNumberTextColor: getDesktopConfig("desktopNumberColors", _currentDeskIndex, _DEFAULT_LIGHT_COLOR)
  property string _currentDayNameFont: getDesktopConfig("dayNameFonts", _currentDeskIndex, _DEFAULT_SANS_FONT)
  property string _currentDayDateFont: getDesktopConfig("dayDateFonts", _currentDeskIndex, _DEFAULT_SERIF_FONT)
  property string _currentDesktopNameFont: getDesktopConfig("desktopNameFonts", _currentDeskIndex, _DEFAULT_SANS_FONT)
  property string _currentNumberFont: getDesktopConfig("desktopNumberFonts", _currentDeskIndex, _DEFAULT_SERIF_FONT)
  property real _currentDayNameScale: Number(getDesktopConfig("dayNameScales", _currentDeskIndex, _DEFAULT_SCALE))
  property real _currentDayDateScale: Number(getDesktopConfig("dayDateScales", _currentDeskIndex, _DEFAULT_SCALE))
  property real _currentDesktopNameScale: Number(getDesktopConfig("desktopNameScales", _currentDeskIndex, _DEFAULT_SCALE))
  property real _currentNumberScale: Number(getDesktopConfig("desktopNumberScales", _currentDeskIndex, _DEFAULT_SCALE))

  QML.Connections {
    target: KDE_plasmoid.Plasmoid.configuration

    function onValueChanged() {
      _Root._configurationRevision++
    }
  }

  width: _fullWidth
  implicitWidth: _fullWidth
  QTQ_L.Layout.minimumWidth: _fullWidth
  QTQ_L.Layout.preferredWidth: _fullWidth
  QTQ_L.Layout.maximumWidth: _fullWidth
  QTQ_L.Layout.fillHeight: true

  KDE_taskmanager.VirtualDesktopInfo {
    id: desktopInfo

    QTQ.Component.onCompleted: scheduleDesktopSync()

    onCurrentDesktopChanged: scheduleDesktopSync()
    onDesktopIdsChanged: scheduleDesktopSync()
    onNumberOfDesktopsChanged: scheduleDesktopSync()
    onDesktopNamesChanged: scheduleDesktopSync()

    function scheduleDesktopSync() {
      desktopSyncTimer.restart()
    }

    function broadcastDesktopChanged() {
      _Root.handleOnDesktopChanged(getCurrentDeskNo())
    }

    function getCurrentDeskNo() {
      const currentId = currentDesktop
      const ids = desktopIds || []
      const idx = ids.indexOf(currentId)
      return idx >= 0 ? idx + 1 : 0
    }
  }

  QTQ.Timer {
    id: desktopSyncTimer
    interval: 0
    onTriggered: desktopInfo.broadcastDesktopChanged()
  }

  function handleOnDesktopChanged(newDeskNo) {
    if (newDeskNo < 1)
    {
      return
    }
    _Root._currentDesktopNo = newDeskNo
    var names = desktopInfo.desktopNames || []
    _Root._currentDesktopName = (names && names[newDeskNo - 1])
        ? names[newDeskNo - 1]
        : qsTr("Desktop %1").arg(newDeskNo)
  }

  QTQ.Timer {
    interval: 1000 * 10 // sec
    running: true
    repeat: true
    triggeredOnStart: true

    onTriggered: { _currentDate = new Date() }
  }

  DesktopIndicator {
    anchors.fill: parent
    heightWidthRatio: _Root._heightWidthRatio
    desktopNo: _Root._currentDesktopNo
    desktopName: _Root._currentDesktopName
    currentDate: _Root._currentDate
    interactive: false

    sectionDateWidthWeight: _Root._sectionDateWidthWeight
    sectionDesktopNameWidthWeight: _Root._sectionDesktopNameWidthWeight
    sectionDesktopNumberWidthWeight: _Root._sectionDesktopNumberWidthWeight

    dateSectionOrder: _Root._dateSectionOrder
    nameSectionOrder: _Root._nameSectionOrder
    sectionDesktopNumberOrder: _Root._sectionDesktopNumberOrder

    dateBackgroundColor: _Root._currentDeskColor
    dayNameColor: _Root._currentDayNameColor
    dayDateColor: _Root._currentDayDateColor
    dayNameFont: _Root._currentDayNameFont
    dayDateFont: _Root._currentDayDateFont
    dayNameScale: _Root._currentDayNameScale
    dayDateScale: _Root._currentDayDateScale

    desktopNameBackgroundColor: _Root._currentDesktopNameBackgroundColor
    desktopNameColor: _Root._currentDesktopNameColor
    desktopNameFont: _Root._currentDesktopNameFont
    desktopNameScale: _Root._currentDesktopNameScale

    numberBackgroundColor: _Root._currentNumberColor
    numberTextColor: _Root._currentNumberTextColor
    numberFont: _Root._currentNumberFont
    numberScale: _Root._currentNumberScale
  }
}
