package com.livebrush.events
{

	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.livebrush.graphics.canvas.Layer;
	
	public class ControllerEvent extends Event
	{
		
		public static const CHANGE					:String = "controllerChange";
		public static const SELECT					:String = "select";
		public static const MOUSE_EVENT				:String = "mouseEvent";
		
		public var triggerEvent   					:Event = null;
		public var data								:Object = null;
	
		public function ControllerEvent (type:String, bubbles:Boolean=false, cancelable:Boolean=false, triggerEvent:Event=null, data:Object=null):void
		{
			super(type, bubbles, cancelable);
			this.triggerEvent = triggerEvent;
			this.data = data;
		
		public override function clone():Event
		{
			return new ControllerEvent(type,bubbles,cancelable, triggerEvent, data);
		}
		
		public override function toString():String
		{
			return formatToString("ControllerEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
	
}