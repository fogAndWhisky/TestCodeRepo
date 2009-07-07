/**
 * View for a cute animated lightning bolt.
 * 
 * TODO:
 * Add ability to customise: color, segments, maxFrames, volatility.
 */

package view
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	import flash.media.Sound;
	
	import assetLib.ColorLib;
	import assetLib.SoundLib;

	public class LightningBolt extends Sprite
	{
		/** The start point */
		protected var start:Point;
		
		/** The end point */
		protected var end:Point;
		
		/** Frame counter for lifespan of the bolt */
		protected var count:uint = 0;
		
		/** Max frames for this bolt to exist */
		protected var maxFrames:uint = 15;
		
		/**
		 * Constructor
		 * 
		 * @param start Point to start the bolt
		 * @param end   Point to end the bolt
		 */
		public function LightningBolt(start:Point, end:Point)
		{
			super();
			this.start = start;
			this.end = end;
			
			var glowFilter:GlowFilter = new GlowFilter(ColorLib.LIGHTNING_GLOW);
			filters = [glowFilter];
			
			generateBolt();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			
			var sound:Sound = new SoundLib.ZAP_SOUND();
			sound.play();
		}
		
		/**
		 * Create a bolt of lightning
		 */
		protected function generateBolt():void
		{
			graphics.clear();
			graphics.lineStyle(1, ColorLib.LIGHTNING, 1);
			graphics.moveTo(start.x, start.y);
			
			var segments:uint = 10;
			var nextX:Number = start.x;
			var nextY:Number = start.y;
			
			var segWidth:Number = ((end.x - start.x)/segments);
			var segHeight:Number = ((end.y - start.y)/segments);
			
			graphics.lineTo(nextX, nextY);
			
			for (var a:uint = 0; a < segments; a++)
			{
				nextX = start.x + ((a+1) * segWidth) + (Math.random() * (segments - a));
				nextY = start.y + ((a+1) * segHeight) + (Math.random() * (segments - a));
				graphics.lineTo(nextX, nextY);
			}
		}
		
		/**
		 * Animate over the life of the bolt
		 * 
		 * @param e The Event.ENTER_FRAME event
		 */
		private function onEnterFrame(e:Event):void
		{
			count ++;
			generateBolt();
			if (count > maxFrames)
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				parent.removeChild(this);
			}
		}
	}
}