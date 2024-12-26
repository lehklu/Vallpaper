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

    Component.onCompleted: {
      cb_log("SimpleKCM onCompleted")
      cb_logo(cfg_vrame6)
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

	property var cfg_vrame6
	property var cfg_vrame6Default

  ColumnLayout {

  RowLayout { // Manage/Select Desktop

    Rectangle {
      color: "orange"
      border.color: "black"
      border.width: 1              
    }

		Label {
		  text: "Desktop"
    }

    ComboBox {
		  id: dateDisplayFormat
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

  RowLayout { // Timeline
    Label {
		  text: "Timeline"
    }    
  }

  RowLayout { // Settings
    Label {
		  text: "Settings"
    }    
  }

  }
}