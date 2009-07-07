/**
 * Static factory class for generating bombs
 */

package model
{
	public class BombFactory
	{
		/******************************
		 * Protected statics
		 ******************************/
		public static var alphaMax:Number;
		public static var alphaMin:Number;
		public static var color:uint;
		public static var startRadius:Number;
		public static var endRadius:Number;
		public static var explodeTicks:Number;
		public static var fadeTicks:Number;
		/** Gate to ensure parameters set before use */
		private static var isInited:Boolean;
		
		/**
		 * Set the parameters for bomb creation
		 * 
		 * @note You must set this before generating any bombs
		 * 
		 * @param alphaMax     Initial alpha for a bomb
		 * @param alphaMin     Alpha bomb will fade to when exploding
		 * @param bombColor	   Color of the bomb
		 * @param startRadius  Initial radius for a bomb
		 * @param endRadius    Final radius for a bomb
		 * @param explodeTicks Number of timer ticks for the bomb's explode phase
		 * @param fadeTicks    Number of timer ticks for the bomb's fade phase
		 */
		public static function setBombParams(alphaMax:Number, alphaMin:Number, bombColor:uint, 
										     startRadius:Number, endRadius:Number, explodeTicks:Number, fadeTicks:Number):void
		{
			BombFactory.alphaMax = alphaMax;
			BombFactory.alphaMin = alphaMin;
			BombFactory.color = bombColor;
			BombFactory.startRadius = startRadius;
			BombFactory.endRadius = endRadius;
			BombFactory.explodeTicks = explodeTicks;
			BombFactory.fadeTicks = fadeTicks;
			
			isInited = true;
		}
		
		/**
		 * Generate a new bomb
		 * 
		 * @param x X position to place the bomb
		 * @param y Y position to place the bomb
		 * 
		 * @return  The bomb instance
		 */
		public static function newBomb(x:Number, y:Number):Bomb
		{
			if (isInited)
			{
				return new Bomb(x, y, alphaMax, alphaMin, color, startRadius, endRadius, explodeTicks, fadeTicks);
			}
			else
			{
				throw new Error("Bomb parameters must be set using BombFactory.setBombParams() before creating a new bomb");
			}
		}

	}
}