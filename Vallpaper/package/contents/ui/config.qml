/*
 *  Copyright 2025  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.kcmutils
// import org.kde.plasma.plasmoid /*SED*/

import org.kde.plasma.private.pager

import "../js/v.js" as VJS
ColumnLayout { /*SED*/
	id: _Root

	property var cfg_vallpaper6 /*SED*/

  property var plasmacfgAdapter  

  property var currentDeskCfg  
  property var currentSlotCfg

  FontMetrics {
    id: _FontMetrics
  }

  SystemPalette {
    id: _ActiveSystemPalette
    colorGroup: SystemPalette.Active    
  }  

  Component.onCompleted: {

    plasmacfgAdapter = new VJS.PlasmacfgAdapter(cfg_vallpaper6, $newCfg => { cfg_vallpaper6 = $newCfg; }); /*SED*/
    selectDesktop__init(_Pager.currentPage);
  }

	PagerModel {
        id: _Pager

        enabled: _Root.visible
        pagerType: PagerModel.VirtualDesktops
	}

  ColumnLayout { // Container
    Layout.leftMargin: _FontMetrics.averageCharacterWidth
    Layout.rightMargin: _FontMetrics.averageCharacterWidth
    Layout.bottomMargin: _FontMetrics.averageCharacterWidth * 2

    // S E L E C T   D E S K T O P - - - - - - - - - -
    // S E L E C T   D E S K T O P - - - - - - - - - -
    // S E L E C T   D E S K T O P - - - - - - - - - -
    RowLayout { 

		      Label {
		        text: "For desktop"
          }

          ComboBox {
            id: _SelectDesktop
            Layout.fillWidth: true
            model: ListModel {}
            textRole: 'displayText'

		        Connections {
			        id: _SelectDesktopConnections

              function onCurrentIndexChanged() { selectDesktop__handleCurrentIndexChanged(); }
              function onCountChanged() { selectDesktop__updateButtonsState();}
		        }            
          }

          Button {
            id: btnAddDesktopConfig
            icon.name: "list-add"

            onClicked: _DlgAddConfig.open()
          }

          Button {
            id: btnRemoveDesktopConfig
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
    RowLayout {

        Item {
          Layout.fillWidth: true
        }

        Label {
		      text: "Activated at"
        }

        ComboBox {
          id: _SelectSlot                      
          model: ListModel{}

          Connections {
			      id: _SelectSlotConnections

            function onCurrentIndexChanged() { selectSlot__handleCurrentIndexChanged(); }
            function onCountChanged() { selectSlot__updateButtonsState();}
		      }                      

  				property alias desktopConfig: _Root.currentDeskCfg
				  onDesktopConfigChanged: selectSlot__init()
        }

		    Button {
          id: btnAddTimeslot
          icon.name: "list-add"                      

          onClicked: _DlgAddTimeslot.open()
		    }

		    Button {
          id: btnRemoveTimeslot
          icon.name: "edit-delete-remove"          

          onClicked: selectSlot__removeTimeslot()
  		  }              

    }
    // - - - - - - - - - -  S E L E C T   S L O T
    // - - - - - - - - - -  S E L E C T   S L O T
    // - - - - - - - - - -  S E L E C T   S L O T

    GroupBox {
	    Layout.fillWidth: true

	    Layout.fillHeight: true      
      
      background: Rectangle { // group box border
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        radius: 5
      }

      ColumnLayout {
		    anchors.fill: parent      

        // B A C K G R O U N D   - - - - - - - - - -
        // B A C K G R O U N D   - - - - - - - - - -
        // B A C K G R O U N D   - - - - - - - - - -
        GridLayout {
          columns: 3

          // a1-1
          Label {
            Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 15                                        
            
            text: 'Background'
          }
          
          // a1-2
		      RowLayout {

            property var myHeight: Screen.height
            property var myWidth: Screen.width

			      SpinBox {
              stepSize: 1
              to: parent.myHeight

              property alias myCfg: _Root.currentSlotCfg
              onMyCfgChanged: value = myCfg.paddingTop

              onValueChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
          	    myCfg.paddingTop = value;
              });            
			      }

			      Label {
				      text: 'px padding top'
			      }
  				}          

          // a1-3
          Item {}

          // a2-1
		      RowLayout {
            Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 12                          

            property var myHeight: Screen.height
            property var myWidth: Screen.width

			      SpinBox {
              stepSize: 1
              to: parent.myWidth

              property alias myCfg: _Root.currentSlotCfg
              onMyCfgChanged: value = myCfg.paddingLeft

              onValueChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
          	    myCfg.paddingLeft = value;
              });            
			      }

			      Label {
				      text: 'left'
			      }
  				}

          // a2-2
          RowLayout {
            Button {
              Layout.preferredHeight: _FontMetrics.height * 2.5
              Layout.preferredWidth: Layout.preferredHeight

              property alias myCfg: _Root.currentSlotCfg
              onMyCfgChanged: myColor = myCfg.background            

              property string myColor
              onMyColorChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
        	      myCfg.background = myColor;
              });

              onClicked: {

	              dlgSelectColor.selectedColor = myColor;
                dlgSelectColor.options = 0; /*SED*/
	              dlgSelectColor.handleOnAccepted = ($$selectedColor) => {
  	              myColor = $$selectedColor.toString();
	              };

	              dlgSelectColor.open();
              }

  				    Rectangle {
                width: parent.height * 0.6
                height: width
                anchors.centerIn: parent

                color: parent.myColor
	  		      }                      
            }                      
            
            Label {
				      text:  '[' + Screen.width + 'x' + Screen.height + ']'
			      }                                
          }

          // a2-3
		      RowLayout {

            property var myHeight: Screen.height
            property var myWidth: Screen.width

			      SpinBox {
              stepSize: 1
              to: parent.myWidth

              property alias myCfg: _Root.currentSlotCfg
              onMyCfgChanged: value = myCfg.paddingRight

              onValueChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
          	    myCfg.paddingRight = value;
              });            
			      }

			      Label {
				      text: 'right'
			      }            
  				}          

          // a3-1
          Item {
            Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 12                          
          }

          // a3-2
		      RowLayout {

            property var myHeight: Screen.height
            property var myWidth: Screen.width

			      SpinBox {
              stepSize: 1
              to: parent.myHeight

              property alias myCfg: _Root.currentSlotCfg
              onMyCfgChanged: value = myCfg.paddingBottom

              onValueChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
          	    myCfg.paddingBottom = value;
              });            
			      }

			      Label {
				      text: 'bottom'
			      }
  				}            

          // a3-3
          Item {}
        }
        // - - - - - - - - - -  B A C K G R O U N D
        // - - - - - - - - - -  B A C K G R O U N D
        // - - - - - - - - - -  B A C K G R O U N D

        Rectangle {
          Layout.preferredWidth: parent.width
          Layout.preferredHeight: _FontMetrics.height

          color: "transparent"
        
          Rectangle {
            anchors.centerIn: parent
            width: parent.width * .95
            height: 1

            color: _ActiveSystemPalette.mid
          }        
        }

        // I M A G E  - - - - - - - - - -        
        // I M A G E  - - - - - - - - - -        
        // I M A G E  - - - - - - - - - -        
        GridLayout {
          columns: 3

          // b1-1
          Label {
            Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 10              

            text: 'Image'
          }          

          // b1-2
    		  RowLayout {
			  
            Label {
              text: 'interval'
			      }

            SpinBox {
              id: _Interval

              stepSize: 1
              readonly property IntValidator intValidator: IntValidator {}
              to: intValidator.top

              property alias myCfg: _Root.currentSlotCfg
              onMyCfgChanged: value = myCfg.interval

              onValueChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
        	      myCfg.interval = value;
              });                                    
			      }

			      Label {
              Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 8              
  				    text: _Interval.value==0?'infinite':(_Interval.value==1?'second':'seconds')
              font.italic: _Interval.value==0
	  		    }          
          }                            

          // b1-3
		      RowLayout {

			      Label {
				      text: 'fill mode'
			      }

			      ComboBox {
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
          Item {
            Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 10
          }

          // b2-2, b2-3
          RowLayout {
            Layout.columnSpan: 2

            ColumnLayout {

              Label {
                horizontalAlignment: Text.AlignHCenter
					      text: 'desaturate'
				      }

				      Slider {
                property alias myCfg: _Root.currentSlotCfg
                onMyCfgChanged: value = myCfg.desaturate

                onValueChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
          	      myCfg.desaturate = value;
                });                                                  
				      }
			      }                      

            ColumnLayout {

              Label {
                horizontalAlignment: Text.AlignHCenter
		  			    text: 'blur'
				      }

				      Slider {
                property alias myCfg: _Root.currentSlotCfg
                onMyCfgChanged: value = myCfg.blur

                onValueChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
            	    myCfg.blur = value;
                });                                                                
				      }
			      }          


            ColumnLayout {

              Label {
					      text: 'colorize'
				      }

    				  Slider {
                property alias myCfg: _Root.currentSlotCfg
                onMyCfgChanged: value = myCfg.colorize

                onValueChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
          	      myCfg.colorize = value;
                  effects__updateColorizeValue(myCfg);
                });                                
				      }
			      }

			      Button {

              property alias myCfg: _Root.currentSlotCfg
              onMyCfgChanged: myColor = myCfg.colorizeColor

              property string myColor
              onMyColorChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
        	      myCfg.colorizeColor = myColor;
                effects__updateColorizeValue(myCfg);
              });

              onClicked: {

	              dlgSelectColor.selectedColor = myColor;
                dlgSelectColor.options = 0;
	              dlgSelectColor.handleOnAccepted = ($$selectedColor) => {
	                myColor = $$selectedColor.toString();
	              };

	              dlgSelectColor.open();
              }

  				    Rectangle {
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

        Rectangle {
          Layout.preferredWidth: parent.width
          Layout.preferredHeight: _FontMetrics.height

          color: "transparent"
        
          Rectangle {
            anchors.centerIn: parent
            width: parent.width * .95
            height: 1

            color: _ActiveSystemPalette.mid
          }        
        }

        // S O U R C E S  - - - - - - - - - -        
        // S O U R C E S  - - - - - - - - - -                
        // S O U R C E S  - - - - - - - - - -        
        GridLayout {
          columns: 3

          // c1-1
			    Label {
            Layout.preferredWidth: _FontMetrics.averageCharacterWidth * 10              

            text: 'Sources'
			    }          

          // c1-2, c1-3
    		RowLayout {
          Layout.columnSpan: 2

				  Button {
            id: '_BtnAddFolder'
            icon.name: "list-add"
					  text: 'Folder'

            onClicked: imagesources__addPathUsingDlg(_DlgAddFolder);            
				  }

				  Button {
            id: '_BtnAddFiles'
            icon.name: "list-add"
					  text: 'Files'

            onClicked: imagesources__addPathUsingDlg(_DlgAddFiles);            
				  }

				  Button {
            id: '_BtnSetUrl'
            icon.name: "internet-web-browser-symbolic"            
					  text: 'Use url'

            onClicked: imagesources__setUrl();            
				  }          

          Item {
            Layout.fillWidth: true
          }

			    CheckBox {
      	    text: 'shuffle'

            enabled: _ImageSources.count > 1

            property alias myCfg: _Root.currentSlotCfg
            onMyCfgChanged: checked = myCfg.shuffle

            onCheckedChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {
        	    myCfg.shuffle = checked?1:0;
            });
  		    }                    
        }          

        }

        // - - - - - - - - - -   S O U R C E S
        // - - - - - - - - - -   S O U R C E S        
        // - - - - - - - - - -   S O U R C E S                

		    ColumnLayout {
			    Layout.fillWidth: true
          Layout.fillHeight: true

			    ScrollView {
      	    Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 100


            ListView {
              id: _ImageSources
        	    width: parent.width

              property alias myCfg: _Root.currentSlotCfg
              onMyCfgChanged: {

		      	    inceptSources(myCfg.imagesources)

						    imagesources__updateButtonsState();
		          }

              model: ListModel {

                onCountChanged: plasmacfgAdapter.propagateCfgChange_afterAction(() => {

		      	      _ImageSources.extractSourcesToModel();

						      imagesources__updateButtonsState();
					      })                
              }

		          function extractSourcesToModel() {

		      	    let sources = [];

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

              delegate: RowLayout {

                Button {
                  icon.name: "edit-delete-remove"

                  onClicked: imagesources__removeSource(model.index);                  
								}

								Text {
								  Layout.fillWidth: true
                  text: model.path
								}
							}
				    }

			    }          

        }


      }
    }


