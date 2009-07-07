/**
 * Static factory class for generating bots
 */


package model
{
	public class BotFactory
	{
		/******************************
		 * Protected statics
		 ******************************/
		protected static var width:int;
		protected static var height:int;
		protected static var minBotSpeed:Number;
		protected static var maxBotSpeed:Number;
		protected static var botRadius:Number;
		protected static var botColors:Array;
		protected static var botAlpha:Number;
		/** Gate to ensure parameters set before use */
		protected static var isInited:Boolean;
		
		/**
		 * Set the parameters for bot creation
		 * 
		 * @note You must set this before generating any bots
		 * 
		 * @param w          Width of the play area
		 * @param h          Height of the play area
		 * @param minSpeed   Minimum allowable speed for a bot
		 * @param maxSpeed   Maximum allowable speed for a bot
		 * @param initRadius Initial bot size
		 * @param botColor   Bot color
		 * @param botAlpha   Bot alpha
		 */
		public static function setBotParams(w:int, h:int, minSpeed:Number, maxSpeed:Number,
											initRadius:Number, botColors:Array, botAlpha:Number):void
		{
			width = w;
			height = h;
			minBotSpeed = minSpeed;
			maxBotSpeed = maxSpeed;
			botRadius = initRadius;
			BotFactory.botColors = botColors;
			BotFactory.botAlpha = botAlpha;
			
			isInited = true;
		}
		
		/**
		 * Generate a new bot
		 * 
		 * @param x (optional) A specific X location to place the bot. Random by default.
		 * @param y (optional) A specific Y location to place the bot. Random by default.
		 * 
		 * @return The newly created Bot
		 */
		public static function newBot(x:Number = NaN, y:Number = NaN):Bot
		{
			if (isInited)
			{
				var vel:Number = (Math.random() * (maxBotSpeed - minBotSpeed)) + minBotSpeed;
				var colorIndex:uint = Math.random() * botColors.length;
				var color:uint = botColors[colorIndex];
				if (isNaN(x))
					x = Math.random() * width;
				if (isNaN(y))
					var y:Number = Math.random() * height;
				
				return new Bot(x, y, botAlpha, BombFactory.alphaMin, 
							   color, botRadius, BombFactory.endRadius, BombFactory.explodeTicks, 
							   BombFactory.fadeTicks, vel);
			}
			else
			{
				throw new Error("Field parameters must be set using BotFactory.setBotParams() before creating a new bot");
			}
		}
	}
}