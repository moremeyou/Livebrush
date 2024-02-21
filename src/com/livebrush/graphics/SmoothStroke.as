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
	import com.livebrush.graphics.Stroke;
	import com.livebrush.ui.Consol;
	import com.livebrush.graphics.Deco;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.DecoGroup;
	
	public class SmoothStroke extends Stroke
	{
		
		public static const EDGE_NUM					:int = 3;
		
		
		public function SmoothStroke (edge1:Edge, edge2:Edge, edge3:Edge=null, type:String="solid", weight:Number=1)
		{
			super(edge1, edge2, edge3, type, weight);
			
			init();
		}
		
	
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void { }
		
		public override function applyProps ():void
		{
			color = edge1.color;
			alpha = edge1.alpha;
			decoGroup = edge1.decoGroup;
			lines = edge1.lines;
			width = edge1.length;

			startEdge = Edge.interpolate(edge2, edge3, .5);
			endEdge = Edge.interpolate(edge1, edge2, .5);
			ctrlEdge = edge2;
			
			changed = false;
		}
		
		
		// STROKE ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function draw (layer:LineLayer, seg:int=MIDDLE):void
		{
			var decos:Sprite = layer.decos;
			var graphics:Graphics = layer.vectors.graphics;
		
			if (type==StrokeStyle.SOLID_STROKE)
			{
				graphics.beginFill(color, alpha);
				graphics.moveTo(endEdge.a.x, endEdge.a.y);
				graphics.curveTo(ctrlEdge.a.x, ctrlEdge.a.y, startEdge.a.x, startEdge.a.y);
				graphics.lineTo(startEdge.b.x, startEdge.b.y);
				graphics.curveTo(ctrlEdge.b.x, ctrlEdge.b.y, endEdge.b.x, endEdge.b.y);
				
				graphics.endFill();
				graphics.beginFill(color, alpha);
				
				if (seg==START || seg == BOTH) 
				{
					graphics.moveTo(edge3.a.x, edge3.a.y);
					graphics.lineTo(startEdge.a.x, startEdge.a.y);
					graphics.lineTo(startEdge.b.x, startEdge.b.y);
					graphics.lineTo(edge3.b.x, edge3.b.y);
					graphics.lineTo(edge3.a.x, edge3.a.y);
				}
				if (seg==END || seg == BOTH) 
				{
					graphics.moveTo(edge1.a.x, edge1.a.y);
					graphics.lineTo(endEdge.a.x, endEdge.a.y);
					graphics.lineTo(endEdge.b.x, endEdge.b.y);
					graphics.lineTo(edge1.b.x, edge1.b.y);
					graphics.lineTo(edge1.a.x, edge1.a.y);
				}
				
				graphics.endFill();
			}
			else if (type != StrokeStyle.SOLID_STROKE)
			{
				if (type==StrokeStyle.RAKE_STROKE)
				{
					graphics.lineStyle(weight, color, alpha, true, LineScaleMode.NORMAL, CapsStyle.NONE);
					
					for (var i:int=0; i<lines; i++)
					{
						graphics.moveTo(startEdge.points[i].x, startEdge.points[i].y);
						graphics.curveTo(ctrlEdge.points[i].x, ctrlEdge.points[i].y, endEdge.points[i].x, endEdge.points[i].y);
						
						if (seg==START || seg == BOTH) 
						{
							graphics.moveTo(edge3.points[i].x, edge3.points[i].y);
							graphics.lineTo(startEdge.points[i].x, startEdge.points[i].y);
						}
						if (seg==END || seg == BOTH) 
						{
							graphics.moveTo(edge1.points[i].x, edge1.points[i].y);
							graphics.lineTo(endEdge.points[i].x, endEdge.points[i].y);
						}
						
					}
				}
				else if (type==StrokeStyle.PATH_STROKE)
				{
					//// // Consol.Trace("SmoothStroke: draw> " + seg);
					
					graphics.lineStyle(weight, color, alpha, true, LineScaleMode.NORMAL, CapsStyle.NONE);
					
					graphics.moveTo(startEdge.x, startEdge.y);
					graphics.curveTo(ctrlEdge.x, ctrlEdge.y, endEdge.x, endEdge.y);
					
					if (seg==START || seg == BOTH) 
					{
						graphics.moveTo(edge3.x, edge3.y);
						graphics.lineTo(startEdge.x, startEdge.y);
					}
					if (seg==END || seg == BOTH) 
					{
						//// // Consol.Trace("SmoothStroke: draw> " + seg);
						graphics.moveTo(edge1.x, edge1.y);
						graphics.lineTo(endEdge.x, endEdge.y);
					}
				}
			}
			
			drawDeco(decos);
		}
		
		public override function drawWireframe (seg:int=MIDDLE, target:Sprite=null):void
		{
			target = (target==null ? Canvas.GLOBAL_CANVAS.wireframe : target);
			var graphics:Graphics = target.graphics;

			graphics.lineStyle(0, color, 1, true, LineScaleMode.NORMAL, CapsStyle.NONE);
			for (var i:int=0; i<lines; i++)
			{
				if (i == 0 || i == lines-1)
				{
					graphics.moveTo(startEdge.points[i].x, startEdge.points[i].y);
					graphics.curveTo(ctrlEdge.points[i].x, ctrlEdge.points[i].y, endEdge.points[i].x, endEdge.points[i].y);
					
					if (seg==START || seg == BOTH) 
					{
						graphics.moveTo(edge3.points[i].x, edge3.points[i].y);
						graphics.lineTo(startEdge.points[i].x, startEdge.points[i].y);
						
						// end edge
						graphics.moveTo(endEdge.a.x, endEdge.a.y);
						graphics.lineTo(endEdge.b.x, endEdge.b.y);
					}
					if (seg==END || seg == BOTH) 
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
						graphics.moveTo(startEdge.a.x, startEdge.a.y);
						graphics.lineTo(startEdge.b.x, startEdge.b.y);
						// end edge
						graphics.moveTo(endEdge.a.x, endEdge.a.y);
						graphics.lineTo(endEdge.b.x, endEdge.b.y);
					}
				}
			}
		}
		
		public override function invert ():void
		{
			var tempEdge:Edge = edge1;
			edge1 = edge3;
			edge3 = tempEdge;
			
			edge1.invert();
			edge2.invert();
			edge3.invert();
			
			applyProps();
		}
		
		
		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function getSVG (seg:int=MIDDLE):XML
		{
			
			var path:XML = new XML(<g/>);
			
			if (type==StrokeStyle.SOLID_STROKE)
			{
				path.appendChild(new XML (<path fill={colorToHexString()} opacity={alpha} stroke-width={0} stroke={colorToHexString()}
													d={"M"+startEdge.a.x+","+startEdge.a.y+
													  "Q"+ctrlEdge.a.x+","+ctrlEdge.a.y+","+endEdge.a.x+","+endEdge.a.y+
													  "L"+endEdge.b.x+","+endEdge.b.y+
													  "Q"+ctrlEdge.b.x+","+ctrlEdge.b.y+","+startEdge.b.x+","+startEdge.b.y+
													  "z"}  />));
				
				if (seg==START || seg == BOTH) 
				{
					path.appendChild(new XML (<path fill={colorToHexString()} opacity={alpha} stroke-width={0} stroke={colorToHexString()}
														d={"M"+edge3.a.x+","+edge3.a.y+
														   "L"+startEdge.a.x+","+startEdge.a.y+
														   "L"+startEdge.b.x+","+startEdge.b.y+
														   "L"+edge3.b.x+","+edge3.b.y+
														   "z"}  />));
					
				}
				if (seg==END || seg == BOTH) 
				{
					
					path.appendChild(new XML (<path fill={colorToHexString()} opacity={alpha} stroke-width={0} stroke={colorToHexString()}
														d={"M"+edge1.a.x+","+edge1.a.y+
														   "L"+endEdge.a.x+","+endEdge.a.y+
														   "L"+endEdge.b.x+","+endEdge.b.y+
														   "L"+edge1.b.x+","+edge1.b.y+
														   "z"}  />));
				}
				
			}
			else if (type != StrokeStyle.SOLID_STROKE)
			{
				if (type==StrokeStyle.RAKE_STROKE)
				{
					
					path = new XML(<g fill={"none"} opacity={alpha} stroke-width={weight} stroke={colorToHexString()} />);
					
					for (var j:int=0; j<lines; j++)
					{
						path.appendChild(new XML (<path d={"M"+startEdge.points[j].x+","+startEdge.points[j].y+
														   "Q"+ctrlEdge.points[j].x+","+ctrlEdge.points[j].y+","+endEdge.points[j].x+","+endEdge.points[j].y}  />));
						
						if (seg==START || seg == BOTH) 
						{
							path.appendChild(new XML (<path d={"M"+edge3.points[j].x+","+edge3.points[j].y+
														   	   "L"+startEdge.points[j].x+","+startEdge.points[j].y}  />));
							
							
						}
						if (seg==END || seg == BOTH) 
						{
							
							path.appendChild(new XML (<path d={"M"+edge1.points[j].x+","+edge1.points[j].y+
														   	   "L"+endEdge.points[j].x+","+endEdge.points[j].y}  />));
						}
					
					
					}
				}
				else if (type==StrokeStyle.PATH_STROKE)
				{
					path = new XML (<path fill={"none"} opacity={alpha} stroke-width={weight} stroke={colorToHexString()}
										d={"M"+startEdge.x+","+startEdge.y+
										   "Q"+ctrlEdge.x+","+ctrlEdge.y+","+endEdge.x+","+endEdge.y} />);
					
					if (seg==START || seg == BOTH) 
					{
						path.appendChild(new XML (<path d={"M"+edge3.x+","+edge3.y+
														   "L"+startEdge.x+","+startEdge.y}  />));
					}
					if (seg==END || seg == BOTH) 
					{
						path.appendChild(new XML (<path d={"M"+edge1.x+","+edge1.y+
														   "L"+endEdge.x+","+endEdge.y}  />));
					}
					
				}
			}
			
			
			
			
			return path;
			
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////

		
	}
}