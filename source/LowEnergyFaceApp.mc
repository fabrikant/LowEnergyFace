using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Time;
using Toybox.Background;
using Toybox.Activity;

(:background)
class LowEnergyFaceApp extends Application.AppBase {

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
		FIELD_TYPE_TIME1,
		STATUS_TYPE_CONNECT,
		STATUS_TYPE_MESSAGE,
		STATUS_TYPE_DND,
		STATUS_TYPE_ALARM,
		STORAGE_POSITION_KEY,
		STORAGE_KEY_WEATHER,
		STORAGE_KEY_RESPONCE_CODE,
		STORAGE_KEY_RECIEVE,
		STORAGE_KEY_TEMP,
		STORAGE_KEY_PRESSURE,
		STORAGE_KEY_HUMIDITY,
		STORAGE_KEY_ICON,
		STORAGE_KEY_WIND_SPEED,
		STORAGE_KEY_WIND_DEG,
		STORAGE_KEY_DT,
		STORAGE_KEY_WEATHER_OLD,
	}

	var imageText = {
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
		FIELD_TYPE_TIME1	   => "q",
	};

	var gView;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    	registerEvents();
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
     	gView = new LowEnergyFaceView();
        return [ gView ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {
    	gView.settingsChanged = true;
    	registerEvents();
    	gView.requestUpdate();
        WatchUi.requestUpdate();
    }

	///////////////////////////////////////////////////////////////////////////
	// Background
	function onBackgroundData(data) {
		//////////////////////////////////////////////////////////
		//DEBUG
		//System.println("onBackgroundData "+Time.now().value());
		//System.println("data: "+data);
		//////////////////////////////////////////////////////////
    	if (data[STORAGE_KEY_RESPONCE_CODE] != null){
     		Application.Storage.setValue(STORAGE_KEY_RESPONCE_CODE, data[STORAGE_KEY_RESPONCE_CODE]);
	        if (data[STORAGE_KEY_RESPONCE_CODE].toNumber() == 200){
	        	Application.Storage.setValue(STORAGE_KEY_WEATHER, data);
	        }
 		}
        registerEvents();
    }


    function getServiceDelegate(){
        return [new BackgroundService()];
    }

	function registerEvents(){
		if (Application.Properties.getValue("WidTp") != 0){
			return;
		}
		var geoLatLong = [Application.Storage.getValue("Lat"),
						  Application.Storage.getValue("Lon")];
		if (geoLatLong[0] == null || geoLatLong[1] == null){
			return;
		}
		if (geoLatLong[0] == 0 && geoLatLong[1] == 0){
			return;
		}
		var kewOw = Application.Properties.getValue("keyOW");
		if (kewOw.equals("")){
			return;
		}
		var registeredTime = Background.getTemporalEventRegisteredTime();
		if (registeredTime != null){
			//////////////////////////////////////////////////////////
			//DEBUG
			//System.println("now: "+Time.now().value()+" Event already set: "+registeredTime.value());
			//////////////////////////////////////////////////////////
			return;
		}
		var lastTime = Background.getLastTemporalEventTime();
		var duration = new Time.Duration(600);
		var now = Time.now();
		if (lastTime == null){
			//////////////////////////////////////////////////////////
			//DEBUG
			//System.println("reg ev now 1");
			//////////////////////////////////////////////////////////
			Background.registerForTemporalEvent(now);
		}else{
			if (now.greaterThan(lastTime.add(duration))){
				//////////////////////////////////////////////////////////
				//DEBUG
				//System.println("reg ev now 2");
				//////////////////////////////////////////////////////////
				Background.registerForTemporalEvent(now);
			}else{
			    var nextTime = lastTime.add(duration);
				//////////////////////////////////////////////////////////
				//DEBUG
			    //System.println("reg ev "+nextTime.value());
				//////////////////////////////////////////////////////////
			    Background.registerForTemporalEvent(nextTime);
			}
		}
	}
}