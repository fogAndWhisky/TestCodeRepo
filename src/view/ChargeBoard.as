/**
 * Part of the stats board. Displays remaining bombs (charges).
 */

package view
{
	import fl.transitions.easing.Strong;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	import assetLib.ColorLib;

	public class ChargeBoard extends Sprite
	{
		
		/** Color of the charge board */
		private const bgColor:uint = ColorLib.BACKGROUND;
		/**
		 * If space gets too squeezed, we downsize the charge icons
		 * Minimum slop space before downsizing
		 */
		private const mininimumSpace:Number = 20;
		/** When downsizing, value to slice out of icon size */
		private const downSizeMultiplier:Number = .25;
		
		/** Number of charges */
		private var _charges:uint;
		/** Holder for the bank of icons */
		private var chargeBank:Sprite;
		
		/** Value used to determine width of board  */
		private var useWidth:Number;
		/** Value used to determine height of board  */
		private var useHeight:Number;
		/**
		 * Constructor
		 * 
		 * @param w Width of the scoreboard
		 * @param h Height of the scoreboard
		 */
		public function ChargeBoard(w:Number, h:Number)
		{
			super();
			
			useWidth = w;
			useHeight = h;
			
			graphics.beginFill(bgColor, 1);
			graphics.drawRoundRect(0, 0, w, h, 20, 20);
			graphics.endFill();
			
			chargeBank = new Sprite();
			
			addChild(chargeBank);
		}
		
		/**
		 * Set the number of charges
		 * 
		 * @param count The number of charges to set
		 */
		public function set charges(count:uint):void
		{
			_charges = count;
			var charge:Sprite;
			
			while(chargeBank.numChildren)
			{
				chargeBank.removeChildAt(0);
			}
			
			//create charge icons
			for (var a:uint = 0; a < count; a++)
			{
				charge = new ChargeTile();
				charge.y = useHeight/2 - (charge.height/2);
				chargeBank.addChild(charge);
			}
			
			//distribute x position
			var spaceSpokenFor:Number = charge.width * count;
			 
			
			//if we've not enough space, resize all tiles
			if (spaceSpokenFor > useWidth - mininimumSpace)
			{
				for (a = 0; a < count; a++)
				{
					charge = chargeBank.getChildAt(a) as Sprite;
					charge.width = charge.height = (useWidth / count);
					charge.width = charge.height -= charge.height * downSizeMultiplier;
					charge.y = useHeight/2 - (charge.height/2);
				}
				
				spaceSpokenFor = charge.width * count; 
			}
			
			var spacer:Number = (useWidth - spaceSpokenFor) / (count + 1);
			
			for (a = 0; a < count; a++)
			{
				charge = chargeBank.getChildAt(a) as Sprite;
				charge.x = (charge.width * a) + (spacer * (a + 1));
			}
		}
		
		/**
		 * Remove a charge tile
		 */
		public function debit():void
        {
        	//fade a charge
        	if (_charges)
        	{
        		_charges --;
        		var charge:ChargeTile = chargeBank.getChildAt(_charges) as ChargeTile;
        		charge.fade();
        	}
        }
	}
}