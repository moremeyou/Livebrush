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
	import com.livebrush.data.Settings;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.styles.DecoAsset;
	import com.livebrush.data.Storable;
	import com.livebrush.graphics.Stroke;
	import com.livebrush.graphics.Edge;
	import com.livebrush.styles.Style;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.graphics.SmoothLine;
	import com.livebrush.graphics.SmoothStroke;
	import com.livebrush.data.StateManager;
	import com.livebrush.ui.Consol;
	
	
	public class Line extends EventDispatcher implements Storable
	{
		
		public static const SMOOTH_LINE				:String = "smooth";
		public static const STRAIGHT_LINE			:String = "straight";
		
		public var decoCount						:int;
		public var decoLoadCount					:int;
		public var style							:Style = null;
		public var strokes							:Array;
		public var type								:String = "solid";
		public var weight							:Number = 1;
		public var edges							:Array;
		public var lines							:int = 2;
		public var created							:Boolean = false;
		public var lastStrokeLength					:int = 0; // reset each time we draw strokes
		public var newStrokeCount					:int = 0;
		public var changed							:Boolean = false;
	
		public function Line (type:String="solid", lines:int=2, weight:Number=1)
		{
			lastStrokeLength = 0;
			decoCount = 0;
			decoLoadCount = 0;
			this.lines = lines;
			this.type = type;
			this.weight = weight;
			strokes = [];
			edges = [];
		}

		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get lastEdgeIndex ():int {   return length-1;   }
		public function get secondLastEdge ():Edge {   return edges[Math.max(0, edges.length-2)];   }
		public function get firstEdge ():Edge {   return edges[0];   }
		public function get lastEdge ():Edge {   return edges[edges.length-1];   }
		public function get firstStroke ():Stroke {   return strokes[0];   }
		public function get lastStroke ():Stroke {   return strokes[strokes.length-1];   }
		public function get length ():int {   return edges.length;   }
		public function get hasDecos ():Boolean {   return decoCount>0;   }
		public function get decosLoaded ():Boolean {   return (decoLoadCount == decoCount);   }
		
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function die ():void
		{
			created = false;

			while (edges.length > 0)
			{
				edges.pop().die();
			}
			while (strokes.length > 0)
			{
				//strokes.pop().die();
				strokes.pop().dieDecos();
			}
			
			lastStrokeLength = 0;
			changed = true;
			decoLoadCount = 0;
		}
		
		public function rebuild ():void
		{
			/*StateManager.addItem(function(state:Object):void{   var l:LineLayer = state.data.layer; l.line.setXML(state.data.lineXML.toXMLString()); l.setup();   },
								 function(state:Object):void{   var l:LineLayer = state.data.layer; l.line.addEdgeAt(index, pt);   }, 
								 -1, {lineXML:getXML()});*/
			
			/* = Line.xmlToLine(state.data.lineXML);
			StateManager.addItem(function(state:Object):void{      },
										 function(state:Object):void{   var l:LineLayer = LineLayer(state.canvasManager.getLayer(state.data.brushDepth)); l.line = Line.xmlToLine(state.data.lineXML); l.setup(); l.depth=state.data.brushDepth;   }, 
										 brush.stateIndex, {lineXML:brush.line.getXML(), brushDepth:brush.layer.depth});*/
			
			
			
			created = false;
			
			for (var i:int=0; i<edges.length; i++)
			{
				// do this because killing the strokes, kills the decos also
				if (edges[i].decoGroup != null) edges[i].decoGroup = edges[i].decoGroup.copy();
			}
			
			var tempEdges:Array = edges.slice();

			while (strokes.length > 0)
			{
				//strokes.pop().die();
				strokes.pop().dieDecos();
			}
			
			edges = [];
			strokes = [];
			lastStrokeLength = 0;
			decoLoadCount = 0;
			
			for (i=0; i<tempEdges.length; i++)
			{
				addEdge(tempEdges[i], true);
			}
			
			changed = true;
		}
		
		public function applyProps ():void
		{
			changed = true;
			for (var i:int=0; i<strokes.length; i++)
			{
				//// // Consol.Trace("Stroke changed");
				if (strokes[i].changed) strokes[i].applyProps();
			}
		}
		
		
		// LINE ACTIONS /////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public static function newLine (smooth:Boolean, type:String, lines:int, weight:Number):Line
		{
			var line:Line;
			
			if (smooth) line = new SmoothLine(type, lines, weight);
			else line = new Line(type, lines, weight);
			
			return line;
		}
		
		public function draw (layer:Layer):void
		{
			//// // Consol.Trace("Line.draw");
			if (length > 1)
			{
				for (var s:int=0; s<strokes.length; s++)
				{
					if (s==0) strokes[s].draw(layer, Stroke.START);
					else if (s==strokes.length-1) strokes[s].draw(layer, Stroke.END);
					else strokes[s].draw(layer, Stroke.MIDDLE);
				}
				newStrokeCount = 0;
			}
			changed = false;
		}
		
		public function drawNew (layer:Layer):void
		{
			if (length > 1)
			{
				for (var s:int=lastStrokeLength-1; s<strokes.length; s++)
				{
					if (s==0) strokes[s].draw(layer, Stroke.START);
					else strokes[s].draw(layer);
				}
			}
			
			newStrokeCount = 0;
		}
		
		public function drawWireframe ():void
		{
			if (edges.length>1)
			{
				var vectors:Sprite = Canvas.GLOBAL_CANVAS.wireframe;
				
				for (var s:int=0; s<strokes.length; s++)
				{
					if (s==0) strokes[s].drawWireframe(Stroke.START);
					else if (s==strokes.length-1) strokes[s].drawWireframe(Stroke.END);
					else strokes[s].drawWireframe(Stroke.MIDDLE);
				}
				
				
				// start edge
				vectors.graphics.moveTo(firstStroke.edge2.a.x, firstStroke.edge2.a.y);
				vectors.graphics.lineTo(firstStroke.edge2.b.x, firstStroke.edge2.b.y);
				// end edge
				vectors.graphics.moveTo(lastStroke.edge1.a.x, lastStroke.edge1.a.y);
				vectors.graphics.lineTo(lastStroke.edge1.b.x, lastStroke.edge1.b.y);
			}
		}
		
		public function subdivide ():void
		{
			if (length>1)
			{
				var edge1:Edge;
				var edge2:Edge;
				var newEdge:Edge;
				var subEdges:Array = [];
				var newEdges:Array = [];
				
				for (var i:int=1; i<length; i++)
				{
					edge1 = edges[i-1];
					edge2 = edges[i];
					newEdge = Edge.interpolate(edge1, edge2, .5);
					subEdges.push(newEdge);
				}
				
				do 
				{
					newEdges.push(edges.shift());
					if (subEdges.length>0) newEdges.push(subEdges.shift());
				} 
				while (edges.length>0)
				
				edges = newEdges;
				
				rebuild();
			}
		}
		
		public function simplify ():void
		{
			if (length>2)
			{
				var newEdges:Array = [];

				//for (var i:int=0; i<length; i++)
				while (edges.length > 2)
				{
					newEdges.push(edges.shift());
					edges.shift().die();
				} 
				//while (edges.length > 2);
				if (edges.length>1) edges.shift().die();
				newEdges.push(edges.shift());
				
				edges = newEdges;
				
				rebuild();
			}
		}
		
		public function applyStyle (style:Style):void
		{
			weight = style.strokeStyle.weight;
			lines = style.strokeStyle.lines;
			type = style.strokeStyle.strokeType;
			for (var i:int=0; i<length; i++)
			{
				edges[i].lines = lines;
				edges[i].applyProps();
			}
			
		}
		
		
		// ADD EDGES, STROKES & DECOS ///////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function addEdge (edge:Edge, lockStart:Boolean=false):void
		{
			edges.push(edge);
			
			// need to also set the deco (if exists) angle delta
			if (edges.length==3 && this is SmoothLine && !lockStart) 
			{
				edges[0].angle = edge.angle;
				edges[1].angle = edge.angle; 
				edges[0].applyProps();
				edges[1].applyProps();
			}
			else if (edges.length==2 && !lockStart) 
			{
				edges[0].angle = edge.angle;
				edges[0].applyProps();
			}

			var stroke:Stroke;
			
			if (length > 2)
			{
				stroke = addStroke([length-1, length-2, length-3])
			}
			else if (length > 1) // for both smooth and straight. because a straight is created before smooth
			{
				stroke = addStroke([length-1, length-2]);
			}
			
			created = ((this is SmoothLine) ? (edges.length>2) : (edges.length>1));
			
			if (stroke != null)
			{
				if (stroke.decoGroup != null) 
				{
					decoCount++;
					//// // Consol.Trace(stroke.decoGroup.loaded);
					if (!stroke.decoGroup.loaded) stroke.decoGroup.addEventListener(Event.COMPLETE, decoCompleteHandler);
					else decoComplete();
				}
				newStrokeCount++; // this is important for when we are still running the brush - but not adding new strokes
				// we'll keep trying to draw. but there wont be any new strokes. this is good.
				lastStrokeLength = strokes.length;
			}
		}
		
		public function addEdgeAt (index:int, pt:Point=null):void
		{
			if (index != lastEdgeIndex)
			{
				/*StateManager.addItem(function(state:Object):void{   var l:LineLayer = state.data.layer; l.line.deleteEdge(null, index+1);   },
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
				
				if (aStrokes.length > 1)
				{
					newStroke = new Stroke(edges[index+1], edges[index], null, type, weight);
					//strokes[aStrokes[0]].edge1 = newEdge;
					strokes[aStrokes[1]].edge2 = newEdge;
				}
				else  // added from the first edge
				{
					newStroke = new Stroke(edges[index+2], edges[index+1], null, type, weight);
					strokes[aStrokes[0]].edge1 = newEdge;
				}
				
				strokes.splice(aStrokes[0]+1, 0, newStroke);
				
				lastStrokeLength = strokes.length;
				
				applyProps();
			}
		}
		
		protected function addStroke (edgeIndices:Array):Stroke
		{
			var stroke:Stroke;
			
			if (length > 3 && this is SmoothLine)
			{
				stroke = new SmoothStroke(edges[edgeIndices[0]], edges[edgeIndices[1]], edges[edgeIndices[2]], type, weight);
				//if (atEnd)
				strokes.push(stroke);
				//else strokes.unshift(stroke);
			}
			else if (length > 2 && !(this is SmoothLine))
			{
				stroke = new Stroke(edges[edgeIndices[0]], edges[edgeIndices[1]], edges[edgeIndices[2]], type, weight);
				strokes.push(stroke);
			}
			else if (length == 2)
			{
				stroke = new Stroke(edges[edgeIndices[0]], edges[edgeIndices[1]], null, type, weight);
				strokes.push(stroke);
			}
			else if (length == 3 && this is SmoothLine)
			{
				strokes[0].die();
				// stroke = // don't do this because then we'll be increasing the newStrokeCount. When this is really just replacing the straight stroke.
				stroke = strokes[0] = new SmoothStroke(edges[edgeIndices[0]], edges[edgeIndices[1]], edges[edgeIndices[2]], type, weight);
			}
			
			return stroke;
		}
		
		public function addEdgeDeco (index:int, decoAsset:DecoAsset, initObj:Settings):void
		{
			//// // Consol.Trace("add deco to edge index: " + index);
			
			invalidateEdgeStrokes(index);
			
			edges[index].addDeco(decoAsset, initObj);
			
			applyProps();
			
			//// // Consol.Trace("Line.addEdgeDeco: " + changed);
		}
		
		
		// REMOVE EDGES /////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function deleteEdges (delEdgeList:Array, indices:Boolean=false):void
		{
			//Consol.globalOutput("delete");
			var edgeIndices:Array;
			if (!indices) edgeIndices = getEdgeIndices(delEdgeList);
			else edgeIndices = delEdgeList.slice();
			
			StateManager.addItem(function(state:Object):void{   var l:LineLayer = LineLayer(state.canvasManager.getLayer(state.activeLayerDepth)); l.line.setXML(state.data.lineXML.toXMLString()); l.setup();   },
								 function(state:Object):void{   var l:LineLayer = LineLayer(state.canvasManager.getLayer(state.activeLayerDepth)); l.line.deleteEdges(state.data.edgeIndices, true); l.setup();   }, 
								 -1, {lineXML:getXML(), edgeIndices:edgeIndices});
			
			if (delEdgeList.length == edges.length) deleteAllEdges();
			else for (var i:int=delEdgeList.length-1; i>=0; i--) if (!indices) deleteEdge(delEdgeList[i]) else deleteEdge(null, delEdgeList[i]);
		}
		
		protected function deleteAllEdges ():void
		{
			die();
		}
		
		public function deleteEdge (edge:Edge=null, i:int=-5):void // all:Boolean=false
		{
			var index:int = (edge==null ? i : getEdgeIndex(edge));
			var aStrokes:Array = invalidateEdgeStrokes(index);
			
			if (length > 1)
			{
				if (aStrokes.length > 1)
				{
					strokes[aStrokes[1]].edge2 = strokes[aStrokes[0]].edge2;
				}
				strokes.splice(aStrokes[0], 1)[0].die();
			}
			
			edges.splice(index, 1)[0].die();
			
			lastStrokeLength = strokes.length;
			applyProps();
		}
		
		public function removeEdgeDecos (indices:Array):void
		{
			var edge:Edge;
			for (var i:int=0; i<indices.length; i++)
			{
				edge = edges[indices[i]];
				if (edge.hasDecos)
				{
					edge.removeDecos();
					edge.decoGroup = null;
				}
			}
			changed = true;
		}
		
		
		// MODIFY EDGES /////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function modifyEdgeColor (index:int, value:Number):void
		{
			edges[index].color = value;
		}
		
		public function modifyEdgeAlpha (index:int, value:Number):void
		{
			edges[index].alpha = value;
		}
		
		public function modifyEdge (index:int, c:Point, a:Point, b:Point):void
		{
			edges[index].transformEdge(c, a, b);
			invalidateEdgeIndex(index);
		}
		
		public function invalidateEdge (edge:Edge):void
		{
			changed = true;
			if (length > 1) invalidateEdgeStrokes(getEdgeIndex(edge));
		}
		
		public function invalidateEdgeIndex (edgeIndex:int):void
		{
			changed = true;
			if (length > 1) invalidateEdgeStrokes(edgeIndex);
		}
		
		protected function invalidateEdgeStrokes (edgeIndex:int):Array
		{
			var aStrokes:Array = getStrokeIndicesUsingEdge(edgeIndex);
			//// // Consol.Trace(aStrokes);
			for (var i:int=0;i<aStrokes.length;i++)
			{
				strokes[aStrokes[i]].changed = true;
			}
			return aStrokes;
		}
		
		protected function getStrokeIndicesUsingEdge(edgeIndex:int):Array // returns array of stroke indices
		{
			var edgeStrokes:Array = [];
			
			if (!(this is SmoothLine))
			{
				if (edgeIndex > 0 && edgeIndex < lastEdgeIndex)
				{
					edgeStrokes = [edgeIndex-1, edgeIndex];
				}
				else if (edgeIndex == 0)
				{
					edgeStrokes.push(0);
				}
				else if (edgeIndex == lastEdgeIndex)
				{
					edgeStrokes.push(edgeIndex-1);			
				}
			}
			else if (this is SmoothLine)
			{
				if (length < 4)
				{
					edgeStrokes = [0];
				}
				else if (edgeIndex > 1 && edgeIndex < (lastEdgeIndex-1))
				{
					edgeStrokes = [edgeIndex-2, edgeIndex-1, edgeIndex];
				}
				else if (edgeIndex == 0)
				{
					edgeStrokes.push(0);
				}
				else if (edgeIndex == lastEdgeIndex)
				{
					edgeStrokes.push(edgeIndex-2);			
				}
				else if (edgeIndex == 1) // second edge
				{
					edgeStrokes = [0, 1];
				}
				else if (edgeIndex == (lastEdgeIndex-1)) // second last edge
				{
					edgeStrokes = [strokes.length-2, strokes.length-1]; //  [strokes.length-2, strokes.length-1]
				}
			}
			return edgeStrokes;
		}
		
		
		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function getSVG ():XML
		{
			
			var group:XML = new XML (<g/>);
			
			
			if (length > 1)
			{
				for (var s:int=0; s<strokes.length; s++)
				{
					if (s==0) group.appendChild(strokes[s].getSVG(Stroke.START));
					else if (s==strokes.length-1) group.appendChild(strokes[s].getSVG(Stroke.END));
					else group.appendChild(strokes[s].getSVG(Stroke.MIDDLE));
				}
			}
			
			
			/*for (var i:int=0;i<strokes.length;i++)
			{
				group.appendChild(strokes[i].getSVG());
			}*/
			
			return group;
			
		}
		
		public function setXML (xml:String):void
		{
			var lineXML:XML = new XML (xml);
			try 
			{   
				die();  
			} 
			catch (e:Error) 
			{   
				// // Consol.Trace("Edge: Die Error");   
			}
			for each (var stroke:XML in lineXML.*) 
			{
				stroke.@lines = Number(lineXML.@lines);
				var newEdge:Edge = Edge.xmlToEdge(stroke.toXMLString());
				addEdge(newEdge, true);
				
			}
			//Consol.globalOutput("LINE: set XML");
		}
		
		public function getXML ():XML
		{
			var lineXML:XML = new XML (<line lines={lines} type={type} smooth={(this is SmoothLine)} weight={weight}/>);

			for (var i:int=0; i<edges.length; i++)
			{
				lineXML.appendChild(edges[i].getXML());
			}
	
			return lineXML;
		}
		
		public function setEdgeXML (index:int, xml:String, setDecos:Boolean=false):void
		{
			//edges[index].die();
			//edges[index] = Edge.xmlToEdge(xml);
			var xmlObj:XML = new XML(xml);
			xmlObj.@lines = lines;
			edges[index].setXMLDecoBool(xmlObj.toXMLString(), setDecos);
			invalidateEdgeIndex(index);
		}
		
		public static function xmlToLine (xml:XML):Line
		{
			var line:Line = Line.newLine(xml.@smooth=="true"?true:false, xml.@type, Number(xml.@lines), Number(xml.@weight));
			line.setXML(xml.toXMLString());
			return line;
		}
		
		protected function decoComplete ():void
		{
			decoLoadCount++;
			if (decoLoadCount == decoCount) lineComplete();
		}
		
		protected function lineComplete ():void
		{
			dispatchEvent (new Event(Event.COMPLETE, true, false));
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected function decoCompleteHandler (e:Event):void
		{
			e.target.removeEventListener(e.type, decoCompleteHandler);
			decoComplete();
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function copy (includeDecos:Boolean=true, basic:Boolean=false):Line
		{
			var newLine:Line;
			if (basic) newLine = new Line (type, 2, 1);
			else newLine = new Line (type, lines, weight);
			
			for (var i:int=0; i<edges.length; i++)
			{
				newLine.addEdge(edges[i].copy(includeDecos, basic), true);
			}
			return newLine;
		}
		
		public function stringType ():String
		{
			return (this is SmoothLine ? SMOOTH_LINE : STRAIGHT_LINE);
		}
		
		protected function getEdgeIndex (edge:Edge):int 
		{
			return edges.indexOf(edge);
			//return edges[edges.indexOf(edge)];
			//return objToIndex(edge, edges);
		}
		
		protected function getEdgeIndices (edgeList:Array=null):Array
		{
			var a:Array = [];
			var i:int=0;
			
			if (edgeList == null)
			{
				for (i=0; i<length; i++)
				{
					a.push(i);
				}
			}
			else 
			{
				for (i=0; i<edgeList.length; i++)
				{
					a.push(getEdgeIndex(edgeList[i]));
				}
			}
			return a;
		}
		
		public static function toStraightLine (line:Line):Line
		{
			return convertLine(line, false);
		}
		
		public static function toSmoothLine (line:Line):SmoothLine
		{
			return SmoothLine(convertLine(line, true));
		}
		
		public static function convertLine (line:Line, smooth:Boolean):Line
		{
			var newLine:Line = Line.newLine(smooth, line.type, line.lines, line.weight);
			for (var i:int=0; i<line.length; i++) newLine.edges.push(line.edges[i].copy());
			newLine.rebuild();
			return newLine;
		}
		
		public static function isSmoothLine (line:Line):Boolean
		{
			return (line is SmoothLine);
		}
		
		
	}
}