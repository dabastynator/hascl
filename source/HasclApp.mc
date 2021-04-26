using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Graphics;

class HasclApp extends Application.AppBase {

	function initialize()
	{
		AppBase.initialize();
	}

	// onStart() is called on application start up
	function onStart(state)
	{
	}

	// onStop() is called when your application is exiting
	function onStop(state)
	{
	}
	
	function showSwitches(code, data)
	{
	}
	
	function toSwitches()
	{
		var caller = new WebCaller();
		caller.call("/switch/list", method(:showSwitches));
	}
	
	function showUser(code, data)
	{
		if (data instanceof Array)
		{
			var userList = "";
			for (var i = 0; i < data.size(); i++) {
				var rUser = data[i];
				if (rUser instanceof Dictionary)
				{
					var entity = rUser["entity_id"].substring(0, 7);
					if ("person.".equals(entity))
					{
						if (userList.length() > 0)
						{
							userList = userList + "\n";
						}
						userList = userList + rUser["attributes"]["friendly_name"] 
						           + " (" + rUser["state"] + ")"; 
					}
				}
			}
			var alert = new Alert({
				:timeout => 5000,
				:font => Graphics.FONT_MEDIUM,
				:text => userList,
				:fgcolor => Graphics.COLOR_WHITE,
				:bgcolor => Graphics.COLOR_BLACK
				});
			alert.pushView(WatchUi.SLIDE_UP);
		}
	}
	
	function toUser()
	{
		var caller = new WebCaller();
		caller.get("/api/states", method(:showUser));
	}
	
	function showScenes(code, data)
	{
	if (data instanceof Array)
		{
			var menu = new WatchUi.Menu2({:title=>"Scenes"});
			var delegate = new SceneDelegate();
			for (var i = 0; i < data.size(); i++)
			{
				var rScene = data[i];
				if (rScene instanceof Dictionary)
				{
					var entity = rScene["entity_id"].substring(0, 6);
					if ("scene.".equals(entity))
					{
						menu.addItem(
							new WatchUi.MenuItem(
								rScene["attributes"]["friendly_name"],
								"",
								rScene["entity_id"],
								{}
							)
						); 
					}
				}
			}
			WatchUi.pushView( menu, delegate, WatchUi.SLIDE_UP);
		}
	}
	
	function toScene()
	{
		var caller = new WebCaller();
		caller.get("/api/states", method(:showScenes));
	}
	
	function toAreas()
	{
	}

	// Return the initial view of your application here
	function getInitialView()
	{
		var view = new CircleButtonView();
		view.doShowAnimation(false);
		view.setLineColor(0x3eb7ed);
		view.setCenter(Rez.Drawables.hass);
		view.addButton(Rez.Drawables.user, method(:toUser));
		view.addButton(Rez.Drawables.paint_pallet, method(:toScene));
		view.addButton(Rez.Drawables.switches, method(:toSwitches));
		view.addButton(Rez.Drawables.exit_door, method(:toAreas));
		return [ view, view.getDelegate() ];
	}

}
