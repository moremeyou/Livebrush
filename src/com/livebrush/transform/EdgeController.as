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
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.ui.Consol;
	import com.livebrush.graphics.GraphicUpdate;
	import com.livebrush.utils.Controller;
	
	public class EdgeController extends Controller
	{
		protected var nodes												:Array;
		protected var action											:String = "idle"; // move, scale
		protected var activeNode										:MovieClip;
	
		public function EdgeController (view:EdgeView):void
		{
			super(view);
			
			nodes = [];
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get tool ():Tool {   return Tool(EdgeView(view).tool);   }
		public function get index ():int {   return EdgeView(view).edgeIndex;   }
		public function get layer ():LineLayer {   return EdgeView(view).layer;   }
		public function get nodeA ():MovieClip {   return nodes[1];   }
		public function get nodeB ():MovieClip {   return nodes[2];   }
		public function get nodeC ():MovieClip {   return nodes[0];   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			activeNode = nodes[0];
		}
		
		public override function die ():void
		{
			if (nodes != null)
			{
				var tempNodes:Array = nodes.slice();
				for (var i:int=0; i<tempNodes.length; i++)
				{
					unregisterNode(tempNodes[i]);
				}
				tempNodes = [];
				nodes = null;
			}
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function updateModel ():void
		{
			tool["transformEdge"](EdgeView(view).getUpdateObj());
		}
		
		public function registerNode (node:MovieClip):void
		{
			node.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			node.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			node.addEventListener(MouseEvent.CLICK, clickHandler);
			nodes.push(node);
		}
		
		public function unregisterNode (node:MovieClip):void
		{
			node.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			node.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			node.removeEventListener(MouseEvent.CLICK, clickHandler);
			nodes.splice(nodes.indexOf(node),1);
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected function clickHandler (e:MouseEvent):void
		{
			// this will do nothing here. we're not selecting. we're adding edges
		}
		
		protected function mouseDownHandler (e:MouseEvent):void
		{
			tool.begin();
			
			if (e.target == nodeC && !e.ctrlKey)
			{
				tool["addEdgeAt"](LineLayer(layer), EdgeView(view).edgeIndex);
			}
			else if (e.target == nodeA || e.target == nodeB || (e.target == nodeC && e.ctrlKey))
			{
				activeNode = MovieClip(e.target);
				
				Canvas.STAGE.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
				Canvas.STAGE.addEventListener (MouseEvent.MOUSE_UP, mouseUpHandler);
			}
		}
		
		protected function mouseUpHandler (e:MouseEvent):void
		{
			tool.finish();
			Canvas.STAGE.removeEventListener (MouseEvent.MOUSE_UP, mouseUpHandler);
			Canvas.STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
		}
		
		protected function moveHandler (e:Event):void
		{
			activeNode.x = Canvas.CONTROLS.mouseX;
			activeNode.y = Canvas.CONTROLS.mouseY;
			
			if (activeNode == nodeA) 
			{
				nodeB.x = nodeC.x + (nodeC.x - nodeA.x);
				nodeB.y = nodeC.y + (nodeC.y - nodeA.y);
			}
			else if (activeNode == nodeB) 
			{
				nodeA.x = nodeC.x + (nodeC.x - nodeB.x);
				nodeA.y = nodeC.y + (nodeC.y - nodeB.y);
			}
			
			if (activeNode != nodeC) view.update(GraphicUpdate.toolUpdate());
 			
			updateModel();
		}

	}
	
}