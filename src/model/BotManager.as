/**
 * Model representing the array of all bots.
 * 
 * This class handles the interactions between bombs/bots as they explode.
 */

package model
{
	import events.BombEvent;
	import events.BotManagerBombEvent;
	import events.BotManagerEvent;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.sfmultimedia.display.Axis;
	
	public class BotManager extends EventDispatcher
	{
		/******************************
		 * Private constants (manager states)
		 ******************************/
		/** State machine default state */
		protected const DEFAULT_STATE:uint = 0;
		
		/** State machine state during a reaction */
		protected const REACTION_STATE:uint = 1;
		
		/** State machine state once reaction complete */
		protected const COMPLETE_STATE:uint = 2;
		
		/** State machine state once level complete */
		protected const INVALIDATED_STATE:uint = 3;
		
		
		
		/** List of free bots */
		protected var botList:Array;
		
		/** Queue of expired bots awaiting removal */
		private var spliceList:Array;
		
		/** State machine index */
		protected var state:uint;
		
		/** Maximum number of reactions for any given reaction cycle */
		protected var maxReactionCount:uint;
		
		/** Point indicating last event of interest within this manager */
		protected var lastPoint:Point;
		
		/**
		 * Constructor
		 * 
		 * @param count Number of bots to create
		 */
		public function BotManager(count:uint)
		{
			super();
			botList = new Array();
			spliceList = new Array();
			
			for (var a:uint = 0; a < count; a++)
			{
				var bot:Bot = BotFactory.newBot();
				push(bot);
			}
			
			state = DEFAULT_STATE;
		}
		
		/** 
		 * Update the bots in two stages
		 * 
		 * - Update all animations and reflect if necessary
		 * - Check collisions and trigger state changes
		 * 
		 * @param playField The legal play region
		 * @param bombList  List of currently active bombs
		 */
		public function update(playField:Rectangle, bombList:Array):void
		{
			if (bombList.length && state == DEFAULT_STATE)
			{
				maxReactionCount = 0;
				state = REACTION_STATE;
			}
			
			animate(playField);
			var reactionCount:uint = 0;
			if (state < INVALIDATED_STATE)
				reactionCount = checkCollisions(bombList);
	
			if (reactionCount - bombList.length > maxReactionCount)
				maxReactionCount = reactionCount;
			
			cleanUp();
			
			if (state == REACTION_STATE && !reactionCount)
			{
				checkIfBotsCleared();
				
				if (state != COMPLETE_STATE)
					state = DEFAULT_STATE;
					
				dispatchEvent(new BotManagerEvent(botList.length, maxReactionCount, 
												  lastPoint, BotManagerEvent.REACTION_COMPLETE));
			}
		}
		
		/**
		 * Set the system to INVALIDATED_STATE, thereby forbidding further reactions
		 */
		public function ceaseReacting():void
		{
			state = INVALIDATED_STATE;
		}
		
		/**
		 * Destroy this manager and all associated bots
		 */
		public function destroy():void
		{
			while (botList.length)
			{
				var bot:Bot = botList.pop() as Bot;
				bot.destroy();
			}
			delete this;
		}
		
		/**
		 * Get a reference to the botList
		 * 
		 * @return the botList
		 */
		public function getBotList():Array
		{
			return botList;
		}
		
		/**
		 * Push a bot onto the botList
		 * 
		 * @param bot A Bot Object to add to the list
		 * 
		 * @return The length of the list
		 */
		public function push(bot:Bot):uint
		{
			botList.push(bot);
			bot.addEventListener(BombEvent.INVALIDATE, onBotInvalidate);
			bot.addEventListener(BombEvent.EXPLODE, onBotExplode);
			bot.addEventListener(BombEvent.CONCLUDE, onBotConclude);
			return botList.length;
		}
		
		/**
		 * Get the length of the botList
		 * 
		 * @return Length of botList
		 */
		public function get length():uint
		{
			return botList.length;
		}
		
		/**
		 * Update positions and animations of all bots
		 * 
		 * @param playField A reference to the rect that defines the play area
		 */
		protected function animate(playField:Rectangle):void
		{
			var bot:Bot;
			var a:uint;
			var len:uint = botList.length;
			for (a = 0; a < len; a++)
			{
				bot = botList[a] as Bot;
				bot.update();
				
				/* If moving freely, check for bounding */
				if (bot.state == Bomb.FREE_STATE)
				{
					var l:int = playField.x;
					var t:int = playField.y;
					var w:int = playField.width;
					var h:int = playField.height;
					var r:int = l + w;
					var b:int = t + h;
					
					if (bot.x > r)
						bot.reflect(Axis.X, r);
					else if (bot.x < l)
						bot.reflect(Axis.X, l);
						
					if (bot.y > b)
						bot.reflect(Axis.Y, b);
					else if (bot.y < t)
						bot.reflect(Axis.Y, t);
				}
			}
		}
		
		/**
		 * Check collisions
		 * 
		 * This is a heuristic method with a maximum number of iterations of
		 * count! (factorial).
		 * 
		 * @param bombs List of currently active bombs
		 * 
		 * @return 		The number of items reacting right now
		 */
		protected function checkCollisions(bombs:Array):uint
		{
			/** First check all bots against the bombs */
			
			var bot:Bot;
			var bomb:Bomb;
			var bombBot:Bot;
			var dist:Number;
			var a:uint;
			var b:uint;
			var aLen:uint;
			var bombsLen:uint = bombs.length;
			var explodeLen:uint;
			
			/* Generate list of exploding bots */
			var explodeList:Array = new Array();
			aLen = botList.length
			
			/* Do one loop of all bots to ascentain those already in the chain reaction.
			 * Doing this once avoids a costly loop, checking each bot against all others.
			 */
			for (a = 0; a < aLen; a++)
			{
				bot = botList[a] as Bot;
				/* Allow collisions with exploding bots and bots that haven't 
				 * faded so far as to make invalid.
				 */
				if (bot.state == Bomb.EXPLODE_STATE || bot.state == Bomb.FADE_STATE)
				{
					explodeList.push(bot);
				}
			}
			explodeLen = explodeList.length;
			
			aLen = botList.length
			for (a = 0; a < aLen; a++)
			{
				bot = botList[a] as Bot;
				
				if (bot.state == Bomb.FREE_STATE)
				{
					//check bot against bombs
					for (b = 0; b < bombsLen; b++)
					{
						bomb = bombs[b] as Bomb;
						dist = Math.sqrt(Math.pow(bot.x - bomb.x, 2) + 
							   			 Math.pow(bot.y - bomb.y, 2));
						if (dist < bomb.radius)
						{
							explodeBot(bot);
							break;
						}
					}
					//check bot against other bots
					for (b = 0; b < explodeLen; b++)
					{
						bombBot = explodeList[b] as Bot;
						dist = Math.sqrt(Math.pow(bot.x - bombBot.x, 2) + 
							   			 Math.pow(bot.y - bombBot.y, 2));
							   			 
						if (dist < bombBot.radius)
						{
							explodeBot(bot);
							break;
						}
					}
				}
			}
			return explodeLen + bombsLen;
		}
		
		/**
		 * Remove bots marked in the splice list.
		 */
		protected function cleanUp():void
		{
			while (spliceList.length)
			{
				var bot:Bot = spliceList.pop() as Bot;
				var len:uint = botList.length;
				for (var a:uint = 0; a < len; a++)
				{
					var checkBot:Bot = botList[a] as Bot;
					if (checkBot == bot)
					{
						botList.splice(a, 1);
						break;
					}
				}
			}
		}
		
		/**
		 * Explode this bot, adding it to the reaction list.
		 * 
		 * @param bot The bot being exploded
		 */
		protected function explodeBot(bot:Bot):void
		{
			bot.explode();
		}
		
		/**
		 * Forward bomb explode events
		 * 
		 * @param e Bomb event
		 */
		protected function onBotExplode(e:BombEvent):void
		{
			var bot:Bot = e.target as Bot;
			lastPoint = new Point(bot.x, bot.y);
			forwardBombEvent (bot, BotManagerBombEvent.EXPLODE);
		}
		
		/**
		 * Event from exploding bot. Explosion complete.
		 * 
		 * Mark this bot as 'invalid' and forward the event.
		 * 
		 * @param e Bomb event
		 */
		protected function onBotInvalidate(e:BombEvent):void
		{
			var bot:Bot = e.target as Bot;
			bot.removeEventListener(BombEvent.INVALIDATE, onBotInvalidate);
			
			forwardBombEvent (bot, BotManagerBombEvent.INVALIDATE);
		}
		
		/**
		 * Event from exploding bot. Bot's job is done. Safe to remove it.
		 * 
		 * @param e Bomb event
		 */
		protected function onBotConclude(e:BombEvent):void
		{
			var bot:Bot = e.target as Bot;
			bot.removeEventListener(BombEvent.CONCLUDE, onBotConclude);
			forwardBombEvent (bot, BotManagerBombEvent.CONCLUDE);
			spliceList.push(bot);
		}
		
		/**
		 * Forward a bomb event
		 * 
		 * @param bomb The bomb which spawned the event
		 * @param type The activity the bomb is doing
		 */
		protected function forwardBombEvent(bomb:Bomb, type:String):void
		{
			dispatchEvent(new BotManagerBombEvent(bomb, botList.length, maxReactionCount, type));
		}
		
		/**
		 * If the bots are all cleared, issue the BOTS_CLEARED event
		 */
		protected function checkIfBotsCleared():void
		{
			if (!botList.length)
			{
				dispatchEvent(new BotManagerEvent(botList.length, maxReactionCount, 
													lastPoint, BotManagerEvent.BOTS_CLEARED));
				state = COMPLETE_STATE;
			}
		}
	}
}