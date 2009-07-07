/**
 * The visual representation of a single bomb
 */

package view
{
	import assetLib.SoundLib;
	import events.BombEvent;
	
	import flash.display.Sprite;
	
	import model.Bomb;
	
	public class BombView extends Sprite
	{
		
		/** The model underlying this sprite */
		protected var manager:Bomb;
		
		/** Render color (derived from Bot model) */
		protected var color:uint;
		
		/**
		 * Constructor
		 * 
		 * @param manager The bomb data model
		 */
		public function BombView(manager:Bomb)
		{
			this.manager = manager;
			color = manager.color;
		}
		
		/**
		 * Update the position of this view element
		 * 
		 * @param x		 X ordinate of the bomb
		 * @param y		 Y ordinate of the bomb
		 * @param radius Blast radius of the bomb
		 * @param alpha  Transparency of the bomb
		 */
		public function update(x:Number, y:Number, radius:Number, alpha:Number):void
		{
			this.x = x;
			this.y = y;
			
			graphics.clear();
			graphics.beginFill(color, alpha);
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();
		}
		
		/**
		 * Event from Bomb model. Bomb has exploded
		 * 
		 * @param e The BombEvent.EXPLODE event
		 */
		public function onExplode(e:BombEvent):void
		{
			/* No implementation at present */
		}
	}
}