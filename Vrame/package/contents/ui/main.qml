/*
 *  Copyright 2026  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick as QTQ
import QtQuick.Controls as QTQ_C
import org.kde.plasma.core as KDE_pc
import org.kde.plasma.plasmoid as KDE_plasmoid

import Qt5Compat.GraphicalEffects as QT5_ge

/* 6.5 */ import org.kde.plasma.private.pager as KDE_pager /**/
/* 6.6 * import plasma.applet.org.kde.plasma.pager as KDE_pager /**/

import org.kde.plasma.wallpapers.image as KDE_wallpaper


import "../js/v.js" as VJS

/*MOD*/KDE_plasmoid.PlasmoidItem {
	id: _Root

/*MOD*/property var config: KDE_plasmoid.Plasmoid.configuration.vrame6
/*MOD*/KDE_plasmoid.Plasmoid.backgroundHints: KDE_pc.Types.NoBackground
/*MOD*/property var prefixActionText: '' // empty

  property var previousConfigJson
  property var configAdapter

  property var activeImage
  property bool repeaterReady: false

/*MOD*/KDE_plasmoid.Plasmoid.contextualActions: [
    KDE_pc.Action {
        text: prefixActionText + "Open image"
        icon.name: "document-open"
        priority: KDE_plasmoid.Plasmoid.LowPriorityAction
        visible: true
        enabled: activeImage.getCount()>0
        onTriggered: { _Canvas.actionOpen(); }
    },
    KDE_pc.Action {
        text: prefixActionText + "Next image"
        icon.name: "user-desktop"
        priority: KDE_plasmoid.Plasmoid.LowPriorityAction
        visible: true
        enabled: activeImage.getCount()>1 || !activeImage.cache
        onTriggered: { _Canvas.actionNext(); }
    }
  ]

  onConfigChanged: {

    const configJson = JSON.stringify(config);
    if(previousConfigJson==configJson) { return;}
    //<--


    previousConfigJson=configJson;
    configAdapter = new VJS.PlasmacfgAdapter(config);
  }

	KDE_pager.PagerModel {
    id: _Pager

    enabled: _Root.visible
    pagerType: KDE_pager.PagerModel.VirtualDesktops

    QTQ.Component.onCompleted: {

      _ImageRepeater.model = count + 1; // +1 =^= shared image
    }

    onCurrentPageChanged: {

      if( ! repeaterReady) { return; }
	    //<--


      const newActiveImage = _ImageRepeater.imageFor(_Pager.currentPage);
      newActiveImage.refresh();
      activeImage = newActiveImage;
    }
	}

  QTQ.Timer {
	  id: _Timer
    interval: 1000 * 1 // sec
    repeat: true
    running: true
    onTriggered: {

      if( ! activeImage) { return; }
	    //<--


      activeImage.refresh();
    }
  }

  // C A N V A S - - - - - - - - - - - - - - - - - -
  // C A N V A S - - - - - - - - - - - - - - - - - -
  // C A N V A S - - - - - - - - - - - - - - - - - -
  QTQ.Rectangle {
    id: _Canvas

    anchors.fill: parent
    color: activeImage.slotCfg.background

    QTQ.Repeater {
	    id: _ImageRepeater

      onModelChanged: {

        if(model==0) { return; };
        //<--


        repeaterReady=true;

        activeImage = _ImageRepeater.imageFor(_Pager.currentPage);
        activeImage.refresh();
      }

      function imageFor($pageNo) {

        const deskCfg = configAdapter.findAppropiateDeskCfgFor_pageNo($pageNo);

        const imageIdx = deskCfg.deskNo==VJS.DESKNO_GLOBAL?count-1:$pageNo;

        return itemAt(imageIdx);
      }

      // I M A G E - - - - - - - - - - - - - - - - - -
      // I M A G E - - - - - - - - - - - - - - - - - -
      // I M A G E - - - - - - - - - - - - - - - - - -
      QTQ.Image {
        anchors.fill: parent

        visible: false // displayed through Graphical effects

        //  this property sets the maximum number of pixels stored for the loaded image so that large images do not use more memory than necessary.
        //  If only one dimension of the size is set to greater than 0, the other dimension is set in proportion to preserve the source image's aspect ratio. (The fillMode is independent of this.)
        sourceSize.width: width

        asynchronous: true
        autoTransform: true

        property var slotCfg

        property string infoText
		    property var timestampFetched
        property var wpBackend: KDE_wallpaper.ImageBackend {
          usedInConfig: false
          renderingMode: KDE_wallpaper.ImageBackend.SlideShow
        }

		    QTQ.Component.onCompleted: { refresh(); }

        function getCount() { return VJS.IS_USE_URL(slotCfg.imagesources)?1:wpBackend.slideFilterModel.rowCount(); }

		    function refresh() {

          if( ! configAdapter) { return; }
	        //<--


          const deskCfg = configAdapter.findAppropiateDeskCfgFor_pageNo(index);
          const appropiateSlotCfg = deskCfg.findAppropiateSlotCfgFor_now();

          if(appropiateSlotCfg!=slotCfg)
          {
            source = "";
            infoText = source;
			      timestampFetched = -1;
			      slotCfg = appropiateSlotCfg;

			      anchors.topMargin =     slotCfg.paddingTop;
            anchors.bottomMargin =  slotCfg.paddingBottom;
            anchors.leftMargin =    slotCfg.paddingLeft;
            anchors.rightMargin =   slotCfg.paddingRight;

            fillMode = slotCfg.fillMode;

            wpBackend.pauseSlideshow = true;
            wpBackend.slidePaths = [];

            if( ! VJS.IS_USE_URL(slotCfg.imagesources))
            {
              wpBackend.slideshowMode = slotCfg.shuffleMode;
              //wpBackend.slideFilterModel.sortRole = wpBackend.slideshowMode;
              wpBackend.slideTimer = slotCfg.interval==0?VJS.PLASMA_SLIDETIMER_MAXVALUE:slotCfg.interval;

              for(let $$path of slotCfg.imagesources)
			        {
                const safePath = VJS.AS_URISAFE($$path);
				        wpBackend.addSlidePath(safePath);
			        }

              wpBackend.pauseSlideshow = slotCfg.interval==0;
            }
          }

          imgFetchNext();
		    }

		    function imgFetchNext($force=false) {

          if( ! $force &&
              ! (timestampFetched===-1) &&
              (slotCfg.interval==0 || (Date.now() < (timestampFetched + slotCfg.interval*1000)))
          ) { return; }
          //<--


          if(getCount() === 0) { return; }
          //<--


          if(VJS.IS_USE_URL(slotCfg.imagesources))
          {
            cache = false;

            source = ""; // trigger reload
            source = VJS.GET_URL(slotCfg.imagesources);
          }
          else
          {
            cache = true;

            if($force) { wpBackend.nextSlide(); }
            source = wpBackend.image;
          }

          infoText = source;
          timestampFetched = Date.now();
		    }
	    }
      // - - - - - - - - - - - - - I M A G E
      // - - - - - - - - - - - - - I M A G E
      // - - - - - - - - - - - - - I M A G E
    }

    // D I S P L A Y C H A I N - - - - - - - - - - - - - - - - - -
    // D I S P L A Y C H A I N - - - - - - - - - - - - - - - - - -
    // D I S P L A Y C H A I N - - - - - - - - - - - - - - - - - -
    QT5_ge.Desaturate {
	    id: dcDesaturate

      source: activeImage
      anchors.fill: activeImage
      visible: activeImage.source!=""

      desaturation: activeImage.slotCfg.desaturate
    }

    QT5_ge.FastBlur {
	    id: dcBlur

      source: dcDesaturate
      anchors.fill: dcDesaturate
      visible: dcDesaturate.visible

      radius: activeImage.slotCfg.blur * 100
    }

    QT5_ge.ColorOverlay {
	    id: dcColorOverlay

      source: dcBlur
      anchors.fill: dcBlur
      visible: dcBlur.visible

      color: activeImage.slotCfg.colorizeValue
    }
    // - - - - - - - - - - - - - D I S P L A Y C H A I N
    // - - - - - - - - - - - - - D I S P L A Y C H A I N
    // - - - - - - - - - - - - - D I S P L A Y C H A I N

    QTQ.Rectangle {
      visible: activeImage.slotCfg.displayCurrentSource
	    width: labelInfo.contentWidth
      height: labelInfo.contentHeight
      anchors.top: parent.top
      anchors.left: parent.left
      color: '#ff1d1d85'

	    QTQ_C.Label {
		    id: labelInfo
  	    color: "#ffffffff"
  	    text: activeImage.infoText
      }
    }

    function actionNext() {

	    activeImage.imgFetchNext(true);
    }

    function actionOpen() {

	    Qt.openUrlExternally(activeImage.source)
    }

/* Dev *
    QTQ.Rectangle {
      id: _LogBackground
      color: '#00ff0000'
      anchors.fill: parent

      QTQ_C.ScrollView {
        anchors.fill: parent
        background: QTQ.Rectangle {
          color: '#0000ff00'
        }

        QTQ_C.TextArea {
          id: _Log
          readOnly: true

          background: QTQ.Rectangle {
            color: '#88ffffff'
          }
          wrapMode: QTQ.TextEdit.Wrap
          horizontalAlignment: QTQ.TextEdit.AlignRight

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
/* /Dev */
  }
  // - - - - - - - - - - - - - C A N V A S
  // - - - - - - - - - - - - - C A N V A S
  // - - - - - - - - - - - - - C A N V A S


  QTQ.MouseArea {
    anchors.fill: parent

    onPressAndHold: { _Canvas.actionNext(); }
    onDoubleClicked: { _Canvas.actionOpen(); }
  }
}
