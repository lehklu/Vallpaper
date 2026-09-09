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

  property real _heightWidthRatio: Number(configurationValue("heightWidthRatio", 50))
  property int _fullWidth: Math.round(height * _heightWidthRatio / 10)
  property real _sectionDateWidthWeight: Number(configurationValue("sectionDateWidthWeight", 50))
  property real _nameSectionWidth: Number(configurationValue("sectionDesktopNameWidthWeight", 50))
  property real _sectionDesktopNumberWidthWeight: Number(configurationValue("sectionDesktopNumberWidthWeight", 50))
  property int _dateSectionOrder: sectionOrderIndex("date", 0)
  property int _nameSectionOrder: sectionOrderIndex("desktopName", 1)
  property int _sectionDesktopNumberOrder: sectionOrderIndex("desktopNumber", 2)

  property var _defaultDeskColors: [
    "#a0ffa0",
    "#a8a8ff",
    "#ff97ff",
    "#ffff8f",
    "#ffffff",
    "#41f2f2"
  ]
  property date _currentDate: new Date()
  property int _currentDesktopNo: 0
  property string _currentDesktopName: ""
  property int _configurationRevision: 0
  property var _currentDeskColor: configurationValue("dateColor" + _currentDesktopNo,
      _defaultDeskColors[(_currentDesktopNo - 1 + 6) % 6])
  property var _currentNumberColor: configurationValue("numberColor" + _currentDesktopNo, "#000000")
  property var _currentDayNameColor: configurationValue("dayNameColor" + _currentDesktopNo, "#000000")
  property var _currentDayDateColor: configurationValue("dayDateColor" + _currentDesktopNo, "#000000")
  property var _currentDesktopNameColor: configurationValue("desktopNameColor" + _currentDesktopNo, "#000000")
  property var _currentDesktopNameBackgroundColor: configurationValue("desktopNameBackgroundColor" + _currentDesktopNo,
      _defaultDeskColors[(_currentDesktopNo - 1 + 6) % 6])
  property var _currentNumberTextColor: configurationValue("numberTextColor" + _currentDesktopNo,
      _defaultDeskColors[(_currentDesktopNo - 1 + 6) % 6])
  property string _currentDayNameFont: configurationValue("dayNameFont" + _currentDesktopNo, "Inconsolata")
  property string _currentDayDateFont: configurationValue("dayDateFont" + _currentDesktopNo, "Cantarell")
  property string _currentDesktopNameFont: configurationValue("desktopNameFont" + _currentDesktopNo, "Cantarell")
  property string _currentNumberFont: configurationValue("numberFont" + _currentDesktopNo, "Cantarell")
  property real _currentDayNameScale: Number(configurationValue("dayNameScale" + _currentDesktopNo, 50))
  property real _currentDayDateScale: Number(configurationValue("dayDateScale" + _currentDesktopNo, 50))
  property real _currentDesktopNameScale: Number(configurationValue("desktopNameScale" + _currentDesktopNo, 50))
  property real _currentNumberScale: Number(configurationValue("numberScale" + _currentDesktopNo, 50))

  function configurationValue(key, fallback) {
    // Keep this dependency so configuration changes refresh every current
    // appearance property, including dynamically named desktop settings.
    var revision = _configurationRevision
    var match = key.match(/^(.*?)([0-9]+)$/)
    if (match)
    {
      var keyPrefix = match[1]
      var deskIndex = Number(match[2]) - 1
      var candidateListNames = [
          keyPrefix + "s",
            keyPrefix === "dateColor" ? "dateBackgroundColors" : "",
            keyPrefix === "numberColor" ? "desktopNumberBackgroundColors" : "",
            keyPrefix === "numberTextColor" ? "desktopNumberColors" : "",
            keyPrefix === "numberFont" ? "desktopNumberFonts" : "",
            keyPrefix === "numberScale" ? "desktopNumberScales" : ""
      ]
      for (var i = 0; i < candidateListNames.length; ++i)
      {
        var listName = candidateListNames[i]
        if (!listName)
        {
          continue
        }
        var stored = KDE_plasmoid.Plasmoid.configuration[listName]
        if (stored)
        {
          try
          {
            var values = JSON.parse(stored)
            if (values && values[deskIndex] !== undefined && values[deskIndex] !== null && values[deskIndex] !== "")
            {
              return values[deskIndex]
            }
          }
          catch (e)
          {}
        }
      }
      return fallback
    }
    var val = KDE_plasmoid.Plasmoid.configuration[key]
    return val !== undefined && val !== null ? val : fallback
  }

  function sectionOrderIndex(section, fallback) {
    var order = String(configurationValue("sectionOrder", "date,desktopName,desktopNumber")).split(",")
    var index = order.indexOf(section)
    return index >= 0 ? index : fallback
  }

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

    QTQ.Component.onCompleted: scheduleDesktopSync();

    onCurrentDesktopChanged: scheduleDesktopSync();
    onDesktopIdsChanged: scheduleDesktopSync();
    onNumberOfDesktopsChanged: scheduleDesktopSync();
    onDesktopNamesChanged: scheduleDesktopSync();

    function scheduleDesktopSync() {
      desktopSyncTimer.restart();
    }

    function broadcastDesktopChanged() {

      _Root.handleOnDesktopChanged(getCurrentDeskNo());
    }

    function getCurrentDeskNo() {

      const currentId = currentDesktop;
      const ids = desktopIds;

      if (!ids.length || currentId === undefined || currentId === null)
      {
        return 0;
      }

      let idx = 0;

      for (; idx < ids.length; idx++)
      {
        if (ids[idx] == currentId)
        { break; }
        //<--


      }

      return idx < ids.length ? idx + 1 : 0;
    }
  }

  QTQ.Timer {
    id: desktopSyncTimer
    interval: 0
    onTriggered: desktopInfo.broadcastDesktopChanged()
  }

  function handleOnDesktopChanged($currentDesktopNo) {
    if ($currentDesktopNo < 1)
    {
      return;
    }
    _Root._currentDesktopNo = $currentDesktopNo;
    _Root._currentDesktopName = desktopInfo.desktopNames[$currentDesktopNo - 1]
        || qsTr("Desktop %1").arg($currentDesktopNo);
  }

  QTQ.Timer {
    interval: 1000 * 10 // sec
    running: true
    repeat: true
    triggeredOnStart: true

    onTriggered: { _currentDate = new Date(); }
  }

  DesktopIndicator {
    anchors.fill: parent
    desktopNo: _Root._currentDesktopNo
    desktopName: _Root._currentDesktopName
    currentDate: _Root._currentDate
    interactive: false

    sectionDateWidthWeight: _Root._sectionDateWidthWeight
    sectionDesktopNameWidthWeight: _Root._nameSectionWidth
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