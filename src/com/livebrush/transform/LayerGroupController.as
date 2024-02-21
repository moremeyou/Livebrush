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
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.tools.Tool;
	import com.livebrush.transform.LayerBoxView;
	import com.livebrush.transform.LayerGroupView;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.transform.TransformBoxController;
	import com.livebrush.ui.Consol;
	
	public class LayerGroupController extends TransformBoxController
	{
		
		public function LayerGroupController (view:LayerGroupView):void
		{
			super(view);
			
			init();
		}
		

		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void { }
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function updateModel ():void
		{
			tool["transformLayerGroup"](LayerGroupView(view));
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
		
		
	}
	
}