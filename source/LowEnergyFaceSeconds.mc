using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;


class SecondsField extends WatchUi.Layer {

	private var backgroundColor = null, color = null;
	
    function initialize(params) {
		setColors();
        var iniParams = {
        	:locX => params.get(:x),
        	:locY => params.get(:y),
        	:width =>  params.get(:w),
        	:height => params.get(:h),
        	:identifier => :secFieldID
        };

        Layer.initialize(iniParams);
    }

	function draw(settingsChanged){

		if (settingsChanged){
			setColors();
		}
		
		var targetDc = getDc();
		targetDc.setColor(Graphics.COLOR_TRANSPARENT, backgroundColor);
    	targetDc.clear();
		targetDc.setColor(color,Graphics.COLOR_TRANSPARENT);
		var value = System.getClockTime().sec.format("%02d");
		targetDc.drawText(0, 0, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_LEFT);
		
	}
	
	private function setColors(){
		color = Application.Properties.getValue("TimeCol");
		backgroundColor = Application.Properties.getValue("BkGdCol2");
	}
}
