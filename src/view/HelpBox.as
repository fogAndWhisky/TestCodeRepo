/**
 * Purpose-built info box specifically for the instructions/learing window.
 * 
 * Loads a swf containing help information.
 */

package view
{
	import assetLib.ColorLib;
	
	import gs.TweenLite;
	import gs.easing.Strong;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.StyleSheet;
	
	public class HelpBox extends InfoBox
	{
		/***********
		 * Protected consts
		 ***********/
		/* Local references to colors */
		protected const btnUpColor:uint = ColorLib.PARTICLE_4;
		protected const btnOverColor:uint = ColorLib.PARTICLE_2;
		protected const btnDownColor:uint = ColorLib.PARTICLE_3;
		
		/** Width of a button */
		protected const BTN_WIDTH:Number = 35;
		/** Height of a button */
		protected const BTN_HEIGHT:Number = 25;
		
		/***********
		 * Protected consts
		 ***********/
		/** Total number of pages in loaded swf */
		protected var maxCount:uint;
		/** Path of the swf */
		protected var path:String;
		/** String of info text (used only for a load error here */
		protected var label:String;
		/** Current page of the loaded swf */
		protected var count:uint;
		/* loader and urlRequest classes */
		protected var loader:Loader;
		protected var urlRequest:URLRequest;
		/** The loaded swf itself */
		protected var contentSwf:MovieClip;
		/** Tween used to move the contentSwf around */
		protected var contentTween:TweenLite;
		/** Btn for navigating contentSwf */
		protected var nextBtn:SimpleButton;
		/** Btn for navigating contentSwf */
		protected var prevBtn:SimpleButton;
		
		/**
		 * Constructor
		 * 
		 * @param w   			Width of the help window
		 * @param h   			Height of the help window
		 * @param path 			The load path
		 */
		public function HelpBox(w:Number, h:Number, path:String)
		{
			this.path = path;
			super(w,h,"");
		}
		
		/**
		 * No building. Just load the provided swf URL.
		 * 
		 * @param w             The width of the dialog
		 * @param h             The height of the dialog
		 * @param msg           The text to display
		 * @param autoDismissMS (optional) Milliseconds until message auto-dismisses. Default 0,
		 * 						which indicates no auto-dismiss.
		 * @param buttonRank	(optional) An array of InfoButtons to display in this view
		 */
		override protected function buildContent(w:Number, h:Number, msg:String, 
										autoDismissMS:uint = 0, buttonRank:Array = null):void
		{	
			loadFile();
			summon();
		}
		
		/**
		 * Load a help file
		 */
		protected function loadFile():void
		{
			urlRequest = new URLRequest(path);
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSwfLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.load(urlRequest);
			addChild(loader);
		}
		
		/**
		 * Event from URLLoader. Text has loaded.
		 * 
		 * @param e The Event.COMPLETE event
		 */
		protected function onSwfLoaded(e:Event):void
		{
			contentSwf = e.currentTarget.content as MovieClip;
			contentSwf.x = -(bg.width / 2) + (SPACER/2);
			contentSwf.y = -(bg.height / 2) + (SPACER/2);;
			
			count = 1;
			maxCount = contentSwf.maxCount;

			nextBtn = drawPrevNextButton([btnUpColor, btnOverColor, btnDownColor, 0], 0, BTN_WIDTH, BTN_HEIGHT);
			prevBtn = drawPrevNextButton([btnUpColor, btnOverColor, btnDownColor, 0], 1, BTN_WIDTH, BTN_HEIGHT);
			
			addChild(nextBtn);
			addChild(prevBtn);
			
			prevBtn.x = - (width/2) + SPACER;
			nextBtn.x = prevBtn.x + prevBtn.width + SPACER;
			nextBtn.y = prevBtn.y = (bg.height/2) - (nextBtn.height + SPACER);
			
			nextBtn.addEventListener(MouseEvent.CLICK, next);
			prevBtn.addEventListener(MouseEvent.CLICK, previous);
			
			checkEnabled();
			
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onSwfLoaded);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			
			this.setChildIndex(closeBtn, this.numChildren - 1);
		}
		
		/**
		 * Get next page of help
		 * 
		 * @param e The MouseEvent.CLICK event
		 */
		protected function next(e:MouseEvent):void
		{
			var pageMC:MovieClip;
			var contentMC:MovieClip = contentSwf.contentMC;
			pageMC = contentMC["c" + count + "MC"];
			pageMC.endAnimation();
			count ++;
			pageMC = contentMC["c" + count + "MC"];
			pageMC.startAnimation();
			
			contentTween = new TweenLite(contentMC, 1, {x:  SPACER - (bg.width * (count - 1)),
														ease: Strong.easeOut});
			checkEnabled();
		}
		
		/**
		 * Get previous page of help
		 * 
		 * @param e The MouseEvent.CLICK event
		 */
		protected function previous(e:MouseEvent):void
		{
			var pageMC:MovieClip;
			var contentMC:MovieClip = contentSwf.contentMC;
			pageMC = contentMC["c" + count + "MC"];
			pageMC.endAnimation();
			count --;
			pageMC = contentMC["c" + count + "MC"];
			pageMC.startAnimation();
			
			contentTween = new TweenLite(contentMC, 1, {x:    SPACER - (bg.width * (count - 1)),
														ease: Strong.easeOut});
			checkEnabled();
		}
		
		/**
		 * Event from URLLoader. Error has occurred.
		 * 
		 * @param e The IOErrorEvent.IO_ERROR event
		 */
		protected function onLoadError(e:IOErrorEvent):void
		{
			label = "Sorry. Techie glitch. No help for you";
			label += e.toString();
			
			textField.text = label;
			
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onSwfLoaded);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
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
				prevBtn.enabled = prevBtn.mouseEnabled = false;
				prevBtn.alpha = .1;
			}
			else
			{
				prevBtn.enabled = prevBtn.mouseEnabled = true;
				prevBtn.alpha = 1;
			}
			
			if (count == maxCount)
			{
				nextBtn.enabled = nextBtn.mouseEnabled = false;
				nextBtn.alpha = .1;
			}
			else
			{
				nextBtn.enabled = nextBtn.mouseEnabled = true;
				nextBtn.alpha = 1;
			}
		}
	}
}