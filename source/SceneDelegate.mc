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
		// If view was already closed by user, a popVew causes an hard crash of the watch 
		// WatchUi.popView(WatchUi.SLIDE_LEFT);
	}
	
	function onSelect(item)
	{
		if("clear_cached_scenes".equals(item.getId()))
		{
			Application.Storage.deleteValue("scene_cache");
			WatchUi.popView(WatchUi.SLIDE_LEFT);
		} else {
			mCaller.setParameter({"entity_id" => item.getId()});
			mCaller.post("/api/services/scene/turn_on", method(:close));
		}
	}

}