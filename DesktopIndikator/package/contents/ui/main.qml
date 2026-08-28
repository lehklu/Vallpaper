/*
 *  Copyright 2026  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick as QTQ
import QtQml as QTQ_QML
import QtQuick.Layouts as QTQ_L
import org.kde.plasma.plasmoid as KDE_plasmoid

import org.kde.taskmanager as KDE_taskmanager

KDE_plasmoid.PlasmoidItem {
  id: _Root

  property int _fullWidth: height * 4
  property int _currentDateWidth: _fullWidth / 4 * 3
  property int _deskWidth: _fullWidth / 4 * 1
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
  property int _configurationRevision: 0
  property var _currentDeskColor: configurationValue("dateColor" + _currentDesktopNo,
                                                     _defaultDeskColors[(_currentDesktopNo - 1 + 6) % 6])
  property var _currentNumberColor: configurationValue("numberColor" + _currentDesktopNo, "#000000")
  property var _currentDayNameColor: configurationValue("dayNameColor" + _currentDesktopNo, "#000000")
  property var _currentDayDateColor: configurationValue("dayDateColor" + _currentDesktopNo, "#000000")
  property var _currentNumberTextColor: configurationValue("numberTextColor" + _currentDesktopNo,
                                                            _defaultDeskColors[(_currentDesktopNo - 1 + 6) % 6])
  property string _currentDayNameFont: configurationValue("dayNameFont" + _currentDesktopNo, "Inconsolata")
  property string _currentDayDateFont: configurationValue("dayDateFont" + _currentDesktopNo, "Cantarell")
  property string _currentNumberFont: configurationValue("numberFont" + _currentDesktopNo, "Cantarell")

  function configurationValue(key, fallback) {
    // Keep this dependency so configuration changes refresh every current
    // appearance property, including dynamically named desktop settings.
    var revision = _configurationRevision
    return KDE_plasmoid.Plasmoid.configuration[key] || fallback
  }

  QTQ_QML.Connections {
    target: KDE_plasmoid.Plasmoid.configuration
    function onValueChanged() {
      _Root._configurationRevision++
    }
  }

  width: _fullWidth
  QTQ_L.Layout.minimumWidth: _fullWidth
  QTQ_L.Layout.fillHeight: true

  KDE_taskmanager.VirtualDesktopInfo {
    id: desktopInfo

    QTQ.Component.onCompleted: scheduleDesktopSync();

    onCurrentDesktopChanged: scheduleDesktopSync();
    onDesktopIdsChanged: scheduleDesktopSync();
    onNumberOfDesktopsChanged: scheduleDesktopSync();

    function scheduleDesktopSync() {
      desktopSyncTimer.restart();
    }

  	function broadcastDesktopChanged() {

	    _Root.handleOnDesktopChanged(getCurrentDeskNo());
	  }

    function getCurrentDeskNo() {

      const currentId = currentDesktop;
      const ids = desktopIds;

      if (!ids.length || currentId === undefined || currentId === null) {
        return 0;
      }

      let idx = 0;

      for(; idx < ids.length; idx++)
      {
        if(ids[idx] == currentId) { break; }
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
	  if ($currentDesktopNo < 1) {
      return;
    }
	  _Root._currentDesktopNo=$currentDesktopNo;
  }

  QTQ.Timer {
    interval: 1000 * 10 // sec
	  running: true
	  repeat: true
	  triggeredOnStart: true

	  onTriggered: { _currentDate = new Date(); }
  }

  QTQ.Rectangle { id: _RectDate
	  width: _currentDateWidth
	  height: parent.height
	  anchors.left: parent.left
	  color: _currentDeskColor

	  QTQ.Text { id: _TxtDay
      anchors.top: parent.top
	    anchors.horizontalCenter: parent.horizontalCenter

	    font.family: _currentDayNameFont
	    font.pixelSize: _RectDate.height * 0.5
	    font.weight: 400

      color: _currentDayNameColor

	    text : Qt.locale().toString(_Root._currentDate, "dddd")
	  }

    QTQ.Text { id: _TxtDate
	    anchors.bottom: parent.bottom
	    anchors.horizontalCenter: parent.horizontalCenter

	    font.family: _currentDayDateFont
	    font.pixelSize: _RectDate.height * 0.5
	    font.weight: 600

	    color: _currentDayDateColor

	    text : Qt.locale().toString(_Root._currentDate, "dd.MM")
    }
  }

  QTQ.Rectangle { id: _RectNo
	  width: _deskWidth
	  height: parent.height
	  color: _currentNumberColor
	  anchors.right: parent.right

	  QTQ.Text { id: _TxtNo
	    anchors.verticalCenter: parent.verticalCenter
	    anchors.horizontalCenter: parent.horizontalCenter

	    font.family: _currentNumberFont
	    font.pixelSize: _RectNo.height * 0.8
	    font.weight: 700

	    color: _currentNumberTextColor

	    text : _Root._currentDesktopNo
	  }
  }
}
