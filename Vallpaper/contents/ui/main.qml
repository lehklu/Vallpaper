/*
 *  Copyright 2019  Werner Lechner <werner.lechner.2@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.mediaframe 2.0

import org.kde.kwindowsystem 1.0 as KWindowSystem

import QtGraphicalEffects 1.0

import "../js/vallpaper.js" as JS

Rectangle {
    id: root
/* Dev *
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
      backgroundVisible: false
      style: TextAreaStyle {
      	textColor: '#1d1d85'
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

property var myConnector: wallpaper
property var myActionTextPrefix: /*SED01*/'<Vallpaper> '
color: act_timeslot.background

property var cfgAdapter

property var act_deskCfg
property var act_image
property var act_timeslot

KWindowSystem.KWindowSystem {
	id: kWindowSystem

  onCurrentDesktopChanged: handleDesktopChanged()
}

Connections {
	target: myConnector.configuration
  onVallpaper2Changed: setCfgAdapter()
}

Component.onCompleted: {

	setCfgAdapter();

  myConnector.setAction("open", myActionTextPrefix + "Open image", "document-open");
  myConnector.setAction("next", myActionTextPrefix + "Next image","user-desktop");
}


Repeater {
	id: imageRepeater
  model: kWindowSystem.numberOfDesktops + 1 // + 1 shared default cfg

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
				//llog.say($$path);
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
					This.source = $$path;
					This.iInfo=$$path;
					This.sTsFetched = Date.now();
					//llog.say('next ' + $wd + ' ' + This.sMediaFrame.random + ' ' + $$path);
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
  onTriggered: refreshAct_Timeslot()
}





																				// f u n c t i o n s

																				// f u n c t i o n s

																				// f u n c t i o n s

function setCfgAdapter() {

	cfgAdapter = new JS.CfgAdapter(this, myConnector.configuration.vallpaper2);
	handleDesktopChanged();
}

function handleDesktopChanged() {

	act_deskCfg = cfgAdapter.findAppropiateCfg(kWindowSystem.currentDesktop);
	act_image = imageRepeater.itemAt(act_deskCfg.deskNo);
	refreshAct_Timeslot();
}

function refreshAct_Timeslot() {

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