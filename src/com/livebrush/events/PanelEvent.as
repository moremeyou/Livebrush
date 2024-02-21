package com.livebrush.events
{

	import flash.events.Event;
	
	
	public class PanelEvent extends Event
	{
		
		public static const CLOSE				:String = "close";
		public static const HELP				:String = "help";
		public static const DRAG				:String = "drag";
		public static const COLLAPSE			:String = "collapse";
		
		public function SettingsEvent (type:String, bubbles:Boolean=false, cancelable:Boolean=false):void
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			return new SettingsEvent(type,bubbles,cancelable);
		}
		
		public override function toString():String
		{
			return formatToString("SettingsEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
	
}