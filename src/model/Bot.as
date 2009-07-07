/**
 * Model representing the position, velocity and state of each bot. Subclassed from Bomb,
 * as bot characteristics and behaviors (other than motion) essentially derive from bomb.
 */

package model
{
	import net.sfmultimedia.display.Axis;
	
	public class Bot extends Bomb
	{
		
		/** x component of movement */
		protected var xVel:Number;
		
		/** y component of movement */
		protected var yVel:Number;
		
		/**
		 * Constructor
		 * 
		 * @param xPos         X position
		 * @param yPos         Y position
		 * @param alphaMax     The start alpha for the bot
		 * @param alphaMin     The end alpha for the bot
		 * @param color        The color for the bot
		 * @param startRadius  The initial size of the bot
		 * @param endRadius    The final size of the bot
		 * @param explodeTicks Number of timer ticks for this bot's explode phase
		 * @param fadeTicks    Number of timer ticks for this bot's fade phase
		 * @param botVel       The single-axis velocity of this bot
		 */
		public function Bot(xPos:Number,
							yPos:Number,
							alphaMax:Number, 
		                    alphaMin:Number,
		                    color:uint, 
		                    startRadius:Number, 
		                    endRadius:Number, 
		                    explodeTicks:uint, 
		                    fadeTicks:uint,
							botVel:Number)
		{
			super(xPos, yPos, alphaMax, alphaMin, color, startRadius, endRadius, explodeTicks, fadeTicks);
			
			/* Set motion to one of four diagonals */
			var dirIndex:uint = Math.random() * 4;
			switch (dirIndex)
			{
				case 0:
					xVel = -botVel;
					yVel = -botVel;
					break;
				case 1:
					xVel = botVel;
					yVel = -botVel;
					break;
				case 2:
					xVel = botVel;
					yVel = botVel;
					break;
				case 3:
					xVel = -botVel;
					yVel = botVel;
					break;
			}
		}
		
		/**
		 * Get the string value of the bot
		 * 
		 * @return The class name
		 */
		override public function toString():String
		{
			return "model.Bot";
		}

		/**
		 * Update position of the bot
		 */
		override public function update():void
		{
			var alpha:Number = alphaMax;
				
			switch (_state)
			{
				case FREE_STATE:
					_x += xVel;
					_y += yVel;
					break;
				case EXPLODE_STATE:
					ticks ++;
					_radius = (ticks/explodeTicks) * radiusDifference;
					if (ticks > explodeTicks)
						_state = FADE_STATE;
					break;
				case FADE_STATE:
				case INVALID_STATE:
					ticks ++;
					/* Complicated-looking equation simply tweens alpha from alphaMax to 0 */
					alpha = alphaMax - (((ticks - explodeTicks) / fadeTicks) * alphaMax);
					
					if (alpha < alphaMin)
						invalidate();
					if (ticks >= totalTicks)
						destroy();
					break;
			}
			sprite.update(_x, _y, _radius, alpha);
		}
		
		/**
		 * Reflect across the requested axis.
		 * 
		 * @param axis     Axis.X or Axis.Y, according to the axis across which we're reflecting
		 * @param position The new position of the bot, to avoid breaking the limit box
		 */
		public function reflect (axis:int, position:Number):void
		{
			if (axis == Axis.X)
			{
				_x = position;
				xVel *= -1;
			}
			else
			{
				_y = position;
				yVel *= -1;
			}
		}
	}
}