/**
 * A tiny preloader class.
 */
package
{
	import assetLib.ColorLib;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import gs.TweenGroup;
	import gs.TweenLite;
	

	[SWF(width='800', height='600', backgroundColor='#023C47', framerate='99')]

	public class HiggsPreloader extends Sprite
	{
		
		/** Game font */
		[Embed(source='fonts/P22UNDER.TTF', fontName='_GameFont', fontWeight='regular', 
				mimeType='application/x-font', 
				unicodeRange='U+002E-U+002F, U+0030-U+0039, U+004C, U+0050, U+0061-U+007A')]
		private var GameFont:Class;
		
		/** Last-chance fallback error if the preloader fails */
		protected const FAIL_MESSAGE:String = "Load failure. Please contact game admin.";
		
		protected const BYTES_IN_K:uint = 1024;
		
		/* Metrics */
		protected const PRELOADER_WIDTH:Number = 200;
		protected const PRELOADER_HEIGHT:Number = 20;
		protected const HALF_WIDTH:Number = PRELOADER_WIDTH / 2;
		protected const HALF_HEIGHT:Number = PRELOADER_HEIGHT / 2;
		
		protected const FILL_COLOR:uint = ColorLib.METER_FILL;
		protected const LINE_COLOR:uint = ColorLib.BLACK;
		protected const TEXT_COLOR:uint = ColorLib.LIGHT_TEXT;
		
		/* Loader and on-screen elements */
		protected var loader:Loader;
		protected var textField:TextField;
		protected var textFormat:TextFormat;
		protected var progressBar:Sprite;
		
		/** Tween management for transitioning from preloader to content */
		protected var tweenGroup:TweenGroup;
		protected var aProgressTween:TweenLite;
		protected var aContentTween:TweenLite;
		
		
		/**
		 * Constructor
		 */
		public function HiggsPreloader()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			createPreloader();
			loadContent();
		}
		
		/**
		 * Build the preloader.
		 */
		protected function createPreloader():void
		{
			textFormat = new TextFormat();
			textFormat.color = TEXT_COLOR;
			textFormat.font = "_GameFont";
			
			textField = new TextField();
			textField.defaultTextFormat = textFormat;
			textField.embedFonts = true;
			textField.autoSize = "left";
			textField.selectable = false;
			textField.y = -5;
			textField.x = 15;
			
			progressBar = new Sprite();
			progressBar.x = 400;
			progressBar.y = 300;
			
			progressBar.addChild(textField);
			addChild(progressBar);
		}
		
		/**
		 * Load the main swf
		 */
		protected function loadContent():void
		{
			loader = new Loader();
			loader.alpha = 0;
			addChild(loader);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onGameLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onGameLoadFailed);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadUpdate);
			loader.load(new URLRequest("BotGame.swf"));
		}
		
		/**
		 * Update the preloader
		 * 
		 * @param e The ProgressEvent.PROGRESS event
		 */
		protected function onLoadUpdate(e:ProgressEvent):void
		{
			textField.text = Math.floor(e.bytesLoaded/BYTES_IN_K) + "/" + 
							 Math.floor(e.bytesTotal/BYTES_IN_K) + "kb";
			
			var percent:Number = e.bytesLoaded / e.bytesTotal;
			
			progressBar.graphics.clear();
			progressBar.graphics.beginFill(FILL_COLOR, 1);
			progressBar.graphics.drawRoundRectComplex(-HALF_WIDTH, -HALF_HEIGHT, 
														PRELOADER_WIDTH * percent,
														PRELOADER_HEIGHT, 10, 0, 0, 10);
			progressBar.graphics.endFill();
			progressBar.graphics.lineStyle(1, LINE_COLOR);
			progressBar.graphics.drawRoundRectComplex(-HALF_WIDTH, -HALF_HEIGHT, PRELOADER_WIDTH,
														PRELOADER_HEIGHT, 10, 0, 0, 10);
		}
		
		/**
		 * Game has loaded. Fade out preloader
		 * 
		 * @param e The Event.COMPLETE event.
		 */
		protected function onGameLoaded(e:Event):void
		{
			removeLoaderListeners();
			
			tweenGroup = new TweenGroup();
			tweenGroup.align = TweenGroup.ALIGN_SEQUENCE;
			
			aProgressTween = new TweenLite(progressBar, 2, {alpha: 0});
			aContentTween = new TweenLite(loader, 2, {alpha: 1});
			
			tweenGroup.push(aProgressTween);
			tweenGroup.push(aContentTween);
		}
		
		/**
		 * Something's gone wrong with the load. Inform user.
		 * 
		 * @param e The IOErrorEvent.IO_ERROR event
		 */
		protected function onGameLoadFailed(e:IOErrorEvent):void
		{
			removeLoaderListeners();
			textField.text = FAIL_MESSAGE;
		}
		
		/**
		 * Clear out the loader listeners
		 */
		protected function removeLoaderListeners():void
		{
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onGameLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onGameLoadFailed);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadUpdate);
		}
	}
}