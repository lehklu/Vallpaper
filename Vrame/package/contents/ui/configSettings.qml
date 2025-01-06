/*
 *  Copyright 2024  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs as QtDialogs
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

  property var act_desktop  
  property var act_timeslot

  Component.onCompleted: {
    cb_log("SimpleKCM onCompleted")

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
		        text: "Add"
            icon.name: "list-add"

            onClicked: dlgAddConfig.open()
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
          textRole: "slot"

          Connections {
			      id: _TimeslotsConnections

            function onCurrentIndexChanged() { timeslots__handleCurrentIndexChanged(); }
            function onCountChanged() { timeslots__updateButtonsState();}
		      }                      

  				property alias desktopConfig: _Root.act_desktop
				  onDesktopConfigChanged: timeslots__init()
        }

		    Button {
          id: btnAddTimeslot
          icon.name: "list-add"                      
	  	    text: 'Add'

          onClicked: dlgAddTimeslot.open()
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

  				  Rectangle {
              anchors.centerIn: parent
              width: 20
              height: 20

              color: "cyan"
  				  }
	  		  }
		    }

		    RowLayout {

			    Label {
            text: 'Borders'
          }

			    SpinBox {
            stepSize: 1
            to: 100

				    value: 0
			    }

			    Label {
				    text: 'px top (max. ' + 100 + ')'
			    }

			    SpinBox {
            stepSize: 1
            to: 100

				    value: 0
			    }

			    Label {
				    text: 'px bottom (max. ' + 100 + ')'
			    }
		    }

  		  RowLayout {

		  	  Label {
            text: '' // spacer
          }

			    SpinBox {
            stepSize: 1
            to: 100

				    value: 0
			    }

			    Label {
  				  text: 'px left (max. ' + 100 + ')'
	  		  }

			    SpinBox {
            stepSize: 1
            to: 100

				    value: 0
			    }

			    Label {
				    text: 'px right (max. ' + 100 + ')'
			    }
		    }

		    RowLayout {

			    Label {
				    text: 'Fill mode'
			    }

			    ComboBox {
				    currentIndex: 0

				    model:
        	    [
                'Fill',
                'Fit',
                'Fill - preserve aspect ratio',
                'Tile',
                'Tile vertically',
                'Tile horizontally',
                'As is'
              ]

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
  					  value: 0
				    }
			    }

          ColumnLayout {

            Label {
              horizontalAlignment: Text.AlignHCenter
					    text: 'Blur'
				    }

				    Slider {
					    value: 0
				    }
			    }

          ColumnLayout {

            Label {
					    text: 'Colorize'
				    }

    				Slider {
  					  value: 0
				    }
			    }

			    Button {

				    Rectangle {
              anchors.centerIn: parent
              width: 20
              height: 20

              color: 'magenta'
				    }
			    }
		    }

    		RowLayout {
			  
          Label {
            text: 'Interval'
			    }

          SpinBox {
            stepSize: 1
            to: 100
  				  value: 0
			    }
        }        


    		RowLayout {

			    Label {
            text: 'Image sources'
			    }

			    CheckBox {
      	    text: 'shuffle'

      	    checked: true

  		    }

          Item {
            Layout.fillWidth: true
          }          

				  Button {
					  text: 'Add folder...'
				  }

				  Button {
					  text: 'Add files...'
				  }

				  Button {
					  text: 'Use url...'
				  }          

        }

		    ColumnLayout {
			    Layout.fillWidth: true
          Layout.fillHeight: true


          Component.onCompleted: { // DEV
            const model = _ImageSources.model;
            model.append({"path": "......................."});
            model.append({"path": "......................."});
          }                

			    ScrollView {
      	    Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 100


            ListView {
              id: _ImageSources
        	    width: parent.width
              model: ListModel {}

              delegate: RowLayout {
                width: parent.width

                Button {
                  icon.name: "edit-delete-remove"
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
  }




  /* Dev */
Rectangle {
		z: 1 // z-order
    id: llogBackground
    anchors.fill: parent
    anchors.topMargin: parent.height*0.5
    color: '#00ff0000'                  

    ScrollView {
      anchors.fill: parent      
      background: Rectangle {
        color: '#0000ff00'
      }      

      TextArea {
        id: llog
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

function cb_log($o) {

	llog.say($o);
}

function cb_logo($o) {

	llog.sayo($o);
}
/* /Dev */


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Dialog {
	id: dlgAddConfig
  width: parent.width * 0.6

	title: 'Add config for'
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
	const nowTimeslot = act_desktop.findAppropiateTimeslot_now();  
	const orderedTimeslots = act_desktop.getTimeslots();

	let activateIdx = 0;
	for(let $$i in orderedTimeslots)
	{
		const timeslot = orderedTimeslots[$$i];

		timeslots__insertElement({ 'slot': timeslot.slot });

    if(timeslot===nowTimeslot)
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

function timeslots__insertElement($timeslotsElement) {

  const model = _Timeslots.model;

	let idx = 0;
	while(idx < model.count && $timeslotsElement.slot > model.get(idx).slot)
	{
		++idx;
	}

	if(model.count===0)
	{
		model.append($timeslotsElement);
	}
	else
	{
		model.insert(idx, $timeslotsElement);
	}

	_Timeslots.currentIndex = idx;
}

function timeslots__handleCurrentIndexChanged() {

	timetable__updateButtonState();

	act_timeslot = act_desktop.getTimeslot(_Timeslots.model.get(_Timeslots.currentIndex).slot);
  cb_logo(_Timeslots.model.get(0));
  cb_log("-----------------");
  cb_logo(_Timeslots.model.get(_Timeslots.currentIndex).fillMode);
	cb_log('act_ #' + act_desktop.deskNo + ' @' + act_timeslot.slot);
}

function timetable__updateButtonState() {

	btnAddTimeslot.enabled = _Timeslots.model.count < 60 * 24;

	btnRemoveTimeslot.enabled = _Timeslots.currentIndex > 0;
}

function timetable__handleSlotClicked($theClicked, $index) {

	let w = listTimeslots;

	if(w.currentIndex !== $index)
	{
		w.currentIndex = $index;
	}
	else
	{
		$theClicked.checked = true;
	}
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

	act_desktop = cfgAdapter.getCfg(_DesktopConfigs.model.get(_DesktopConfigs.currentIndex).deskNo);
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

}