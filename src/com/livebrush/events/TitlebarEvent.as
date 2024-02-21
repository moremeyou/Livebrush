package com.livebrush.events
{

	import flash.events.Event;
	
	
	public class TitlebarEvent extends Event
	{
		
		public static const OPEN_PROJECT			:String = "open";
		public static const SAVE_PROJECT			:String = "save";
		public static const SAVEAS_PROJECT			:String = "saveAs";
		//public static const IMPORT_STYLE			:String = "importStyle";
		//public static const COLOR_CHANGE			:String = "colorChange";
		
		
		
		public function TitlebarEvent (type:String, bubbles:Boolean=false, cancelable:Boolean=false):void
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