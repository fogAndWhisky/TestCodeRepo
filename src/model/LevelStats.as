/**
 * Value Object containing information about a user's performance on a specific level
 */

package model
{
	import flash.geom.Point;
	
	public class LevelStats
	{
		/** Raw number of items destroyed */
		public var rawScore:Number = 0;
		/** Calculated score */
		public var score:Number = 0;
		/** Modifier for this level (gets multiplied by rawScore) */
		public var scoreModifier:Number = 1;
		/** Count of bombs dropped without hitting any other items */
		public var squiffs:Number = 0;
		/** Points lost from squiffs */
		public var squiffCost:Number = 0;
		/** True only if all items cleared on this level */
		public var cleared:Boolean = false;
		/** True only if user commits a game losing foul */
		public var suddenDeath:Boolean = false;
		/** Multiplier for clearing level */
		public var clearedBonus:Number = 1;
		/** Total count of items released on this level */
		public var itemsTotal:uint = 0;
		/** Remaining count of items */
		public var itemsRemaining:uint = 0;
		/** Count of items required to gain 'success' conditions */
		public var itemsRequired:uint = 0;
		/** Count of bombs remaining in this level */
		public var bombs:uint = 0;
		
		/** 
		 * Flag for rare occassion: tabulated score < 0, but level cleared
		 * Protects user from being penalised for clearing a level after multiple squiffs.
		 */
		public var minScoreOverride:Boolean = false;
		
		/******************************
		 * The following define "instant" properties of the level,
		 * characterising the latest version of a property
		 ******************************/
		/** The last position something "interesting" happened on this level */
		public var lastPointOfInterest:Point = new Point();
		/** The latest score for the level */
		public var lastScore:Number = 0;
		
		/**
		 * Constructor
		 */
		public function LevelStats()
		{
		}
	}
}