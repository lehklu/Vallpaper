/*
 *  Copyright 2025  Werner Lechner <werner.lechner@lehklu.at>
 */

import org.kde.kquickcontrolsaddons
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.private.mediaframe
import org.kde.plasma.private.pager
import QtQuick
import QtQuick.Controls

import Qt5Compat.GraphicalEffects

import "../js/vallpaper.js" as JS

PlasmoidItem {
	id: _Root

  property var myConnector: plasmoid
  property var myActionTextPrefix: /*SED01*/'' // empty

  property var cfgAdapter

  property var current_deskCfg
  property var current_image
  property var current_timeslot

  property var canActionOpen: true
  property var canActionNext: true

  Plasmoid.contextualActions: [
    PlasmaCore.Action {
        text: "Open image"
        icon.name: "document-open"
        priority: Plasmoid.LowPriorityAction
        visible: _Root.canActionOpen
        enabled: _Root.canActionOpen
        onTriggered: action_open()
    },
    PlasmaCore.Action {
        text: "Next image"
        icon.name: "user-desktop"
        priority: Plasmoid.LowPriorityAction
        visible: _Root.canActionNext
        enabled: _Root.canActionNext
        onTriggered: action_next()
    }
  ]    

	PagerModel {
        id: _Pager

        enabled: _Root.visible
        pagerType: PagerModel.VirtualDesktops

        onCurrentPageChanged: { _Canvas.handleDesktopChanged(); }
	}

  Connections {
	  target: myConnector.configuration

    function onValueChanged() { setCfgAdapter(); }
  }

  Rectangle {
    id: _Canvas


    color: current_timeslot.background
    width: parent.width
    height: parent.height

    Component.onCompleted: { setCfgAdapter(); }


    Repeater {
	    id: _ImageRepeater
      model: _Pager.count+1 // + 1 shared default cfg

      Image {
        // set anchors to allow use of margins
		    anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        sourceSize.width: width
        sourceSize.height: height

        asynchronous: true
        autoTransform: true
        visible: false // displayed through Graphical effects

        property string iInfo
		    property var sTsFetched
        property var sTimeslot
        property var sMediaFrame: MediaFrame {}

		    Component.onCompleted: {

			    resetState(undefined);
		    }

		    function resetState($newSlot) {

			    this.sTsFetched = -1;
			    this.sTimeslot = $newSlot;

			    if(this.sTimeslot===undefined) return;
			    //<--


			    this.configThis();
			    this.configMediaFrame();
		    }

		    function configThis() {

			    this.fillMode = this.sTimeslot.fillMode;

			    this.anchors.topMargin =    this.sTimeslot.borderTop;
          this.anchors.bottomMargin =	this.sTimeslot.borderBottom;
          this.anchors.leftMargin =   this.sTimeslot.borderLeft;
          this.anchors.rightMargin =  this.sTimeslot.borderRight;
		    }

		    function configMediaFrame() {

			    let mfr = this.sMediaFrame;


			    mfr.clear();
			    for(let $$path of this.sTimeslot.imagesources)
			    {
				    mfr.add($$path, true); // path, recursive
				    _Log.say($$path);
			    }


			    if(mfr.count === 0)
			    {
				    this.source = "";
			    }

			    mfr.random = this.sTimeslot.shuffle;

			    this.fetchNextImage();
		    }

		    function fetchNextImage($wd = 10) {

			    let This = this;

			    this.sMediaFrame.get(function($$path) {

				    _Log.say($$path);

				    if($$path.indexOf(':')<0)
				    {
					    $$path = 'file://' + $$path;
				    }

				    if($$path.startsWith('http'))
				    {
					    This.cache = false;
              This.source = ""; // trigger reload
              gc();
				    }

				    if($$path!=This.source || $wd===0)
				    {
					    let resanitized = JS.FILENAME_TO_URISAFE($$path);
					    console.log(resanitized);
					    This.source = resanitized;
					    This.iInfo=$$path;
					    This.sTsFetched = Date.now();
					    _Log.say('next ' + $wd + ' ' + This.sMediaFrame.random + ' ' + resanitized);
				    }
				    else
				    {
					    This.fetchNextImage($wd-1);
				    }
			    });
		    }
	    }
    }

// Graphical effects
// Graphical effects
// Graphical effects
  Desaturate {
	  id: geDesaturate

    source: current_image
    anchors.fill: current_image
    visible: current_image.source!=""

    desaturation: current_timeslot.desaturate
  }

  FastBlur {
	  id: geBlur

    source: geDesaturate
    anchors.fill: geDesaturate
    visible: geDesaturate.visible

    radius: current_timeslot.blur * 100
  }

  ColorOverlay {
	  id: geColorOverlay

    source: geBlur
    anchors.fill: geBlur
    visible: geBlur.visible

    color: current_timeslot.colorizeValue
  }
// /Graphical effects
// /Graphical effects
// /Graphical effects

  /* LabelInfo *
  Rectangle {
	  width: labelInfo.contentWidth
    height: labelInfo.contentHeight
    anchors.top: parent.top
    anchors.left: parent.left
    color: '#ff1d1d85'

	  Label {
		  id: labelInfo
  	  color: "#ffffffff"
  	  text: current_image.iInfo
    }
  }
  /* /LabelInfo */


  Timer {
	  id: timer
    interval: 1000 * 1
    repeat: true
    running: true
    onTriggered: _Canvas.refreshcurrent_Timeslot()
  }





																				// f u n c t i o n s

																				// f u n c t i o n s

																				// f u n c t i o n s

  function setCfgAdapter() {

	  cfgAdapter = new JS.CfgAdapter(this, myConnector.configuration.vrame6);
	  handleDesktopChanged();
  }

  function handleDesktopChanged() {

	  if( ! cfgAdapter) { return; }
	  //<--

	  _Log.say("X");
	  _Log.say(_Pager.currentPage);

	  current_deskCfg = cfgAdapter.findAppropiateCfg(_Pager.currentPage);

	  current_image = _ImageRepeater.itemAt(current_deskCfg.deskNo);
	  refreshcurrent_Timeslot();
	  _Log.say("/X");
  }

  function refreshcurrent_Timeslot() {

    console.log(current_image);
    console.log("current_image");


	  let newSlot = current_deskCfg.findAppropiateTimeslotCfg_now();

	  if(newSlot !== current_image.sTimeslot)
	  {
  		current_image.resetState(newSlot);
	  }

	  current_timeslot = current_image.sTimeslot;

	  // refresh image
	  // refresh image
	  // refresh image
	  if(current_timeslot.imagesources.length === 0) return;
	  //<--
	  if(current_timeslot.interval === 0 && current_image.src !== "") return;
	  //<--
	  if(Date.now() < (current_image.sTsFetched + current_timeslot.interval*1000)) return;
	  //<--


	  current_image.fetchNextImage();
  }

  function action_next() {

	  current_image.fetchNextImage();
  }

  function action_open() {

	  Qt.openUrlExternally(current_image.source)
  }

  MouseArea {
	  anchors.fill: parent
	  acceptedButtons: Qt.LeftButton
	  onPressAndHold: action_next();
    onDoubleClicked: action_open();
  }

/* Dev */
Rectangle {
		z: 1 // z-order
    width: parent.width * 0.8
    height: _Log.contentHeight
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 50
    anchors.horizontalCenter: parent.horizontalCenter
    color: '#AAffffff'

    TextArea {
			id: _Log
  		anchors.fill: parent
      color: '#1d1d85'

	  		Component.onCompleted: {

				text="-1";4
			say("0");
		}

      property var lines: []

			function sayo($o) {

      	say(JSON.stringify($o));
			}

			function say($text) {

				let linesText = '';

				lines.push($text);

				if(lines.length > 10)
				{
					lines.splice(0, 1);
					linesText = '...';
				}

				for(let line of lines)
				{
					linesText = linesText+'\n'+line;
				}

      	text=linesText
			}
    }
}
/* /Dev */




  }
}
