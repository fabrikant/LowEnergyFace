using Toybox.Application;
using Toybox.System;
using Toybox.Math;

module Converter {

	function pressure(rawData){

		var value = rawData; /*Pa */
		var unit  = Application.Properties.getValue("PrU");

		if (unit == 0){ /*MmHg*/
			value = Math.round(rawData/133.322).format("%d");
		}else if (unit == 1){ /*Psi*/
			value = Math.round(rawData/6894.757).format("%d");
		}else if (unit == 2){ /*InchHg*/
			value = Math.round(rawData/3386.389).format("%d");
		}else if (unit == 3){ /*bar*/
			value = (rawData/100000).format("%d");
		}else if (unit == 4){ /*kPa*/
			value = (rawData/1000).format("%d");
		}else if (unit == 5){ /*hPa*/
			value = (rawData/100).format("%d");
		}

		return value;
	}

	function temperature(rawData){

		var value = rawData;/*C*/
		var unit  = Application.Properties.getValue("TU");
		if (unit == 1){ /*F*/
			value = ((rawData*9/5) + 32);
		}else if (unit == 2){ /*K*/
			value = Math.round(rawData+273.15);
		}
		return value.format("%d");
	}

	function distance(rawData){
		var value = rawData;//santimeters
		var unit =  Application.Properties.getValue("DU");
		if (unit == 0){ /*km*/
			value = rawData/100000;
		}else if (unit == 1){ /*mile*/
			value = rawData/160934.4;
		}
		return value.format("%.1f");
	}

	function elevation(rawData){

		var value = rawData;//meters
		var unit =  Application.Properties.getValue("EU");

		if (unit == 1){ /*ft*/
			value = rawData*3.281;
		}

		return value;
	}

	function speed(rawData){

		var value = rawData;//meters/sec
		var unit =  Application.Properties.getValue("WU");

		if (unit == 1){ /*km/h*/
			value = rawData*3.6;
		}else if (unit == 2){ /*mile/h*/
			value = rawData*2.237;
		}else if (unit == 3){ /*ft/s*/
			value = rawData*3.281;
		}
		return value;
	}

	function speedUnitName(){

		var value = Application.loadResource(Rez.Strings.SpeedUnitMSec);//meters/sec
		var unit =  Application.Properties.getValue("WU");

		if (unit == 1){ /*km/h*/
			value = Application.loadResource(Rez.Strings.SpeedUnitKmH);
		}else if (unit == 2){ /*mile/h*/
			value = Application.loadResource(Rez.Strings.SpeedUnitMileH);
		}else if (unit == 3){ /*ft/s*/
			value = Application.loadResource(Rez.Strings.SpeedUnitFtSec);
		}
		return value;

	}
}