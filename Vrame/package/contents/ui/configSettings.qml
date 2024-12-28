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

  Column { // Page

    Rectangle { // Select Desktop
      anchors.left: parent.left
      anchors.right: parent.right
      height: childrenRect.height          
      
      border.color: "magenta"
      color: '#00000000'
      border.width: 1              

      Column {
        anchors.left: parent.left
        anchors.right: parent.right

        RowLayout {
          anchors.left: parent.left
          anchors.right: parent.right

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
      }
    }

    Rectangle { // Timeline
      anchors.left: parent.left    
      anchors.right: parent.right
      height: childrenRect.height
      
      border.color: "blue"
      color: '#00000000'
      border.width: 1              

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

      RowLayout {
        anchors.left: parent.left    
        anchors.right: parent.right        
        height: childrenRect.height

        Item {
          Layout.fillWidth: true
            Rectangle { anchors.fill: parent; color: "#ffaaaa" } // to visualize the spacer
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
    }

  }




  /* Dev */
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