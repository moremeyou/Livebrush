package com.livebrush.graphics
{
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	
	import com.livebrush.events.CanvasEvent;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.tools.Tool;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.utils.Controller;
	import com.livebrush.utils.Model;
	import com.livebrush.utils.View;
	import com.livebrush.graphics.CanvasView;
	import com.livebrush.ui.Consol;
	
	public class CanvasController extends Controller
	{
		
		public function CanvasController (view:View):void
		{
			super(view);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get canvasView ():CanvasView {   return CanvasView(view);   }
		public function get canvasManager ():CanvasManager {   return canvasView.canvasManager;   }
		public function get canvas ():Canvas {   return canvasView.canvas;   }
		public function get activeLayer ():Layer {   return canvasManager.activeLayer;   }
		public function get activeLayers ():Array {   return canvasManager.activeLayers;   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			canvas.stage.addEventListener (Event.RESIZE, resizeHandler);
			//canvas.stage.addEventListener (MouseEvent.MOUSE_MOVE, canvasLoop);
			canvas.stage.addEventListener (Event.ENTER_FRAME, canvasLoop);
			canvas.comp.addEventListener(MouseEvent.MOUSE_DOWN, canvasMouseHandler);
			canvas.comp.addEventListener(MouseEvent.MOUSE_UP, canvasMouseHandler);
			canvas.comp.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, canvasMouseHandler);
			
			// Don't do this until/if you formalized the other events so they get dispersed from the manager objects
			// See notes Tool obj in the setup method
			/*canvas.controls.addEventListener(MouseEvent.MOUSE_DOWN, controlsMouseHandler);
			canvas.controls.addEventListener(MouseEvent.MOUSE_UP, controlsMouseHandler);
			canvas.controls.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, controlsMouseHandler);*/
			
			// These should be from the EditMenu UI 
			canvas.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			//canvas.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler, true);
			canvas.stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
			//canvas.stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler, true);
			
			resize();
		}
		
		public override function die ():void
		{
			canvas.stage.removeEventListener (Event.RESIZE, resizeHandler);
			canvas.stage.removeEventListener (MouseEvent.MOUSE_MOVE, canvasLoop);
			canvas.comp.removeEventListener(MouseEvent.MOUSE_DOWN, canvasMouseHandler);
			canvas.comp.removeEventListener(MouseEvent.MOUSE_UP, canvasMouseHandler);
			canvas.comp.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, canvasMouseHandler);
			
			/*canvas.controls.removeEventListener(MouseEvent.MOUSE_DOWN, controlsMouseHandler);
			canvas.controls.removeEventListener(MouseEvent.MOUSE_UP, controlsMouseHandler);
			canvas.controls.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, controlsMouseHandler);*/
			
			canvas.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			canvas.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler, true);
		}
		
		
		// CANVAS ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function resize ():void
		{
			//canvas.x = ((canvas.stage.nativeWindow.width - Canvas.WIDTH) / 2) + canvas.offset.x;
			//canvas.y = ((canvas.stage.nativeWindow.height - Canvas.HEIGHT) / 2) + canvas.offset.y;
			canvasView.resize();
		}
	
	
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected function canvasMouseHandler (e:MouseEvent):void
		{
			canvas.lastMouseEvent = e;
			
			canvasManager.canvasMouseEvent(new CanvasEvent(CanvasEvent.MOUSE_EVENT, false, false, e))
		}
		
		private function canvasLoop (e:Event):void
		{
			// bad: we're also updating a bunch of non-cursor related props.
			// cursor will be another view down the road
			canvas.updateCursor();
		}
		
		private function keyHandler (e:KeyboardEvent):void
		{
			//Consol.globalOutput("Stage key event");
			//dispatchEvent(new CanvasEvent(CanvasEvent.KEY_EVENT, false, false, e));
			canvasManager.canvasKeyEvent(new CanvasEvent(CanvasEvent.KEY_EVENT, false, false, e))
		}
		
		private function resizeHandler (e:Event):void
		{
			resize();
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// TBD / DEBUG //////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function controlsMouseHandler (e:MouseEvent):void
		{
			//canvasManager.controlsMouseEvent(new CanvasEvent(CanvasEvent.MOUSE_EVENT, false, false, e))
		}*/

	}
}