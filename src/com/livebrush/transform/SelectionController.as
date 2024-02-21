package com.livebrush.transform
{

	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.tools.Tool;
	import com.livebrush.transform.LayerLineView;
	import com.livebrush.transform.LayerBoxView;
	import com.livebrush.transform.SelectionView;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.ui.Consol;
	import com.livebrush.events.CanvasEvent;
	import com.livebrush.utils.Controller;
	import com.livebrush.data.StateManager;
	
	
	public class SelectionController extends Controller
	{
		
		private var lastMouseEvent								:MouseEvent;
		private var lastSelectionBounds							:Rectangle;
		
		public function SelectionController (view:SelectionView):void
		{
			super(view);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get canvasManager ():CanvasManager {   return CanvasManager(SelectionView(view).canvasManager);   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			lastSelectionBounds = new Rectangle();
			canvasManager.addEventListener (CanvasEvent.MOUSE_EVENT, canvasMouseHandler);
		}
		
		public override function die ():void
		{
			reset();
			canvasManager.removeEventListener (CanvasEvent.MOUSE_EVENT, canvasMouseHandler);
		}
		
		public function reset ():void
		{
			lastSelectionBounds = new Rectangle();
			Canvas.STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			Canvas.STAGE.removeEventListener (MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function updateModel ():void
		{
			setSelection(SelectionView(view).getSelectionBounds(Canvas.SELECTION), (lastMouseEvent.shiftKey ? 0 : (lastMouseEvent.ctrlKey ? 1 : 2))); 
		}
		
		private function setSelection (bounds:Rectangle, type:int)
		{
			//// // Consol.Trace("SelectionController: setSelection");
			canvasManager.canvasSelection(bounds, type);
		}
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function canvasMouseHandler (e:CanvasEvent):void
		{
			// CanvasEvent.MOUSE_EVENT - all MouseEvents except when MOUSE_DOWN is OUTSIDE the canvas (ex: the canvas matte)
			var mouseEvent:MouseEvent = e.triggerEvent as MouseEvent;
			// use this to check if they clicked the lineLineLayer(layer).hitTest(mouseEvent.stageX, mouseEvent.stageY);
			
			if (mouseEvent.type == MouseEvent.MOUSE_DOWN && canvasManager.selectionAllowed)
			{
				//Consol.globalOutput("mouse down!");
				// this point could be a method of canvas. getMousePt(scope:DisplayObjectContainer):Point;
				SelectionView(view).beginSelection(new Point(Canvas.SELECTION.mouseX, Canvas.SELECTION.mouseY));
				Canvas.STAGE.addEventListener (MouseEvent.MOUSE_UP, mouseUpHandler);
				Canvas.STAGE.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
				
			}
		}
		
		private function moveHandler (e:MouseEvent):void
		{
			//Consol.globalOutput("mouse move!");
			SelectionView(view).updateSelection(new Point(Canvas.SELECTION.mouseX, Canvas.SELECTION.mouseY));
		}
		
		private function mouseUpHandler (e:MouseEvent):void
		{
			var bounds:Rectangle = SelectionView(view).getSelectionBounds(Canvas.SELECTION);
			
			StateManager.addItem(function(state:Object):void{   setSelection(state.data.lastBounds, 2);   },
								 function(state:Object):void{   setSelection(state.data.bounds, 2);   },
								 -1, {bounds:bounds.clone(), lastBounds:lastSelectionBounds.clone()});
			StateManager.closeState();
			
			
			reset();
			lastMouseEvent = e;
			lastSelectionBounds = bounds.clone();
			updateModel();
			SelectionView(view).clear();
		}
		

		
	}
	
}