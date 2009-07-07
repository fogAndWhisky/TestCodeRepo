/**
 * The box used to display Modal information
 */

package view
{
	import flash.display.Sprite;
	
	import gs.TweenGroup;
	import gs.TweenLite;
	import gs.easing.Bounce;
	import gs.utils.tween.TweenLiteVars;
	
	public class ExpandingInfoBox extends InfoBox
	{
		/** Time (seconds) for a tween to occur */
		protected const TWEEN_TIME:Number = .5;
		/** Time (ms) between sequence events */
		protected const STAGGER_TIME:Number = 1;
		/** A mask around the text */
		protected var textMask:Sprite;
		/** Height of the window, minus spacers for clean layout */
		public var boxHeight:Number;
		/** Width of the window, minus spacers for clean layout */
		public var boxWidth:Number;
		/** Sequence of tweens to make window animate nicely */
		protected var tweenGroup:TweenGroup;
		/** An array of messages to be displayed in order */
		protected var msgSequence:Array;
		
		/**
		 * Constructor
		 * 
		 * @param w             The width of the dialog
		 * @param h             The height of the dialog
		 * @param msg           The text to display
		 * @param autoDismissMS (optional) Milliseconds until message auto-dismisses. Default 0.
		 * @param buttonRank	(optional) An array of InfoButtons to display in this view
		 * @param msgSequence	(optional) An array of messages to add to the sequence
		 */
		public function ExpandingInfoBox(	w:Number, h:Number, msg:String, 
											autoDismissMS:uint=0, buttonRank:Array=null,
											msgSequence:Array = null)
		{
			h = 5;
			boxWidth = w;
			this.msgSequence = msgSequence;
			
			super(w, h, msg, autoDismissMS, buttonRank);
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
		override protected function buildContent(w:Number, h:Number, msg:String, 
												 autoDismissMS:uint = 0, buttonRank:Array = null):void
		{
			super.buildContent (w, h, msg, autoDismissMS, buttonRank);
			boxHeight = h = textField.textHeight + (SPACER * 2);
			
			textMask = new Sprite();
			addChild(textMask);
			
			drawBox();
			
			textField.mask = textMask;
			
			tweenGroup = new TweenGroup();
			tweenGroup.align = TweenGroup.ALIGN_SEQUENCE;
			tweenGroup.stagger = STAGGER_TIME;
			
			var tween:TweenLite;
			var mainTweenVars:TweenLiteVars;
			mainTweenVars = new TweenLiteVars();
			mainTweenVars.onUpdate = onExpandBox;
			
			
			var tweenVars:TweenLiteVars;
			var newBoxHeight:Number;
			var len:uint = msgSequence.length;
			for (var a:Number = 0; a < len; a++)
			{
				tweenVars = mainTweenVars.clone();
				if (a == 0)
					tweenVars.delay = TWEEN_TIME * 4;
				textField.htmlText += "<br />" + msgSequence[a];
				newBoxHeight = textField.textHeight + (SPACER * 2);
				
				tweenVars.boxHeight = newBoxHeight;
				tween = new TweenLite(this, TWEEN_TIME, tweenVars);
				tweenGroup.push(tween);
			}
			
			if (buttonRank)
			{
				tweenVars = mainTweenVars.clone();
				newBoxHeight = textField.textHeight + buttonBank.height + (SPACER * 3);
				
				tweenVars.boxHeight = newBoxHeight;
				tween = new TweenLite(this, TWEEN_TIME, tweenVars);
				tweenGroup.push(tween);
				
				tween = new TweenLite(buttonBank, TWEEN_TIME, {alpha: 1});
				tweenGroup.push(tween);
				
				buttonBank.alpha = 0;
			}
		}
		
		/**
		 * Event from Tween. Motion change.
		 */
		protected function onExpandBox():void
		{
			drawBox();
		}
		
		/**
		 * Render the background and the text mask. Position the text field.
		 */
		protected function drawBox():void
		{
			bg.graphics.clear();
			bg.graphics.beginFill(bgColor, .5);
			bg.graphics.lineStyle(lineWieght, lineColor, .75, true);
			bg.graphics.drawRoundRectComplex(-boxWidth/2, -boxHeight/2, boxWidth, boxHeight, 
										  		 bigRad, smallRad, smallRad, bigRad);
			bg.graphics.endFill();
			
			textMask.graphics.clear();
			textMask.graphics.beginFill(bgColor, .5);
			textMask.graphics.lineStyle(lineWieght, lineColor, .75, true);
			textMask.graphics.drawRect(-boxWidth/2, -boxHeight/2, boxWidth, boxHeight);
			textMask.graphics.endFill();
			
			textField.height = textField.textHeight + SPACER;
			textField.y = (-boxHeight + SPACER)/2;
			buttonBank.y = textField.y + textField.textHeight + SPACER;
		}
	}
}