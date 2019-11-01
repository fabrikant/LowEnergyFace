using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;


class StatusField extends WatchUi.Layer {

	const App = Application.getApp();
	const imageText = {
		App.STATUS_TYPE_CONNECT => "c",
		App.STATUS_TYPE_ALARM   => "a",
		App.STATUS_TYPE_MESSAGE => "i",
		App.STATUS_TYPE_DND => "k"
	};
	const fieldSignatures = {
		App.STATUS_TYPE_CONNECT => "Con",
		App.STATUS_TYPE_ALARM   => "Al",
		App.STATUS_TYPE_MESSAGE => "Mes",
		App.STATUS_TYPE_DND => "DND"
	};
	private var oldValue = null;
	private var mImageFont;

    function initialize(params) {

		mImageFont = params.get(:imageFont);
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
		var value = false;
		var id = getId();

		if (id == App.STATUS_TYPE_CONNECT){
			value = System.getDeviceSettings().connectionAvailable;
		} else if (id == App.STATUS_TYPE_ALARM){
			value = System.getDeviceSettings().alarmCount > 0;
		} else if (id == App.STATUS_TYPE_MESSAGE){
			value = System.getDeviceSettings().notificationCount > 0;
		} else if (id == App.STATUS_TYPE_DND){
			value = System.getDeviceSettings().doNotDisturb;
		}
		if (settingsChanged || value != oldValue){
			var backgroundColor = Application.Properties.getValue("BkGdCol");
			var targetDc = getDc();
			targetDc.setColor(Graphics.COLOR_TRANSPARENT, backgroundColor);
        	targetDc.clear();
			var color = Application.Properties.getValue(fieldSignatures[id]+(value ? "Tr" : "F")+"Col");

			if (color != backgroundColor && imageText[id] != null) {
				targetDc.setColor(color,Graphics.COLOR_TRANSPARENT);
				targetDc.drawText(0, 0, mImageFont, imageText[id], Graphics.TEXT_JUSTIFY_LEFT);
			}
		}
		oldValue = value;
	}
}