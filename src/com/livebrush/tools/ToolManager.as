package com.livebrush.tools
{
	import flash.events.EventDispatcher;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.events.EventPhase;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	//import flash.ui.Multitouch;
    //import flash.ui.MultitouchInputMode;
	//import flash.events.TouchEvent;
	
	import com.livebrush.events.ToolbarEvent;
	import com.livebrush.events.HelpEvent;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.Window;
	import com.livebrush.events.*
	import com.livebrush.data.Settings;
	import com.livebrush.ui.Consol;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.graphics.canvas.BackgroundLayer;
	import com.livebrush.styles.StyleManager;
	import com.livebrush.tools.Tool;
	import com.livebrush.tools.BrushTool;
	import com.livebrush.tools.ColorLayerTool;
	import com.livebrush.tools.SampleTool;
	import com.livebrush.tools.TransformTool;
	import com.livebrush.tools.HelpTool;
	import com.livebrush.tools.PenTool;
	import com.livebrush.events.StateEvent;
	import com.livebrush.utils.Update;
	

	public class ToolManager extends EventDispatcher 
	{
		//public static var TOUCH_SUPPORT							:Boolean = false;
		
		public var updateDelay									:int = 1000;
		private var timeout										:int;
		private var updateEvent									:UpdateEvent;
		private var tools										:Array = [];
		public var brushTool									:BrushTool;
		public var colorLayerTool								:ColorLayerTool;
		public var sampleTool									:SampleTool;
		public var transformTool								:TransformTool;
		public var helpTool										:HelpTool;
		public var handTool										:HandTool;
		public var penTool										:PenTool;
		public var ui											:UI;
		public var canvasManager								:CanvasManager;
		public var styleManager									:StyleManager;
		public var activeTool									:Tool;
		public var lastTool										:Tool;
		private var _toolKeyChars								:String = "";
		public var quickTool									:Tool = null;
		
		public function ToolManager (ui:UI, canvasManager:CanvasManager, styleManager:StyleManager):void
		{
			this.ui = ui;
			this.canvasManager = canvasManager;
			this.styleManager = styleManager;

			init();
		}

		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get canvas ():Canvas {   return canvasManager.canvas;   }
		
		
		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			initTools();
			
			canvasManager.addEventListener(CanvasEvent.LAYER_SELECT, layerSelectHandler);
			//canvasManager.addEventListener(CanvasEvent.LAYER_ADD, layerDeleteHandler);
			canvasManager.addEventListener(CanvasEvent.LAYER_DELETE, layerDeleteHandler);
			//toolbar.addEventListener (ToolbarEvent.TOOL_SELECT, toolSelectHandler);
			canvasManager.addEventListener(CanvasEvent.MOUSE_EVENT, canvasMouseEvent);
			canvasManager.addEventListener(CanvasEvent.KEY_EVENT, canvasKeyEvent);
			//canvasManager.addEventListener(CanvasEvent.SELECTION_EVENT, setSelection); // only do this if we centralize all events through can man
		
			
		}
		
		
		private function initTools ():void
		{
			brushTool = registerTool(new BrushTool(this)) as BrushTool;
			colorLayerTool = registerTool(new ColorLayerTool(this)) as ColorLayerTool;
			//imageLayerTool = registerTool(new ImageLayerTool(this)) as ImageLayerTool;
			sampleTool = registerTool(new SampleTool(this)) as SampleTool;
			//brushGroupTool = registerTool(new BrushGroupTool(this)) as BrushGroupTool;
			transformTool = registerTool(new TransformTool(this)) as TransformTool;
			helpTool = registerTool(new HelpTool(this)) as HelpTool;
			penTool = registerTool(new PenTool(this)) as PenTool;
			handTool = registerTool(new HandTool(this)) as HandTool;
			
			activeTool = new Tool(this);
			lastTool = new Tool(this);
			
			_toolKeyChars = "BTPGE";
			
			setTool(brushTool);
			//setTool(basicTool);
			//setTool(transformTool);
			//setTool(penTool);
			
			//quickTool = transformTool;
			
			//ui.selectTool(activeTool.name);
		}

		
		// TOOL MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function registerTool (newTool:Tool):Tool
		{
			newTool.addEventListener(UpdateEvent.LAYER, updateHandler); 
			newTool.addEventListener(UpdateEvent.SELECTION, updateHandler); 
			newTool.addEventListener(UpdateEvent.BEGIN, updateHandler); 
			newTool.addEventListener(UpdateEvent.FINISH, updateHandler); 
			
			tools.push(newTool);
			//_toolKeyChars += newTool.KEY;
			
			return newTool;
		}
		
		public function setTool (tool:Tool):void
		{
			if (activeTool.state == Tool.RUN_STATE) activeTool.finish(false);
			
			//try{ui.toolbarView.toggleTool(tool.name);}catch(e:Error){}
			// ui.toolbarView.toggleTool(tool.name)
			//// // Consol.Trace(tool.name);
			//ui.toolbarView.toggleToolName(tool.name);
			
			resetUpdateTimeout(null, false);
			
			if (activeTool.isActive) activeTool.reset();
			
			lastTool = activeTool;
			activeTool = tool
			activeTool.setup();
			
			ui.selectTool(activeTool.name);
			
			if (lastTool == transformTool || lastTool == penTool) {
				//canvasManager.updateViews, 100, GraphicUpdate.canvasUpdate()
				canvasManager.refreshLayers();
			}
		}
		
		public function resetTool ():void
		{
			activeTool.reset();
			activeTool.setup();
		}
		
		public function setToolByName (toolName:String):void
		{
			setTool(getToolByName(toolName));
		}
		
		public function setQuickToolByName (toolName:String="transformTool")
		{
			setQuickTool(getToolByName(toolName));
		}
		
		public function setQuickTool (tool:Tool=null):void
		{
			quickTool = (tool==null ? transformTool : tool);
			
			
			
			if (quickTool != activeTool) //  && quickTool != null
			{
				quickTool.setup();
			}
			
			quickTool.begin(); // we always need to force a start event - to store the beginning state
				
			/*if (tool != transformTool) // quickTool.isActive &&  
				{
					quickTool.finish(false);
					quickTool.reset();
				}
				else
				{
					//tool.begin();
				}
				
				quickTool = tool;
				
				quickTool.begin();
			}*/
		}
		
		public function finishQuickTool ():void
		{
			quickTool.finish(false); // we always need to force a finish event - to store the state
			
			if (quickTool != activeTool)
			{
				quickTool.reset();
				activeTool.reset();
				activeTool.setup();
				quickTool = null;
			}
			/*{
				quickTool.reset();
				//quickTool.finish(false);
				//stateChange(); // set the states up for modifications, then we can remove this
			}*/
			/*else if (activeTool == penTool)
			{
				quickTool.reset();
				quickTool.setup();
			}*/
		}
		
		
		// DISPATCH /////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function dispatchUpdate (e:UpdateEvent):void
		{
			
			if (activeTool is TransformTool) ui.pushTransformProps(transformTool.settings);
						//// // Consol.Trace(e);
			if (e.type == UpdateEvent.FINISH) activeTool.state = Tool.ACTIVE_STATE;
			updateEvent = null
			dispatchEvent(new UpdateEvent(e.type, false, false, e.data));
		}
		

		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function stateChange (e:StateEvent=null):void
		{
			//// // Consol.Trace("ToolManager: State Change Event");
			activeTool.reset();
			activeTool.setup();
		}
		
		private function updateHandler (e:UpdateEvent):void
		{
			if (e.delay || updateDelay == 0) 
			{
				updateEvent = e;
				resetUpdateTimeout(e, true);
			}
			else 
			{
				resetUpdateTimeout(e, false); 
				dispatchUpdate(e);
			}
		}
		
		private function layerSelectHandler (e:CanvasEvent):void
		{
			if (activeTool.state == Tool.RUN_STATE) activeTool.finish(false);
			if (activeTool.isActive) activeTool.reset();
			setTool(activeTool);
		}
		
		private function layerDeleteHandler (e:CanvasEvent):void
		{
			if (activeTool.isActive) activeTool.reset();
		}
		
		private function canvasMouseEvent (e:CanvasEvent):void
		{
			// we could pass these events to the active tool
			// but it would have to be a specific canvasMouseEvent method - not an event listener
			
			//// // Consol.Trace("canvas mouse event: " + e.target);
			//dispatchEvent(new CanvasEvent(e.type, ));
			
			// Tool object listens for events from canvas man
			// so receiving them here is just in case there are any tool man actions to happen as well
		}
		
		private function canvasKeyEvent (e:CanvasEvent):void
		{
			//// // Consol.Trace("canvas key event");
			
			var keyEvent:KeyboardEvent = KeyboardEvent(e.triggerEvent);
			var char:String = String.fromCharCode(keyEvent.charCode).toUpperCase();
			
			//// // Consol.Trace(Keyboard.SPACE == keyEvent.keyCode);
			//// // Consol.Trace(_toolKeyChars);
			
			if (activeTool != handTool && keyEvent.type == KeyboardEvent.KEY_DOWN && !canvas.locked && activeTool.state != Tool.RUN_STATE && !canvasManager.stylePreviewLayer.visible)
			{
				if (keyEvent.keyCode == Keyboard.SPACE)
				{
					canvas.lockContent();
					canvas.stage.addEventListener (MouseEvent.MOUSE_DOWN, stageMouseEvent);
					canvas.stage.addEventListener (MouseEvent.MOUSE_UP, stageMouseEvent);
				}
				else if (_toolKeyChars.indexOf(char) > -1)
				{
					//setTool(getToolByKey(char));
					//ui.selectTool(activeTool.name);
				}
				
				
			}
			else if (activeTool != handTool && keyEvent.type == KeyboardEvent.KEY_UP && canvas.locked && activeTool.state != Tool.RUN_STATE)
			{
				if (keyEvent.keyCode == Keyboard.SPACE)
				{
					canvas.unlockContent();
					canvas.stopDrag();
					canvas.stage.removeEventListener (MouseEvent.MOUSE_DOWN, stageMouseEvent);
					canvas.stage.removeEventListener (MouseEvent.MOUSE_UP, stageMouseEvent);
				}
			}
		}
		
		private function stageMouseEvent (e:MouseEvent):void
		{
			if (e.type == MouseEvent.MOUSE_DOWN)
			{
				canvas.startDrag();
			}
			else if (e.type == MouseEvent.MOUSE_UP)
			{
				canvas.stopDrag();
			}
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function resetUpdateTimeout (e:UpdateEvent, restart:Boolean=true):void
		{
			clearTimeout(timeout);
			if (restart) timeout = setTimeout(dispatchUpdate, updateDelay, e);
		}
		
		private function getToolByName (toolName:String):Tool
		{
			var tool:Tool;
			switch (toolName)
			{
				case BrushTool.NAME : tool = brushTool; break;
				case ColorLayerTool.NAME : tool = colorLayerTool; break;
				//case ImageLayerTool.NAME : tool = imageLayerTool; break;
				case SampleTool.NAME : tool = sampleTool; break;
				//case BrushGroupTool.NAME : tool = brushGroupTool; break;
				case TransformTool.NAME : tool = transformTool; break;
				case HelpTool.NAME : tool = helpTool; break;
				case PenTool.NAME : tool = penTool; break;
				case HandTool.NAME : tool = handTool; break;
			}
			return tool;
		}
		
		private function getToolByKey (char:String):Tool
		{
			var tool:Tool;
			switch (char)
			{
				case BrushTool.KEY : tool = brushTool; break;
				case ColorLayerTool.KEY : tool = colorLayerTool; break;
				case SampleTool.KEY : tool = sampleTool; break;
				case TransformTool.KEY : tool = transformTool; break;
				case HelpTool.KEY : tool = helpTool; break;
				case PenTool.KEY : tool = penTool; break;
				case HandTool.KEY : tool = handTool; break;
			}
			return tool;
		}

	}
	
}