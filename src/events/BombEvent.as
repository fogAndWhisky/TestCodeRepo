/**
 * Events issued by Bombs (and by extension by Bots)
 */

package events
{
	import flash.events.Event;

	public class BombEvent extends Event
	{
		/* Event type constants */
		public static const DROP:String = "drop";
		public static const EXPLODE:String = "explode";
		public static const INVALIDATE:String = "invalidate";
		public static const CONCLUDE:String = "concluded";
		
		public var isPrimary:Boolean;
		
		/**
		 * Constructor
		 * 
		 * @param isPrimary	 Is this the start of the event chain?
		 * @param type		 Standard event param
		 * @param bubbles	 Standard event param
		 * @param cancelable Standard event param
		 */
		public function BombEvent(isPrimary:Boolean, type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.isPrimary = isPrimary;
		}
		
	}
}