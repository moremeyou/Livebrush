package com.livebrush.events
{

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import com.livebrush.graphics.canvas.Layer;
	
	public class CanvasEvent extends Event
	{
		
		public static const LAYER_CHANGE			:String = "layerChange";
		public static const LAYER_SELECT			:String = "layerSelect";
		public static const LAYER_MOVE				:String = "layerMove";
		public static const LAYER_ADD				:String = "layerAdd";
		public static const LAYER_DELETE			:String = "layerDelete";
		public static const MOUSE_EVENT				:String = "mouseEvent";
		public static const KEY_EVENT				:String = "keyboardEvent";
		public static const	INIT					:String = "init";
		public static const	SELECTION_EVENT			:String = "selectionBox";
		
		public var layer							:Layer = null;
		public var triggerEvent   					:Event = null;
		public var data								:Object = null;
	
		public function CanvasEvent (type:String, bubbles:Boolean=false, cancelable:Boolean=false, triggerEvent:Event=null, layer:Layer=null, data:Object=null):void
		{
			super(type, bubbles, cancelable);
			this.layer = layer;
			this.triggerEvent = triggerEvent;
			this.data = data;
		}
		
		public override function clone():Event
		{
			return new CanvasEvent(type, bubbles, cancelable, triggerEvent, layer, data);
		}
		
		public override function toString():String
		{
			return formatToString("CanvasEvent", "type", "bubbles", "cancelable", "eventPhase", "triggerEvent", "layer", data);
		}
		
	}
	
	
}