using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;


class AmPmField extends WatchUi.Layer {

	const amString = "A", pmString = "P";

	private var oldValue = null;


    function initialize(params) {

         var iniParams = {
        	:locX => params.get(:x),
        	:locY => params.get(:y),
        	:width =>  params.get(:w),
        	:height => params.get(:h),
        	:identifier => params.get(:id)
        };
        Layer.initialize(iniParams);
    }

	function draw(settingsChanged, sunEventCalculator){
		var value = System.getClockTime().hour >= 12 ? Application.Properties.getValue("PmString") : Application.Properties.getValue("AmString");
		if (settingsChanged || value != oldValue){

			var backgroundColor = Application.Properties.getValue("BgndCol");
			var targetDc = getDc();
			targetDc.setColor(Graphics.COLOR_TRANSPARENT, backgroundColor);
        	targetDc.clear();

			if (!System.getDeviceSettings().is24Hour && Application.Properties.getValue("ShowAmPm")){
				targetDc.setColor(Application.Properties.getValue("TimeColor"),Graphics.COLOR_TRANSPARENT);
				targetDc.drawText(0, 0, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_LEFT);
			}
		}
		oldValue = value;
	}

}