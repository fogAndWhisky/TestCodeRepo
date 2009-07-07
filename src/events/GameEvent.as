/**
 * Events issued by the Main Game Class.
 */

package events
{
	import flash.events.Event;
	
	public class GameEvent extends Event
	{
		/* Event type consts */
		public static const PLAY:String = "play";
		public static const PAUSE:String = "pause";
		public static const NEXT_LEVEL:String = "nextLevel";
		public static const RESTART_GAME:String = "restartGame";
		public static const RESTART_LEVEL:String = "restartLevel";
		
		/**
		 * Constructor
		 * 
		 * @param type		 Standard event param
		 * @param bubbles	 Standard event param
		 * @param cancelable Standard event param
		 */
		public function GameEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}