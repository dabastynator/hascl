using Toybox.WatchUi;
using Toybox.Application.Properties;

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
			}
		}
		//mMusicView.setVolume(volume);
		mMusicView.setContent(artist, title, playing);
	}

	function updatePlaying()
	{
		mCaller.callParam("XBMC.GetInfoLabels", {"labels" => ["player.title", "player.artist", "player.volume"]}, method(:onUpdateMusic));
	}

	function showVolume(code, data)
	{
		if (data instanceof Dictionary)
		{
			var volume = data["result"];
			mMusicView.setVolume(volume);
		}
	}
	
	function onStop(code, data)
	{
	}
	
	function onPlayPause(code, data)
	{
	}

	function onTap (event)
	{
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
				mCaller.callParam("Player.Stop", {"playerid" => 0}, method(:onStop));
			} else if (coords[0] < 2 * width / 3)
			{
				mCaller.callParam("Player.PlayPause", {"playerid" => 0}, method(:onPlayPause));
				//mCaller.call("/mediaserver/play_pause", "", mUpdateCallback);
			} else
			{
				mCaller.callParam("Player.GoTo", {"playerid" => 0, "to" => "next"}, null);
				//mCaller.call("/mediaserver/next", "", mUpdateCallback);
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
			//mCaller.call("/mediaserver/play_pause", "", mUpdateCallback);
		}
		if (event.getKey() == WatchUi.KEY_UP)
		{
			//mCaller.call("/mediaserver/delta_volume", "delta=" + (+mVolumeDelta), method(:showVolume));
		}
		if (event.getKey() == WatchUi.KEY_DOWN)
		{
			//mCaller.call("/mediaserver/delta_volume", "delta=" + (-mVolumeDelta), method(:showVolume));
		}
	}

}