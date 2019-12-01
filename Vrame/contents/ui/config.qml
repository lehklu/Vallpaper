/*
 *  Copyright 2019  Werner Lechner <werner.lechner.2@gmail.com>
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

import "../js/vallpaper.js" as JS


Item {
// r o o t
// r o o t
// r o o t

id: root
/* Dev *
Rectangle {
		z: 1 // z-order
    id: llogBackground
    visible: llog.text.length>0
    width: parent.width * 0.8
    height: parent.height * 0.3
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 50
    anchors.horizontalCenter: parent.horizontalCenter
    color: '#AAffffff'

    TextArea {
        id: llog
        width: parent.width
        height: parent.height
        anchors.fill: parent
        backgroundVisible: false
        style: TextAreaStyle {
                textColor: '#1d1d85'
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


property var myConnector: plasmoid
width: parent.width
height: parent.height

property var cfg_vrame2

property var act_desktop
property var act_timeslot

															// A d a p t e r
															// A d a p t e r
															// A d a p t e r
property var cfgAdapter
Component.onCompleted: {

	cfgAdapter = new JS.CfgAdapter(this, cfg_vrame2);
	chooseDesktop__fillModel_activate(kWindowSystem.currentDesktop);
}


function cb_handleConfigChanged($newCfg) {

	cfg_vrame2 = $newCfg;
}
															//
															//
															//

property int myFontWidth: theme.mSize(theme.defaultFont).width
property int myFontHeight: theme.mSize(theme.defaultFont).height
property int mySmallButtonWidth: myFontWidth * 4

SystemPalette { id: kSystemPalette }
KWindowSystem.KWindowSystem { id: kWindowSystem }

ColumnLayout {
	anchors.fill: parent

RowLayout {
// c h o o s e   d e s k t o p
// c h o o s e   d e s k t o p
// c h o o s e   d e s k t o p

  Label {
    text: 'Desktop'
	}

	ComboBox {
		id: comboActiveConfig

		Layout.fillWidth: true
		model: ListModel {}
		textRole: 'text'

		Connections {
			id: comboActiveConfigConnections // pausable

			onCurrentIndexChanged: chooseDesktop__handleCurrentIndexChanged();
			onCountChanged: chooseDesktop__handleCountChanged();
		}
	}

	Button {
		id: btnAddConfig
		Layout.preferredWidth: root.mySmallButtonWidth
  	text: 'Add'

  	onClicked: chooseDesktop__beginAddConfig()
	}

	Button {
		id: btnRemoveConfig
		Layout.preferredWidth: root.mySmallButtonWidth
    text: 'X'

    onClicked: chooseDesktop__removeConfig();
	}
// c h o o s e   d e s k t o p
}

GroupBox {
// t i m e t a b l e
// t i m e t a b l e
// t i m e t a b l e
	Layout.preferredWidth: parent.width * 0.9
	anchors.horizontalCenter: parent.horizontalCenter
	title: 'Activate at'
	flat: true

	RowLayout {
		anchors.fill: parent

		ScrollView {
			Layout.fillWidth: true
			Layout.preferredHeight: root.myFontHeight * 3.5
			horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOn

	    ListView {
	    	id: listTimeslots
	      orientation: ListView.Horizontal
	      width: parent.width
	      model: ListModel {}

				Connections {
					id: listTimeslotsConnections // pausable

					onCurrentIndexChanged: timetable__handleCurrentIndexChanged();
					onCountChanged: timetable__handleCountChanged();
				}

				property alias parentCfg: root.act_desktop
				onParentCfgChanged: timetable__fillModel_activateCurrent();

				delegate: Button {
										text: model.slot
										checkable: true
								  	onClicked: timetable__handleSlotClicked(this, index)

								  	property int refCurrentIndex: listTimeslots.currentIndex
								  	onRefCurrentIndexChanged: checked = index == refCurrentIndex
										}
			}
		}

		Button {
			id: btnAddTimeslot
			anchors.top: parent.top
			Layout.preferredWidth: root.mySmallButtonWidth
	  	text: 'Add'

	  	onClicked: timetable__beginAddSlot()
		}

		Button {
			id: btnRemoveTimeslot
			anchors.top: parent.top
			Layout.preferredWidth: root.mySmallButtonWidth
	    text: 'X'

	    onClicked: timetable__removeSlot()
		}
	}
// t i m e t a b l e
}

GroupBox {
// p r o p e r t i e s
// p r o p e r t i e s
// p r o p e r t i e s
	Layout.fillWidth: true
	Layout.fillHeight: true

  ColumnLayout {
		anchors.fill: parent
		id: colProperties

		property int myLabelWidth: root.myFontWidth * 12

		RowLayout {
		// b a c k g r o u n d

			Label {
				Layout.preferredWidth: colProperties.myLabelWidth
				text: 'Background'
			}

			Button {
				Layout.preferredWidth: root.myFontHeight * 2.5
				Layout.preferredHeight: root.myFontHeight * 2.5

        property string selectedColor: undefined
        onSelectedColorChanged: cfgAdapter.propagateChange(() => {
        	s_cfg.background = selectedColor;
        });

        property alias s_cfg: root.act_timeslot
        onS_cfgChanged: selectedColor = s_cfg.background

        onClicked: properties__selectColor(this);

				Rectangle {
          anchors.centerIn: parent
          width: root.myFontHeight * 2
          height: root.myFontHeight * 2

          color: parent.selectedColor
				}
			}
		// b a c k g r o u n d
		}

		RowLayout {
		// B o r d e r s   t o p / b o t t o m

			Label {
				Layout.preferredWidth: colProperties.myLabelWidth
        text: 'Borders'
      }

			SpinBox {
				suffix: 'px'
        decimals: 0
        maximumValue: myConnector.height

				value: 0
        onValueChanged: cfgAdapter.propagateChange(() => {
        	s_cfg.borderTop = value;
        });

        property alias s_cfg: root.act_timeslot
        onS_cfgChanged: value = s_cfg.borderTop
			}

			Label {
				Layout.preferredWidth: colProperties.myLabelWidth
				text: 'top (max. ' + myConnector.height + ')'
			}

			SpinBox {
				suffix: 'px'
        decimals: 0
        maximumValue: myConnector.height

				value: 0
        onValueChanged: cfgAdapter.propagateChange(() => {
        	s_cfg.borderBottom = value;
        });

        property alias s_cfg: root.act_timeslot
        onS_cfgChanged: value = s_cfg.borderBottom
			}

			Label {
				text: 'bottom (max. ' + myConnector.height + ')'
			}

		// B o r d e r s   t o p / b o t t o m
		}

		RowLayout {
		// B o r d e r s   l e f t / r i g h t

			Label {
				Layout.preferredWidth: colProperties.myLabelWidth
        text: '' // spacer
      }

			SpinBox {
				suffix: 'px'
        decimals: 0
        maximumValue: myConnector.width

				value: 0
        onValueChanged: cfgAdapter.propagateChange(() => {
        	s_cfg.borderLeft = value;
        });

        property alias s_cfg: root.act_timeslot
        onS_cfgChanged: value = s_cfg.borderLeft
			}

			Label {
				Layout.preferredWidth: colProperties.myLabelWidth
				text: 'left (max. ' + myConnector.width + ')'
			}

			SpinBox {
				suffix: 'px'
        decimals: 0
        maximumValue: myConnector.width

				value: 0
        onValueChanged: cfgAdapter.propagateChange(() => {
        	s_cfg.borderRight = value;
        });

        property alias s_cfg: root.act_timeslot
        onS_cfgChanged: value = s_cfg.borderRight
			}

			Label {
				text: 'right (max. ' + myConnector.width + ')'
			}

		// B o r d e r s   l e f t / r i g h t
		}

		RowLayout {
		// f i l l M o d e

			Label {
				Layout.preferredWidth: colProperties.myLabelWidth
				text: 'Fill mode'
			}

			ComboBox {
				Layout.preferredWidth: root.myFontWidth * 25

				currentIndex: 0
        onCurrentIndexChanged: cfgAdapter.propagateChange(() => {
        	s_cfg.fillMode = model[currentIndex].value;
        });

        property alias s_cfg: root.act_timeslot
        onS_cfgChanged: currentIndex = indexFromFillMode(s_cfg.fillMode)


				model:
        	[
          { 'text': 'Fill',                           'value': Image.Stretch },
          { 'text': 'Fit',                            'value': Image.PreserveAspectFit },
          { 'text': 'Fill - preserve aspect ratio',   'value': Image.PreserveAspectCrop },
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
		// f i l l M o d e
		}

		RowLayout {
		// e f f e c t s

			Label {
				Layout.preferredWidth: colProperties.myLabelWidth
				text: 'Effects'
			}

      ColumnLayout { // geDesaturation

        Label {
					Layout.preferredWidth: colProperties.myLabelWidth
          horizontalAlignment: Text.AlignHCenter
					text: 'Desaturate'
				}

				Slider {
					Layout.preferredWidth: colProperties.myLabelWidth
          updateValueWhileDragging: false

					value: 0
        	onValueChanged: cfgAdapter.propagateChange(() => {
        		s_cfg.desaturate = value;
        	});

        	property alias s_cfg: root.act_timeslot
        	onS_cfgChanged: value = s_cfg.desaturate
				}
			}

      ColumnLayout { // geFastBlur

        Label {
					Layout.preferredWidth: colProperties.myLabelWidth
          horizontalAlignment: Text.AlignHCenter
					text: 'Blur'
				}

				Slider {
					Layout.preferredWidth: colProperties.myLabelWidth
          updateValueWhileDragging: false

					value: 0
        	onValueChanged: cfgAdapter.propagateChange(() => {
        		s_cfg.blur = value;
        	});

        	property alias s_cfg: root.act_timeslot
        	onS_cfgChanged: value = s_cfg.blur
				}
			}

      ColumnLayout { // geColorOverlay

        Label {
					Layout.preferredWidth: colProperties.myLabelWidth
          horizontalAlignment: Text.AlignHCenter
					text: 'Colorize'
				}

				Slider {
					Layout.preferredWidth: colProperties.myLabelWidth
          updateValueWhileDragging: false

					value: 0
        	onValueChanged: cfgAdapter.propagateChange(() => {
	        	s_cfg.colorize = value;
	        	util__setColorizeValue(s_cfg);
  	      });

    	    property alias s_cfg: root.act_timeslot
      	  onS_cfgChanged: value = s_cfg.colorize
				}
			}

			Button {
				Layout.preferredWidth: root.myFontHeight * 2.5
				Layout.preferredHeight: root.myFontHeight * 2.5

        property string selectedColor: undefined
        onSelectedColorChanged: cfgAdapter.propagateChange(() => {
        	s_cfg.colorizeColor = selectedColor;
        	util__setColorizeValue(s_cfg);
        });

        property alias s_cfg: root.act_timeslot
        onS_cfgChanged: selectedColor = s_cfg.colorizeColor

        onClicked: properties__selectColor(this);

				Rectangle {
          anchors.centerIn: parent
          width: root.myFontHeight * 2
          height: root.myFontHeight * 2

          color: parent.selectedColor
				}
			}
		// e f f e c t s
		}

		RowLayout {
		// i n t e r v a l

			Label {
				Layout.preferredWidth: colProperties.myLabelWidth
        text: 'Interval'
			}

      SpinBox {
				suffix: 's'
        decimals: 0

				readonly property IntValidator intValidator: IntValidator {}
        maximumValue: intValidator.top

				value: 0
        onValueChanged: cfgAdapter.propagateChange(() => {
        	s_cfg.interval = value;
        });

        property alias s_cfg: root.act_timeslot
        onS_cfgChanged: value = s_cfg.interval
			}
    // i n t e r v a l
    }

		RowLayout {
    // r a n d o m

			Label {
				Layout.preferredWidth: colProperties.myLabelWidth
        text: 'Picture sources'
			}

			CheckBox {
      	text: 'random'

      	checked: true
        onCheckedChanged: cfgAdapter.propagateChange(() => {
        	s_cfg.random = checked?1:0;
        });

        property alias s_cfg: root.act_timeslot
        onS_cfgChanged: checked = s_cfg.random
  		}
    // r a n d o m
    }

		ColumnLayout {
    // p i c t u r e s o u r c e s
    // p i c t u r e s o u r c e s
    // p i c t u r e s o u r c e s

			Layout.fillWidth: true
      Layout.fillHeight: true

			ScrollView {
      	Layout.fillWidth: true
        Layout.fillHeight: true
        frameVisible: true

        ListView {
        	id: listPicturesources
        	width: parent.width

					property int changeFlag: 0
		      onChangeFlagChanged: cfgAdapter.propagateChange(() => {

		      	s_cfg.sources = extractSources(model);

						picturesources__updateButtonState();
					});

		      property alias s_cfg: root.act_timeslot
		      onS_cfgChanged: {

		      	inceptSources(model, s_cfg.sources)

						picturesources__updateButtonState();
		      }

		      function extractSources($model) {

		      	let sources = [];

		      	for(let i = 0; i < $model.count; ++i)
		      	{
		      		sources.push($model.get(i).path);
		      	}

		      	return sources;
		      }

					function inceptSources($model, $sources) {

						$model.clear();

						for(let $$source of $sources)
						{
							$model.append({path: $$source});
						}
		      }

          model: ListModel {}

          delegate: RowLayout {
          						width: parent.width

											Button {
                        Layout.preferredWidth: root.mySmallButtonWidth
                        text: 'X'

                        onClicked: picturesources__removeSource(model.index);
											}

											Text {
												color: kSystemPalette.text
												Layout.fillWidth: true
                        text: model.path
											}
										}
				}
			}

			RowLayout {
    		Layout.alignment: Qt.AlignCenter

				Button {
					id: btnAddFolder
					text: 'Add folder...'

					onClicked: picturesources__addPathWith(dlgAddFolder);
				}

				Button {
					id: btnAddFiles
					text: 'Add files...'

					onClicked: picturesources__addPathWith(dlgAddFiles);
				}

				Button {
					id: btnAddUrl
					text: 'Use url...'

					onClicked: picturesources__addUrl();
				}
			}
		// p i c t u r e s o u r c e s
		}
	}

	Item {} // workaround: without this, layout is unusable on small (height) screens ('Add' buttons at bottom are cut not visible)
// p r o p e r t i e s
}
}

																				// u t i l

																				// u t i l

																				// u t i l

function util__buildElementDesktopList($no) {

	let sort = '#' + ('  '+$no).slice(-3);

	return {
		'text': (JS.CFG_DESKNO_DEFAULT===$no?'*':sort + ': ' + kWindowSystem.desktopName($no)),
    'deskNo': $no,
    'sort': sort
		}
}

function util__buildElementTimetable($slot) {

	return { 'slot': $slot }
}

function util__setColorizeValue($aTimeslot) {

	let alpha = Math.round(255 * $aTimeslot.colorize);
	$aTimeslot.colorizeValue = '#' + ("00" + alpha.toString(16)).substr(-2) + $aTimeslot.colorizeColor.substr(-6);
}

																				// c h o o s e D e s k t o p

																				// c h o o s e D e s k t o p

																				// c h o o s e D e s k t o p

function chooseDesktop__fillModel_activate($deskNo) {

	let activateNo = JS.CFG_DESKNO_DEFAULT;

	// fill
	let memConnTarget = comboActiveConfigConnections.target;
	comboActiveConfigConnections.target = null;

	for(let $$cfg of cfgAdapter.getCfgs())
	{
		chooseDesktop__modelInsertElement(util__buildElementDesktopList($$cfg.deskNo));

		if($$cfg.deskNo === $deskNo)
		{
			activateNo = $deskNo;
		}
	}

	comboActiveConfigConnections.target = memConnTarget;


	// activate
	let w = comboActiveConfig;

	let activateIndex = 0;
	for(let i = 0; i < w.model.count; ++i)
	{
		if(w.model.get(i).deskNo === activateNo)
		{
			activateIndex = i;
			break;
			// <--
		}
	}

	if(w.currentIndex == activateIndex)
	{
		chooseDesktop__handleCurrentIndexChanged();
	}
	else
	{
		w.currentIndex = activateIndex;
	}
}

function chooseDesktop__handleCountChanged() {

	chooseDesktop__updateButtonState();
}

function chooseDesktop__handleCurrentIndexChanged() {

	chooseDesktop__updateButtonState();

	let w = comboActiveConfig;

	act_desktop = cfgAdapter.getCfg(w.model.get(w.currentIndex).deskNo);
}

function chooseDesktop__updateButtonState() {

	let w = comboActiveConfig;

	btnAddConfig.enabled = w.model.count < kWindowSystem.numberOfDesktops+1;

	btnRemoveConfig.enabled = w.currentIndex > JS.CFG_DESKNO_DEFAULT;
}

function chooseDesktop__modelInsertElement($desktopElement) {

	let w = comboActiveConfig;

	let idx = 0;
	while(idx < w.model.count && $desktopElement.sort > w.model.get(idx).sort)
	{
		++idx;
	}

	if(w.model.count===0)
	{
		w.model.append($desktopElement);
	}
	else
	{
		w.model.insert(idx, $desktopElement);
	}

	w.currentIndex = idx;
}

function chooseDesktop__beginAddConfig() {

	let w = comboActiveConfig;

	let existingNos = [];
	for(let i = 0; i < w.model.count; ++i)
	{
		existingNos.push(w.model.get(i).deskNo);
	}
	dlgAddDesktop.excludeNos = existingNos;


	dlgAddDesktop.handleOnAccepted = ($$element)=>{

		cfgAdapter.newCfgFor_clone($$element.deskNo, w.model.get(w.currentIndex).deskNo);

		chooseDesktop__modelInsertElement($$element);
	}


	dlgAddDesktop.open();
}

function chooseDesktop__removeConfig() {

	let w = comboActiveConfig;

	cfgAdapter.deleteCfg(w.model.get(w.currentIndex).deskNo);

	w.model.remove(w.currentIndex);

	w.currentIndex = Math.max(0, w.currentIndex - 1);
}

																				// t i m e t a b l e

																				// t i m e t a b l e

																				// t i m e t a b l e

function timetable__fillModel_activateCurrent() {

	let w = listTimeslots;

	// fill
	let nowTimeslot = act_desktop.findAppropiateTimeslot_now();

	let memConnTarget = listTimeslotsConnections.target;
	listTimeslotsConnections.target = null;

	w.model.clear();

	let orderedTimeslots = act_desktop.getTimeslots();
	let activateIdx = 0;
	for(let i in orderedTimeslots)
	{
		let timeslot = orderedTimeslots[i];

		timetable__modelInsertElement(util__buildElementTimetable(timeslot.slot));

		activateIdx = timeslot===nowTimeslot?i:activateIdx;
	}

	listTimeslotsConnections.target = memConnTarget;


	// activate
	if(w.currentIndex == activateIdx)
	{
		timetable__handleCurrentIndexChanged();
	}
	else
	{
		w.currentIndex = activateIdx;
	}
}

function timetable__modelInsertElement($timetableElement) {

	let w = listTimeslots;

	let idx = 0;
	while(idx < w.model.count && $timetableElement.slot > w.model.get(idx).slot)
	{
		++idx;
	}

	if(w.model.count===0)
	{
		w.model.append($timetableElement);
	}
	else
	{
		w.model.insert(idx, $timetableElement);
	}

	w.currentIndex = idx;
}

function timetable__handleCountChanged() {

	timetable__updateButtonState();
}

function timetable__handleCurrentIndexChanged() {

	let w = listTimeslots;

	timetable__updateButtonState();

	act_timeslot = act_desktop.getTimeslot(w.model.get(w.currentIndex).slot);
	//llog.say('act_ #' + act_desktop.deskNo + ' @' + act_timeslot.slot);
}

function timetable__updateButtonState() {

	let w = listTimeslots;

	btnAddTimeslot.enabled = w.model.count < 60 * 24;

	btnRemoveTimeslot.enabled = w.currentIndex > 0;
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

function timetable__beginAddSlot() {

	let w = listTimeslots;

	let slots = [];
	for(let i = 0; i < w.model.count; ++i)
	{
		slots.push(w.model.get(i).slot);
	}
	dlgAddTime.excludeSlots = slots;


	dlgAddTime.handleOnAccepted = ($$element) => {

		cfgAdapter.newTimeslotFor_clone(act_desktop, $$element.slot, w.model.get(w.currentIndex).slot);

		timetable__modelInsertElement($$element);
	};


	dlgAddTime.open();
}

function timetable__removeSlot() {

	let w = listTimeslots;

	cfgAdapter.deleteTimeslot(act_desktop, w.model.get(w.currentIndex).slot);

	w.model.remove(w.currentIndex);

	w.currentIndex = Math.max(0, w.currentIndex - 1);
}

																				// p r o p e r t i e s

																				// p r o p e r t i e s

																				// p r o p e r t i e s

function properties__selectColor($target) {

	dlgSelectColor.color = $target.selectedColor;


	dlgSelectColor.handleOnAccepted = ($$color) => {

		$target.selectedColor = $$color;
	};


	dlgSelectColor.open();
}

																				// p i c t u r e s o u r c e s

																				// p i c t u r e s o u r c e s

																				// p i c t u r e s o u r c e s
function picturesources__removeSource($index) {

	let w = listPicturesources;

	w.model.remove($index);
	--w.changeFlag;
}

function picturesources__addPathWith($$dlg) {

	let w = listPicturesources;

	$$dlg.handleOnAccepted = ($$resultUrls) => {

		for(let i=0; i<$$resultUrls.length; ++i)
		{
			let desanitized = JS.FILENAME_FROM_URISAFE($$resultUrls[i]);
			w.model.append({ path: desanitized });
		}
		++w.changeFlag;
	};


	$$dlg.open();
}

function picturesources__addUrl() {

	let w = listPicturesources;

	dlgAddUrl.handleOnAccepted = ($$text) => {

		w.model.append({ path: $$text });
		++w.changeFlag;
	};


	dlgAddUrl.open();
}

function picturesources__updateButtonState() {

	let m = listPicturesources.model;

	btnAddFolder.enabled = ! (m.count > 0 && m.get(0).path.startsWith('http'));
	btnAddFiles.enabled = btnAddFolder.enabled;

	btnAddUrl.enabled = ! m.count > 0;
}

																				// d l g A d d D e s k t o p

																				// d l g A d d D e s k t o p

																				// d l g A d d D e s k t o p

Dialog {
	id: dlgAddDesktop

	width: parent.width * 0.6

	title: 'Add desktop config'
  standardButtons: Dialog.Ok | Dialog.Cancel

  property var excludeNos

  property var handleOnAccepted
  onAccepted: handleOnAccepted(comboDesktopCfgs.model[comboDesktopCfgs.currentIndex])

  onVisibleChanged: {

  	if(!visible)
  		return;
  		// <--


			let m = [];
			for(let i=0; i<kWindowSystem.numberOfDesktops; ++i)
      {
      	let no = i+1;
      	if(excludeNos.includes(no))
      		continue;
      		// <--


      	m.push(util__buildElementDesktopList(no));
			}
			comboDesktopCfgs.model = m;
		}

	ComboBox {
		id: comboDesktopCfgs
		width: parent.width
	}
}

																				// d l g A d d T i m e

																				// d l g A d d T i m e

																				// d l g A d d T i m e

Dialog {
	id: dlgAddTime

	width: parent.width * 0.5

	title: 'Add time'
  standardButtons: Dialog.Cancel

  property var excludeSlots: []
  property string newSlot

  property var handleOnAccepted
  onAccepted: handleOnAccepted(util__buildElementTimetable(newSlot))

  Component.onCompleted: initModels();

  onVisibleChanged: {

  	if(!visible)
  		return;
  		// <--


		buildNewSlot();
		}

	RowLayout {

		ComboBox {
			id: comboHour

			onCurrentIndexChanged: dlgAddTime.buildNewSlot();
		}

		Label {
    	text: ':'
		}

		ComboBox {
			id: comboMinute

			onCurrentIndexChanged: dlgAddTime.buildNewSlot();
		}

		Button {
			id: btnAdd
			Layout.preferredWidth: root.mySmallButtonWidth
  		text: 'Add'

  		onClicked: dlgAddTime.accept()
		}
  }

  function initModels() {

  	let mh = [];
  	for(let i = 0; i < 24; ++i)
  	{
  		let text = ('00'+i).slice(-2);
  		mh.push({'text': text});
  	}
  	comboHour.model = mh;

		let mm = [];
  	for(let i = 0; i < 60; ++i)
  	{
  		let text = ('00'+i).slice(-2);
  		mm.push({'text': text});
  	}
  	comboMinute.model = mm;
  }

  function buildNewSlot() {

  	if(comboHour.currentIndex < 0 || comboMinute.currentIndex < 0)
  		return;
  		//<--


  	let hh = comboHour.model[comboHour.currentIndex].text;
  	let mm = comboMinute.model[comboMinute.currentIndex].text;

  	newSlot = hh + ':' + mm;
  	btnAdd.enabled = !excludeSlots.includes(newSlot);
  }
}

																				// d l g S e l e c t C o l o r

																				// d l g S e l e c t C o l o r

																				// d l g S e l e c t C o l o r

ColorDialog {
	id: dlgSelectColor

  title: "Select color"
  modality: Qt.WindowModal
  showAlphaChannel: myConnector === plasmoid

  property var handleOnAccepted
  onAccepted: handleOnAccepted(color)
}

																				// d l g F o l d e r

																				// d l g F o l d e r

																				// d l g F o l d e r
FileDialog {
  	id: dlgAddFolder
		title: "Choose a folder"
    selectFolder: true

	  property var handleOnAccepted
  	onAccepted: handleOnAccepted(fileUrls)
	}

																				// d l g F i l e s

																				// d l g F i l e s

																				// d l g F i l e s
	FileDialog {
  	id: dlgAddFiles
		title: "Choose files"
    selectExisting: true
    selectMultiple: true

	  property var handleOnAccepted
  	onAccepted: handleOnAccepted(fileUrls)
	}

																				// d l g A d d U r l

																				// d l g A d d U r l

																				// d l g A d d U r l

Dialog {
	id: dlgAddUrl

	width: parent.width * 0.6

	title: 'Use Url'
  standardButtons: Dialog.Ok | Dialog.Cancel

  property var handleOnAccepted
  onAccepted: handleOnAccepted(tfUrl.text);

	TextField {
		id: tfUrl
		focus: dlgAddUrl.visible

		anchors.fill: parent
	}
}

																				//

																				//

																				//
// root
}
