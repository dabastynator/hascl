using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Graphics;

class HasclApp extends Application.AppBase {

	var mCaller;
	var mLegacyCaller;
	var mKodiCaller;

	function initialize()
	{
		AppBase.initialize();
		mCaller = new WebCaller();
		mLegacyCaller = new LegacyWebCaller();
		mKodiCaller = new KodiWebCaller();
	}

	// onStart() is called on application start up
	function onStart(state)
	{
	}

	// onStop() is called when your application is exiting
	function onStop(state)
	{
	}
	
	function showSwitchesLights(switches, lights)
	{
		var menu = new WatchUi.Menu2({:title=>"Switches"});
		var delegate = new SwitchDelegate();
		for (var i = 0; i < switches.size(); i++)
		{
			var s = switches[i];
			menu.addItem(new WatchUi.ToggleMenuItem(s["name"], "", s["id"], s["state"], {}));
		}
		for (var i = 0; i < lights.size(); i++)
		{
			var s = lights[i];
			menu.addItem(new WatchUi.ToggleMenuItem(s["name"], "", s["id"], s["state"], {}));
		}
		menu.addItem(new WatchUi.MenuItem("<clear cache>", "", "clear_cached_scenes", {}));
		WatchUi.pushView( menu, delegate, WatchUi.SLIDE_UP);
	}
	
	function readSwitchesLights(code, data)
	{
		if (data instanceof Array)
		{
			var switches = [];
			var lights = [];
			for (var i = 0; i < data.size(); i++)
			{
				var entity = data[i];
				if (entity instanceof Dictionary)
				{
					var id = entity["entity_id"].substring(0, 6);
					if ("switch".equals(id))
					{
						switches.add({"name" => entity["attributes"]["friendly_name"],
							"id" => entity["entity_id"],
							"state" => "on".equals(entity["state"])});
					} else if ("light.".equals(id)) {
						lights.add({"name" => entity["attributes"]["friendly_name"],
							"id" => entity["entity_id"],
							"state" => "on".equals(entity["state"])});
					}
				}
			}
			Application.Storage.setValue("switch_cache", switches);
			Application.Storage.setValue("light_cache", lights);
			showSwitchesLights(switches, lights);
		}
	}
	
	function toSwitches()
	{
		var switches = Application.Storage.getValue("switch_cache");
		var lights = Application.Storage.getValue("light_cache");
		if(switches == null || lights == null)
		{
			mCaller.get("/api/states", method(:readSwitchesLights));
		} else {
			showSwitchesLights(switches, lights);
		}
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
		menu.addItem(new WatchUi.MenuItem("<clear cache>", "", "clear_cached_scenes", {}));
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
	
	function showPlaylists(playlists)
	{
		var menu = new WatchUi.Menu2({:title=>"Playlists"});
		var delegate = new PlaylistDelegate();
		for (var i = 0; i < playlists.size(); i++)
		{
			var pls = playlists[i];
			menu.addItem(new WatchUi.MenuItem(pls["name"], "", pls["name"], {}));
		}
		menu.addItem(new WatchUi.MenuItem("<clear cache>", "", "clear_cached_scenes", {}));
		WatchUi.pushView( menu, delegate, WatchUi.SLIDE_UP);
	}
	
	function readPlaylists(code, data)
	{
		if ((data instanceof Array) and (data.size() > 0))
		{
			var playlists = [];
			for (var i = 0; i < data.size(); i++) {
				var playlist = data[i];
				if (playlist instanceof Dictionary)
				{
					playlists.add({"name" => playlist["name"]});
				}
			}
			Application.Storage.setValue("playlist_cache", playlists);
			showPlaylists(playlists);
		}
	}
	
	function toPlaylists()
	{
		var playlists = Application.Storage.getValue("playlist_cache");
		if(playlists != null)
		{
			showPlaylists(playlists);
		} else {
			var music = Properties.getValue("legacy_musicunit");
			mLegacyCaller.call("/mediaserver/playlists", "id=" + music, method(:readPlaylists));
		}
	}
	
	function toLegacyMusic()
	{
		var view = new MusicView();
		WatchUi.pushView(view, new LegacyMusicDelegate(view), WatchUi.SLIDE_UP);
	}
	
	function kodiEnter()
	{
		mKodiCaller.call("Input.Select", null);
	}
	
	function kodiUp()
	{
		mKodiCaller.call("Input.Up", null);
	}
	
	function kodiVolUp()
	{
		mKodiCaller.callParam("Application.SetVolume", {"volume" => "increment"}, null);
	}
	
	function kodiRight()
	{
		mKodiCaller.call("Input.Right", null);
	}
	
	function kodiDown()
	{
		mKodiCaller.call("Input.Down", null);
	}
	
	function kodiBack()
	{
		mKodiCaller.call("Input.Back", null);
	}
	
	function kodiLeft()
	{
		mKodiCaller.call("Input.Left", null);
	}
	
	function kodiVolDown()
	{
		mKodiCaller.callParam("Application.SetVolume", {"volume" => "decrement"}, null);
	}
	
	function kodiMusic()
	{
		var view = new MusicView();
		WatchUi.pushView(view, new KodiMusicDelegate(view), WatchUi.SLIDE_UP);
	}
	
	
	function toKodi()
	{
		var view = new CircleButtonView();
		view.doShowAnimation(false);
		view.setLineColor(0x3eb7ed);
		view.setCenter(Rez.Drawables.enter, method(:kodiEnter));
		view.addButton(Rez.Drawables.up, method(:kodiUp));
		view.addButton(Rez.Drawables.vol_up, method(:kodiVolUp));
		view.addButton(Rez.Drawables.right, method(:kodiRight));
		view.addButton(Rez.Drawables.forth, method(:kodiMusic));
		view.addButton(Rez.Drawables.down, method(:kodiDown));
		view.addButton(Rez.Drawables.back, method(:kodiBack));
		view.addButton(Rez.Drawables.left, method(:kodiLeft));
		view.addButton(Rez.Drawables.vol_down, method(:kodiVolDown));
		WatchUi.pushView(view, view.getDelegate(), WatchUi.SLIDE_UP);
	}

	// Return the initial view of your application here
	function getInitialView()
	{
		var view = new CircleButtonView();
		view.doShowAnimation(false);
		view.setLineColor(0x3eb7ed);
		view.setCenter(Rez.Drawables.hass, null);
		view.addButton(Rez.Drawables.user, method(:toUser));
		if (mLegacyCaller.isValid())
		{
			view.addButton(Rez.Drawables.playlist, method(:toPlaylists));
			view.addButton(Rez.Drawables.headphone, method(:toLegacyMusic));
		}
		view.addButton(Rez.Drawables.paint_pallet, method(:toScene));
		view.addButton(Rez.Drawables.switches, method(:toSwitches));
		view.addButton(Rez.Drawables.kodi, method(:toKodi));
		return [ view, view.getDelegate() ];
	}

}
