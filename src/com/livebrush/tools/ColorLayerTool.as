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
	import com.livebrush.graphics.canvas.ColorLayer;
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
	import com.livebrush.data.StateManager;
	
	
	public class ColorLayerTool extends Tool
	{
		public static const NAME							:String = "colorLayerTool";
		public static const KEY								:String = "G";
		
		public function ColorLayerTool (toolMan:ToolManager):void
		{
			super(toolMan);
			
			init();
		}
		
		private function init ():void
		{
			name = NAME;
		}
	
		protected override function canvasMouseEvent (e:CanvasEvent):void
		{
			var mouseEvent:MouseEvent = e.triggerEvent as MouseEvent;
			
			var settings:Settings = ui.bucketPropsView.settings;
			
			if (mouseEvent.type == MouseEvent.MOUSE_DOWN)
			{
				//canvasManager.addLayer(Layer.newColorLayer(canvas, ui.toolbar.color.hexValue.toString()));
				var layer:ColorLayer = new ColorLayer(canvas, canvasManager.activeLayerDepth+1);
				//layer.color = uint("0xFF"+settings.color);
				layer.color = uint(settings.color);
				layer.alpha = settings.alpha;
				layer.label = settings.color;
				layer.changed = true;
				layer.loaded = true;
				//layer.setInitProps();
				layer.initProps.color = layer.color;
				layer.initProps.alpha = layer.alpha;
				layer.setup();
				
				canvasManager.addLayer(layer);
				
				
				
				
				
				var d:int = layer.depth;
				/*var initProps:Object = layer.initProps;
				StateManager.addItem(function():void{      },
									 function():void{   activeLayer.initProps=initProps; activeLayer.setup(); activeLayer.depth=d;   });*/
				
				StateManager.addItem(function(state:Object):void{      },
									 function(state:Object):void{   var l:ColorLayer = state.data.layer; l.setXML(state.data.layerXML.toXMLString()); l.setup();   }, 
									 -1, {layerXML:layer.getXML()}, d);
				
				finish(false);
				//StateManager.closeState();
				
				
			}
		}
		
	}

}
	
