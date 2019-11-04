using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Math;
using Toybox.SensorHistory;
using Toybox.ActivityMonitor;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Position;
using Toybox.Activity;

class DataField extends WatchUi.Layer {

	enum{
		FIELD_TYPE_EMPTY,
		FIELD_TYPE_BAT,
		FIELD_TYPE_HR,
		FIELD_TYPE_STEPS,
		FIELD_TYPE_PRESSURE,
		FIELD_TYPE_TEMPERATURE,
		FIELD_TYPE_CALORIES,
		FIELD_TYPE_DISTANCE,
		FIELD_TYPE_FLOOR,
		FIELD_TYPE_ELEVATION,
		FIELD_TYPE_SUN_EVENT,
		FIELD_TYPE_SUNRISE,
		FIELD_TYPE_SUNSET,
		FIELD_TYPE_MOON_PHASE,
	}
	const imageText = {
		FIELD_TYPE_HR          => "g",
		FIELD_TYPE_STEPS       => "l",
		FIELD_TYPE_PRESSURE    => "b",
		FIELD_TYPE_TEMPERATURE => "p",
		FIELD_TYPE_CALORIES    => "d",
		FIELD_TYPE_DISTANCE    => "e",
		FIELD_TYPE_FLOOR       => "f",
		FIELD_TYPE_ELEVATION   => "j",
		FIELD_TYPE_SUN_EVENT   => "m",
		FIELD_TYPE_SUNRISE     => "n",
		FIELD_TYPE_SUNSET      => "o",
	};
	const fieldSignatures = {
		FIELD_TYPE_HR          => "Hr",
		FIELD_TYPE_STEPS       => "St",
		FIELD_TYPE_PRESSURE    => "Pr",
		FIELD_TYPE_TEMPERATURE => "T",
		FIELD_TYPE_CALORIES    => "C",
		FIELD_TYPE_DISTANCE    => "D",
		FIELD_TYPE_FLOOR       => "F",
		FIELD_TYPE_ELEVATION   => "EL",
		FIELD_TYPE_SUN_EVENT   => "SE",
		FIELD_TYPE_SUNRISE     => "SR",
		FIELD_TYPE_SUNSET      => "SS",
	};
	const font = Graphics.FONT_XTINY;
	private var mImageFont;
	private var mWidth, mHeight, oldValue = null, backgroundColor = null, type = null;


    function initialize(params) {
    	mWidth = params.get(:w);
    	mHeight = params.get(:h);
		mImageFont = params.get(:imageFont);
        var iniParams = {
        	:locX => params.get(:x),
        	:locY => params.get(:y),
        	:width => mWidth,
        	:height => mHeight,
        	:identifier => params.get(:id)
        };
        Layer.initialize(iniParams);
    }

