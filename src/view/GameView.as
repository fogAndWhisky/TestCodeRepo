/**
 * Main level view.
 * 
 * Note that views in this game are 'dumb'. All functional logic is driven from controller and model.
 */

package view
{
	import events.LevelEvent;
	
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import model.Bot;
	import model.BotManager;
	
	public class GameView extends Sprite
	{
		/** Metric for shake effect when bomb droppped */
		protected const SHAKE_RANGE:Number = 7;
		/** Half the preceding number */
		protected const HALF_SHAKE_RANGE:Number = SHAKE_RANGE/2;
		
		/** A reference to the Model's BotManager, the list of all bots */
		protected var manager:BotManager;
		
		/** Timer to handle shake event */
		protected var shakeTimer:Timer;
		
		/** Rectangle defining the metrics of the play area */
		protected var playField:Rectangle;
		
		/**
		 * Constructor
		 * 
		 * @param manager   A reference to the Model's BotManager, the list of all bots
		 * @param playField Rectangle defining the metrics of the play area
		 */
		public function GameView(manager:BotManager, playField:Rectangle)
		{
			this.manager = manager;
			generateChildren();
			mask = GameChrome.getGameMask();
			this.playField = playField;
		}
		
		/**
		 * Create the visual representation of all bots.
		 * 
		 * After creation, a reference is handed back to the individual Bot models,
		 * so updates may be managed directly from the models
		 */
		public function generateChildren():void
		{
			var len:uint = manager.length;
			var botList:Array = manager.getBotList();
			for (var a:uint = 0; a < len; a++)
			{
				var bot:Bot = botList[a] as Bot;
				var botView:BombView = new BombView(bot);
				bot.view = botView;
				
				addChild(botView);
			}
		}
		
		/**
		 * Cleanly deconstruct this view
		 */
		public function destroy():void
		{
			mask = null;
			releaseShakeTimerListeners();
			parent.removeChild(this);
			delete this;
		}
		
		/**
		 * Event from level. A bomb has been dropped
		 * 
		 * @param e The LevelEvent.BOMB event
		 */
		public function onBomb(e:LevelEvent):void
		{
			startShake();
			
			/* Create cool lightning bolt effect */
			var r:uint = Math.random() * 4;
			var start:Point;
			
			switch (r)
			{
				case 0:
					start = new Point(playField.x, playField.y);
					break;
				case 1:
					start = new Point(playField.x + playField.width, playField.y);
					break;
				case 2:
					start = new Point(playField.x + playField.width, playField.y + playField.height);
					break;
				case 3:
					start = new Point(playField.x, playField.y + playField.height);
					break;
			}
			var reactionPoint:Point = e.levelStats.lastPointOfInterest;
			var lightning:LightningBolt = new LightningBolt(start, new Point(reactionPoint.x, reactionPoint.y));
			addChild(lightning);
		}
		
		/**
		 * Begin shake action
		 */
		protected function startShake():void
		{
			releaseShakeTimerListeners();
				
			shakeTimer = new Timer(15, 15);
			shakeTimer.addEventListener(TimerEvent.TIMER, onShake);
			shakeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onShakeComplete);
			shakeTimer.start();
		}
		
		/**
		 * Randomly jiggle the view on each shake
		 * 
		 * @param e The TimerEvent.TIMER event
		 */
		protected function onShake(e:TimerEvent):void
		{
			x = (Math.random() * SHAKE_RANGE) - HALF_SHAKE_RANGE;
			y = (Math.random() * SHAKE_RANGE) - HALF_SHAKE_RANGE;
		}
		
		/**
		 * Place the view back where it started
		 * 
		 * @param e The TimerEvent.TIMER_COMPLETE event
		 */
		protected function onShakeComplete(e:TimerEvent):void
		{
			x = 0;
			y = 0;
			releaseShakeTimerListeners();
		}
		
		/**
		 * Remove shake event listeners
		 */
		protected function releaseShakeTimerListeners():void
		{
			if (shakeTimer)
			{
				shakeTimer.removeEventListener(TimerEvent.TIMER, onShake);
				shakeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onShakeComplete);
			}
		}
	}
}