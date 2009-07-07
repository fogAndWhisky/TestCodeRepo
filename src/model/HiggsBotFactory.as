/**
 * Custom BotFactory for Higgs version. Adds unique unique creation behavior
 * for 'special' Higgs Boson.
 */

package model
{
	import assetLib.ColorLib;
	
	public class HiggsBotFactory extends BotFactory
	{

		/**
		 * Generate a new bot
		 * 
		 * @param x (optional) 		 A specific X location to place the bot. Random by default.
		 * @param y (optional) 		 A specific Y location to place the bot. Random by default.
		 * @param isHiggs (optional) If true, the bot is a Higgs Boson (default is 'false').
		 * 
		 * @return The newly created Bot
		 */
		public static function newBot(x:Number = NaN, y:Number = NaN, isHiggs:Boolean = false):Bot
		{
			if (isInited)
			{
				var vel:Number = (Math.random() * (maxBotSpeed - minBotSpeed)) + minBotSpeed;
				
				if (isNaN(x))
					x = Math.random() * width;
				if (isNaN(y))
					var y:Number = Math.random() * height;
					
				
				var alpha:Number;
				var color:uint;
				var radius:Number;
				
				if (isHiggs)
				{
					alpha = 1;
					color = ColorLib.BLACK;
					radius = 10;
					
					return new HiggsBoson(x, y, alpha, BombFactory.alphaMin, 
							   color, radius, BombFactory.endRadius, BombFactory.explodeTicks, 
							   BombFactory.fadeTicks, vel);
				}
				else
				{
					alpha = botAlpha;
					var colorIndex:uint = Math.random() * botColors.length;
					color = botColors[colorIndex];
					radius = botRadius;
					
					return new Bot(x, y, alpha, BombFactory.alphaMin, 
							   color, radius, BombFactory.endRadius, BombFactory.explodeTicks, 
							   BombFactory.fadeTicks, vel);
				}
				
				
			}
			else
			{
				throw new Error("Field parameters must be set using BotFactory.setBotParams() before creating a new bot");
			}
		}
	}
}