/**
 * Specialized version of the game view with special skinning for the 'special' Higgs Boson
 */

package view
{
	import flash.geom.Rectangle;
	
	import model.Bot;
	import model.BotManager;
	import model.HiggsBoson;

	public class HiggsGameView extends GameView
	{
		/**
		 * Constructor
		 * 
		 * @param manager   A reference to the Model's BotManager, the list of all bots
		 * @param playField Rectangle defining the metrics of the play area
		 */
		public function HiggsGameView(manager:BotManager, playField:Rectangle)
		{
			super(manager, playField);
		}
		
		/**
		 * Create the visual representation of all bots.
		 * 
		 * This specialised view identifies the unique HiggsBoson and
		 * gives it the specialised skin.
		 * 
		 * After creation, a reference is handed back to the individual Bot models,
		 * so updates may be managed directly from the models
		 */
		override public function generateChildren():void
		{
			var len:uint = manager.length;
			var botList:Array = manager.getBotList();
			
			var botView:BombView; 
			
			for (var a:uint = 0; a < len; a++)
			{
				var bot:Bot = botList[a] as Bot;
				
				if (bot is HiggsBoson)
					botView = new HiggsBosonView(bot);
				else
					botView = new BombView(bot);
					
				bot.view = botView;
				addChild(botView);
			}
		}
		
	}
}