	function draw(settingsChanged){
		if (type == null || settingsChanged) {
			type = Application.Properties.getValue("F"+getId());
		}
		if (backgroundColor == null || settingsChanged){
			var bkGndColorId = "BkGdCol";
			if (getId() == 1){
				backgroundColor = Application.Properties.getValue(bkGndColorId+"1");
			} else {
				backgroundColor = Application.Properties.getValue(bkGndColorId+"3");
			}
		}
		if (type == FIELD_TYPE_EMPTY && settingsChanged){
			var targetDc = getDc();
			targetDc.setColor(Graphics.COLOR_TRANSPARENT, backgroundColor);
        	targetDc.clear();
		}else if (type == FIELD_TYPE_EMPTY){
			//Do nothing, its required
		///////////////////////////////////////////////////////////////////
		//BATTERY
		}else if (type == FIELD_TYPE_BAT){
			drawBattery(settingsChanged);
		///////////////////////////////////////////////////////////////////
		//MOON PHASE
		}else if (type == FIELD_TYPE_MOON_PHASE){
			drawMoonPhase(settingsChanged);
		///////////////////////////////////////////////////////////////////
		//ALL SIMPLE FIELDS
		}else {
			var value = "";
			///////////////////////////////////////////////////////////////////
			//HEART RATE
			if (type == FIELD_TYPE_HR){
				value = null;
				var info = Activity.getActivityInfo();
				if (info != null){
					value = info.currentHeartRate;
				}
				if (value == null){
					var iter = SensorHistory.getHeartRateHistory({:period =>1, :order => SensorHistory.ORDER_NEWEST_FIRST});
					if (iter != null){
						var sample = iter.next();
						if (sample != null){
							if (sample.data != null){
								value = sample.data.toString();
							}
						}
					}
				}
				if (value == null) {
					value = "";
				}
			///////////////////////////////////////////////////////////////////
			//STEPS
			}else if (type == FIELD_TYPE_STEPS){
				value = ActivityMonitor.getInfo().steps;
				if (value > 9999){
					value = (value/1000).format("%.1f")+"k";
				}
			///////////////////////////////////////////////////////////////////
			//PRESSURE
			}else if (type == FIELD_TYPE_PRESSURE){
				value = null;
				var info = Activity.getActivityInfo();
				if (info != null){
					if (info.ambientPressure != null){
						value = Converter.pressure(info.ambientPressure);
					}
				}
				if (value == null){
					var iter = SensorHistory.getPressureHistory({:period =>1, :order => SensorHistory.ORDER_NEWEST_FIRST});
					if (iter != null){
						var sample = iter.next();
						if (sample != null){
							if (sample.data != null){
								value = Converter.pressure(sample.data);
							}
						}
					}
				}
				if (value == null) {
					value = "";
				}
			///////////////////////////////////////////////////////////////////
			//TEMPERATURE
			}else if (type == FIELD_TYPE_TEMPERATURE){
				value = "";
				var iter = SensorHistory.getTemperatureHistory({:period =>1, :order => SensorHistory.ORDER_NEWEST_FIRST});
				if (iter != null){
					var sample = iter.next();
					if (sample != null){
						if (sample.data != null){
							value = Converter.temperature(sample.data);
						}
					}
				}
			///////////////////////////////////////////////////////////////////
			//CALORIES
			}else if (type == FIELD_TYPE_CALORIES){

				value = ActivityMonitor.getInfo().calories;

			///////////////////////////////////////////////////////////////////
			//DISTANCE

			}else if (type == FIELD_TYPE_DISTANCE){

				value = Converter.distance(ActivityMonitor.getInfo().distance);
			///////////////////////////////////////////////////////////////////
			//FLOOR
			}else if (type == FIELD_TYPE_FLOOR){

				value = ActivityMonitor.getInfo().floorsClimbed;
			///////////////////////////////////////////////////////////////////
			//ELEVATION
			}else if (type == FIELD_TYPE_ELEVATION){
				value = null;

				var info = Activity.getActivityInfo();
				if (info != null){
					if (info.altitude != null){
						value = Converter.elevation(info.altitude);
					}
				}
				if (value == null){
					var iter = SensorHistory.getElevationHistory({:period =>1, :order => SensorHistory.ORDER_NEWEST_FIRST});
					if (iter != null){
						var sample = iter.next();
						if (sample != null){
							if (sample.data != null){
								value = Converter.elevation(sample.data);
							}
						}
					}
				}
				if (value == null){
					value = 0;
				}
				if (value > 9999){
					value = (value/1000).format("%.1f")+"k";
				}else{
					value = value.format("%d");
				}
			///////////////////////////////////////////////////////////////////
			//SUNRISE
			}else if (type == FIELD_TYPE_SUNRISE){

				var moment = getSunEvent(SUNRISE, true);
				if (moment == null) {
					value = Application.loadResource(Rez.Strings.gps) +
						Application.loadResource(Rez.Strings.notset);
				} else {
					value = getMomentView(moment);
				}
			///////////////////////////////////////////////////////////////////
			//SUNSET
			}else if (type == FIELD_TYPE_SUNSET){

				var moment = getSunEvent(SUNSET, true);
				if (moment == null) {
					value = Application.loadResource(Rez.Strings.gps) +
						Application.loadResource(Rez.Strings.notset);
				} else {
					value = getMomentView(moment);
				}
			///////////////////////////////////////////////////////////////////
			//SUN EVENT
			}else if (type == FIELD_TYPE_SUN_EVENT){

				var sunset =  getSunEvent(SUNSET, false);
				var now = Time.now().value();
				if(sunset == null){
					value = Application.loadResource(Rez.Strings.gps) +
						Application.loadResource(Rez.Strings.notset);
				}else{
					if (sunset.value() < now){
						value = getMomentView(getSunEvent(SUNRISE, true));
					} else {
						var sunrise = getSunEvent(SUNRISE, false);
						if (now < sunrise.value()){
							value = getMomentView(sunrise);
						}else{
							value = getMomentView(sunset);
						}
					}
				}
			}
			drawOrdinaryField({
					:value => value,
					:propNameColor => fieldSignatures[type]+"Col",
					:imageText => imageText[type],
					:settingsChanged=>settingsChanged});
		}
//		var targetDc = getDc();
//		targetDc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
//		targetDc.drawRectangle(0,0,mWidth,mHeight);
	}

