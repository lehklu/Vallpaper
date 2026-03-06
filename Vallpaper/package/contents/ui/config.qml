/*
 *  Copyright 2026  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick as QTQ
import QtQuick.Controls as QTQ_C
import QtQuick.Layouts as QTQ_L
import QtQuick.Dialogs as QTQ_D

/* 6.5 */ import org.kde.plasma.private.pager as KDE_pager /**/
/* 6.6 * import plasma.applet.org.kde.plasma.pager as KDE_pager /**/

import org.kde.plasma.wallpapers.image as KDE_wallpaper


import "../js/v.js" as VJS

QTQ_L.ColumnLayout { id: _Root

  property var title // for KDE Settings page

/*MOD*/property var cfg_vallpaper6

  property var plasmacfgAdapter

  property var currentDeskCfg
  property var currentSlotCfg

  QTQ.FontMetrics { id: _FontMetrics
  }

  QTQ.SystemPalette { id: _ActiveSystemPalette
    colorGroup: QTQ.SystemPalette.Active
  }

  QTQ.Component.onCompleted: {

/*MOD*/plasmacfgAdapter = new VJS.PlasmacfgAdapter(cfg_vallpaper6, $newCfg => { cfg_vallpaper6 = $newCfg; });
    selectDesktop__init(_Pager.currentPage);
  }

	 KDE_pager.PagerModel { id: _Pager
    enabled: _Root.visible
    pagerType: KDE_pager.PagerModel.VirtualDesktops
	}

  QTQ_L.RowLayout { // Container

    QTQ.Item { // left padding
      width: _FontMetrics.averageCharacterWidth
    }

    QTQ_L.ColumnLayout { // content
      QTQ_L.Layout.fillWidth: true

      QTQ.Item { // top padding
        height: _FontMetrics.height
      }

      // S E L E C T   D E S K T O P - - - - - - - - - -
      // S E L E C T   D E S K T O P - - - - - - - - - -
      // S E L E C T   D E S K T O P - - - - - - - - - -
      QTQ_L.RowLayout {

        QTQ_C.Label {
          text: "For desktop"
        }

        QTQ_C.ComboBox { id: _SelectDesktop

          QTQ_L.Layout.fillWidth: true
          model: QTQ.ListModel {}
          textRole: 'displayText'

		      QTQ.Connections { id: _SelectDesktopConnections

            function onCurrentIndexChanged() { selectDesktop__handleCurrentIndexChanged(); }
            function onCountChanged() { selectDesktop__updateButtonsState();}
		      }
        }

        QTQ_C.Button { id: _BtnAddTimeslotDesktopConfig
          icon.name: "list-add"

          onClicked: _DlgAddConfig.open()
        }

        QTQ_C.Button { id: _BtnRemoveDesktopConfig
          icon.name: "edit-delete-remove"

          onClicked: selectDesktop__removeConfig()
        }
      }
      // - - - - - - - - - - S E L E C T   D E S K T O P
      // - - - - - - - - - - S E L E C T   D E S K T O P
      // - - - - - - - - - - S E L E C T   D E S K T O P

      // S E L E C T   S L O T   - - - - - - - - - -
      // S E L E C T   S L O T   - - - - - - - - - -
      // S E L E C T   S L O T   - - - - - - - - - -
      QTQ_L.RowLayout {

        QTQ.Item {
          QTQ_L.Layout.fillWidth: true
        }

        QTQ_C.Label {
		      text: "Activated at"
        }

        QTQ_C.ComboBox { id: _SelectSlot
          model: QTQ.ListModel{}

          QTQ.Connections { id: _SelectSlotConnections

            function onCurrentIndexChanged() { selectSlot__handleCurrentIndexChanged(); }
            function onCountChanged() { selectSlot__updateButtonsState();}
		      }

  				property alias desktopConfig: _Root.currentDeskCfg
				  onDesktopConfigChanged: selectSlot__init()
        }

		    QTQ_C.Button { id: _BtnAddTimeslotTimeslot
          icon.name: "list-add"

          onClicked: _DlgAddTimeslot.open()
		    }

		    QTQ_C.Button { id: _BtnRemoveTimeslot
          icon.name: "edit-delete-remove"

          onClicked: selectSlot__removeTimeslot()
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
            }

            // a0-2
            QTQ.Item {}

            // a0-3
            QTQ.Item {}

            // a1-1
            QTQ_C.Switch {
              text: 'display source'

              property alias myCfg: _Root.currentSlotCfg
              onMyCfgChanged: checked = myCfg.displayCurrentSource
              onClicked: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
        	      myCfg.displayCurrentSource = checked?1:0;
              });
            }

            // a1-2
		        QTQ_L.RowLayout {

              property var myHeight: Screen.height
              property var myWidth: Screen.width

			        QTQ_C.SpinBox {
                stepSize: 1
                to: parent.myHeight

                property alias myCfg: _Root.currentSlotCfg
                onMyCfgChanged: value = myCfg.paddingTop

                onValueChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
          	      myCfg.paddingTop = value;
                });
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

              property var myHeight: Screen.height
              property var myWidth: Screen.width

			        QTQ_C.SpinBox {
                stepSize: 1
                to: parent.myWidth

                property alias myCfg: _Root.currentSlotCfg
                onMyCfgChanged: value = myCfg.paddingLeft

                onValueChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
          	      myCfg.paddingLeft = value;
                });
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

                property alias myCfg: _Root.currentSlotCfg
                onMyCfgChanged: myColor = myCfg.background

                property string myColor
                onMyColorChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
        	        myCfg.background = myColor;
                });

                onClicked: {

	                _DlgSelectColor.selectedColor = myColor;
/*MOD*/           _DlgSelectColor.options = 0;
	                _DlgSelectColor.handleOnAccepted = ($$selectedColor) => {
  	                myColor = $$selectedColor.toString();
	                };

	                _DlgSelectColor.open();
                }

  				      QTQ.Rectangle {
                  width: parent.height * 0.6
                  height: width
                  anchors.centerIn: parent

                  color: parent.myColor
	  		        }
              }

              QTQ_C.Label {
				        text:  '[' + Screen.width + 'x' + Screen.height + ']'
			        }
            }

            // a2-3
		        QTQ_L.RowLayout {

              property var myHeight: Screen.height
              property var myWidth: Screen.width

			        QTQ_C.SpinBox {
                stepSize: 1
                to: parent.myWidth

                property alias myCfg: _Root.currentSlotCfg
                onMyCfgChanged: value = myCfg.paddingRight

                onValueChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
          	      myCfg.paddingRight = value;
                });
			        }

			        QTQ_C.Label {
				        text: 'right'
			        }
  				  }

            // a3-1
            QTQ.Item {
              QTQ_L.Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 12
            }

            // a3-2
		        QTQ_L.RowLayout {

              property var myHeight: Screen.height
              property var myWidth: Screen.width

			        QTQ_C.SpinBox {
                stepSize: 1
                to: parent.myHeight

                property alias myCfg: _Root.currentSlotCfg
                onMyCfgChanged: value = myCfg.paddingBottom

                onValueChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
          	      myCfg.paddingBottom = value;
                });
			        }

			        QTQ_C.Label {
				        text: 'bottom'
			        }
  				  }

            // a3-3
            QTQ.Item {}
          }
          // - - - - - - - - - -  B A C K G R O U N D
          // - - - - - - - - - -  B A C K G R O U N D
          // - - - - - - - - - -  B A C K G R O U N D

        QTQ.Rectangle {
          QTQ_L.Layout.preferredWidth: parent.width
          QTQ_L.Layout.preferredHeight: _FontMetrics.height

          color: "transparent"

          QTQ.Rectangle {
            anchors.centerIn: parent
            width: parent.width * .95
            height: 1

            color: _ActiveSystemPalette.mid
          }
        }

        // I M A G E  - - - - - - - - - -
        // I M A G E  - - - - - - - - - -
        // I M A G E  - - - - - - - - - -
        QTQ_L.GridLayout {
          columns: 3

          // b1-1
          QTQ_C.Label {
            QTQ_L.Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 10

            text: 'Image'
          }

          // b1-2
    		  QTQ_L.RowLayout {

            QTQ_C.Label {
              text: 'interval'
			      }

            QTQ_C.SpinBox { id: _Interval

              stepSize: 1
              to: VJS.PLASMA_SLIDETIMER_MAXVALUE

              property alias myCfg: _Root.currentSlotCfg
              onMyCfgChanged: value = myCfg.interval

              onValueChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
        	      myCfg.interval = value;
              });
			      }

			      QTQ_C.Label {
              QTQ_L.Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 8
  				    text: _Interval.value==0?'infinite':(_Interval.value==1?'second':'seconds')
              font.italic: _Interval.value==0
	  		    }
          }

          // b1-3
		      QTQ_L.RowLayout {

			      QTQ_C.Label {
				      text: 'fill mode'
			      }

			      QTQ_C.ComboBox {
				      currentIndex: 0
              textRole: 'text'

              property alias myCfg: _Root.currentSlotCfg
              onMyCfgChanged: currentIndex = indexFromFillMode(myCfg.fillMode)

              onCurrentIndexChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
        	      myCfg.fillMode = model[currentIndex].value;
              });

				      model:
        	      [
                  { 'text': 'Stretch',                           'value': Image.Stretch },
                  { 'text': 'Fit',                            'value': Image.PreserveAspectFit },
                  { 'text': 'Crop',   'value': Image.PreserveAspectCrop },
                  { 'text': 'Tile',                           'value': Image.Tile },
                  { 'text': 'Tile vertically',                'value': Image.TileVertically },
                  { 'text': 'Tile horizontally',              'value': Image.TileHorizontally },
                  { 'text': 'As is',                          'value': Image.Pad }
                ]

              function indexFromFillMode($mode) {

          	    let idx;

					      for(idx in model)
                {
          	      if(model[idx].value===$mode)
          	      {
 							      break;
 							      //<--
          	      }
					      }

        	      return idx;
              }
			      }
		      }

          // b2-1
          QTQ.Item {
            QTQ_L.Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 10
          }

          // b2-2, b2-3
          QTQ_L.RowLayout {
            QTQ_L.Layout.columnSpan: 2

            QTQ_C.SpinBox {
              stepSize: 1
              to: 100

              property alias myCfg: _Root.currentSlotCfg
              onMyCfgChanged: value = 100 - myCfg.desaturate * 100

              onValueChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
          	    myCfg.desaturate = 1 - value/100;
              });
			      }
            QTQ_C.Label {
					    text: '% saturate '
				    }
            QTQ.Canvas {
              width: _FontMetrics.averageCharacterWidth *1/ 3
              anchors.top: parent.top
              anchors.bottom: parent.bottom
              onPaint: {
                var ctx = getContext("2d");
                ctx.lineWidth = width;
                ctx.setLineDash([1, 1]);
                ctx.strokeStyle = _ActiveSystemPalette.dark

                ctx.moveTo(0, 0)
                ctx.lineTo(0, height)

                ctx.stroke()
              }
            }


            QTQ_C.SpinBox {
              stepSize: 1
              to: 100

              property alias myCfg: _Root.currentSlotCfg
              onMyCfgChanged: value = myCfg.blur * 100

              onValueChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
          	    myCfg.blur = value/100;
              });
			      }
            QTQ_C.Label {
		  			  text: '% blur '
				    }
            QTQ.Canvas {
              width: _FontMetrics.averageCharacterWidth *1/ 3
              anchors.top: parent.top
              anchors.bottom: parent.bottom
              onPaint: {
                var ctx = getContext("2d");
                ctx.lineWidth = width;
                ctx.setLineDash([1, 1]);
                ctx.strokeStyle = _ActiveSystemPalette.dark

                ctx.moveTo(0, 0)
                ctx.lineTo(0, height)

                ctx.stroke()
              }
            }

            QTQ_C.SpinBox {
              stepSize: 1
              to: 100

              property alias myCfg: _Root.currentSlotCfg
              onMyCfgChanged: value = myCfg.colorize * 100

              onValueChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
          	    myCfg.colorize = value / 100;
                effects__updateColorizeValue(myCfg);
              });
			      }
            QTQ_C.Label {
					    text: '% colorize'
				    }
			      QTQ_C.Button {

              property alias myCfg: _Root.currentSlotCfg
              onMyCfgChanged: myColor = myCfg.colorizeColor

              property string myColor
              onMyColorChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
        	      myCfg.colorizeColor = myColor;
                effects__updateColorizeValue(myCfg);
              });

              onClicked: {

	              _DlgSelectColor.selectedColor = myColor;
                _DlgSelectColor.options = 0;
	              _DlgSelectColor.handleOnAccepted = ($$selectedColor) => {
	                myColor = $$selectedColor.toString();
	              };

	              _DlgSelectColor.open();
              }

  				    QTQ.Rectangle {
                anchors.centerIn: parent
                width: 20
                height: 20

                color: parent.myColor
  				    }
			      }
		      }
        }

        // - - - - - - - - - -  I M A G E
        // - - - - - - - - - -  I M A G E
        // - - - - - - - - - -  I M A G E

        QTQ.Rectangle {
          QTQ_L.Layout.preferredWidth: parent.width
          QTQ_L.Layout.preferredHeight: _FontMetrics.height

          color: "transparent"

          QTQ.Rectangle {
            anchors.centerIn: parent
            width: parent.width * .95
            height: 1

            color: _ActiveSystemPalette.mid
          }
        }

        // S O U R C E S  - - - - - - - - - -
        // S O U R C E S  - - - - - - - - - -
        // S O U R C E S  - - - - - - - - - -
        QTQ_L.GridLayout {
          columns: 3

          // c1-1
			    QTQ_C.Label {
            QTQ_L.Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 10

            text: 'Sources'
			    }

          // c1-2, c1-3
    		  QTQ_L.RowLayout {
            QTQ_L.Layout.columnSpan: 2

				    QTQ_C.Button { id: _BtnAddTimeslotFolder
              icon.name: "list-add"
					    text: 'Folder'

              onClicked: imagesources__addPathUsingDlg(_DlgAddFolder);
				    }

            QTQ_C.Label {
					    text: 'shuffle'
				    }

			      QTQ_C.ComboBox { id: _ComboShuffleMode
				      currentIndex: 0
              textRole: 'text'

              property alias myCfg: _Root.currentSlotCfg
              onMyCfgChanged: currentIndex = indexFromShuffleMode(myCfg.shuffleMode)

              onCurrentIndexChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
        	      myCfg.shuffleMode = model[currentIndex].value;
              });

				      model:
        	      [
                  { 'text': 'Random',       'value': KDE_wallpaper.SortingMode.Random },
                  { 'text': 'A to Z',       'value': KDE_wallpaper.SortingMode.Alphabetical },
                  { 'text': 'Z to A',       'value': KDE_wallpaper.SortingMode.AlphabeticalReversed },
                  { 'text': 'Newest first', 'value': KDE_wallpaper.SortingMode.ModifiedReversed },
                  { 'text': 'Oldest first', 'value': KDE_wallpaper.SortingMode.Modified }
                ]

              function indexFromShuffleMode($mode) {

          	    let idx;

					      for(idx in model)
                {
          	      if(model[idx].value===$mode)
          	      {
 							      break;
 							      //<--
          	      }
					      }

        	      return idx || 0;
              }
			      }

            QTQ.Canvas {
              width: _FontMetrics.averageCharacterWidth *1/ 3
              anchors.top: parent.top
              anchors.bottom: parent.bottom
              onPaint: {
                var ctx = getContext("2d");
                ctx.lineWidth = width;
                ctx.setLineDash([1, 1]);
                ctx.strokeStyle = _ActiveSystemPalette.dark

                ctx.moveTo(0, 0)
                ctx.lineTo(0, height)

                ctx.stroke()
              }
            }

				    QTQ_C.Button { id: _BtnSetUrl
              icon.name: "internet-web-browser-symbolic"
					   text: 'Use url'

              onClicked: imagesources__setUrl();
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
          clip: true // !!!!!! aarrgh
          QTQ_C.ScrollBar.vertical: QTQ_C.ScrollBar { policy: QTQ_C.ScrollBar.AlwaysOn } // ?!?? no effect from 'policy: QTQ_C.ScrollBar.AlwaysOn'

          property alias myCfg: _Root.currentSlotCfg
          onMyCfgChanged: {

            inceptSources(myCfg.imagesources)

            imagesources__updateButtonsState();
          }

          QTQ.Rectangle {
            z: -1
            anchors.fill: parent
            color: _ActiveSystemPalette.light
          }

          model: QTQ.ListModel {

            onCountChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {

              _ImageSources.extractSourcesToModel();

              imagesources__updateButtonsState();
            })
          }

		      function extractSourcesToModel() {

            const sources = [];

            for(let i = 0; i < model.count; ++i)
            {
              sources.push(model.get(i).path);
            }

            myCfg.imagesources = sources;
		      }

					function inceptSources($sources) {

            model.clear();

            for(let $$source of $sources)
						{
              model.append({path: $$source});
            }
		      }

          delegate: QTQ_L.RowLayout {

            QTQ_C.Button {
              icon.name: "edit-delete-remove"

              onClicked: imagesources__removeSource(model.index);
            }

						QTQ.Text {
              QTQ_L.Layout.fillWidth: true
              text: model.path
						}
					}
				}
      }
    }

