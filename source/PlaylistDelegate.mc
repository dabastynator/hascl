using Toybox.WatchUi;
using Toybox.Application.Properties;

class PlaylistDelegate extends WatchUi.Menu2InputDelegate {

	var mCaller = null;

	function initialize()
	{
		Menu2InputDelegate.initialize();
		mCaller = new LegacyWebCaller();
		var music = Properties.getValue("legacy_musicunit");
		mCaller.setDefaultParameter("player=mplayer&id=" + music);
	}
	
	function stringReplace(str, oldString, newString)
	{
		var result = str;
		
		while (true)
		{
			var index = result.find(oldString);
			
			if (index != null)
			{
				var index2 = index+oldString.length();
				result = result.substring(0, index) + newString + result.substring(index2, result.length());
			}
			else
			{
				return result;
			}
		}	
		return null;
	} 
	
	function setPlaylist(code, data)
	{
		var view = new MusicView();
		WatchUi.pushView(view, new MusicDelegate(view), WatchUi.SLIDE_UP);
	}
	
	function onSelect(item)
	{
		var encoded = stringReplace(item.getId(), " ", "%20");
		mCaller.call("/mediaserver/play_playlist", "playlist=" + encoded, method(:setPlaylist));
	}

}