package com.livebrush.events
{

	import flash.events.Event;
	import com.livebrush.data.Settings;
	
	
	public class ConsolEvent extends Event
	{
		
		public static const OUTPUT					:String = "output";
		
		public var output							:String;
		public var options							:Object;
		
		public function ConsolEvent (type:String, bubbles:Boolean=false, cancelable:Boolean=false, output:String="", options:Object=undefined):void
		{
			super(type, bubbles, cancelable);
			
			this.output = output;
			this.options = options;
		}
		
		public override function clone():Event
		{
			return new ConsolEvent(type,bubbles,cancelable,output,Settings.copyObject(options));
		}
		
		public override function toString():String
		{
			return formatToString("SettingsEvent", "type", "bubbles", "cancelable", "eventPhase", "output", "options");
		}
		
	}
	
	
}