/* Dev *
QTQ.Rectangle { id: _LogBackground
  color: '#00ff0000'
  QTQ_L.Layout.fillWidth: true
  height: 300

  ScrollView {
    anchors.fill: parent
    background: QTQ.Rectangle {
                  color: '#0000ff00'
    }

    TextArea { id: _Log
      background: QTQ.Rectangle {
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
/* /Dev */

    }

    QTQ.Item { // right padding
      width: _FontMetrics.averageCharacterWidth
    }
  }

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
QTQ_D.FolderDialog { id: _DlgAddFolder
		title: "Choose a folder"

	  property var handleOnAccepted
  	onAccepted: handleOnAccepted([currentFolder])
	}

QTQ_C.Dialog { id: _DlgSetUrl

	width: parent.width * 0.6

	title: 'Use Url'
  standardButtons: QTQ_C.Dialog.Ok | QTQ_C.Dialog.Cancel

  property var handleOnAccepted
  onAccepted: handleOnAccepted(_TfUrl.text);

	QTQ_C.TextField { id: _TfUrl
		focus: _DlgSetUrl.visible

		anchors.fill: parent
	}
}

QTQ_D.ColorDialog { id: _DlgSelectColor

  title: "Select color"
  modality: Qt.WindowModal

  property var handleOnAccepted
  onAccepted: handleOnAccepted(selectedColor)
}


