/**
 * Viewer for all the game stats, including:
 * 
 * Score
 * Charges
 * Level stats:
 * 		Destroyed so far / Bots this level
 * 		Required for success
 * 		Score for this level
 * 
 */


package view
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import assetLib.ColorLib;
	import assetLib.ResourceStrings;

	public class StatsBoard extends Sprite
	{
		/***********
		 * Private consts
		 ***********/
		/** Color of the background rect */
		private const bgColor:uint = ColorLib.PARTICLE_2;
		/** Text folor */
		private const fgColor:uint = ColorLib.DARK_TEXT;
		/** Pixel space between items and edges */
		private const SPACER:Number = 20;
		
		/**
		 * If space gets too squeezed, we downsize the charge icons
		 * Minimum slop space before downsizing
		 */
		private const mininimumSpace:Number = 20;
		/** When downsizing, value to slice out of icon size */
		private const downSizeMultiplier:Number = .25;
		
		/***********
		 * Protected members
		 ***********/
		/** Set of tiles telling user how many charges left */
		private var chargeBoard:ChargeBoard;
		/** Textfields displaying score for the entire game */
		private var gameScoreLabelTxt:TextField;
		private var gameScoreTxt:TextField;
		
		/** TextFormat applied to all text fields */
		protected var _textFormat:TextFormat;

		/** Meter indicating progress within level */
		protected var meter:CompletionMeter;
		
		/**
		 * Constructor
		 * 
		 * @param w Width of the scoreboard
		 * @param h Height of the scoreboard
		 */
		public function StatsBoard(w:Number, h:Number)
		{
			super();
			
			_textFormat = new TextFormat();
			_textFormat.align = TextFormatAlign.CENTER;
			_textFormat.color = fgColor;
			_textFormat.size = 18;
			_textFormat.font = "_GameFont";
			
			graphics.beginFill(bgColor, 1);
			graphics.drawRoundRect(0, 0, w, h, 20, 20);
			graphics.endFill();
			
			/* Game score and label */
			gameScoreLabelTxt = createTextField();
			gameScoreLabelTxt.x = 0;
			gameScoreLabelTxt.y = SPACER;
			addChild(gameScoreLabelTxt);
			
			gameScoreLabelTxt.text = ResourceStrings.GAME_SCORE;
			
			gameScoreTxt = createTextField();
			gameScoreTxt.x = 0;
			gameScoreTxt.y = gameScoreLabelTxt.y + gameScoreLabelTxt.textHeight + SPACER;
			addChild(gameScoreTxt);
			
			chargeBoard = new ChargeBoard(w - (SPACER * 2), 50);
			chargeBoard.x = SPACER;
			chargeBoard.y = gameScoreTxt.y + gameScoreTxt.height + SPACER;
			addChild(chargeBoard);
			
			meter = new CompletionMeter(w - (SPACER * 2), 50);
			meter.x = SPACER;
			meter.y = chargeBoard.y + chargeBoard.height + SPACER;
			addChild(meter);
			
			reset();
		}
		
		/**
		 * Set back to default state
		 */
		public function reset():void
		{
			gameScoreTxt.text = "0";
		}
		
		/**
		 * Set back to default state
		 */
		public function resetForNewLevel():void
		{
			/* No implementation needed for now */
		}
		
		/**
		 * Set the score for the game
		 * 
		 * Note that this is simply a display of score, so we use a string
		 * 
		 * @param text The text to place in the Scoreboard's text field
		 */
		public function set totalScore(text:String):void
        {
        	gameScoreTxt.text = text;
        }
		
		/**
		 * Set the score for the level
		 * 
		 * Note that this is simple a display of score, so we use a string
		 * 
		 * @param text The text to place in the Scoreboard's text field
		 */
		public function set levelScore(text:String):void
        {
        	/* No implementation needed for now */
        }
        
       /**
        * Update level information
        * 
        * @param destroyed	Items destroyed so far
        * @param required	Items required to achieve success threshold
        * @param total		Total items on this level
        */
       public function updateStats(destroyed:uint, required:uint, total:uint):void
       {
       		meter.update(destroyed, required, total);
       }
		
		/**
		 * Set the number of charges in the charge board
		 * 
		 * @param count The number of charges to set
		 */
		public function set charges(count:uint):void
		{
			chargeBoard.charges = count;
		}
		
		/**
		 * Remove a charge tile
		 */
		public function debitCharge():void
		{
			chargeBoard.debit();
		}
		
		/**
		 * Create a generic text field for the stats board
		 * 
		 * @return The created TextField
		 */
		protected function createTextField():TextField
		{
			var textField:TextField = new TextField();
			textField.defaultTextFormat = _textFormat;
			textField.embedFonts = true;
			textField.text = "0";
			textField.selectable = false;
			textField.width = width;
			textField.height = textField.textHeight;
			return textField;
		}
	}
}