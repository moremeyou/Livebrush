package com.livebrush.graphics.canvas
{
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.utils.setTimeout;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject
	import flash.display.PixelSnapping;
	import flash.geom.ColorTransform;
	import flash.geom.Transform;
	import flash.events.IOErrorEvent;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.filters.BlurFilter;
	import flash.utils.getTimer;
	import flash.display.Loader;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import com.livebrush.geom.ColorMatrix;
	import com.livebrush.data.Exchangeable;
	import com.livebrush.data.Settings;
	import com.livebrush.data.Storable;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.canvas.ColorLayer;
	import com.livebrush.graphics.canvas.BackgroundLayer;
	import com.livebrush.graphics.canvas.ImageLayer;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.graphics.canvas.BitmapLayer;
	import com.livebrush.graphics.canvas.SWFLayer;
	import com.livebrush.graphics.Line;
	//import com.livebrush.graphics.BitmapSprite;
	import com.livebrush.data.FileManager;
	import com.livebrush.data.GlobalSettings;
	import com.livebrush.ui.LayerThumb;
	import flash.text.TextField;
	import com.livebrush.ui.Consol;
	
	//import com.quasimondo.geom.ColorMatrix;
	import org.casalib.util.ColorUtil;
	import org.casalib.math.Percent;
	
	
	public class Layer extends EventDispatcher implements Storable
	{
	
		public static var BACKGROUND			:String = "background";
		public static var BITMAP				:String = "bitmap";
		public static var LINE					:String = "line";
		public static var IMAGE					:String = "image";
		public static var SWF					:String = "swf";
		public static var COLOR					:String = "color";
		public static var MASK					:String = "mask";
		
		public static var LAYER_COUNT			:Number = 0;
	
		protected var _type						:String;
		protected var loader					:Loader;
		public var initProps					:Object;
		public var label						:String = "New Layer";
		protected var graphics					:Sprite; // refers the reference in the canvas Sprite. the layer parent
		public var solid						:Bitmap = null; // the color-fill or image 
		private var _alpha						:Number = 1;
		public var canvas						:Canvas;
		private var ctf							:ColorTransform;
		public var changed						:Boolean = false;
		protected var compFileName				:String = null;
		public var loaded						:Boolean = false;
		public var layerXML						:XML = null;
		protected var _color					:Number = -1;
		protected var _colorPercent				:Number = 0;
		protected var _cached					:Boolean = false;
		protected var _thumb					:BitmapData;
		//protected var qM
		private var _enabled					:Boolean = true;
		private var _linkedDepths				:Array;
		
		
		public function Layer (canvas:Canvas, depth:int=0):void
		{
			this.canvas = canvas;
			LAYER_COUNT++;
			cached = false;
			graphics = canvas.getNewLayer();
			ctf = new ColorTransform();
			if (depth != 0) this.depth = depth;
			_linkedDepths = [];
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get isLinked ():Boolean {   return (_linkedDepths.length>0);   }
		public function set linkedDepths (a:Array):void {   _linkedDepths=a.slice();   }
		public function get linkedDepths ():Array {   return _linkedDepths;   }
		public function get parent ():Sprite {   return graphics.parent as Sprite    } // the canvas layer holder		
		public function set depth (n:int):void {   parent.setChildIndex(graphics, Math.min(parent.numChildren-1, n));   }
		public function get depth ():int {    return parent.getChildIndex(graphics);    }
		public function set alpha (n:Number):void {	_alpha=n; graphics.alpha = n;   }
		public function get alpha ():Number {    return _alpha; }//graphics.alpha;   }
		public function set color (n:Number):void {	_color = n; setColor();   }
		public function get color ():Number {    return _color;    }
		public function get hexColor ():uint {   return ctf.color;   }
		public function set colorPercent (n:Number):void {	_colorPercent = n; setColor();   }
		public function get colorPercent ():Number {    return _colorPercent;    }
		public function set blendMode (s:String):void {	graphics.blendMode = s;   }
		public function get blendMode ():String {    return graphics.blendMode;    }
		public function set width (s:Number):void {	graphics.width = s;   }
		public function get width ():Number {    return graphics.width;    }
		public function get content ():Sprite {    return graphics;    }
		public function get rect ():Rectangle {    return graphics.getBounds(canvas);    }
		public function set height (s:Number):void {	graphics.height = s;   }
		public function get height ():Number {    return graphics.height;    }
		public function set scaleX (s:Number):void {	graphics.scaleX = s;   }
		public function get scaleX ():Number {    return graphics.scaleX;    }
		public function set scaleY (s:Number):void {	graphics.scaleY = s;   }
		public function get scaleY ():Number {    return graphics.scaleY;    }
		public function set rotation (r:Number):void {	graphics.rotation = r;   }
		public function get rotation ():Number {    return graphics.rotation;    }
		public function set x (x:Number):void {	graphics.x = x;   }
		public function get x ():Number {    return graphics.x;    }
		public function set y (y:Number):void {	graphics.y = y;   }
		public function get y ():Number {    return graphics.y;    }
		public function set enabled (b:Boolean):void {	 _enabled = b; visible=visible;   }
		public function get enabled ():Boolean {    return _enabled;    }
		public function set visible (b:Boolean):void {	 graphics.visible = (enabled ? b : false);   }
		public function get visible ():Boolean {    return graphics.visible;    }
		public function get canvasManager ():CanvasManager {   return canvas.canvasManager;   }
		public function get transform ():Transform {   return graphics.transform;   }
		public function get transformMatrixString ():String {   var m:Matrix=transform.matrix; return (m.a + "," + m.b + "," + m.c + "," + m.d + "," + m.tx + "," + m.ty);   }
		public function set transform (t:Transform):void {   graphics.transform = t;   }
		
		//public function get stringType ():String {   return layerXML.@type;   }
		public function get stringType ():String {   return _type;   }
		
		public function get cached ():Boolean {   return _cached;   }
		public function set cached (b:Boolean):void {   _cached=b;   }
		public function get boundingBox ():Rectangle {   return graphics.getRect(Canvas.GRAPHIC_REPS);   }
		public function get centerX ():Number {   return (x + (width/2));   }
		public function get centerY ():Number {   return (y + (height/2));   }
		public function get centerPt ():Point {   return new Point(centerX, centerY);   }
		public function get pos ():Point {   return new Point(x, y);   }
		public function get thumb ():BitmapData {   return _thumb;   }
		public function get abstract ():Boolean {   return (graphics.stage == null);   }
		
		
		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			_thumb = new BitmapData(30, 30, false, 0xFFFFFF);
		}
		
		public function die ():void
		{
			if (solid != null) clearSolid(false);
			
			layerXML = null;
			
			parent.removeChildAt(depth);
		}

		public function setup ():void
		{
			applyInitProps();
		}
		
		public function toggleAbstract ():void
		{
			if (abstract) canvas.layers.addChild(graphics);
			else canvas.layers.removeChild(graphics);
		}
		
		
		// LAYER ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function copy ():Layer
		{
			var newLayer:Layer = new Layer(canvas);
			return newLayer;
		}

		protected function setColor ():void
		{
			//// // Consol.Trace(_color);
			if (_color != -1)
			{
				var _alpha:Number = graphics.alpha;
				var newCTF:ColorTransform = new ColorTransform();
				newCTF.color = _color//uint("0x"+_color); //hexColor;
				ctf = graphics.transform.colorTransform = ColorUtil.interpolateColor(new ColorTransform(), newCTF, new Percent(colorPercent));
				graphics.alpha = _alpha;
			}
		}
		
		public function updateDisplay (cacheGraphics:Boolean=true):void
		{
			generateThumb();
		}
		
		public function resetTransform (_scale:Boolean=true, _rotation:Boolean=true, _skew:Boolean=true):void
		{
			//var pt:Point = new Point(x, y);
			var pt1:Point = centerPt;
			
			if (_scale && _rotation && _skew)
			{
				transform.matrix = new Matrix();
			}
			else
			{
				if (_scale)
				{
					scaleX = scaleY = 1;
				}
				if (_rotation)
				{
					rotation = 0;
				}
				if (_skew)
				{
					var scale:Object = {x:scaleX, y:scaleY};
					var rot:Number = rotation;
					
					transform.matrix = new Matrix();
					
					scaleX = scale.x;
					scaleY = scale.y;
					rotation = rot;
				}
			}
			
			var pt2:Point = centerPt.subtract(pt1);
			
			x -= pt2.x;
			y -= pt2.y;
				
		}
		
		
		// STATIC LAYER CREATION ////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public static function newImageLayer (canvas:Canvas, src:String, initProps:Object=null):ImageLayer
		{
			var layer:ImageLayer = new ImageLayer(canvas);
			layer.src = src;
			layer.depth = layer.canvasManager.activeLayerDepth+1;
			layer.label = src;
			layer.changed = true;
			layer.initProps = initProps;
			//layer.loaded = true;
			
			layer.setup();
			return layer;
		}
		
		public static function newSWFLayer (canvas:Canvas, src:String, initProps:Object=null):SWFLayer
		{
			var layer:SWFLayer = new SWFLayer(canvas);
			layer.src = src;
			layer.depth = layer.canvasManager.activeLayerDepth+1;
			layer.label = src;
			layer.changed = true;
			layer.initProps = initProps;
			//layer.loaded = true;
			
			layer.setup();
			return layer;
		}
		
		public static function newLineLayer (canvas:Canvas=null, depth:int=0):LineLayer
		{
			canvas = canvas==null ? Canvas.GLOBAL_CANVAS : canvas;
			
			var layer:LineLayer = new LineLayer(canvas);
			layer.depth = depth != 0 ? depth : layer.canvasManager.activeLayerDepth+1;
			layer.label = "Line Layer ("+LAYER_COUNT+")";
			layer.changed = true;
			layer.loaded = true;
			return layer;
		}
		
		public static function newBitmapLayer (canvas:Canvas=null, depth:int=0):BitmapLayer
		{
			canvas = canvas==null ? Canvas.GLOBAL_CANVAS : canvas;
			
			var layer:BitmapLayer = new BitmapLayer(canvas);
			layer.depth = depth != 0 ? depth : layer.canvasManager.activeLayerDepth+1;
			layer.label = "Bitmap Layer ("+LAYER_COUNT+")";
			layer.changed = true;
			layer.loaded = true;
			return layer;
		}
		

		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function setXML (xml:String):void
		{
			cached = false;
			
			layerXML = new XML (xml);
			
			label = layerXML.@label;
			alpha = Number(layerXML.@alpha);
			//// // Consol.Trace(layerXML.@blendMode)
			blendMode = layerXML.@blendMode;
			
			var initSettings:Settings = new Settings();
			initSettings.x = Number(layerXML.@x);
			initSettings.y = Number(layerXML.@y);
			initSettings.rotation = Number(layerXML.@rotation);
			initSettings.scaleX = Number(layerXML.@scaleX);
			initSettings.scaleY = Number(layerXML.@scaleY);
			initSettings.alpha = Number(layerXML.@alpha);
			try {   initSettings.enabled = (layerXML.@enabled=="false"?false:true);   } catch(e:Error) {}
			//// // Consol.Trace(layerXML.@matrix);
			if (layerXML.@matrix.length()>0) initSettings.matrix = String(layerXML.@matrix);
			else initSettings.matrix = null;
			initSettings.color = Number(layerXML.@color),
			initSettings.colorPercent = Number(layerXML.@colorPercent);
			//if (this is ImageLayer) // // Consol.Trace(initSettings.matrix);
			setInitProps(initSettings);
			
			/*initProps = {x:Number(layerXML.@x),
						 y:Number(layerXML.@y),
						 rotation:Number(layerXML.@rotation),
						 scaleX:Number(layerXML.@scaleX),
						 scaleY:Number(layerXML.@scaleY),
						 alpha:Number(layerXML.@alpha)}//,
						 //// // Consol.Trace(layerXML.attributes.toString().indexOf("color") > -1);
						 if (!attributeExists("color", layerXML.attributes))
						 {
						 	//// // Consol.Trace("layerXML.@color = null");
							initProps.color = -1,
						 	initProps.colorPercent = 0;
						 }
						 else
						 {
						 	//// // Consol.Trace("layerXML.@color = " + Number(layerXML.@color));
							initProps.color = Number(layerXML.@color),
						 	initProps.colorPercent = Number(layerXML.@colorPercent);
						 }*/
							
		}
	
		public function getXML ():XML
		{
			var newLayerXML:XML = new XML ();
			return newLayerXML;
		}
		
		public function setTransformXML (xml:String):void
		{
			setXML(xml);
			//src = layerXML.solid.@src;
			if (initProps != null) applyInitProps();
		}
		
		protected function setInitProps (settings:Settings=null):void
		{
			if (settings != null) 
			{
				initProps = Settings.copyObject(settings);
			}
			else
			{
				initProps = {x:x,
							 y:y,
							 rotation:rotation,
							 scaleX:scaleX,
							 scaleY:scaleY,
							 alpha:alpha,
							 matrix:transformMatrixString,
				 			 color:color,
							 colorPercent:colorPercent,
							 enabled:enabled};
			}
		}
		
		protected function applyInitProps ():void
		{
			x = initProps.x;
			y = initProps.y;
			rotation = initProps.rotation;
			scaleX = initProps.scaleX;
			scaleY = initProps.scaleY;
			if (initProps.matrix != null) transform.matrix = stringToMatrix(initProps.matrix);
			alpha = initProps.alpha;
			color = initProps.color;
			colorPercent = initProps.colorPercent;
			enabled = initProps.enabled;
			setColor();
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public static function createBackgroundLayer ():BackgroundLayer
		{
			return new BackgroundLayer(Canvas.GLOBAL_CANVAS);
		}
		
		public function generateThumb ():void
		{
			try 
			{
				var mat:Matrix = new Matrix(); // transform.matrix; //
				var scaleX:Number;// = 30/solid.width; //width;
				var scaleY:Number;// = 30/solid.height; //Canvas.HEIGHT;
				scaleX = 30/solid.width;
				scaleY = 30/solid.height;
				//var rect:Rectangle = solid.bitmapData.getColorBoundsRect(0xFF000000, 0x00000000);
				mat.scale(scaleX, scaleY);
				_thumb.draw(canvasManager.emptyThumb);
				
				//var rect:Rectangle = solid.bitmapData.getColorBoundsRect(0xFFFFFFFF, 0x00000000, false);
				//mat.translate(-rect.x, -rect.y);
				
				_thumb.draw(solid.bitmapData, mat);
			}
			catch (e:Error)
			{
				// Consol.Trace("Layer: <<< Error creating layer thumbnail >>>");
			}
		}
		
		public function drawTo (bitmap:Bitmap):void
		{
			//// // Consol.Trace(solid);
			try 
			{   
				bitmap.bitmapData.draw(solid.bitmapData, graphics.transform.matrix, graphics.transform.colorTransform, graphics.blendMode, null, true);   
			}
			catch (e:Error) 
			{   
				bitmap.bitmapData.draw(new BitmapData(Canvas.WIDTH, Canvas.HEIGHT, true, 0x00000000), graphics.transform.matrix, graphics.transform.colorTransform, graphics.blendMode, null, true);   
			}
		}
		
		public function clearSolid (recreate:Boolean=true):void
		{
			solid.bitmapData.dispose();
			if (recreate) 
			{
				solid.bitmapData = new BitmapData(Canvas.WIDTH, Canvas.HEIGHT, true, 0x00000000);
				solid.smoothing = true;
			}
		}
		
		public function hitTest (x:Number, y:Number):Boolean
		{
			return solid.bitmapData.hitTest(new Point(0, 0), 0x00, new Point(x, y));
		}
		
		public function mouseHitTest ():Boolean
		{
			return solid.bitmapData.hitTest(new Point(0, 0), 0x00, new Point(solid.mouseX, solid.mouseY));
		}
		
		public function getFileName ():String
		{
			if (compFileName == null) compFileName = "Layer_" + getTimer() + "_" + label; 
			return compFileName;
		}
		
		protected function attributeExists (attrString:String, attrs:XMLList):Boolean
		{
			return (attrs.toString().indexOf(attrString) > -1)
			//return (attrs.@[attrString].length()>0)
		}
		
		public static function isBackgroundLayer (layer:Layer):Boolean
		{
			return (layer is BackgroundLayer);
		}
		
		public static function isLineLayer (layer:Layer):Boolean
		{
			return (layer is LineLayer);
		}
		
		public static function isBoxLayer (layer:Layer):Boolean
		{
			return ((layer is ImageLayer || layer is ColorLayer || layer is SWFLayer) && !Layer.isBackgroundLayer(layer));
		}
		
		public static function isBitmapLayer (layer:Layer):Boolean
		{
			return (layer is BitmapLayer);
		}
		
		public function stringToMatrix (str:String):Matrix
		{
			var mat:Matrix = new Matrix();
			var list:Array = str.split(",");
			mat.a = Number(list[0]);
			mat.b = Number(list[1]);
			mat.c = Number(list[2]);
			mat.d = Number(list[3]);
			mat.tx = Number(list[4]);
			mat.ty = Number(list[5]);
			
			return mat;
		}
		
		
		// LEGACY ///////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*public function saveImage (name:String):void
		{
			FileManager.writeLayerImage(solid.bitmapData, name);
		}*/
		
	}
}