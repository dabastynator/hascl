using Toybox.Application.Properties;
using Toybox.StringUtil;

class KodiWebCaller {

	var mUrl = "";	
	var mOptions;
	var mParameter = null;
	var mCallback = null;
	
	function initialize()
	{
		mUrl = Properties.getValue("kodi_endpoint") + "/jsonrpc";
		var user = Properties.getValue("kodi_user");
		var pwd = Properties.getValue("kodi_pwd");
		var token = StringUtil.encodeBase64(user + ":" + pwd);  
		System.println("Read koid properties:");
		System.println(" Url: " + mUrl);
		System.println(" Access: " + user + ":" + pwd);
		System.println(" Token: " + token);
		
		mOptions = {
			:method => Communications.HTTP_REQUEST_METHOD_POST,
			:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
			:headers => {	"Authorization" => "Basic " + token,
							"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON}
		};
	}
	
	function onReceive(responseCode, data)
	{
		System.println("WebCaller::onReceive: " + responseCode);
		if (responseCode != 200)
		{
			var alert = new Alert({
				:timeout => 8000,
				:font => Graphics.FONT_SMALL,
				:text => mUrl + " returned " + responseCode + "\nEnsure a running kodi and correct app settings.",
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
	
	function callParam(method, param, callback)
	{
		mCallback = callback;
		System.println("Call: " + mUrl);
		var parameter = {
		    "jsonrpc" => "2.0",
		    "method" => method,
		    "id" => 1,
		};
		parameter["params"] = param;
		Communications.makeWebRequest(mUrl, parameter, mOptions, method(:onReceive));
	}

	function call(method, callback)
	{
		mCallback = callback;
		System.println("Call: " + mUrl);
		var parameter = {
		    "jsonrpc" => "2.0",
		    "method" => method,
		    "id" => 1
		};		
		Communications.makeWebRequest(mUrl, parameter, mOptions, method(:onReceive));
	}
	
}
