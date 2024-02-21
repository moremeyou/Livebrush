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
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	
	import com.livebrush.events.CanvasEvent;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.Line;
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
	import com.livebrush.data.GlobalSettings;
	import com.livebrush.data.StateManager;
	import com.livebrush.graphics.canvas.BitmapLayer;
	
	import com.wacom.Tablet;
	
	public class BrushTool extends Tool
	{
		public static const NAME						:String = "brushTool";
		public static const KEY							:String = "B";
		
		public static const LIVEBRUSH					:String = "livebrush";
		public static const AUTOBRUSH					:String = "autobrush";
		
		private var initTimeout							:Timer
		private var brushGroup							:BrushGroup;
		private var activeBrushGroup					:BrushGroup;
		private var brushCompleteDelay					:Timer;
		//private var bitmapLayer							:BitmapLayer = null;
		public var strokeBuffer							:int = 0;
		
		
		public function BrushTool (toolMan:ToolManager):void
		{
			super(toolMan);
			
			init();
		}
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			name = NAME;
			
			//engine = new Engine ();
			activeBrushGroup = new BrushGroup ();
			brushGroup = new BrushGroup ();
			
			brushCompleteDelay = new Timer (GlobalSettings.CACHE_DELAY, 1);
			brushCompleteDelay.addEventListener(TimerEvent.TIMER, brushComplete);
			
			//engine.addEventListener(DrawEvent.BRUSH_GROUP_COMPLETE, drawEventHandler);
			//engine.addEventListener(DrawEvent.BRUSH_GROUP_START, drawEventHandler);
		}
		
		
		// TOOL ACTIONS /////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function addBrushGroup (brushGroup:BrushGroup):void
		{
			activeBrushGroup.merge(brushGroup);
		}
		
		public function stopAllBrushes ():void
		{
			_stopBrushes(activeBrushGroup.brushes);
		}
		
		public function stopLastBrush ():void
		{
			try { _stopBrushes([activeBrushGroup.lastBrush]); } catch (e:Error) {}
		}
		
		private function _stopBrushes (brushList:Array, now:Boolean=false):void
		{
			for (var i:int=0; i<brushList.length; i++)
			{
				if (!now) 
				{
					brushList[i].queueFinish();
				}
				else 
				{
					//brushList[i].state = LiveBrush.FINISHED;
					activeBrushGroup.removeBrush(brushList[i].id);
				}
			}
		}
		
		public function stopNow ():void
		{
			_stopBrushes(activeBrushGroup.brushes, true);
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function brushComplete (e:TimerEvent=null):void
		{
			finish(true, false);
			UI.MAIN_UI.toggle(true);
			strokeBuffer = 0;
			//UI.setStatus("Busy");
		}
		
		protected override function enterFrameHandler (e:Event):void
		{
			var brush:LiveBrush;
			var moving:Boolean;
			
			try
			{
				for (var i:int=0;i<activeBrushGroup.brushes.length;i++)
				{
					brush = activeBrushGroup.brushes[i];
					
					if (brush.state == LiveBrush.DRAWING || brush.state == LiveBrush.FINISHING)
					{
						//begin();
						UI.MAIN_UI.toggle(false, false, false);
						
						// Don't do this. Way to many variables to check ... just think of the brush group issues.
						/*if (brush.lineStyle.maxStrokes != 0 && brush.lineStyle.maxStrokes == brush.line.length)
						{
							brush.layer = LineLayer(canvasManager.addLayer(Layer.newLineLayer(canvas, brush.layer.depth+1)));
							brush.setNewLine();
						}*/
						
						try { moving = brush.move(); } catch (e:Error) {  }
						// // // Consol.Trace("BrushTool: moving = brush.move(); > " + e);
						
						//// // Consol.Trace("BrushTool: moving = brush.move()");
						
						if (moving) 
						{
							try 
							{ 
								brush.line.drawNew(brush.layer); 
							} 
							catch (e:Error) 
							{ 
								// // Consol.Trace("BrushTool: brush.line.drawNew(brush.layer) > " + e); 
							}
						
							try 
							{ 
								if (GlobalSettings.CACHE_REALTIME) {
									
									if (GlobalSettings.DRAW_MODE == 0) {
										
										brush.layer.cacheVectors();
									
									} else if (GlobalSettings.DRAW_MODE == 1) {
										
										if (strokeBuffer > GlobalSettings.STROKE_BUFFER) {
											brush.layer.cacheVectors();
											strokeBuffer = 0;
										} else {
											strokeBuffer++;
										}
										
									}
								}
								
								//if (GlobalSettings.CACHE_REALTIME) brush.layer.cacheVectors(); 
							} 
							catch (e:Error) 
							{ 
								// // Consol.Trace("BrushTool: brush.layer.cacheVectors() > " + e);
							}
						
							try 
							{
								if (GlobalSettings.CACHE_DECOS) brush.layer.cacheDecos(); 
							} 
							catch (e:Error) 
							{ 
								// // Consol.Trace("BrushTool: brush.layer.cacheDecos(); > " + e); 
							}
						}
						
						try 
						{ 
							brushCompleteDelay.reset(); 
						}
						catch (e:Error) 
						{ 
							// // Consol.Trace("BrushTool: brushCompleteDelay.reset(); > " + e);
						}
					}
					else if (brush.state == LiveBrush.FINISHED)
					{
						//// // Consol.Trace("BrushTool: brush.state==FINISHED");
						
						/*var line:Line = brush.line.copy();
						var d:int = brush.layer.depth;
						StateManager.addItem(function():void{      },
											 function():void{   LineLayer(activeLayer).line=line; LineLayer(activeLayer).setup(); activeLayer.depth=d;   },
											 brush.stateIndex);*/
											 
						// We don't want to create undo's for each addEdge method on line. Because we want this be as fast as possible;
						// That's why we group it all here. Group it all at the end here.
						
						brush.layer.cacheVectors();
						
						
						if (GlobalSettings.DRAW_MODE == 0) {
						
							StateManager.addItem(function(state:Object):void{      }, // this works because every vector lines is created on a new layer
												 function(state:Object):void{   var l:LineLayer = LineLayer(state.canvasManager.getLayer(state.data.brushDepth)); l.line = Line.xmlToLine(state.data.lineXML); l.setup(); l.depth=state.data.brushDepth;   }, 
												 brush.stateIndex, {lineXML:brush.line.getXML(), brushDepth:brush.layer.depth});
						
						} 
						else if (GlobalSettings.DRAW_MODE == 1) {
						
							brush.layer.cacheDecos();
							StateManager.addItem(function(state:Object):void{   canvasManager.setObjectsXML(state.data.beginObjectsXML);   },
												 function(state:Object):void{   canvasManager.setObjectsXML(state.data.finishObjectsXML);   },
												 brush.stateIndex, {beginObjectsXML:canvasManager._selectedObjects.slice(), finishObjectsXML:canvasManager.storeSelectedObjects().slice()},
												 -1, "Tool: finish");
						}
						// 
						
						//brush.layer.cacheVectors();
						
						activeBrushGroup.removeBrush(brush.id);
						
						if (activeBrushGroup.brushes.length == 0)
						{
							setBrushCompleteDelay();
						}
					}
				}
			}
			catch (e:Error)
			{
				//// // Consol.Trace("BrushTool: Critical draw error. Do we need to handle this elsewhere?")
				// Consol.Trace("BrushTool: Critical Error: " + e);
				UI.MAIN_UI.alert({message:"Brush Tool Error\nPlease save your project and restart Livebrush.", id:"criticalAlert"});
				stopNow();
				brushComplete();
			}
			
		}
		
		protected override function canvasMouseEvent (e:CanvasEvent):void // From: canvasManager
		{
			//// Consol.Trace("BrushTool: GlobalSettings.DRAW_MODE = " + GlobalSettings.DRAW_MODE);
			
			var mouseEvent:MouseEvent = e.triggerEvent as MouseEvent;
			var newBrush:LiveBrush;
			
			brushGroup.brushes = [];
			
			if (mouseEvent.type == MouseEvent.MOUSE_DOWN && activeBrushGroup.brushes.length < 11)
			{
				UI.setStatus("Drawing");
				
				begin();
				//UI.MAIN_UI.toggle(false, false, false);
				
				if (!GlobalSettings.SHOW_MOUSE_WHILE_DRAWING) Mouse.hide();
				
				// always enable pressure
				if (GlobalSettings.WACOM_DOCK) {
					Tablet.startPressure();
				}
				
				if (styleManager.styleGroup.length == 1) 
				{
						//StateManager.openState();
						
						if (GlobalSettings.DRAW_MODE == 0) {
							
							newBrush = brushGroup.addBrush(LIVEBRUSH, styleManager.activeStyle, canvasManager.addLayer(Layer.newLineLayer(canvas)) as LineLayer);
						
						} else if (GlobalSettings.DRAW_MODE == 1) {
							
							//if (bitmapLayer == null) bitmapLayer = canvasManager.addLayer(Layer.newBitmapLayer(canvas)) as BitmapLayer
							newBrush = brushGroup.addBrush(LIVEBRUSH, styleManager.activeStyle, canvasManager.activeBitmapLayer);
						
						}
						
						// should only be adding a state when we create the bitmap layer the first time
						// otherwise like normal
						// so this code below may have to go into the first condition
						
						newBrush.stateIndex = StateManager.currentIndex;
						StateManager.closeState(true);
				}
				else
				{
					var group:Array = styleManager.styleGroup.slice(0,5).reverse();
					//for (var b:int=0; b<styleManager.styleGroup.length; b++)
					for (var b:int=0; b<group.length; b++)
					{
						//StateManager.openState();
						
						if (GlobalSettings.DRAW_MODE == 0) {
							
							newBrush = brushGroup.addBrush(LIVEBRUSH, group[b], canvasManager.addLayer(Layer.newLineLayer(canvas)) as LineLayer);
						
						} else if (GlobalSettings.DRAW_MODE == 1) {
							
							//if (bitmapLayer == null) bitmapLayer = canvasManager.addLayer(Layer.newBitmapLayer(canvas)) as BitmapLayer
							newBrush = brushGroup.addBrush(LIVEBRUSH, group[b], canvasManager.activeBitmapLayer);
						
						}
						
						newBrush.stateIndex = StateManager.currentIndex;
						StateManager.closeState(true);
					}
				}
				
				addBrushGroup(brushGroup);
			}
		}
		
		//protected override function canvasMouseUp (e:MouseEvent):void
		protected override function stageMouseUp (e:MouseEvent):void
		{ 
			if (state == RUN_STATE)
			{
				Mouse.show();
				
				for (var i:int=0; i<activeBrushGroup.brushes.length; i++)
				{
					//var brush:LiveBrush = engine.activeBrushGroup.brushes[i];
					var brush:LiveBrush = activeBrushGroup.brushes[i];
					if (brush.lineStyle.mouseUpComplete || !brush.isDynamic)
					{
						//if (brush.line.created)
						//{
							brush.queueFinish();
						/*}
						else
						{
							//StateManager.openState();
							StateManager.clearState();
							StateManager.lock();
							canvasManager.remLayer(brush.layer.depth);
							StateManager.unlock(this);
							activeBrushGroup.removeBrush(brush.id);
							
						}*/
					}
				}
			}
			
			if (GlobalSettings.WACOM_DOCK) {
				Tablet.stopPressure();
			}
		}
		
		protected override function canvasKeyEvent (e:CanvasEvent):void 
		{
			//// Consol.Trace(e.triggerEvent["keyCode"] == Keyboard.SPACE);
			
			if (state == Tool.RUN_STATE && !(e.triggerEvent["keyCode"] == Keyboard.SPACE)) {
				//// Consol.Trace(String.fromCharCode(e.triggerEvent["charCode"]));
				var key:String = String.fromCharCode(e.triggerEvent["charCode"]);
				
				for (var i:int=0; i<activeBrushGroup.brushes.length; i++)
				{
					activeBrushGroup.brushes[i].addDeco(int(key));
				}
			}
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function setBrushCompleteDelay ():void
		{
			//// // Consol.Trace("BrushTool: setBrushCompleteDelay");
			
			brushCompleteDelay.delay = GlobalSettings.CACHE_DELAY;
			brushCompleteDelay.reset();
			brushCompleteDelay.start();
		}
		
		
		// LEGACY ///////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

		
	}
}
	
