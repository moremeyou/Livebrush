package com.livebrush.tools
{
	import flash.events.EventDispatcher;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import com.livebrush.events.ToolbarEvent;
	import com.livebrush.events.HelpEvent;
	import com.livebrush.events.CanvasEvent;
	import com.livebrush.ui.Panel;
	import com.livebrush.ui.Consol;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.styles.StyleManager;
	import com.livebrush.ui.UI;
	import com.livebrush.tools.*; //ToolManager;
	import com.livebrush.utils.Update;
	import com.livebrush.utils.Model;
	import com.livebrush.graphics.GraphicUpdate;
	import com.livebrush.utils.Update;
	import com.livebrush.data.Settings;
	import com.livebrush.data.StateManager;
	
	
	public class Tool extends Model
	{
		public static const REALTIME_EDITMODE							:String = "realtimeMode";
		public static const WIREFRAME_EDITMODE							:String = "wireframeMode";
		public static const AUTO_EDITMODE								:String = "autoEditMode";
		public static const ACTIVE_STATE								:String = "activeState";
		public static const IDLE_STATE									:String = "idleState";
		public static const RUN_STATE									:String = "runState";
		
		private var updateDelay											:Timer;
		public var state												:String = IDLE_STATE;
		public var toolManager											:ToolManager;
		public var name													:String
		//public var stateIndex											:int = -1;
		
		
		public function Tool (toolManager:ToolManager):void
		{
			super();
			
			
			this.toolManager = toolManager;
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get ui ():UI {   return toolManager.ui;   }
		public function get styleManager ():StyleManager {   return toolManager.styleManager;   }
		public function get canvasManager ():CanvasManager {   return toolManager.canvasManager;   }
		public function get canvas ():Canvas {   return canvasManager.canvas;   }
		public function get activeLayer ():Layer {   return canvasManager.activeLayer;   }
		public function get activeLayers ():Array {   return canvasManager.activeLayers;   }
		public function get isActive ():Boolean {   return (state == RUN_STATE || state == ACTIVE_STATE);   }
		public function get isRunning ():Boolean {   return (state == RUN_STATE);   }
		public function get settings ():Settings {   return new Settings();   }
		public function set settings (data:Settings):void {   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void { }
		
		protected override function die ():void
		{
			super.die();
		}
		
		
		// TOOL ACTIONS /////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function setup ():void
		{
			//// // Consol.Trace("Tool: setup");
			
			state = ACTIVE_STATE;
			
			canvasManager.addEventListener(CanvasEvent.MOUSE_EVENT, canvasMouseEvent);
			canvasManager.addEventListener(CanvasEvent.SELECTION_EVENT, setSelection);
			
			canvasManager.addEventListener(CanvasEvent.KEY_EVENT, canvasKeyEvent);
			
			// Leave this for now. If things get really fucked, you need to formalize this event so it comes from canMan, thru toolMan, and called on here
			Canvas.CONTROLS.addEventListener(MouseEvent.MOUSE_DOWN, controlsMouseHandler);
			Canvas.CONTROLS.addEventListener(MouseEvent.MOUSE_UP, controlsMouseHandler);
			
			// This one is okay. Because we don't want to have it being forwarded through unnecessary class objects
			Canvas.STAGE.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			// This might also be okay - because it's global
			canvas.stage.addEventListener (MouseEvent.MOUSE_UP, stageMouseUp);
		}

		public function reset ():void
		{
			//// // Consol.Trace("Tool: reset");
			
			state = IDLE_STATE;
			
			canvasManager.removeEventListener(CanvasEvent.MOUSE_EVENT, canvasMouseEvent);
			canvasManager.removeEventListener(CanvasEvent.SELECTION_EVENT, setSelection);
			
			canvasManager.removeEventListener(CanvasEvent.KEY_EVENT, canvasKeyEvent);
			
			// See setup notes for these events
			Canvas.CONTROLS.removeEventListener(MouseEvent.MOUSE_DOWN, controlsMouseHandler);
			Canvas.CONTROLS.removeEventListener(MouseEvent.MOUSE_UP, controlsMouseHandler);
			
			// This one is okay. Because we don't want to have it being forwarded through unnecessary class objects
			Canvas.STAGE.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			canvas.stage.removeEventListener (MouseEvent.MOUSE_UP, stageMouseUp);
		}
		
		public function begin ():void
		{
			if (state != Tool.RUN_STATE)
			{
				//// // Consol.Trace("Tool: begin");
				StateManager.openState();
				//if (!StateManager.global.locked) 
				canvasManager._selectedObjects = canvasManager.storeSelectedObjects();
				
				state = Tool.RUN_STATE;
				toolUpdate(Update.beginUpdate());
			}
		}
		
		public function finish (delay:Boolean=true, saveState:Boolean=true):void
		{
			// // Consol.Trace("Tool: finish");
			
			//StateManager.openState();
			if (saveState)
			{
				StateManager.addItem(function(state:Object):void{   canvasManager.setObjectsXML(state.data.beginObjectsXML);   },
								 function(state:Object):void{   canvasManager.setObjectsXML(state.data.finishObjectsXML);   },
								 -1, {beginObjectsXML:canvasManager._selectedObjects.slice(), finishObjectsXML:canvasManager.storeSelectedObjects().slice()},
								 -1, "Tool: finish");
				StateManager.closeState();
			}
			
			//stateIndex = -1;
			
			state = Tool.ACTIVE_STATE;
			toolUpdate(Update.finishUpdate(null, delay));
		}
		
		protected function setSelection (e:CanvasEvent):void { }
		
	
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected function canvasMouseEvent (e:CanvasEvent):void // From: canvasManager
		{
			// CanvasEvent.MOUSE_EVENT - all MouseEvents except when MOUSE_DOWN is OUTSIDE the canvas (ex: the canvas matte)
			//// // Consol.Trace("canvas mouse event (from inside Tool): " + e.target);
		
			var mouseEvent:MouseEvent = e.triggerEvent as MouseEvent;
			
			if (mouseEvent.type == MouseEvent.MOUSE_DOWN)
			{
				var clickedContent:Boolean = activeLayer.hitTest(mouseEvent.stageX, mouseEvent.stageY);
				
				if (clickedContent)
				{
					contentMouseDown(mouseEvent);
				}
				else
				{
					openCanvasMouseDown(mouseEvent);
				}
			}
			else if (mouseEvent.type == MouseEvent.MOUSE_UP)
			{
				canvasMouseUp(mouseEvent);
			}
		}
		
		// This method should be automatically called when the stage gets a mouseUp event (ideally from canMan to toolMan to tool)
		// but for now, (just set it up in Tool)
		// because otherwise, we have to call it manually from the canvasMouseEvent method
		// this will confuse things if we override this method
		protected function canvasMouseUp (e:MouseEvent):void { }
		
		protected function contentMouseDown (e:MouseEvent):void { }
		
		protected function openCanvasMouseDown (e:MouseEvent):void { }
		
		protected function controlsMouseHandler (e:MouseEvent):void // From: Canvas.CONTROLS
		{
			//Consol.globalOutput("Controller event: " + e);
			// all mouse events. But only from the controls sprite on canvas
		}
		
		protected function stageMouseUp (e:MouseEvent):void { }
		
		protected function enterFrameHandler (e:Event):void
		{
			// enterFrame
		}
		
		protected function canvasKeyEvent (e:CanvasEvent):void { }
		
		
		// UTILS / SHORTCUTS ////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function pullProps ():void
		{
		}
		
		protected function clearWireframes ():void
		{
			Canvas.WIREFRAME.graphics.clear();
		}
		
		public function toolUpdate (type:Update=null):void
		{
			if (type == null) // this should be specific. i know at leaste one is coming from edge controller
			{
				clearWireframes();
				update(GraphicUpdate.toolUpdate(), true, false);
			}
			else
			{
				// view, dispatch
				update(type, true, true);
			}
		}
		
		public function selectionUpdate (layers:Array):void
		{
			update(Update.selectionUpdate({layers:layers}, false), true, true);
		}
		
		public function layerUpdate (delay:Boolean=true):void
		{
			clearWireframes();
			update(GraphicUpdate.layerUpdate({layers:activeLayers}, delay), true, true);
		}
		
		public static function isTransformTool (t:Tool):Boolean
		{
			return (t is TransformTool);
		}
		
		
		// TBD / DEBUG //////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// LEGACY ///////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*protected function resetUpdateDelay (restart:Boolean=true):void
		{
			updateDelay.reset();
			if (restart) updateDelay.start();
		}*/
		
		/*protected function updateDelayHandler (e:TimerEvent):void
		{
			//update();
		}*/
		
		// Keep these here for now. They tell us which events do what.
		/*public function controllerEvent (e:MouseEvent):void
		{
			Consol.globalOutput(e);
		}*/
		
		/*protected function keyHandler (e:CanvasEvent):void
		{
			// CanvasEvent.KEY_EVENT - key events when the stage has focus
		}*/
		
		/*protected function canvasMouseHandler (e:CanvasEvent):void
		{
			// CanvasEvent.MOUSE_EVENT - all MouseEvents except when MOUSE_DOWN is OUTSIDE the canvas (ex: the canvas matte)
		}*/
		
		/*protected function stageMouseMoveHandler (e:MouseEvent):void
		{
			// mouseMove
		}*/

	}
	
}