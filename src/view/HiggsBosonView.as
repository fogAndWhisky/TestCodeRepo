/**
 * Specialized view for the Higgs Boson 8-ball
 */

package view
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	
	import assetLib.ColorLib;
	import model.Bomb;

	public class HiggsBosonView extends BombView
	{
		/** Embedded PNG for the number 8 marker */
		[Embed (source="images/8marker.png")]
		private var BosonMarker:Class;
		
		/** Sprite holding the '8' marker */
		private var markerSprite:Sprite;
		
		/** Sprite masking the rolling '8' effect */
		private var maskSprite:Sprite;
		
		/** Previous x ordinate for determining velocity */
		private var lastX:Number;
		/** Previous y ordinate for determining velocity */
		private var lastY:Number;
		
		/**
		 * Constructor
		 * 
		 * @param manager The bomb data model
		 */
		public function HiggsBosonView(manager:Bomb)
		{
			super(manager);
			markerSprite = new Sprite();
			addChild(markerSprite);
			
			maskSprite = new Sprite();
			addChild(maskSprite);
			
			var marker:Bitmap = new BosonMarker();
			marker.width = marker.height = manager.radius;
			marker.x = -marker.width / 2;
			marker.y = -marker.height / 2;
			markerSprite.addChild(marker);
			
			markerSprite.mask = maskSprite;
			
			var glowFilter:GlowFilter = new GlowFilter(ColorLib.BOMB, 1, 2, 2, .5);
			filters = [glowFilter];
		}
		
		/**
		 * Update the position of this view element
		 * 
		 * @param x      The x position of the bomb
		 * @param y      The y position of the bomb
		 * @param radius Blast radius of the bomb
		 * @param alpha  Transparency of the bomb
		 */
		override public function update(x:Number, y:Number, radius:Number, alpha:Number):void
		{
			super.update (x, y, radius, alpha);
			
			maskSprite.graphics.clear();
			maskSprite.graphics.beginFill(color, alpha);
			maskSprite.graphics.drawCircle(0, 0, radius);
			maskSprite.graphics.endFill();
			
			var xVel:Number = lastX - x;
			var yVel:Number = lastY - y;
			
			
			markerSprite.rotation ++;
			markerSprite.x -= xVel;
			markerSprite.y -= yVel;
			
			var d:Number = 2 * radius;
			
			if (markerSprite.x > d)
				markerSprite.x = - d;
			else if (markerSprite.x < -d) 
				markerSprite.x = d;
				
			
			if (markerSprite.y > d)
				markerSprite.y = - d;
			else if (markerSprite.y < -d) 
				markerSprite.y = d;
			
			lastX = x;
			lastY = y;
			
			markerSprite.width = markerSprite.height = manager.radius;
			markerSprite.alpha = alpha;
		}
	}
}