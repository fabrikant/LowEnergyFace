using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;

class Widget extends WatchUi.Layer {


    function initialize(params) {
        Layer.initialize(params);
    }

	function drawValue(param){
		if (param[:clear]){
			clearField(param[:targetDc], param[:backgroundColor], param[:coord]);
		}
		param[:targetDc].setColor(param[:color],Graphics.COLOR_TRANSPARENT);
		if (param[:justify] == null){
			param[:targetDc].drawText(
				param[:coord][:x]+param[:coord][:w]/2,
				param[:coord][:y]+param[:coord][:h]/2,
				param[:font],
				param[:text],
				Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
			);
		}else if ((param[:justify] == Graphics.TEXT_JUSTIFY_LEFT)){
			param[:targetDc].drawText(
				param[:coord][:x],
				param[:coord][:y]+param[:coord][:h]/2,
				param[:font],
				param[:text],
				Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
			);
		}
	}

	 function border(coord){
		var targetDc = getDc();
	    targetDc.setColor(Application.Properties.getValue("WeathCol"), Graphics.COLOR_TRANSPARENT);
		targetDc.drawRectangle(coord[:x], coord[:y], coord[:w], coord[:h]);
	}

	function clearField(targetDc, bckgrndColor, coord){
	    targetDc.setColor(bckgrndColor, Graphics.COLOR_TRANSPARENT);
		targetDc.fillRectangle(coord[:x], coord[:y], coord[:w], coord[:h]);
	}
 }