/* Dev *
    Rectangle {
      id: _LogBackground
      color: '#00ff0000'                  
      Layout.fillWidth: true
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
/* /Dev */


  }


function dev_log($o) {

	_Log.say($o);
}

function dev_logo($o) {

	_Log.sayo($o);
}
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FolderDialog {
  	id: _DlgAddFolder
		title: "Choose a folder"

	  property var handleOnAccepted
  	onAccepted: handleOnAccepted([currentFolder])
	}

FileDialog {
  	id: _DlgAddFiles
		title: "Choose files"

    fileMode: FileDialog.OpenFiles

	  property var handleOnAccepted
  	onAccepted: handleOnAccepted(selectedFiles)
	}

Dialog {
	id: _DlgSetUrl

	width: parent.width * 0.6

	title: 'Use Url'
  standardButtons: Dialog.Ok | Dialog.Cancel

  property var handleOnAccepted
  onAccepted: handleOnAccepted(tfUrl.text);

	TextField {
		id: tfUrl
		focus: _DlgSetUrl.visible

		anchors.fill: parent
	}
}

ColorDialog {
	id: dlgSelectColor

  title: "Select color"
  modality: Qt.WindowModal

  property var handleOnAccepted
  onAccepted: handleOnAccepted(selectedColor)
}


