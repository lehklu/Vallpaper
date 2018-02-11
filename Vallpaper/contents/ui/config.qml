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
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

import org.kde.kwindowsystem 1.0 as KWindowSystem
import QtQuick.Window 2.2

Item {
    id: root
    property var myConnector: wallpaper
    width: parent.width
    height: parent.height

    property var cfg_vdwConfigs

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
        } // siehe auch main.qml

    property var activeTab
    property bool pauseHandleCfgPropsChanged: false

    SystemPalette {
        id: sysPalette
    }

    KWindowSystem.KWindowSystem {
        id: kWindowSystem
    }

    TabView {
        id: tabView
        width: parent.width
        height: parent.height
        style: TabViewStyle {
            tab: Rectangle {
                color: styleData.selected ? sysPalette.highlight:sysPalette.midlight
                border.color:  styleData.selected ? sysPalette.highlightedText:sysPalette.text
                border.width:  styleData.selected ? 2 : 1
                implicitWidth: Math.max(text.width + 25, 80)
                implicitHeight: 30
                Text {
                    id: text
                    anchors.centerIn: parent
                    text: styleData.title
                    color: styleData.selected ? sysPalette.highlightedText:sysPalette.text
                }
            }
        }

        Component.onCompleted: {

            currentIndex=kWindowSystem.currentDesktop-1
        }

        Repeater {
            model: kWindowSystem.numberOfDesktops

            Tab {
                title: (index==tabView.currentIndex?"Desktop ":"") + "[ " + (index+1) + " ]"
                readonly property int myVdNo: index // index == delegate from Repeater

                property var cfgColorHex
                property var cfgBorderTop
                property var cfgBorderBottom
                property var cfgBorderLeft
                property var cfgBorderRight
                property var cfgInterval
                property var cfgFillMode
                property var cfgGeDesaturate
                property var cfgGeFastBlur
                property var cfgGeColorOverlayAlpha
                property var cfgPathsModel: ListModel {}
                property var cfgOrUrl

                onCfgColorHexChanged:               handleCfgPropsChanged()
                onCfgBorderTopChanged:              handleCfgPropsChanged()
                onCfgBorderBottomChanged:           handleCfgPropsChanged()
                onCfgBorderLeftChanged:             handleCfgPropsChanged()
                onCfgBorderRightChanged:            handleCfgPropsChanged()
                onCfgIntervalChanged:               handleCfgPropsChanged()
                onCfgFillModeChanged:               handleCfgPropsChanged()
                onCfgGeDesaturateChanged:           handleCfgPropsChanged()
                onCfgGeFastBlurChanged:             handleCfgPropsChanged()
                onCfgGeColorOverlayAlphaChanged:    handleCfgPropsChanged()
                // onCfgPathsModelChanged:                  handleCfgPropsChanged()
                onCfgOrUrlChanged:                  handleCfgPropsChanged()

                onVisibleChanged: { if(visible) { activeTab=this; } }

                Component.onCompleted: {

                    // populate my cfgProps
                    var cfgPropsSet=false;

                    for(var i in cfg_vdwConfigs)
                    {
                        var cfgI=JSON.parse(cfg_vdwConfigs[i]);

                        if(cfgI.vdNo!=myVdNo)
                            continue;


                        setCfgPropsFromConfig(cfgI);
                        cfgPropsSet=true;
                        break; // !
                    }

                    if(!cfgPropsSet)
                    {
                        var cfgNew=JSON.parse(JSON.stringify(configDEFAULT)); // clone configDEFAULT

                        cfgNew.vdNo=myVdNo;
                        setCfgPropsFromConfig(cfgNew);

                        cfg_vdwConfigs.push(JSON.stringify(cfgNew));
                    }
                }

                function handleCfgPropsChanged() {

                    if(pauseHandleCfgPropsChanged)
                        return;

                    var workConfigList=[];

                    for(var i in cfg_vdwConfigs)
                    {
                        var cfgI=JSON.parse(cfg_vdwConfigs[i]);

                        if(cfgI.vdNo==myVdNo)
                        {
                            setConfigFromCfgProps(cfgI)
                        }

                        workConfigList.push(JSON.stringify(cfgI));
                    }

                    cfg_vdwConfigs=workConfigList; // >>changed
                }

                function setCfgPropsFromConfig($cfgO) {

                    pauseHandleCfgPropsChanged=true;

                    cfgColorHex=$cfgO.colorHex;
                    cfgBorderTop=$cfgO.borderTop;
                    cfgBorderBottom=$cfgO.borderBottom;
                    cfgBorderLeft=$cfgO.borderLeft;
                    cfgBorderRight=$cfgO.borderRight;
                    cfgInterval=$cfgO.interval;
                    cfgFillMode=$cfgO.fillMode;
                    cfgGeDesaturate=$cfgO.geDesaturate;
                    cfgGeFastBlur=$cfgO.geFastBlur;
                    cfgGeColorOverlayAlpha=$cfgO.geColorOverlayAlpha;
                    cfgPathsModel_fromConfig($cfgO);
                    cfgOrUrl=$cfgO.orUrl;

                    pauseHandleCfgPropsChanged=false;
                }

                function setConfigFromCfgProps($cfgO) {

                    $cfgO.colorHex=cfgColorHex;
                    $cfgO.borderTop=cfgBorderTop;
                    $cfgO.borderBottom=cfgBorderBottom;
                    $cfgO.borderLeft=cfgBorderLeft;
                    $cfgO.borderRight=cfgBorderRight;
                    $cfgO.interval=cfgInterval;
                    $cfgO.fillMode=cfgFillMode;
                    $cfgO.geDesaturate=cfgGeDesaturate;
                    $cfgO.geFastBlur=cfgGeFastBlur;
                    $cfgO.geColorOverlayAlpha=cfgGeColorOverlayAlpha;
                    $cfgO.orUrl=cfgOrUrl;
                    cfgPathsModel_toConfig($cfgO);
                }

                function cfgPathsModel_fromConfig($cfgO) {

                    cfgPathsModel.clear;
                    for(var i in $cfgO.paths)
                    {
                        cfgPathsModel.append($cfgO.paths[i]);
                    }
                }

                function cfgPathsModel_toConfig($cfgO) {

                    $cfgO.paths=[];
                    for(var i=0; i<cfgPathsModel.count; i++)
                    {
                        $cfgO.paths.push(cfgPathsModel.get(i));
                    }
                }

                function addPaths($urls, $type) {

                    for(var i in $urls)
                    {
                        var pathO = {
                            'path':$urls[i],
                            'type':$type,
                            };

                        cfgPathsModel.append(pathO);
                    }

                    handleCfgPropsChanged();
                }

                function removePathAt($pathlistIdx) {

                    cfgPathsModel.remove($pathlistIdx);

                    handleCfgPropsChanged();
                }

                function colorAccepted($color) {

                    cfgColorHex=$color.toString() // ==> als #ffaa00
                }

                Rectangle { // provide background color for view
                    color: sysPalette.window
                    border.width: 1
                    border.color: sysPalette.text

                    ColumnLayout {
                        width: parent.width
                        height: parent.height
                        spacing: units.largeSpacing
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: units.largeSpacing / 2

                        Row {
                            // color
                            // color
                            // color
                            spacing: units.smallSpacing

                            Label {
                                width: units.gridUnit * 6
                                anchors.verticalCenter: colorButton.verticalCenter
                                text: "Background"
                            }

                            Button {
                                id: colorButton
                                width: units.gridUnit * 3
                                text: " " // needed to it gets a proper height...
                                onClicked: { colorDialog.color=cfgColorHex; colorDialog.open() }

                                Rectangle {
                                    id: colorRect
                                    anchors.centerIn: parent
                                    width: parent.width - 2 * units.smallSpacing
                                    height: theme.mSize(theme.defaultFont).height
                                    color: cfgColorHex
                                }
                            }
                        }

                        Row {
                            // Borders top/bottom
                            // Borders top/bottom
                            // Borders top/bottom
                            spacing: units.smallSpacing

                            Label {
                                width: units.gridUnit * 6
                                anchors.verticalCenter: borderTSpinBox.verticalCenter
                                text: "Borders"
                            }

                            SpinBox {
                                id: borderTSpinBox

                                suffix: "px"
                                decimals: 0

                                maximumValue: myConnector.height

                                Component.onCompleted:  value=cfgBorderTop
                                onValueChanged:         cfgBorderTop=value
                            }

                            Label {
                                width: units.gridUnit * 6
                                anchors.verticalCenter: borderTSpinBox.verticalCenter
                                text: "top (max. " + borderTSpinBox.maximumValue + ")"
                            }

                            SpinBox {
                                id: borderBSpinBox

                                suffix: "px"
                                decimals: 0

                                maximumValue: myConnector.height

                                Component.onCompleted:  value=cfgBorderBottom
                                onValueChanged:         cfgBorderBottom=value
                            }

                            Label {
                                width: units.gridUnit * 6
                                anchors.verticalCenter: borderBSpinBox.verticalCenter
                                text: "bottom (max. " + borderBSpinBox.maximumValue + ")"
                            }
                        }

                        Row {
                            // left/right
                            // left/right
                            // left/right
                            spacing: units.smallSpacing

                            Label {
                                width: units.gridUnit * 6
                                anchors.verticalCenter: borderLSpinBox.verticalCenter
                                text: ""
                            }

                            SpinBox {
                                id: borderLSpinBox

                                suffix: "px"
                                decimals: 0

                                maximumValue: myConnector.width

                                Component.onCompleted:  value=cfgBorderLeft
                                onValueChanged:         cfgBorderLeft=value
                            }

                            Label {
                                width: units.gridUnit * 6
                                anchors.verticalCenter: borderLSpinBox.verticalCenter
                                text: "left (max. " + borderLSpinBox.maximumValue + ")"
                            }

                            SpinBox {
                                id: borderRSpinBox

                                suffix: "px"
                                decimals: 0

                                maximumValue: myConnector.width

                                Component.onCompleted:  value=cfgBorderRight
                                onValueChanged:         cfgBorderRight=value
                            }

                            Label {
                                width: units.gridUnit * 6
                                anchors.verticalCenter: borderRSpinBox.verticalCenter
                                text: "right (max. " + borderRSpinBox.maximumValue + ")"
                            }
                        }

                        Row {
                            // interval
                            // interval
                            // interval
                            spacing: units.smallSpacing

                            Label {
                                width: units.gridUnit * 6
                                anchors.verticalCenter: intervalSpinBox.verticalCenter
                                text: "Interval"
                            }

                            SpinBox {
                                id: intervalSpinBox

                                suffix: "s"
                                decimals: 0

                                // Once a day should be high enough
                                maximumValue: 24*(60*60)

                                Component.onCompleted:  value=cfgInterval
                                onValueChanged:         cfgInterval=value
                            }
                        }

                        Row {
                            // fillMode
                            // fillMode
                            // fillMode
                            spacing: units.smallSpacing

                            Label {
                                id: labelFillMode
                                width: units.gridUnit * 6
                                anchors.verticalCenter: colFillMode.verticalCenter
                                text: "Fill mode"
                            }

                            Column {
                                id: colFillMode

                                ComboBox {
                                    id: cbFillMode
                                    width: units.gridUnit * 15
                                    currentIndex: indexFromFillMode(cfgFillMode)
                                    model:
                                    [
                                        { "text": "Fill",                           "value": Image.Stretch },
                                        { "text": "Fit",                            "value": Image.PreserveAspectFit },
                                        { "text": "Fill - preserve aspect ratio",   "value": Image.PreserveAspectCrop },
                                        { "text": "Tile",                           "value": Image.Tile },
                                        { "text": "Tile vertically",                "value": Image.TileVertically },
                                        { "text": "Tile horizontally",              "value": Image.TileHorizontally },
                                        { "text": "As is",                          "value": Image.Pad }
                                    ]

                                    onActivated: cfgFillMode = model[index].value // index === param von onActivated

                                    function indexFromFillMode($fillMode) {

                                        for(var i in model)
                                        {
                                            if(model[i].value==$fillMode) return i;
                                        }

                                        return -1;
                                    }
                                }
                            }
                        }

                        Row {
                            // effects
                            // effects
                            // effects
                            spacing: units.smallSpacing

                            Label {
                                id: labelEffects
                                width: units.gridUnit * 6
                                anchors.verticalCenter: colEffectAnchor.verticalCenter
                                text: "Effects"
                            }

                            // geDesaturation
                            // geDesaturation
                            // geDesaturation
                            Column {
                                id: colEffectAnchor
                                width: units.gridUnit * 6

                                Label {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    text: "Desaturate"
                                }

                                Slider {
                                    width: parent.width
                                    updateValueWhileDragging: false

                                    Component.onCompleted:  value=cfgGeDesaturate
                                    onValueChanged:         cfgGeDesaturate=value
                                }
                            }

                            // geFastBlur
                            // geFastBlur
                            // geFastBlur
                            Column {
                                width: units.gridUnit * 6

                                Label {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    text: "Blur"
                                }

                                Slider {
                                    width: parent.width
                                    updateValueWhileDragging: false

                                    Component.onCompleted:  value=cfgGeFastBlur
                                    onValueChanged:         cfgGeFastBlur=value
                                }
                            }

                            // geColorOverlay
                            // geColorOverlay
                            // geColorOverlay
                            Column {
                                width: units.gridUnit * 6

                                Label {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    text: "Colorize"
                                }

                                Slider {
                                    width: parent.width
                                    updateValueWhileDragging: false

                                    Component.onCompleted:  value=cfgGeColorOverlayAlpha
                                    onValueChanged:         cfgGeColorOverlayAlpha=value
                                }
                            }
                        }

                        // paths or url
                        // paths or url
                        // paths or url
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: units.smallSpacing / 2

                            RowLayout {
                                anchors.fill: parent

                                Label {
                                    text: "Local picture sources   ###  or Url:"
                                }

                                TextField {
                                    Layout.fillWidth: true
                                    Component.onCompleted:  text=cfgOrUrl
                                    onTextChanged: cfgOrUrl=text
                                }
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                frameVisible: true

                                ListView {
                                    width: parent.width
                                    model: cfgPathsModel

                                    delegate: RowLayout {
                                        width: parent.width

                                        Button {
                                            id: removePathButton
                                            iconName: "bookmark-remove"
                                            onClicked: removePathAt(model.index)
                                        }

                                        Text {
                                            id: pathText
                                            Layout.fillWidth: true
                                            text: model.path
                                            color: sysPalette.text
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.alignment: Qt.AlignCenter

                                Row {
                                    spacing: units.smallSpacing

                                    Button {
                                        iconName: "folder-new"
                                        onClicked: { folderDialog.open(); }
                                        text: "Add folder..."
                                    }

                                    Button {
                                        iconName: "file-new"
                                        onClicked: { fileDialog.open(); }
                                        text: "Add files..."
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    FileDialog {
        id: folderDialog
        visible: false
        title: "Choose a folder"
        selectFolder: true

        onAccepted: activeTab.addPaths(fileUrls, 'folder')
    }

    FileDialog {
        id: fileDialog
        visible: false
        title: "Choose files"
        selectExisting: true
        // selectMultiple: true

        onAccepted: activeTab.addPaths(fileUrls, 'file')
    }

    ColorDialog {
        id: colorDialog
        modality: Qt.WindowModal
        showAlphaChannel: myConnector===plasmoid
        title: "Select color"

        onAccepted: activeTab.colorAccepted(colorDialog.color)
    }

    /* Dev
    Rectangle {
        id: llogBackground
        visible: llog.text.length>0
        width: parent.width * 0.8
        height: parent.height * 0.3
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#AAffffff"

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