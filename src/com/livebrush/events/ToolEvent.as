package com.livebrush.events
{

	import flash.events.Event;
	//import com.livebrush.graphics.canvas.Layer;
	
	public class ToolEvent extends Event
	{
		
		public static const	CHANGE						:String = "change";
		
		public var data									:Object = null;
		// data object might hold additional information such as how to update the canvas
		// or specific layers to update
	
		public function ToolEvent (type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object=null):void
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		public override function clone():Event
		{
			return new ToolEvent(type,bubbles,cancelable,data);
		}
		
		public override function toString():String
		{
			return formatToString("ToolEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
	
}