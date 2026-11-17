/*
 *  Copyright 2026  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick as QTQ
import QtQuick.Controls as QTQ_C
import QtQuick.Layouts as QTQ_L
import QtQuick.Dialogs as QTQ_D

import org.kde.taskmanager as KDE_taskmanager
import org.kde.plasma.wallpapers.image as KDE_wallpapersImage

import "subparts" as SUBPARTS
import "../js/lib.js" as LJS

QTQ_L.ColumnLayout { id: _Root
  property var title // for KDE Settings page

/*MOD*/property var cfg_vallpaper602
/*MOD*/property var cfg_vallpaper601
/*MOD*/property var cfg_vallpaper602Default // for Plasma
/*MOD*/property var cfg_vallpaper601Default // for Plasma

  readonly property bool _enableLogger: false
  readonly property var _LOGGER: _LOGOVERLAY.item

  readonly property var _qtqScreenName: QTQ.Screen.name
  on_QtqScreenNameChanged: _SelectDesktop.init()

  property var _plasmacfgAdapter
  property var _currentDeskCfg
  property var _currentSlotCfg

  QTQ.Component.onCompleted: {

/*MOD*/if ((!cfg_vallpaper602 || cfg_vallpaper602.length === 0) && (cfg_vallpaper601 && cfg_vallpaper601.length > 0)) { cfg_vallpaper602 = LJS.CFG_602_FROM_601(cfg_vallpaper601); }
/*MOD*/_plasmacfgAdapter = new LJS.PlasmacfgAdapter(cfg_vallpaper602, ($newCfg) => { cfg_vallpaper602 = $newCfg; });

    _SelectDesktop.init();
  }

  QTQ.FontMetrics { id: _FontMetrics }

  QTQ.SystemPalette { id: _ActiveSystemPalette
    colorGroup: QTQ.SystemPalette.Active
  }

  KDE_taskmanager.VirtualDesktopInfo { id: _VirtualDesktopInfo }

  function buildSelectDesktopElement($deskNo) {

    return {
      'displayText': (LJS.DESKNO_GLOBAL === $deskNo ? LJS.DESKNO_GLOBAL_NAME : _VirtualDesktopInfo.desktopNames[$deskNo - 1]),
      'deskNo': $deskNo
    };
  }


  function ensureIndexOfValue($model, $value) {

    for (let idx = 0; idx < $model.length; ++idx)
    {
      if ($model[idx].value === $value) { return idx; }
      //<--


    }

    return 0;
  }

  QTQ_L.RowLayout { // Container

    /* left padding */ QTQ.Item { width: _FontMetrics.averageCharacterWidth}

    QTQ_L.ColumnLayout { // content
      QTQ_L.Layout.fillWidth: true

      // S E L E C T   D E S K T O P - - - - - - - - - -
      // S E L E C T   D E S K T O P - - - - - - - - - -
      // S E L E C T   D E S K T O P - - - - - - - - - -
      QTQ_L.RowLayout {

        QTQ_C.Label {
          text: "For desktop"
          font.styleName: "Bold"

          QTQ.MouseArea { id: _DimensionsLabelMouseArea
            anchors.fill: parent
            hoverEnabled: true
          }

          QTQ_C.ToolTip.visible: _DimensionsLabelMouseArea.containsMouse
          QTQ_C.ToolTip.text: "Screen: " + QTQ.Screen.name
        }

        QTQ_C.ComboBox { id: _SelectDesktop

          QTQ_L.Layout.fillWidth: true
          model: QTQ.ListModel { id: _ModelSelectDesktop }
          textRole: 'displayText'

          QTQ.Connections { id: _SelectDesktopConnections

            target: _SelectDesktop

            function onCurrentIndexChanged() { _SelectDesktop.handleCurrentIndexChanged(); }
            function onCountChanged() { _SelectDesktop.updateButtonsState(); }
          }

          function init() {

            if ( ! (_plasmacfgAdapter && _ModelSelectDesktop)) { return; }
            //<--


            const deskNo = LJS.GET_CURRENT_DESKNO(_VirtualDesktopInfo, _qtqScreenName);

            let activateNo = LJS.DESKNO_GLOBAL;

            const memConnTarget = _SelectDesktopConnections.target;
            _SelectDesktopConnections.target = null;

            _ModelSelectDesktop.clear();
            for (const $$cfg of _plasmacfgAdapter.getCfgs())
            {
              insertElement(buildSelectDesktopElement($$cfg.deskNo));

              if ($$cfg.deskNo === deskNo) { activateNo = $$cfg.deskNo;}
            }

            _SelectDesktopConnections.target = memConnTarget;


            let activateIndex = 0;
            for (let i = 0; i < _ModelSelectDesktop.count; ++i)
            {
              if (_ModelSelectDesktop.get(i).deskNo === activateNo)
              {
                activateIndex = i;
                break;
              }
            }

            if (currentIndex === activateIndex)
            {
              handleCurrentIndexChanged();
            }
            else
            {
              currentIndex = activateIndex;
            }
          }

          function handleCurrentIndexChanged() {

            updateButtonsState();

            const item = _ModelSelectDesktop.get(currentIndex);
            _currentDeskCfg = _plasmacfgAdapter.getCfgForDeskNo(item.deskNo);
          }

          function updateButtonsState() {

            _BtnAddDesktopConfig.enabled = _ModelSelectDesktop.count < _VirtualDesktopInfo.numberOfDesktops + 1;
            _BtnRemoveDesktopConfig.enabled = currentIndex > 0;
          }

          function insertElement($desktopElement) {

            let idx = 0;

            if (_ModelSelectDesktop.count === 0)
            {
              _ModelSelectDesktop.append($desktopElement);
            }
            else
            {
              while (idx < _ModelSelectDesktop.count && $desktopElement.deskNo > _ModelSelectDesktop.get(idx).deskNo)
              {
                ++idx;
              }

              _ModelSelectDesktop.insert(idx, $desktopElement);
            }

            const memConnTarget = _SelectDesktopConnections.target;
            _SelectDesktopConnections.target = null;

            // reassign model, so dropdownbox shows correct order !?
            _SelectDesktop.model=null;
            _SelectDesktop.model=_ModelSelectDesktop;

            _SelectDesktopConnections.target = memConnTarget;

            currentIndex = idx;
            handleCurrentIndexChanged();
          }

          function removeDesktopConfig() {

            const currentItem = _ModelSelectDesktop.get(currentIndex);

            _plasmacfgAdapter.deleteCfgDeskNo(currentItem.deskNo);
            _ModelSelectDesktop.remove(currentIndex);

            currentIndex = Math.min(currentIndex, _ModelSelectDesktop.count - 1);
            handleCurrentIndexChanged();
          }
        }

        QTQ_C.Button { id: _BtnAddDesktopConfig
          icon.name: "list-add"

          onClicked: _DlgAddDesktopConfig.open()
        }

        QTQ_C.Button { id: _BtnRemoveDesktopConfig
          icon.name: "edit-delete-remove"

          onClicked: _SelectDesktop.removeDesktopConfig()
        }
      }
      // - - - - - - - - - - S E L E C T   D E S K T O P
      // - - - - - - - - - - S E L E C T   D E S K T O P
      // - - - - - - - - - - S E L E C T   D E S K T O P

      // S E L E C T   S L O T   - - - - - - - - - -
      // S E L E C T   S L O T   - - - - - - - - - -
      // S E L E C T   S L O T   - - - - - - - - - -
      QTQ_L.RowLayout {

        QTQ_C.Button { id: _BtnDonate

          text: 'Donate with PayPal'
          leftPadding: 14
          rightPadding: 14
          topPadding: 8
          bottomPadding: 8
          contentItem: QTQ_C.Label {
            text: _BtnDonate.text
            font.pointSize: parent.font.pointSize * 0.8
            font.bold: true
            color: '#ffffff'
            horizontalAlignment: QTQ.Text.AlignHCenter
            verticalAlignment: QTQ.Text.AlignVCenter
          }
          background: QTQ.Rectangle {
            radius: 4
            color: _BtnDonate.pressed ? '#005a94' : (_BtnDonate.hovered ? '#005ea6' : '#0070ba')
          }
          onClicked: Qt.openUrlExternally('https://www.paypal.com/donate/?hosted_button_id=U5UKKNTXNPTLN')
        }

        QTQ.Item { QTQ_L.Layout.fillWidth: true }

        QTQ_C.Label { text: "Activated at" }

        QTQ_C.ComboBox { id: _SelectSlot
          model: QTQ.ListModel{ id: _ModelSelectSlot }

          QTQ.Connections { id: _SelectSlotConnections

            target: _SelectSlot

            function onCurrentIndexChanged() { _SelectSlot.handleCurrentIndexChanged(); }
            function onCountChanged() { _SelectSlot.updateButtonsState(); }
          }

          property alias _currentDeskCfg: _Root._currentDeskCfg
          on_CurrentDeskCfgChanged: {

            const memConnTarget = _SelectSlotConnections.target;
            _SelectSlotConnections.target = null;

            _ModelSelectSlot.clear();
            const nowTimeslotCfg = _currentDeskCfg.findNowActiveTimeslotCfg();
            const orderedTimeslotCfgs = _currentDeskCfg.getOrderedTimeslots();

            let activateIdx = 0;
            for (let $$i = 0; $$i < orderedTimeslotCfgs.length; ++$$i)
            {
              const timeslotCfg = orderedTimeslotCfgs[$$i];
              insertSlot({ "slotmarker": timeslotCfg.slotmarker });

              if (timeslotCfg === nowTimeslotCfg) { activateIdx = $$i; }
            }

            _SelectSlotConnections.target = memConnTarget;

            if (_SelectSlot.currentIndex === activateIdx)
            {
              handleCurrentIndexChanged();
            }
            else
            {
              currentIndex = activateIdx;
            }
          }

          function insertSlot($slot) {

            let idx = 0;

            if (_ModelSelectSlot.count === 0)
            {
              _ModelSelectSlot.append($slot);
            }
            else
            {
              while (idx < _ModelSelectSlot.count && $slot.slotmarker > _ModelSelectSlot.get(idx).slotmarker)
              {
                ++idx;
              }

              _ModelSelectSlot.insert(idx, $slot);
            }


            const memConnTarget = _SelectSlotConnections.target;
            _SelectSlotConnections.target = null;

            // reassign model, so dropdownbox shows correct order !?
            _SelectSlot.model=null;
            _SelectSlot.model=_ModelSelectSlot;

            _SelectSlotConnections.target = memConnTarget;

            currentIndex = idx;
            handleCurrentIndexChanged();
          }

          function addTimeslotFromDialog(newSlotMarker, currentSlotMarker) {

            _plasmacfgAdapter.atCfg_newTimeslotForMarker_cloneMarker(_currentDeskCfg, newSlotMarker, currentSlotMarker);
            insertSlot({ "slotmarker": newSlotMarker });
          }

          function handleCurrentIndexChanged() {

            updateButtonsState();

            const item = _ModelSelectSlot.get(currentIndex);
            _currentSlotCfg = _currentDeskCfg.getTimeslotForSlotmarker(item.slotmarker);
          }

          function updateButtonsState() {

            _BtnAddTimeslot.enabled = _ModelSelectSlot.count < 60 * 24;
            _BtnRemoveTimeslot.enabled = currentIndex > 0;
          }

          function removeTimeslot() {

            const currentItem = _ModelSelectSlot.get(currentIndex);

            _plasmacfgAdapter.atCfg_deleteTimeslot(_currentDeskCfg, currentItem.slotmarker);
            _ModelSelectSlot.remove(currentIndex);

            currentIndex = Math.min(currentIndex, _ModelSelectSlot.count - 1);
            handleCurrentIndexChanged();
          }
        }

        QTQ_C.Button { id: _BtnAddTimeslot
          icon.name: "list-add"

          onClicked: _DlgCreateTimeslot.open()
        }

        QTQ_C.Button { id: _BtnRemoveTimeslot
          icon.name: "edit-delete-remove"

          onClicked: _SelectSlot.removeTimeslot()
        }
      }
      // - - - - - - - - - -  S E L E C T   S L O T
      // - - - - - - - - - -  S E L E C T   S L O T
      // - - - - - - - - - -  S E L E C T   S L O T

      QTQ_C.Frame {
        QTQ_L.Layout.fillWidth: true
        QTQ_L.Layout.fillHeight: true

        background: QTQ.Rectangle { // group box border
          anchors.fill: parent
          color: "transparent"
          border.color: _ActiveSystemPalette.mid
          border.width: 2
          radius: 5
        }

        QTQ_L.ColumnLayout {
          anchors.fill: parent

          // B A C K G R O U N D   - - - - - - - - - -
          // B A C K G R O U N D   - - - - - - - - - -
          // B A C K G R O U N D   - - - - - - - - - -
          QTQ_L.GridLayout {
            columns: 3

            // a0-1
            QTQ_C.Label {
              QTQ_L.Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 15

              text: 'Background'
              font.styleName: "Bold"
            }

            // a0-2
            QTQ.Item {}

            // a0-3
            QTQ.Item {}

            // a1-1
            QTQ_C.Switch {
              text: 'display source'

              property alias _cfg: _Root._currentSlotCfg
              on_CfgChanged: checked = _cfg.displayCurrentSource
              onClicked: _plasmacfgAdapter.propagateCfgChange_preprocess(() => { _cfg.displayCurrentSource = checked; });
            }

            // a1-2
            QTQ_L.RowLayout {

              QTQ_C.SpinBox {
                stepSize: 1
                to: QTQ.Screen.height

                property alias _cfg: _Root._currentSlotCfg
                on_CfgChanged: value = _cfg.paddingTop
                onValueModified: _plasmacfgAdapter.propagateCfgChange_preprocess(() => { _cfg.paddingTop = value; });
              }

              QTQ_C.Label {
                text: 'px padding top'
              }
            }

            // a1-3
            QTQ.Item {}

            // a2-1
            QTQ_L.RowLayout {
              QTQ_L.Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 12

              QTQ_C.SpinBox {
                stepSize: 1
                to: QTQ.Screen.width

                property alias _cfg: _Root._currentSlotCfg
                on_CfgChanged: value = _cfg.paddingLeft
                onValueModified: _plasmacfgAdapter.propagateCfgChange_preprocess(() => { _cfg.paddingLeft = value; });
              }

              QTQ_C.Label {
                text: 'left'
              }
            }

            // a2-2
            QTQ_L.RowLayout {
              QTQ_C.Button {
                QTQ_L.Layout.preferredHeight: _FontMetrics.height * 2.5
                QTQ_L.Layout.preferredWidth: QTQ_L.Layout.preferredHeight

                property string _color

                property alias _cfg: _Root._currentSlotCfg
                on_CfgChanged: _color = _cfg.background

                onClicked: {

                  _DlgSelectColor.selectedColor = _color;
/*MOD*/           _DlgSelectColor.options = 0;
                  _DlgSelectColor._OnAccepted = ($$selectedColor) => {
                    _color = $$selectedColor.toString();
                    _plasmacfgAdapter.propagateCfgChange_preprocess(() => { _cfg.background = _color; });
                  };

                  _DlgSelectColor.open();
                }

                QTQ.Rectangle {
                  width: parent.height * 0.6
                  height: width
                  anchors.centerIn: parent

                  color: parent._color
                }
              }

              QTQ_C.Label { text:  '[' + QTQ.Screen.width + 'x' + QTQ.Screen.height + ']' }
            }

            // a2-3
            QTQ_L.RowLayout {

              QTQ_C.SpinBox {
                stepSize: 1
                to: QTQ.Screen.width

                property alias _cfg: _Root._currentSlotCfg
                on_CfgChanged: value = _cfg.paddingRight
                onValueModified: _plasmacfgAdapter.propagateCfgChange_preprocess(() => { _cfg.paddingRight = value; });
              }

              QTQ_C.Label { text: 'right' }
            }

            // a3-1
            QTQ.Item { QTQ_L.Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 12 }

            // a3-2
            QTQ_L.RowLayout {

              QTQ_C.SpinBox {
                stepSize: 1
                to: QTQ.Screen.height

                property alias _cfg: _Root._currentSlotCfg
                on_CfgChanged: value = _cfg.paddingBottom
                onValueModified: _plasmacfgAdapter.propagateCfgChange_preprocess(() => { _cfg.paddingBottom = value; });
              }

              QTQ_C.Label { text: 'bottom' }
            }

            // a3-3
            QTQ.Item {}
          }
          // - - - - - - - - - -  B A C K G R O U N D
          // - - - - - - - - - -  B A C K G R O U N D
          // - - - - - - - - - -  B A C K G R O U N D

          SUBPARTS.HorizontalDivider {}

          // I M A G E  - - - - - - - - - -
          // I M A G E  - - - - - - - - - -
          // I M A G E  - - - - - - - - - -
          QTQ_L.GridLayout {
            columns: 3

            // b1-1
            QTQ_C.Label {
              QTQ_L.Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 10

              text: 'Image'
              font.styleName: "Bold"
            }

            // b1-2
            QTQ_L.RowLayout {

              QTQ_C.Label { text: 'interval' }

              QTQ_C.SpinBox { id: _Interval

                stepSize: 1
                to: LJS.KDE_IMAGEBACKEND_SLIDETIMER_MAXVALUE

                property alias _cfg: _Root._currentSlotCfg
                on_CfgChanged: value = _cfg.interval
                onValueModified: _plasmacfgAdapter.propagateCfgChange_preprocess(() => { _cfg.interval = value; });
              }

              QTQ_C.Label {
                QTQ_L.Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 8
                text: _Interval.value===0?(LJS.IS_USE_URL(_ImageSources._cfg.imagesources)?'infinite':'1 week'):(_Interval.value===1?'second':'seconds')
                font.italic: _Interval.value===0
              }
            }

            // b1-3
            QTQ_L.RowLayout {

              QTQ_C.Label { text: 'fill mode' }

              QTQ_C.ComboBox {
                currentIndex: 0
                textRole: 'text'

                property alias _cfg: _Root._currentSlotCfg
                on_CfgChanged: currentIndex = ensureIndexOfValue(model, _cfg.fillMode)
                onActivated: ($$index) => _plasmacfgAdapter.propagateCfgChange_preprocess(() => { _cfg.fillMode = model[$$index].value; })

                model:
                  [
                    { 'text': 'Stretch',            'value': QTQ.Image.Stretch },
                    { 'text': 'Fit',                'value': QTQ.Image.PreserveAspectFit },
                    { 'text': 'Crop',               'value': QTQ.Image.PreserveAspectCrop },
                    { 'text': 'Tile',               'value': QTQ.Image.Tile },
                    { 'text': 'Tile vertically',    'value': QTQ.Image.TileVertically },
                    { 'text': 'Tile horizontally',  'value': QTQ.Image.TileHorizontally },
                    { 'text': 'As is',              'value': QTQ.Image.Pad }
                  ]
              }
            }

            // b2-1
            QTQ.Item { QTQ_L.Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 10 }

            // b2-2, b2-3
            QTQ_L.RowLayout {
              QTQ_L.Layout.columnSpan: 2

              QTQ_C.SpinBox {
                stepSize: 1
                to: 200

                property alias _cfg: _Root._currentSlotCfg
                on_CfgChanged: value = _cfg.saturatePct
                onValueModified: _plasmacfgAdapter.propagateCfgChange_preprocess(() => { _cfg.saturatePct = value; });
              }
              QTQ_C.Label {
                text: '% saturate '
              }

              QTQ_C.ToolSeparator {}

              QTQ_C.SpinBox {
                stepSize: 1
                to: 100

                property alias _cfg: _Root._currentSlotCfg
                on_CfgChanged: value = _cfg.blurPct
                onValueModified: _plasmacfgAdapter.propagateCfgChange_preprocess(() => { _cfg.blurPct = value; });
              }
              QTQ_C.Label {
                text: '% blur '
              }

              QTQ_C.ToolSeparator {}

              QTQ_C.SpinBox {
                stepSize: 1
                to: 100

                property alias _cfg: _Root._currentSlotCfg
                on_CfgChanged: value = _cfg.colorizePct
                onValueModified: _plasmacfgAdapter.propagateCfgChange_preprocess(() => { _cfg.colorizePct = value; });
              }

              QTQ_C.Label { text: '% colorize' }

              QTQ_C.Button {

                property string _color

                property alias _cfg: _Root._currentSlotCfg
                on_CfgChanged: _color = _cfg.colorizeColor

                onClicked: {

                  _DlgSelectColor.selectedColor = _color;
                  _DlgSelectColor.options = 0;
                  _DlgSelectColor._OnAccepted = ($$selectedColor) => {
                    _color = $$selectedColor.toString();
                    _plasmacfgAdapter.propagateCfgChange_preprocess(() => { _cfg.colorizeColor = _color; });
                  };
                  _DlgSelectColor.open();
                }

                QTQ.Rectangle {
                  anchors.centerIn: parent
                  width: 20
                  height: 20

                  color: parent._color
                }
              }
            }
          }

          // - - - - - - - - - -  I M A G E
          // - - - - - - - - - -  I M A G E
          // - - - - - - - - - -  I M A G E

          SUBPARTS.HorizontalDivider {}

          // S O U R C E S  - - - - - - - - - -
          // S O U R C E S  - - - - - - - - - -
          // S O U R C E S  - - - - - - - - - -
          QTQ_L.GridLayout {
            columns: 3

            // c1-1
            QTQ_C.Label {
              QTQ_L.Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 10

              text: 'Sources'
              font.styleName: "Bold"
            }

            // c1-2, c1-3
            QTQ_L.RowLayout {
              QTQ_L.Layout.columnSpan: 2

              QTQ_C.Button { id: _BtnAddTimeslotFolder
                icon.name: "list-add"
                text: 'Folder'

                onClicked: _DlgAddFolder.open()
              }

              QTQ_C.Label { text: 'shuffle' }

              QTQ_C.ComboBox { id: _ComboShuffleMode
                currentIndex: 0
                textRole: 'text'

                property alias _cfg: _Root._currentSlotCfg
                on_CfgChanged: currentIndex = ensureIndexOfValue(model, _cfg.shuffleMode)
                onActivated: ($$index) => _plasmacfgAdapter.propagateCfgChange_preprocess(() => { _cfg.shuffleMode = model[$$index].value; })

                model:
                  [
                    { 'text': 'Random',       'value': KDE_wallpapersImage.SortingMode.Random },
                    { 'text': 'A to Z',       'value': KDE_wallpapersImage.SortingMode.Alphabetical },
                    { 'text': 'Z to A',       'value': KDE_wallpapersImage.SortingMode.AlphabeticalReversed },
                    { 'text': 'Newest first', 'value': KDE_wallpapersImage.SortingMode.ModifiedReversed },
                    { 'text': 'Oldest first', 'value': KDE_wallpapersImage.SortingMode.Modified }
                  ]
              }

              QTQ_C.ToolSeparator {}

              QTQ_C.Button { id: _BtnSetUrl
                icon.name: "internet-web-browser-symbolic"
                text: 'Use URL'

                onClicked: _DlgSetUrl.open()
              }
            }
          }

          // - - - - - - - - - -   S O U R C E S
          // - - - - - - - - - -   S O U R C E S
          // - - - - - - - - - -   S O U R C E S

          QTQ.ListView { id: _ImageSources
            QTQ_L.Layout.fillWidth: true
            QTQ_L.Layout.fillHeight: true
            QTQ_L.Layout.minimumHeight: _FontMetrics.height * 2.5
            clip: true
            QTQ_C.ScrollBar.vertical: QTQ_C.ScrollBar { policy: QTQ_C.ScrollBar.AlwaysOn } // ?!?? no effect from 'policy: QTQ_C.ScrollBar.AlwaysOn'

            property alias _cfg: _Root._currentSlotCfg
            on_CfgChanged: {

              _ModelImagesources.clear();
              for(let $$source of _cfg.imagesources)
              {
                _ModelImagesources.append({path: $$source});
              }

              updateButtonsState();
            }

            QTQ.Rectangle { // listview background
              z: -1
              anchors.fill: parent
              color: _ActiveSystemPalette.light
            }

            model: QTQ.ListModel { id: _ModelImagesources }

            delegate: QTQ_L.RowLayout {

              QTQ_C.Button {
                icon.name: "edit-delete-remove"

                onClicked: _ImageSources.removeSource(index)
              }

              QTQ.Text {
                QTQ_L.Layout.fillWidth: true
                text: model.path
              }
            }

            function addSource($path) {

              _ModelImagesources.append({ path: $path });
              syncSourcesToConfig();
            }

            function removeSource($index) {

              _ModelImagesources.remove($index);
              syncSourcesToConfig();
            }

            function syncSourcesToConfig() {

              _plasmacfgAdapter.propagateCfgChange_preprocess(() => {

                const sources = [];
                for (let i = 0; i < _ModelImagesources.count; ++i) { sources.push(_ModelImagesources.get(i).path); }
                _currentSlotCfg.imagesources = sources;

                _ImageSources.updateButtonsState();
              });
            }

            function updateButtonsState() {

              _BtnAddTimeslotFolder.enabled = !LJS.IS_USE_URL(_currentSlotCfg.imagesources);
              _ComboShuffleMode.enabled = _BtnAddTimeslotFolder.enabled;
              _BtnSetUrl.enabled = _ModelImagesources.count === 0;
            }
          }
        }
      }
    }

    QTQ.Loader { id: _LOGOVERLAY
      source: _enableLogger?"subparts/LogOverlay.qml":""

      anchors.fill: parent
      enabled: false // let clicks through
    }

    /* right padding */ QTQ.Item { width: _FontMetrics.averageCharacterWidth }
  }

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  QTQ_D.FolderDialog { id: _DlgAddFolder
    title: "Choose a folder"

    onAccepted: {
      const targetFolder = selectedFolder.toString() || currentFolder.toString();
      const desanitized = decodeURI(targetFolder);
      _ImageSources.addSource(desanitized.substring("file://".length));
    }
  }

  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  QTQ_C.Dialog { id: _DlgSetUrl

    width: _Root.width * 0.6

    title: 'Enter URL'
    standardButtons: QTQ_C.Dialog.Ok | QTQ_C.Dialog.Cancel

    onAccepted: _ImageSources.addSource(_TfUrl.validUrl())

    contentItem: QTQ_L.ColumnLayout {

      QTQ.Rectangle {

        QTQ_L.Layout.alignment: Qt.AlignHCenter
        QTQ_L.Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 10
        QTQ_L.Layout.preferredHeight: QTQ_L.Layout.preferredWidth

        color: (_ImgUrl.status === QTQ.Image.Ready)?"transparent":_ActiveSystemPalette.mid

        QTQ.Image { id: _ImgUrl
          autoTransform: true

          anchors.fill: parent
          fillMode: QTQ.Image.PreserveAspectFit

          source: _TfUrl.validUrl()
        }
      }

      QTQ_C.TextField { id: _TfUrl
        focus: _DlgSetUrl.visible
        QTQ_L.Layout.fillWidth: true
        placeholderText: "https://... | file://..."

        function validUrl() {

          if(!text) { return text; }
          //<--


          return text.startsWith("http://") || text.startsWith("https://") || text.startsWith("file://")?text:"file://"+text;
        }
      }
    }
  }

  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  QTQ_D.ColorDialog { id: _DlgSelectColor

    title: "Select color"
    modality: Qt.WindowModal

    property var _OnAccepted
    onAccepted: _OnAccepted(selectedColor)
  }

  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  QTQ_C.Dialog { id: _DlgAddDesktopConfig
    width: _Root.width * 0.6

    title: '"For desktop" add'
    standardButtons: QTQ_C.Dialog.Ok | QTQ_C.Dialog.Cancel

    onAccepted: {

      const element = _ComboDesktopConfigAdd.model[_ComboDesktopConfigAdd.currentIndex];
      const currentDesktopConfigDeskNo = _ModelSelectDesktop.get(_SelectDesktop.currentIndex).deskNo;

      _plasmacfgAdapter.newCfgForDeskNo_cloneDeskNo(element.deskNo, currentDesktopConfigDeskNo);
      _SelectDesktop.insertElement(element);
    }

    onVisibleChanged: {

      if(!visible) { return; }
      //<--


      _ComboDesktopConfigAdd.buildModel();
    }

    QTQ_C.ComboBox { id: _ComboDesktopConfigAdd
      width: parent.width
      textRole: 'displayText'

      function buildModel() {

        const existingDeskNos = [];
        for (let i = 0; i < _ModelSelectDesktop.count; ++i)
        {
          existingDeskNos.push(_ModelSelectDesktop.get(i).deskNo);
        }

        const available = [];
        for (let deskNo = 0; deskNo < _VirtualDesktopInfo.numberOfDesktops + 1; ++deskNo)
        {
          if (existingDeskNos.includes(deskNo)) { continue; }
          //<--


          available.push(buildSelectDesktopElement(deskNo));
        }

        model = available;
      }
    }
  }

  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  QTQ_C.Dialog { id: _DlgCreateTimeslot

    title: '"Activated at" add'
    standardButtons: QTQ_C.Dialog.Ok | QTQ_C.Dialog.Cancel
    readonly property var _okButton: standardButton(QTQ_C.Dialog.Ok)

    property var _slotsToExclude: []
    property string _newSlot

    onAccepted: {
      const currentSlotmarker = _ModelSelectSlot.get(_SelectSlot.currentIndex).slotmarker;
      _SelectSlot.addTimeslotFromDialog(_newSlot, currentSlotmarker);
    }

    QTQ.Component.onCompleted: initModels()

    onVisibleChanged: {

      if(!visible) { return; }
      // <--


      _DlgCreateTimeslot._slotsToExclude = Object.keys(_currentDeskCfg.timeslots);

      buildNewSlot();
    }

    QTQ_L.RowLayout {

      QTQ_C.ComboBox { id: _ComboHour
        model: QTQ.ListModel { id: _ModelComboHour }
        textRole: 'text'

        onCurrentIndexChanged: _DlgCreateTimeslot.buildNewSlot();
      }

      QTQ_C.Label {
        text: ':'
      }

      QTQ_C.ComboBox { id: _ComboMinute
        model: QTQ.ListModel { id: _ModelComboMinute }
        textRole: 'text'

        onCurrentIndexChanged: _DlgCreateTimeslot.buildNewSlot();
      }
    }

    function initModels() {

      const mh = _ComboHour.model;
      for(let i = 0; i < 24; ++i)
      {
        const text = ('00'+i).slice(-2);
        mh.append({'text': text});
      }
      _ComboHour.currentIndex = 0;

      const mm = _ComboMinute.model;
      for(let i = 0; i < 60; ++i)
      {
        let text = ('00'+i).slice(-2);
        mm.append({'text': text});
      }
      _ComboMinute.currentIndex = 0;
    }

    function buildNewSlot() {

      if(_ComboHour.currentIndex < 0 || _ComboMinute.currentIndex < 0) { return; }
      //<--


      const hh = _ModelComboHour.get(_ComboHour.currentIndex).text;
      const mm = _ModelComboMinute.get(_ComboMinute.currentIndex).text;

      _newSlot = hh + ':' + mm;
      _okButton.enabled = !_slotsToExclude.includes(_newSlot);
    }
  }
}
