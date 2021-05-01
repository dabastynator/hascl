using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Graphics;

class HasclApp extends Application.AppBase {

	var mCaller;
	var mLegacyCaller;

	function initialize()
	{
		AppBase.initialize();
		mCaller = new WebCaller();
		mLegacyCaller = new LegacyWebCaller();
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
		if (data instanceof Array)
		{
			var menu = new WatchUi.Menu2({:title=>"Switches"});
			var delegate = new SwitchDelegate();
			for (var i = 0; i < data.size(); i++)
			{
				var rSwitch = data[i];
				if (rSwitch instanceof Dictionary)
				{
					var entity = rSwitch["entity_id"].substring(0, 6);
					if ("switch".equals(entity) || "light.".equals(entity))
					{
						menu.addItem(
							new WatchUi.ToggleMenuItem(
								rSwitch["attributes"]["friendly_name"],
								"",
								rSwitch["entity_id"],
								"on".equals(rSwitch["state"]),
								{}
							)
						);
					}
				}
			}
			WatchUi.pushView( menu, delegate, WatchUi.SLIDE_UP);
		}
	}
	
	function toSwitches()
	{
		mCaller.get("/api/states", method(:showSwitches));
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
		mCaller.get("/api/states", method(:showUser));
	}
	
	function showScenes(scenes)
	{
		var menu = new WatchUi.Menu2({:title=>"Scenes"});
		var delegate = new SceneDelegate();
		for (var i = 0; i < scenes.size(); i++)
		{
			var scene = scenes[i];
			menu.addItem(
				new WatchUi.MenuItem(
					scene["name"],
					"",
					scene["id"],
					{}
				)
			);
		}
		menu.addItem(
				new WatchUi.MenuItem(
					"<Clear cached Scenes>",
					"",
					"clear_cached_scenes",
					{}
				)
			);
		WatchUi.pushView( menu, delegate, WatchUi.SLIDE_UP);
	}
	
	function readScenes(code, data)
	{
		if (data instanceof Array)
		{
			var scenes = [];
			for (var i = 0; i < data.size(); i++)
			{
				var scene = data[i];
				if (scene instanceof Dictionary)
				{
					var entity = scene["entity_id"].substring(0, 6);
					if ("scene.".equals(entity))
					{
						scenes.add({"name" => scene["attributes"]["friendly_name"], "id" => scene["entity_id"]});
					}
				}
			}
			Application.Storage.setValue("scene_cache", scenes);
			showScenes(scenes);
		}
	}
	
	function toScene()
	{
		var scenes = Application.Storage.getValue("scene_cache");
		if(scenes != null)
		{
			showScenes(scenes);
		} else {
			mCaller.get("/api/states", method(:readScenes));
		}
	}
	
	function showPlaylists(code, data)
	{
		if ((data instanceof Array) and (data.size() > 0))
		{
			var menu = new WatchUi.Menu2({:title=>"Playlists"});
			var delegate = new PlaylistDelegate();
			for (var i = 0; i < data.size(); i++) {
				var playlist = data[i];
				if (playlist instanceof Dictionary)
				{
					menu.addItem(
						new WatchUi.MenuItem(
							playlist["name"],
							"",
							playlist["name"],
							{}
						)
					);
				}
			}
			WatchUi.pushView( menu, delegate, WatchUi.SLIDE_UP);
		}
	}
	
	function toPlaylists()
	{
		var caller = new WebCaller();
		var music = Properties.getValue("legacy_musicunit");
		mLegacyCaller.call("/mediaserver/playlists", "id=" + music, method(:showPlaylists));
	}
	
	function toMusic()
	{
		var view = new MusicView();
		WatchUi.pushView(view, new MusicDelegate(view), WatchUi.SLIDE_UP);
	}

	// Return the initial view of your application here
	function getInitialView()
	{
		var view = new CircleButtonView();
		view.doShowAnimation(false);
		view.setLineColor(0x3eb7ed);
		view.setCenter(Rez.Drawables.hass);
		view.addButton(Rez.Drawables.user, method(:toUser));
		if (mLegacyCaller.isValid())
		{
			view.addButton(Rez.Drawables.playlist, method(:toPlaylists));
			view.addButton(Rez.Drawables.headphone, method(:toMusic));
		}
		view.addButton(Rez.Drawables.paint_pallet, method(:toScene));
		view.addButton(Rez.Drawables.switches, method(:toSwitches));
		return [ view, view.getDelegate() ];
	}

}
