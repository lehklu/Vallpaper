/*
 *  Copyright 2024  Werner Lechner <werner.lechner@lehklu.at>
 */

import org.kde.plasma.plasmoid
import org.kde.plasma.private.pager 2.0
import QtQuick
import QtQuick.Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kquickcontrolsaddons

import org.kde.plasma.private.mediaframe 2.0

import Qt5Compat.GraphicalEffects

import "../js/vallpaper.js" as JS

PlasmoidItem {
	id: _Root

property var myConnector: plasmoid
property var myActionTextPrefix: /*SED01*/'' // empty

property var cfgAdapter

property var act_deskCfg
property var act_image
property var act_timeslot

	PagerModel {
        id: _Pager

        enabled: _Root.visible
        pagerType: PagerModel.VirtualDesktops

        onCurrentPageChanged: { root.handleDesktopChanged() }
	}


Rectangle {
    id: root
/* Dev */
Rectangle {
		z: 1 // z-order
    id: llogBackground
    width: parent.width * 0.8
    height: llog.contentHeight
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 50
    anchors.horizontalCenter: parent.horizontalCenter
    color: '#AAffffff'

    TextArea {
			id: llog
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

color: act_timeslot.background
width: parent.width
height: parent.height


Connections {
	target: myConnector.configuration

  function onValueChanged() { setCfgAdapter() }
}

Component.onCompleted: {

	llog.say("A");
	setCfgAdapter();

  //myConnector.setAction("open", myActionTextPrefix + "Open image", "document-open");
  //myConnector.setAction("next", myActionTextPrefix + "Next image","user-desktop");
}


Repeater {
	id: imageRepeater
  model: 5 + 1 // + 1 shared default cfg

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
			for(let $$path of this.sTimeslot.sources)
			{
				mfr.add($$path, true); // path, recursive
				llog.say($$path);
			}

			if(mfr.count === 0)
			{
				this.source = "";
			}

			mfr.random = this.sTimeslot.random;

			this.fetchNextImage();
		}

		function fetchNextImage($wd = 10) {

			let This = this;

			this.sMediaFrame.get(function($$path) {

				llog.say($$path);

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
					llog.say('next ' + $wd + ' ' + This.sMediaFrame.random + ' ' + resanitized);
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

  source: act_image
  anchors.fill: act_image
  visible: act_image.source!=""

  desaturation: act_timeslot.desaturate
}

FastBlur {
	id: geBlur

  source: geDesaturate
  anchors.fill: geDesaturate
  visible: geDesaturate.visible

  radius: act_timeslot.blur * 100
}

ColorOverlay {
	id: geColorOverlay

  source: geBlur
  anchors.fill: geBlur
  visible: geBlur.visible

  color: act_timeslot.colorizeValue
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
  	text: act_image.iInfo
  }
}
/* /LabelInfo */


Timer {
	id: timer
  interval: 1000 * 1
  repeat: true
  running: true
  onTriggered: root.refreshAct_Timeslot()
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

	llog.say("*** handleDesktopChanged()");
	llog.say(_Pager.currentPage);

	act_deskCfg = cfgAdapter.findAppropiateCfg(_Pager.currentPage);
	act_image = imageRepeater.itemAt(act_deskCfg.deskNo);
	refreshAct_Timeslot();
	llog.say("*** handleDesktopChanged() exit");
}

function refreshAct_Timeslot() {

	llog.say("*** refreshAct_Timeslot");

	let newSlot = act_deskCfg.findAppropiateTimeslot_now();

	if(newSlot !== act_image.sTimeslot)
	{
		act_image.resetState(newSlot);
	}

	act_timeslot = act_image.sTimeslot;

	// refresh image
	// refresh image
	// refresh image
	if(act_timeslot.sources.length === 0) return;
	//<--

	if(act_timeslot.interval === 0 && act_image.src !== "") return;
	//<--

	//llog.say(Date.now() + ' < ' + (act_image.sTsFetched + act_timeslot.interval*1000))
	if(Date.now() < (act_image.sTsFetched + act_timeslot.interval*1000)) return;
	//<--


	act_image.fetchNextImage();
}

function action_next() {

	act_image.fetchNextImage();
}

function action_open() {

	Qt.openUrlExternally(act_image.source)
}

MouseArea {
	anchors.fill: parent
	acceptedButtons: Qt.LeftButton
	onPressAndHold: action_next();
  onDoubleClicked: action_open();
}
}
}
