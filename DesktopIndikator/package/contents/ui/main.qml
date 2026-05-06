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
  property var _deskColors: [
    "#a0ffa0",
	"#a8a8ff",
	"#ff97ff",
	"#ffff8f",
	"#ffffff",
	"#41f2f2"
  ]
  property var _contrastColor: "#000000"

  property date _currentDate: new Date()
  property int _currentDesktopNo: 0
  property var _currentDeskColor: _deskColors[_currentDesktopNo]

  width: _fullWidth
  QTQ_L.Layout.minimumWidth: _fullWidth
  QTQ_L.Layout.fillHeight: true

  KDE_taskmanager.VirtualDesktopInfo { id: _VirtualDesktopInfo

    QTQ.Component.onCompleted: broadcastDesktopChanged();

    onCurrentDesktopChanged: broadcastDesktopChanged();

	function broadcastDesktopChanged() {

	  _Root.handleOnDesktopChanged(_VirtualDesktopInfo.currentDesktop);
	}
  }

  function handleOnDesktopChanged($currentDesktopNo) {

    const colIdx=($currentDesktopNo-1) % _Root._deskColors.length;

    _currentDeskColor=_Root._deskColors[colIdx];
	_Root._currentDesktopNo=$currentDesktopNo;
  }

  QTQ.Timer {
    interval: 1000 * 10 // sec
	running: true
	repeat: true
	triggeredOnStart: true

	onTriggered: { _currentDate = new Date(); }
  }

  QTQ.Rectangle {
    id: _RectDate

	width: _currentDateWidth
	height: parent.height
	anchors.left: parent.left
	color: _currentDeskColor

	QTQ.Text {
	  id: _TxtDay
	  anchors.top: parent.top
	  anchors.horizontalCenter: parent.horizontalCenter

	  font.family: "Inconsolata"
	  font.pixelSize: _RectDate.height * 0.5
	  font.weight: 400

      color: _contrastColor

	  text : Qt.locale().toString(_Root._currentDate, "dddd")
	}

    QTQ.Text {
      id: _TxtDate
	  anchors.bottom: parent.bottom
	  anchors.horizontalCenter: parent.horizontalCenter

	  font.family: "Cantarell"
	  font.pixelSize: _RectDate.height * 0.5
	  font.weight: 600

	  color: _contrastColor

	  text : Qt.locale().toString(_Root._currentDate, "dd.MM")
    }
  }

  QTQ.Rectangle {
    id: _RectNo
	width: _deskWidth
	height: parent.height
	color: _contrastColor
	anchors.right: parent.right

	QTQ.Text {
	  id: _TxtNo
	  anchors.verticalCenter: parent.verticalCenter
	  anchors.horizontalCenter: parent.horizontalCenter

	  font.family: "Cantarell"
	  font.pixelSize: _RectNo.height * 0.8
	  font.weight: 700

	  color: _currentDeskColor

	  text : _Root._currentDesktopNo
	}
  }
}