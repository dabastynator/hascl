using Toybox.WatchUi;
using Toybox.Application.Properties;
using Toybox.Attention;

class KodiMusicDelegate extends WatchUi.BehaviorDelegate {

	var mCaller = null;
	var mMusicView = null;
	var mVolumeDelta = 10;

	function initialize(musicView)
	{
		BehaviorDelegate.initialize();
		mCaller = new KodiWebCaller();
		mMusicView = musicView;
		updatePlaying();
	}
	
	function onUpdateMusic(code, data)
	{
		var artist = "---";
		var title = "---";
		var volume = 0;
		var playing = false;
		if (data instanceof Dictionary)
		{
			var result = data["result"];
			if (result instanceof Dictionary)
			{
				artist = result["player.artist"];
				title = result["player.title"];
				volume = result["player.volume"];
				if (artist.length() == 0)
				{
					artist = result["player.filename"];
				}
				else if (title.length() == 0)
				{
					title = result["player.filename"];
				}
				playing = !"0.00".equals(result["player.playspeed"]);
			}
		}
		//mMusicView.setVolume(volume);
		mMusicView.setContent(artist, title, playing);
	}

	function updatePlaying()
	{
		mCaller.callParam("XBMC.GetInfoLabels", {"labels" => ["player.title", "player.artist", "player.filename", "player.volume", "player.playspeed"]}, method(:onUpdateMusic));
	}

	function showVolume(code, data)
	{
		if (data instanceof Dictionary)
		{
			var volume = data["result"];
			mMusicView.setVolume(volume);
		}
	}
	
	function onCallUpdate(code, data)
	{
		updatePlaying();
	}


	function onTap (event)
	{
		if (Attention has :vibrate) {
			var vibeData = [
				new Attention.VibeProfile(25, 100), // On for 100 ms
			];
			Attention.vibrate(vibeData);
		}
		var width = CircleButtonView.Width;
		var height = CircleButtonView.Height;
		var coords = event.getCoordinates();
		if (coords[1] < height * 0.4)
		{
			updatePlaying();
		} else if (coords[1] < height * 0.7)
		{
			if (coords[0] < width / 3)
			{
				mCaller.callParam("Player.Stop", {"playerid" => 0}, method(:onCallUpdate));
			} else if (coords[0] < 2 * width / 3)
			{
				mCaller.callParam("Player.PlayPause", {"playerid" => 0}, method(:onCallUpdate));
			} else
			{
				mCaller.callParam("Player.GoTo", {"playerid" => 0, "to" => "next"}, method(:onCallUpdate));
			}
		} else {
			if (coords[0] < width / 2)
			{
				mCaller.callParam("Application.SetVolume", {"volume" => "decrement"}, method(:showVolume));
			} else
			{
				mCaller.callParam("Application.SetVolume", {"volume" => "increment"}, method(:showVolume));
			}
		}
	}

	function onKey(event)
	{
		if (event.getKey() == WatchUi.KEY_ENTER)
		{
			mCaller.callParam("Player.PlayPause", {"playerid" => 0}, method(:onCallUpdate));
		}
		if (event.getKey() == WatchUi.KEY_UP)
		{
			mCaller.callParam("Application.SetVolume", {"volume" => "increment"}, method(:showVolume));
		}
		if (event.getKey() == WatchUi.KEY_DOWN)
		{
			mCaller.callParam("Application.SetVolume", {"volume" => "decrement"}, method(:showVolume));
		}
	}

}