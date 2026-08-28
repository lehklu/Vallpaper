/*
 *  Copyright 2026  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick as QTQ
import QtQml as QTQ_QML
import QtQuick.Layouts as QTQ_L
import org.kde.plasma.plasmoid
import org.kde.plasma.plasmoid as KDE_plasmoid

import org.kde.taskmanager as KDE_taskmanager

KDE_plasmoid.PlasmoidItem {
  id: _Root

  property int _fullWidth: height * 5
  property real _dateSectionWidth: Number(configurationValue("dateSectionWidth", 3))
  property real _nameSectionWidth: Number(configurationValue("nameSectionWidth", 1))
  property real _numberSectionWidth: Number(configurationValue("numberSectionWidth", 1))
  property bool _dateSectionVisible: configurationValue("dateSectionVisible", true) === true || configurationValue("dateSectionVisible", true) === "true"
  property bool _nameSectionVisible: configurationValue("nameSectionVisible", true) === true || configurationValue("nameSectionVisible", true) === "true"
  property bool _numberSectionVisible: configurationValue("numberSectionVisible", true) === true || configurationValue("numberSectionVisible", true) === "true"
  property int _dateSectionOrder: sectionOrderIndex("date", 0)
  property int _nameSectionOrder: sectionOrderIndex("desktopName", 1)
  property int _numberSectionOrder: sectionOrderIndex("number", 2)
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

  function configurationValue(key, fallback) {
    // Keep this dependency so configuration changes refresh every current
    // appearance property, including dynamically named desktop settings.
    var revision = _configurationRevision
    return Plasmoid.configuration[key] || fallback
  }

  function sectionOrderIndex(section, fallback) {
    var order = String(configurationValue("sectionOrder", "date,desktopName,number")).split(",")
    var index = order.indexOf(section)
    return index >= 0 ? index : fallback
  }

  function sectionTotalWidth() {
    return (_dateSectionVisible ? _dateSectionWidth : 0)
            + (_nameSectionVisible ? _nameSectionWidth : 0)
            + (_numberSectionVisible ? _numberSectionWidth : 0)
  }

  function sectionWidth(weight, visible) {
    var total = sectionTotalWidth()
    return visible && total > 0 ? _fullWidth * weight / total : 0
  }

  function sectionOffset(order) {
    var offset = 0
    if (_dateSectionVisible && _dateSectionOrder < order)
      offset += sectionWidth(_dateSectionWidth, true)
    if (_nameSectionVisible && _nameSectionOrder < order)
      offset += sectionWidth(_nameSectionWidth, true)
    if (_numberSectionVisible && _numberSectionOrder < order)
      offset += sectionWidth(_numberSectionWidth, true)
    return offset
  }

  QTQ_QML.Connections {
    target: Plasmoid.configuration
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

  QTQ.Rectangle { id: _RectDate
	  x: sectionOffset(_dateSectionOrder)
	  width: sectionWidth(_dateSectionWidth, _dateSectionVisible)
	  height: parent.height
	  visible: _dateSectionVisible
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

  QTQ.Rectangle { id: _RectName
	  x: sectionOffset(_nameSectionOrder)
	  width: sectionWidth(_nameSectionWidth, _nameSectionVisible)
	  height: parent.height
	  visible: _nameSectionVisible
	  color: _currentDesktopNameBackgroundColor

	  QTQ.Text {
	    anchors.centerIn: parent
	    width: parent.width - 8
	    text: _currentDesktopName
	    color: _currentDesktopNameColor
	    font.family: _currentDesktopNameFont
	    elide: Text.ElideRight
	    horizontalAlignment: Text.AlignHCenter
	  }
  }

  QTQ.Rectangle { id: _RectNo
	  x: sectionOffset(_numberSectionOrder)
	  width: sectionWidth(_numberSectionWidth, _numberSectionVisible)
	  height: parent.height
	  color: _currentNumberColor
	  visible: _numberSectionVisible

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
