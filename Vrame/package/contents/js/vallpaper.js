const CHARMAP_TEXT_URI={"txt": "%", "uri": "%25"};

const CFG_DESKNO_DEFAULT = 0;

const SLOTMARKER_DEFAULT = '00:00';

const JSON_TIMESLOTMARKER_DEFAULT = `{
	"slotmarker": "` + SLOTMARKER_DEFAULT + `",
	"background": "#1d1d85",
	"borderTop": 0,
	"borderBottom": 0,
	"borderLeft": 0,
	"borderRight": 0,
	"fillMode": 1,
	"desaturate": 0,
	"blur": 0,
	"colorize": 0,
	"colorizeColor": "#ffffff",
	"colorizeValue": "#00ffffff",
	"interval": 0,
	"shuffle": 0,
	"imagesources": []
}`;

const JSON_CFG_DEFAULT = '{ "deskNo": 0, "timeslots": { "' + SLOTMARKER_DEFAULT + '": ' + JSON_TIMESLOTMARKER_DEFAULT + ' }}';

class CfgAdapter {

	constructor($cfgJSONs, $fOnPropagateChange=undefined) {

		this.fOnPropagateChange = $fOnPropagateChange;

    this.desktopCfgs = [];

    this.initCfgs($cfgJSONs);
	}

	initCfgs($cfgJSONs) {

  	for(let $$cfgJSON of $cfgJSONs)
    {
    	let cfg=new DesktopCfg($$cfgJSON);

      this.addCfg(cfg);
		}

		if(!this.desktopCfgs.length)
		{
			this.addCfg(new DesktopCfg(JSON_CFG_DEFAULT));
			this.propagateChange();
		}
	}

  propagateChange($fChange=undefined) {

  	if($fChange) { $fChange(); }


		let newCfgJSONs=[];

		for(let cfg of this.getCfgs())
		{
			newCfgJSONs.push(JSON.stringify(cfg));
		}


		if(this.fOnPropagateChange) { this.fOnPropagateChange(newCfgJSONs); }
	}

	newCfgFor_clone($no, $srcNo) {

		this.addCfg(this.getCfg($srcNo).cloneAs($no));
		this.propagateChange();
	}

  deleteCfg($no) {

  	this.desktopCfgs.splice($no, 1);
		this.propagateChange();
	}

  getCfgs() {

  			// ev. sparse array
    return this.desktopCfgs.filter(($$cfg) => { return $$cfg!==undefined});
	}

	addCfg($cfg) {

		this.desktopCfgs[$cfg.deskNo] = $cfg;
	}

	getCfg($no) {

  	return this.desktopCfgs[$no];
 	}

	findAppropiateCfg($no) {

  	return this.desktopCfgs[$no]!==undefined?this.desktopCfgs[$no]:this.desktopCfgs[CFG_DESKNO_DEFAULT];
 	}

	newTimeslotFor_clone($deskCfg, $slot, $srcSlot) {

		$deskCfg.timeslots[$slot] = $deskCfg.timeslots[$srcSlot].cloneAs($slot);
		this.propagateChange();
	}

	deleteTimeslot($deskCfg, $slot) {

		delete $deskCfg.timeslots[$slot];
		this.propagateChange();
	}
}


class DesktopCfg {

	constructor($json) {

		let o = JSON.parse($json);

		Object.assign(this, o);


		let timeslotKeys = Object.keys(this.timeslots);
		for(let $$key of timeslotKeys)
		{
			this.timeslots[$$key] = new TimeslotCfg(this.timeslots[$$key]);
		}
	}

	cloneAs($no) {

		let clone = new DesktopCfg(JSON.stringify(this));
		clone.deskNo = $no;

		return clone;
	}

	getTimeslot($slot) {

		return this.timeslots[$slot];
	}

	findAppropiateTimeslotCfg_now() {

		let d = new Date();
		let nowSlot = ('00' + d.getHours()).slice(-2) + ':' + ('00' + d.getMinutes()).slice(-2);

		let keys = Object.keys(this.timeslots).sort();

		let hit = SLOTMARKER_DEFAULT;

		for(let $$key of keys)
		{
			if($$key > nowSlot)
			{
				break;
			}

			hit = $$key;
		}

		return this.timeslots[hit];
	}

	getTimeslotCfgs() {

		let keys = Object.keys(this.timeslots).sort();

		let result = [];

		for(let $$key of keys)
		{
			result.push(this.timeslots[$$key]);
		}

		return result;
	}
}

class TimeslotCfg {

	constructor($template) {

		Object.assign(this, $template);
	}

	cloneAs($slotmarker) {

		let clone = new TimeslotCfg(this);
		clone.slotmarker = $slotmarker;

		return clone;
	}
}

//
// Global functions
//

let FILENAME_TO_URISAFE=function(name) {

	let result = name;

	result = result.replace(new RegExp(CHARMAP_TEXT_URI.txt,"g"), CHARMAP_TEXT_URI.uri);

	return result;
}

let FILENAME_FROM_URISAFE=function(name) {

	let result = name;

	result = result.replace(new RegExp(CHARMAP_TEXT_URI.uri,"g"), CHARMAP_TEXT_URI.txt);

	return result;
}
