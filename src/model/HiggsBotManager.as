/**
 * Custom BotManager for Higgs version. Simply adds in the 'special' Higgs Boson.
 */

package model
{
	import events.BotManagerEvent;
	
	
	public class HiggsBotManager extends BotManager
	{
		/** Special '8-ball' bot for this version of the game */
		private var higgsBoson:Bot;
		
		/**
		 * Constructor
		 * 
		 * Adds in creation of 'special' Higgs Boson
		 * 
		 * @param count Number of bots to create
		 */
		public function HiggsBotManager(count:uint)
		{
			super(count);
			higgsBoson = HiggsBotFactory.newBot(NaN, NaN, true);
			push(higgsBoson);
		}
		
		/**
		 * If the bots are all cleared, issue the BOTS_CLEARED event.
		 * 
		 * Overriding the superclass since the addition of the Higgs Boson adds 
		 * one to the length of the list.
		 */
		override protected function checkIfBotsCleared():void
		{
			if (!(botList.length - 1))
			{
				dispatchEvent(new BotManagerEvent(botList.length, maxReactionCount, 
													lastPoint, BotManagerEvent.BOTS_CLEARED));
				state = COMPLETE_STATE;
			}
		}
	}
}