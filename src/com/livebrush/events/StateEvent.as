package com.livebrush.events
{

	import flash.events.Event;
	
	
	public class StateEvent extends Event
	{
		
		public static const CHANGE				:String = "stateChange";
		
		public var undo								:Function;
		public var redo								:Function;
		
		
		public function StateEvent (type:String, bubbles:Boolean=false, cancelable:Boolean=false, undo:Function=null, redo:Function=null):void
		{
			super(type, bubbles, cancelable);
			
			this.undo = undo;
			this.redo = redo;
		}
		
		public override function clone():Event
		{
			return new StateEvent(type,bubbles,cancelable,undo,redo);
		}
		
		public override function toString():String
		{
			return formatToString("StateEvent", "type", "bubbles", "cancelable", "eventPhase", "undo", "redo");
		}
		
	}
	
	
}