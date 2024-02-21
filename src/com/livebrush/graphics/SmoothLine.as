package com.livebrush.graphics
{
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.EventPhase;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.styles.Style;
	import com.livebrush.data.Storable;
	import com.livebrush.graphics.Stroke;
	import com.livebrush.graphics.Edge;
	import com.livebrush.graphics.Line;
	import com.livebrush.styles.Style;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.data.StateManager;
	import com.livebrush.ui.Consol;
	
	
	public class SmoothLine extends Line implements Storable
	{

		public function SmoothLine (type:String, lines:int, weight:Number)
		{
			super(type, lines, weight);
		}
		

		// LINE / EDGE ACTIONS //////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function addEdgeAt (index:int, pt:Point=null):void
		{
			if (index != lastEdgeIndex && length > 1)
			{
				/*StateManager.addItem(function(state:Object):void{   var l:LineLayer = state.data.layer; l.line.deleteEdge(null, index+1);   },
								 //function(state:Object):void{   var l:LineLayer = state.data.layer; l.line.addEdgeAt(Edge.xmlToEdge(state.data.edgeXML.toXMLString()), index);   }, 
								 function(state:Object):void{   var l:LineLayer = state.data.layer; l.line.addEdgeAt(index, pt);   }, 
								 -1, {}, Canvas.GLOBAL_CANVAS.canvasManager.activeLayerDepth);*/
				
				
				var aStrokes:Array = invalidateEdgeStrokes(index);
				//var newEdge:Edge = (edge!=null ? edge : Edge.interpolate(edges[index], edges[index+1], .5));
				var newEdge:Edge = Edge.interpolate(edges[index], edges[index+1], .5);
				var newStroke:Stroke;
				
				if (pt != null) 
				{
					//newEdge.modifyBasic(pt, newEdge.angleRads, newEdge.width);
					newEdge.modify(pt, newEdge.angleRads, newEdge.width);
					newEdge.applyProps();
				}
				
				
				edges.splice(index+1, 0, newEdge);
				//newStroke = new SmoothStroke(edges[index+2], edges[index+1], edges[index], type, weight);
				
				if (length > 3)
				{
					if (index < 2 || (index == lastEdgeIndex-2)) // because we already added the edge... there's got to be a more formal way of doing this
					{
						if (index == 0)
						{
							newStroke = new SmoothStroke(edges[index+2], edges[index+1], edges[index], type, weight);
							strokes[aStrokes[0]].edge3 = newEdge;
							strokes.splice(aStrokes[0], 0, newStroke);
						}
						else if (index == 1)
						{
							newStroke = new SmoothStroke(edges[index+2], edges[index+1], edges[index], type, weight);
							strokes[aStrokes[0]].edge1 = newEdge;
							try {   strokes[aStrokes[1]].edge3 = newEdge;   } catch (e:Error){}
							strokes.splice(aStrokes[0]+1, 0, newStroke);
						}
						else if (index == lastEdgeIndex-2)
						{
							newStroke = new SmoothStroke(edges[lastEdgeIndex], newEdge, edges[index], type, weight);
							strokes[aStrokes[1]].edge1 = newEdge;
							strokes.splice(aStrokes[0]+2, 0, newStroke);
						}
					}
					else if (index < lastEdgeIndex-1)
					{
						newStroke = new SmoothStroke(edges[index+2], edges[index+1], edges[index], type, weight);
						strokes[aStrokes[1]].edge1 = newEdge;
						strokes[aStrokes[2]].edge3 = newEdge;
						strokes.splice(aStrokes[0]+2, 0, newStroke);
					}
				}
				else if (length == 3)
				{
					newStroke = new SmoothStroke(edges[2], edges[1], edges[0], type, weight);
					strokes[0].die();
					strokes[0] = newStroke;
				}
				
				lastStrokeLength = strokes.length;
				applyProps();
			}
		}
		
		public override function deleteEdge (edge:Edge=null, i:int=-5):void // all:Boolean=false
		{
			//// // Consol.Trace((edge==null));
			var index:int = (edge==null ? i : getEdgeIndex(edge));
			var aStrokes:Array = invalidateEdgeStrokes(index);
			
			if (length > 3)
			{
				if (index > 1 && index < lastEdgeIndex-1)
				{
					strokes[aStrokes[2]].edge3 = strokes[aStrokes[0]].edge2;
					strokes[aStrokes[0]].edge1 = strokes[aStrokes[2]].edge2;
					strokes.splice(aStrokes[1], 1)[0].die();
				}
				else if (index == 0)
				{
					strokes.splice(aStrokes[0], 1)[0].die();
				}
				else if (index == lastEdgeIndex)
				{
					strokes.splice(aStrokes[0], 1)[0].die();
				} 
				else if (index == 1)
				{
					strokes[aStrokes[1]].edge3 = edges[0]; //strokes[aStrokes[0]].edge2;
					strokes.splice(aStrokes[0], 1)[0].die();
				}
				else if (index == lastEdgeIndex-1)
				{
					strokes[aStrokes[0]].edge1 = edges[lastEdgeIndex];
					strokes.splice(aStrokes[1], 1)[0].die();
				}
				
				edges.splice(index, 1)[0].die();
				
				lastStrokeLength = strokes.length;
				applyProps();
			}
			else if (length == 3)
			{
				edges.splice(index, 1)[0].die();
				var stroke:Stroke = new Stroke(edges[1], edges[0], null, type, weight);
				strokes[0].die();
				strokes[0] = stroke;
			}
			else if (length == 2)
			{
				super.deleteEdge(edge);
			}
		}
		
		public override function draw (layer:Layer):void
		{
			if (length > 1)
			{
				for (var s:int=0; s<strokes.length; s++)
				{
					if (edges.length==3)
					{
						strokes[s].draw(layer, Stroke.BOTH);
						//// // Consol.Trace("SmoothLine: draw stroke both");
					}
					else
					{
						if (s==0) strokes[s].draw(layer, Stroke.START);
						else if (s==strokes.length-1) strokes[s].draw(layer, Stroke.END);
						else strokes[s].draw(layer, Stroke.MIDDLE);
					}
					
				}
				newStrokeCount = 0;
			}
			changed = false;
		}
		
		public override function drawNew (layer:Layer):void
		{
			if (length > 2)
			{
				for (var s:int=lastStrokeLength-1; s<strokes.length; s++)
				{
					if (s==0) strokes[s].draw(layer, Stroke.START);
					else strokes[s].draw(layer);
				}
			}
			newStrokeCount = 0;
		}
		
		public override function drawWireframe ():void
		{
			if (length > 1) 
			{
				var vectors:Sprite = Canvas.GLOBAL_CANVAS.wireframe;
				//vectors.graphics.clear();
				
				for (var s:int=0; s<strokes.length; s++)
				{
					if (edges.length==3)
					{
						strokes[s].drawWireframe(Stroke.BOTH);
					}
					else
					{
						if (s==0) strokes[s].drawWireframe(Stroke.START);
						else if (s==strokes.length-1) strokes[s].drawWireframe(Stroke.END);
						else strokes[s].drawWireframe(Stroke.MIDDLE);
					}
				}
				
				if (length > 2)
				{
					// start edge
					vectors.graphics.moveTo(firstStroke.edge3.a.x, firstStroke.edge3.a.y);
					vectors.graphics.lineTo(firstStroke.edge3.b.x, firstStroke.edge3.b.y);
				}
				if (length == 2)
				{
					// start edge
					vectors.graphics.moveTo(firstStroke.edge2.a.x, firstStroke.edge2.a.y);
					vectors.graphics.lineTo(firstStroke.edge2.b.x, firstStroke.edge2.b.y);
				}
				// end edge
				vectors.graphics.moveTo(lastStroke.edge1.a.x, lastStroke.edge1.a.y);
				vectors.graphics.lineTo(lastStroke.edge1.b.x, lastStroke.edge1.b.y);
			}
		}
		
		
		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function getSVG ():XML
		{
			
			var group:XML = new XML (<g/>);
			
			
			if (length > 1)
			{
				for (var s:int=0; s<strokes.length; s++)
				{
					if (edges.length==3)
					{
						group.appendChild(strokes[s].getSVG(Stroke.BOTH));
					}
					else
					{
						if (s==0) group.appendChild(strokes[s].getSVG(Stroke.START));
						else if (s==strokes.length-1) group.appendChild(strokes[s].getSVG(Stroke.END));
						else group.appendChild(strokes[s].getSVG(Stroke.MIDDLE));
					}
					
				}

			}
			
			
			/*for (var i:int=0;i<strokes.length;i++)
			{
				group.appendChild(strokes[i].getSVG());
			}*/
			
			return group;
			
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function copy (includeDecos:Boolean=true, basic:Boolean=false):Line
		{
			var newLine:SmoothLine;
			
			if (basic) newLine = new SmoothLine (type, 2, 1);
			else newLine = new SmoothLine (type, lines, weight);
			
			for (var i:int=0; i<edges.length; i++)
			{
				newLine.addEdge(edges[i].copy(includeDecos, basic));
			}
			return newLine;
		}
		
		
		


	}
}