/*
 *  Copyright 2026  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick as QTQ
import QtQuick.Controls as QTQ_C
import org.kde.plasma.core as KDE_core
import org.kde.plasma.plasmoid as KDE_plasmoid

import QtQuick.Effects as QTQ_E

import org.kde.taskmanager as KDE_taskmanager
import org.kde.plasma.wallpapers.image as KDE_wallpapersImage


import "../js/lib.js" as LJS

/*MOD*/KDE_plasmoid.WallpaperItem { id: _Root

  readonly property bool _enableLogger: false
  readonly property var _LOGGER: _LOGOVERLAY.item

/*MOD*/ // KDE_plasmoid.Plasmoid.backgroundHints: KDE_core.Types.NoBackground
/*MOD*/readonly property var _config: configuration.vallpaper602
/*MOD*/readonly property var _prefixActionText: '<Vallpaper> '

  on_ConfigChanged: {

    let configToUse = _config;
    if( ! configToUse || configToUse.length===0)
    {
/*MOD*/configToUse = LJS.CFG_602_FROM_601(configuration.vallpaper601);
    }

    const configJson = JSON.stringify(configToUse);
    if (_previousConfigJson === configJson) { return; }

    _previousConfigJson = configJson;
    _configAdapter = new LJS.PlasmacfgAdapter(configToUse);

    // Avoid unwanted handlings during change of repeater model--v
    _Timer.stop();
    _activeImage = null;
    _repeaterModel = _configAdapter.getCfgs();
    //--^
    handleSituationChanged();
  }


  readonly property var _qtqScreen: QTQ.Screen

  property var _activeImage: null
  property var _repeaterModel: []
  property var _configAdapter
  property bool _repeaterReady: false
  property var _previousConfigJson
  property var _activeDeskNo

  KDE_core.Action { id: _ActionOpen
    text: _prefixActionText + "Open image"
    icon.name: "document-open"
    priority: KDE_plasmoid.Plasmoid.LowPriorityAction
    visible: true
    enabled: _activeImage ? _activeImage._imageCount > 0 : false
    onTriggered: actionOpen()
  }

  KDE_core.Action { id: _ActionNext
    text: _prefixActionText + "Next image"
    icon.name: "user-desktop"
    priority: KDE_plasmoid.Plasmoid.LowPriorityAction
    visible: true
    enabled: _activeImage ? (_activeImage._imageCount > 1 || _activeImage._usingUrl) : false
    onTriggered: actionNext()
  }

/*MOD*/contextualActions: [
    _ActionOpen,
    _ActionNext
  ]

  QTQ.MouseArea {
    anchors.fill: parent

    acceptedButtons: Qt.LeftButton
    propagateComposedEvents: true

    onClicked: (mouse) => { mouse.accepted = false; }

    onDoubleClicked: (mouse) => {

      if (mouse.button === Qt.LeftButton) { actionOpen(); }
      else { mouse.accepted = false; }
    }

    onPressAndHold: (mouse) => {

      if (mouse.button === Qt.LeftButton) { actionNext(); }
      else { mouse.accepted = false; }
    }
  }

  KDE_taskmanager.VirtualDesktopInfo { id: _VirtualDesktopInfo

    QTQ.Component.onCompleted: {

      updateDeskNo();
      handleSituationChanged();
    }

    onCurrentDesktopChanged: {

      if (LJS.IS_PER_SCREEN_SUPPORTED(_VirtualDesktopInfo)) { return; } // KDE Plasma 6.7+
      //<--


      updateDeskNo();
    }

    // KDE Plasma 6.7+ per-screen signal
    onCurrentDesktopForScreenChanged: ($changedScreenName) => {

      if ($changedScreenName !== _qtqScreen.name) { return; }
      //<--


      updateDeskNo();
    }

    onNumberOfDesktopsChanged: {

      updateDeskNo();
    }

    function updateDeskNo() {

      _activeDeskNo = LJS.GET_CURRENT_DESKNO(_VirtualDesktopInfo, _qtqScreen.name);
      handleSituationChanged();
    }
  }

  QTQ.Timer { id: _Timer

    onTriggered: {

      if (!_activeImage) { return; }
      //<--


      _activeImage.updateStateAndFetchNext();
      updateTimerInterval();
    }
  }

  function actionOpen() {

    if( ! (_activeImage && _activeImage.source)) { return; }
    //<--

    Qt.openUrlExternally(_activeImage.source);
  }

  function actionNext() {

    if( ! _activeImage) { return; }
    //<--

    _activeImage.imgRequestNext(true);
    updateTimerInterval();
  }

  function handleSituationChanged() {

    if (!(_repeaterReady && _activeDeskNo && _ImageRepeater)) { return; }
    //<--


    _activeImage = imageFor(_activeDeskNo);
    if( ! _activeImage) { return }
    //<--


    _activeImage.updateStateAndFetchNext();
    updateTimerInterval();
  }

  function updateTimerInterval() {

    if (!(_Timer && _activeDeskNo && _activeImage && _configAdapter)) { return; }
    //<--


    const deskCfg = _configAdapter.ensureCfgForDeskNo(_activeDeskNo);
    if (!deskCfg || !_activeImage._slotCfg) { return; }
    //<--


    const timeslotDelta = deskCfg.getMillisToNextTimeslot(_activeImage._slotCfg.slotmarker);
    const slideDelta = _activeImage.getMillisToNextSlide();
    const nextDelta = Math.min(timeslotDelta, slideDelta);

    if(isFinite(nextDelta))
    {
      _Timer.interval = nextDelta;
      _Timer.restart();
    }
    else
    {
      _Timer.stop();
    }
  }

  function imageFor($deskNo) {

    if (!_configAdapter) { return null; }
    //<--


    const deskCfg = _configAdapter.ensureCfgForDeskNo($deskNo);
    const targetDeskNo = deskCfg.deskNo;
    for (let i = 0; i < _ImageRepeater.count; ++i)
    {
      const item = _ImageRepeater.itemAt(i);
      if (item._deskNo === targetDeskNo) { return item; }
      //<--


    }

    return null;
  }

  // C A N V A S - - - - - - - - - - - - - - - - - -
  // C A N V A S - - - - - - - - - - - - - - - - - -
  // C A N V A S - - - - - - - - - - - - - - - - - -
  QTQ.Rectangle { id: _Canvas

    anchors.fill: parent
    color: (_activeImage && _activeImage._slotCfg) ? _activeImage._slotCfg.background : "#ffff00"

    QTQ.Repeater { id: _ImageRepeater

      model: _repeaterModel
      onModelChanged: {

        if (!model || model.length === 0 || !_configAdapter) { return; }
        //<--


        _repeaterReady = true;
        handleSituationChanged();
      }

      // I M A G E - - - - - - - - - - - - - - - - - -
      // I M A G E - - - - - - - - - - - - - - - - - -
      // I M A G E - - - - - - - - - - - - - - - - - -
      QTQ.Image { id: _DelegateImage
        anchors.fill: parent

        visible: false // displayed through Graphical effects

        //  this property sets the maximum number of pixels stored for the loaded image so that large images do not use more memory than necessary.
        //  If only one dimension of the size is set to greater than 0, the other dimension is set in proportion to preserve the source image's aspect ratio. (The fillMode is independent of this.)
        sourceSize.width: width

        asynchronous: true
        autoTransform: true // This property holds whether the image should automatically apply image transformation metadata such as EXIF orientation.

        readonly property int _deskNo: modelData.deskNo
        property var _slotCfg

        property string _infoText
		    property var _timestampFetched: null
        property int _imageCount: 0
        readonly property var _usingUrl: !cache

        property var _kdeWpBackend: KDE_wallpapersImage.ImageBackend {
          usedInConfig: false
          renderingMode: KDE_wallpapersImage.ImageBackend.SlideShow
          slideTimer: LJS.KDE_IMAGEBACKEND_SLIDETIMER_MAXVALUE // don't let ImageBackend do its slideshow

          onImageChanged: _DelegateImage.updateCount()
          onLoadingChanged: _DelegateImage.updateCount()
        }

        QTQ.Connections {
          target: _kdeWpBackend.slideFilterModel

          function onRowsInserted()   { _DelegateImage.updateCountAndImage(); }
          function onRowsRemoved()    { _DelegateImage.updateCount(); }
          function onModelReset()     { _DelegateImage.updateCountAndImage(); }
          function onLayoutChanged()  { _DelegateImage.updateCountAndImage(); }
        }

        QTQ.Component.onCompleted: { updateStateAndFetchNext(); }

        function getCount() {

          const count =  _slotCfg ? (LJS.IS_USE_URL(_slotCfg.imagesources) ? 1 : (_kdeWpBackend && _kdeWpBackend.slideFilterModel ? _kdeWpBackend.slideFilterModel.rowCount() : 0)) : 0;
          return count;
        }

        function updateCount() { _imageCount = getCount(); }

        function updateCountAndImage() {

          updateCount();

          if(!_timestampFetched && _imageCount > 0)
          {
            // Run async, so if triggered by multiple events, execute only once (on first !_timestampFetched)
            Qt.callLater(() => { if(!_timestampFetched && _imageCount > 0) { imgRequestNext(); }});
          }
        }

        function getMillisToNextSlide() {

          if (!_slotCfg || _slotCfg.interval === 0 || (_imageCount <= 1 && !LJS.IS_USE_URL(_slotCfg.imagesources))) { return Infinity; }
          if(!_timestampFetched) { return 0;}
          //<--


          const nextTimestamp = _timestampFetched + (_slotCfg.interval * 1000);
          const remaining = nextTimestamp - Date.now();
          return Math.max(LJS.MILLIS_TO_NEXT_MIN_ms, remaining);
        }

		    function updateStateAndFetchNext() {

          if( ! _configAdapter) { return; }
	        //<--


          const deskCfg = _configAdapter.ensureCfgForDeskNo(_deskNo);
          const applicableSlotCfg = deskCfg.findNowActiveTimeslotCfg();

          if(applicableSlotCfg !== _slotCfg)
          {
            source = "";
            _infoText = "";
			      _timestampFetched = null;
			      _slotCfg = applicableSlotCfg;

			      anchors.topMargin =     _slotCfg.paddingTop;
            anchors.bottomMargin =  _slotCfg.paddingBottom;
            anchors.leftMargin =    _slotCfg.paddingLeft;
            anchors.rightMargin =   _slotCfg.paddingRight;

            fillMode = _slotCfg.fillMode;

            _kdeWpBackend.slidePaths = [];

            if( ! LJS.IS_USE_URL(_slotCfg.imagesources) && _slotCfg.imagesources.length>0)
            {
              let newPaths = [];
              for(let $$path of _slotCfg.imagesources)
			        {
				        newPaths.push($$path);
			        }
              _kdeWpBackend.slidePaths = newPaths;

              _kdeWpBackend.slideshowMode = _slotCfg.shuffleMode;
            }
          }

          imgRequestNext();
		    }

        function imgRequestNext($force=false) {

          if( ! $force &&
              _timestampFetched &&
              (_slotCfg.interval === 0 || (Date.now() < (_timestampFetched + _slotCfg.interval*1000)))
          ) { return; }
          //<--


          if(getCount() === 0) { return; }
          //<--


          if(LJS.IS_USE_URL(_slotCfg.imagesources))
          {
            cache = false;

            source = ""; // trigger reload
            source = LJS.GET_URL(_slotCfg.imagesources);
          }
          else
          {
            cache = true;

            _kdeWpBackend.nextSlide();
            source = _kdeWpBackend.image;
          }

          _infoText = source;
          _timestampFetched = Date.now();
          updateTimerInterval();
		    }
	    }
      // - - - - - - - - - - - - - I M A G E
      // - - - - - - - - - - - - - I M A G E
      // - - - - - - - - - - - - - I M A G E
    }

    // D I S P L A Y - - - - - - - - - - - - - - - - - -
    // D I S P L A Y - - - - - - - - - - - - - - - - - -
    // D I S P L A Y - - - - - - - - - - - - - - - - - -
    QTQ_E.MultiEffect {

      source: _activeImage
      anchors.fill: _activeImage
      visible: _activeImage ? _activeImage.source !== "" : false

      saturation: (_activeImage && _activeImage._slotCfg) ? -1 + _activeImage._slotCfg.saturatePct/100 : 0.0

      blurEnabled: blur > 0.0
      blur: (_activeImage && _activeImage._slotCfg) ? _activeImage._slotCfg.blurPct/100 : 0.0
      blurMax: 32

      colorization: (_activeImage && _activeImage._slotCfg) ? _activeImage._slotCfg.colorizePct/100 : 0.0
      colorizationColor: (_activeImage && _activeImage._slotCfg) ? _activeImage._slotCfg.colorizeColor : "#ffffff"
    }

    QTQ.Rectangle {
      visible: Boolean(_activeImage && _activeImage._slotCfg && _activeImage._slotCfg.displayCurrentSource)
	    width: labelInfo.contentWidth
      height: labelInfo.contentHeight
      anchors.top: parent.top
      anchors.left: parent.left
      color: '#ff071169'

	    QTQ_C.Label {
		    id: labelInfo
  	    color: "#ffffffff"
  	    text: !_activeImage?"? ? ?":"[[" + _qtqScreen.name + "#" + _activeDeskNo + "]] " + _activeImage._infoText
      }
    }
    // - - - - - - - - - - - - - D I S P L A Y
    // - - - - - - - - - - - - - D I S P L A Y
    // - - - - - - - - - - - - - D I S P L A Y
  }
  // - - - - - - - - - - - - - C A N V A S
  // - - - - - - - - - - - - - C A N V A S
  // - - - - - - - - - - - - - C A N V A S

  QTQ.Loader {
    id: _LOGOVERLAY
    source: _enableLogger?"subparts/LogOverlay.qml":""

    anchors.fill: parent
    enabled: false // let clicks through
  }
}
