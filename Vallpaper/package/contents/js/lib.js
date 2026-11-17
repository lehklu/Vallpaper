/*
 *  Copyright 2026  Werner Lechner <werner.lechner@lehklu.at>
 */

const KDE_IMAGEBACKEND_SLIDETIMER_MAXVALUE = 604800; // 1 week  ?Found by trial&error?

const MILLIS_TO_NEXT_MIN_ms = 100;
const MILLIS_TO_NEXT_DEJITTER_ms = 200;

const DESKNO_GLOBAL = 0;
const DESKNO_GLOBAL_NAME = '*';

const TIMESLOT_MARKER_DEFAULT = '00:00';

const TIMESLOT_DEFAULT_jsonstr = `{
	"slotmarker": "` + TIMESLOT_MARKER_DEFAULT + `",
	"background": "#071169",
	"displayCurrentSource": false,
	"paddingTop": 0,
	"paddingBottom": 0,
	"paddingLeft": 0,
	"paddingRight": 0,
	"fillMode": 1,
	"saturatePct": 100,
	"blurPct": 0,
	"colorizePct": 0,
	"colorizeColor": "#ffffff",
	"interval": 0,
	"shuffleMode": 0,
	"imagesources": []
}`;

const DESKCFG_DEFAULT_jsonstr = `{
  "deskNo": ` + DESKNO_GLOBAL + `,
  "timeslots": {
    "` + TIMESLOT_MARKER_DEFAULT + `": ` + TIMESLOT_DEFAULT_jsonstr + `
    }
  }`;

// P l a s m a c f g A d a p t e r
// P l a s m a c f g A d a p t e r
// P l a s m a c f g A d a p t e r
class PlasmacfgAdapter {

	constructor($plasmacfg_jsonstrs, $cfgChangedCallback=undefined) {

    this.deskCfgs = new Map();
		this.fCfgChangedCallback = $cfgChangedCallback;

    if(!$plasmacfg_jsonstrs || $plasmacfg_jsonstrs.length === 0)
    {
			this.addCfg(new DeskCfg(DESKCFG_DEFAULT_jsonstr));
    }
    else
    {
      $plasmacfg_jsonstrs.forEach($$deskCfg_jsonstr => { this.addCfg(new DeskCfg($$deskCfg_jsonstr)); });
    }
	}

  propagateCfgChange_preprocess($preprocessCallback=undefined) {

  	if($preprocessCallback) { $preprocessCallback(); }

		if( ! this.fCfgChangedCallback) { return; }
    //<--


    const newCfgJSONs = this.getCfgs().map($$cfg =>  JSON.stringify($$cfg));

    this.fCfgChangedCallback(newCfgJSONs);
	}

	newCfgForDeskNo_cloneDeskNo($newDeskNo, $cloneDeskNo) {

		this.addCfg(this.getCfgForDeskNo($cloneDeskNo).cloneAs($newDeskNo));
		this.propagateCfgChange_preprocess();
	}

  deleteCfgDeskNo($deskNo) {

  	this.deskCfgs.delete($deskNo);
		this.propagateCfgChange_preprocess();
	}

  getCfgs() {

    return Array.from(this.deskCfgs.values());
	}

	addCfg($cfg) {

		this.deskCfgs.set($cfg.deskNo, $cfg);
	}

	getCfgForDeskNo($deskNo) {

    return this.deskCfgs.get($deskNo);
 	}

	ensureCfgForDeskNo($deskNo) {

  		return this.getCfgForDeskNo($deskNo) || this.deskCfgs.get(DESKNO_GLOBAL);
 	}

	atCfg_newTimeslotForMarker_cloneMarker($deskCfg, $slotmarker, $cloneSlotmarker) {

		$deskCfg.timeslots[$slotmarker] = $deskCfg.timeslots[$cloneSlotmarker].cloneAs($slotmarker);
		this.propagateCfgChange_preprocess();
	}

	atCfg_deleteTimeslot($deskCfg, $slotmarker) {

		delete $deskCfg.timeslots[$slotmarker];
		this.propagateCfgChange_preprocess();
	}
}

// D e s k t o p C f g
// D e s k t o p C f g
// D e s k t o p C f g
class DeskCfg {

	constructor($json) {

		const o = JSON.parse($json);

		Object.assign(this, o);


		const timeslotKeys = Object.keys(this.timeslots);
		for(const $$key of timeslotKeys)
		{
			this.timeslots[$$key] = new TimeslotCfg(this.timeslots[$$key]); // replace object with TimeslotCfg instance
		}
	}

