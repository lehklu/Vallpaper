/*
 *  Copyright 2026  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick as QTQ
import QtQml as QML
import QtQuick.Layouts as QTQ_L
import org.kde.plasma.plasmoid as KDE_plasmoid

import org.kde.taskmanager as KDE_taskmanager

KDE_plasmoid.PlasmoidItem { id: _Root

  property int _fullWidth: height * 5
  property real _sectionDateWidth: Number(configurationValue("sectionDateWidth", 3))
  property real _nameSectionWidth: Number(configurationValue("sectionDesktopNameWidth", 1))
  property real _sectionDesktopNumberWidth: Number(configurationValue("sectionDesktopNumberWidth", 1))
  property bool _sectionDateVisible: configurationValue("sectionDateVisible", true) === true || configurationValue("sectionDateVisible", true) === "true"
  property bool _nameSectionVisible: configurationValue("nameSectionVisible", true) === true || configurationValue("nameSectionVisible", true) === "true"
  property bool _sectionDesktopNumberVisible: configurationValue("sectionDesktopNumberVisible", true) === true || configurationValue("sectionDesktopNumberVisible", true) === "true"
  property int _dateSectionOrder: sectionOrderIndex("date", 0)
  property int _nameSectionOrder: sectionOrderIndex("desktopName", 1)
  property int _sectionDesktopNumberOrder: sectionOrderIndex("number", 2)
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
    var match = key.match(/^(.*?)([0-9]+)$/)
    if (match) {
      var stored = KDE_plasmoid.Plasmoid.configuration[match[1] + "s"]
      if (stored) {
        try {
          var values = JSON.parse(stored)
          return values[Number(match[2]) - 1] || fallback
        } catch (e) {}
      }
      return fallback
    }
    return KDE_plasmoid.Plasmoid.configuration[key] || fallback
  }

  function sectionOrderIndex(section, fallback) {
    var order = String(configurationValue("sectionOrder", "date,desktopName,number")).split(",")
    var index = order.indexOf(section)
    return index >= 0 ? index : fallback
  }

  function sectionTotalWidth() {
    return (_sectionDateVisible ? _sectionDateWidth : 0)
            + (_nameSectionVisible ? _nameSectionWidth : 0)
            + (_sectionDesktopNumberVisible ? _sectionDesktopNumberWidth : 0)
  }

  function sectionWidth(weight, visible) {
    var total = sectionTotalWidth()
    return visible && total > 0 ? _fullWidth * weight / total : 0
  }

  function sectionOffset(order) {
    var offset = 0
    if (_sectionDateVisible && _dateSectionOrder < order)
      offset += sectionWidth(_sectionDateWidth, true)
    if (_nameSectionVisible && _nameSectionOrder < order)
      offset += sectionWidth(_nameSectionWidth, true)
    if (_sectionDesktopNumberVisible && _sectionDesktopNumberOrder < order)
      offset += sectionWidth(_sectionDesktopNumberWidth, true)
    return offset
  }

  QML.Connections {
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
	  width: sectionWidth(_sectionDateWidth, _sectionDateVisible)
	  height: parent.height
	  visible: _sectionDateVisible
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
	    elide: QTQ.Text.ElideRight
	    horizontalAlignment: QTQ.Text.AlignHCenter
	  }
  }

  QTQ.Rectangle { id: _RectNo
	  x: sectionOffset(_sectionDesktopNumberOrder)
	  width: sectionWidth(_sectionDesktopNumberWidth, _sectionDesktopNumberVisible)
	  height: parent.height
	  color: _currentNumberColor
	  visible: _sectionDesktopNumberVisible

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