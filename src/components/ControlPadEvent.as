package components  
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class ControlPadEvent extends Event 
	{
		static public const PAD_MOVE:String = "padMove";
		
		public var dx:Number;
		public var dy:Number;
		
		public function ControlPadEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, dx:Number = 0, dy:Number = 0) 
		{
			super(type, bubbles, cancelable);
			this.dx = dx;
			this.dy = dy;
		}
		
		override public function clone():Event
		{
			return new ControlPadEvent(type, bubbles, cancelable, dx, dy);
		}
		
		override public function toString():String
		{
			return formatToString("ControlPadEvent", "type", "bubbles", "cancelable", "eventPhase", "dx", "dy");
		}
	}

}