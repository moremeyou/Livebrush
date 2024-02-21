package com.livebrush.events
{

	import flash.events.Event;
	
	
	public class ToolbarEvent extends Event
	{
		
		public static const TOOL_SELECT				:String = "toolSelect";
		public static const COLOR_CHANGE			:String = "colorChange";
		
		public function ToolbarEvent (type:String, bubbles:Boolean=false, cancelable:Boolean=false):void
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			return new ToolbarEvent(type,bubbles,cancelable);
		}
		
		public override function toString():String
		{
			return formatToString("SettingsEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
	
}