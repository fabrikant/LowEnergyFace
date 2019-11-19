using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Math;
using Toybox.Time;

class WeatherField extends WatchUi.Layer {

	private var mImageFont, mBackgroundColor = null;
	const weatherFont = Application.loadResource(Rez.Fonts.weather);
	const weatherText ={
		"01" => "1",
		"02" => "2",
		"03" => "3",
		"04" => "4",
		"09" => "5",
		"10" => "6",
		"11" => "7",
		"13" => "8",
		"50" => "9"
	};
	var coordinates = {};

    function initialize(params) {
       var iniParams = {
        	:locX => params.get(:x),
        	:locY => params.get(:y),
        	:width => params.get(:w),
        	:height => params.get(:h)
        };

        Layer.initialize(iniParams);
		mImageFont = params.get(:imageFont);
		coordinates[:owner] = {:x => 0, :y => 0,:w => params.get(:w), :h => params.get(:h)};
		var targetDc = getDc();
		///////////////////////////////////////////////////////////////////////
		//ICON CLOUD
		var x = 0;
		var w = targetDc.getTextWidthInPixels("1", weatherFont);
		coordinates[:iCloud] = {:x => x, :y => 0, :w => w, :h => coordinates[:owner][:h]}; //iCloud -lol. icon cloud
		///////////////////////////////////////////////////////////////////////
		//TEMPERATURE
		x += w;
		w = targetDc.getTextWidthInPixels("-40°", Graphics.FONT_SYSTEM_LARGE);
		coordinates[:temp] = {:x => x, :y => 0, :w => w, :h => coordinates[:owner][:h]};
		///////////////////////////////////////////////////////////////////////
		//WIND
		x += w;
		w = targetDc.getTextWidthInPixels("999", Graphics.FONT_NUMBER_MEDIUM)-7;
		var halfH = coordinates[:owner][:h]/2;
		coordinates[:wind] = {:x => x, :y => 0, :w => w, :h => coordinates[:owner][:h]};
		///////////////////////////////////////////////////////////////////////
		//ICONS HIMIDITY AND PRESSURE
		x += w + 0.3*halfH;
		coordinates[:iHum] = {:x => x, :y => 0, :w => halfH, :h => halfH};
		coordinates[:iPres]  = {:x => x, :y => halfH, :w => halfH, :h => halfH};
		///////////////////////////////////////////////////////////////////////
		//TEXT FIELDS HIMIDITY AND PRESSURE
		x += coordinates[:iPres][:w];
		w = coordinates[:owner][:w] - x;
		coordinates[:hum] = {:x => x, :y => 0, :w => w, :h => halfH};
		coordinates[:pres] = {:x => x, :y => halfH, :w => w, :h => halfH};
		Application.Storage.setValue(Application.getApp().STORAGE_KEY_WEATHER_OLD, null);
    }


