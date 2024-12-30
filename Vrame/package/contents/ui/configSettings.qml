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

SimpleKCM {
	id: generalPage

	property var cfg_vrame6
	property var cfg_vrame6Default

  Component.onCompleted: {
    cb_log("SimpleKCM onCompleted")
    cb_logo(cfg_vrame6)
  }

  ColumnLayout { // Container
	  anchors.fill: parent  

    RowLayout { // Select Desktop

		      Label {
		        text: "For desktop"
          }

          ComboBox {
            Layout.fillWidth: true
            model: [
              "model1",
              "model2",
              "model3"
			      ]
          }

          Button {
		        text: "Add"
            icon.name: "list-add"
          }

          Button {
            icon.name: "edit-delete-remove"
          }      
    }

    RowLayout {

      Component.onCompleted: { // DEV
        const model = listTimeslots.model;
        model.append({"slot": "00:00"});
        model.append({"slot": "01:00"});
        model.append({"slot": "02:00"});
        model.append({"slot": "03:00"});
        model.append({"slot": "04:00"});
        model.append({"slot": "05:00"});
        model.append({"slot": "06:00"});
        model.append({"slot": "07:00"});
        model.append({"slot": "08:00"});
        listTimeslots.currentIndex=0;
      }      

        Item {
          Layout.fillWidth: true
        }

        Label {
		      text: "Activated at"
        }

        ComboBox {
          id: listTimeslots                      
          model: ListModel{}
          textRole: "slot"
        }

		    Button {
          icon.name: "list-add"                      
	  	    text: 'Add'
		    }

		    Button {
          icon.name: "edit-delete-remove"          
  		  }              

    }

    GroupBox {
	    Layout.fillWidth: true
	    Layout.fillHeight: true      
      
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
            const model = listSources.model;
            model.append({"path": "......................."});
            model.append({"path": "......................."});
          }                

			    ScrollView {
      	    Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 100


            ListView {
              id: listSources
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




  /* Dev *
Rectangle {
		z: 1 // z-order
    id: llogBackground
    visible: llog.text.length>0
    width: parent.width * 0.8
    height: parent.height * 0.3
    anchors.bottom: parent.bottom
    //anchors.bottomMargin: 50
    //anchors.horizontalCenter: parent.horizontalCenter

    TextArea {
        id: llog
        width: parent.width
        height: parent.height
        anchors.fill: parent
        background: Rectangle {
          implicitWidth: 200
          implicitHeight: 40
          color: '#AAffffff'          
        }            

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

function cb_log($o) {

	llog.say($o);
}

function cb_logo($o) {

	llog.sayo($o);
}
/* /Dev */
}