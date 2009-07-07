/**
 * Custom Level for Higgs version.
 * 
 * Adds Higgs-specific behaviors, particularly when checking Bot explosions (need to see if Higgs
 * destroyed), and when checking if a level is complete (different conditions).
 */

package model
{
	import events.BotManagerBombEvent;
	import events.LevelEvent;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import view.HiggsGameView;

	public class HiggsLevel extends Level
	{
		
		/**
		 * Constructor
		 * 
		 * @param game      Reference to the game sprite
		 * @param tickTime  Time (ms) between timer updates
		 * @param playField Rectangle forming game bounds
		 * @param count     The number of bots for this level
		 * @param bombs     The number of bombs provided at this level
		 * @param required  Number of bots destroyed to succeed on this level
		 * @param botValue  Score value of each bot
		 */
		public function HiggsLevel(game:BotGame, tickTime:uint, playField:Rectangle, 
								   count:uint, bombs:uint, required:uint, botValue:uint)
		{
			super(game, tickTime, playField, count, bombs, required, botValue);
		}
		
		/**
		 * Override to use custom BotManager
		 */
		override protected function createManager():void
		{
			manager = new HiggsBotManager(levelStats.itemsTotal);
		}
		
		/**
		 * Override to use custom GameView
		 */
		override protected function createView():void
		{
			_view = new HiggsGameView(manager, playField);
		}
		
		/**
		 * Check success/fail conditions to determine if level is complete.
		 * 
		 * Conditions that signal a level is complete:
		 * 1. Higgs Boson destroyed OR
		 * 2. (No currently active reaction AND
		 * 3. (No more bombs OR
		 * 4. No more bots))
		 * 
		 * Success:
		 * 1. Minimum number of bots destroyed
		 * 
		 * Failure:
		 * 1. Higgs Boson destroyed OR
		 * 2. Minimum number of bots not destroyed
		 * 
		 * NOTE: Test of Higgs destruction is handled in onBotExplode(). We set levelStats.suddenDeath
		 * to true in that method to avoid double failure events.
		 */
		override protected function checkIfLevelComplete():void
		{
			var isLevelComplete:Boolean = !bombList.length && (!levelStats.bombs || !(manager.length - 1));
			if (isLevelComplete && !levelStats.suddenDeath)
			{
				_controller.disable();
				var destroyed:uint = levelStats.itemsTotal - levelStats.itemsRemaining;
				var outcome:String = (destroyed >= levelStats.itemsRequired) ?	LevelEvent.SUCCESS : 
																				LevelEvent.FAILURE;
				if (outcome == LevelEvent.SUCCESS)
					tabulateScore();
				dispatchEvent(new LevelEvent(levelStats, outcome));
			}
		}
		
		/**
		 * Event listener. Bot has exploded. Add to score.
		 * 
		 * @param e BotManagerBombEvent object
		 */
		override protected function onBotExplode(e:BotManagerBombEvent):void
		{
			levelStats.lastPointOfInterest = e.lastPoint;
			/* Check if destroyed bot was Higgs */
			if (e.bomb is HiggsBoson)
			{
				levelStats.suddenDeath = true;
				manager.ceaseReacting();
				_controller.disable();
				dispatchEvent(new LevelEvent(levelStats, LevelEvent.FAILURE));
			}
			else
			{
				/* Add to score */
				levelStats.rawScore ++;
				levelStats.itemsRemaining --;
				levelStats.lastScore += levelStats.scoreModifier;
				dispatchEvent(new LevelEvent(levelStats, LevelEvent.SCORE));
			}
		}
	}
}