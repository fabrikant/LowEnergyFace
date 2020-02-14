using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;


class SecondsField extends WatchUi.Layer {

	private var oldValue = null;
	private var showSeconds = null;
	
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

	function draw(settingsChanged){
		
		if (showSeconds == null || settingsChanged){
			showSeconds = Application.Properties.getValue("Sec");
			clearField();
		}
		if (showSeconds){
			var value = System.getClockTime().sec.format("%02d");
			if (value != oldValue){
				clearField();
				var targetDc = getDc();
				targetDc.setColor(Application.Properties.getValue("TimeCol"),Graphics.COLOR_TRANSPARENT);
				targetDc.drawText(0, 0, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_LEFT);
				oldValue = value;
			}
		}
	}
	
	private function clearField(){
		var backgroundColor = Application.Properties.getValue("BkGdCol2");
		var targetDc = getDc();
		targetDc.setColor(Graphics.COLOR_TRANSPARENT, backgroundColor);
    	targetDc.clear();
	}
}