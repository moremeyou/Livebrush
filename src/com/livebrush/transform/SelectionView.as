package com.livebrush.transform
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import com.livebrush.ui.Consol;
	import com.livebrush.graphics.Line;
	import com.livebrush.graphics.Edge;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.tools.Tool;
	import com.livebrush.transform.LayerLineController;
	import com.livebrush.transform.SelectionController;
	import com.livebrush.transform.LineEdgeView;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.utils.View;
	import com.livebrush.utils.Model;
	import com.livebrush.utils.Controller;
	import com.livebrush.data.StateManager;
	
	
	public class SelectionView extends View
	{
		private var startPt												:Point;
		private var endPt												:Point;
		
		public function SelectionView (model:Model):void
		{
			super(model)
			
			init();
		}
		
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get canvasManager ():CanvasManager {   return CanvasManager(model);   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			createController();
		}
		
		public override function die ():void
		{
			controller.die();
			clear();
		}
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createController ():void
		{
			controller = new SelectionController(this); 
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function beginSelection (startPt:Point):void
		{
			this.startPt = startPt;
		}
		
		public function updateSelection (endPt:Point):void
		{
			this.endPt = endPt;
			//update();
			Canvas.SELECTION.graphics.clear();
			drawBox();
		}
		
		private function drawBox ():void
		{
			var rect:Rectangle = new Rectangle();
			rect.topLeft = startPt;
			rect.bottomRight = endPt;
			Canvas.SELECTION.graphics.lineStyle(1, 0xFFFFFF, 1, false, "none");
			Canvas.SELECTION.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
		}
		
		public function clear ():void
		{
			//Consol.globalOutput("clear");
			Canvas.SELECTION.graphics.clear();
			startPt = null;
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function getSelectionBounds (scope:DisplayObjectContainer):Rectangle
		{
			return Canvas.SELECTION.getBounds(scope).clone();
		}
		
		
	}
	
}