using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;

class Background extends WatchUi.Drawable {

	var delimiters = [0,0];

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };
        Drawable.initialize(dictionary);
    }

    function draw(dc) {
//        dc.setColor(Graphics.COLOR_TRANSPARENT, Application.getApp().getProperty("BkGdCol"));
//        dc.clear();
//		System.println(delimiters);
		var w = dc.getWidth();
		dc.setColor(Application.getApp().getProperty("BkGdCol1"),Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(0, 0, w, delimiters[0]);
		dc.setColor(Application.getApp().getProperty("BkGdCol2"),Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(0, delimiters[0], w, delimiters[1]);
		dc.setColor(Application.getApp().getProperty("BkGdCol3"),Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(0, delimiters[1], w, dc.getHeight() - delimiters[1]);
    }

     function drawIfNeed(dc, settingsChanged) {
//        dc.setColor(Graphics.COLOR_TRANSPARENT, Application.getApp().getProperty("BkGdCol"));
//        dc.clear();
		if (!settingsChanged){
			return;
		}
		draw(dc);
    }

}
