using Toybox.WatchUi;
using Toybox.Application.Properties;

class SceneDelegate extends WatchUi.Menu2InputDelegate {

	var mCaller = null;

	function initialize()
	{
		Menu2InputDelegate.initialize();
		mCaller = new WebCaller();
	}
	
	function close(code, data)
	{
		WatchUi.popView(WatchUi.SLIDE_LEFT);
	}
	
	function onSelect(item)
	{
		mCaller.setParameter({"entity_id" => item.getId()});
		mCaller.post("/api/services/scene/turn_on", method(:close));
	}

}