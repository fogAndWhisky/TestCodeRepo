/**
 * Sprite representing an individual tile on the chargeboard
 */

package view
{
	import flash.display.Sprite;
	
	import gs.TweenLite;

	public class ChargeTile extends Sprite
	{
		/** Embedded PNG reprenting the charge */
		[Embed (source="images/charge.png")]
		private var ChargeMarker:Class;
		
		/**
		 * Constructor
		 */
		public function ChargeTile()
		{
			super();
			
			addChild(new ChargeMarker());
		}
        
       /**
        * Fade this charge away
        */
        public function fade():void
        {
        	var aTween:TweenLite = new TweenLite(this, 1, {alpha: .1});
        }
		
	}
}