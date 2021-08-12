using Toybox.Application.Properties;

class WebCaller {

	var mUrl = "";	
	var mToken = "";
	var mParameter = null;
	var mCallback = null;
	
	function initialize()
	{
		mUrl = Properties.getValue("endpoint");
		mToken = Properties.getValue("token");
		System.println("Read properties:");
		System.println(" Url: " + mUrl);
		System.println(" Token: " + mToken);
	}
	
	function onReceive(responseCode, data)
	{
		System.println("WebCaller::onReceive: " + responseCode);
		if (responseCode != 200)
		{
			var alert = new Alert({
				:timeout => 8000,
				:font => Graphics.FONT_SMALL,
				:text => mUrl + " returned " + responseCode + "\nEnsure a running server and correct app settings.",
				:fgcolor => Graphics.COLOR_RED,
				:bgcolor => Graphics.COLOR_BLACK
				});
			alert.pushView(WatchUi.SLIDE_UP);
			return;
		}
		if (data instanceof Dictionary)
		{
			var error = data["error"]; 
			if (error  instanceof Dictionary)
			{
				var alert = new Alert({
					:timeout => 8000,
					:font => Graphics.FONT_MEDIUM,
					:text => error["message"],
					:fgcolor => Graphics.COLOR_RED,
					:bgcolor => Graphics.COLOR_BLACK
					});
				alert.pushView(WatchUi.SLIDE_UP);
				return;
			}
		}
		if (mCallback != null)
		{
			mCallback.invoke(responseCode, data);
		}
	}
	
	function setParameter(parameter)
	{
		mParameter = parameter;
	}
	
	function get(path, callback)
	{
		call(path, Communications.HTTP_REQUEST_METHOD_GET, callback);
	}
	
	function post(path, callback)
	{
		call(path, Communications.HTTP_REQUEST_METHOD_POST, callback);
	}
	
	function call(path, method, callback)
	{
		var url = mUrl + path;
		var options = {
			:method => method,
			:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
			:headers => {	"Authorization" => "Bearer " + mToken,
							"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON}
		};
		mCallback = callback;		
		System.println("Call: " + url);		
		Communications.makeWebRequest(url, mParameter, options, method(:onReceive));
	}
	
}