	///////////////////////////////////////////////////////////////////////////
	// SUN EVENTS
	private function getMomentView(moment){
		var info = Gregorian.info(moment,Time.FORMAT_SHORT);
		return info.hour.format("%02d")+":"+info.min.format("%02d");
	}

	private function getSunEvent(event, allowTomorrow){
		var geoLatLong = [Application.Properties.getValue("Lat"),
						  Application.Properties.getValue("Lon")];
		if (geoLatLong[0] == 0 && geoLatLong[1] == 0){
			return null;
		}
		var myLocation = new Position.Location(
		    {
		        :latitude => geoLatLong[0],
		        :longitude => geoLatLong[1],
		        :format => :degrees
		    }
		).toRadians();

		var now = Time.now();
		var d = now.value().toDouble() / Time.Gregorian.SECONDS_PER_DAY - 0.5 + 2440588 - 2451545;
		var cache = Application.getApp().gView.sunEventsCache;
		if (cache[:day] == null){
			var sunEventCalculator = new SunCalc();
			sunEventCalculator.fillCache(cache, now, myLocation[0],myLocation[1]);
		}else if ( !(Math.round(cache[:day]).equals(Math.round(d)) && cache[:lat].equals(myLocation[0]) && cache[:lon].equals(myLocation[1]) )){
			var sunEventCalculator = new SunCalc();
			sunEventCalculator.fillCache(cache, now, myLocation[0],myLocation[1]);
		}
		var eventMoment = cache[event][0];
		if (eventMoment.value() < now.value() && allowTomorrow){
			eventMoment = cache[event][1];
		}

		return eventMoment;
	}

