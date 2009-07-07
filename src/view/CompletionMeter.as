/**
 * Sprite representing a meter of user progress through a level
 */

package view
{
	import assetLib.ColorLib;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class CompletionMeter extends Sprite
	{
		/** Text folor */
		protected const fgColor:uint = ColorLib.DARK_TEXT;
		/** Color for the meter fill */
		protected const METER_COLOR:uint = ColorLib.METER_FILL;
		/** Line width of the the keyline */
		protected const KEYLINE_WIDTH:Number = 3;
		/** Corner radius */
		protected const CORNER_RADIUS:Number = 20;
		/** Sprite representing a line around the meter */
		protected var keylineSprite:Sprite;
		/** Sprite representing the actual metered progress */
		protected var meterSprite:Sprite;
		/** Sprite masking the meter */
		protected var maskSprite:Sprite;
		
		/* Textfields */
		protected var firstNumTextField:TextField;
		protected var thresholdNumTextField:TextField;
		protected var lastNumTextField:TextField;
		/** Format for the textfields */
		protected var _textFormat:TextFormat;
		
		/**
		 * Constructor
		 * 
		 * @param w Width for the meter
		 * @param h Height for the meter
		 */
		public function CompletionMeter(w:Number, h:Number)
		{
			super();
			
			_textFormat = new TextFormat();
			_textFormat.align = TextFormatAlign.CENTER;
			_textFormat.color = fgColor;
			_textFormat.size = 12;
			_textFormat.font = "_GameFont";
			
			firstNumTextField = createTextField();
			thresholdNumTextField = createTextField();
			lastNumTextField = createTextField();
			
			firstNumTextField.text = "0";
			thresholdNumTextField.text = "?";
			lastNumTextField.text = "??";
			
			firstNumTextField.x = 0;
			thresholdNumTextField.x = (w / 2) - thresholdNumTextField.textWidth;
			lastNumTextField.x = w - lastNumTextField.textWidth;
			
			createMeterAndMask(w, h);
			
			createKeyline(w, h);
			meterSprite.y = keylineSprite.y;
			
			addChild(firstNumTextField);
			addChild(thresholdNumTextField);
			addChild(lastNumTextField);
		}
        
       /**
        * Update level information
        * 
        * @param destroyed	Items destroyed so far
        * @param required	Items required to achieve success threshold
        * @param total		Total items on this level
        */
       public function update(destroyed:uint, required:uint, total:uint):void
       {
       		var w:Number = keylineSprite.width * (destroyed / total);
       		var h:Number = keylineSprite.height - (KEYLINE_WIDTH);
       		meterSprite.graphics.clear();
       		meterSprite.graphics.beginFill(METER_COLOR);
			meterSprite.graphics.drawRoundRect(0, KEYLINE_WIDTH/2, w, h, CORNER_RADIUS);
			meterSprite.graphics.endFill();
			
			firstNumTextField.text = "0";
			thresholdNumTextField.text = String(required);
			lastNumTextField.text = String(total);
			
			thresholdNumTextField.x = keylineSprite.width * (required / total) - thresholdNumTextField.textWidth;
			lastNumTextField.x = keylineSprite.width - lastNumTextField.textWidth;
       }
		
		/**
		 * Create a generic text field for the stats board
		 * 
		 * @param w Width for the keyline
		 * @param h Height for the keyline
		 */
		protected function createKeyline(w:Number, h:Number):void
		{
			keylineSprite = new Sprite();
			keylineSprite.graphics.lineStyle(KEYLINE_WIDTH, ColorLib.BLACK, 1, true);
			keylineSprite.graphics.drawRoundRect(0, 0, w, h, CORNER_RADIUS);
			keylineSprite.y = 20;
			addChild(keylineSprite);
		}
		
		/**
		 * Create a generic text field for the stats board
		 * 
		 * @param w Width for the keyline
		 * @param h Height for the keyline
		 */
		protected function createMeterAndMask(w:Number, h:Number):void
		{
			meterSprite = new Sprite();
			addChild(meterSprite);
			
			maskSprite = new Sprite();
			maskSprite.graphics.beginFill(ColorLib.BLACK);
			maskSprite.graphics.drawRoundRect(0, 0, w, h, CORNER_RADIUS);
			maskSprite.graphics.endFill();
			maskSprite.y = 20;
			addChild(maskSprite);
			
			meterSprite.mask = maskSprite;
		}
		
		/**
		 * Create a generic text field for the stats board
		 * 
		 * @return The created Textfield
		 */
		protected function createTextField():TextField
		{
			var textField:TextField = new TextField();
			textField.defaultTextFormat = _textFormat;
			textField.embedFonts = true;
			textField.text = "0";
			textField.selectable = false;
			textField.autoSize = TextFormatAlign.CENTER;
			return textField;
		}
	}
}