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

  property var config: Plasmoid.configuration.vrame6
  property var myConnector: plasmoid
  property var myActionTextPrefix: /*SED01*/'' // empty
  property var cfgAdapter
  property var actionCanOpen: true
  property var actionCanNext: true

  onConfigChanged: { _Canvas.setCfgAdapter(); }

  Plasmoid.contextualActions: [
    PlasmaCore.Action {
        text: "Open image"
        icon.name: "document-open"
        priority: Plasmoid.LowPriorityAction
        visible: true
        enabled: actionCanOpen
        onTriggered: action_open()
    },
    PlasmaCore.Action {
        text: "Next image"
        icon.name: "user-desktop"
        priority: Plasmoid.LowPriorityAction
        visible: true
        enabled: actionCanNext
        onTriggered: action_next()
    }
  ]    

	PagerModel {
        id: _Pager

        enabled: _Root.visible
        pagerType: PagerModel.VirtualDesktops

        onCurrentPageChanged: { _Canvas.handleDesktopChanged(); }
	}

  Timer {
	  id: _Timer
    interval: 1000 * 1 // sec
    repeat: true
    running: true
    onTriggered: _Canvas.updateActiveSlot()
  }  

  // - - - - - - - - - - - - - C A N V A S
  // - - - - - - - - - - - - - C A N V A S
  // - - - - - - - - - - - - - C A N V A S
  Rectangle {
    id: _Canvas

    anchors.fill: parent          
    color: activeSlot.background

    property var activeDeskCfg
    property var activeImage
    property var activeSlot

    Component.onCompleted: {

      setCfgAdapter();
      console.log("----------------------------------------------setCfgAdapter()");
    }

    Repeater {
	    id: _ImageRepeater
  
      model: _Pager.count+1 // + 1 =^= shared default cfg

      // - - - - - - - - - - - - - I M A G E
      // - - - - - - - - - - - - - I M A G E
      // - - - - - - - - - - - - - I M A G E
      Image {
        anchors.fill: parent          

        visible: false // displayed through Graphical effects

        //  this property sets the maximum number of pixels stored for the loaded image so that large images do not use more memory than necessary. 
        //  If only one dimension of the size is set to greater than 0, the other dimension is set in proportion to preserve the source image's aspect ratio. (The fillMode is independent of this.)
        sourceSize.width: width 

        asynchronous: true
        autoTransform: true

        property string infoText
		    property var timestampFetched
        property var slot
        property var mediaframe: MediaFrame {}

		    Component.onCompleted: {

			    resetState(undefined);
		    }

		    function resetState($newSlot) {

          console.log("111111111111111111111111111111111111111111111" + $newSlot);

			    timestampFetched = -1;
			    slot = $newSlot;

			    if(slot===undefined) return;
			    //<--


			    setupImage();
			    setupMediaframe();
          console.log("999999999999999999999999999999999999999");
		    }

		    function setupImage() {

			    fillMode = slot.fillMode;

			    anchors.topMargin =     slot.borderTop;
          anchors.bottomMargin =  slot.borderBottom;
          anchors.leftMargin =    slot.borderLeft;
          anchors.rightMargin =   slot.borderRight;
		    }

		    function setupMediaframe() {

			    mediaframe.clear();

			    mediaframe.random = slot.shuffle;

          for(let $$path of slot.imagesources)
			    {
				    mediaframe.add($$path, true); // path, recursive
			    }

			    fetchNextImage();
		    }

		    function fetchNextImage($watchdog = 10) {

          if(mediaframe.count === 0)
          {
            source = "";

            return;
            //<--
          }


			    mediaframe.get(function($$path) {

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

				    if($$path!=This.source || $watchdog===0)
				    {
					    let resanitized = JS.FILENAME_TO_URISAFE($$path);
					    console.log(resanitized);
					    This.source = resanitized;
					    This.infoText=$$path;
					    This.timestampFetched = Date.now();
				    }
				    else
				    {
					    This.fetchNextImage($watchdog-1);
				    }
			    });
		    }
	    }
      // I M A G E - - - - - - - - - - - - - - - - - -
      // I M A G E - - - - - - - - - - - - - - - - - -
      // I M A G E - - - - - - - - - - - - - - - - - -
    }

// Graphical effects
// Graphical effects
// Graphical effects
Desaturate {
	id: geDesaturate

  source: _Canvas.activeImage
  anchors.fill: _Canvas.activeImage
  visible: _Canvas.activeImage.source!=""

  desaturation: _Canvas.activeSlot.desaturate
}

FastBlur {
	id: geBlur

  source: geDesaturate
  anchors.fill: geDesaturate
  visible: geDesaturate.visible

  radius: _Canvas.activeSlot.blur * 100
}

ColorOverlay {
	id: geColorOverlay

  source: geBlur
  anchors.fill: geBlur
  visible: geBlur.visible

  color: _Canvas.activeSlot.colorizeValue
}
// /Graphical effects
// /Graphical effects
// /Graphical effects

Rectangle {
  visible: true
	width: labelInfo.contentWidth
  height: labelInfo.contentHeight
  anchors.top: parent.top
  anchors.left: parent.left
  color: '#ff1d1d85'

	Label {
		id: labelInfo
  	color: "#ffffffff"
  	text: _Canvas.activeImage.infoText
  }
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

	activeDeskCfg = cfgAdapter.findAppropiateCfg(_Pager.currentPage);
	activeImage = _ImageRepeater.itemAt(activeDeskCfg.deskNo);
	updateActiveSlot();
}

function updateActiveSlot() {

	let newSlot = activeDeskCfg.findAppropiateTimeslotCfg_now();

	if(newSlot !== activeImage.slot)
	{
		activeImage.resetState(newSlot);
	}

	activeSlot = activeImage.slot;

	// refresh image
	// refresh image
	// refresh image
	if(activeSlot.imagesources.length === 0) return;
	//<--

	if(activeSlot.interval === 0 && activeImage.src !== "") return;
	//<--

	if(Date.now() < (activeImage.timestampFetched + activeSlot.interval*1000)) return;
	//<--


	activeImage.fetchNextImage();
}

function action_next() {

	activeImage.fetchNextImage();
}

function action_open() {

	Qt.openUrlExternally(activeImage.source)
}

MouseArea {
	anchors.fill: parent
	acceptedButtons: Qt.LeftButton
	onPressAndHold: action_next();
  onDoubleClicked: action_open();
}
  }
  // C A N V A S - - - - - - - - - - - - - - - - - -
  // C A N V A S - - - - - - - - - - - - - - - - - -
  // C A N V A S - - - - - - - - - - - - - - - - - -
}
