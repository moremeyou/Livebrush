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

	
	public class HelpTool extends Tool
	{
		public static const NAME							:String = "helpTool";
		public static const KEY								:String = "h";
		
		public function HelpTool (toolMan:ToolManager):void
		{
			super(toolMan);
			
			init();
		}
		
		private function init ():void { }

	}

}
	
