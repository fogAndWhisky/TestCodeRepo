/**
 * Base class for infomation alerts
 */

package view
{
	import assetLib.ColorLib;
	
	import controller.InfoButton;
	
	import flash.display.Bitmap;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import gs.TweenMax;
	import gs.utils.tween.BlurFilterVars;
	import gs.utils.tween.TweenMaxVars;
	import gs.easing.Strong;

	public class InfoBox extends Sprite
	{
		/***********
		 * Protected consts
		 ***********/
		/** Spacer for clean layout */
		protected const SPACER:Number = 10;
		/** Larger corner radius */
		protected const bigRad:Number = 15;
		/** Smaller corner radius */
		protected const smallRad:Number = 5;
		
		/* Local references to colors */
		protected const bgColor:uint = ColorLib.BLACK;
		protected const lineColor:uint = ColorLib.LIGHT_TEXT;
		protected const textColor:uint = ColorLib.LIGHT_TEXT;
		/** Box keyline weight */
		protected const lineWieght:uint = 3;
		
		/***********
		 * Protected members
		 ***********/
		/** Close button */
		protected var closeBtn:SimpleButton;
		/** Textfield for display text */
		protected var textField:TextField;
		/** Format for the text if the textField */
		protected var textFormat:TextFormat;
		
		/** Background */
		protected var bg:Sprite;
		/** Timer for auto-dismiss */
		protected var dismissTimer:Timer;
		/** Optional list of buttons when user action required */
		protected var buttonBank:Sprite;
		
		/** Filter for cool fade in */
		protected var blurFilter:BlurFilter;
		public var blurValue:Number;
		
		/** Embedded PNG for the UP state of the close button */
		[Embed (source="images/close_up.png")]
		private var CloseUp:Class;
		/** Embedded PNG for the DOWN state of the close button */
		[Embed (source="images/close_over.png")]
		private var CloseDown:Class;
		
		/** Tween managing the blur effect */
		protected var blurTween:TweenMax;
		/** The controlling tween of a dismiss */
		protected var aTween:TweenMax;
		
		/**
		 * Constructor
		 * 
		 * @param w             The width of the dialog
		 * @param h             The height of the dialog
		 * @param msg           The text to display
		 * @param autoDismissMS (optional) Milliseconds until message auto-dismisses. Default 0,
		 * 						which indicates no auto-dismiss.
		 * @param buttonRank	(optional) An array of InfoButtons to display in this view
		 */
		public function InfoBox(w:Number, h:Number, msg:String, 
								autoDismissMS:uint = 0, buttonRank:Array = null)
		{
			super();
			bg = new Sprite();
			bg.graphics.beginFill(bgColor, .5);
			bg.graphics.lineStyle(lineWieght, lineColor, .75, true);
			bg.graphics.drawRoundRectComplex(-w/2, -h/2, w, h, 
										  		 bigRad, smallRad, smallRad, bigRad);
			bg.graphics.endFill();
			addChild(bg);
			
			var closeUpSprite:Bitmap = new CloseUp();
			var closeDownSprite:Bitmap = new CloseDown();
			closeBtn = new SimpleButton(closeUpSprite, closeDownSprite, closeDownSprite, closeDownSprite);
			closeBtn.x = - (bg.width / 2) + SPACER;
			closeBtn.y = - (bg.height / 2) + SPACER;
			closeBtn.addEventListener(MouseEvent.CLICK, onCloseBtnClick);
			addChild(closeBtn);
			
			buildContent(w, h, msg, autoDismissMS, buttonRank);
		}
		
		/**
		 * Fill in the contents of the window
		 * 
		 * @param w 			Window width
		 * @param h 			Window height
		 * @param msg 			Text to display
		 * @param autoDismiss 	(optional) Milliseconds until message auto-dismisses. Default 0.
		 * @param buttonRank 	(optional) An array of InfoButtons to display in this view
		 */
		protected function buildContent(w:Number, h:Number, msg:String, 
										autoDismissMS:uint = 0, buttonRank:Array = null):void
		{
			
			
			textFormat = new TextFormat();
			textFormat.align = TextFormatAlign.CENTER;
			textFormat.color = textColor;
			textFormat.size = 18;
			textFormat.font = "_GameFont";
			
			textField = new TextField();
			textField.multiline = true;
			textField.wordWrap = true;
			textField.condenseWhite = true;
			textField.antiAliasType = "advanced";
			textField.defaultTextFormat = textFormat;
			textField.embedFonts = true;
			textField.htmlText = msg;
			textField.selectable = false;
			textField.width = bg.width - (SPACER * 2);
			textField.height =  textField.textHeight + 
								textField.getLineMetrics(textField.numLines-1).descent;
			textField.x = - (width/2) + SPACER;
			
			if (buttonRank)
			{
				closeBtn.visible = false;
				buttonBank = new Sprite();
				var len:uint = buttonRank.length;
				for (var a:uint = 0; a < len; a++)
				{
					var button:InfoButton = buttonRank[a] as InfoButton;
					button.y = (button.height + SPACER) * a;
					buttonBank.addChild(button);
				}
				buttonBank.x = -buttonBank.width / 2;
				buttonBank.y = (height / 2) - (buttonBank.height + SPACER);
				addChild(buttonBank);
				
				textField.y = closeBtn.y + closeBtn.height + SPACER;
			}
			else
			{
				textField.y = - (textField.textHeight/2);
			}
			
			addChild(textField);
			
			
			if (autoDismissMS)
				setAutoDismissTimer(autoDismissMS);
				
			summon();
		}
		
		
		/**
		 * Animate in this infobox
		 */
		public function summon():void
		{
			var startVars:TweenMaxVars = new TweenMaxVars();
			startVars.autoAlpha = 0;
			startVars.scaleX = 0;
			startVars.scaleY = 0;
			
			var tweenVars:TweenMaxVars = new TweenMaxVars();
			tweenVars.autoAlpha = 1;
			tweenVars.scaleX = 1;
			tweenVars.scaleY = 1;
			tweenVars.ease = Strong.easeInOut;
			tweenVars.startAt = startVars;
			
			var startBlurFilterVars:BlurFilterVars = new BlurFilterVars(255, 0, 1);
			var endBlurFilterVars:BlurFilterVars = new BlurFilterVars(0, 0, 1);
			var blurTweenVars:TweenMaxVars = new TweenMaxVars();
			blurTweenVars.blurFilter = endBlurFilterVars;
			blurTweenVars.ease = Strong.easeIn;
			blurTweenVars.startAt = new TweenMaxVars({blurFilter: startBlurFilterVars});
			
			
			aTween = TweenMax.to(this, 2, tweenVars);
			blurTween = TweenMax.to(this, 1, blurTweenVars);
		}
		
		/**
		 * Dismiss this infobox
		 */
		public function dismiss():void
		{
			if (dismissTimer)
			{
				dismissTimer.removeEventListener(TimerEvent.TIMER, onTimerComplete);
				dismissTimer.stop();
			}
			
			var startVars:TweenMaxVars = new TweenMaxVars();
			startVars.autoAlpha = alpha;
			startVars.scaleX = scaleX;
			startVars.scaleY = scaleY;
			
			var tweenVars:TweenMaxVars = new TweenMaxVars();
			tweenVars.autoAlpha = 0;
			tweenVars.scaleX = 0;
			tweenVars.scaleY = 0;
			tweenVars.ease = Strong.easeInOut;
			tweenVars.startAt = startVars;
			
			var startBlurFilterVars:BlurFilterVars = new BlurFilterVars(0, 0, 1);
			var endBlurFilterVars:BlurFilterVars = new BlurFilterVars(255, 0, 1);
			var blurTweenVars:TweenMaxVars = new TweenMaxVars();
			blurTweenVars.blurFilter = endBlurFilterVars;
			blurTweenVars.ease = Strong.easeOut;
			blurTweenVars.startAt = new TweenMaxVars({blurFilter: startBlurFilterVars});
			
			
			aTween = TweenMax.to(this, 2, tweenVars);
			blurTween = TweenMax.to(this, 1, blurTweenVars);
		}
		
		/**
		 * Deconstruct this alert
		 */
		public function destroy():void
		{
			parent.removeChild(this);
			delete this;
		}
		
		/**
		 * Event from aTween. Animation complete. Remove this alert.
		 * 
		 * @param e The Tween event
		 */
		protected function onDismissComplete():void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Event from close button. User has asked for close.
		 * 
		 * @param e The MouseEvent.CLICK event
		 */
		protected function onCloseBtnClick(e:MouseEvent):void
		{
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		/**
		 * Start the autoDismiss timer
		 * 
		 * @param autoDismissMS The number of milliseconds until we dismiss
		 */
		protected function setAutoDismissTimer(autoDismissMS:uint):void
		{	
			dismissTimer = new Timer(autoDismissMS);
			dismissTimer.addEventListener(TimerEvent.TIMER, onTimerComplete);
			dismissTimer.start();
		}
		
		/**
		 * Event from auto dismiss timer. Timeout complete. Time to dismiss.
		 * 
		 * @param e The TimerEvent.TIMER_COMPLETE event
		 */
		protected function onTimerComplete(e:TimerEvent):void
		{
			dismissTimer.removeEventListener(TimerEvent.TIMER, onTimerComplete);
			dismiss();
		}
	}
}