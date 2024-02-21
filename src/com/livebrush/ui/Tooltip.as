package com.livebrush.ui
{
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.EventPhase;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	
	import com.livebrush.ui.UI;
	import com.livebrush.ui.TooltipAsset;
	import com.livebrush.ui.Consol;
	
	
	public class Tooltip {
		
		
		private static var SINGLETON					:Tooltip;
		private static var OBJECTS						:Array = [];
		private static var CURRENT_TIP					:Object = null;
		private static var TOOLTIP_ASSET				:TooltipAsset;
		private static var TIMEOUT						:int = 0;
		
		public function Tooltip ():void {
			
			init();
		
		}
		
		public static function getInstance ():Tooltip
		{
			var instance:Tooltip;
			
			if (SINGLETON == null) 
			{
				SINGLETON = new Tooltip();
				instance = SINGLETON;
			}
			else 
			{
				instance = SINGLETON;
			}
			
			return instance;
		}
		
		private function init ():void {
			
			TOOLTIP_ASSET = new TooltipAsset();
			TOOLTIP_ASSET._label.autoSize = TextFieldAutoSize.LEFT;
			
		}
		
		public static function addTip (obj:DisplayObject, label:String, left:Boolean=true, top:Boolean=true):void {
			
			OBJECTS.push({obj:obj, label:label, left:left, top:top});
			
			obj.addEventListener(MouseEvent.MOUSE_OVER, SINGLETON._mouseListener);
			obj.addEventListener(MouseEvent.MOUSE_OUT, SINGLETON._mouseListener);

		}
		
		private function _mouseListener (e:MouseEvent):void {
		
			var obj:Object;
			
			//// Consol.Trace("Tooltip mouseListener: " + e);
			
			if (e.eventPhase == EventPhase.AT_TARGET) {
				
				obj = _getObj(e.target);
				
				if (e.type == MouseEvent.MOUSE_OVER) {
					
					clearTimeout(TIMEOUT);
					TIMEOUT = setTimeout(_showTooltip, 750, obj);
					
				} else if (e.type == MouseEvent.MOUSE_OUT) {
					
					_hideTooltip();
					
				}
				
			} //else {
			
				if (e.type == MouseEvent.MOUSE_MOVE) {
					
					TOOLTIP_ASSET.x = UI.TOOLTIP_HOLDER.mouseX - (TOOLTIP_ASSET.width+10);
					TOOLTIP_ASSET.y = UI.TOOLTIP_HOLDER.mouseY;
					
					// offsets for left and top postitioning
					// use CURRENT_TIP
					
				}
			//}
			
		}
		
		private function _showTooltip (o:Object):void {
		
			//// Consol.Trace("Show Tooltip: " + o.label);
			
			if (CURRENT_TIP != null) _hideTooltip();
			
			CURRENT_TIP = o;
			
			TOOLTIP_ASSET._label.autoSize = TextFieldAutoSize.LEFT;
			TOOLTIP_ASSET._label.text = o.label;
			TOOLTIP_ASSET._bg.width = TOOLTIP_ASSET._label.textWidth+17;
			
			CURRENT_TIP.obj.addEventListener(MouseEvent.MOUSE_MOVE, _mouseListener);
			
			TOOLTIP_ASSET.x = UI.TOOLTIP_HOLDER.mouseX - (TOOLTIP_ASSET.width+10);
			TOOLTIP_ASSET.y = UI.TOOLTIP_HOLDER.mouseY;;
			
			UI.TOOLTIP_HOLDER.addChild(TOOLTIP_ASSET);
		
		}
		
		private function _hideTooltip ():void {
		
			//// Consol.Trace("Hide Tooltip");
			
			clearTimeout(TIMEOUT);
			
			try {
				
				CURRENT_TIP.obj.removeEventListener(MouseEvent.MOUSE_MOVE, _mouseListener);
				UI.TOOLTIP_HOLDER.removeChild(TOOLTIP_ASSET); 
				
			} catch (e:Error) {}
			
			CURRENT_TIP = null;
			
		}
		
		private function _getObj (obj:Object):Object {
		
			var dataObj:Object;
			
			for (var i:int=0;i<OBJECTS.length;i++) {
				
				if (obj == OBJECTS[i].obj) dataObj = OBJECTS[i];
			
			}
			
			return dataObj;
		
		}
		
	}

	
}