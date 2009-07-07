/**
 * Wrapper for a SimpleButton and a text field to make a simple asset-less button.
 * By design, the button appears as a rounded rectangle.
 */

package controller
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import assetLib.ColorLib;

	public class GameButton extends SimpleButton
	{
		/* Default metrics */
		protected const DEFAULT_W:Number = 221;
		protected const DEFAULT_H:Number = 40;
		protected const DEFAULT_RAD:Number = 20;
		protected const DEFAULT_FONT_SIZE:Number = 18;
		/** Local reference to font color const */
		protected const FONT_COLOR:uint = ColorLib.DARK_TEXT;
		
		/* Background metrics */
		protected var w:Number;
		protected var h:Number;
		protected var rad:Number;
		protected var fontSize:Number;
		
		/** The label text for the button */
		protected var _label:String;
		/** The TextFormat for the label field */
		protected var _textFormat:TextFormat;
		
		
		/**
		 * Constructor
		 * 
		 * @param label     The text for this button
		 * @param upColor   The color for this button in the 'up' state
		 * @param overColor The color for this button in the 'over' state
		 * @param downColor The color for this button in the 'down' state
		 */
		public function GameButton(label:String, upColor:uint, overColor:uint, downColor:uint)
		{
			_label = label;
			defineMetrics();
			
			var upState:Sprite = drawRect(upColor) as Sprite;
			var overState:Sprite = drawRect(overColor) as Sprite;
			var downState:Sprite = drawRect(downColor) as Sprite;
			var hitTestState:Sprite = drawRect(0) as Sprite;
			
			super(upState, overState, downState, hitTestState);
		}
		
		/**
		 * Set the label
		 * 
		 * @param value The new text for the button
		 */
		public function set label(value:String):void
		{
			_label = value;
		}
		
		/**
		 * Delegate the internal button click event
		 * 
		 * @param e The MouseEvent
		 */
		public function onMouseClick(e:MouseEvent):void
		{
			dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		/**
		 * Draw the rounded rect that serves as background for this button
		 * 
		 * @param color The color for the rect
		 * 
		 * @return A sprite of the rect (cast as DisplayObject)
		 */
		protected function drawRect(color:uint):DisplayObject
		{
			var display:Sprite = new Sprite();
			display.graphics.beginFill(color, 1);
			display.graphics.drawRoundRect(0, 0, w, h, rad, rad);
			display.graphics.endFill();
			
			display.addChild(createTextField(display));
			return display;
		}
		
		/**
		 * Create the button text field
		 * 
		 * @param display The sprite into which we're drawing the TextField
		 * 
		 * @return The TextField
		 */
		protected function createTextField(display:Sprite):TextField
		{
			var textField:TextField = new TextField();
			textField.embedFonts = true;
			textField.text = _label;
			textField.selectable = false;
			textField.setTextFormat(getTextFormat());
			
			textField.width = display.width;
			textField.height = textField.textHeight + textField.getLineMetrics(0).descent;
			textField.y = (display.height / 2) - textField.height / 2;
			return textField;
		}
		
		/**
		 * Get the current TextFormat, or use the default one
		 * 
		 * @return The current TextFormat
		 */
		protected function getTextFormat():TextFormat
		{
			if (_textFormat == null)
			{
				_textFormat = new TextFormat();
				_textFormat.font = "_GameFont";
				_textFormat.color = FONT_COLOR;
				_textFormat.align = "center";
				_textFormat.size = fontSize;
			}
			return _textFormat;
		}
		
		/**
		 * Define the metrics. 
		 * 
		 * Abstracted from constructor to allow subclasses to override default values.
		 */
		protected function defineMetrics():void
		{
			if (isNaN(w))
			{
				w = DEFAULT_W;
				h = DEFAULT_H;
				rad = DEFAULT_RAD;
				fontSize = DEFAULT_FONT_SIZE;
			}
		}
	}
}