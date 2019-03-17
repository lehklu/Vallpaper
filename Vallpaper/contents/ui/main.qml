/*
 *  Copyright 2018  Werner Lechner <werner.lechner.2@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.5
import QtQuick.Controls 1.3 /* 1.3 2.2 */
import QtQuick.Controls.Styles 1.2 /* 1.2 1.4 */

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.mediaframe 2.0

import org.kde.kwindowsystem 1.0 as KWindowSystem

import QtGraphicalEffects 1.0

Rectangle {
    id: root

    property var myConnector: wallpaper
    property var myActionTextPrefix: '<Vallpaper> '
    color: activeColor

    property int activeVdNo
    property var activeColor
    property var activeImage
    property var activeGeDesaturate
    property var activeGeFastBlur
    property var activeGeColorOverlay

    property var tabCfg:[]

    property var configDEFAULT: {
        "colorHex": "#1d1d85",
        "borderTop":0,
        "borderBottom":0,
        "borderLeft":0,
        "borderRight":0,
        "interval":9,
        "fillMode":1,
        "geDesaturate": 0.0,
        "geFastBlur": 0.0,
        "geColorOverlayAlpha": 0.0,
        "paths": [],
        "orUrl": ""
        } // siehe auch config.qml

    property bool changePeriodically: true
    property int loadedPathsVdNo: -1

    MediaFrame {
        id: mediaFrame
        random: true
    }

    KWindowSystem.KWindowSystem {
        id: kWindowSystem

        Component.onCompleted: changeActiveDesktopNo(kWindowSystem.currentDesktop)

        onCurrentDesktopChanged: changeActiveDesktopNo(kWindowSystem.currentDesktop)

        function changeActiveDesktopNo($vdno) {

            activeVdNo=$vdno-1;
            updateActiveProps();
        }
    }

    Connections {
        target: myConnector.configuration
        onVdwConfigsChanged: setTabCfg()
    }

    Component.onCompleted: {

        setTabCfg();

        myConnector.setAction("open", myActionTextPrefix + "Open image", "document-open");
        myConnector.setAction("next", myActionTextPrefix + "Next image","user-desktop");
    }

    Repeater {
        id: imageRepeater
        model: kWindowSystem.numberOfDesktops

        Image {
            property var timestamp
            property bool isSolitarySource
            property var memSource

            // set anchors to allow use of margins
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            sourceSize.width: width
            sourceSize.height: height

            asynchronous: true
            autoTransform: true
            visible: false // displayed through Graphical effects

            // onStatusChanged: handleOnBufferReady(index, source, status)

            Component.onCompleted: { resetProps(); if(! changePeriodically) { checkIntervals(); } }

            function resetProps() {

                this.source="";
                this.timestamp=0;
                this.isSolitarySource=false;

                if(tabCfg[index]===undefined)
                    return;


                this.fillMode=              tabCfg[index].fillMode;
                this.anchors.topMargin=     tabCfg[index].borderTop;
                this.anchors.bottomMargin=  tabCfg[index].borderBottom;
                this.anchors.leftMargin=    tabCfg[index].borderLeft;
                this.anchors.rightMargin=   tabCfg[index].borderRight;
            }
        }
    }

    // Graphical effects
    // Graphical effects
    // Graphical effects
    Desaturate {
        id: geDesaturate

        source: activeImage
        anchors.fill: activeImage
        visible: activeImage.source!=""

        desaturation: activeGeDesaturate
    }

    FastBlur {
        id: geBlur

        source: geDesaturate
        anchors.fill: activeImage
        visible: activeImage.source!=""

        radius: activeGeFastBlur
    }

    ColorOverlay {
        id: geColorOverlay

        source: geBlur
        anchors.fill: activeImage
        visible: activeImage.source!=""

        color: activeGeColorOverlay
    }
    // Graphical effects
    // Graphical effects
    // Graphical effects

    /**
    Label {
        id: labelSource
        color: "#ffffffff"
        background: Rectangle {
            color: "#ff000000"
        }
    }
    /**/

    Timer {
        id: timer
        interval: 1000 * 1
        repeat: true
        running: changePeriodically
        onTriggered: checkIntervals()
    }

    function setTabCfg() {

        tabCfg=[];
        changePeriodically=false;

        var configList = myConnector.configuration.vdwConfigs;

        for(var i in configList)
        {
            var cfgI=JSON.parse(configList[i]);

            tabCfg[cfgI.vdNo] = cfgI;
            changePeriodically=changePeriodically||(cfgI.interval>0);
        }

        // create missing cfgs and setup images
        for(var i=0; i < kWindowSystem.numberOfDesktops; i++)
        {
            // missing cfg
            if(tabCfg[i]===undefined)
            {
                var cfgNew=JSON.parse(JSON.stringify(configDEFAULT)); // clone configDEFAULT
                tabCfg[i]=cfgNew;
                changePeriodically=changePeriodically||(cfgNew.interval>0);
            }

            // images
            var imageI=imageRepeater.itemAt(i);
            if(imageI!=null)
            {
                imageI.resetProps();
            }
        }

        updateActiveProps();

        checkIntervals();
    }

    function updateActiveProps() {

        if(tabCfg[activeVdNo]===undefined)
            return;

        activeColor=        tabCfg[activeVdNo].colorHex;
        activeGeDesaturate= tabCfg[activeVdNo].geDesaturate;
        activeGeFastBlur=   tabCfg[activeVdNo].geFastBlur * 100;
        var coaIntValue=Math.round(255 * tabCfg[activeVdNo].geColorOverlayAlpha);
        activeGeColorOverlay='#' + ("00" + coaIntValue.toString(16)).substr(-2) + activeColor.substr(-6);

        activeImage=imageRepeater.itemAt(activeVdNo);
        //labelSource.text=activeImage.source;
    }

    function checkIntervals() {

        var now=Date.now();

        for(var i=0; i<imageRepeater.count; i++)
        {
            var imageI=imageRepeater.itemAt(i);

            if(imageI==null)
                continue;

            if(imageI.isSolitarySource)
                continue;

            if(tabCfg[i].interval==0 && imageI.source!="")
                continue;

            if(now < (imageI.timestamp + tabCfg[i].interval*1000))
                continue;


            acquireNextItem(i, now);
        }
    }

    function acquireNextItem($vdNo, $timestamp) {

        var imageI=imageRepeater.itemAt($vdNo);

        imageI.timestamp = $timestamp;

        if(isSourceUrl($vdNo))
        {
            // from url
            imageI.cache = false;
            imageI.source = ""; // trigger reload
            gc();
            imageI.source = tabCfg[$vdNo].orUrl;
            //labelSource.text=activeImage.source;
        }
        else
        {
            // from local pictures
            if($vdNo!=loadedPathsVdNo)
            {
                mediaFrame.clear();

                var paths = tabCfg[$vdNo].paths;

                for(var i in paths)
                {
                    mediaFrame.add(paths[i].path, true); // path, recursive
                }

                imageI.isSolitarySource = mediaFrame.count<=1;
                imageI.source = mediaFrame.count==0?"":imageI.source;

                loadedPathsVdNo=$vdNo;
            }

            setNewSource(imageI, 10 /* tries to avoid repeated image */);
        }
    }

    function setNewSource($image, $wd) {

			mediaFrame.get(function($$filePath) {
      	/*
         * folder = ohne
         * files = mit 'file://'
         * gebraucht wird mit
         */
				var path=$$filePath.indexOf('file://')===0?$$filePath:'file://'+$$filePath;

				if(path!==$image.memSource || $wd===0)
				{
        	$image.source = path;
        	$image.memSource = path;
        	//labelSource.text=activeImage.source;
				}
				else
				{
					setNewSource($image, $wd-1);
				}
			});
    }

    function isSourceUrl($vdNo) {

        return tabCfg[$vdNo].orUrl!==undefined && tabCfg[$vdNo].orUrl.length>0;
    }

    function action_next() {

        activeImage.source="";
        activeImage.timestamp = -1;
        activeImage.isSolitarySource=false;

        if(! changePeriodically) { checkIntervals(); };
    }

    function action_open() {

        Qt.openUrlExternally(activeImage.source)
    }

		MouseArea {
			anchors.fill: parent
			acceptedButtons: Qt.LeftButton
			onPressAndHold: action_next();
      onDoubleClicked: action_open();
		}

    /* Dev *
    Rectangle {
        id: llogBackground
        visible: llog.text.length>0
        width: parent.width * 0.8
        height: parent.height * 0.7
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#CCffffff"

        TextArea {
            id: llog
            width: parent.width
            height: parent.height
            anchors.fill: parent
            backgroundVisible: false
            style: TextAreaStyle {
                    textColor: "#1d1d85"
                    }

            property int autoclear:0

            function clear() {

                text="";
                autoclear=0;
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
    } /**/
}