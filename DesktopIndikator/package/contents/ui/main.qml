/*
 *  Copyright 2026  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick as QTQ
import QtQml as QML
import QtQuick.Layouts as QTQ_L
import org.kde.plasma.plasmoid as KDE_plasmoid
import org.kde.taskmanager as KDE_taskmanager

import "../js/desktopindikator.js" as JSLIB

KDE_plasmoid.PlasmoidItem {
  id: _Root

  clip: true

  readonly property var _DEFAULT_COLORS_DARK: ["#071169"]
  readonly property var _DEFAULT_COLORS_LIGHT: ["#ffffff"]
  readonly property string _DEFAULT_DARK_COLOR: "#071169"
  readonly property string _DEFAULT_LIGHT_COLOR: "#ffffff"
  readonly property string _DEFAULT_SANS_FONT: "Sans Serif"
  readonly property string _DEFAULT_Serif_FONT: "Serif"
  readonly property real _DEFAULT_SCALE: 50

  property int _configurationChangedDependencyTrigger: 0

  readonly property var _parsedConfiguration: {
    var _rev = _configurationChangedDependencyTrigger
    var raw = KDE_plasmoid.Plasmoid.configuration ? KDE_plasmoid.Plasmoid.configuration.desktopindikator01 : ""
    return JSLIB.parseConfiguration(raw)
  }

  function getConfig(key, fallback) {
    var _rev = _configurationChangedDependencyTrigger
    return JSLIB.getConfig(_parsedConfiguration, KDE_plasmoid.Plasmoid.configuration, key, fallback)
  }

  function getDesktopConfig(listName, deskIndex, fallback) {
    var _rev = _configurationChangedDependencyTrigger
    return JSLIB.getDesktopConfig(_parsedConfiguration, KDE_plasmoid.Plasmoid.configuration, listName, deskIndex, fallback)
  }

  property real _heightWidthRatio: Number(getConfig("heightWidthRatio", 50))
  property int _fullWidth: Math.round(height * _heightWidthRatio / 10)
  property real _sectionDateWidthWeight: Number(getConfig("sectionDateWidthWeight", 50))
  property real _sectionDesktopNameWidthWeight: Number(getConfig("sectionDesktopNameWidthWeight", 50))
  property real _sectionDesktopNumberWidthWeight: Number(getConfig("sectionDesktopNumberWidthWeight", 50))
  property string _sectionOrder: String(getConfig("sectionOrder", "date,desktopName,desktopNumber"))

  property date _currentDate: new Date()
  property int _currentDesktopNo: 0
  property string _currentDesktopName: ""

  readonly property int _currentDeskIndex: _currentDesktopNo

  property var _currentDeskColor: getDesktopConfig("dateBackgroundColors", _currentDeskIndex, _DEFAULT_LIGHT_COLOR)
  property var _currentNumberColor: getDesktopConfig("desktopNumberBackgroundColors", _currentDeskIndex, _DEFAULT_DARK_COLOR)
  property var _currentDayNameColor: getDesktopConfig("dayNameColors", _currentDeskIndex, _DEFAULT_DARK_COLOR)
  property var _currentDayDateColor: getDesktopConfig("dayDateColors", _currentDeskIndex, _DEFAULT_DARK_COLOR)
  property var _currentDesktopNameColor: getDesktopConfig("desktopNameColors", _currentDeskIndex, _DEFAULT_DARK_COLOR)
  property var _currentDesktopNameBackgroundColor: getDesktopConfig("desktopNameBackgroundColors", _currentDeskIndex, _DEFAULT_LIGHT_COLOR)
  property var _currentNumberTextColor: getDesktopConfig("desktopNumberColors", _currentDeskIndex, _DEFAULT_LIGHT_COLOR)
  property string _currentDayNameFont: getDesktopConfig("dayNameFonts", _currentDeskIndex, _DEFAULT_SANS_FONT)
  property string _currentDayDateFont: getDesktopConfig("dayDateFonts", _currentDeskIndex, _DEFAULT_Serif_FONT)
  property string _currentDesktopNameFont: getDesktopConfig("desktopNameFonts", _currentDeskIndex, _DEFAULT_SANS_FONT)
  property string _currentNumberFont: getDesktopConfig("desktopNumberFonts", _currentDeskIndex, _DEFAULT_Serif_FONT)
  property real _currentDayNameScale: Number(getDesktopConfig("dayNameScales", _currentDeskIndex, _DEFAULT_SCALE))
  property real _currentDayDateScale: Number(getDesktopConfig("dayDateScales", _currentDeskIndex, _DEFAULT_SCALE))
  property real _currentDesktopNameScale: Number(getDesktopConfig("desktopNameScales", _currentDeskIndex, _DEFAULT_SCALE))
  property real _currentNumberScale: Number(getDesktopConfig("desktopNumberScales", _currentDeskIndex, _DEFAULT_SCALE))

  QML.Connections {
    target: KDE_plasmoid.Plasmoid.configuration

    function onValueChanged() {
      _Root._configurationChangedDependencyTrigger++
    }

    function onDesktopindikator01Changed() {
      _Root._configurationChangedDependencyTrigger++
    }

    function onConfigurationChanged() {
      _Root._configurationChangedDependencyTrigger++
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
      return JSLIB.GET_CURRENT_DESKNO(desktopInfo)
    }
  }

  QTQ.Timer {
    id: desktopSyncTimer
    interval: 0
    onTriggered: desktopInfo.broadcastDesktopChanged()
  }

  function handleOnDesktopChanged(newDeskNo) {
    JSLIB.handleOnDesktopChanged(_Root, desktopInfo, newDeskNo)
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

    sectionOrder: _Root._sectionOrder

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