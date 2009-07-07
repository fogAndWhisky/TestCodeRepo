/**
 * Model representing individual game levels.
 * 
 * Maintains a static currentID for level management. Use new Level() for construction and 
 * start() and pause() to control timer updates.
 */

package model
{
	import controller.GameController;
	
	import events.BombEvent;
	import events.BotManagerBombEvent;
	import events.BotManagerEvent;
	import events.LevelEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import view.BombView;
	import view.GameView;
	
	public class Level extends EventDispatcher
	{
		
		
		/******************************
		 * Protected statics
		 ******************************/
		/** The current level. Auto-start at 0. */
		protected static var currentLevel:int = -1;
		
		
		/******************************
		 * Protected members
		 ******************************/
		/** Value object containing all stats for this level */
		protected var levelStats:LevelStats;
		
		/** Flag to mark this level as demo mode only */
		 protected var isInDemoMode:Boolean; 
		
		/** Timer to control game flow */
		protected var timer:Timer;
		 
		/**
		 * Reference to the main gaime
		 */
		protected var game:BotGame; 
		
		/** Array of bots */
		protected var manager:BotManager;
		
		/** Array of bombs */
		protected var bombList:Array;
			
		/** The game view */
		protected var _view:GameView;
		
		/** Rectangle defining the play area */
		protected var playField:Rectangle;
		
		/** Reference to the user controller. */
		protected var _controller:GameController;
		
		/** Coordinates of last bomb position */
		protected var bombPoint:Point;
		
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
		 * 
		 */
		public function Level(game:BotGame, tickTime:uint, playField:Rectangle, 
							  count:uint, bombs:uint, required:uint, botValue:Number)
		{
			this.game = game;
			this.playField = playField;
			
			levelStats = new LevelStats();
			levelStats.itemsRemaining = levelStats.itemsTotal = count;
			levelStats.bombs = bombs;
			levelStats.scoreModifier = botValue;
			levelStats.score = 0;
			levelStats.itemsRequired = required;
			
			if (levelStats.itemsRequired > levelStats.itemsTotal)
				throw Error("Bots required is greater than bots in level. Impossible success conditions!");
			
			timer = new Timer(tickTime);
			timer.addEventListener(TimerEvent.TIMER, onTimerUpdate);
			
			createManager();
			
			manager.addEventListener(BotManagerBombEvent.EXPLODE, onBotExplode);
			manager.addEventListener(BotManagerBombEvent.CONCLUDE, onBotConclude);
			manager.addEventListener(BotManagerEvent.REACTION_COMPLETE, onReactionConclude);
			manager.addEventListener(BotManagerEvent.BOTS_CLEARED, onBotsCleared);
			
			bombList = new Array();

			createView();
			this.addEventListener(LevelEvent.BOMB, _view.onBomb);
			_controller = new GameController(playField, onBombDrop);
		}
		
		/**
		 * Setter to mark level as demo only. Disable controller.
		 * 
		 * @param isInDemoMode If true, disable controller
		 */
		public function set isDemo(isInDemoMode:Boolean):void
		{
			this.isInDemoMode = isInDemoMode;
			if (isInDemoMode)
				_controller.disable();
		}
		
		/**
		 * Getter for the current level ID
		 * 
		 * @return the value of the current level
		 */
		public static function get currentID():int
		{
			return currentLevel;
		}
		
		/**
		 * Increment the level
		 * 
		 * @return The new level ID
		 */
		public static function nextLevelID():uint
		{
			currentLevel ++;
			return currentLevel;
		}
		
		/**
		 * Setter for the current level ID
		 * 
		 * Note: use nextLevelID() to increment levels. Use this
		 * to set specific level.
		 * 
		 * @param ID The new level value
		 */
		public static function set currentID(ID:int):void
		{
			currentLevel = ID;
		}
		
		/**
		 * Getter to reference the view associated with this level
		 * 
		 * @return a reference to this level's view
		 */
		public function get view():GameView
		{
			return _view;
		}
		
		/**
		 * Getter to reference the controller associated with this level
		 * 
		 * @return a reference to this level's controller
		 */
		public function get controller():GameController
		{
			return _controller;
		}
		
		/**
		 * Start the level going!
		 */
		public function start():void
		{
			timer.start();
			if (!isInDemoMode)
				_controller.enable();
		}
		
		/**
		 * Pause the level
		 */
		public function pause():void
		{
			timer.stop();
			_controller.disable();
		}
		
		/**
		 * Destroy this level, including the associated BotManager, View and Controller
		 */
		public function destroy():void
		{
			manager.removeEventListener(BotManagerBombEvent.EXPLODE, onBotExplode);
			manager.removeEventListener(BotManagerBombEvent.CONCLUDE, onBotConclude);
			manager.removeEventListener(BotManagerEvent.REACTION_COMPLETE, onReactionConclude);
			manager.removeEventListener(BotManagerEvent.BOTS_CLEARED, onBotsCleared);
			
			removeEventListener(LevelEvent.BOMB, _view.onBomb);
			
			manager.destroy();
			_view.destroy();
			_controller.destroy();
		}
		
		/**
		 * Event handler: timer has updated
		 * 
		 * @param e A TimerEvent.TIMER event
		 */
		protected function onTimerUpdate(e:TimerEvent):void
		{
			manager.update(playField, bombList);
		}
		
		/**
		 * Check success/fail conditions to determine if level is complete.
		 * 
		 * Conditions that signal a level is complete:
		 * 1. No currently active reaction AND
		 * 2. (No more bombs OR
		 * 3. No more bots)
		 * 
		 * Success:
		 * 1. Minimum number of bots destroyed
		 * 
		 * Failure:
		 * 1. Minimum number of bots not destroyed
		 */
		protected function checkIfLevelComplete():void
		{
			var isLevelComplete:Boolean = !bombList.length && (!levelStats.bombs || !manager.length);
			if (isLevelComplete)
			{
				_controller.disable();
				var destroyed:uint = levelStats.itemsTotal - levelStats.itemsRemaining;
				var outcome:String = (destroyed >= levelStats.itemsRequired) ?  LevelEvent.SUCCESS : 
																				LevelEvent.FAILURE;
				if (outcome == LevelEvent.SUCCESS)
					tabulateScore();
				dispatchEvent(new LevelEvent(levelStats, outcome));
			}
		}
		
		/**
		 * Compute the score for this level
		 */
		protected function tabulateScore():void
		{
			var score:Number = 0;
			var mod:Number = levelStats.scoreModifier;
			
			/* Start by tabulating the value of all bots destroyed */
			var len:uint = levelStats.rawScore + 1;
			for (var a:uint = 1; a < len; a++)
			{
				score = (a * levelStats.scoreModifier);
			}
			
			/* Subtract 10 * scoreMod for all squiffs */
			levelStats.squiffCost = -5 * mod * levelStats.squiffs;
			score += levelStats.squiffCost;
			
			/* Add big bonus for a cleared board  */
			if (levelStats.cleared)
			{
				levelStats.clearedBonus = levelStats.bombs + 1;
				if (score < 0)
				{
					levelStats.minScoreOverride = true;
					score = levelStats.scoreModifier;
				}
				score *= levelStats.clearedBonus;
			}
				
			levelStats.score = score;
		}
		
		/**
		 * Event listener. Bot has exploded. Add to score.
		 * 
		 * @param e A BotManagerBombEvent.EXPLODE event
		 */
		protected function onBotExplode(e:BotManagerBombEvent):void
		{
			/* Add to score */
			levelStats.rawScore ++;
			levelStats.itemsRemaining --;
			levelStats.lastPointOfInterest = new Point(e.target.x, e.target.y);
			levelStats.lastScore += levelStats.scoreModifier;
			
			dispatchEvent(new LevelEvent(levelStats, LevelEvent.SCORE));
		}
		
		/**
		 * Generate a manager. 
		 * 
		 * Separated from constructor to allow for overriding by subclasses.
		 */
		protected function createManager():void
		{
			manager = new BotManager(levelStats.itemsTotal);
		}
		
		/**
		 * Create the game view. 
		 * 
		 * Separated from constructor to allow for implementation of specialised views.
		 */
		protected function createView():void
		{
			_view = new GameView(manager, playField);
		}
		
		/**
		 * Event listener. Bot has vanished. Check if game over.
		 * 
		 * @param e A BotManagerBombEvent.CONCLUDE event
		 */
		protected function onBotConclude(e:BotManagerBombEvent):void
		{
			/* Unimplemented at present */
		}
		
		/**
		 * Event listener. Reaction complete. Check if game over.
		 * 
		 * @param e BotManagerEvent.REACTION_COMPLETE event
		 */
		private function onReactionConclude(e:BotManagerEvent):void
		{
			if (e.maxReactionCount == 0)
			{
				levelStats.lastPointOfInterest = bombPoint;
				levelStats.squiffs ++;
				dispatchEvent(new LevelEvent(levelStats, LevelEvent.SQUIFF));
			}
			checkIfLevelComplete();
		}
		
		/**
		 * Event listener. All bots deleted.
		 * 
		 * @param e BotManagerEvent.BOTS_CLEARED event
		 */
		private function onBotsCleared(e:BotManagerEvent):void
		{
			levelStats.cleared = true;
		}
		
		/**
		 * Event listener. Controller reports that bomb has been dropped
		 * 
		 * @param e Event event
		 */
		private function onBombDrop(e:Event):void
		{
			addBomb(e.target.x, e.target.y);
			
			if (levelStats.bombs == 0)
				_controller.disable();
			
			levelStats.lastPointOfInterest = new Point(e.target.x, e.target.y);
			dispatchEvent(new LevelEvent(levelStats, LevelEvent.BOMB));
		}
		
		/**
		 * Add a bomb to the game
		 * 
		 * @param xPos x position of bomb
		 * @param yPos y position of bomb
		 */
		private function addBomb(xPos:Number, yPos:Number):void
		{
			if (levelStats.bombs > 0)
			{
				levelStats.bombs --;
				var bomb:Bomb = BombFactory.newBomb(xPos, yPos);
				bombList.push(bomb);
				bomb.addEventListener(BombEvent.CONCLUDE, removeBomb);
				
				timer.addEventListener(TimerEvent.TIMER, bomb.onTimerUpdate);
				var bombView:BombView = new BombView(bomb);
				bomb.view = bombView;
				game.addChild(bombView);
				
				bomb.explode(true);
				
				/** Record position in case of squiff */
				bombPoint = new Point(bomb.x, bomb.y);
			}
		}
		
		/**
		 * Event from Bomb. Lifecycle complete
		 * 
		 * @param e BotManagerBombEvent.CONCLUDE event
		 */
		private function removeBomb(e:BombEvent):void
		{
			var bomb:Bomb = e.target as Bomb;
			bomb.removeEventListener(BombEvent.CONCLUDE, removeBomb);
			timer.removeEventListener(TimerEvent.TIMER, bomb.onTimerUpdate);
			
			/* Remove bomb reference from bombList */
			var len:uint = bombList.length;
			for (var a:uint = 0; a < len; a++)
			{
				if (bomb == bombList[a] as Bomb)
					bombList.splice(a, 1);
			}
		}
	}
}