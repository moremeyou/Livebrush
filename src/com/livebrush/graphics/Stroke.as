package com.livebrush.graphics
{

	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.EventPhase;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.display.LineScaleMode;
	import flash.display.BlendMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.styles.Style;
	import com.livebrush.data.Storable;
	import com.livebrush.styles.StrokeStyle;
	import com.livebrush.graphics.Edge;
	import com.livebrush.graphics.Line;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.Stroke;
	import com.livebrush.ui.Consol;
	import com.livebrush.graphics.Deco;
	import com.livebrush.graphics.DecoGroup;
	
	import org.casalib.util.ColorUtil;
	
	
	public class Stroke
	{
		public static const EDGE_NUM			:int = 2;
		public static const START				:int = 0;
		public static const MIDDLE				:int = 1;
		public static const END					:int = 2;
		public static const BOTH				:int = 3;
		
		protected var line						:Line;
		public var startEdge					:Edge; 
		public var endEdge						:Edge;
		public var ctrlEdge						:Edge;
		public var lines						:int;
		public var weight						:Number;
		public var width						:Number;
		public var type							:String;
		public var color						:uint = 0;
		public var alpha						:Number = 0;
		public var decoGroup					:DecoGroup;
		public var edgeIndices					:Array;
		public var changed						:Boolean = false;
		private var _edge1						:Edge;
		private var _edge2 						:Edge;
		private var _edge3						:Edge;
		
		public function Stroke (edge1:Edge, edge2:Edge, edge3:Edge=null, type:String="solid", weight:Number=1)
		{
			this.line = line;
			this.edgeIndices = edgeIndices;
			this.type = type;
			this.weight = weight;
			
			this.edge1 = edge1;
			this.edge2 = edge2;
			this.edge3 = edge3;
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get edge1 ():Edge {   return _edge1;   }
		public function get edge2 ():Edge {   return _edge2;   }
		public function get edge3 ():Edge {   return _edge3;   }
		public function set edge1 (e:Edge):void {   _edge1 = e; changed = true;   }
		public function set edge2 (e:Edge):void {   _edge2 = e; changed = true;   }
		public function set edge3 (e:Edge):void {   _edge3 = e; changed = true;   }
		public function get masterEdge ():Edge {   return endEdge;   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			applyProps();
		}
		
		public function die ():void
		{
			//killDecos(); or is it done elsewhere?
		}
		
		public function applyProps ():void
		{
			color = edge1.color;
			alpha = edge1.alpha;
			decoGroup = edge1.decoGroup;
			lines = edge1.lines;
			width = edge1.length;

			startEdge = edge2;
			endEdge = edge1;
			ctrlEdge = startEdge;
			
			changed = false;
		}
		
		
		// STROKE ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function draw (layer:LineLayer, seg:int=MIDDLE):void
		{
			var decos:Sprite = layer.decos;
				var graphics:Graphics = layer.vectors.graphics;
			
				if (type==StrokeStyle.SOLID_STROKE)
				{
					graphics.beginFill(color, alpha);
					graphics.moveTo(startEdge.b.x, startEdge.b.y);
					graphics.lineTo(startEdge.a.x, startEdge.a.y);
					graphics.lineTo(endEdge.a.x, endEdge.a.y);
					graphics.lineTo(endEdge.b.x, endEdge.b.y);
					graphics.lineTo(startEdge.b.x, startEdge.b.y);
					graphics.endFill();
				}
				else if (type != StrokeStyle.SOLID_STROKE)
				{
					if (type==StrokeStyle.RAKE_STROKE)
					{
						graphics.lineStyle(weight, color, alpha, true, LineScaleMode.NORMAL, CapsStyle.NONE);
						for (var j:int=0; j<lines; j++)
						{
							graphics.moveTo(startEdge.points[j].x, startEdge.points[j].y);
							graphics.lineTo(endEdge.points[j].x, endEdge.points[j].y);
						}
					}
					else if (type==StrokeStyle.PATH_STROKE)
					{
						graphics.lineStyle(weight,color, alpha, true, LineScaleMode.NORMAL, CapsStyle.NONE);
						graphics.moveTo(startEdge.x, startEdge.y);
						graphics.lineTo(endEdge.x, endEdge.y);
					}
				}
				
				drawDeco(decos);
		}
	
		public function drawWireframe (seg:int=MIDDLE, target:Sprite=null):void
		{
			target = (target==null ? Canvas.GLOBAL_CANVAS.wireframe : target);
			var graphics:Graphics = target.graphics;

			graphics.lineStyle(0, color, 1, true, LineScaleMode.NORMAL, CapsStyle.NONE);
			
			for (var i:int=0; i<lines; i++)
			{
				if (i == 0 || i == lines-1)
				{
					graphics.moveTo(startEdge.points[i].x, startEdge.points[i].y);
					graphics.lineTo(endEdge.points[i].x, endEdge.points[i].y);
					
					if (seg==START) 
					{
						graphics.moveTo(edge2.points[i].x, edge2.points[i].y);
						graphics.lineTo(startEdge.points[i].x, startEdge.points[i].y);
						
						// end edge
						graphics.moveTo(endEdge.a.x, endEdge.a.y);
						graphics.lineTo(endEdge.b.x, endEdge.b.y);
					}
					else if (seg==END) 
					{
						graphics.moveTo(edge1.points[i].x, edge1.points[i].y);
						graphics.lineTo(endEdge.points[i].x, endEdge.points[i].y);
						
						// start edge
						graphics.moveTo(startEdge.a.x, startEdge.a.y);
						graphics.lineTo(startEdge.b.x, startEdge.b.y);
					}
					else
					{
						// start edge
						//graphics.moveTo(startEdge.a.x, startEdge.a.y);
						//graphics.lineTo(startEdge.b.x, startEdge.b.y);
						// end edge
						graphics.moveTo(endEdge.a.x, endEdge.a.y);
						graphics.lineTo(endEdge.b.x, endEdge.b.y);
					}
					
				}
			}
		}
		
		public function drawDeco (decos:Sprite):void
		{
			if (decoGroup != null)
			{
				for (var d:int=0; d<decoGroup.length; d++)
				{
					var deco:Deco = decoGroup.getDeco(d);
					var offset:Object = deco.offset;
					//// // Consol.Trace("offset: " + deco.offset.x + " : " + deco.offset.y);
					deco.angle += edge1.deltaAngle;
					
					// for smoothed strokes. the angle will always be off. because we're positioning 
					// it at the smoothed edge. but using the edge1 angle
					// this should be solved if we make it so the actual ctrl pt makes the line go through our edge width pts
					// don't worry about it for now
					
					var midPoint:Point = masterEdge.midPoint(deco.pos);
					
					deco.x = midPoint.x;
					deco.y = midPoint.y;
					
					var offPt:Object = {x:midPoint.x+offset.x, y:midPoint.y+offset.y};

					if ((offset.x != 0 || offset.y != 0) && edge1.deltaAngleRads != 0)
					{
						var radians:Number = edge1.deltaAngleRads; //n * Math.PI / 180; //ConversionUtil.degreesToRadians(angle);
						var baseX:Number   = offPt.x - midPoint.x;
						var baseY:Number   = offPt.y - midPoint.y;
						
						offPt.x = (Math.cos(radians) * baseX) - (Math.sin(radians) * baseY) + midPoint.x;
						offPt.y = (Math.sin(radians) * baseX) + (Math.cos(radians) * baseY) + midPoint.y;
						
						/*if (this is SmoothStroke)
						{
							offPt.x += (masterEdge.c.x-edge1.c.x);
							offPt.y += (masterEdge.c.y-edge1.c.y);
						}*/
					}
					
					offset.x = (offPt.x-midPoint.x);
					offset.y = (offPt.y-midPoint.y);
					
					deco.x += offset.x;
					deco.y += offset.y;
					
					deco.draw(decos);
				}
			}
			edge1.deltaAngleRads = 0;
		}
		
		public function dieDecos ():void
		{
			if (decoGroup != null)
			{
				while (decoGroup.length > 0)
				{
					decoGroup.removeDecoIndex(0);
				}
				
				decoGroup = null;
			}
		}
		
		public function invert ():void
		{
			var tempEdge:Edge = edge1;
			edge1 = edge2;
			edge2 = tempEdge;
			
			edge1.invert();
			edge2.invert();
			
			applyProps();
		}
		
		
		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function getSVG (seg:int=MIDDLE):XML
		{
			
			var path:XML = new XML();
			
			if (type==StrokeStyle.SOLID_STROKE)
			{
				
								  
				path = new XML (<path fill={colorToHexString()} opacity={alpha} stroke-width={0} stroke={colorToHexString()}
								d={"M"+startEdge.a.x+","+startEdge.a.y+
								"L"+endEdge.a.x+","+endEdge.a.y+
								"L"+endEdge.b.x+","+endEdge.b.y+
								"L"+startEdge.b.x+","+startEdge.b.y+
								"z"}  />);
			}
			else if (type != StrokeStyle.SOLID_STROKE)
			{
				if (type==StrokeStyle.RAKE_STROKE)
				{
					path = new XML(<g fill={"none"} opacity={alpha} stroke-width={weight} stroke={colorToHexString()} />);
					for (var j:int=0; j<lines; j++)
					{
						path.appendChild(new XML (<path d={"M"+startEdge.points[j].x+","+startEdge.points[j].y+
														   "L"+endEdge.points[j].x+","+endEdge.points[j].y}  />));
						
					}
				}
				else if (type==StrokeStyle.PATH_STROKE)
				{
					path = new XML (<path fill={"none"} opacity={alpha} stroke-width={weight} stroke={colorToHexString()}
										d={"M"+startEdge.x+","+startEdge.y+
										"L"+endEdge.x+","+endEdge.y} />);
				}
			}
			
			
			
			
			return path;
			
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected function colorToHexString ():String
		{
			var rgb:Object = ColorUtil.getRGB(color);
			return "#"+ColorUtil.getHexStringFromRGB(rgb.r, rgb.g, rgb.b);
		}
		
		/*protected function getSVGBox (x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number, x4:Number, y4:Number):XML
		{
			var path:XML = new XML (<path fill={colorToHexString()} opacity={alpha} stroke-width={weight} stroke={colorToHexString()}
									d={"M"+startEdge.a.x+","+startEdge.a.y+
									  "Q"+ctrlEdge.a.x+","+ctrlEdge.a.y+","+endEdge.a.x+","+endEdge.a.y+
									  "L"+endEdge.b.x+","+endEdge.b.y+
									  "Q"+ctrlEdge.b.x+","+ctrlEdge.b.y+","+startEdge.b.x+","+startEdge.b.y+
									  "z"}  />);
			
			return path;
		}
		
		protected function getSVGCurve (x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number, x4:Number, y4:Number, x5:Number, y5:Number, x6:Number, y6:Number):XML
		{
		}*/

	}
}