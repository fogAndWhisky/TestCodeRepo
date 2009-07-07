/**
 * Events issued by the BotManager Class.
 */
package events
{
	import flash.events.Event;
	import flash.geom.Point;
	
	public class BotManagerEvent extends Event
	{
		/* Event type consts */
		public static const REACTION_COMPLETE:String = "reaction_complete";
		public static const BOTS_CLEARED:String = "bots_cleared";
	
		/** Number of bots remaining */
		public var remaining:uint;
		
		/** Maximum count for any given reaction */
		public var maxReactionCount:uint;
		
		/** Point of last event of interest */
		public var lastPoint:Point;

		/**
		 * Constructor
		 * 
		 * @param remaining  		The number of bots remaining in the manager list
		 * @param maxReactionCount  Maximum number of elements in a chain reaction
		 * @param lastPoint 		Point of that event of interest
		 * @param type       		Standard event param
		 * @param bubbles    		Standard event param
		 * @param cancelable 		Standard event param
		 */
		public function BotManagerEvent(remaining:uint, maxReactionCount:uint, lastPoint:Point,
										type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.remaining = remaining;
			this.maxReactionCount = maxReactionCount;
			this.lastPoint = lastPoint;
		}
	}
}