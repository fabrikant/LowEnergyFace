using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;


class AmPmField extends WatchUi.Layer {

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
		var value = System.getClockTime().hour >= 12 ? Application.loadResource(Rez.Strings.Pm) : Application.loadResource(Rez.Strings.Am);
		if (settingsChanged || value != oldValue){

			var backgroundColor = Application.Properties.getValue("BkGdCol2");
			var targetDc = getDc();
			targetDc.setColor(Graphics.COLOR_TRANSPARENT, backgroundColor);
        	targetDc.clear();

			if (!System.getDeviceSettings().is24Hour && Application.Properties.getValue("AmPm")){
				targetDc.setColor(Application.Properties.getValue("TimeCol"),Graphics.COLOR_TRANSPARENT);
				targetDc.drawText(0, 0, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_LEFT);
			}
		}
		oldValue = value;
	}
}