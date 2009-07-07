/**
 * Unique class for the 'special' bot within this version of the game.
 * 
 * NOTE: this subclass exists specifically so that we can identify it within the HiggsBotManager
 * as a unique class. Thus there is no new code here, just a uniquely identifiable class.
 * This mightn't be the best way to handle this. Consider re-factor.
 */

package model
{
	public class HiggsBoson extends Bot
	{
		/**
		 * Constructor
		 * 
		 * See superclass for details
		 */
		public function HiggsBoson(xPos:Number, yPos:Number, alphaMax:Number, alphaMin:Number, color:uint, startRadius:Number, endRadius:Number, explodeTicks:uint, fadeTicks:uint, botVel:Number)
		{
			super(xPos, yPos, alphaMax, alphaMin, color, startRadius, endRadius, explodeTicks, fadeTicks, botVel);
		}
		
	}
}