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
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.transform.LayerLineController;
	import com.livebrush.transform.EdgeController;
	import com.livebrush.transform.LayerLineView;
	import com.livebrush.transform.LineEdgeView;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.transform.SyncDisplay;
	import com.livebrush.utils.Update;
	import com.livebrush.graphics.GraphicUpdate;
	import com.livebrush.utils.View;
	import com.livebrush.utils.Controller;
	
	public class EdgeView extends View
	{
		public var layer												:LineLayer;
		public var edgeIndex											:int;
		private var controlObjs											:Array;
		private var edgeSprite											:Sprite;
		public var widthObj1											:SyncDisplay;
		public var widthObj2											:SyncDisplay;
		public var posObj												:SyncDisplay;
		
		public function EdgeView (tool:Tool, layer:LineLayer, edgeIndex:int):void
		{
			super(tool);
			
			this.layer = layer;
			this.edgeIndex = edgeIndex;
			controlObjs = [];
			
			init();
		}
		
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get tool ():Tool {   return Tool(model);   }
		public function get edgePoints ():Array {   return [edge.c, edge.a, edge.b];   }
		public function get controlC ():Object {   return posObj.child2;   } 
		public function get controlA ():Object {   return widthObj1.child2;   }
		public function get controlB ():Object {   return widthObj2.child2;   }
		public function get edge ():Edge {   return layer.line.edges[edgeIndex];   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			createView();

			createController();
			
			registerController();
			
			update(GraphicUpdate.layerUpdate()); // superficial update because the view has just be created
		}
		
		public override function die ():void
		{
			var tempObjs:Array = controlObjs.slice();
			for (var i:int=0; i<tempObjs.length; i++)
			{
				tempObjs[i].die();
				Canvas.CONTROLS.removeChild(tempObjs[i].child2);
				delete tempObjs[i];
			}
			tempObjs = [];
			controlObjs = [];
			
			controller.die();
			controller = null;
		}
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			controlObjs = [];
			
			posObj = new SyncDisplay(Canvas.WIREFRAME, edge.c, Canvas.CONTROLS, Canvas.CONTROLS.addChild(new EdgeControlNode()));
			controlObjs.push(posObj);
			
			widthObj1 = new SyncDisplay(Canvas.WIREFRAME, edge.a, Canvas.CONTROLS, Canvas.CONTROLS.addChild(new EdgeControlNode()));
			controlObjs.push(widthObj1);
			
			widthObj2 = new SyncDisplay(Canvas.WIREFRAME, edge.b, Canvas.CONTROLS, Canvas.CONTROLS.addChild(new EdgeControlNode()));
			controlObjs.push(widthObj2);
		}
		
		protected override function createController ():void
		{
			controller = new EdgeController(this);
		}
		
		protected override function registerController ():void
		{
			EdgeController(controller).registerNode(MovieClip(posObj.child2));
			EdgeController(controller).registerNode(MovieClip(widthObj1.child2));
			EdgeController(controller).registerNode(MovieClip(widthObj2.child2));
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function update (update:Update=null):void
		{
			if (update.type == UpdateEvent.LINE || update.type == UpdateEvent.LAYER)
			{
				posObj.child1Pos = edge.c;
				widthObj1.child1Pos = edge.a;
				widthObj2.child1Pos = edge.b;
				
				for (var i:int=0; i<controlObjs.length; i++)
				{
					controlObjs[i].updateSync(true);
				}
			}
			else if (update.type == UpdateEvent.TOOL)
			{
				for (i=0; i<controlObjs.length; i++)
				{
					controlObjs[i].updateSync(false);
				}
			}
			
			drawEdge();
		}
		
		protected function drawEdge ():void
		{
			//Canvas.WIREFRAME.graphics.clear();
			Canvas.WIREFRAME.graphics.lineStyle(1, 0xFFFFFF, 1, false, "none");
			Canvas.WIREFRAME.graphics.moveTo(widthObj1.child1X, widthObj1.child1Y);
			Canvas.WIREFRAME.graphics.lineTo(widthObj2.child1X, widthObj2.child1Y);
		}
		
		public function set visualState (s:int):void
		{
			//// // Consol.Trace(s);
			controlC.gotoAndStop(s+1);
			controlA.gotoAndStop(s+1);
			controlB.gotoAndStop(s+1);
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function getUpdateObj ():Object
		{
			return {layer:layer, index:edgeIndex, c:controlC, a:controlA, b:controlB, color:edge.color, alpha:edge.alpha, fromScope:Canvas.CONTROLS};
		}


	}
	
}