	cloneAs($newDeskNo) {

		const clone = new DeskCfg(JSON.stringify(this));
		clone.deskNo = $newDeskNo;

		return clone;
	}

	getTimeslotForSlotmarker($slotmarker) {

		return this.timeslots[$slotmarker];
	}

	findNowActiveTimeslotCfg() {

    const now = new Date();
    const nowSlotmarker = ('00' + now.getHours()).slice(-2) + ':' + ('00' + now.getMinutes()).slice(-2);
    const orderedSlotmarkers = Object.keys(this.timeslots).sort();

		const appropiateSlotmarker = orderedSlotmarkers.reverse().find($$slotmarker => $$slotmarker <= nowSlotmarker);

		return this.timeslots[appropiateSlotmarker];
	}

  getOrderedTimeslots() {

		const keys = Object.keys(this.timeslots).sort();
		const result = [];

		for(const $$key of keys)
		{
			result.push(this.timeslots[$$key]);
		}

		return result;
	}

	getMillisToNextTimeslot($baseSlotmarker) {

		const orderedSlotmarkers = Object.keys(this.timeslots).sort();
		if(orderedSlotmarkers.length === 1) { return Infinity; } // no slot to change
    //<--


		let nextSlotmarker = orderedSlotmarkers.find($$slotmarker => $$slotmarker > $baseSlotmarker);

		const nextDate = new Date();
    const nowTime = nextDate.getTime(); // Reihenfolge ^~v
    if(!nextSlotmarker) { nextDate.setDate(nextDate.getDate() + 1); }
    const parts_HHmm = !nextSlotmarker?orderedSlotmarkers[0].split(':'):nextSlotmarker.split(':');
    nextDate.setHours(parseInt(parts_HHmm[0], 10), parseInt(parts_HHmm[1], 10), 0, 0);

		const delta = nextDate.getTime() - nowTime;
		return Math.max(MILLIS_TO_NEXT_MIN_ms, MILLIS_TO_NEXT_DEJITTER_ms + delta);
	}
}

// T i m e s l o t C f g
// T i m e s l o t C f g
// T i m e s l o t C f g
class TimeslotCfg {

	constructor($template) {

		Object.assign(this, $template);
	}

	cloneAs($slotmarker) {

		const clone = new TimeslotCfg(this);
		clone.slotmarker = $slotmarker;

		return clone;
	}
}


// G l o b a l   f u n c t i o n s
// G l o b a l   f u n c t i o n s
// G l o b a l   f u n c t i o n s

const IS_USE_URL = function($imagesources) {

	return $imagesources.length===1 && ($imagesources[0].startsWith('http') || $imagesources[0].startsWith('file://'));
}

const GET_URL = function($imagesources) {

  return $imagesources[0];
}

const IS_PER_SCREEN_SUPPORTED = function($VirtualDesktopInfo) {

  return typeof $VirtualDesktopInfo.currentDesktopByScreenName === 'function';
}

const GET_CURRENT_DESKNO = function($VirtualDesktopInfo, $screenName) {

  const currentId = ($screenName && IS_PER_SCREEN_SUPPORTED($VirtualDesktopInfo)) ?
      $VirtualDesktopInfo.currentDesktopByScreenName($screenName) :
      $VirtualDesktopInfo.currentDesktop;

  const ids = $VirtualDesktopInfo.desktopIds;
  const idx = ids.indexOf(currentId);

  return idx+1;
}

const CFG_602_FROM_601 = function($cfg601) {

  if( ! $cfg601 || $cfg601.length === 0) { return []; }
  //<--


  const result = [];
  for(const $$deskCfg_jsonstr of $cfg601)
  {
    const deskCfg = JSON.parse($$deskCfg_jsonstr);

    for(const $$slotmarker of Object.keys(deskCfg.timeslots))
    {
      const timeslot = deskCfg.timeslots[$$slotmarker];

      if('displayCurrentSource' in timeslot)
      {
        timeslot.displayCurrentSource = timeslot.displayCurrentSource===1;
      }

      if('desaturate' in timeslot)
      {
        timeslot.saturatePct = 100 - Math.round(timeslot.desaturate * 100);
        delete timeslot.desaturate;
      }

      if('blur' in timeslot)
      {
        timeslot.blurPct = Math.round(timeslot.blur * 100);
        delete timeslot.blur;
      }

      if('colorize' in timeslot)
      {
        timeslot.colorizePct = Math.round(timeslot.colorize * 100);
        delete timeslot.colorize;
      }

      if('colorizeValue' in timeslot)
      {
        delete timeslot.colorizeValue;
      }
    }

    result.push(JSON.stringify(deskCfg));
  }

  return result;
}