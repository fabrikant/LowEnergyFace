using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Math;
using Toybox.Time;
using Toybox.SensorHistory;

class GraphField extends Widget {

	var coordinates = {};
	var oldValues = {};

    function initialize(params) {
       var iniParams = {
        	:locX => params.get(:x),
        	:locY => params.get(:y),
        	:width => params.get(:w),
        	:height => params.get(:h)
        };

        Widget.initialize(iniParams);

        var targetDc = getDc();
		coordinates[:owner] = {
			:x => 0,
			:y => 0,
			:w => params.get(:w),
			:h => params.get(:h)
		};

		var w = targetDc.getTextWidthInPixels("9999", Graphics.FONT_SYSTEM_LARGE);
		coordinates[:curValue] = {
			:x => coordinates[:owner][:w]-w,
			:y => 0,
			:w => w,
			:h => coordinates[:owner][:h]
		};

		w = targetDc.getTextWidthInPixels("9999", Graphics.FONT_SYSTEM_XTINY);
		coordinates[:maxValue] = {
			:x => coordinates[:curValue][:x]-w,
			:y => 0,
			:w => w,
			:h => coordinates[:owner][:h]/2
		};

		coordinates[:minValue] = {
			:x => coordinates[:maxValue][:x],
			:y => coordinates[:maxValue][:h],
			:w => w,
			:h => coordinates[:maxValue][:h]
		};

		coordinates[:graph] = {
			:x => 0,
			:y => 0,
			:w => coordinates[:minValue][:x],
			:h => coordinates[:owner][:h]
		};
		var backgroundColor = Application.Properties.getValue("BkGdCol1");
		clearField(targetDc, backgroundColor, coordinates[:owner]);

	}

	function draw(settingsChanged){

		var targetDc = getDc();
		var color = Application.Properties.getValue("WeathCol");
		var backgroundColor = Application.Properties.getValue("BkGdCol1");
		var fieldType = Application.Properties.getValue("WidTp");

		if (settingsChanged){
			clearField(targetDc, backgroundColor, coordinates[:owner]);
		}

		if (color == backgroundColor){
			return;
		}
		var iterator = getIteratorHistory(fieldType);
		if (iterator != null){
			var value = convetValue(iterator.getMax(),fieldType);
			var symbol = :maxValue;
			if (!value.equals(oldValues[symbol]) || settingsChanged){
				drawValue({
					:text => value,
					:targetDc => targetDc,
					:clear => true,
					:font => Graphics.FONT_SYSTEM_XTINY,
					:coord => coordinates[symbol],
					:color => color,
					:backgroundColor => backgroundColor
				});
				oldValues[symbol] = value;
			}
			value = convetValue(iterator.getMin(),fieldType);
			symbol = :minValue;
			if (!value.equals(oldValues[symbol]) || settingsChanged){
				drawValue({
					:text => value,
					:targetDc => targetDc,
					:clear => true,
					:font => Graphics.FONT_SYSTEM_XTINY,
					:coord => coordinates[symbol],
					:color => color,
					:backgroundColor => backgroundColor
				});
				oldValues[symbol] = value;
			}
			var sample = iterator.next();
			if (sample != null){
				var data = sample.data;
				value = convetValue(data,fieldType);
				symbol = :curValue;
				if (!value.equals(oldValues[symbol]) || settingsChanged){
					drawValue({
						:text => value,
						:targetDc => targetDc,
						:clear => true,
						:font => Graphics.FONT_SYSTEM_LARGE,
						:coord => coordinates[symbol],
						:color => color,
						:backgroundColor => backgroundColor
					});
					oldValues[symbol] = value;
				}

				///////////////////////////////////////////////////////////////
				//DRAW GRAPH
				var when = sample.when;
				symbol = :graph;
				if ( when.value() != oldValues[symbol] || settingsChanged){
					oldValues[symbol] = when.value();
					clearField(targetDc, backgroundColor, coordinates[:graph]);
					targetDc.setColor(color, Graphics.COLOR_TRANSPARENT);
					targetDc.setPenWidth(2);
					targetDc.drawLine(0, 0, 0, coordinates[:graph][:h]);
					targetDc.drawLine(0, coordinates[:graph][:h]-1, coordinates[:graph][:w],coordinates[:graph][:h]-1);
					var lastPoint = null;
					var min = iterator.getMin();
					var max = iterator.getMax();
					var x = coordinates[:graph][:w];
					var y = coordinates[:graph][:h] / 2;
					do{
						data = sample.data;
						//draw line
						targetDc.setPenWidth(2);
						if (!(max-min).equals(0)){
							y = coordinates[:graph][:h] - (data - min)*coordinates[:graph][:h]/(max-min);
						}
						if (lastPoint == null){
							lastPoint = [x,y];
						} else {
							targetDc.drawLine(x, y, lastPoint[0], lastPoint[1]);
							lastPoint[0] = x;
							lastPoint[1] = y;
						}
						//draw hours label

						if(sample.when.subtract(when).greaterThan(new Time.Duration(3600))){
							when = sample.when;
							targetDc.drawLine(x, coordinates[:graph][:h]-1, x, coordinates[:graph][:h]-5);
						}
						x -= 1;
						sample = iterator.next();
					} while (sample.data != null && x > 0);
					targetDc.setPenWidth(1);
				}
			}
		}


//		border(coordinates[:owner]);
//		border(coordinates[:curValue]);
//		border(coordinates[:maxValue]);
//		border(coordinates[:minValue]);
//		border(coordinates[:graph]);
	}

	function drawTextField(value, symbol, settingsChanged, targetDc, col, bkgCol, font){
	}

	function getIteratorHistory(fieldType){

		var options = {
			//:period => new Time.Duration(14400),
			//:period => 1000,
			//:order => SensorHistory.ORDER_NEWEST_FIRST
		};

		if (fieldType == 1){
			return SensorHistory.getElevationHistory(options);
		} else if (fieldType == 2){
			return SensorHistory.getHeartRateHistory(options);
		} else if (fieldType == 3){
			return SensorHistory.getPressureHistory(options);
		} else if (fieldType == 4){
			return SensorHistory.getTemperatureHistory(options);
		} else {
			return null;
		}
	}

	function convetValue(value,fieldType){
		var result = "";
		if (fieldType == 1){
			result = Converter.elevation(value);
		} else if (fieldType == 2){
			result = value;
		} else if (fieldType == 3){
			return Converter.pressure(value);
		} else if (fieldType == 4){
			return Converter.temperature(value)+"°";
		}

		if (result > 9999){
			result = (result/1000).format("%.1f")+"k";
		} else {
			result = result.format("%d");
		}
		return result;
	}
}