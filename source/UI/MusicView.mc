using Toybox.WatchUi;

class Button {

	private var mImage;
	private var mX;
	private var mY;
	private var mVisible = true;

	function initialize(resource, x, y)
	{
		mImage = WatchUi.loadResource( resource );
		mX = x;
		mY = y;
	}

	function draw(dc)
	{
		if (mVisible)
		{
			var x = mX * dc.getWidth() - mImage.getWidth() / 2;
			var y = mY * dc.getHeight() - mImage.getHeight() / 2;
			dc.drawBitmap(x, y, mImage);
		}
	}

	function visible(v)
	{
		mVisible = v;
	}

}

class MarqueeText {

	private var mText = "";
	private var mStatus = 0;
	private var mY = 0;
	public var mX = 0;
	private var mColor;
	private var mColorBg = Graphics.COLOR_BLACK;
	private var mLeft;
	private var mRight;
	private var mStayDuration = 1;
	private var mSpeed = 80; // In pixel per second
	private var mDirty = true;
	private var mWidth = 0;
	private var mFont = Graphics.FONT_SMALL;
	public var mBrightness = 1;


	function initialize(left, right, y, color)
	{
		mY = y;
		mLeft = left;
		mRight = right;
		mColor = color;
	}

	function setText(text)
	{
		mText = text;
		mDirty = true;
	}

	function handleState()
	{
		if (mDirty)
		{
			mDirty = false;
			mStatus = 0;
		} else {
			mStatus = (mStatus + 1) % 3;
		}
		if (mWidth > mRight - mLeft)
		{
			var from = mLeft;
			var to = mRight - mWidth;
			if (mStatus == 0)
			{
				mX = from;
				WatchUi.animate(self, :mBrightness, WatchUi.ANIM_TYPE_LINEAR, 0, 1, mStayDuration, method(:handleState));
			}
			if (mStatus == 1)
			{
				var duration = (from-to).abs() / mSpeed;
				if (duration < mStayDuration)
				{
					duration = mStayDuration;
				}
				WatchUi.animate(self, :mX, WatchUi.ANIM_TYPE_LINEAR, from, to, duration, method(:handleState));
			}
			if (mStatus == 2)
			{
				mX = to;
				WatchUi.animate(self, :mBrightness, WatchUi.ANIM_TYPE_LINEAR, 1, 0, mStayDuration, method(:handleState));
			}
		} else {
			mBrightness = 1;
			mX= mLeft + (mRight - mLeft - mWidth) / 2;
			WatchUi.requestUpdate();
		}
	}

	function draw(dc)
	{
		if (mDirty)
		{
			mWidth = dc.getTextWidthInPixels(mText, mFont);
			handleState();
		}
		var y = mY * dc.getHeight();
		var b = 5 * mBrightness;
		if (b > 1)
		{
			b = 1;
		}
		var color = (255 * b * mColor).toNumber();
		color = color | (color << 8) | (color << 16);
		dc.setColor(color, mColorBg);
		dc.drawText(mX, y, mFont, mText, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
	}

}

class MusicView extends WatchUi.View {

	var mMarqueeArtist;
	var mMarqueeTitle;
	var mButtons = [];
	var mVolume = -1;
	var mTimer;

	function initialize()
	{
		View.initialize();

		mButtons.add(new Button(Rez.Drawables.stop, 0.2, 0.58));
		mButtons.add(new Button(Rez.Drawables.play, 0.5, 0.58));
		mButtons.add(new Button(Rez.Drawables.pause, 0.5, 0.58));
		mButtons.add(new Button(Rez.Drawables.next, 0.8, 0.58));
		mButtons.add(new Button(Rez.Drawables.vol_down, 0.33, 0.82));
		mButtons.add(new Button(Rez.Drawables.vol_up, 0.67, 0.82));
		mButtons[2].visible(false);

		var marginTitle = 0.154 * CircleButtonView.Width;
		var marginArtist = 0.038 * CircleButtonView.Width;
		mMarqueeArtist = new MarqueeText(marginTitle, CircleButtonView.Width - marginTitle, 0.23, 1);
		mMarqueeTitle = new MarqueeText(marginArtist, CircleButtonView.Width - marginArtist, 0.38, 0.5);

		mTimer = new Timer.Timer();
	}

	function onShow()
	{
	}

	function onHide()
	{
		mTimer.stop();
	}

	// Update the view
	function onUpdate(dc)
	{
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.clear();
		for (var i = 0; i < mButtons.size(); i++) {
			var button = mButtons[i];
			button.draw(dc);
		}
		mMarqueeArtist.draw(dc);
		mMarqueeTitle.draw(dc);
		if (mVolume > 0)
		{
			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
			if (mVolume < 70)
			{
				dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_BLACK);
			}
			if (mVolume < 50)
			{
				dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
			}
			if (mVolume < 30)
			{
				dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
			}
			dc.setPenWidth(9);
			var degreeSize = mVolume * 3.6;
			var center = dc.getWidth() / 2;
			dc.drawArc(center, center, center - 2, Graphics.ARC_CLOCKWISE, 90, 90 - degreeSize);
		}
	}

	function hideVolume()
	{
		mVolume = -1;
		WatchUi.requestUpdate();
	}

	function setVolume(volume)
	{
		mVolume = volume;
		mTimer.stop();
		mTimer.start(method(:hideVolume), 1000, false);
		WatchUi.requestUpdate();
	}

	function onUpdateMusic(code, data)
	{
		var artist = "---";
		var title = "---";
		mButtons[1].visible(true);
		mButtons[2].visible(false);
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
				mButtons[1].visible(false);
				mButtons[2].visible(true);
			}
			setVolume(current["volume"]);
		}
		if (WatchUi has :cancelAllAnimations)
		{
			WatchUi.cancelAllAnimations();
		}
		mMarqueeArtist.setText(artist);
		mMarqueeTitle.setText(title);
		WatchUi.requestUpdate();
	}

}