	function draw(settingsChanged){
		var app = Application.getApp();
		var data = Application.Storage.getValue(app.STORAGE_KEY_WEATHER);
		if (data == null){
			return;
		}
		var targetDc = getDc();
		if (mBackgroundColor == null || settingsChanged){
			mBackgroundColor = Application.Properties.getValue("BkGdCol1");
		}
		if (dataInvalid(data, app)){
			clearField(targetDc, mBackgroundColor, coordinates[:owner]);
			Application.Storage.setValue(app.STORAGE_KEY_WEATHER, null);
			Application.Storage.setValue(app.STORAGE_KEY_WEATHER_OLD, null);
			return;
		}
		var oldData = Application.Storage.getValue(app.STORAGE_KEY_WEATHER_OLD);
		if (!settingsChanged && dataEqual(data, oldData, app)){
			return;
		}
		var color = Application.Properties.getValue("WeathCol");
		if (settingsChanged || oldData == null){
			clearField(targetDc, mBackgroundColor, coordinates[:owner]);
			drawValue({:targetDc => targetDc,
					:clear => false,
					:coord => coordinates[:iPres],
					:text => "b",
					:font => mImageFont,
					:color =>  color,
					:backgroundColor => mBackgroundColor
				});
			drawValue({:targetDc => targetDc,
					:clear => false,
					:coord => coordinates[:iHum],
					:text => "h",
					:font => mImageFont,
					:color =>  color,
					:backgroundColor => mBackgroundColor
				});
		}

		///////////////////////////////////////////////////////////////////////
		//CLOUD ICON
		var key = app.STORAGE_KEY_ICON;
		if (settingsChanged || !fieldEqual(data, oldData, key)){

			drawValue({:targetDc => targetDc,
					:clear => true,
					:coord => coordinates[:iCloud],
					:text => weatherText[data[key].substring(0,2)],
					:font => weatherFont,
					:color =>  color,
					:backgroundColor => mBackgroundColor
				});
		}
		///////////////////////////////////////////////////////////////////////
		//TEMPERATURE
		key = app.STORAGE_KEY_TEMP;
		if (settingsChanged || !fieldEqual(data, oldData, key)){

			drawValue({:targetDc => targetDc,
					:clear => true,
					:coord => coordinates[:temp],
					:text => Converter.temperature(data[key].toNumber())+"°",
					:font => Graphics.FONT_SYSTEM_LARGE,
					:color =>  color,
					:backgroundColor => mBackgroundColor
				});
		}
		///////////////////////////////////////////////////////////////////////
		//PRESSURE
		key = app.STORAGE_KEY_PRESSURE;
		if (settingsChanged || !fieldEqual(data, oldData, key)){

			drawValue({:targetDc => targetDc,
					:clear => true,
					:coord => coordinates[:pres],
					:text => Converter.pressure(data[key].toNumber()*100),
					:font => Graphics.FONT_SYSTEM_XTINY,
					:color =>  color,
					:backgroundColor => mBackgroundColor
				});
		}
		///////////////////////////////////////////////////////////////////////
		//HUMIDITY
		key = app.STORAGE_KEY_HUMIDITY;
		if (settingsChanged || !fieldEqual(data, oldData, key)){

			drawValue({:targetDc => targetDc,
					:clear => true,
					:coord => coordinates[:hum],
					:text => data[key].toNumber().format("%d")+"%",
					:font => Graphics.FONT_SYSTEM_XTINY,
					:color =>  color,
					:backgroundColor => mBackgroundColor
				});
		}
		///////////////////////////////////////////////////////////////////////
		//WIND DIRECTION AND SPEED
		if (settingsChanged || !(fieldEqual(data, oldData, app.STORAGE_KEY_WIND_DEG) && fieldEqual(data, oldData, app.STORAGE_KEY_WIND_SPEED))){
			clearField(targetDc, mBackgroundColor, coordinates[:wind]);
			targetDc.setColor(color, Graphics.COLOR_TRANSPARENT);
			var windDirection = windDirection(22, data[app.STORAGE_KEY_WIND_DEG].toNumber(), [coordinates[:wind][:x], coordinates[:wind][:y]+3]);
			targetDc.fillPolygon(windDirection);

			var str = Converter.speed(data[app.STORAGE_KEY_WIND_SPEED].toNumber()).format("%d");
			var x = coordinates[:wind][:x] + coordinates[:wind][:w] - targetDc.getTextWidthInPixels(str, Graphics.FONT_SYSTEM_XTINY)-2;
			targetDc.drawText(x, 0, Graphics.FONT_SYSTEM_XTINY, str, Graphics.TEXT_JUSTIFY_LEFT);

			str = Converter.speedUnitName();
			x = coordinates[:wind][:x] + coordinates[:wind][:w] - targetDc.getTextWidthInPixels(str, Graphics.FONT_SYSTEM_XTINY)-2;
			var y = coordinates[:wind][:y] + coordinates[:wind][:h] - Graphics.getFontHeight(Graphics.FONT_SYSTEM_XTINY);
			targetDc.drawText(x, y, Graphics.FONT_SYSTEM_XTINY, str, Graphics.TEXT_JUSTIFY_LEFT);
		}

		Application.Storage.setValue(app.STORAGE_KEY_WEATHER_OLD, data);

		/////////////////////////////////////////////////////////////
		// DEBUG
//		border(coordinates[:owner]);
//		border(coordinates[:iCloud]);
//		border(coordinates[:temp]);
//		border(coordinates[:wind]);
//		border(coordinates[:iPres]);
//		border(coordinates[:pres]);
//		border(coordinates[:iHum]);
//		border(coordinates[:hum]);
		/////////////////////////////////////////////////////////////
	}


