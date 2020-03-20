using Toybox.Application;
using Toybox.System;
using Toybox.Math;
using Toybox.Time;
using Toybox.Time.Gregorian;

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
			value = rawData/100000.0;
		}else if (unit == 1){ /*mile*/
			value = rawData/160934.4;
		}
		return value.format("%.2f");
	}

	function elevation(rawData){
		var value = rawData;//meters
		var unit =  Application.Properties.getValue("ELU");
		if (unit == 1){ /*foot*/
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
		}else if (unit == 4){ /*ft/s*/
			value = getBeaufort(rawData);
		}
		return value;
	}

	function getBeaufort(rawData){
		if(rawData >= 33){
			return 12;
		}else if(rawData >= 28.5){
			return 11;
		}else if(rawData >= 24.5){
			return 10;
		}else if(rawData >= 20.8){
			return 9;
		}else if(rawData >= 17.2){
			return 8;
		}else if(rawData >= 13.9){
			return 7;
		}else if(rawData >= 10.8){
			return 6;
		}else if(rawData >= 8){
			return 5;
		}else if(rawData >= 5.5){
			return 4;
		}else if(rawData >= 3.4){
			return 3;
		}else if(rawData >= 1.6){
			return 2;
		}else if(rawData >= 0.3){
			return 1;
		}else {
			return 0;
		}
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
		}else if (unit == 4){ /*ft/s*/
			value = Application.loadResource(Rez.Strings.SpeedUnitBof);
		}
		return value;
	}

    function moonPhase(now)
    {
    	//var now = Time.now();
        var date = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        // date.month, date.day date.year

		var n0 = 0;
		var f0 = 0.0;
		var AG = f0;

		//current date
	    var Y1 = date.year;
	    var M1 = date.month;
	    var D1 = date.day;

	    var YY1 = n0;
	    var MM1 = n0;
	    var K11 = n0;
	    var K21 = n0;
	    var K31 = n0;
	    var JD1 = n0;
	    var IP1 = f0;
	    var DP1 = f0;

	    // calculate the Julian date at 12h UT
	    YY1 = Y1 - ( ( 12 - M1 ) / 10 ).toNumber();
	    MM1 = M1 + 9;
	    if( MM1 >= 12 ) {
	    	MM1 = MM1 - 12;
	    }
	    K11 = ( 365.25 * ( YY1 + 4712 ) ).toNumber();
	    K21 = ( 30.6 * MM1 + 0.5 ).toNumber();
	    K31 = ( ( ( YY1 / 100 ) + 49 ).toNumber() * 0.75 ).toNumber() - 38;

	    JD1 = K11 + K21 + D1 + 59;                  // for dates in Julian calendar
	    if( JD1 > 2299160 ) {
	    	JD1 = JD1 - K31;        				// for Gregorian calendar
		}

	    // calculate moon's age in days
	    IP1 = normalize( ( JD1 - 2451550.1 ) / 29.530588853 );
	    var AG1 = IP1*29.53;

		return AG1.toNumber();

    }

    function normalize( v )
	{
	    v = v - v.toNumber();
	    if( v < 0 ) {
	        v = v + 1;
		}
	    return v;
	}

	function stringReplace(str, find, replace){
		var res = "";
		var ind = str.find(find);
		var len = find.length();
		var first;
		while (ind != null){
			if (ind == 0) {
				first = "";
			} else {
				first = str.substring(0, ind);
			}
			res = res + first + replace;
			str = str.substring(ind + len, str.length());
			ind = str.find(find);
		}
		res = res + str;
		return res;
	}

	function weekOfYear(moment){

		var momentInfo = Gregorian.info(moment, Gregorian.FORMAT_SHORT);
		var jan1 = 	Gregorian.moment(
			{
				:year => momentInfo.year,
				:month => 1,
				:day =>1,
			}
		);

		var jan1DayOfWeek = Gregorian.info(jan1, Gregorian.FORMAT_SHORT).day_of_week;
		jan1DayOfWeek = jan1DayOfWeek == 1 ? 7 : jan1DayOfWeek - 1;

		if (jan1DayOfWeek < 5){

			var beginMoment = jan1;
			if (jan1DayOfWeek > 1){
				beginMoment = Gregorian.moment(
					{
						:year => momentInfo.year-1,
						:month => 12,
						:day =>33-jan1DayOfWeek,
					}
				);
			}
			return 1 + beginMoment.subtract(moment).value()/(Gregorian.SECONDS_PER_DAY*7);
		} else{

			return weekOfYear(
				Gregorian.moment(
					{
						:year => momentInfo.year-1,
						:month => 12,
						:day =>31,
					}
				)
			);
		}
	}

	function min(a,b){
	 if(a>b){
	 	return b;
	 } else {
	 	return a;
	 }
	}

}