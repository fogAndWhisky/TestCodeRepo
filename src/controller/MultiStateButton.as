/**
 * Simple multi-state button
 */

package controller
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class MultiStateButton extends Sprite
	{
		/** List of all the buttons in this multi-state */
		protected var buttons:Array;
		/** Current pointer to the butons array */
		protected var _index:uint;
		/** Pointer to the buttons array array when last event was issued */
		protected var _lastEventIndex:uint;
		/** Length of the buttons array */
		protected var length:uint;
		/** Flag to indicate internal buttons are active */
		protected var _enabled:Boolean;
		
		/**
		 * Constructor
		 * 
		 * @param buttons A list of DisplayObjects to rotate through
		 */
		public function MultiStateButton(buttons:Array)
		{
			super();
			this.buttons = buttons;
			_index = 0;
			length = buttons.length;
			
			for (var a:uint = 0; a < length; a++)
			{
				var btn:DisplayObject = buttons[a] as DisplayObject;
				btn.addEventListener(MouseEvent.CLICK, onBtnClick);
				addChild(btn);
			}
			_enabled = true;
			setState();
		}
		
		/**
		 * Get the current index (read-only)
		 * 
		 * @return The current _index
		 */
		public function get index():uint
		{
			return _index;
		}
		
		/**
		 * Get the current index (read-only)
		 * 
		 * @return The current _index
		 */
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		/**
		 * Get the current index (read-only)
		 * 
		 * @return The current _index
		 */
		public function set enabled(state:Boolean):void
		{
			if (_enabled != state)
			{
			
				_enabled = state;
				var item:DisplayObject;
				var btn:SimpleButton;
				var a:uint;
			
				for (a = 0; a < length; a++)
				{
					item = buttons[a] as DisplayObject;
					
					if (_enabled)
						item.addEventListener(MouseEvent.CLICK, onBtnClick);
					else
						item.removeEventListener(MouseEvent.CLICK, onBtnClick);
						
					if (item is SimpleButton)
					{
						btn = item as SimpleButton;
						btn.enabled = btn.mouseEnabled = _enabled;
					}
				}
			}
		}
		
		/**
		 * Get the index (read-only) as it was when the last event was issued.
		 * 
		 * @return The current _index
		 */
		public function get lastEventIndex():uint
		{
			return _lastEventIndex;
		}
		
		/**
		 * Auto-advance the state
		 */
		protected function advance():void
		{
			_index = (_index + 1 == length) ? 0 : _index + 1;
			setState();
		}
		
		/**
		 * Set to the current buttonstate
		 */
		protected function setState():void
		{
			for (var a:uint = 0; a < length; a++)
			{
				var btn:DisplayObject = buttons[a] as DisplayObject;
				btn.visible = a == _index;
			}
		}
		
		/**
		 * Intercept the button events to advance to next button.
		 * 
		 * Note that the MouseEvent bubbles up, so no need to dispatch an explicit event.
		 * 
		 * @param e The MouseEvent.CLICK event
		 */
		protected function onBtnClick(e:MouseEvent):void
		{
			_lastEventIndex = _index;
			advance();
		}
	}
}