QTQ_C.Dialog { id: _DlgAddTimeslot

	title: 'Add Settings activated at'
  standardButtons: QTQ_C.Dialog.Cancel

  property var excludeSlots: []
  property string newSlot

  onAccepted: {

    const element = {"slotmarker": newSlot};

		plasmacfgAdapter.atCfg_newTimeslotForMarker_cloneMarker(currentDeskCfg, element.slotmarker, _SelectSlot.model.get(_SelectSlot.currentIndex).slotmarker);

    selectSlot__insertSlot(element);
	}

  QTQ.Component.onCompleted: initModels();

  onVisibleChanged: {

  	if(!visible)
  		return;
  		// <--


	  let slots = [];
	  for(let i = 0; i < _SelectSlot.model.count; ++i)
	  {
		  slots.push( _SelectSlot.model.get(i).slotmarker);
	  }
	  _DlgAddTimeslot.excludeSlots = slots;

		buildNewSlot();
		}

	QTQ_L.RowLayout {

		QTQ_C.ComboBox { id: _ComboHour
      model: QTQ.ListModel {}
      textRole: 'text'

			onCurrentIndexChanged: _DlgAddTimeslot.buildNewSlot();
		}

		QTQ_C.Label {
    	text: ':'
		}

		QTQ_C.ComboBox { id: _ComboMinute
      model: QTQ.ListModel {}
      textRole: 'text'

			onCurrentIndexChanged: _DlgAddTimeslot.buildNewSlot();
		}

		QTQ_C.Button { id: _BtnAddTimeslot
  		text: 'Add'

  		onClicked: _DlgAddTimeslot.accept()
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

  	if(_ComboHour.currentIndex < 0 || _ComboMinute.currentIndex < 0)
  		return;
  		//<--


  	const hh = _ComboHour.model.get(_ComboHour.currentIndex).text;
  	const mm = _ComboMinute.model.get(_ComboMinute.currentIndex).text;

  	newSlot = hh + ':' + mm;
  	_BtnAddTimeslot.enabled = !excludeSlots.includes(newSlot);
  }
}



QTQ_C.Dialog { id: _DlgAddConfig
  width: parent.width * 0.6

	title: 'Add Settings for'
  standardButtons: QTQ_C.Dialog.Ok | QTQ_C.Dialog.Cancel

  onAccepted: {

    const element = _ComboAddConfig.model[_ComboAddConfig.currentIndex];
    const currentDesktopConfigDeskNo = _SelectDesktop.model.get(_SelectDesktop.currentIndex).deskNo;

    plasmacfgAdapter.newCfgForDeskNo_cloneDeskNo(element.deskNo, currentDesktopConfigDeskNo);

    selectDesktop__insertElement(element);
	}

  onVisibleChanged: {

  	if(!visible) { return; }
    // <--


	  const existingDeskNos = [];
	  for(let i = 0; i < _SelectDesktop.model.count; ++i)
	  {
		  existingDeskNos.push(_SelectDesktop.model.get(i).deskNo);
	  }

		const myModel = [];
		for(let i=0; i<_Pager.count+1; ++i)
    {
      const deskNo = i;
      if(existingDeskNos.includes(deskNo)) { continue; }
      //<--


      myModel.push(selectDesktop__buildElement(deskNo));
		}

  	_ComboAddConfig.model = myModel;
	}

	QTQ_C.ComboBox { id: _ComboAddConfig
		width: parent.width
    textRole: 'displayText'
	}
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////////////

function selectSlot__init() {

	const memConnTarget = _SelectSlotConnections.target;
	_SelectSlotConnections.target = null;

	_SelectSlot.model.clear();
	const nowTimeslotCfg = currentDeskCfg.findAppropiateSlotCfgFor_now();
	const orderedTimeslotCfgs = currentDeskCfg.getOrderedTimeslots();

	let activateIdx = 0;
	for(let $$i in orderedTimeslotCfgs)
	{
		const timeslotCfg = orderedTimeslotCfgs[$$i];

		selectSlot__insertSlot({"slotmarker": timeslotCfg.slotmarker});

    if(timeslotCfg===nowTimeslotCfg)
    {
      activateIdx = $$i;
    }
	}

	_SelectSlotConnections.target = memConnTarget;


	// activate
	if(_SelectSlot.currentIndex == activateIdx)
	{
		selectSlot__handleCurrentIndexChanged();
	}
	else
	{
		_SelectSlot.currentIndex = activateIdx;
	}


}

function selectSlot__insertSlot($slot) {

  const model = _SelectSlot.model;

	let idx = 0;
	while(idx < model.count && $slot > model.get(idx))
	{
		++idx;
	}

	if(model.count===0)
	{
		model.append($slot);
	}
	else
	{
		model.insert(idx, $slot);
	}

	_SelectSlot.currentIndex = idx;
}

function selectSlot__handleCurrentIndexChanged() {

	selectSlot__updateButtonsState();

	currentSlotCfg = currentDeskCfg.getTimeslotForSlotmarker(_SelectSlot.model.get(_SelectSlot.currentIndex).slotmarker);
}

function selectSlot__updateButtonsState() {

	_BtnAddTimeslotTimeslot.enabled = _SelectSlot.model.count < 60 * 24;

	_BtnRemoveTimeslot.enabled = _SelectSlot.currentIndex > 0;
}

function selectSlot__removeTimeslot() {

	plasmacfgAdapter.atCfg_deleteTimeslot(currentDeskCfg, _SelectSlot.model.get(_SelectSlot.currentIndex).slotmarker);

	_SelectSlot.model.remove(_SelectSlot.currentIndex);

	_SelectSlot.currentIndex = Math.max(0, _SelectSlot.currentIndex - 1);
}





function selectDesktop__removeConfig() {

	plasmacfgAdapter.deleteCfgDeskNo(_SelectDesktop.model.get(_SelectDesktop.currentIndex).deskNo);

	_SelectDesktop.model.remove(_SelectDesktop.currentIndex);

	_SelectDesktop.currentIndex = Math.min(_SelectDesktop.currentIndex, _SelectDesktop.model.count - 1);
}

function selectDesktop__updateButtonsState() {

	_BtnAddTimeslotDesktopConfig.enabled = _SelectDesktop.model.count < _Pager.count+1;

	_BtnRemoveDesktopConfig.enabled = _SelectDesktop.currentIndex > 0;
}


function selectDesktop__handleCurrentIndexChanged() {

	selectDesktop__updateButtonsState();

	currentDeskCfg = plasmacfgAdapter.getCfgForDeskNo(_SelectDesktop.model.get(_SelectDesktop.currentIndex).deskNo);
}

function selectDesktop__init($pageNo) {

  const currentConfigDeskNo = $pageNo+1;

	let activateNo = VJS.DESKNO_GLOBAL;

	// fill model
	const memConnTarget = _SelectDesktopConnections.target;
	_SelectDesktopConnections.target = null;

	for(const $$cfg of plasmacfgAdapter.getCfgs())
	{
		selectDesktop__insertElement(selectDesktop__buildElement($$cfg.deskNo));

		if($$cfg.deskNo === currentConfigDeskNo)
		{
			activateNo = $$cfg.deskNo;
		}
	}

	_SelectDesktopConnections.target = memConnTarget;


  // activate current
  const model = _SelectDesktop.model;

	let activateIndex = 0;
	for(let i = 0; i < model.count; ++i)
	{
		if(model.get(i).deskNo === activateNo)
		{
			activateIndex = i;
			break;
			// <--
		}
	}

	if(_SelectDesktop.currentIndex == activateIndex)
	{
		selectDesktop__handleCurrentIndexChanged();
	}
	else
	{
		_SelectDesktop.currentIndex = activateIndex;
	}
}

function selectDesktop__buildElement($deskNo) {

	const orderText = '#' + ('  '+$deskNo).slice(-3);

	return {
		'displayText': (VJS.DESKNO_GLOBAL===$deskNo?VJS.DESKNO_GLOBAL_NAME:_Pager.data(_Pager.index($deskNo-1, 0), 0)),
    'deskNo': $deskNo,
    'orderText': orderText
		}
}

function selectDesktop__insertElement($desktopElement) {

  const model = _SelectDesktop.model;

	let idx = 0;
	while(idx < model.count && $desktopElement.orderText > model.get(idx).orderText)
	{
		++idx;
	}

	if(model.count===0)
	{
		model.append($desktopElement);
	}
	else
	{
		model.insert(idx, $desktopElement);
	}

	_SelectDesktop.currentIndex = idx;
}

function effects__updateColorizeValue($slot) {

	let alpha = Math.round(255 * $slot.colorize);
	$slot.colorizeValue = '#' + ("00" + alpha.toString(16)).substr(-2) + $slot.colorizeColor.substr(-6);
}

function imagesources__updateButtonsState() {

	_BtnAddTimeslotFolder.enabled = ! VJS.IS_USE_URL(_ImageSources.myCfg.imagesources);
  _ComboShuffleMode.enabled = _BtnAddTimeslotFolder.enabled;

	_BtnSetUrl.enabled = ! _ImageSources.model.count > 0;
}

function imagesources__addPathUsingDlg($$dlg) {

	$$dlg.handleOnAccepted = ($$resultUrls) => {

		for(let i=0; i<$$resultUrls.length; ++i)
		{
			const desanitized = VJS.AS_URISAFE($$resultUrls[i].toString(), false);
			_ImageSources.model.append({ path: desanitized });
		}
	};


	$$dlg.open();
}

function imagesources__setUrl() {

	_DlgSetUrl.handleOnAccepted = ($$text) => {

		_ImageSources.model.append({ path: VJS.AS_URL($$text) });
	};

	_DlgSetUrl.open();
}

function imagesources__removeSource($index) {

	_ImageSources.model.remove($index);
}

}