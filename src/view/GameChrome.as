/**
 * The skin for the game. Includes some items which are "controller" and not strictly "viewer".
 * 
 * Viewer elements:
 * - Game logo
 * - Stats board
 * - Help and info windows
 * 
 * Controller elements
 * - Play/Pause button
 * - Help button
 * - Learn button
 * 
 * The chrome also defines a "game mask" available through the static method GameChrome.getGameMask().
 * This allows other game elements, such as the game viewer or game controller, to access the mask
 * and use it to mask themselves.
 */

package view
{
	import assetLib.ColorLib;
	import assetLib.ResourceStrings;
	import assetLib.SoundLib;
	
	import controller.GameButton;
	import controller.InfoButton;
	import controller.MultiStateButton;
	
	import events.GameEvent;
	import events.LevelEvent;
	
	import flash.display.Bitmap;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	
	import model.LevelStats;

	public class GameChrome extends Sprite
	{
		/************
		 * Static properties
		 ************/
		/** Reference to the rect which defines the play area */
		public static var _playField:Rectangle;
		
		/************
		 * Private consts
		 ************/
		/** Unit for spacing out game elements */
		private const SPACER:uint = 20;
		/* Colors for chrome */
		private const playButtonColor:uint = ColorLib.PARTICLE_4;
		private const helpButtonColor:uint = ColorLib.PARTICLE_3;
		private const learnButtonColor:uint = ColorLib.PARTICLE_5;
		private const overButtonColor:uint = ColorLib.PARTICLE_2;
		private const downButtonColor:uint = ColorLib.PARTICLE_3;
		
		/** Time in MS before auto-dismissing a notification */
		private const autoDismissMS:uint = 4000;
		/** ID for the Play state of the play/pause button */
		private const PLAY:uint = 0;
		/** ID for the Pause state of the play/pause button */
		private const PAUSE:uint = 1;
		
		/** Embedded PNG representing the game logo */
		[Embed(source="images/boson-logo2.png")]
		private var Logo:Class;
		/** Embedded PNG representing the Sound On icon */
		[Embed(source="images/soundOnIcon.png")]
		private var SoundOnIcon:Class;
		/** Embedded PNG representing the Sound Off icon */
		[Embed(source="images/soundOffIcon.png")]
		private var SoundOffIcon:Class;
		
		/** Instance of the embedded Logo PNG */
		private var logo:Bitmap;
		/** Instance of board with all player stats */
		private var statsBoard:StatsBoard;
		/* Game buttons */
		private var learnBtn:GameButton;
		private var helpBtn:GameButton;
		private var playPauseBtn:MultiStateButton;
		private var soundBtn:MultiStateButton;
		
		/** The background */
		private var gameBG:Sprite;
		
		/** List of alerts (info and help boxes) */
		private var alerts:Array;
		
		/**
		 * Constructor
		 * 
		 * @param playField The rectangle defining the play area
		 */
		public function GameChrome(playField:Rectangle)
		{
			super();
			
			_playField = playField;
			
			var left:Number = playField.x + playField.width + SPACER;
			var top:Number = playField.y;
			var bottom:Number = playField.y + playField.height;
			
			logo = new Logo();
			logo.x = left;
			logo.y = top;
			addChild(logo);
			
			createPlayPauseBtn();
			createSoundBtn();
			
			learnBtn = new GameButton(ResourceStrings.LEARN, learnButtonColor, overButtonColor, downButtonColor);
			learnBtn.x = left;
			learnBtn.y = playPauseBtn.y - (learnBtn.height + SPACER);
			
			helpBtn = new GameButton(ResourceStrings.HELP, helpButtonColor, overButtonColor, downButtonColor);
			helpBtn.x = left;
			helpBtn.y = learnBtn.y - (helpBtn.height + SPACER);
			
			addChild(helpBtn);
			addChild(learnBtn);
			
			helpBtn.addEventListener(MouseEvent.CLICK, onHelp);
			learnBtn.addEventListener(MouseEvent.CLICK, onHelp);
			
			statsBoard = new StatsBoard(logo.width, 275);
			statsBoard.x = left;
			statsBoard.y = logo.y + logo.height + SPACER;
			addChild(statsBoard);
			
			alerts = new Array();
			
			newInfo(ResourceStrings.WELCOME);
		}
		
		/**
		 * Generate a clone of the game background.
		 * 
		 * Static so easily accessible across the app.
		 * 
		 * @return A sprite whose shape perfectly matches the game background
		 */
		public static function getGameMask():Sprite
		{
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(ColorLib.GAME_FIELD, 1);
			sprite.graphics.drawRoundRectComplex(_playField.x, _playField.y,
										  _playField.width, _playField.height, 
										  15, 5, 5, 15);
			sprite.graphics.endFill();
			return sprite;
		}
		
		/**
		 * Reset any readouts to initial conditions
		 * 
		 * @param isFullReset Set to true if resetting a complete game. Use false to reset just
		 * 					  the current level.
		 */
		public function reset(isFullReset:Boolean):void
		{
			if (isFullReset)
			{
				statsBoard.reset();
			}
		}
		
		/**
		 * Refresh for a new level
		 * 
		 * @param isDemo   Flag to indicate this is a demo.
		 * @param level    The level number
		 * @param count    The number of particles on this level
		 * @param bombs    The number of bombs the user has
		 * @param success  The number of particles to destroy to win on this level
		 * @param isReplay (optional) If true, user is re-playing this level. Default is false.
		 */
		public function initLevel(isDemo:Boolean, level:uint, count:uint, bombs:uint, 
								  success:uint, isReplay:Boolean = false):void
		{
			if (!isDemo)
			{
				var msg:String;
				if (isReplay)
					msg =  ResourceStrings.INSTRUCTIONS_REPLAY;
				else
					msg = ResourceStrings["INSTRUCTIONS_CALL_TO_ARMS" + String(level)];
				msg += ResourceStrings.LEVEL + String(level) + "!<br /><br />";
				var instructions:Array = ResourceStrings.INSTUCTIONS.split("XX");
				
				msg += instructions[0] + bombs + instructions[1] + String(success) + instructions[2] + 
						String(count) + instructions[3] + "<br /><br />";
				msg += ResourceStrings.WARNING;
				
				
				newInfo(msg, true);
				statsBoard.alpha = 1;
			}
			else
			{
				statsBoard.alpha = .75;
			}
			statsBoard.charges = bombs;
			
			statsBoard.resetForNewLevel();
			statsBoard.updateStats(0, success, count);
		}
		
		/**
		 * Event from Level. User has scored. Display it.
		 * 
		 * @param e The LevelEvent.SCORE event
		 */
		public function onScore(e:LevelEvent):void
		{
			var levelStats:LevelStats = e.levelStats;
			var reactionPoint:Point = levelStats.lastPointOfInterest;
			var scoreItem:ScoreItem = new ScoreItem("+" + String(levelStats.lastScore), 
													reactionPoint.x, reactionPoint.y);
			addChild(scoreItem);
			
			var sound:Sound = new SoundLib.EXPLODE_SOUND();
			sound.play();
			
			var destroyed:uint = levelStats.itemsTotal - levelStats.itemsRemaining;
			statsBoard.updateStats(destroyed, levelStats.itemsRequired, levelStats.itemsTotal);
		}
		
		/**
		 * Event from Level. User has scored. Display it.
		 * 
		 * @param e The LevelEvent.BOMB event
		 */
		public function onBomb(e:LevelEvent):void
		{
			statsBoard.debitCharge();
		}
		
		/**
		 * Event from the level. Level has concluded in failure
		 * 
		 * @param e The LevelEvent.FAILURE event
		 */
		public function onLevelFailure(e:LevelEvent):void
		{
			var sound:Sound = new SoundLib.FAIL_SOUND();
			sound.play();
			
			var levelStats:LevelStats = e.levelStats;
			var remaining:uint = levelStats.itemsRemaining;
			var total:uint = levelStats.itemsTotal;
			var destroyed:uint = total - remaining;
			var suddenDeath:Boolean = levelStats.suddenDeath;
			
			var condolenceNum:uint = Math.random() * 10;
			var condolence:String = ResourceStrings["CONDOLENCE" + String(condolenceNum)];
			
			var msg:String = condolence + "<br /><br />";
			
			if (suddenDeath)
			{
				msg += ResourceStrings.SUDDEN_FAIL;
			}
			else
			{
				var failMsgArray:Array = ResourceStrings.PERFORMANCE_FAIL.split("XX");
				msg += failMsgArray[0] + String(destroyed) + failMsgArray[1] + String(total) + failMsgArray[2];
			}
			
			var buttonRank:Array = new Array();
			
			var replayLevelButton:InfoButton = new InfoButton("Replay level", playButtonColor, 
															overButtonColor, downButtonColor);
			replayLevelButton.addEventListener(MouseEvent.CLICK, restartLevel);
			var restartButton:InfoButton = new InfoButton("Start over", playButtonColor, 
															overButtonColor, downButtonColor);
			restartButton.addEventListener(MouseEvent.CLICK, restartGame);
			
			
			buttonRank.push(replayLevelButton);
			buttonRank.push(restartButton);
			
			newInfo(msg, false, buttonRank, false, null, true);
		}
		
		/**
		 * Event passed forward from the level. Level has concluded in success
		 * 
		 * @param levelStats The stats from the current level
		 * @param score      The total game score
		 */
		public function onLevelSuccess(levelStats:LevelStats, score:Number):void
		{
			var sound:Sound = new SoundLib.SUCCESS_SOUND();
			sound.play();
			
			var remaining:uint = levelStats.itemsRemaining;
			var total:uint = levelStats.itemsTotal;
			var destroyed:uint = total - remaining;
			
			var msg:String = ResourceStrings.PERFORMANCE_SUCCESS0;
			
			var msgArray:Array = ResourceStrings.PERFORMANCE_SUCCESS1.split("XX");
			statsBoard.totalScore = String(score);
			
			
			var buttonRank:Array = new Array();
			var nextLevelButton:InfoButton = new InfoButton("Next Level", playButtonColor, 
															overButtonColor, downButtonColor);
			nextLevelButton.addEventListener(MouseEvent.CLICK, nextLevel);
			buttonRank.push(nextLevelButton);
			
			var msgQueue:Array = new Array();
			msgQueue.push(msgArray[0] + destroyed + msgArray[1] + total + msgArray[2]);
			
			
			if (levelStats.squiffs)
				msgQueue.push(ResourceStrings.SQUIFFS + ": " + levelStats.squiffs + 
								" (" + levelStats.squiffCost + ")");
			
			if (levelStats.cleared)
			{
				var clearBonusMsg:String = ResourceStrings.LEVEL_CLEARED;
				if (levelStats.bombs)
					clearBonusMsg += ResourceStrings.BOMBS_REMAINING;
					
				if (levelStats.minScoreOverride)
					msgQueue.push(ResourceStrings.LEVEL_CLEARED_MINIMUM + levelStats.scoreModifier);
					
				msgQueue.push(clearBonusMsg + "! (x" + levelStats.clearedBonus + ")");
			}
			
			
			msgQueue.push(ResourceStrings.LEVEL_SCORE + ": " + levelStats.score);
			msgQueue.push(ResourceStrings.GAME_SCORE + ": " + score);
			
			newInfo(msg, false, buttonRank, true, msgQueue, true);
		}
		
		/**
		 * Event forwarded from the game. Game is over.
		 * 
		 * @param levelStats The stats from the current level
		 * @param score      The total game score
		 */
		public function onGameOver(levelStats:LevelStats, score:Number):void
		{
			var sound:Sound = new SoundLib.SUCCESS_SOUND();
			sound.play();
			
			var remaining:uint = levelStats.itemsRemaining;
			var total:uint = levelStats.itemsTotal;
			var destroyed:uint = total - remaining;
			
			var msg:String = ResourceStrings.FINAL_SUCCESS0;
			
			var msgArray:Array = ResourceStrings.FINAL_SUCCESS1.split("XX");
			statsBoard.totalScore = String(score);
			
			var msgQueue:Array = new Array();
			msgQueue.push(msgArray[0] + destroyed + msgArray[1] + total + msgArray[2]);
			
			if (levelStats.squiffs)
				msgQueue.push(ResourceStrings.SQUIFFS + ": " + levelStats.squiffs + 
								" (" + levelStats.squiffCost + ")");
			
			if (levelStats.cleared)
			{
				var clearBonusMsg:String = ResourceStrings.LEVEL_CLEARED;
				if (levelStats.bombs)
					clearBonusMsg += ResourceStrings.BOMBS_REMAINING;
					
				if (levelStats.minScoreOverride)
					msgQueue.push(ResourceStrings.LEVEL_CLEARED_MINIMUM + levelStats.scoreModifier);
					
				msgQueue.push(clearBonusMsg + "! (x" + levelStats.clearedBonus + ")");
			}
			
			
			msgQueue.push(ResourceStrings.LEVEL_SCORE + ": " + levelStats.score);
			msgQueue.push(ResourceStrings.GAME_SCORE + ": " + score);
			
			msgQueue.push(ResourceStrings.FINAL_SUCCESS2);
			msgQueue.push(ResourceStrings.FINAL_SUCCESS3);
			
			var buttonRank:Array = new Array();
			var restartButton:InfoButton = new InfoButton("Start over", playButtonColor, 
															overButtonColor, downButtonColor);
			restartButton.addEventListener(MouseEvent.CLICK, restartGame);
			buttonRank.push(restartButton);
			
			newInfo(msg, false, buttonRank, true, msgQueue, true);
		}
		
		/**
		 * User has "squiffed", ie, Dropped a bomb and hit nothing whatsoever
		 * 
		 * @param e The LevelEvent.SQUIFF event
		 */
		public function onSquiff(e:LevelEvent):void
		{
			var reactionPoint:Point = e.levelStats.lastPointOfInterest;
			var scoreItem:ScoreItem = new ScoreItem(ResourceStrings.SQUIFF, reactionPoint.x, reactionPoint.y);
			addChild(scoreItem);
		}
		
		/**
		 * User has cleared all bots on the current level
		 * 
		 * @param e The LevelEvent.BOTS_CLEARED event
		 */
		public function onBotsCleared(e:LevelEvent):void
		{
			/** No implementation for now */
		}
		 
		/**
		 * Event from the play/pause button
		 * 
		 * @param e The CLICK MouseEvent
		 */
		private function onPlayPause(e:MouseEvent):void
		{
			var event:uint = (e.currentTarget.lastEventIndex);
			
			var gameEventType:String;
			
			if (event == PLAY)
			{
				dismissBoxes();
				gameEventType = GameEvent.PLAY;
			}
			else
			{
				gameEventType = GameEvent.PAUSE;
			}
				
			dispatchEvent(new GameEvent(gameEventType));			
		}
		 
		/**
		 * Event from the sound button. Toggle sound off/on
		 * 
		 * @param e The CLICK MouseEvent
		 */
		private function onToggleSound(e:MouseEvent):void
		{
			var event:uint = (e.currentTarget.lastEventIndex);
			var vol:Number = (event == PLAY) ? 0 : 1;
			var sTrans:SoundTransform = new SoundTransform(vol);
			SoundMixer.soundTransform = sTrans;
		}
		
		/**
		 * Create the play/pause multi-state button
		 */
		private function createPlayPauseBtn():void
		{
			var playButton:GameButton = new GameButton( ResourceStrings.PLAY, playButtonColor,
														overButtonColor, downButtonColor);
			var pauseButton:GameButton = new GameButton(ResourceStrings.PAUSE, playButtonColor,
														overButtonColor, downButtonColor);
			
			playPauseBtn = new MultiStateButton([playButton, pauseButton]);
			playPauseBtn.x = _playField.x + _playField.width + SPACER;
			playPauseBtn.y = _playField.x + _playField.height - playPauseBtn.height;
			addChild(playPauseBtn);
			playPauseBtn.addEventListener(MouseEvent.CLICK, onPlayPause);
		}
		
		/**
		 * Create the sound/mute button
		 */
		private function createSoundBtn():void
		{
			var btnHeight:Number = playPauseBtn.height - 6;
			
			var playSoundUpState:Sprite = new Sprite();
			playSoundUpState.graphics.beginFill(ColorLib.SOUND_BTN);
			playSoundUpState.graphics.drawRoundRect(0, 0, 50, btnHeight, 20, 20);
			playSoundUpState.graphics.endFill();
			playSoundUpState.addChild(new SoundOnIcon());
			
			var playSoundOverState:Sprite = new Sprite();
			playSoundOverState.graphics.beginFill(overButtonColor);
			playSoundOverState.graphics.drawRoundRect(0, 0, 50, btnHeight, 20);
			playSoundOverState.graphics.endFill();
			playSoundOverState.addChild(new SoundOnIcon());
			
			var playSoundDownState:Sprite = new Sprite();
			playSoundDownState.graphics.beginFill(downButtonColor);
			playSoundDownState.graphics.drawRoundRect(0, 0, 50, btnHeight, 20);
			playSoundDownState.graphics.endFill();
			playSoundDownState.addChild(new SoundOnIcon());
			
			var pauseSoundUpState:Sprite = new Sprite();
			pauseSoundUpState.graphics.beginFill(ColorLib.SOUND_BTN);
			pauseSoundUpState.graphics.drawRoundRect(0, 0, 50, btnHeight, 20);
			pauseSoundUpState.graphics.endFill();
			pauseSoundUpState.addChild(new SoundOffIcon());
			
			var pauseSoundOverState:Sprite = new Sprite();
			pauseSoundOverState.graphics.beginFill(overButtonColor);
			pauseSoundOverState.graphics.drawRoundRect(0, 0, 50, btnHeight, 20);
			pauseSoundOverState.graphics.endFill();
			pauseSoundOverState.addChild(new SoundOffIcon());
			
			var pauseSoundDownState:Sprite = new Sprite();
			pauseSoundDownState.graphics.beginFill(downButtonColor);
			pauseSoundDownState.graphics.drawRoundRect(0, 0, 50, btnHeight, 20);
			pauseSoundDownState.graphics.endFill();
			pauseSoundDownState.addChild(new SoundOffIcon());
			
			var playSoundBtn:SimpleButton = new SimpleButton(playSoundUpState, playSoundOverState, 
															 playSoundDownState, playSoundUpState); 
															 
			var muteSoundBtn:SimpleButton = new SimpleButton(pauseSoundUpState, pauseSoundOverState, 
															 pauseSoundDownState, pauseSoundUpState);
			
			soundBtn = new MultiStateButton([playSoundBtn, muteSoundBtn]);
			soundBtn.x = playPauseBtn.x + playPauseBtn.width - soundBtn.width;
			soundBtn.y = playPauseBtn.y + 3;
			
			addChild(soundBtn);
			soundBtn.addEventListener(MouseEvent.CLICK, onToggleSound);
		}
		
		/**
		 * Post a new info box
		 * 
		 * @param msg         	The text for the info box
		 * @param autoDismiss 	If true, the window will dismiss itself automatically
		 * @param buttonRank  	An array of InfoButtons to appear within the alert
		 * @param success		If true, level is complete
		 * @param msgQueue		Array of strings to display in the box
		 * @param isModal		If the infobox is modal, disable buttons
		 */
		protected function newInfo(msg:String, autoDismiss:Boolean = false, 
									buttonRank:Array = null, success:Boolean = false,
									msgQueue:Array = null, isModal:Boolean = false):void
		{
			dismissBoxes();
			if (isModal)
				disable();
				
			var ms:uint = (autoDismiss) ? autoDismissMS : 0;
			var infoBox:InfoBox;
			
			if (success)
				infoBox = new ExpandingInfoBox(300, 300, msg, ms, buttonRank, msgQueue);
			else
				infoBox = new InfoBox(300, 300, msg, ms, buttonRank);
			infoBox.x = _playField.x + (_playField.width/2);
			infoBox.y = _playField.y + (_playField.height/2);
			infoBox.addEventListener(Event.CLOSE, onClose);
			infoBox.addEventListener(Event.COMPLETE, onInfoComplete);
			alerts.push(infoBox);
			addChild(infoBox);
		}
		
		/**
		 * Event from Help button
		 * 
		 * @param e The Mouse CLICK event
		 */
		private function onHelp(e:MouseEvent):void
		{
			dismissBoxes();
			
			var helpBox:HelpBox;
			if (e.currentTarget == learnBtn)
				helpBox = new HelpBox(300, 400, "content/learn.swf");
			else
				helpBox = new HelpBox(300, 400, "content/help.swf");
			helpBox.addEventListener(Event.CLOSE, onClose);
			helpBox.addEventListener(Event.COMPLETE, onInfoComplete);
			helpBox.x = _playField.x + (_playField.width/2);
			helpBox.y = _playField.y + (_playField.height/2);
			alerts.push(helpBox);
			addChild(helpBox);
		}
		
		/**
		 * Enable chrome buttons
		 */
		private function enable():void
		{
			playPauseBtn.alpha = 1;
			learnBtn.alpha = 1;
			helpBtn.alpha = 1;
			
			playPauseBtn.enabled = true;
			learnBtn.enabled = learnBtn.mouseEnabled = true;
			helpBtn.enabled = helpBtn.mouseEnabled = true;
			
			playPauseBtn.addEventListener(MouseEvent.CLICK, onPlayPause);
		}
		
		/**
		 * Disable chrome buttons
		 */
		private function disable():void
		{
			playPauseBtn.alpha = .25;
			learnBtn.alpha = .25;
			helpBtn.alpha = .25;
			
			playPauseBtn.enabled = false;
			learnBtn.enabled = learnBtn.mouseEnabled = false;
			helpBtn.enabled = helpBtn.mouseEnabled = false;
			
			playPauseBtn.removeEventListener(MouseEvent.CLICK, onPlayPause);
		}
		
		/**
		 * Event from info/help box. It's informing us it would like to close.
		 * 
		 * @param e The CLOSE event
		 */
		private function onClose(e:Event):void
		{
			dismissBoxes();
		}
		
		/**
		 * Event from info/help box. It's requesting to destroyed.
		 * 
		 * @param e The COMPLETE event
		 */
		private function onInfoComplete(e:Event):void
		{
			var info:InfoBox = e.target as InfoBox;
			
			var a:uint = alerts.length;
			while (a--)
			{
				var alert:InfoBox = alerts[a] as InfoBox;
				if (alert == info)
				{
					alerts.splice(a, 1);
					alert.destroy();
					break;
				}
			}
			
			enable();
		}
		
		/**
		 * Event from Infobox. User requests move to next level
		 * 
		 * @param e The MouseEvent.CLICK event
		 */
		private function nextLevel(e:MouseEvent):void
		{
			dismissBoxes();
			dispatchEvent(new GameEvent(GameEvent.NEXT_LEVEL));
		}
		
		/**
		 * Event from Infobox. User requests replay of current level
		 * 
		 * @param e The MouseEvent.CLICK event
		 */
		private function restartLevel(e:MouseEvent):void
		{
			dismissBoxes();
			dispatchEvent(new GameEvent(GameEvent.RESTART_LEVEL));
		}
		
		/**
		 * Event from Infobox. User requests new game
		 * 
		 * @param e The MouseEvent.CLICK event
		 */
		private function restartGame(e:MouseEvent):void
		{
			dismissBoxes();
			dispatchEvent(new GameEvent(GameEvent.RESTART_GAME));
		}
		
		/**
		 * Dismiss existing info and help boxes
		 * 
		 * We only allow one info box at a time, but we want the old one to be able
		 * to animate away cleanly. Storing in an array like this allows unrestricted
		 * monkey-bashing.
		 */
		private function dismissBoxes():void
		{
			var a:uint = alerts.length;
			while (a--)
			{
				var alert:InfoBox = alerts.pop() as InfoBox;
				alert.dismiss();
			}
		}
	}
}