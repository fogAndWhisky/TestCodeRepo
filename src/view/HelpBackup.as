/**
 * Purpose-built info box specifically for help window.
 */

package view
{
	import assetLib.ColorLib;
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.StyleSheet;
	import flash.text.TextFormatAlign;
	
	public class HelpBox extends InfoBox
	{
		
		protected const btnUpColor:uint = ColorLib.PARTICLE_4;
		protected const btnOverColor:uint = ColorLib.PARTICLE_2;
		protected const btnDownColor:uint = ColorLib.PARTICLE_3;
		protected const BTN_WIDTH:Number = 35;
		protected const BTN_HEIGHT:Number = 25;
		
		protected var styleSheet:StyleSheet;
		
		protected var maxCount:uint;
		
		protected var path:String;
		protected var label:String;
		protected var count:uint;
		
		protected var urlLoader:URLLoader;
		protected var urlRequest:URLRequest;
		
		protected var nextBtn:SimpleButton;
		protected var prevBtn:SimpleButton;
		
		/**
		 * Constructor
		 * 
		 * @param pages			Total number of pages for this help series
		 * @param w   			Width of the help window
		 * @param h   			Height of the help window
		 * @param msg 			Hijacked for this implementation to define the load path
		 * @param autoDismissMS (optional) Milliseconds until message auto-dismisses. Default 0.
		 */
		public function HelpBox(pages:uint, w:Number, h:Number, msg:String, autoDismissMS:uint = 0)
		{
			/* styleSheet = new StyleSheet();
			
			var img:Object = new Object();
			img.textAlign = "center";
			
			var a:Object = new Object();
			a.color = 0xFFFFFF;
			
			styleSheet.setStyle("a", a);
			styleSheet.setStyle("img", img); */
			
			
			
			super(w, h, "", autoDismissMS);
			
			textFormat.align = TextFormatAlign.LEFT;
			textField.defaultTextFormat = textFormat;
			
			path = msg;
			loadHelpFile(1);
			maxCount = pages;
			
			
			
			/* textField.styleSheet = styleSheet;  */
		}
		
		/**
		 * Load a help file
		 * 
		 * @param count The index number of the help file
		 */
		protected function loadHelpFile(count:uint):void
		{
			this.count = count;
			urlRequest = new URLRequest(path + String(count) + ".xml");
			urlLoader = new URLLoader(urlRequest);
			urlLoader.addEventListener(Event.COMPLETE, onTextLoaded);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		}
		
		/**
		 * Event from URLLoader. Text has loaded.
		 * 
		 * @param e The event from the URLLoader
		 */
		protected function onTextLoaded(e:Event):void
		{
			label = e.target.data;
			textField.height = bg.height - closeBtn.height - (SPACER * 3);
			textField.y = closeBtn.y + closeBtn.height + SPACER;
			textField.htmlText = label;
			
			textField.border = true;
			textField.borderColor = 0xff9900;
			
			if (!nextBtn)
			{
				nextBtn = drawPrevNextButton([btnUpColor, btnOverColor, btnDownColor, 0], 0, BTN_WIDTH, BTN_HEIGHT);
				prevBtn = drawPrevNextButton([btnUpColor, btnOverColor, btnDownColor, 0], 1, BTN_WIDTH, BTN_HEIGHT);
				
				addChild(nextBtn);
				addChild(prevBtn);
				
				prevBtn.x = - (width/2) + SPACER;
				nextBtn.x = prevBtn.x + prevBtn.width + SPACER;
				nextBtn.y = prevBtn.y = (bg.height/2) - (nextBtn.height + SPACER);
				
				nextBtn.addEventListener(MouseEvent.CLICK, next);
				prevBtn.addEventListener(MouseEvent.CLICK, previous);
			}
			
			checkEnabled();
			
			urlLoader.removeEventListener(Event.COMPLETE, onTextLoaded);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		}
		
		/**
		 * Get next page of help
		 * 
		 * @param e The mouse event
		 */
		protected function next(e:MouseEvent):void
		{
			if (count < maxCount)
			{
				count ++;
				loadHelpFile(count);
			}
		}
		
		/**
		 * Get previous page of help
		 * 
		 * @param e The mouse event
		 */
		protected function previous(e:MouseEvent):void
		{
			if (count > 1)
			{
				count --;
				loadHelpFile(count);
			}
		}
		
		/**
		 * Event from URLLoader. Error has occurred.
		 * 
		 * @param e The Error event
		 */
		protected function onLoadError(e:IOErrorEvent):void
		{
			label = "Sorry. Techie glitch. No help for you";
			label += e.toString();
			
			textField.text = label;
			
			urlLoader.removeEventListener(Event.COMPLETE, onTextLoaded);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		}
		
		/**
		 * Draw the next and back buttons.
		 * 
		 * These are hard-coded here to be triangles pointing right or left
		 * 
		 * @param colors    An array of 4 colors (uint) for the four button states in order:
		 * 					upColor, overColor, downColor, hitStateColor
		 * @param direction 0 for the next button and 1 for the prev button
		 * @param w         The width of the button
		 * @param h         The height of the button
		 * 
		 * @return The button instance
		 */
		protected function drawPrevNextButton(colors:Array, direction:uint, w:Number, h:Number):SimpleButton
		{
			if (colors.length != 4)
				throw new Error("Error drawing button. Colors array must contain exactly 4 uint values.");
			
			var sprites:Array = new Array();
			var spineX:Number = (direction) ? w : 0;
			var pointX:Number = (direction) ? 0 : w;
			var len:uint = colors.length;
			for (var a:uint = 0; a < len; a++)
			{
				var sprite:Sprite = new Sprite();
				var color:uint = colors[a];
				sprite.graphics.beginFill(color, 1);
				
				sprite.graphics.moveTo(spineX, 0);
				sprite.graphics.lineTo(pointX, h/2);
				sprite.graphics.lineTo(spineX, h);
				sprite.graphics.lineTo(spineX, 0);
				
				sprite.graphics.endFill();
				sprites.push(sprite);
			}
			var btn:SimpleButton = new SimpleButton(sprites[0], sprites[1], sprites[2], sprites[3]);
			return btn;
		}
		
		/**
		 * Check the previous and next buttons for enabled state
		 */
		protected function checkEnabled():void
		{
			if (count == 1)
			{
				prevBtn.enabled = false;
				prevBtn.alpha = .1;
			}
			else
			{
				prevBtn.enabled = true;
				prevBtn.alpha = 1;
			}
			
			if (count == maxCount)
			{
				nextBtn.enabled = false;
				nextBtn.alpha = .1;
			}
			else
			{
				nextBtn.enabled = true;
				nextBtn.alpha = 1;
			}
		}
	}
}