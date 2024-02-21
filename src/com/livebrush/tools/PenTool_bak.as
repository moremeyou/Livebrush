package com.livebrush.tools
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.setTimeout
	import flash.utils.clearTimeout
	import flash.events.TimerEvent;
	
	import com.livebrush.events.ToolbarEvent;
	import com.livebrush.events.HelpEvent;
	import com.livebrush.events.CanvasEvent;
	import com.livebrush.ui.Panel
	import com.livebrush.ui.UI;
	import com.livebrush.ui.Consol;
	import com.livebrush.tools.Tool;
	import com.livebrush.tools.ToolManager;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.Line;
	import com.livebrush.graphics.SmoothLine;
	import com.livebrush.graphics.Edge;
	import com.livebrush.graphics.Stroke;
	import com.livebrush.styles.StrokeStyle;
	import com.livebrush.styles.StyleManager;
	import com.livebrush.transform.EdgeView;
	import com.livebrush.transform.LineWireframeView;
	import com.livebrush.utils.Selection;
	import com.livebrush.geom.SelectionBox;
	import com.livebrush.styles.Style;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.graphics.GraphicUpdate;
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.transform.SingleEdgeView;
	import com.livebrush.data.StateManager;
	
	
	public class PenTool extends Tool
	{
		public static const NAME										:String = "penTool";
		public static const KEY											:String = "P";
		
		public static const ADD_OPEN									:String = "addOpen";
		public static const ADD_INSIDE									:String = "addInside";
		public static const ADD_OUTSIDE									:String = "addOutside";
		
		public var updateDelay											:int = 1000;
		private var timeout												:int;
		private var newLine												:Line;
		private var newEdge												:Edge;
		private var liveEdgeIndex										:int = 0;
		private var lastNewEdge											:Edge;
		private var lastNewEdgeAngleRads								:Number;
		private var updateNewEdge										:Boolean = false;
		private var wireframeView										:LineWireframeView;
		public var edgeViews											:Array;
		private var addMode												:String = ADD_OPEN;
		private var singleEdgeView										:SingleEdgeView;
		private var lastSingleEdgeView									:SingleEdgeView;
		
		public function PenTool (toolMan:ToolManager):void
		{
			super(toolMan);
			
			edgeViews = [];
	
			init();
		}
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			name = NAME;
		}

		protected override function die ():void
		{
			super.die();
			
			clearTimeout(timeout);
			
			if (newLine != null)
			{
				newLine.die();
				newLine = null;
				newEdge = null;
			}
			
			edgeViews = [];
		}
		
		public override function setup ():void
		{
			super.setup(); 
			
			if (activeLayers.length == 1 && (activeLayer is LineLayer && !Layer.isBitmapLayer(activeLayer)) && LineLayer(activeLayer).line.length > 0)
			{
				for (var i:int=0; i<LineLayer(activeLayer).line.length; i++)
				{
					edgeViews.push(registerView(new EdgeView(this, LineLayer(activeLayer), i)));
				}
				
				wireframeView = LineWireframeView(registerView(new LineWireframeView(this, LineLayer(activeLayer).line)));
			}
			
			views.reverse(); // reverse to get the edge view lines on top of the wireframe
			
			update(GraphicUpdate.layerUpdate());
		}
		
		public override function reset ():void
		{
			super.reset();
			//// // Consol.Trace("PenTool reset");
			Canvas.WIREFRAME.graphics.clear();
			liveEdgeIndex = 0;
			addMode = ADD_OPEN;
			die();
		}
		
		
		// TOOL ACTIONS /////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function addEdgeAt (layer:LineLayer, index:int, pt:Point=null):void
		{
			if (addMode == ADD_OPEN)
			{
				layer.line.addEdgeAt(index, pt);
			
				reset();
				setup();

				layerUpdate();
				
				StateManager.closeState();
			}
		}
		
		public function transformEdge (upObj:Object, updateNow:Boolean=true):void // 
		{
			// this method is a dup from the TransformTool. But it's slightly different. Can't just call from transTool method...
			
			var fromScope:Sprite = upObj.fromScope==null ? Canvas.WIREFRAME : upObj.fromScope;
			var layer:LineLayer = upObj.layer;
			var edgeIndex:int = upObj.index;
			var c:Object = upObj.c;
			var a:Object = upObj.a;
			var b:Object = upObj.b;
			
			//layer:LineLayer, edgeIndex:int, c:Object, a:Object, b:Object, fromScope:Sprite=null
			
			if (fromScope != Canvas.WIREFRAME)
			{
				layer.line.modifyEdge(edgeIndex, 
									  SyncPoint.localToLocal(SyncPoint.objToPoint(c), fromScope, Canvas.WIREFRAME),
									  SyncPoint.localToLocal(SyncPoint.objToPoint(a), fromScope, Canvas.WIREFRAME),
									  SyncPoint.localToLocal(SyncPoint.objToPoint(b), fromScope, Canvas.WIREFRAME));
				
				wireframeView.wireLine.modifyEdge(edgeIndex, 
									  SyncPoint.localToLocal(SyncPoint.objToPoint(c), fromScope, Canvas.WIREFRAME),
									  SyncPoint.localToLocal(SyncPoint.objToPoint(a), fromScope, Canvas.WIREFRAME),
									  SyncPoint.localToLocal(SyncPoint.objToPoint(b), fromScope, Canvas.WIREFRAME));
			}
			else
			{
				layer.line.modifyEdge(edgeIndex, new Point(c.x, c.y), new Point(a.x, a.y), new Point(b.x, b.y));
				
				wireframeView.wireLine.modifyEdge(edgeIndex, new Point(c.x, c.y), new Point(a.x, a.y), new Point(b.x, b.y));
			}
			
			if (updateNow) layerUpdate();
		}
		
		
		// INTERNAL ACTIONS /////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function setNewLine (useExisting:Boolean):void
		{
			var layer:LineLayer = activeLayer as LineLayer;
			
			if (useExisting) newLine = Line.newLine((layer.line is SmoothLine), layer.line.type, layer.line.lines, layer.line.weight);
			//lineLayer.line = Line.newLine(style.lineStyle.smoothing, strokeStyle.strokeType, strokeStyle.lines, strokeStyle.weight);
			//else newLine = Line.newLine(styleManager.activeStyle.lineStyle.smoothing, "solid", 2, 1);
			else newLine = Line.newLine(styleManager.activeStyle.lineStyle.smoothing, 
										styleManager.activeStyle.strokeStyle.strokeType, 
										styleManager.activeStyle.strokeStyle.lines, 
										styleManager.activeStyle.strokeStyle.weight);
			addMode = ADD_OUTSIDE;
		}
		
		private function addNewEdge (usePrevious:Boolean, copyFromRealLine:Boolean=false):void
		{
			if (usePrevious)
			{
				if (copyFromRealLine)
				{
					newEdge = LineLayer(activeLayer).line.edges[liveEdgeIndex].copy(false, true);
					if (liveEdgeIndex == 0) newEdge.invert();
				}
				else 
				{
					//// // Consol.Trace("PenTool: addNewEdge> don't copy");
					
					lastNewEdge = newEdge;
				
					newEdge = lastNewEdge.copy();
					
					var dy:Number = Canvas.Y-lastNewEdge.c.y;
					var dx:Number = Canvas.X-lastNewEdge.c.x;
					var angleRads:Number = Math.atan2(dy, dx);
					//lastNewEdge.modify (lastNewEdge.c, angleRads, lastNewEdge.width);
					// most recent >>>>>>> newEdge.modify (Canvas.MOUSE_POINT, angleRads, lastNewEdge.width);
				}
			}
			else
			{
				newEdge = new Edge(Canvas.X, Canvas.Y, 25, 90, newLine.lines, 0xFF0000, newLine.weight, null);
			}
			
			newLine.addEdge(newEdge);
		}
		
		private function applyNewLine (delay:Boolean=false):void
		{
			//// // Consol.Trace("PenTool: applyNewLine");
			
			var edge:Edge;
			var layer:LineLayer = activeLayer as LineLayer;
			var line:Line = layer.line;
			var existingLineEdge:Edge;
			var lineXML:XML = line.getXML();
			
			
			if (line.length > 0) existingLineEdge = line.edges[liveEdgeIndex];
			else existingLineEdge = newEdge; // newLine.edges[0];
			
			for (var i:int=0; i<newLine.length; i++)
			{
				edge = newLine.edges[i];
				edge.alpha = existingLineEdge.alpha;
				//edge.color = existingLineEdge.color;
				edge.lines = existingLineEdge.lines;;
				edge.applyProps();
			}
			newLine.type = line.type;
			newLine.lines = line.lines;
			newLine.applyProps();
			
			if (line.length == 1)
			{
				line.edges[0].modify(line.edges[0].c, newLine.edges[0].angleRads, line.edges[0].length);
				newLine.edges.shift();
			}
			else if (line.length > 1) 
			{
				newLine.edges.shift();
			}
			
			if (line.length > 1 && liveEdgeIndex == 0)
			{
				for (i=0; i<newLine.edges.length; i++)
				{
					newLine.edges[i].invert();
				}
				
				newLine.edges.reverse();
				
				line.edges = newLine.edges.concat(line.edges);
			}
			else
			{
				line.edges = line.edges.concat(newLine.edges);
			}
			
			LineLayer(activeLayer).line.rebuild();
			
			
			//// // Consol.Trace("Pen Tool: applyNewLine");
			/*StateManager.addItem(function(state:Object):void{   var l:LineLayer = state.data.layer; l.line.setXML(state.data.lineXML.toXMLString()); l.setup();   },
								 function(state:Object):void{   var l:LineLayer = state.data.layer; l.line.setXML(state.data.newLineXML.toXMLString()); l.setup();   }, 
								 -1, {lineXML:lineXML, newLineXML:line.getXML()}, -1, "PenTool: applyNewLine");*/
			
	
	
			reset();
			layerUpdate(delay);
			finish(delay);
			setup();
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function contentMouseDown (e:MouseEvent):void
		{
			if (Layer.isLineLayer(activeLayer)) 
			{
				// GOOD NOTES:
				
				//addEdgeAt(LineLayer(activeLayer), getClosestEdgeViewIndex(Canvas.MOUSE_POINT), Canvas.MOUSE_POINT);
				
				// This is where we could detect WHERE they clicked in the line
				// check all the pairs of edges
				// adding up the distance between each
				// then the closest one gets the edge
				
				// and because we already know that they've clicked on the line
				// we can assume they want to add an edge between this pair
				
				// because we know they clicked on the line, we get around the issue of a closer pair the is at a different part of the line
				
				// doesn't work quite right
				// because if there are 2 closer edges around this point, and a long dist between the actual edges we're clicking between,
				// it will use the closer ones.
			}
			else
			{
				openCanvasMouseDown(e);
			}
		}
		
		protected override function openCanvasMouseDown (e:MouseEvent):void
		{
			//// // Consol.Trace("PenTool: openCanvasMouseDown");
			
			var layer:LineLayer;
			
			resetUpdateTimeout(false);
			
			begin();
			
			if (!Layer.isLineLayer(activeLayer) || Layer.isBitmapLayer(activeLayer))
			{
				layer = canvasManager.addLayer(Layer.newLineLayer(canvas)) as LineLayer;
				//layer.line = Line.newLine(styleManager.activeStyle.lineStyle.smoothing, "solid", 2, 1);
				layer.line = Line.newLine(styleManager.activeStyle.lineStyle.smoothing, 
										  styleManager.activeStyle.strokeStyle.strokeType, 
										  styleManager.activeStyle.strokeStyle.lines, 
										  styleManager.activeStyle.strokeStyle.weight);
				
				/*StateManager.addItem(function(state:Object):void{      },
									 function(state:Object):void{   var l:LineLayer = state.data.layer; l.line = Line.xmlToLine(state.data.lineXML); l.setup();   }, 
									 -1, {lineXML:layer.line.getXML()}, -1, "PenTool: openCanvasMouseDown");*/
				
				//StateManager.closeState();
				
				setNewLine(false);
				addNewEdge(false);

			}
			else if (activeLayer is LineLayer) // we can assume a line layer will always have a line object. even it its empty.
			{
				layer = activeLayer as LineLayer;
				if (layer.line.length == 0) // need to check if we save a project with empty line, when re-open, does all this still work?
				{
					setNewLine(true);
					addNewEdge(false);
					
				}
				else if (newLine != null)
				{
					addNewEdge(true);
				}
				else
				{
					setNewLine(true);
					liveEdgeIndex = 0; 
					if (layer.line.length > 0) liveEdgeIndex = getClosestEdgeIndex(Canvas.MOUSE_POINT);
					addNewEdge(true, true);
					addNewEdge(true);
				}
			}
			
			if (wireframeView != null) 
			{
				unregisterView(wireframeView);
				wireframeView.die();
			}
			
			wireframeView = LineWireframeView(registerView(new LineWireframeView(this, newLine))); 
			
			singleEdgeView = SingleEdgeView(registerView(new SingleEdgeView(this, layer, newEdge, false)));
			
			updateNewEdge = true;
		}
		
		protected override function canvasMouseUp (e:MouseEvent):void
		{
			// there is an aditional level of delay here. this is because we don't want to reset the wireframe until they're done adding (upon reset)
			if (updateNewEdge)
			{
				updateNewEdge = false;
				
				unregisterView(singleEdgeView);
				singleEdgeView.die();
				singleEdgeView = null;
				
				if (updateDelay == 0) 
				{
					resetUpdateTimeout(false);
					applyNewLine();
				}
				else 
				{
					resetUpdateTimeout(true); 
				}
				
				if (LineLayer(activeLayer).line.length > 0)
				{
				}
				else
				{
					applyNewLine();
				}  
			}
		}
		
		// this function event is part of the old tool event setup
		// not sure how else to do this one
		protected override function controlsMouseHandler (e:MouseEvent):void
		{
			//Consol.globalOutput("Controller event: " + e);
			canvasMouseUp(e);
			// all mouse events. But only from the controls sprite on canvas
		}
		
		// this function event is part of the old tool event setup
		// consider aligning it with all the other canvas events (That get dispatched from canvasManager)
		protected override function enterFrameHandler (e:Event):void
		{
			
			if (updateNewEdge)
			{
				//// // Consol.Trace("loop");
				var angleRads:Number = canvas.angleRads;
				var newEdgeWidth:Number = 25;
				
				if (newLine.length > 1)
				{
					//// // Consol.Trace("loop");
					var dy:Number = canvas.mousePt.y-lastNewEdge.c.y;
					var dx:Number = canvas.mousePt.x-lastNewEdge.c.x;
					angleRads = Math.atan2(dy, dx); // + (Math.PI/2); 
					
					newEdgeWidth = newEdge.width;
					
					newEdge.modify (canvas.mousePt, angleRads, newEdgeWidth); 
					
					if (LineLayer(activeLayer).line.length == 0) 
					//if (newLine.length == 2 && newLine is SmoothLine) 
					{
						newEdgeWidth = lastNewEdge.width;
						
						lastNewEdge.modify (lastNewEdge.c, angleRads, newEdgeWidth);
					}
					else if (newLine.length > 2)  // This is to average out the lastEdge angle. But we should also increase its width too...
					{
						newEdgeWidth = lastNewEdge.width;
						
						dy = canvas.mousePt.y-newLine.edges[newLine.edges.length-3].c.y;
						dx = canvas.mousePt.x-newLine.edges[newLine.edges.length-3].c.x;
						var angleRads2 = Math.atan2(dy, dx); // + (Math.PI/2); 
						lastNewEdge.modify (lastNewEdge.c, angleRads2, newEdgeWidth);
						
						//if (Math.abs(lastNewEdgeAngleRads - angleRads2) < Math.PI/2) lastNewEdge.modify (lastNewEdge.c, angleRads2, lastNewEdge.width);
						
						//if (Math.abs(angleRads-angleRads2) < Math.PI/2) newEdge.modify (canvas.mousePt, angleRads, newEdge.width); // , Transformer.container // layer.canvas.wireframe
						//else newEdge.modify (canvas.mousePt, angleRads2, newEdge.width); // , Transformer.container // layer.canvas.wireframe
					}
					
					
					newLine.invalidateEdge(lastNewEdge);
					newLine.invalidateEdge(newEdge);
				}
				else 
				{
					newEdgeWidth = newEdge.width;
					
					//// // Consol.Trace("loop");
					newEdge.modify (canvas.mousePt, Math.PI, newEdgeWidth);
					// modify the angle based on the mouse move direction - from canvas
					// still need to fix this jitter bug
				}
				
				newLine.applyProps();
				
				clearWireframes();
				
				// flips the 2nd edge (orient the first edge to the second in a 2-edge line (this edge creates the first stroke)
				if (newLine.length == 2 && LineLayer(activeLayer).line.length < 2) 
				{
					//newEdge.modify (canvas.mousePt, angleRads, newEdge.width); // , Transformer.container // layer.canvas.wireframe
					
					
					lastNewEdge.modify (lastNewEdge.c, angleRads, lastNewEdge.width);
					
					
					//singleEdgeView.edge.modify (canvas.mousePt, angleRads, newEdgeWidth);
				}
		
				singleEdgeView.edge.modify (canvas.mousePt, angleRads, newEdgeWidth);
				
				toolUpdate();
				
				wireframeView.update(new GraphicUpdate(UpdateEvent.LINE));
				
				//singleEdgeView.update(null);
				
				
				
			}
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function getClosestEdgeIndex (pt:Point):int
		{
			var closeEdge:int;
			var dist:Number = Point.distance(edgeViews[0].edge.c, pt);
			if (Point.distance(edgeViews[edgeViews.length-1].edge.c, pt) < dist) closeEdge = edgeViews.length-1;
			else 0;
			return closeEdge;
		}
	
		private function resetUpdateTimeout (restart:Boolean=true):void
		{
			clearTimeout(timeout);
			if (restart) timeout = setTimeout(applyNewLine, updateDelay);
		}
		
		
		// TBD / DEBUG //////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function getClosestEdgeViewIndex (pt:Point):int
		{
			var thisDist:Number = 0;
			var closestDist:Number = 10000;
			var closeIndex:int = 0;
			var edge1:Edge;
			var edge2:Edge;
			
			for (var i:int=1; i<edgeViews.length; i++)
			{
				edge1 = edgeViews[i].edge;
				edge2 = edgeViews[i-1].edge;
				thisDist = Point.distance(edge1.c, pt) + Point.distance(edge2.c, pt);
				if (thisDist < closestDist) 
				{
					closestDist = thisDist;
					closeIndex = i-1;
				}
			}
			
			return closeIndex;
		}*/

	}
	
}