/**
 * Main controller class for game (Not for chrome UI).
 * 
 * Mostly this just manages the Mouse with a pulsing cursor. Might add Key events later.
 */

package controller
{
	import assetLib.ColorLib;
	
	import gs.TweenMax;
	import gs.events.TweenEvent;
	import gs.easing.Linear;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	
	import view.GameChrome;
	
	public class GameController extends Sprite
	{
		/** Diameter of the controller */
		protected const size:Number = 30;
		
		/** The game space */
		protected var playField:Rectangle;
		
		/** The external listener function */
		protected var listenerFunction:Function;
		
		/** Tween for animating cursor */
		protected var scaleTween:TweenMax;
		
		/** Holds state between mouse and keyboard control */
		protected var isMouseMode:Boolean;
		
		/**
		 * Constructor
		 * 
		 * @param playField		   A reference to the playField rect, passed from the main Game class
		 * @param listenerFunction Function to receive bomb event
		 */
		public function GameController(playField:Rectangle, listenerFunction:Function)
		{
			this.playField = playField;
			this.listenerFunction = listenerFunction;
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(size, size, 0, -size/2, -size/2);
			
			graphics.beginGradientFill(	GradientType.RADIAL, 
										[ColorLib.BOMB, ColorLib.CONTROLLER_MID, ColorLib.BLACK], 
										[.5, .3, 0], [0, 0x99, 0xFF], matrix);
			graphics.drawCircle(0, 0, size/2);
			graphics.endFill();
			
			beginPulse();
			
			this.startDrag(true, playField);
			
			mask = GameChrome.getGameMask();
		}
		
		/**
		 * Tear down this Object
		 */
		public function destroy():void
		{
			disable();
			parent.removeChild(this);
			delete this;
		}
		
		/**
		 * Enable the controller
		 */
		public function enable():void
		{
			addEventListener(MouseEvent.MOUSE_UP, listenerFunction);
			addEventListener(MouseEvent.MOUSE_OUT, showMouse);
			addEventListener(MouseEvent.MOUSE_OVER, hideMouse);
		}
		
		/**
		 * Disable the controller
		 */
		public function disable():void
		{
			removeEventListener(MouseEvent.MOUSE_UP, listenerFunction);
			removeEventListener(MouseEvent.MOUSE_OUT, showMouse);
			removeEventListener(MouseEvent.MOUSE_OVER, hideMouse);
			Mouse.show();
		}
		
		/**
		 * Begin tween to animate the cursor
		 */
		protected function beginPulse():void
		{
			/* Values defining the tween are hard-coded here, as they're probably too trivial for config */
			scaleTween = new TweenMax(this, 1, {scaleX: .5, scaleY: .5, yoyo: 0});
		}
		
		/**
		 * Hide mouse when user playing
		 * 
		 * @e Mouse event
		 */
		 private function hideMouse(e:MouseEvent):void
		 {
		 	Mouse.hide();
		 }
		
		/**
		 * Show mouse when user outside game
		 * 
		 * @e Mouse event
		 */
		 private function showMouse(e:MouseEvent):void
		 {
		 	Mouse.show();
		 }
	}
}