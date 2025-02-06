const DESKNO_DEFAULT = 0;

const SLOTMARKER_DEFAULT = '00:00';

const TIMESLOT_DEFAULT_jsonstr = `{
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

const DESKCFG_DEFAULT_jsonstr = `{
  "deskNo": ` + DESKNO_DEFAULT + `, 
  "timeslots": { 
    "` + SLOTMARKER_DEFAULT + `": ` + TIMESLOT_DEFAULT_jsonstr + ` 
    }
  }`;

// P l a s m a c f g A d a p t e r  
// P l a s m a c f g A d a p t e r  
// P l a s m a c f g A d a p t e r  
class PlasmacfgAdapter {

	constructor($plasmacfg_jsonstrs, $fAfterPropagateChange=undefined) {

    this.deskCfgs = [];
		this.fAfterPropagateChange = $fAfterPropagateChange;

    if($plasmacfg_jsonstrs.length>0)
    {
      for(const $$deskCfg_jsonstr of $plasmacfg_jsonstrs)
      {
        this.addCfg(new DeskCfg($$deskCfg_jsonstr));
      }
    }
    else
    {
			this.addCfg(new DeskCfg(DESKCFG_DEFAULT_jsonstr));
			this.propagateChange();      
    }
	}

  propagateChange($fBeforePropagateChange=undefined) {

  	if($fBeforePropagateChange) { $fBeforePropagateChange(); }


		const newCfgJSONs=[];

		for(const cfg of this.getCfgs())
		{
			newCfgJSONs.push(JSON.stringify(cfg));
		}


		if(this.fAfterPropagateChange) { this.fAfterPropagateChange(newCfgJSONs); }
	}

	newCfgForNo_cloneNo($newNo, $cloneNo) {

		this.addCfg(this.getCfgForNo($cloneNo).cloneAsNo($newNo));
		this.propagateChange();
	}

  deleteCfgNo($no) {

  	this.deskCfgs.splice($no, 1);
		this.propagateChange();
	}

  getCfgs() {

  			// ev. sparse array
    return this.deskCfgs.filter(($$cfg) => { return $$cfg!==undefined});
	}

	addCfg($cfg) {

		this.deskCfgs[$cfg.deskNo] = $cfg;
	}

	getCfgForNo($no) {

  	return this.deskCfgs[$no];
 	}

	findAppropiateCfgForNo($no) {

  	return this.deskCfgs[$no]!==undefined?this.deskCfgs[$no]:this.deskCfgs[DESKNO_DEFAULT];
 	}

	atCfg_newTimeslotForMarker_cloneMarker($deskCfg, $slotmarker, $cloneSlotmarker) {

		$deskCfg.timeslots[$slotmarker] = $deskCfg.timeslots[$cloneSlotmarker].cloneAsNo($slotmarker);
		this.propagateChange();
	}

	atCfg_deleteTimeslot($deskCfg, $slotmarker) {

		delete $deskCfg.timeslots[$slotmarker];
		this.propagateChange();
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
			this.timeslots[$$key] = new TimeslotCfg(this.timeslots[$$key]);
		}
	}

	cloneAsNo($newNo) {

		const clone = new DeskCfg(JSON.stringify(this));
		clone.deskNo = $newNo;

		return clone;
	}

	getTimeslotForMarker($marker) {

		return this.timeslots[$marker];
	}

	getCurrentAppropiateTimeslot() {

		const d = new Date();
		const nowSlot = ('00' + d.getHours()).slice(-2) + ':' + ('00' + d.getMinutes()).slice(-2);

		const markers = Object.keys(this.timeslots).sort();

		let appropiateMarker = SLOTMARKER_DEFAULT;

		for(const $$marker of markers)
		{
			if($$marker > nowSlot)
			{
				break;
			}

			appropiateMarker = $$marker;
		}

		return this.timeslots[appropiateMarker];
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
}

// T i m e s l o t C f g
// T i m e s l o t C f g
// T i m e s l o t C f g
class TimeslotCfg {

	constructor($template) {

		Object.assign(this, $template);
	}

	cloneAsNo($slotmarker) {

		let clone = new TimeslotCfg(this);
		clone.slotmarker = $slotmarker;

		return clone;
	}
}


// G l o b a l   f u n c t i o n s
// G l o b a l   f u n c t i o n s
// G l o b a l   f u n c t i o n s
const AS_URISAFE = function($text, $asUriSafe=true) {

  const target = $asUriSafe?"%":"%25";
  const replacement = $asUriSafe?"%25":"%";

  const result = $text.replace(new RegExp(target, "g"), replacement);

  return result;
}