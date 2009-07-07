/**
 * Model representing the position, state and size of a bomb
 */

package model
{
	
	import events.BombEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	
	import view.BombView;
	
	public class Bomb extends EventDispatcher
	{
		/******************************
		 * Public static constants
		 ******************************/
		 
		/** State of bomb when deplyed, but not exploded. */
		public static const FREE_STATE:uint = 8;
		
		/** State of bomb when exploding. */
		public static const EXPLODE_STATE:uint = 0;
		
		/** State of bomb when done exploding. */
		public static const FADE_STATE:uint = 1;
		
		/** State of bomb when done (simply awaiting cleanup). */
		public static const INVALID_STATE:uint = 2;
		
		/** State of bomb when done (simply awaiting cleanup). */
		public static const DESTROYED_STATE:uint = 4;
		
		
		/******************************
		 * Private members
		 ******************************/
		/** Current state of the bomb */
		protected var _state:uint;
		 
		/** x position of this bomb */
		protected var _x:Number;
		
		/** y position of this bomb */
		protected var _y:Number;
		
		/** Current radius of this bomb */
		protected var _radius:Number;
		
		/** Bomb's color */
		protected var _color:uint;
		
		/** Maximum alpha for each bot/bomb */
		protected var alphaMax:Number;
		
		/** Minimum alpha at which we determine the bomb/bot is no longer reacting */
		protected var alphaMin:Number = 0;
		
		/** Beginning radius of this bomb */
		protected var startRadius:Number;
		
		/** Final radius of this bomb */
		protected var endRadius:Number;
		
		/** Difference between start and end radii (used to avoid repeated calculation) */
		protected var radiusDifference:Number;
		
		/** Current timer ticks for this bomb */
		protected var ticks:uint;
		
		/** Timer ticks for this bomb's explode phase */
		protected var explodeTicks:uint;
		
		/** Timer ticks for this bomb's fade phase */
		protected var fadeTicks:uint;
		
		/** Total timer ticks for this bomb (used to avoid repeated calculation) */
		protected var totalTicks:uint;
		
		/** Visual representation of this bomb */
		protected var sprite:BombView;
		
		/**
		 * Constructor
		 * 
		 * @param xPos         X position
		 * @param yPos         Y position
		 * @param alphaMax     The start alpha for the bomb
		 * @param alphaMin     The point at which we determine the bomb is no longer reacting
		 * @param color        The color for the bomb
		 * @param startRadius  The initial size of the bomb
		 * @param endRadius    The final size of the bomb
		 * @param explodeTicks Number of timer ticks for this bomb's explode phase
		 * @param fadeTicks    Number of timer ticks for this bomb's fade phase
		 */
		public function Bomb(xPos:Number,
							 yPos:Number,
							 alphaMax:Number, 
							 alphaMin:Number,
							 color:uint, 
							 startRadius:Number, 
							 endRadius:Number, 
							 explodeTicks:uint, 
							 fadeTicks:uint)
		{
			this._x = xPos;
			this._y = yPos;
			this.alphaMax = alphaMax;
			this.alphaMin = alphaMin;
			this._color = color;
			this.startRadius = startRadius;
			this.endRadius = endRadius;
			this.explodeTicks = explodeTicks;
			this.fadeTicks = fadeTicks;
			
			totalTicks = explodeTicks + fadeTicks;
			radiusDifference = endRadius - startRadius;
			_radius = startRadius;
			
			_state = FREE_STATE;
		}
		
		/**
		 * Get the string value of the bot
		 * 
		 * @return The class name
		 */
		override public function toString():String
		{
			return "model.Bomb";
		}
		
		/**
		 * Explode the bomb and dispatch the EXPLODE event.
		 * 
		 * @param isPrimaryEvent If 'true', explosion is first in a chain
		 * 						 (default is 'false')
		 */
		public function explode(isPrimaryEvent:Boolean = false):void
		{
			_state = EXPLODE_STATE;
			ticks = 0;
			dispatchEvent(new BombEvent(isPrimaryEvent, BombEvent.EXPLODE));
		}
		
		/**
		 * Update position of the bomb
		 */
		public function update():void
		{
			ticks ++;
			
			var alpha:Number = alphaMax;
			
			switch (_state)
			{
				case EXPLODE_STATE:
					_radius = (ticks/explodeTicks) * radiusDifference;
					alpha = alphaMax;
					if (ticks > explodeTicks)
						_state = FADE_STATE;
					break;
				case FADE_STATE:
				case INVALID_STATE:
					/* Complicated-looking equation simply tweens alpha from alphaMax to 0 */
					alpha = alphaMax - (((ticks - explodeTicks) / fadeTicks) * alphaMax);
					if (alpha < alphaMin)
						invalidate();
					if (ticks > totalTicks)
						destroy();
					break;
			}
			sprite.update(_x, _y, _radius, alpha);
		}
		
		/**
		 * Event from timer. Time to update.
		 * 
		 * @param e TimerEvent
		 */
		public function onTimerUpdate(e:TimerEvent):void
		{
			update();
		}
		
		/**
		 * Set a view sprite to link to this model
		 * 
		 * @param bombView The view to this model
		 */
		public function set view(bombView:BombView):void
		{
			sprite = bombView as BombView;
			addEventListener(BombEvent.EXPLODE, sprite.onExplode);
		}
		
		/**
		 * Getter for bomb's state
		 * 
		 * @return The state of the bomb (see class prologue for details)
		 */
		public function get state():uint
		{
			return _state;
		}
		
		/**
		 * Getter for radius of bomb
		 * 
		 * @return The radius
		 */
		public function get radius():Number
		{
			return _radius;
		}
		
		/**
		 * Getter for x position of bomb
		 * 
		 * @return the x ordinate
		 */
		public function get x():Number
		{
			return _x;
		}
		
		/**
		 * Setter for y position of bomb
		 * 
		 * @param _x The new value for x
		 */
		public function set x(_x:Number):void
		{
			this._x = _x;
		}
		
		/**
		 * Getter for y position of bomb
		 * 
		 * @return the y ordinate
		 */
		public function get y():Number
		{
			return _y;
		}
		
		/**
		 * Setter for y position of bomb
		 * 
		 * @param _y The new value for y
		 */
		public function set y(_y:Number):void
		{
			this._y = _y;
		}
		
		/**
		 * Getter for the color property of the bomb
		 * 
		 * @return The color of the bomb
		 */
		public function get color():uint
		{
			return _color;
		}
		
		/**
		 * This bomb is no longer reacting. Issue an INVALIDATE event.
		 */
		protected function invalidate():void
		{
			dispatchEvent(new BombEvent(false, BombEvent.INVALIDATE));
		}
		
		/**
		 * This bomb has expired. Issue a CONCLUDE event and remove the sprite.
		 */
		public function destroy():void
		{
			_state = DESTROYED_STATE;
			dispatchEvent(new BombEvent(false, BombEvent.CONCLUDE));
			sprite.parent.removeChild(sprite);
		}
	}
}