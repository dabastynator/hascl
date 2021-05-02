using Toybox.WatchUi;
using Toybox.Application.Properties;

class SwitchDelegate extends WatchUi.Menu2InputDelegate {

	var mCaller = null;

	function initialize()
	{
		Menu2InputDelegate.initialize();
		mCaller = new WebCaller();
	}
	
	function onSelect(item)
	{
		if("clear_cached_scenes".equals(item.getId()))
		{
			Application.Storage.deleteValue("switch_cache");
			Application.Storage.deleteValue("light_cache");
			WatchUi.popView(WatchUi.SLIDE_LEFT);
		} else {
			var entity = item.getId().substring(0, 6);
			var state = "off";
			var type = "switch";
			if ("light.".equals(entity))
			{
				type = "light";
			}
			if (item.isEnabled())
			{
				state = "on";
			}
			mCaller.setParameter({"entity_id" => item.getId()});
			mCaller.post("/api/services/" + type + "/turn_" + state, null);
		}
	}

}