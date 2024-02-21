package com.livebrush.graphics
{

	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.EventPhase;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.events.EventDispatcher;
	import com.livebrush.data.Settings;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.styles.DecoAsset;
	import com.livebrush.data.Storable;
	import com.livebrush.graphics.Stroke;
	import com.livebrush.styles.Style;
	import com.livebrush.graphics.Deco;
	import com.livebrush.graphics.DecoGroup;
	import com.livebrush.transform.SyncPoint;
	
	import com.livebrush.ui.Consol;
	
	public class Edge extends EventDispatcher implements Storable
	{
		public var deltaAngleRads				:Number = 0;
		public var points						:Array;
		public var centerPt						:Point;
		private var _angleRads					:Number;
		public var length						:Number;
		public var lines						:int;
		public var color						:uint;
		public var alpha						:Number;
		public var decoGroup					:DecoGroup;
		public var lineIndex					:int;
		
		public function Edge (x:Number, y:Number, length:Number, angle:Number, lines:int=2, color:uint=0xFFFFFF, alpha:Number=1, decoGroup:DecoGroup=null)
		{
			points = [];
			centerPt = new Point (x, y);
			this.length = length;
			this.angle = angle;
			this.lines = lines;
			//trace("Edge Width: " + length)
			this.color = color;
			this.alpha = alpha;
			this.decoGroup = decoGroup;
			
			init();
		}

		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get pos ():Point {   return  centerPt;   }
		public function set pos (pt:Point):void {   x=pt.x; y=pt.y;   }
		public function set x (n:Number):void {  centerPt.x = n;   }
		public function get x ():Number {   return  centerPt.x;   }
		public function set y (n:Number):void {  centerPt.y = n;   }
		public function get y ():Number {   return  centerPt.y;   }
		public function get c ():Point {   return  centerPt;   }
		public function get a ():Point {   return  points[0];   }
		public function get b ():Point {   return  points[points.length-1];   }
		public function set angle (n:Number):void {   angleRads = n * Math.PI / 180;   }
		public function get angle ():Number {   return angleRads * 180 / Math.PI;   }
		public function set angleRads (n:Number):void {   _angleRads = n;   } 
		public function get angleRads ():Number {   return _angleRads;   }
		public function set width (n:Number):void {   length = n;   }
		public function get width ():Number {   return length;   }
		public function get deltaAngle ():Number {   return deltaAngleRads * 180 / Math.PI;   }
		public function get hasDecos ():Boolean {   return decoGroup!=null;   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			applyProps();
		}
		
		public function die ():void 
		{
		}
		
		public function applyProps ():void
		{
			points = [];
		
			var halfWidth:Number = length / 2;
			//trace("Edge Width: " + length)
			
			var t:Number = Math.PI/2;
			
			var widthPt1:Point = centerPt.clone();
			widthPt1.offset (
							   (halfWidth * Math.cos(angleRads - t)),
							   (halfWidth * Math.sin(angleRads - t))
							);
			
			var widthPt2:Point = centerPt.clone();
			widthPt2.offset (
							   (halfWidth * Math.cos(angleRads + t)),
							   (halfWidth * Math.sin(angleRads + t))
							);
			
			var lineFraction:Number
			var divPt:Point;
			var i:int;
			
			for (i=0; i<Math.max(2,lines); i++)
			{
				// Determine a point between the two offset width points
				lineFraction = i/(Math.max(2,lines)-1);
				lineFraction = isNaN(lineFraction) ? 0 : lineFraction; 
				divPt = Point.interpolate (widthPt1, widthPt2, lineFraction); // flip the two points if other order is needed
				points.push(divPt);
			}
			//trace(points);
		}
		
		
		// EDGE ACTIONS /////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function addDeco (decoAsset:DecoAsset, initObj:Settings):void
		{
			if (decoGroup == null) decoGroup = new DecoGroup();
			//// // Consol.Trace("add deco to edge: " + decoAsset);
			decoGroup.addDeco(decoAsset, initObj);
		}
		
		public function removeDecos ():void
		{
			if (decoGroup != null) decoGroup.removeAllDecos();
		}
		
		public function modify (c:Point, angleRads:Number, width:Number, fromScope:DisplayObjectContainer=null):void
		{
			modifyEdge(c, angleRads, width, fromScope);
		}
		
		public function modifyEdge (c:Point, angleRads:Number, width:Number, fromScope:DisplayObjectContainer=null):void
		{
			fromScope = fromScope!=null ? fromScope : Canvas.GLOBAL_CANVAS.comp;
			
			c = SyncPoint.localToLocal(c, fromScope, Canvas.GLOBAL_CANVAS.comp);
			
			pos = c;
			this.width = width;
			deltaAngleRads = angleRads - this.angleRads;
			this.angleRads = angleRads;
			applyProps();
		}
		
		public function transformEdge (c:Point, a:Point, b:Point):void
		{
			//trace(c + " : " + a + " : " + b);
			var xDist:Number = b.x - a.x;
			var yDist:Number = b.y - a.y;
			var angleRads:Number = Math.atan2(yDist, xDist) + Math.PI/2;

			pos = c;
			this.width = Point.distance(a, b);
			deltaAngleRads += (angleRads - this.angleRads);
			this.angleRads = angleRads;
			applyProps();
		}


		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public static function xmlToEdge (xml:String):Edge
		{
			var edgeXML:XML = new XML (xml);
			var edge:Edge = new Edge (Number(edgeXML.@x), Number(edgeXML.@y), Number(edgeXML.@width), Number(edgeXML.@angle), Number(edgeXML.@lines), Number(edgeXML.@color), Number(edgeXML.@alpha)); // Deco.xmlToDeco(edgeXML.deco.toString()
			if (edgeXML.@decorate=="true") 
			{
				var decoGroup:DecoGroup = new DecoGroup ();
				
				for each (var deco:XML in edgeXML.*) 
				{
					decoGroup.addDecoObj(Deco.xmlToDeco(deco.toXMLString()));
				}
				
				edge.decoGroup = decoGroup;
			}
			
			return edge;
		}
		
		public function setXML (xml:String):void 
		{
			var edgeXML:XML = new XML (xml);
			//var newEdge:Edge = xmlToEdge(xml);
			//var edge:Edge = new Edge (Number(edgeXML.@x), Number(edgeXML.@y), Number(edgeXML.@width), Number(edgeXML.@angle), Number(edgeXML.@lines), Number(edgeXML.@color), Number(edgeXML.@alpha));
			//Edge (x:Number, y:Number, length:Number, angle:Number, lines:int=2, color:uint=0xFFFFFF, alpha:Number=1, decoGroup:DecoGroup=null)
			
			
			centerPt = new Point(Number(edgeXML.@x), Number(edgeXML.@y));
			length = edgeXML.@width;
			angle = edgeXML.@angle;
			lines = edgeXML.@lines;
			color = edgeXML.@color;
			alpha = edgeXML.@alpha;
			
			decoGroup.removeAllDecos();
			
			if (edgeXML.@decorate=="true") 
			{
				for each (var deco:XML in edgeXML.*) 
				{
					decoGroup.addDecoObj(Deco.xmlToDeco(deco.toXMLString()));
				}
			}
			
			applyProps();
		}
		
		public function setXMLDecoBool (xml:String, setDecoGroup:Boolean=false):void
		{
			var edgeXML:XML = new XML (xml);
			//// // Consol.Trace(xml);
			centerPt = new Point(Number(edgeXML.@x), Number(edgeXML.@y));
			length = Number(edgeXML.@width);
			angle = Number(edgeXML.@angle);
			lines = Number(edgeXML.@lines);
			color = uint(edgeXML.@color);
			alpha = Number(edgeXML.@alpha);
			
			
			
			if (setDecoGroup)
			{
				if (decoGroup != null) decoGroup.removeAllDecos();
				else decoGroup = new DecoGroup();
				
				if (edgeXML.@decorate=="true") 
				{
					for each (var deco:XML in edgeXML.*) 
					{
						decoGroup.addDecoObj(Deco.xmlToDeco(deco.toXMLString()));
					}
				}
			}
			
			applyProps();
		}
		
		public function getXML ():XML
		{
			
			var edgeXML:XML = new XML (<stroke x={x} y={y} width={length} color={color} alpha={alpha} angle={angle} decorate={hasDecos} />);
			//Consol.globalOutput((deco) + " : " + hasDecos);
			if (hasDecos) 
			{
				for (var i:int=0; i<decoGroup.length; i++)
				{
					edgeXML.appendChild(decoGroup.getDeco(i).getXML());
				}
			}
			return edgeXML;
			
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function copy (includeDecos:Boolean=true, basic:Boolean=false):Edge
		{
			var newEdge:Edge;
			if (basic) newEdge = new Edge (centerPt.x, centerPt.y, length, angle, 2, color, 1, (decoGroup!=null && includeDecos)?decoGroup.copy():null);
			else newEdge = new Edge (centerPt.x, centerPt.y, length, angle, lines, color, alpha, (decoGroup!=null && includeDecos)?decoGroup.copy():null);
			return newEdge;
		}
		
		// decoGroups aren't included in the interpolation. maybe make this a param.
		static public function interpolate (edge1:Edge, edge2:Edge, f:Number):Edge
		{
			var iPt:Point = Point.interpolate(edge1.centerPt, edge2.centerPt, f);
			
			var edge:Edge = new Edge (iPt.x, iPt.y, (edge1.length+edge2.length)*f, (edge1.angle+edge2.angle)*f, edge1.lines, edge1.color, edge1.alpha, null); // edge1.decoGroup// (edge1.angle+edge2.angle)*f
			
			var points:Array = [];
			for (var i:int=0; i<edge1.lines; i++)
			{
				points.push(Point.interpolate(edge1.points[i], edge2.points[i], f));
			}
			edge.points = points;
			
			return edge;
		}

		public function invert ():void
		{
			var b:uint = angleRads;
			
			angleRads += Math.PI;
			
			//// // Consol.Trace(b + " : " + angleRads);
			
			applyProps();
		}
		
		public function midPoint (pos:Number):Point
		{
			return Point.interpolate(a, b, pos);
		}
		
		public override function toString ():String
		{
			return "Edge: x=" + x + ", y=" + y + ", length=" + length + ", angle=" + angle;
		}
		
		
		// TBD / DEBUG //////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*public function draw (gfx:Graphics):void
		{
			gfx.clear();
			gfx.lineStyle(1, 0xFF0000, 1);
			gfx.moveTo(a.x, a.y);
			gfx.lineTo(b.x, b.y);
		}*/
		
		
		// LEGACY ///////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*public function transformEdge (c:Point, a:Point, b:Point, fromScope:DisplayObjectContainer=null, basic:Boolean=false):void
		{
			fromScope = fromScope!=null ? fromScope : Canvas.GLOBAL_CANVAS;
			
			a = SyncPoint.localToLocal(a, fromScope, Canvas.GLOBAL_CANVAS.comp);
			b = SyncPoint.localToLocal(b, fromScope, Canvas.GLOBAL_CANVAS.comp);
			
			var xDist:Number = b.x - a.x;
			var yDist:Number = b.y - a.y;
			var angleRads:Number = Math.atan2(yDist, xDist) + Math.PI/2;

			modifyEdge(c, angleRads, Point.distance(a, b), fromScope, basic);
		}*/
		
	}
}