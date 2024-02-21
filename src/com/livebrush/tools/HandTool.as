package com.livebrush.tools
{
	import flash.events.EventDispatcher;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import fl.controls.ColorPicker;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.EventPhase;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	
	import com.livebrush.events.CanvasEvent;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.styles.StyleManager;
	import com.livebrush.styles.Style;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.Consol;
	//import com.livebrush.ui.Toolbar;
	import com.livebrush.tools.BrushGroup;
	import com.livebrush.events.ToolbarEvent;
	import com.livebrush.events.HelpEvent;
	import com.livebrush.ui.Panel
	import com.livebrush.tools.LiveBrush;
	import com.livebrush.data.Settings;
	
	
	public class HandTool extends Tool
	{
		public static const NAME					:String = "handTool";
		public static const KEY						:String = "H";

		public function HandTool (toolMan:ToolManager):void
		{
			super(toolMan);
		
			init();
		}
		
		private function init ():void
		{
			name = NAME;
			
		}
		
		
		// TOOL ACTIONS /////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function setColor ():void
		{
			color = canvas.getMouseColor(allLayers);
			ui.pushColorProps(settings);
		}*/
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function canvasMouseEvent (e:CanvasEvent):void
		{
			var mouseEvent:MouseEvent = e.triggerEvent as MouseEvent;
			
			if (mouseEvent.type == MouseEvent.MOUSE_DOWN)
			{
				canvas.lockContent();
				canvas.startDrag();
			}
			/*else if (mouseEvent.type == MouseEvent.MOUSE_UP)
			{
				canvas.unlockContent();
				canvas.stopDrag();
			}*/

		}
		
		protected override function stageMouseUp (e:MouseEvent):void { 
		
			canvas.unlockContent();
			canvas.stopDrag();
		
		}
		
	}

}
	
