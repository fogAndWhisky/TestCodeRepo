/**
 * Descendant of GameButton, with a specialized defineMetrics method which uses slightly modified
 * metrics. 
 */

package controller
{
	public class InfoButton extends GameButton
	{
		/* Metrics */
		private const GB_HEIGHT:Number = 150;
		private const GB_WIDTH:Number = 35;
		private const GB_FONTSIZE:Number = 16;
		
		/**
		 * Constructor
		 * 
		 * @param label     The text for this button
		 * @param upColor   The color for this button in the 'up' state
		 * @param overColor The color for this button in the 'over' state
		 * @param downColor The color for this button in the 'down' state
		 */
		public function InfoButton(label:String, upColor:uint, overColor:uint, downColor:uint)
		{
			super(label, upColor, overColor, downColor);
		}
		
		/**
		 * Some custom metrics for this button
		 */
		override protected function defineMetrics():void
		{
			w = GB_HEIGHT;
			h = GB_WIDTH;
			rad = DEFAULT_RAD;
			fontSize = GB_FONTSIZE;
		}
	}
}