Dialog {
	id: _DlgAddTimeslot

	title: 'Add Settings activated at'
  standardButtons: Dialog.Cancel

  property var excludeSlots: []
  property string newSlot

  onAccepted: {

    const element = {"slotmarker": newSlot};

		plasmacfgAdapter.atCfg_newTimeslotForMarker_cloneMarker(currentDeskCfg, element.slotmarker, _SelectSlot.model.get(_SelectSlot.currentIndex).slotmarker);

    selectSlot__insertSlot(element);
	}

  Component.onCompleted: initModels();

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

	RowLayout {

		ComboBox {
			id: comboHour
      model: ListModel {}
      textRole: 'text'

			onCurrentIndexChanged: _DlgAddTimeslot.buildNewSlot();
		}

		Label {
    	text: ':'
		}

		ComboBox {
			id: comboMinute
      model: ListModel {}
      textRole: 'text'

			onCurrentIndexChanged: _DlgAddTimeslot.buildNewSlot();
		}

		Button {
			id: btnAdd
  		text: 'Add'

  		onClicked: _DlgAddTimeslot.accept()
		}
  }

  function initModels() {

  	const mh = comboHour.model;
  	for(let i = 0; i < 24; ++i)
  	{
  		const text = ('00'+i).slice(-2);
  		mh.append({'text': text});
  	}
    comboHour.currentIndex = 0;

		const mm = comboMinute.model;
  	for(let i = 0; i < 60; ++i)
  	{
  		let text = ('00'+i).slice(-2);
  		mm.append({'text': text});
  	}
    comboMinute.currentIndex = 0;
  }

  function buildNewSlot() {

  	if(comboHour.currentIndex < 0 || comboMinute.currentIndex < 0)
  		return;
  		//<--


  	let hh = comboHour.model.get(comboHour.currentIndex).text;
  	let mm = comboMinute.model.get(comboMinute.currentIndex).text;

  	newSlot = hh + ':' + mm;
  	btnAdd.enabled = !excludeSlots.includes(newSlot);
  }
}



