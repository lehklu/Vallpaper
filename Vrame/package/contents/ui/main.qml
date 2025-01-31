/*
 *  Copyright 2025  Werner Lechner <werner.lechner@lehklu.at>
 */

import org.kde.kquickcontrolsaddons
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

  property var devShowInfo: true

  property var config: Plasmoid.configuration.vrame6
  property var connector2Plasma: plasmoid
  property var prefixActionText: /*SED01*/'' // empty
  property var cfgAdapter

  property var activeDeskCfg
  property var activeImage
  property var activeSlot
  property var actionCanOpen: true
  property var actionCanNext: true  

  property bool repeaterReady: false

  onActiveImageChanged: { 
    // Workaround: activeImage wird durch irgendwas auf null gesetzt!??1!
    
    if(activeImage!=null) { return; }
    //<--

    
    activeImage = _ImageRepeater.itemAt(activeDeskCfg.deskNo);
   }    

  onConfigChanged: { _Canvas.cnvSetCfgAdapter(); }

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

    onCurrentPageChanged: { _Canvas.cnvSetActiveDeskCfg(); }
	}

  Timer {
	  id: _Timer
    interval: 1000 * 1 // sec
    repeat: true
    running: true
    onTriggered: { _Canvas.cnvUpdateActiveSlot();}
  }  

  // - - - - - - - - - - - - - C A N V A S
  // - - - - - - - - - - - - - C A N V A S
  // - - - - - - - - - - - - - C A N V A S
  Rectangle {
    id: _Canvas

    anchors.fill: parent          
    color: activeSlot.background

    Repeater {
	    id: _ImageRepeater
  
      model: _Pager.count

      Component.onCompleted: {
        
        repeaterReady=true;

        _Canvas.cnvSetActiveDeskCfg();
		  }


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

		    Component.onCompleted: { imgResetState(); }

		    function imgResetState($newSlot=undefined) {

			    timestampFetched = -1;
			    slot = $newSlot;

			    if(slot===undefined) return;
			    //<--


			    imgApplyCfg();
		    }

		    function imgApplyCfg() {

			    fillMode = slot.fillMode;

			    anchors.topMargin =     slot.borderTop;
          anchors.bottomMargin =  slot.borderBottom;
          anchors.leftMargin =    slot.borderLeft;
          anchors.rightMargin =   slot.borderRight;

			    mediaframe.clear();
			    mediaframe.random = slot.shuffle;
          for(let $$path of slot.imagesources)
			    {
				    mediaframe.add($$path, true); // path, recursive
			    }

			    imgFetchNext();
		    }

		    function imgFetchNext($watchdog = 10) {

          if(mediaframe.count === 0)
          {
            source = "";

            return;
            //<--
          }


			    mediaframe.get($$path => {

				    if($$path.indexOf(':')<0)
				    {
					    $$path = 'file://' + $$path;
				    }

				    if($$path.startsWith('http'))
				    {
					    cache = false;
              source = ""; // trigger reload
              gc();
				    }

				    if($$path!=source || $watchdog===0)
				    {
					    let resanitized = JS.FILENAME_TO_URISAFE($$path);
					    source = resanitized;
					    infoText=$$path;
					    timestampFetched = Date.now();
				    }
				    else
				    {
					    imgFetchNext($watchdog-1);
				    }
			    });
		    }
	    }
      // I M A G E - - - - - - - - - - - - - - - - - -
      // I M A G E - - - - - - - - - - - - - - - - - -
      // I M A G E - - - - - - - - - - - - - - - - - -
    }

    // - - - - - - - - - - - - - D I S P L A Y C H A I N
    // - - - - - - - - - - - - - D I S P L A Y C H A I N
    // - - - - - - - - - - - - - D I S P L A Y C H A I N
    Desaturate {
	    id: dcDesaturate

      source: activeImage
      anchors.fill: activeImage
      visible: activeImage.source!=""

      desaturation: activeSlot.desaturate
    }

    FastBlur {
	    id: dcBlur

      source: dcDesaturate
      anchors.fill: dcDesaturate
      visible: dcDesaturate.visible

      radius: activeSlot.blur * 100
    }

    ColorOverlay {
	    id: dcColorOverlay

      source: dcBlur
      anchors.fill: dcBlur
      visible: dcBlur.visible

      color: activeSlot.colorizeValue
    }
    // D I S P L A Y C H A I N - - - - - - - - - - - - - - - - - -
    // D I S P L A Y C H A I N - - - - - - - - - - - - - - - - - -
    // D I S P L A Y C H A I N - - - - - - - - - - - - - - - - - -

    Rectangle {
      visible: devShowInfo
	    width: labelInfo.contentWidth
      height: labelInfo.contentHeight
      anchors.top: parent.top
      anchors.left: parent.left
      color: '#ff1d1d85'

	    Label {
		    id: labelInfo
  	    color: "#ffffffff"
  	    text: activeImage.infoText
      }
    }

    function cnvSetCfgAdapter() {

	    cfgAdapter = new JS.CfgAdapter(config);
	    cnvSetActiveDeskCfg();
    }

    function cnvSetActiveDeskCfg() {

	    if( ! cfgAdapter) { return; }
	    //<--
	    if( ! repeaterReady) { return; }
	    //<--      

      const deskCfg = cfgAdapter.findAppropiateCfg(_Pager.currentPage);
      if(activeDeskCfg == deskCfg) { return; }
      //<--


      activeDeskCfg = deskCfg;
      activeImage = _ImageRepeater.itemAt(activeDeskCfg.deskNo);

	    cnvUpdateActiveSlot();
    }

    function cnvUpdateActiveSlot() {

	    let appropiateSlot = activeDeskCfg.findAppropiateTimeslotCfg_now();

	    if(appropiateSlot !== activeImage.slot)
	    {
		    activeImage.imgResetState(appropiateSlot);
	    }

	    activeSlot = activeImage.slot;

	    if(activeSlot.imagesources.length === 0) return;
	    //<--
	    if(activeSlot.interval === 0 && activeImage.src !== "") return;
	    //<--
	    if(Date.now() < (activeImage.timestampFetched + activeSlot.interval*1000)) return;
	    //<--


	    activeImage.imgFetchNext();
    }

    function action_next() {

	    activeImage.imgFetchNext();
    }

    function action_open() {

	    Qt.openUrlExternally(activeImage.source)
    }

    MouseArea {
	    anchors.fill: parent
	    acceptedButtons: Qt.LeftButton
	    onPressAndHold: _Canvas.action_next();
      onDoubleClicked: _Canvas.action_open();
    }

/* Dev */
    Rectangle {
      id: _LogBackground
      color: '#00ff0000'                  
      anchors.left: parent.left
      anchors.right: parent.right
      height: 300

      ScrollView {
        anchors.fill: parent      
        background: Rectangle {
          color: '#0000ff00'
        }      

        TextArea {
          id: _Log
          background: Rectangle {
            color: '#88ffffff'
          }
          wrapMode: TextEdit.Wrap
          horizontalAlignment: TextEdit.AlignRight

          property int autoclear:0

          function clear() {

            text='';
            autoclear=0;
          }

          function sayo($o) {

        	  say(JSON.stringify($o));
          }

          function say($text) {

              text=text+'\n'+$text;
              autoclear++;

              if(autoclear>30)
              {
                  clear();
              }
          }
        }
      }
    }

  function dev_log($o) {

  	_Log.say($o);
  }

  function dev_logo($o) {

	  _Log.sayo($o);
  }      
/* /Dev */    
  }
  // C A N V A S - - - - - - - - - - - - - - - - - -
  // C A N V A S - - - - - - - - - - - - - - - - - -
  // C A N V A S - - - - - - - - - - - - - - - - - -

}
