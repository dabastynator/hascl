using Toybox.WatchUi;
using Toybox.Application.Properties;

class LegacyMusicDelegate extends WatchUi.BehaviorDelegate {

	var mCaller = null;
	var mMusicView = null;
	var mVolumeDelta = 10;

	function initialize(musicView)
	{
		BehaviorDelegate.initialize();
		mCaller = new LegacyWebCaller();
		var music = Properties.getValue("legacy_musicunit");
		mCaller.setDefaultParameter("player=mplayer&id=" + music);
		mMusicView = musicView;
		updatePlaying();
	}
	
	function onUpdateMusic(code, data)
	{
		var artist = "---";
		var title = "---";
		var playing = false;
		var current = null;
		if ((data instanceof Array) and (data.size() > 0))
		{
			var media = data[0];
			if (media instanceof Dictionary)
			{
				current = media["current_playing"];
			}
		} else {
			current = data;
		}
		if (current instanceof Dictionary)
		{
			if (current["artist"] != null)
			{
				artist = current["artist"];
			}
			if (current["title"] != null)
			{
				title = current["title"];
			}
			if ("PLAY".equals(current["state"]))
			{
				playing = true;
			}
			mMusicView.setVolume(current["volume"]);
		}
		mMusicView.setContent(artist, title, playing);
	}

	function updatePlaying()
	{
		mCaller.call("/mediaserver/list", "", method(:onUpdateMusic));
	}

	function showVolume(code, data)
	{
		if (data instanceof Dictionary)
		{
			var volume = data["volume"];
			mMusicView.setVolume(volume);
		}
	}

	function changeVolume(code, data, delta)
	{
		if ((data instanceof Array) and (data.size() > 0))
		{
			var media = data[0];
			if (media instanceof Dictionary)
			{
				var current = media["current_playing"];
				if (current instanceof Dictionary)
				{
					var volume = current["volume"] + delta;
					mCaller.call("/mediaserver/volume", "volume=" + volume, method(:showVolume));
				}
			}
		}
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
				mCaller.call("/mediaserver/stop", "", method(:onUpdateMusic));
			} else if (coords[0] < 2 * width / 3)
			{
				mCaller.call("/mediaserver/play_pause", "", method(:onUpdateMusic));
			} else
			{
				mCaller.call("/mediaserver/next", "", method(:onUpdateMusic));
			}
		} else {
			if (coords[0] < width / 2)
			{
				mCaller.call("/mediaserver/delta_volume", "delta=" + (-mVolumeDelta), method(:showVolume));
			} else
			{
				mCaller.call("/mediaserver/delta_volume", "delta=" + (+mVolumeDelta), method(:showVolume));
			}
		}
	}

	function onKey(event)
	{
		if (event.getKey() == WatchUi.KEY_ENTER)
		{
			mCaller.call("/mediaserver/play_pause", "", method(:onUpdateMusic));
		}
		if (event.getKey() == WatchUi.KEY_UP)
		{
			mCaller.call("/mediaserver/delta_volume", "delta=" + (+mVolumeDelta), method(:showVolume));
		}
		if (event.getKey() == WatchUi.KEY_DOWN)
		{
			mCaller.call("/mediaserver/delta_volume", "delta=" + (-mVolumeDelta), method(:showVolume));
		}
	}

}