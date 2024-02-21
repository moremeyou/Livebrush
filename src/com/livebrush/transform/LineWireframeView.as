package com.livebrush.transform
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import com.livebrush.ui.Consol;
	import com.livebrush.graphics.Line;
	import com.livebrush.graphics.SmoothLine;
	import com.livebrush.graphics.Edge;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.tools.Tool;
	import com.livebrush.transform.LayerLineController;
	import com.livebrush.transform.TransformBoxView;
	import com.livebrush.transform.TransformSprite;
	import com.livebrush.transform.LineEdgeView;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.utils.Selection;
	import com.livebrush.utils.Update;
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.graphics.GraphicUpdate;
	import com.livebrush.utils.View;
	import com.livebrush.utils.Controller;
	
	public class LineWireframeView extends View
	{
		public var line													:Line;
		public var wireLine												:Line;
		public var visible												:Boolean;
		
		public function LineWireframeView (tool:Tool, line:Line, visible:Boolean=true):void
		{
			super(tool);
			
			this.line = line;
			this.visible = visible;

			init();
		}
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			createView();
			
			controller = null; //createController();
			
			registerController();
			
			update(GraphicUpdate.lineUpdate()); // superficial. we just created this view;
		}
		
		public override function die ():void
		{
			wireLine.die();
		}
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			//// // Consol.Trace("Wireframe Line");
			//trace("Wireframe Line");
			wireLine = line.copy(false, true);
		}
		
		protected override function registerController ():void { }
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function update (update:Update=null):void
		{
			if (update.type == UpdateEvent.LINE || update.type == UpdateEvent.LAYER)
			{
				for (var i:int=0; i<line.length; i++)
				{
					//trace(line.edges[i].c + " : " + line.edges[i].a + " : " + line.edges[i].b);
					wireLine.modifyEdge(i, line.edges[i].c, line.edges[i].a, line.edges[i].b);
				}
				if (line is SmoothLine) wireLine.applyProps();
				wireLine.drawWireframe();
			}
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function getEdgeAt (index:int):Edge
		{
			return wireLine.edges[index];
		}

	}
	
}