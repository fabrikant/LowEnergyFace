using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Time;
using Toybox.Background;
using Toybox.Activity;

(:background)
class LowEnergyFaceApp extends Application.AppBase {

	enum{
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
    	Background.deleteTemporalEvent();
    	Background.deleteActivityCompletedEvent();
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
     	///////////////////////////////////////////////////////////////////////
    	//DEBUG
        //System.println("onBackgroundData: "+data);
     	///////////////////////////////////////////////////////////////////////
     	if (data[STORAGE_KEY_RESPONCE_CODE] != null){
	        if (data[STORAGE_KEY_RESPONCE_CODE].toNumber() == 200){
	        	Application.Storage.setValue(STORAGE_KEY_WEATHER, data);
	        }
        }else if (data["Lat"] != null){
        	System.println("capture location: "+data["Lat"]+" "+ data["Lon"]);
        	Application.Properties.setValue("Lat", data["Lat"]);
			Application.Properties.setValue("Lon", data["Lon"]);
        }

        var geoLatLong = [Application.Properties.getValue("Lat"),
						  Application.Properties.getValue("Lon")];

		if (geoLatLong[0] == 0 && geoLatLong[1] == 0){

			var location = Activity.getActivityInfo().currentLocation;
			if (location) {
				location = location.toDegrees();
				System.println("AFTER location: "+location);

				Application.Properties.setValue("Lat", location[0].toFloat());
				Application.Properties.setValue("Lon", location[1].toFloat());
			}
		}
        registerEvents();
    }


    function getServiceDelegate(){
        return [new BackgroundService()];
    }

//	function saveCurrentLocation(){
//		//System.println("Start capture location");

	function registerEvents(){

		var kewOw = Application.Properties.getValue("keyOW");
		if (kewOw.length() == 0){
			return;
		}

//		saveCurrentLocation();
		Background.registerForActivityCompletedEvent();

		System.println("Lat: "+Application.Properties.getValue("Lat"));
		System.println("Lon: "+Application.Properties.getValue("Lon"));

//		if (Application.Properties.getValue("Lat") == null || Application.Properties.getValue("Lon") == null){
//			return;
//		}
//		if (Application.Properties.getValue("Lat")==0 && Application.Properties.getValue("Lon")){
//			return;
//		}

		var geoLatLong = [Application.Properties.getValue("Lat"),
						  Application.Properties.getValue("Lon")];

		if (geoLatLong[0] == 0 && geoLatLong[1] == 0){
			return;
		}

		System.println("Start temporal event");
		var lastTime = Background.getLastTemporalEventTime();
		var duration = new Time.Duration(600);
		var now = Time.now();

		if (lastTime == null){
			Background.registerForTemporalEvent(now);
		}else{
			if (now.greaterThan(lastTime.add(duration))){
				Background.registerForTemporalEvent(now);
			}else{
			    var nextTime = lastTime.add(duration);
			    Background.registerForTemporalEvent(nextTime);
			}
		}
	}
}