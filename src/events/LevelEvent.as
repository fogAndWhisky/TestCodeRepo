/**
 * Events issued by the Level Class
 */

package events
{
	import flash.events.Event;
	
	import model.LevelStats;

	public class LevelEvent extends Event
	{
		/* Event type consts */
		/** The user scores */
		public static const SCORE:String = "score";
		/** Level ends in success */
		public static const SUCCESS:String = "success";
		/** Level ends in failure */
		public static const FAILURE:String = "failure";
		/** User releases a bomb */
		public static const BOMB:String = "bomb";
		/** Reaction concludes with no successful hits */
		public static const SQUIFF:String = "squiff";
		/** Reaction concludes with no successful hits */
		public static const BOTS_CLEARED:String = "botsCleared";
		
		/** Custom data for specialty events */
		public var levelStats:LevelStats;
		
		/**
		 * Constructor
		 * 
		 * @param levelStats Payload of level information (see model.LevelStats)
		 * @param type		 Standard event param
		 * @param bubbles	 Standard event param
		 * @param cancelable Standard event param
		 */
		public function LevelEvent( levelStats:LevelStats, type:String, 
									bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.levelStats = levelStats;
		}
	}
}