	///////////////////////////////////////////////////////////////////////////
	// MOON PHASE FIELD
	private function drawMoonPhase(settingsChanged){
		var moment = Time.now();
		var day = Time.Gregorian.info(moment, Time.FORMAT_SHORT).day;
		if ((day != oldValue)|| settingsChanged){
			oldValue = day;
			var moonDay = Converter.moonPhase(Time.now());
			var targetDc = getDc();
			targetDc.setColor(Graphics.COLOR_TRANSPARENT, backgroundColor);
        	targetDc.clear();
			targetDc.setColor(Application.Properties.getValue("MPCol"), backgroundColor);
			var font = Application.loadResource(Rez.Fonts.moon);
			var daysPict = {
				0 => "0",
				3 => "1",
				6 => "2",
				9 => "3",
				12 => "4",
				15 => "5",
				18 => "6",
				21 => "7",
				24 => "8",
				27 => "9"
			};
			var wIcon = targetDc.getTextWidthInPixels("5",font);
			var width = mWidth - wIcon;
			var centerToCenter = width/6;
			var y = mHeight/2;
			var firstVisibleDay = moonDay.toNumber() - 3;
			if (firstVisibleDay < 0){
				firstVisibleDay += 29;
			}
			for (var i = 0; i < 7; i += 1){
				var nextDay = firstVisibleDay + i;
				if(nextDay>29){
					nextDay -= 30;
				}
				if (daysPict[nextDay] != null){
					var x = wIcon/2+centerToCenter*i;
					targetDc.drawText(x, y, font, daysPict[nextDay], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
				}
			}
			var t = 1;
			var v = 5;
			targetDc.drawLine(0, mHeight-1, mWidth, mHeight-1);
			targetDc.fillPolygon([[mWidth/2-t,mHeight],[mWidth/2,mHeight-v],[mWidth/2+t,mHeight]]);
		}
	}

	///////////////////////////////////////////////////////////////////////////
	// BATTERY FIELD

	private function drawBattery(settingsChanged){
		var absoluteValue = Math.round(System.getSystemStats().battery);
		if (absoluteValue != oldValue || settingsChanged) {
			//var value = absoluteValue.format("%d")+((absoluteValue<100)?"%":"");
			var value = absoluteValue.format("%d") + "%";
			var targetDc = getDc();
			var color = Application.Properties.getValue("BatCol");
			fillTextPlace(targetDc, backgroundColor);
			targetDc.setColor(color,Graphics.COLOR_TRANSPARENT);
			targetDc.drawText(mHeight+(mWidth-mHeight)/2, mHeight/2, font, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
			//Рисуем батарею
			var bW = mHeight-3;
			var bH = mHeight-8;
			var bY = (mHeight-bH)/2;
			//Первая отрисовка. Рисуем контур батареи
			if(oldValue==null || settingsChanged){
				fillPicturePlace(targetDc, backgroundColor);
				targetDc.setColor(color,Graphics.COLOR_TRANSPARENT);
				targetDc.setPenWidth(2);
				targetDc.drawRectangle(0, bY, bW, bH);
				targetDc.setPenWidth(1);

				var pH = bH/3;
				var pY = bY + (bH-pH)/2;
				targetDc.fillRectangle(bW, pY, 3, pH);
				oldValue = 0;
			}
			//Перерисовывать будем только если заливка должна поменяться.
			var bW100 = bW-5;
			var oldBW = Math.round(bW100*oldValue/100);
			var newBW = Math.round(bW100*absoluteValue/100);

			if (!(newBW==oldBW) || settingsChanged){
				var color = Application.Properties.getValue((absoluteValue > Application.Properties.getValue("BatLPVal")) ? "BatHPCol" : "BatLPCol");
				var innerW = bW-5;
				var innerH = bH-5;
				var innerX = 2;
				var innerY = bY+2;
				targetDc.setColor(backgroundColor,Graphics.COLOR_TRANSPARENT);
				targetDc.fillRectangle(innerX, innerY, bW100, innerH);
				targetDc.setColor(color,Graphics.COLOR_TRANSPARENT);
				targetDc.fillRectangle(innerX, innerY, newBW, innerH);
			}
		}
		oldValue = absoluteValue;
	}

	///////////////////////////////////////////////////////////////////////////
	// COMMON FUNCTIONS

	private function drawOrdinaryField(drawOptions){
		var color = Application.Properties.getValue(drawOptions[:propNameColor]);
		drawSimpleTextValue(
			drawOptions[:value],
		    color,
		    drawOptions[:settingsChanged]
		);
		if (drawOptions[:settingsChanged] || oldValue == null) {
			drawSimpleImage(drawOptions[:imageText], color);
		}
		oldValue = drawOptions[:value];
	}

	private function drawSimpleImage(imageText, color){
		var targetDc = getDc();
		fillPicturePlace(targetDc, backgroundColor);
		targetDc.setColor(color,Graphics.COLOR_TRANSPARENT);
		targetDc.drawText((mHeight-targetDc.getTextWidthInPixels(imageText,mImageFont))/2,
		                  (mHeight-targetDc.getFontHeight(mImageFont))/2,
		                  mImageFont, imageText, Graphics.TEXT_JUSTIFY_LEFT);
	}

	private function drawSimpleTextValue(newValue, color, settingsChanged){
		if ((newValue != oldValue)|| settingsChanged){
			var targetDc = getDc();
			fillTextPlace(targetDc, backgroundColor);
			targetDc.setColor(color,Graphics.COLOR_TRANSPARENT);
			//targetDc.drawText(mHeight, 0, font, newValue, Graphics.TEXT_JUSTIFY_LEFT);
			targetDc.drawText(mHeight+(mWidth-mHeight)/2, mHeight/2, font, newValue, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

		}
	}

	private function fillTextPlace(targetDc, color){
		targetDc.setColor(color,Graphics.COLOR_TRANSPARENT);
		targetDc.fillRectangle(mHeight, 0, mWidth-mHeight, mHeight);
	}

	private function fillPicturePlace(targetDc, color){
		targetDc.setColor(color,Graphics.COLOR_TRANSPARENT);
		targetDc.fillRectangle(0, 0, mHeight, mHeight);
	}
}