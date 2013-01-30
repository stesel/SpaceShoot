package components 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class FireEvent extends Event 
	{
		static public const FIRE_PROCESSED:String = "fireRrocessed";
		static public const ON_FIRE:String = "onFire";
		static public const OFF_FIRE:String = "offFire";
		
		public var title:String;
		
		public function FireEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, title:String = null) 
		{
			super(type, bubbles, cancelable);
			this.title = title;
		}
		
		override public function clone():Event
		{
			return new FireEvent(type, bubbles, cancelable, title);
		}
		
		override public function toString():String
		{
			return formatToString("FireEvent", "type", "bubbles", "cancelable", "title");
		}
	}

}