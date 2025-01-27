/*
 *  Copyright 2024  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.kcmutils

import org.kde.plasma.private.pager

import "../js/vallpaper.js" as JS

SimpleKCM {
	id: _Root

  property var myPlasmoid: plasmoid

	property var cfg_vrame6
  property var cfg_vrame6Default // unused

  property var cfgAdapter  

  property var current_desktopCfg  
  property var current_timeslotCfg

  Component.onCompleted: {
    dev_log("SimpleKCM onCompleted")

    cfgAdapter = new JS.CfgAdapter(this, cfg_vrame6);
    desktopConfigs__init(_Pager.currentPage);    
  }

	PagerModel {
        id: _Pager

        enabled: _Root.visible
        pagerType: PagerModel.VirtualDesktops
	}

  ColumnLayout { // Container
	  anchors.fill: parent  

    RowLayout { // Select Desktop

		      Label {
		        text: "For desktop"
          }

          ComboBox {
            id: _DesktopConfigs
            Layout.fillWidth: true
            model: ListModel {}
            textRole: 'displayText'

		        Connections {
			        id: _DesktopConfigsConnections

              function onCurrentIndexChanged() { desktopConfigs__handleCurrentIndexChanged(); }
              function onCountChanged() { desktopConfigs__updateButtonsState();}
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

            onClicked: desktopConfigs__removeConfig()
          }      
    }

    RowLayout {

        Item {
          Layout.fillWidth: true
        }

        Label {
		      text: "Activated at"
        }

        ComboBox {
          id: _Timeslots                      
          model: ListModel{}

          Connections {
			      id: _TimeslotsConnections

            function onCurrentIndexChanged() { timeslots__handleCurrentIndexChanged(); }
            function onCountChanged() { timeslots__updateButtonsState();}
		      }                      

  				property alias desktopConfig: _Root.current_desktopCfg
				  onDesktopConfigChanged: timeslots__init()
        }

		    Button {
          id: btnAddTimeslot
          icon.name: "list-add"                      

          onClicked: _DlgAddTimeslot.open()
		    }

		    Button {
          id: btnRemoveTimeslot
          icon.name: "edit-delete-remove"          

          onClicked: timeslots__removeTimeslot()
  		  }              

    }

    GroupBox {
	    Layout.fillWidth: true
	    Layout.fillHeight: true      
      
      background: Rectangle {
        anchors.fill: parent
        color: '#00ffffff'
        border.width: 1
        radius: 5
      }

      ColumnLayout {
		    anchors.fill: parent      

		    RowLayout {
			
          Label {
            text: 'Background'
          }

			    Button {

            property alias myCfg: _Root.current_timeslotCfg
            onMyCfgChanged: myColor = myCfg.background            

            property string myColor
            onMyColorChanged: cfgAdapter.propagateChange(() => {
        	    myCfg.background = myColor;
            });

            onClicked: {

	            dlgSelectColor.selectedColor = myColor;
              dlgSelectColor.options = myPlasmoid === plasmoid?ColorDialog.ShowAlphaChannel:0;
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

		    RowLayout {
          id: _Borders

          property var myHeight: Screen.height
          property var myWidth: Screen.width
    
			    Label {
            text: 'Borders'
          }

			    SpinBox {
            stepSize: 1
            to: _Borders.myHeight

            property alias myCfg: _Root.current_timeslotCfg
            onMyCfgChanged: value = myCfg.borderTop

            onValueChanged: cfgAdapter.propagateChange(() => {
        	    myCfg.borderTop = value;
            });            
			    }

			    Label {
				    text: 'px top (max. ' + _Borders.myHeight + ')'
			    }

			    SpinBox {
            stepSize: 1
            to: _Borders.myHeight

            property alias myCfg: _Root.current_timeslotCfg
            onMyCfgChanged: value = myCfg.borderBottom

            onValueChanged: cfgAdapter.propagateChange(() => {
        	    myCfg.borderBottom = value;
            });                        
			    }

			    Label {
				    text: 'px bottom (max. ' + _Borders.myHeight + ')'
			    }
		    }

  		  RowLayout {

		  	  Label {
            text: '' // spacer
          }

			    SpinBox {
            stepSize: 1
            to: _Borders.myWidth

            property alias myCfg: _Root.current_timeslotCfg
            onMyCfgChanged: value = myCfg.borderLeft

            onValueChanged: cfgAdapter.propagateChange(() => {
        	    myCfg.borderLeft = value;
            });                                    
			    }

			    Label {
  				  text: 'px left (max. ' + _Borders.myWidth + ')'
	  		  }

			    SpinBox {
            stepSize: 1
            to: _Borders.myWidth

            property alias myCfg: _Root.current_timeslotCfg
            onMyCfgChanged: value = myCfg.borderRight

            onValueChanged: cfgAdapter.propagateChange(() => {
        	    myCfg.borderRight = value;
            });                                    
			    }

			    Label {
				    text: 'px right (max. ' + _Borders.myWidth + ')'
			    }
		    }

		    RowLayout {

			    Label {
				    text: 'Fill mode'
			    }

			    ComboBox {
				    currentIndex: 0
            textRole: 'text'

            property alias myCfg: _Root.current_timeslotCfg
            onMyCfgChanged: currentIndex = indexFromFillMode(myCfg.fillMode)

            onCurrentIndexChanged: cfgAdapter.propagateChange(() => {
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

		
        RowLayout {

			    Label {
				    text: 'Effects'
			    }

          ColumnLayout {

            Label {
              horizontalAlignment: Text.AlignHCenter
					    text: 'Desaturate'
				    }

				    Slider {
              property alias myCfg: _Root.current_timeslotCfg
              onMyCfgChanged: value = myCfg.desaturate

              onValueChanged: cfgAdapter.propagateChange(() => {
          	    myCfg.desaturate = value;
              });                                                  
				    }
			    }

          ColumnLayout {

            Label {
              horizontalAlignment: Text.AlignHCenter
					    text: 'Blur'
				    }

				    Slider {
              property alias myCfg: _Root.current_timeslotCfg
              onMyCfgChanged: value = myCfg.blur

              onValueChanged: cfgAdapter.propagateChange(() => {
          	    myCfg.blur = value;
              });                                                                
				    }
			    }

          ColumnLayout {

            Label {
					    text: 'Colorize'
				    }

    				Slider {
              property alias myCfg: _Root.current_timeslotCfg
              onMyCfgChanged: value = myCfg.colorize

              onValueChanged: cfgAdapter.propagateChange(() => {
          	    myCfg.colorize = value;
                effects__updateColorizeValue(myCfg);
              });                                
				    }
			    }

			    Button {

            property alias myCfg: _Root.current_timeslotCfg
            onMyCfgChanged: myColor = myCfg.colorizeColor

            property string myColor
            onMyColorChanged: cfgAdapter.propagateChange(() => {
        	    myCfg.colorizeColor = myColor;
              effects__updateColorizeValue(myCfg);
            });

            onClicked: {

	            dlgSelectColor.selectedColor = myColor;
              dlgSelectColor.options = myPlasmoid === plasmoid?ColorDialog.ShowAlphaChannel:0;
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

    		RowLayout {
			  
          Label {
            text: 'Interval'
			    }

          SpinBox {
            id: _Interval

            stepSize: 1
            readonly property IntValidator intValidator: IntValidator {}
            to: intValidator.top

            property alias myCfg: _Root.current_timeslotCfg
            onMyCfgChanged: value = myCfg.interval

            onValueChanged: cfgAdapter.propagateChange(() => {
        	    myCfg.interval = value;
            });                                    
			    }

			    Label {
  				  text: _Interval.value==0?'':_Interval.value==1?'second':'seconds'
	  		  }          
        }        


    		RowLayout {

			    Label {
            text: 'Image sources'
			    }

			    CheckBox {
      	    text: 'shuffle'

            property alias myCfg: _Root.current_timeslotCfg
            onMyCfgChanged: checked = myCfg.shuffle

            onCheckedChanged: cfgAdapter.propagateChange(() => {
        	    myCfg.shuffle = checked?1:0;
            });
  		    }          

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
        }

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

              property alias myCfg: _Root.current_timeslotCfg
              onMyCfgChanged: {

		      	    inceptSources(myCfg.imagesources)

						    imagesources__updateButtonsState();
		          }

              model: ListModel {

                onCountChanged: cfgAdapter.propagateChange(() => {

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


/* Dev */
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

		cfgAdapter.newTimeslotFor_clone(current_desktopCfg, element.slotmarker, _Timeslots.model.get(_Timeslots.currentIndex).slotmarker);

    timeslots__insertSlot(element);
	}

  Component.onCompleted: initModels();

  onVisibleChanged: {

  	if(!visible)
  		return;
  		// <--


	  let slots = [];
	  for(let i = 0; i < _Timeslots.model.count; ++i)
	  {
		  slots.push( _Timeslots.model.get(i).slotmarker);
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
    const currentDesktopConfigDeskNo = _DesktopConfigs.model.get(_DesktopConfigs.model.currentIndex).deskNo;

    cfgAdapter.newCfgFor_clone(element.deskNo, currentDesktopConfigDeskNo);

    desktopConfigs__insertElement(element);
	}

  onVisibleChanged: {

  	if(!visible) { return; }
    // <--


	  const existingDeskNos = [];
	  for(let i = 0; i < _DesktopConfigs.model.count; ++i)
	  {
		  existingDeskNos.push(_DesktopConfigs.model.get(i).deskNo);
	  }

		const myModel = [];
		for(let i=0; i<_Pager.count+1; ++i)
    {
      const deskNo = i;
      if(existingDeskNos.includes(deskNo)) { continue; }
      //<--


      myModel.push(desktopConfigs__buildElement(deskNo));
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

function timeslots__init() {

	const memConnTarget = _TimeslotsConnections.target;
	_TimeslotsConnections.target = null;

	_Timeslots.model.clear();
	const nowTimeslotCfg = current_desktopCfg.findAppropiateTimeslotCfg_now();  
	const orderedTimeslotCfgs = current_desktopCfg.getTimeslotCfgs();

	let activateIdx = 0;
	for(let $$i in orderedTimeslotCfgs)
	{
		const timeslotCfg = orderedTimeslotCfgs[$$i];

		timeslots__insertSlot({"slotmarker": timeslotCfg.slot});

    if(timeslotCfg===nowTimeslotCfg)
    {
      activateIdx = $$i;
    }
	}

	_TimeslotsConnections.target = memConnTarget;


	// activate
	if(_Timeslots.currentIndex == activateIdx)
	{
		timeslots__handleCurrentIndexChanged();
	}
	else
	{
		_Timeslots.currentIndex = activateIdx;
	}  


}

function timeslots__insertSlot($slot) {

  const model = _Timeslots.model;

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

	_Timeslots.currentIndex = idx;
}

function timeslots__handleCurrentIndexChanged() {

	timeslots__updateButtonsState();

	current_timeslotCfg = current_desktopCfg.getTimeslot(_Timeslots.model.get(_Timeslots.currentIndex).slotmarker);
}

function timeslots__updateButtonsState() {

	btnAddTimeslot.enabled = _Timeslots.model.count < 60 * 24;

	btnRemoveTimeslot.enabled = _Timeslots.currentIndex > 0;
}

function timeslots__removeTimeslot() {

	cfgAdapter.deleteTimeslot(current_desktopCfg, _Timeslots.model.get(_Timeslots.currentIndex).slot);

	_Timeslots.model.remove(_Timeslots.currentIndex);

	_Timeslots.currentIndex = Math.max(0, _Timeslots.currentIndex - 1);
}





function desktopConfigs__removeConfig() {

	cfgAdapter.deleteCfg(_DesktopConfigs.model.get(_DesktopConfigs.currentIndex).deskNo);

	_DesktopConfigs.model.remove(_DesktopConfigs.currentIndex);

	_DesktopConfigs.currentIndex = Math.min(_DesktopConfigs.currentIndex, _DesktopConfigs.model.count - 1);
}

function desktopConfigs__updateButtonsState() {

	btnAddDesktopConfig.enabled = _DesktopConfigs.model.count < _Pager.count+1;

	btnRemoveDesktopConfig.enabled = _DesktopConfigs.currentIndex > JS.CFG_DESKNO_DEFAULT;
}


function desktopConfigs__handleCurrentIndexChanged() {

	desktopConfigs__updateButtonsState();

	current_desktopCfg = cfgAdapter.getCfg(_DesktopConfigs.model.get(_DesktopConfigs.currentIndex).deskNo);
}

function desktopConfigs__init($currentConfigDeskNo) {

	let activateNo = JS.CFG_DESKNO_DEFAULT;

	// fill model
	const memConnTarget = _DesktopConfigsConnections.target;
	_DesktopConfigsConnections.target = null;

	for(const $$cfg of cfgAdapter.getCfgs())
	{
		desktopConfigs__insertElement(desktopConfigs__buildElement($$cfg.deskNo));

		if($$cfg.deskNo === $currentConfigDeskNo)
		{
			activateNo = $$cfg.deskNo;
		}
	}

	_DesktopConfigsConnections.target = memConnTarget;


  // activate current
  const model = _DesktopConfigs.model;  

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

	if(_DesktopConfigs.currentIndex == activateIndex)
	{
		desktopConfigs__handleCurrentIndexChanged();
	}
	else
	{
		_DesktopConfigs.currentIndex = activateIndex;
	}
}

function desktopConfigs__buildElement($deskNo) {

	const orderText = '#' + ('  '+$deskNo).slice(-3);

	return {
		'displayText': (JS.CFG_DESKNO_DEFAULT===$deskNo?'*':_Pager.data(_Pager.index($deskNo-1, 0), 0)),
    'deskNo': $deskNo,
    'orderText': orderText
		}
}

function desktopConfigs__insertElement($desktopElement) {

  const model = _DesktopConfigs.model;

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

	_DesktopConfigs.currentIndex = idx;
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
			let desanitized = JS.FILENAME_FROM_URISAFE($$resultUrls[i].toString());
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