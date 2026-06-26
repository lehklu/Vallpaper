/*
 *  Copyright 2026  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick as QTQ
import QtQuick.Layouts as QTQ_L
import org.kde.plasma.plasmoid as KDE_plasmoid
import org.kde.taskmanager as KDE_taskmanager

KDE_plasmoid.PlasmoidItem {
  id: _Root

  property int _fullWidth: height * 4
  property int _currentDateWidth: _fullWidth / 4 * 3
  property int _deskWidth: _fullWidth / 4 * 1
  
  property var _allDesktopSettings: ({})
  
  function _updateAllSettings() {
    try {
      _allDesktopSettings = JSON.parse(KDE_plasmoid.Plasmoid.configuration.desktopSettings || "{}")
    } catch (e) {
      _allDesktopSettings = {}
    }
  }

  QTQ.Connections {
    target: KDE_plasmoid.Plasmoid.configuration
    function onDesktopSettingsChanged() { _updateAllSettings() }
  }

  QTQ.Component.onCompleted: _updateAllSettings()

  property date _currentDate: new Date()
  property string _currentDesktopId: ""
  property int _currentDesktopNo: 0
  
  property var _currentSettings: _allDesktopSettings[_currentDesktopId] || {}

  width: _fullWidth
  QTQ_L.Layout.minimumWidth: _fullWidth
  QTQ_L.Layout.fillHeight: true

  KDE_taskmanager.VirtualDesktopInfo {
    id: desktopInfo
    QTQ.Component.onCompleted: broadcastDesktopChanged();
    onCurrentDesktopChanged: broadcastDesktopChanged();

  	function broadcastDesktopChanged() {
      const currentId = currentDesktop;
      _Root._currentDesktopId = currentId;
      
      const ids = desktopIds;
      let idx = 0;
      for(; idx < ids.length; idx++) {
        if(ids[idx] == currentId) { break; }
      }
      _Root._currentDesktopNo = idx + 1;
	  }
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
	  color: _currentSettings.dayBgColor || (
      ["#a0ffa0", "#a8a8ff", "#ff97ff", "#ffff8f", "#ffffff", "#41f2f2"][(_Root._currentDesktopNo - 1) % 6]
    )

	  QTQ.Text { id: _TxtDay
      anchors.top: parent.top
	    anchors.horizontalCenter: parent.horizontalCenter

	    font.family: _currentSettings.dayFontName || "Inconsolata"
	    font.pointSize: _currentSettings.dayFontSize || (_RectDate.height * 0.4)
	    font.weight: 400

      color: _currentSettings.dayTextColor || "#000000"

	    text : Qt.locale().toString(_Root._currentDate, "dddd")
	  }

    QTQ.Text { id: _TxtDate
	    anchors.bottom: parent.bottom
	    anchors.horizontalCenter: parent.horizontalCenter

	    font.family: _currentSettings.dateFontName || "Cantarell"
	    font.pointSize: _currentSettings.dateFontSize || (_RectDate.height * 0.4)
	    font.weight: 600

	    color: _currentSettings.dateTextColor || "#000000"

        QTQ.Rectangle {
            anchors.fill: parent
            z: -1
            color: _currentSettings.dateBgColor || "transparent"
        }

	    text : Qt.locale().toString(_Root._currentDate, "dd.MM")
    }
  }

  QTQ.Rectangle { id: _RectNo
	  width: _deskWidth
	  height: parent.height
	  color: _currentSettings.numBgColor || "#000000"
	  anchors.right: parent.right

	  QTQ.Text { id: _TxtNo
	    anchors.verticalCenter: parent.verticalCenter
	    anchors.horizontalCenter: parent.horizontalCenter

	    font.family: _currentSettings.numFontName || "Cantarell"
	    font.pointSize: _currentSettings.numFontSize || (_RectNo.height * 0.6)
	    font.weight: 700

	    color: _currentSettings.numTextColor || (
        ["#a0ffa0", "#a8a8ff", "#ff97ff", "#ffff8f", "#ffffff", "#41f2f2"][(_Root._currentDesktopNo - 1) % 6]
      )

	    text : _Root._currentDesktopNo
	  }
  }
}
