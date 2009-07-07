/**
 * Display for an on-field text effect showing how many points a given explosion was worth
 */

package view
{
	import assetLib.ColorLib;
	
	import gs.TweenLite;
	import gs.easing.Strong;
	
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;


	public class ScoreItem extends Sprite
	{
		/***********
		 * Protected consts
		 ***********/
		/** Hard-coded font size */
		protected const FONT_SIZE:Number = 18;
		/** Distance to migrate */
		protected const Y_MOVE:Number = -15;
		/** Time in seconds to tween */
		protected const TWEEN_SECONDS:Number = 1.75;
		
		/***********
		 * Protected members
		 ***********/
		/** The TextFormat for the label field */
		protected var _textFormat:TextFormat;
		/** The text to display */
		protected var textField:TextField;
		/** Tween to animate the sprite alpha and y position */
		protected var aTween:TweenLite;
		
		/**
		 * Constructor
		 * 
		 * @param label The text for this display item
		 * @param x     X position for this item
		 * @param y		Y position for this item
		 */
		public function ScoreItem(label:String, x:Number, y:Number)
		{
			super();
			this.x = x;
			this.y = y;
			
			_textFormat = new TextFormat();
			_textFormat.font = "_GameFont";
			_textFormat.color = ColorLib.SCORE_ITEM;
			_textFormat.align = "center";
			_textFormat.size = FONT_SIZE;
			
			textField = new TextField();
			textField.height = 20;
			textField.embedFonts = true
			textField.selectable = false;
			textField.defaultTextFormat = _textFormat;
			textField.text = label;
			
			textField.x = -textField.width/2;
			textField.y = -textField.height/2;
			
			addChild(textField);
			
			
			
			aTween = TweenLite.to(this, TWEEN_SECONDS, {y: 			y + Y_MOVE,
														alpha:		0,
														onComplete:	onTweenComplete,
														ease:		Strong.easeOut});
			
			var glowFilter:GlowFilter = new GlowFilter();
			filters = [glowFilter];
		}
		
		/**
		 * Event from aTween. Tween complete. Get rid of this display item
		 */
		protected function onTweenComplete():void
		{
			this.parent.removeChild(this);
			delete this;
		}
	}
}