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
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.tools.Tool;
	import com.livebrush.transform.LineEdgeView;
	import com.livebrush.transform.LayerLineView;
	import com.livebrush.transform.LayerBoxView;
	import com.livebrush.transform.EdgeController;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.ui.Consol;
	import com.livebrush.graphics.GraphicUpdate;
	
	public class LineEdgeController extends EdgeController
	{
		
		public function LineEdgeController (view:LineEdgeView):void
		{
			super(view);

			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get lineView ():LayerLineView {   return LineEdgeView(view).lineView;   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void { }
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function clickHandler (e:MouseEvent):void
		{
			var selectionType:int = (e.shiftKey ? 0 : (e.ctrlKey ? 1 : 2));
		}
		
		protected override function mouseDownHandler (e:MouseEvent):void
		{
			if (e.target == nodeC || e.target == nodeA || e.target == nodeB)
			{
				tool.begin();
				
				var selectionType:int = (e.shiftKey ? 0 : (e.ctrlKey ? 1 : 2));
				
				activeNode = MovieClip(e.target);
				
				lineView.selectEdges([index], selectionType);
				
				Canvas.STAGE.addEventListener (MouseEvent.MOUSE_UP, mouseUpHandler);
				Canvas.STAGE.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			}
		}
		
		
	}
	
}