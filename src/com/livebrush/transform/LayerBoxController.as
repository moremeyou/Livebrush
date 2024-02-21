package com.livebrush.transform
{
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
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
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.ui.Consol;
	import com.livebrush.transform.TransformBoxController;
	
	public class LayerBoxController extends TransformBoxController
	{
		public static const NONE										:String = "none";
		public static const MOVE										:String = "move";
		public static const ROTATE										:String = "rotate";
		public static const SCALE										:String = "scale";
		public static const MOVE_CENTER									:String = "moveCenter";
		
		
		public function LayerBoxController (view:LayerBoxView):void
		{
			super(view);
			
			init();
		}
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get layer ():Layer {   return LayerBoxView(view).layer;   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void { }
		
		public override function die ():void
		{
			super.die();
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function updateModel ():void
		{
			tool["transformLayer"](LayerBoxView(view));
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