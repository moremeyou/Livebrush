package com.livebrush.events
{

	import flash.events.Event;
	
	public class UpdateEvent extends Event
	{
		public static const SELECTION				:String = "selection";
		public static const GROUP					:String = "groupUpdate";
		public static const BEGIN					:String = "begin";
		public static const FINISH					:String = "finish";
		// public static const MULTI_LAYER				:String = "multiLayerUpdate";
		public static const LINE					:String = "lineUpdate";
		public static const LAYER					:String = "layerUpdate";
		public static const CANVAS					:String = "canvasUpdate";
		public static const TOOL					:String = "toolUpdate";
		public static const UI						:String = "uiUpdate";
		public static const WINDOW					:String = "windowUpdate";
		public static const DATA					:String = "dataUpdate";
		public static const TRANSFORM				:String = "transformUpdate";
		public static const COLOR					:String = "colorUpdate";
		public static const BRUSH_STYLE				:String = "brushStyleUpdate";
		public static const PROJECT					:String = "projectUpdate";
		public static const LOADING					:String = "loadingUpdate";
		public static const DRAW_MODE				:String = "drawModeUpdate";
		
		
		public var data  		 					:Object = null;
		public var delay							:Boolean = true;	
	
		public function UpdateEvent (type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object=null, delay:Boolean=true):void
		{
			super(type, bubbles, cancelable);
			
			this.data = data;
			this.delay = delay;
		}
		
		public override function clone():Event
		{
			return new UpdateEvent(type, bubbles, cancelable, data, delay);
		}
		
		public override function toString():String
		{
			return formatToString("UpdateEvent", "type", "bubbles", "cancelable", "eventPhase", "data", "delay");
		}
		
	}
	
	
}