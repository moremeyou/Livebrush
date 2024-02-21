package com.livebrush.events
{

	import flash.events.Event;
	//import com.livebrush.graphics.canvas.Layer;
	
	public class ListEvent extends Event
	{
		
		public static const	ADD							:String = "add";
		public static const	REMOVE						:String = "remove";
		public static const	MOVE						:String = "move";
		public static const	CHANGE						:String = "listItemChange";
		public static const	SELECT						:String = "listItemSelect";
		public static const	LABEL_CHANGE				:String = "labelChange";
		
		
		public var data									:Object = null;
		// data object might hold additional information such as how to update the canvas
		// or specific layers to update
	
		public function ListEvent (type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object=null):void
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		public override function clone():Event
		{
			return new ListEvent(type,bubbles,cancelable,data);
		}
		
		public override function toString():String
		{
			return formatToString("ListEvent", "type", "bubbles", "cancelable", "eventPhase", "data");
		}
		
	}
	
	
}