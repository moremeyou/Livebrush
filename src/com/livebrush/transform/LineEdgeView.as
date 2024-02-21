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
	import com.livebrush.transform.LineEdgeController;
	import com.livebrush.transform.LayerLineView;
	import com.livebrush.transform.EdgeView;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.transform.SyncPoint;
	
	public class LineEdgeView extends EdgeView
	{
		
		public var visible												:Boolean;
		public var lineView												:LayerLineView;
		
		public function LineEdgeView (tool:Tool, lineView:LayerLineView, layer:LineLayer, edgeIndex:int, visible:Boolean=true):void
		{
			super(tool, layer, edgeIndex)
			
			this.visible = visible;
			this.lineView = lineView;
		}
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createController ():void
		{
			controller = new LineEdgeController(this);
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////

	}
	
}