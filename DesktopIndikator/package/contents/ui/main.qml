/*
 *  Copyright 2025  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.private.pager


PlasmoidItem {
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
	Layout.minimumWidth: _fullWidth
	Layout.fillHeight: true

	PagerModel {
    id: _Pager

    enabled: _Root.visible
    pagerType: PagerModel.VirtualDesktops

    onCurrentPageChanged: { _Root.handleOnDesktopChanged(_Pager.currentPage) }
  }

	function handleOnDesktopChanged($currentDesktopNo) {

		const colIdx=$currentDesktopNo % _Root._deskColors.length;

		_currentDeskColor=_Root._deskColors[colIdx];
		_Root._currentDesktopNo=$currentDesktopNo;
	}

	Timer {
		interval: 1000 * 10 // sec
		running: true
		repeat: true
		triggeredOnStart: true

		onTriggered: { _currentDate = new Date(); }
	}

	Rectangle {
		id: _RectDate

		width: _currentDateWidth
		height: parent.height
		anchors.left: parent.left
		color: _currentDeskColor

	  Text {
			id: _TxtDay
			anchors.top: parent.top
			anchors.horizontalCenter: parent.horizontalCenter

			font.family: "Inconsolata"
			font.pixelSize: _RectDate.height * 0.5
			font.weight: 400

			color: _contrastColor

			text : Qt.locale().toString(_Root._currentDate, "dddd")
	  }

	  Text {
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

	Rectangle {
		id: _RectNo
		width: _deskWidth
		height: parent.height
		color: _contrastColor
		anchors.right: parent.right

	  Text {
			id: _TxtNo
			anchors.verticalCenter: parent.verticalCenter
			anchors.horizontalCenter: parent.horizontalCenter

			font.family: "Cantarell"
			font.pixelSize: _RectNo.height * 0.8
			font.weight: 700

			color: _currentDeskColor

			text : _Root._currentDesktopNo+1
	  }
	}
}
