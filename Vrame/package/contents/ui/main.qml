/*
 *  Copyright 2025  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick
import QtQuick.Controls
import org.kde.kquickcontrolsaddons
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.private.mediaframe
import org.kde.plasma.private.pager

import Qt5Compat.GraphicalEffects

import "../js/v.js" as VJS

PlasmoidItem {
	id: _Root

  Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

  property var devShowInfo: true

  property var connector2Plasma: plasmoid
  property var config: Plasmoid.configuration.vrame6
  property var previousConfig

  property var plasmacfgAdapter
  property var prefixActionText: /*SED01*/'' // empty

  property var activeDeskCfg
  property var activeImage
  property var activeSlotCfg

  property var actionOpenEnabled: true
  property var actionNextEnabled: true  

  property bool repeaterReady: false

  onActiveImageChanged: { 
    // Workaround: activeImage wird durch irgendwas auf null gesetzt!??1!
    
    if(activeImage!=null) { return; }
    //<--

    
    activeImage = _ImageRepeater.itemAt(_Pager.currentPage);
   }    

  onConfigChanged: {

    if(previousConfig==config) { return;}
    //<--


    previousConfig=config;
    _Canvas.cnvSetPlasmacfgAdapter();
  }

  Plasmoid.contextualActions: [
    PlasmaCore.Action {
        text: "Open image"
        icon.name: "document-open"
        priority: Plasmoid.LowPriorityAction
        visible: true
        enabled: actionOpenEnabled
        onTriggered: actionOpen()
    },
    PlasmaCore.Action {
        text: "Next image"
        icon.name: "user-desktop"
        priority: Plasmoid.LowPriorityAction
        visible: true
        enabled: actionNextEnabled
        onTriggered: actionNext()
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
    onTriggered: { _Canvas.cnvUpdateActiveSlotCfg();}
  }  

  // C A N V A S - - - - - - - - - - - - - - - - - -
  // C A N V A S - - - - - - - - - - - - - - - - - -
  // C A N V A S - - - - - - - - - - - - - - - - - -  
  Rectangle {
    id: _Canvas

    anchors.fill: parent          
    color: activeSlotCfg.background

    Repeater {
	    id: _ImageRepeater
  
      model: _Pager.count

      Component.onCompleted: {
        
        repeaterReady=true;

        _Canvas.cnvSetActiveDeskCfg();
		  }


      // I M A G E - - - - - - - - - - - - - - - - - -
      // I M A G E - - - - - - - - - - - - - - - - - -
      // I M A G E - - - - - - - - - - - - - - - - - -      
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
        property var slotCfg
        property var mediaframe: MediaFrame {}

		    Component.onCompleted: { imgResetState(); }

		    function imgResetState($newSlotCfg=undefined) {

			    timestampFetched = -1;
			    slotCfg = $newSlotCfg;

			    if(slotCfg===undefined) return;
			    //<--


			    imgApplyCfg();
		    }

		    function imgApplyCfg() {

			    fillMode = slotCfg.fillMode;

			    anchors.topMargin =     slotCfg.paddingTop;
          anchors.bottomMargin =  slotCfg.paddingBottom;
          anchors.leftMargin =    slotCfg.paddingLeft;
          anchors.rightMargin =   slotCfg.paddingRight;

			    mediaframe.clear();
			    mediaframe.random = slotCfg.shuffle;
          for(let $$path of slotCfg.imagesources)
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
					    let resanitized = VJS.AS_URISAFE($$path);
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
      // - - - - - - - - - - - - - I M A G E
      // - - - - - - - - - - - - - I M A G E
      // - - - - - - - - - - - - - I M A G E      
    }

    // D I S P L A Y C H A I N - - - - - - - - - - - - - - - - - -
    // D I S P L A Y C H A I N - - - - - - - - - - - - - - - - - -
    // D I S P L A Y C H A I N - - - - - - - - - - - - - - - - - -    
    Desaturate {
	    id: dcDesaturate

      source: activeImage
      anchors.fill: activeImage
      visible: activeImage.source!=""

      desaturation: activeSlotCfg.desaturate
    }

    FastBlur {
	    id: dcBlur

      source: dcDesaturate
      anchors.fill: dcDesaturate
      visible: dcDesaturate.visible

      radius: activeSlotCfg.blur * 100
    }

    ColorOverlay {
	    id: dcColorOverlay

      source: dcBlur
      anchors.fill: dcBlur
      visible: dcBlur.visible

      color: activeSlotCfg.colorizeValue
    }
    // - - - - - - - - - - - - - D I S P L A Y C H A I N
    // - - - - - - - - - - - - - D I S P L A Y C H A I N
    // - - - - - - - - - - - - - D I S P L A Y C H A I N    

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

    function cnvSetPlasmacfgAdapter() {

	    plasmacfgAdapter = new VJS.PlasmacfgAdapter(config);
	    cnvSetActiveDeskCfg();
    }

    function cnvSetActiveDeskCfg() {

	    if( ! plasmacfgAdapter) { return; }
	    //<--
	    if( ! repeaterReady) { return; }
	    //<--      

      const deskCfg = plasmacfgAdapter.findAppropiateDeskCfgFor_pageNo(_Pager.currentPage);
      if(activeDeskCfg == deskCfg) { return; }
      //<--


      activeDeskCfg = deskCfg;
      activeImage = _ImageRepeater.itemAt(_Pager.currentPage);

	    cnvUpdateActiveSlotCfg();
    }

    function cnvUpdateActiveSlotCfg() {

	    let appropiateSlotCfg = activeDeskCfg.findAppropiateSlotCfgFor_now();

	    if(appropiateSlotCfg !== activeImage.slotCfg)
	    {
		    activeImage.imgResetState(appropiateSlotCfg);
	      activeSlotCfg = activeImage.slotCfg;        
	    }

	    if(activeSlotCfg.imagesources.length === 0) return;
	    //<--
	    if(activeSlotCfg.interval === 0 && activeImage.src !== "") return;
	    //<--
	    if(Date.now() < (activeImage.timestampFetched + activeSlotCfg.interval*1000)) return;
	    //<--


	    activeImage.imgFetchNext();
    }

    function actionNext() {

	    activeImage.imgFetchNext();
    }

    function actionOpen() {

	    Qt.openUrlExternally(activeImage.source)
    }

    MouseArea {
	    anchors.fill: parent
	    acceptedButtons: Qt.LeftButton
	    onPressAndHold: _Canvas.actionNext();
      onDoubleClicked: _Canvas.actionOpen();
    }

/* Dev */
    Rectangle {
      id: _LogBackground
      color: '#00ff0000'                  
      anchors.fill: parent

      ScrollView {
        anchors.fill: parent      
        background: Rectangle {
          color: '#0000ff00'
        }      

        TextArea {
          id: _Log
          readOnly: true
          
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
  // - - - - - - - - - - - - - C A N V A S
  // - - - - - - - - - - - - - C A N V A S
  // - - - - - - - - - - - - - C A N V A S  

}
