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
		FIELD_TYPE_SUNSET
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
		FIELD_TYPE_HR          => "HeartRate",
		FIELD_TYPE_STEPS       => "Steps",
		FIELD_TYPE_PRESSURE    => "Pressure",
		FIELD_TYPE_TEMPERATURE => "Temperature",
		FIELD_TYPE_CALORIES    => "Calories",
		FIELD_TYPE_DISTANCE    => "Distance",
		FIELD_TYPE_FLOOR       => "Floors",
		FIELD_TYPE_ELEVATION   => "Elevation",
		FIELD_TYPE_SUN_EVENT   => "SunEvent",
		FIELD_TYPE_SUNRISE     => "Sunrise",
		FIELD_TYPE_SUNSET      => "Sunset",
	};

	const font = Graphics.FONT_XTINY;
	private var mImageFont;
	private var mWidth, mHeight, oldValue = null, backgroundColor = null, type = null;


    function initialize(params) {

    	mWidth = params.get(:w);
    	mHeight = params.get(:h);
		mImageFont = params.get(:imageFont);

		//System.println("ini: "+id);
        var iniParams = {
        	:locX => params.get(:x),
        	:locY => params.get(:y),
        	:width => mWidth,
        	:height => mHeight,
        	:identifier => params.get(:id)
        };
        Layer.initialize(iniParams);
    }

	function draw(settingsChanged, sunEventCalculator){

		if (type == null || settingsChanged) {
			type = Application.Properties.getValue("F"+getId());
		}

		if (backgroundColor == null || settingsChanged){
			backgroundColor = Application.Properties.getValue("BgndCol");
		}

		if (type == FIELD_TYPE_EMPTY && settingsChanged){

			var targetDc = getDc();
			targetDc.setColor(Graphics.COLOR_TRANSPARENT, backgroundColor);
        	targetDc.clear();
		}else if (type == FIELD_TYPE_EMPTY){
			//Do nothing, its required
		}else if (type == FIELD_TYPE_BAT){

			drawBattery(settingsChanged);

		}else {
			var value = "";
			if (type == FIELD_TYPE_HR){
				value = "";
				var iter = SensorHistory.getHeartRateHistory({:period =>1, :order => SensorHistory.ORDER_NEWEST_FIRST});
				if (iter != null){
					var sample = iter.next();
					if (sample != null){
						if (sample.data != null){
							value = sample.data.toString();
						}
					}
				}

			}else if (type == FIELD_TYPE_STEPS){

				value = ActivityMonitor.getInfo().steps;
				if (value > 9999){
					value = (value/1000).format("%.1f")+"k";
				}

			}else if (type == FIELD_TYPE_PRESSURE){
				value = "";
				var iter = SensorHistory.getPressureHistory({:period =>1, :order => SensorHistory.ORDER_NEWEST_FIRST});
				if (iter != null){
					var sample = iter.next();
					if (sample != null){
						if (sample.data != null){
							value = sample.data.toString();
							value = Converter.pressure(sample.data);
						}
					}
				}

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
			}else if (type == FIELD_TYPE_CALORIES){

				value = ActivityMonitor.getInfo().calories;

			}else if (type == FIELD_TYPE_DISTANCE){

				value = Converter.distance(ActivityMonitor.getInfo().distance);

			}else if (type == FIELD_TYPE_FLOOR){

				value = ActivityMonitor.getInfo().floorsClimbed;

			}else if (type == FIELD_TYPE_ELEVATION){
				value = "";
				var iter = SensorHistory.getElevationHistory({:period =>1, :order => SensorHistory.ORDER_NEWEST_FIRST});
				if (iter != null){
					var sample = iter.next();
					if (sample != null){
						if (sample.data != null){
							value = Converter.elevation(sample.data);
						}
					}
				}

				if (value > 9999){
					ElevationUnitFoot = (value/1000).format("%.1f")+"k";
				}else{
					value = value.format("%d");
				}

			}else if (type == FIELD_TYPE_SUNRISE){

				var moment = getSunEvent(sunEventCalculator, SUNRISE);
				if (moment == null) {
					value = "gps?";
				} else {
					value = getMomentView(moment);
				}

			}else if (type == FIELD_TYPE_SUNSET){

				var moment = getSunEvent(sunEventCalculator, SUNSET);
				if (moment == null) {
					value = "gps?";
				} else {
					value = getMomentView(moment);
				}

			}else if (type == FIELD_TYPE_SUN_EVENT){

				var momentSunset = getSunEvent(sunEventCalculator, SUNSET);
				if(momentSunset == null){
					value = "geo?";
				}else{
					//System.println("Time.now().value() = "+Time.now().value());
					//System.println("momentSunset.value() = "+momentSunset.value());
					if (Time.now().value() < momentSunset.value()){
						value = getMomentView(momentSunset);
					}else{
						value = getMomentView(getSunEvent(sunEventCalculator, SUNRISE));
					}
				}

			}

			drawOrdinaryField({
					:value => value,
					:propNameTextColor => fieldSignatures[type]+"TextColor",
					:propNameImageColor => fieldSignatures[type]+"ImageColor",
					:imageText => imageText[type],
					:settingsChanged=>settingsChanged});

		}
	}

	///////////////////////////////////////////////////////////////////////////
	// SUN EVENTS
	private function getMomentView(moment){

		var info = Gregorian.info(moment,Time.FORMAT_SHORT);
		//System.println(info.day.format("%02d")+"."+info.month.format("%02d")+"."+info.year.format("%d")+" "+info.hour.format("%02d")+":"+info.min.format("%02d"));
		return info.hour.format("%02d")+":"+info.min.format("%02d");

	}

	private function getSunEvent(sunEventCalculator, event){

		if (sunEventCalculator == null){
			sunEventCalculator = new SunCalc();
		}

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
		    }).toRadians();

		return sunEventCalculator.calculate(Time.now(),myLocation[0],myLocation[1],event);

	}

	///////////////////////////////////////////////////////////////////////////
	// BATTERY FIELD

	private function drawBattery(settingsChanged){

		var absoluteValue = Math.round(System.getSystemStats().battery);

		if (absoluteValue != oldValue || settingsChanged) {

			var value = absoluteValue.format("%d")+((absoluteValue<100)?"%":"");
			var targetDc = getDc();

			fillTextPlace(targetDc, backgroundColor);

			targetDc.setColor(Application.Properties.getValue("BatteryTextColor"),Graphics.COLOR_TRANSPARENT);
			targetDc.drawText(mHeight, 0, font, value, Graphics.TEXT_JUSTIFY_LEFT);

			//Рисуем батарею
			var bY = 8;
			var bW = mHeight-3;
			var bH = 10;

			//Первая отрисовка. Рисуем контур батареи
			if(oldValue==null || settingsChanged){
				fillPicturePlace(targetDc, backgroundColor);
				var counterColor = Application.Properties.getValue("BatteryImageColor");
				targetDc.setColor(counterColor,Graphics.COLOR_TRANSPARENT);
				targetDc.setPenWidth(2);
				targetDc.drawRectangle(0, bY, bW, bH);
				targetDc.setPenWidth(1);
				targetDc.fillRectangle(bW, bY+2, 2, 4);
				oldValue = 0;
			}
			//Перерисовывать будем только если заливка должна поменяться.

			var bW100 = bW-5;
			var oldBW = Math.round(bW100*oldValue/100);
			var newBW = Math.round(bW100*absoluteValue/100);

			if (!(newBW==oldBW) || settingsChanged){
				var color = Application.Properties.getValue((absoluteValue > Application.Properties.getValue("BatteryLowPowerValue")) ? "BatteryHighPowerColor" : "BatteryLowPowerColor");
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
		drawSimpleTextValue(drawOptions[:value],
		                    Application.Properties.getValue(drawOptions[:propNameTextColor]),
		                    drawOptions[:settingsChanged]);
		if (drawOptions[:settingsChanged] || oldValue == null) {
			drawSimpleImage(drawOptions[:imageText],
			                Application.Properties.getValue(drawOptions[:propNameImageColor]));
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
			targetDc.drawText(mHeight, 0, font, newValue, Graphics.TEXT_JUSTIFY_LEFT);
		}
	}

	private function fillTextPlace(targetDc, color){
		targetDc.setColor(color,Graphics.COLOR_TRANSPARENT);
		targetDc.fillRectangle(mHeight, 0, mWidth-mHeight, mHeight);
//		targetDc.setColor(Graphics.COLOR_GREEN,Graphics.COLOR_TRANSPARENT);
//		targetDc.drawRectangle(mHeight, 0, mWidth-mHeight, mHeight);
	}

	private function fillPicturePlace(targetDc, color){
		targetDc.setColor(color,Graphics.COLOR_TRANSPARENT);
		targetDc.fillRectangle(0, 0, mHeight, mHeight);
//		targetDc.setColor(Graphics.COLOR_GREEN,Graphics.COLOR_TRANSPARENT);
//		targetDc.drawRectangle(0, 0, mHeight, mHeight);
	}

}