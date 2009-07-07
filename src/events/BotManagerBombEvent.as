/**
 * Specialized BotManager events used for passing along BombEvents.
 */

package events
{
	import flash.geom.Point;
	
	import model.Bomb;
	
	public class BotManagerBombEvent extends BotManagerEvent
	{
		/* Event type consts */
		public static const EXPLODE:String = "explode";
		public static const INVALIDATE:String = "invalidate";
		public static const CONCLUDE:String = "conclude";
		
		/** A bomb doing an action */
		public var bomb:Bomb;

		/**
		 * Constructor
		 * 
		 * @param bomb  	        A specific bomb instance
		 * @param remaining  		The number of bots remaining in the manager list
		 * @param maxReactionCount  Maximum number of elements in a chain reaction
		 * @param type      		Standard event param
		 * @param bubbles    		Standard event param
		 * @param cancelable 		Standard event param
		 */
		public function BotManagerBombEvent(bomb:Bomb, remaining:uint, 
											maxReactionCount:uint,
											type:String, bubbles:Boolean=false, 
											cancelable:Boolean=false)
		{
			super(remaining, maxReactionCount, new Point(bomb.x, bomb.y), type, bubbles, cancelable);
			this.bomb = bomb;
		}

	}
}