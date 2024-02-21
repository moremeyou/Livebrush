package com.livebrush.events
{

	import flash.events.Event;
	
	
	public class LayersPanelEvent extends Event
	{
		
		public static const CHANGE					:String = "layersPanelChange";
		public static const BLENDMODE_CHANGE		:String = "blendModeChange";
		public static const ALPHA_CHANGE			:String = "opacityChange";
		public static const DEPTH_CHANGE			:String = "depthChange";
		public static const DUP_LAYER				:String = "dupLayer"; // for now, just for images. all else is manually set.
		public static const REM_LAYER				:String = "remLayer";
		public static const SELECT_LAYER			:String = "selectLayer";
		public static const ADD_LAYER				:String = "addLayer";
		
		public var action							:String = "";
		
		public function LayersPanelEvent (type:String, bubbles:Boolean=false, cancelable:Boolean=false, action:String=""):void
		{
			super(type, bubbles, cancelable);
			this.action = action;
		}
		
		public override function clone():Event
		{
			return new LayersPanelEvent(type,bubbles,cancelable);
		}
		
		public override function toString():String
		{
			return formatToString("SettingsEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
	
}