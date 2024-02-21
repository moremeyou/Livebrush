package com.livebrush.transform
{
	/*import flash.events.EventDispatcher;
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
	//import com.livebrush.draw.DrawManager;
	import com.livebrush.transform.Transformer;
	import com.livebrush.transform.Controller;
	import com.livebrush.transform.LineTransformer;
	import com.livebrush.transform.GroupTransformer;
	import com.livebrush.graphics.canvas.Canvas;*/
	
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
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.transform.LayerLineController;
	import com.livebrush.transform.EdgeController;
	import com.livebrush.transform.LayerLineView;
	import com.livebrush.transform.LineEdgeView;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.transform.EdgeView;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.transform.SyncDisplay;
	import com.livebrush.utils.Update;
	import com.livebrush.graphics.GraphicUpdate;
	import com.livebrush.utils.View;
	import com.livebrush.utils.Controller;
	
	public class SingleEdgeView extends EdgeView
	{
		public var enabled												:Boolean;
		private var singleEdge											:Edge;
		
		public function SingleEdgeView (tool:Tool, layer:LineLayer, edge:Edge, enabled:Boolean=true):void
		{
			super(tool, layer, 0);
			
			singleEdge = edge;
			
			this.enabled = enabled;
			
			initSingle();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function get edge ():Edge {   return singleEdge;   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void { }
		
		private function initSingle ():void
		{
			createView();

			createController();
			
			if (enabled) registerController();
			
			update(GraphicUpdate.layerUpdate()); // superficial update because the view has just be created
		}
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function update (update:Update=null):void
		{
			posObj.child1Pos = edge.c;
			widthObj1.child1Pos = edge.a;
			widthObj2.child1Pos = edge.b;
			drawEdge();
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////


	}
	
}