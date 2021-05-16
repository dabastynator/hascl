using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Attention;

class CircleButtonDelegate extends WatchUi.BehaviorDelegate {

	var mCallbacks = [];
	var mCenterCallback = null;
	var mView = null;

	function initialize(view)
	{
		mView = view;
		BehaviorDelegate.initialize();
	}
	
	function addCallback(callback)
	{
		mCallbacks.add(callback);
	}
	
	function onKey(event)
	{
		if (event.getKey() == WatchUi.KEY_ENTER)
		{
			if (mView.getIndex() < mCallbacks.size())
			{
				mCallbacks[mView.getIndex()].invoke();
			}
		}
		if (event.getKey() == WatchUi.KEY_UP)
		{
			mView.setIndex((mView.getIndex() + 1) % mCallbacks.size());
		}
		if (event.getKey() == WatchUi.KEY_DOWN)
		{
			mView.setIndex((mView.getIndex() + mCallbacks.size() - 1) % mCallbacks.size());
		}
	}
	
	function onTap (event)
	{
		var coords = event.getCoordinates();
		coords[0] = coords[0] - mView.Width / 2;
		coords[1] = coords[1] - mView.Height / 2;
		var maxDot = 0;
		var index = -1;
		var callback = null;
		for (var i = 0; i < mCallbacks.size(); i++) {
			var sin = Math.sin(2*i*Math.PI / mCallbacks.size());
			var cos = -Math.cos(2*i*Math.PI / mCallbacks.size());
			var dot = sin * coords[0] + cos * coords[1];
			if (dot > maxDot)
			{
				maxDot = dot;
				callback = mCallbacks[i];
				index = i;
			}
		}
		if (Math.sqrt(coords[0]*coords[0] + coords[1]*coords[1]) < mView.Width / 5)
		{
			callback = mCenterCallback;
			index = -1;
		}
		if (callback != null)
		{
			if (index > -1)
			{
				mView.setIndex(index);
			}
			if (Attention has :vibrate) {
				var vibeData = [
					new Attention.VibeProfile(25, 100), // On for 100 ms
				];
				Attention.vibrate(vibeData);
			}
			callback.invoke();
		}
	}

}

class CircleButtonView extends WatchUi.View {

	public static var Width;
	public static var Height;

	private var mImages = [];
	private var mIndex = 0;
	public var mArcAngle = 0;
	private var mMargin = 0.15;
	private var mCenterImage = null;
	private var mShowAnimation = false;
	public var mAppearAnimation = 0;
	private var mDelegate = null;
	private var mLineColor = 0x888888;

	function initialize()
	{
		View.initialize();
		mDelegate = new CircleButtonDelegate(self);
	}
	
	function calcArcAngle(index)
	{
		return -(index+0.5) * 360 / mImages.size() + 90;
	}
	
	function smoothstep(x)
	{
		if (x < 0)
		{
			return 0;
		} else if (x < 1)
		{
			return (3 - 2 * x) * x * x;
		} else {
			return 1;
		}
	}
	
	function smootherstep(x)
	{
		if (x < 0)
		{
			return 0;
		} else if (x < 1)
		{
			return (6 * x * x - 15 * x + 10) * x * x * x;
		} else {
			return 1;
		}
	}
	
	function setLineColor(lineColor)
	{
		mLineColor = lineColor;
	}
	
	function doShowAnimation(animation)
	{
		mShowAnimation = animation;
	}
	
	function setMargin(margin)
	{
		mMargin = margin;
	}

	// Add a resource like Rez.Drawables.id_monkey
	function addButton(resource, callback)
	{
		var image = WatchUi.loadResource(resource);
		mImages.add(image);
		mArcAngle = calcArcAngle(mIndex);
		mDelegate.addCallback(callback);
	}
	// Set a resource like Rez.Drawables.id_monkey
	function setCenter(resource, callback)
	{
		mCenterImage = WatchUi.loadResource( resource );
		mDelegate.mCenterCallback = callback;
	}

	function onShow()
	{
		if (mShowAnimation)
		{
			WatchUi.animate(self, :mAppearAnimation, WatchUi.ANIM_TYPE_LINEAR, 0, 1, 0.6, null);
		}else{
			mAppearAnimation = 1;
		}
	}

	function onUpdate(dc)
	{
		Width = dc.getWidth();
		Height = dc.getHeight();
		var centerX = dc.getWidth() / 2;
		var centerY = dc.getHeight() / 2;
		var margin = mMargin * Width;
	 
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.clear();
		
		if (mCenterImage != null)
		{
			dc.drawBitmap( centerX - mCenterImage.getWidth() / 2, centerY - mCenterImage.getHeight() / 2, mCenterImage );
		}
		
		dc.setColor(mLineColor, Graphics.COLOR_BLACK);
		dc.setPenWidth(1);
		var animationStep = smootherstep(mAppearAnimation);
		var rAnimationStep = 1 - animationStep; 
		for (var i = 0; i < mImages.size(); i++) {
			var image = mImages[i];
			var angle = 2 * i * Math.PI / mImages.size();
			var sin = Math.sin(angle);
			var cos = -Math.cos(angle);
			var marginFactor = 2 * smootherstep(1.5 * (mAppearAnimation * 2 - 1.0 * i / mImages.size())) - 1;
			var offX = sin * (centerX - margin * marginFactor);
			var offY = cos * (centerY - margin * marginFactor);
			dc.drawBitmap( centerX + offX - image.getWidth() / 2, centerY + offY - image.getHeight() / 2, image );
			
			angle = 2 * (i + 0.5) * Math.PI / mImages.size();
			sin = Math.sin(angle) * centerX;
			cos = -Math.cos(angle) * centerY;
			var splitLine = 0.5 + 0.5 * rAnimationStep;
			dc.drawLine(centerX + sin * splitLine, centerY + cos * splitLine, centerX + sin, centerY + cos);
		}
				
		dc.setPenWidth(5);
		var degreeSize = 360 / mImages.size();
		var from = mArcAngle + 0.5 * degreeSize * rAnimationStep;
		var to = mArcAngle + degreeSize * (0.5 + 0.5 * animationStep);  
		if (from < to)
		{
			dc.drawArc(centerX, centerY, centerX - 4, Graphics.ARC_COUNTER_CLOCKWISE, from, to);
		}		
	}
	
	function getIndex()
	{
		return mIndex;
	}
	
	function setIndex(index)
	{
		if (mIndex == index)
		{
			return;
		}
		mIndex = index;
		var newArcAngle = calcArcAngle(mIndex);
		while (newArcAngle - mArcAngle > 180)
		{
			newArcAngle = newArcAngle - 360;	
		}
		while (newArcAngle - mArcAngle < -180)
		{
			newArcAngle = newArcAngle + 360;
		}
		WatchUi.requestUpdate();
		WatchUi.cancelAllAnimations();
		WatchUi.animate(self, :mArcAngle, WatchUi.ANIM_TYPE_EASE_OUT, mArcAngle, newArcAngle, 0.3, null);
	}

	function onHide()
	{
	}
	
	function getDelegate()
	{
		return mDelegate;
	}

}
