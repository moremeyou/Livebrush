package com.livebrush.transform
{
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.Event;
	
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.tools.Tool;
	import com.livebrush.tools.TransformTool;
	import com.livebrush.transform.LayerLineView;
	import com.livebrush.transform.LayerBoxView;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.transform.TransformBoxController;
	import com.livebrush.ui.Consol;
	import com.livebrush.utils.Update;
	import com.livebrush.events.UpdateEvent;
	
	public class LayerLineController extends TransformBoxController
	{
		
		public function LayerLineController (view:LayerLineView):void
		{
			super(view)
			
			init();
		}
		
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get layer ():Layer {   return LayerLineView(view).layer;   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			if (LayerLineView(view).visible) initKeyControls();
		}
		
		public override function die ():void
		{
			Canvas.STAGE.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			Canvas.STAGE.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler, true);
			
			super.die();
		}
		
		private function initKeyControls ():void
		{
			Canvas.STAGE.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			Canvas.STAGE.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler, true);
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function updateModel ():void
		{
			LayerLineView(view).update(new Update(UpdateEvent.GROUP)); //groupUpdate(); 
			TransformTool(tool).transformLine(LayerLineView(view).getGroupedEdgeUpdateObjs());
		}
		
		protected override function initMoveLoop ():void
		{
			// begin a loop update the view (and other shit, if different kind of transforming)
			Canvas.STAGE.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			
			// listen for global mouse up to kill drag
			Canvas.STAGE.addEventListener (MouseEvent.MOUSE_UP, controlNodeEventHandler);
		}
		
		protected override function removeMoveLoop ():void
		{
			Canvas.STAGE.removeEventListener (MouseEvent.MOUSE_UP, controlNodeEventHandler);
			Canvas.STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function keyHandler (e:KeyboardEvent):void
		{
			// keyboard events always go through the model
			// because they only affect one layer at a time
			// the model will know which layer this is (for now, just the topmost layer)
			// no - because we only register these events if the view is visible (the only layer selected)
			//Consol.globalOutput("keyboard event");
			
			
			var char:String = String.fromCharCode(e.charCode).toUpperCase();
			
			if (e.keyCode == Keyboard.ESCAPE) 
			{
				tool.reset();
				tool.setup();
			}
			else if (e.keyCode == Keyboard.DELETE || e.keyCode == Keyboard.BACKSPACE) 
			{
				e.stopImmediatePropagation();
				//if (layer.line.length > 1)
				if (LayerLineView(view).groupedEdgeIndices.length > 0) tool["deleteEdges"](layer, LayerLineView(view).groupedEdgeIndices.items);
				
			}
			/*else if (char == "A" && e.ctrlKey) 
			{
				LayerLineView(view).selectEdges(LayerLineView(view).allEdgeIndices)
			}
			else if (char == "D" && e.ctrlKey) 
			{
				LayerLineView(view).selectEdges([])
			}*/
		}
		
		
	}
	
}