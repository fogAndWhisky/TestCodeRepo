/**
 * Bootstrap class to kick off game.
 * 
 * 
 * GAME TO DOs
 * - Add keyboard controls (later)
 */

package {
	import assetLib.ColorLib;
	
	import events.GameEvent;
	import events.LevelEvent;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import model.BombFactory;
	import model.BotFactory;
	import model.HiggsLevel;
	import model.Level;
	import model.LevelStats;
	
	import view.GameChrome;
	
	[SWF(width='800', height='600', backgroundColor='#023C47', framerate='99')]

	public class BotGame extends Sprite
	{
		/** 
		 * Game font
		 * Include numbers, upper- and lower-case characters, plus .,!'"-+
		 */
		[Embed(source='fonts/P22UNDER.TTF', fontName='_GameFont', fontWeight='regular', 
				mimeType='application/x-font', 
				unicodeRange='U+0021-U+0022, U+0027, U+002B-U+002E, U+0030-U+0039, U+0041-U+005A, U+0061-U+007A')]
		private var GameFont:Class;
		
		/******************************
		 * Private constants (game configuration)
		 ******************************/
		
		/** Frames per second for movie */
		private const gameFPS:int = 99;
		
		/** time (ms) between ticks of the game timer */
		private const timerTick:int = 10;
		
		/** Bot velocity (minimum) */
		private const minBotVelocity:Number = 1;
		
		/** Bot velocity (minimum) */
		private const maxBotVelocity:Number = 2;
		
		/** Playfield left position */
		private const fieldX:Number = 25;
		
		/** Playfield top position */
		private const fieldY:Number = 25;
		
		/** Playfield width */
		private const fieldWidth:Number = 450;
		
		/** Playfield height */
		private const fieldHeight:Number = 550;
		
		/** Initial radius for all bots */
		private const initBotRadius:Number = 2.5;
		
		/** Initial radius for all bots */
		private const botColors:Array = [	ColorLib.PARTICLE_1,
											ColorLib.PARTICLE_2,
											ColorLib.PARTICLE_3,
											ColorLib.PARTICLE_4,
											ColorLib.PARTICLE_5];
		
		/** Initial radius for all bots */
		private const initBotAlpha:Number = .5;
		
		/** Bomb start alpha */
		private const bombAlphaMax:Number = .2;
		
		/** Minimum value of alpha, after which we determine that bombs are no longer reacting */
		private const bombAlphaMin:Number = .01;
		
		/** Bomb start alpha */
		private const bombColor:Number = ColorLib.BOMB;
		
		/** Bomb start radius */
		private const bombStartRadius:Number = 5;
		
		/** Bomb end radius */
		private const bombEndRadius:Number = 30;
		
		/** Timer ticks for bomb explode phase */
		private const bombExplodeTicks:uint = 100;
		
		/** Timer ticks for bomb fade phase */
		private const bombFadeTicks:uint = 50;
		
		/** Number of bots deployed to each level */
		private const levelCounts:Array =   [50, 10, 15, 20, 25, 30, 35, 40, 45, 50, 70];
		
		/** Number of bots to be destroyed to succeed at each level */
		private const levelSuccess:Array =  [20,  2,  5,  8, 12, 16, 20, 30, 35, 40, 60];
		
		/** Number of bombs provided for each level */
		private const levelBombs:Array =    [ 3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3];
		
		/** Score per bot for each level */
		private const levelBotValue:Array = [ 2,  4,  8, 16, 32, 64, 128, 256, 1024, 2048, 4096];
		
		/******************************
		 * Private members
		 ******************************/
		
		/** Playfield */
		private var playField:Rectangle;
		
		/** Level currently in play */
		private var currentLevel:Level;
		
		/** The skin that goes around the game, including score output and game buttons */
		private var chrome:GameChrome;
		
		/**
		 * The background for the game playfield.
		 * Technically, this is part of the chrome, but the playfield itself needs to be sandwiched
		 * between the gameBG and the chrome. 
		 */
		private var gameBG:Sprite;
		
		/** Flag to indicate whether we've enterred actual game play */
		private var isPlaying:Boolean;
		
		/** The game score */
		private var score:Number;
		
		
		/**
		 * Constructor
		 */
		public function BotGame()
		{
			build();
			
			/* Reality check the level consts */
			if (levelCounts.length != levelSuccess.length ||
				levelCounts.length != levelBombs.length ||
				levelCounts.length != levelBotValue.length)
				throw new Error("All level lengths must be equal");
			
			chrome = new GameChrome(playField);
			addChild(chrome);
			
			gameBG = GameChrome.getGameMask();
			addChild(gameBG);
			
			chrome.addEventListener(GameEvent.PLAY, onPlayPause);
			chrome.addEventListener(GameEvent.PAUSE, onPlayPause);
			chrome.addEventListener(GameEvent.NEXT_LEVEL, nextLevel);
			chrome.addEventListener(GameEvent.RESTART_LEVEL, restartLevel);
			chrome.addEventListener(GameEvent.RESTART_GAME, restartGame);
			/* Auto-start in demo mode */
			start(true);
		}
		
		/**
		 * Structure the game
		 */
		private function build():void
		{
			isPlaying = false;
			playField = new Rectangle(fieldX, fieldY, fieldWidth, fieldHeight);
			BombFactory.setBombParams(bombAlphaMax, bombAlphaMin, bombColor, bombStartRadius, bombEndRadius, bombExplodeTicks, bombFadeTicks);
			BotFactory.setBotParams(fieldWidth, fieldHeight, minBotVelocity, maxBotVelocity, initBotRadius, botColors, initBotAlpha);
		}
		
		/**
		 * Start the game. Call this from a button or external project.
		 * 
		 * @param isDemo Flag to indicate we're starting in demo mode
		 */
		public function start(isDemo:Boolean):void
		{
			score = 0;
			chrome.reset(true);
			if (isDemo)
			{
				createLevel(true);
			}
			else
			{
				clearLevel();
				createLevel(false, true, 1);
			}
		}
		
		/**
		 * Generate a new level
		 * 
		 * @param isDemo    		Flag to indicate we're starting in demo mode
		 * @param overrideAutoPick	Flag to indicate that we're specifying a level to go to.
		 * 							If 'true', pickLevel must be specified.
		 * @param pickLevel 		If specified, go to a specific level, otherwise, increment
		 */	
		private function createLevel(isDemo:Boolean, overrideAutoPick:Boolean = false, pickLevel:uint = 0):void
		{
			var previousID:uint = Level.currentID;
			var levelID:uint;
			if (overrideAutoPick)
			{
				levelID = Level.currentID = pickLevel;
			}
			else
			{
				levelID = Level.nextLevelID();
			}
			
			currentLevel = new HiggsLevel(this, timerTick, playField, levelCounts[levelID], levelBombs[levelID], 
										  levelSuccess[levelID], levelBotValue[levelID]);
			addChild(currentLevel.view);
			addChild(currentLevel.controller);
			
			currentLevel.addEventListener(LevelEvent.SCORE, chrome.onScore);
			currentLevel.addEventListener(LevelEvent.BOMB, chrome.onBomb);
			currentLevel.addEventListener(LevelEvent.SUCCESS, onLevelSuccess);
			currentLevel.addEventListener(LevelEvent.FAILURE, chrome.onLevelFailure);
			currentLevel.addEventListener(LevelEvent.SQUIFF, chrome.onSquiff);
			currentLevel.addEventListener(LevelEvent.BOTS_CLEARED, chrome.onBotsCleared);
			this.setChildIndex(chrome, this.numChildren - 1);
			
			currentLevel.isDemo = isDemo;
			currentLevel.start();
			
			chrome.initLevel(isDemo,
							 levelID,
							 levelCounts[levelID],
							 levelBombs[levelID],
							 levelSuccess[levelID],
							 previousID == levelID);
		}
		
		/**
		 * Clear the existing level to set up the next one
		 */
		private function clearLevel():void
		{
			currentLevel.removeEventListener(LevelEvent.SCORE, chrome.onScore);
			currentLevel.removeEventListener(LevelEvent.BOMB, chrome.onBomb);
			currentLevel.removeEventListener(LevelEvent.SUCCESS, chrome.onLevelSuccess);
			currentLevel.removeEventListener(LevelEvent.FAILURE, chrome.onLevelFailure);
			currentLevel.removeEventListener(LevelEvent.SQUIFF, chrome.onSquiff);
			currentLevel.removeEventListener(LevelEvent.BOTS_CLEARED, chrome.onBotsCleared);
			currentLevel.destroy();
			chrome.reset(false);
		}
		
		/**
		 * Event from GameChrome. Play/pause button pressed
		 * 
		 * @param e The GameEvent
		 */
		private function onPlayPause(e:GameEvent):void
		{
			dispatchEvent(e);
			if (!isPlaying)
			{
				isPlaying = true;
				start(false);
			}
			else
			{
				(e.type == GameEvent.PLAY) ? currentLevel.start() : currentLevel.pause();
			}
		}
		
		/**
		 * Event from chrome. User has requested next level.
		 * 
		 * @param e A GameEvent.NEXT_LEVEL event
		 */
		private function nextLevel(e:GameEvent):void
		{
			clearLevel();
			createLevel(false);
		}
		
		/**
		 * Event from chrome. User has requested next level.
		 * 
		 * @param e A GameEvent.RESTART_LEVEL event
		 */
		private function restartLevel(e:GameEvent):void
		{
			clearLevel();
			createLevel(false, true, Level.currentID);
		}
		
		/**
		 * Event from chrome. User has requested next level.
		 * 
		 * @param e A GameEvent.RESTART_GAME event
		 */
		private function restartGame(e:GameEvent):void
		{
			start(false);
		}
		
		/**
		 * Event from Level. User has completed level successfully
		 * 
		 * @param e The LevelEvent.SUCCESS event
		 */
		private function onLevelSuccess(e:LevelEvent):void
		{
			var levelID:uint = Level.currentID;
			var levelStats:LevelStats = e.levelStats;
			
			score += levelStats.score;
			
			if (levelID == levelCounts.length - 1)
			{
				chrome.onGameOver(levelStats, score);
			}
			else
			{
				chrome.onLevelSuccess(levelStats, score);
			}
		}
	}
}