Dialog {
	id: _DlgAddConfig
  width: parent.width * 0.6

	title: 'Add Settings for'
  standardButtons: Dialog.Ok | Dialog.Cancel

  onAccepted: {

    const element = _ComboAddConfig.model[_ComboAddConfig.currentIndex];
    const currentDesktopConfigDeskNo = _SelectDesktop.model.get(_SelectDesktop.model.currentIndex).deskNo;

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

	ComboBox {
		id: _ComboAddConfig
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

	btnAddTimeslot.enabled = _SelectSlot.model.count < 60 * 24;

	btnRemoveTimeslot.enabled = _SelectSlot.currentIndex > 0;
}

function selectSlot__removeTimeslot() {

	plasmacfgAdapter.atCfg_deleteTimeslot(currentDeskCfg, _SelectSlot.model.get(_SelectSlot.currentIndex).slotmarker);

	_SelectSlot.model.remove(_SelectSlot.currentIndex);

	_SelectSlot.currentIndex = Math.max(0, _SelectSlot.currentIndex - 1);
}





function selectDesktop__removeConfig() {

	plasmacfgAdapter.deleteCfgNo(_SelectDesktop.model.get(_SelectDesktop.currentIndex).deskNo);

	_SelectDesktop.model.remove(_SelectDesktop.currentIndex);

	_SelectDesktop.currentIndex = Math.min(_SelectDesktop.currentIndex, _SelectDesktop.model.count - 1);
}

function selectDesktop__updateButtonsState() {

	btnAddDesktopConfig.enabled = _SelectDesktop.model.count < _Pager.count+1;

	btnRemoveDesktopConfig.enabled = _SelectDesktop.currentIndex > 0;
}


function selectDesktop__handleCurrentIndexChanged() {

	selectDesktop__updateButtonsState();

	currentDeskCfg = plasmacfgAdapter.getCfgForDeskNo(_SelectDesktop.model.get(_SelectDesktop.currentIndex).deskNo);
}

function selectDesktop__init($pageNo) {

  const currentConfigDeskNo = $pageNo + 1;

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

	_BtnAddFolder.enabled = ! (_ImageSources.model.count > 0 && _ImageSources.model.get(0).path.startsWith('http'));
	_BtnAddFiles.enabled = _BtnAddFolder.enabled;

	_BtnSetUrl.enabled = ! _ImageSources.model.count > 0;
}

function imagesources__addPathUsingDlg($$dlg) {

	$$dlg.handleOnAccepted = ($$resultUrls) => {

		for(let i=0; i<$$resultUrls.length; ++i)
		{
			let desanitized = VJS.AS_URISAFE($$resultUrls[i].toString(), false);
			_ImageSources.model.append({ path: desanitized });
		}
	};


	$$dlg.open();
}

function imagesources__setUrl() {

	_DlgSetUrl.handleOnAccepted = ($$text) => {

    $$text = $$text.startsWith('http')?$$text:'http://'+$$text;

		_ImageSources.model.append({ path: $$text });
	};

	_DlgSetUrl.open();
}

function imagesources__removeSource($index) {

	_ImageSources.model.remove($index);
}

}