	private function windDirection(size, angle, leftTop){
		var angleRad = Math.toRadians(angle);
		var centerPoint = [size/2,size/2];
		var coords = [[0+size/8,0],[size/2,size],[size-size/8,0],[size/2, size/4]];
	    var result = new [4];
        var cos = Math.cos(angleRad);
        var sin = Math.sin(angleRad);
		var min = [99999, 99999];
        // Transform the coordinates
        for (var i = 0; i < 4; i += 1) {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin) + 0.5;
            var y = (coords[i][0] * sin) + (coords[i][1] * cos) + 0.5;
            result[i] = [centerPoint[0] + x, centerPoint[1] + y];
            if (min[0]>result[i][0]){
            	min[0]=result[i][0];
            }
            if (min[1]>result[i][1]){
            	min[1]=result[i][1];
            }
        }
		var offset = [leftTop[0]-min[0],leftTop[1]-min[1]];
        for (var i = 0; i < 4; i += 1) {
        	result[i][0] = result[i][0] + offset[0];
        	result[i][1] = result[i][1] + offset[1];
		}
        return result;
	}


	private function drawValue(param){
		if (param[:clear]){
			clearField(param[:targetDc], param[:backgroundColor], param[:coord]);
		}
		param[:targetDc].setColor(param[:color],Graphics.COLOR_TRANSPARENT);
		param[:targetDc].drawText(
			param[:coord][:x]+param[:coord][:w]/2,
			param[:coord][:y]+param[:coord][:h]/2,
			param[:font],
			param[:text],
			Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
		);
	}

	private function border(coord){
		var targetDc = getDc();
	    targetDc.setColor(Application.Properties.getValue("WeathCol"), Graphics.COLOR_TRANSPARENT);
		targetDc.drawRectangle(coord[:x], coord[:y], coord[:w], coord[:h]);
	}

	private function clearField(targetDc, bckgrndColor, coord){
	    targetDc.setColor(bckgrndColor, Graphics.COLOR_TRANSPARENT);
		targetDc.fillRectangle(coord[:x], coord[:y], coord[:w], coord[:h]);
	}

	private function dataInvalid(data, app){
		var result = false;
		if (data[app.STORAGE_KEY_RESPONCE_CODE].toNumber() != 200){
			result = true;
		}else{
			if (Time.now().value() - data[app.STORAGE_KEY_RECIEVE].toNumber() > 10800){
				//Old data
				result = true;
			}
		}
		return result;
	}

	private function fieldEqual(data, oldData, fieldKey){
		var result = true;
		if (oldData == null){
			result = false;
		}else{
			if (data[fieldKey] != oldData[fieldKey]) {
				result = false;
			}
		}
		return result;
	}

	private function dataEqual(data, oldData, app){
		if (oldData == null){
			return false;
		} else {
			if(data[app.STORAGE_KEY_DT]==oldData[app.STORAGE_KEY_DT]){
				return true;
			}
			if (( !(data[app.STORAGE_KEY_ICON].equals(oldData[app.STORAGE_KEY_ICON]))
				|| data[app.STORAGE_KEY_TEMP] != oldData[app.STORAGE_KEY_TEMP])
				|| (data[app.STORAGE_KEY_PRESSURE] != oldData[app.STORAGE_KEY_PRESSURE])
				|| (data[app.STORAGE_KEY_HUMIDITY] != oldData[app.STORAGE_KEY_HUMIDITY])
				|| (data[app.STORAGE_KEY_WIND_SPEED] != oldData[app.STORAGE_KEY_WIND_SPEED])
				|| (data[app.STORAGE_KEY_WIND_DEG] != oldData[app.STORAGE_KEY_WIND_DEG])) {
				return false;
			}
		}
		return true;
	}

}