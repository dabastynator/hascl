using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.Timer as Timer;

class Delegate extends Ui.InputDelegate {

	hidden var view;
	
	function initialize(view) 
	{
		InputDelegate.initialize();
		self.view = view;
	}
	
	function onKey(evt)
	{
		view.dismiss();
		return true;
	}
	
	function onTap(evt)
	{
		view.dismiss();
		return true;
	}
}
	
class Alert extends Ui.View {

	hidden var timer;
	hidden var timeout;
	hidden var text;
	hidden var font;
	hidden var fgcolor;
	hidden var bgcolor;
	private var mLines = 1;
	private var mWrapped = false;
	
	function initialize(params)
	{
		View.initialize();
		
		text = params.get(:text);
		if (text == null) {
			text = "Alert";
		}
		
		font = params.get(:font);
		if (font == null) {
			font = Gfx.FONT_MEDIUM;
		}
		
		fgcolor = params.get(:fgcolor);
		if (fgcolor == null) {
			fgcolor = Gfx.COLOR_BLACK;
		}
		
		bgcolor = params.get(:bgcolor);
		if (bgcolor == null) {
			bgcolor = Gfx.COLOR_WHITE;
		}
		
		timeout = params.get(:timeout);
		if (timeout == null) {
			timeout = 2000;
		}
		
		timer = new Timer.Timer();
	}
	
	function onShow() {
		timer.start(method(:dismiss), timeout, false);
	}
	
	function onHide() {
		timer.stop();
	}
	
	function splitString(dc, font, str, margin){
		
		var width = dc.getWidth() - margin * 2;
		var strLen = str.length();
		var firstChar = 0;
		var lastChar = 0;
		var newStr = "";
		mLines = 1;
		
		if(strLen == 0){return "";}
		
		for(var i = 0; i <= strLen; i++) {
			var char = str.substring(i, i + 1);
			if(char.equals("\n"))
			{
				mLines += 1;
			}
			if(char.equals(" ") || i == strLen)
			{
				if(dc.getTextWidthInPixels(str.substring(firstChar, i), font) < width)
				{
					lastChar = i;
				}
				else
				{
					newStr += str.substring(firstChar, lastChar) + "\n";
					firstChar = lastChar + 1;
					mLines += 1;
				}
			}
		}
		newStr += str.substring(firstChar, strLen);
		return newStr;
	}
	
	function onUpdate(dc) {
	
		if (!mWrapped)
		{
			text = splitString(dc, font, text, 4);
			mWrapped = true;
		}	
	
		var tWidth = dc.getTextWidthInPixels(text, font);
		var tHeight = dc.getFontHeight(font) * mLines;
		
		var bWidth = tWidth + 14;
		var bHeight = tHeight + 14;
		
		var bX = (dc.getWidth() - bWidth) / 2;
		var bY = (dc.getHeight() - bHeight) / 2;
		
		dc.setColor(bgcolor, bgcolor);
		dc.fillRectangle(bX, bY, bWidth, bHeight);
		
		dc.setColor(fgcolor, bgcolor);

		dc.setPenWidth(1);
		dc.drawRectangle(bX, bY, bWidth, bHeight);

		var tX = dc.getWidth() / 2;
		var tY = bY + bHeight / 2;
		
		dc.setColor(fgcolor, bgcolor);
		dc.drawText(tX, tY, font, text, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
	}
	
	function dismiss() {
		Ui.popView(SLIDE_IMMEDIATE);
	}
	
	function pushView(transition) {
		Ui.pushView(self, new Delegate(self), transition);
	}
}