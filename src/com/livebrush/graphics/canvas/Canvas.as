package com.livebrush.graphics.canvas
{

	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.ColorTransform;
	import flash.display.StageQuality;
	import flash.display.BlendMode;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.ui.Multitouch;
    import flash.ui.MultitouchInputMode;
	//import flash.events.TouchEvent;
	
	//import com.livebrush.ui.LayersPanel;
	import com.livebrush.graphics.canvas.*;
	//import com.livebrush.graphics.BitmapSprite;
	import com.livebrush.events.CanvasEvent;
	import com.livebrush.events.ConsolEvent;
	import com.livebrush.events.ControllerEvent;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UI;
	import com.livebrush.data.FileManager;
	
	import com.formatlos.as3.lib.display.BitmapDataUnlimited;
	import com.formatlos.as3.lib.display.events.BitmapDataUnlimitedEvent;

	
	public class Canvas extends Sprite
	{
		public static var sizeRes						:Array = [[{x:1280, y:1024, label:"Custom"}, {x:1280, y:1024}, {x:0, y:0}, {x:0, y:0}],
																  [{x:640, y:480, label:""}, {x:1067, y:800}, {x:2667, y:2000}, {x:5334, y:4000}],
																  [{x:800, y:600, label:""}, {x:1333, y:1000}, {x:3333, y:2500}, {x:6666, y:5000}],
																  [{x:1024, y:768, label:"Standard"}, {x:1707, y:1280}, {x:4267, y:3200}, {x:8534, y:6400}],
																  [{x:1280, y:720, label:"Widescreen"}, {x:2133, y:1200}, {x:5333, y:3000}, {x:10666, y:6000}],
																  [{x:1280, y:1024, label:""}, {x:2133, y:1707}, {x:5333, y:4267}, {x:10666, y:9000}],
																  [{x:1920, y:1080, label:"HD Widescreen"}, {x:3200, y:1800}, {x:8000, y:4500}, {x:16000, y:9000}]];
		
		public static var sizeDPI						:Array = [{label:"Normal Quality (72dpi)", data:0},
																  {label:"High Quality (150dpi)", data:1},
																  {label:"Print Quality (300dpi)", data:2}]//,
																 // {label:"Publish Quality (600dpi)", data:3}];
																 
		public static var defaultBackgrounds			:Array = [{label:"None", data:0},
																  {label:"Paper", data:"paper-1024W.jpg"}];
		
		public static const MIN_ZOOM					:Number = .25;
		public static const MAX_ZOOM					:Number = 5;
		
		//public static var WIDTH						:Number = sizeRes[4][0].x;
		//public static var HEIGHT						:Number = sizeRes[4][0].y;
		
		private static var _canvasResIndex				:int = 0;
		private static var _canvasSizeIndex				:int = 0;
		
		public static function get WIDTH ():int {   return sizeRes[_canvasSizeIndex][_canvasResIndex].x;   }
		public static function get HEIGHT ():int {   return sizeRes[_canvasSizeIndex][_canvasResIndex].y;   }
		
		public static var STAGE							:Stage;
		public static var GLOBAL_CANVAS					:Canvas;
		public static var CONTROLS						:Sprite;
		public static var DEBUG							:Sprite;
		
		public static var TOUCH_SUPPORT					:Boolean = false;
		
		public var layersDepth							:int;
		public var canvasManager						:CanvasManager;
		public var offset								:Point; // for use when we setup the canvas movement (spacebar, drag to move, like in ps)
		//private var matte								:CanvasMatte;
		private var maskShape							:Shape;
		private var frame								:Shape
		public var layers								:Sprite;
		private var cursors								:Sprite;
		private var cursor								:Sprite;
		public var comp									:Sprite;
		private var workingComps						:Array;
		public var aboveLayerComp						:Bitmap;
		public var belowLayerComp						:Bitmap;
		public var sampleLayerComp						:Bitmap;
		public var masterComp							:Bitmap;
		public var controlsComp							:Bitmap;
		public var controls								:Sprite;
		public var selection							:Sprite;
		public var wireframe							:Sprite;
		public var graphicReps							:Sprite;
		public var lastMousePt							:Point;
		public var mousePt								:Point;
		public var mouseSpeed							:Number = 0;
		public var lastMouseEvent						:MouseEvent;
		private var lastAngleRads						:Number;
		private var vX									:Number;
		private var lastVY								:Number;
		private var lastVX								:Number;
		private var debug								:Sprite;
		public var stylePreviewLayer					:Sprite;
		public var locked								:Boolean = false;
		private var _angleRads 							:Number;
		//private var mouseSpeed						:Number = 0;
		private var _speed								:Number = 0;
		private var _lastAnglePos						:Point;
		private var velPt								:Point;
		private var _mouseChildren						:Boolean = true;
		private var lastColor							:uint = 0;
		private var _zoom 								:Number = 1;
		
		var dotMc:MovieClip;
		
		
		public function Canvas (manager:CanvasManager):void
		{
			super();
			
			canvasManager = manager;
			
			init();
		}

		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public static function get WIREFRAME ():Sprite {   return Canvas.GLOBAL_CANVAS.wireframe;   }
		public static function get SELECTION ():Sprite {   return Canvas.GLOBAL_CANVAS.selection;   }
		public static function get GRAPHIC_REPS ():Sprite {   return Canvas.GLOBAL_CANVAS.graphicReps;   }
		public static function get X	():Number {   return GLOBAL_CANVAS.comp.mouseX;   }
		public static function get Y	():Number {   return GLOBAL_CANVAS.comp.mouseY;   } 
		public static function get VX	():Number {   return GLOBAL_CANVAS.vx;   }
		public static function get VY	():Number {   return GLOBAL_CANVAS.vy;   } 
		public static function get MOUSE_POINT ():Point {   return new Point(X, Y);   }
		public function get vx ():Number { return velPt.x;  }
		public function get vy ():Number { return velPt.y;  }
		//public function get angleRads ():Number { return Math.atan2(vy, vx);  }
		public function get actualSpeed ():Number { return mouseSpeed;  }
		public function get speed ():Number { return _speed;  }
		public function get angleRads ():Number { return _angleRads;  }
		public function get canvasRect ():Rectangle {   return comp.getBounds(stage);   }
		public static function get SIZE_INDEX	():int {   return _canvasSizeIndex;   }
		public function get zoomAmount ():Number {   return _zoom;   }
		
		
		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			offset = new Point (0, 0);
			
			velPt = new Point();
			
			workingComps = [];
			
			createCanvas();
			
			doubleClickEnabled = true;
			
			addEventListener (Event.ADDED_TO_STAGE, addedHandler);
			
			TOUCH_SUPPORT = Multitouch.supportsTouchEvents;
			
			//Consol.Trace("Canvas: init, TOUCH_SUPPORT = " + TOUCH_SUPPORT);
			
			if (TOUCH_SUPPORT) initTouch();
			
		}
		
		private function initTouch ():void
		{
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT
			//Consol.Trace("Canvas: initTouch, Multitouch.inputMode = " + Multitouch.inputMode);
		}
		
		private function createCanvas ():void
		{
			comp = new Sprite ();
			debug = new Sprite();
			
			controls = new Sprite();
			selection = new Sprite();
			wireframe = new Sprite();
			graphicReps = new Sprite();
			//graphicReps.visible = false; // hide this to see the layer reps
			graphicReps.alpha = 0;//.25;
			//controls.blendMode = BlendMode.INVERT;
			wireframe.blendMode = selection.blendMode = BlendMode.INVERT;
			
			addChild(comp);
			
			aboveLayerComp = newCanvasBitmap();
			belowLayerComp = newCanvasBitmap();
			sampleLayerComp = newCanvasBitmap();
			masterComp = newCanvasBitmap();
			
			comp.addChild(belowLayerComp);
			
			layers = new Sprite();
			comp.addChild(layers);
			layersDepth = comp.getChildIndex(layers);
			
			maskShape = new Shape();
			maskShape.graphics.beginFill(0xFF0000); // needs this
			maskShape.graphics.drawRect(0,0,WIDTH,HEIGHT);
			addChild(maskShape);
			
			/*var wireframeMask:Shape = new Shape();
			wireframeMask.graphics.beginFill(0xFF0000); // needs this
			wireframeMask.graphics.drawRect(0,0,WIDTH,HEIGHT);*/
			
			frame = new Shape();
			frame.graphics.lineStyle(1,0x000000,1);
			frame.graphics.drawRect(0,0,WIDTH,HEIGHT);
			addChild(frame);
			
			comp.mask = maskShape;
			comp.addChild(aboveLayerComp);
			comp.addChild(masterComp);
			comp.addChild(graphicReps);
			comp.addChild(wireframe);
			//comp.addChild(wireframeMask);
			//wireframe.mask = wireframeMask;

			
			//stylePreviewLayer = comp.addChild(new Sprite()) as Sprite;
			//stylePreviewLayer = UI.WINDOW_HOLDER.addChild(new Sprite()) as Sprite;
			stylePreviewLayer = UI.PREVIEW_HOLDER;
			
			
			addChild(controls);
			addChild(selection);
	
			addChild(debug);
			
			cursors = new Sprite ();
			addChild(cursors);
		}
		
		
		// CANVAS ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function canvasZoom (amount:Number=1):void
		{
			//Consol.Trace("Canvas: canvasZoom, amount: " + amount);
			
			_zoom = amount;
			
			comp.scaleX = frame.scaleX = maskShape.scaleX = amount;
			comp.scaleY = frame.scaleY = maskShape.scaleY = amount;
		}
		
		public function lockContent ():void
		{
			if (!locked) 
			{
				_mouseChildren = mouseChildren;
				mouseChildren = false;
				locked = true;
				// // Consol.Trace("lock content");
			}
		}
		
		public function unlockContent (force:Boolean=false):void
		{
			if (locked) 
			{
				// // Consol.Trace("unlock content");
				mouseChildren = true; //(force?true:_mouseChildren); //true;
				locked = false;
				offset = new Point (x, y-30.7);
				setPreviewPosition();
			}
		}
		
		private function setPreviewPosition ():void
		{
			stylePreviewLayer.x = offset.x + (WIDTH/2 - 400);
			stylePreviewLayer.y = offset.y + (HEIGHT/2 - 300);
		}
		
		public function setSize (index:int):void
		{
			offset = new Point();
			
			_canvasSizeIndex = index;
			
			//Consol.Trace("Canvas: setSize, _canvasSizeIndex = " + _canvasSizeIndex);
			//Consol.Trace("Canvas: setSize, WIDTH = " + WIDTH);
			
			aboveLayerComp.bitmapData.dispose();
			belowLayerComp.bitmapData.dispose();
			masterComp.bitmapData.dispose();
			aboveLayerComp.bitmapData = newCanvasBitmapData();
			belowLayerComp.bitmapData = newCanvasBitmapData();
			masterComp.bitmapData = newCanvasBitmapData();
			
			var depth:int = maskShape.parent.getChildIndex(maskShape);
			maskShape.parent.removeChild(maskShape);
			maskShape = new Shape();
			maskShape.graphics.beginFill(0xFF0000); // needs this
			maskShape.graphics.drawRect(0,0,WIDTH,HEIGHT);
			addChildAt(maskShape, depth);
			comp.mask = maskShape;
			
			depth = frame.parent.getChildIndex(frame);
			frame.parent.removeChild(frame);
			frame = new Shape();
			frame.graphics.lineStyle(1,0x000000,1);
			frame.graphics.drawRect(0,0,WIDTH,HEIGHT);
			addChildAt(frame, depth);
			
			setPreviewPosition();
			
		}
		
		public function getNewLayer ():Sprite
		{
			//// // Consol.Trace("new canvas layer");
			return layers.addChild(new Sprite()) as Sprite;
			//return layers.addChild(new BitmapSprite(WIDTH, HEIGHT)) as BitmapSprite;
			
		}
		
		public function moveLayer (from:int, to:int):void
		{
			layers.setChildIndex(layers.getChildAt(from), to);
		}

		public function getLayer (depth:int):Sprite
		{
			//// // Consol.Trace("new canvas layer");
			return layers.getChildAt(depth) as Sprite;
		}
	
		public function addCursor (mc:MovieClip):void
		{
			cursors.addChild(mc);
		}
		
		public function updateCursor (force:Boolean=false):void
		{
			var newPt:Point = new Point (comp.mouseX, comp.mouseY);
			//var newPt:Point = new Point (mouseX, mouseY);
			mousePt = newPt;
			velPt.x = mousePt.x-lastMousePt.x;
			velPt.y = mousePt.y-lastMousePt.y;
			mouseSpeed = Point.distance(newPt, lastMousePt);
			var angle:Number = Math.atan2(vy, vx);
			
			//Consol.Trace(mouseSpeed);
				
			//// // Consol.Trace(VX);
			if (mouseSpeed > 4 || force || _lastAnglePos == null) //  || slowSpeed > 25//  || Math.abs(angle-lastAngle)>(Math.PI/2)  //  || Math.abs(angle-_angleRads)>4 //  || (_lastLineLength+35)==line.length
			{
				_angleRads = angle;
				_lastAnglePos = mousePt;
				lastAngleRads = angle;
			}
			else 
			{
				var slowVX:Number = (mousePt.x-_lastAnglePos.x);
				var slowVY:Number = (mousePt.y-_lastAnglePos.y);
				var dist:Number = Point.distance(mousePt, _lastAnglePos);
				
				if (dist > 10) 
				{
					_angleRads = Math.atan2(slowVY, slowVX);
					_lastAnglePos = mousePt;
				}
			}
			
			
			lastMousePt = mousePt.clone();
			
			//var speed:Number = Point.distance(newPt, lastMousePt);
			//Consol.globalOutput(speed);
			
			
			/*if (speed >= 15)
			{
				mouseSpeed = speed;
				lastAngleRads = angleRads;
				//cursor.rotation = angleRads * 180 / Math.PI;
			}*/
		}
		
		public function hide ():void
		{
			comp.visible = false;
		}
		
		public function show ():void
		{
			comp.visible = true;
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function addedHandler (e:Event):void
		{
			if (e.target == this)
			{
				//Consol.Trace("Canvas: addedHandler");
				
				stage.quality = StageQuality.BEST;
				STAGE = stage;
				
				removeEventListener (Event.ADDED_TO_STAGE, addedHandler);
				
				if (GLOBAL_CANVAS == null)
				{
					//// // Consol.Trace("canvas added");
					mousePt = new Point (mouseX, mouseY);
					lastMousePt = new Point ();
					GLOBAL_CANVAS = this;
					CONTROLS = controls;
					DEBUG = debug;
				}
			}
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function generateCanvasBitmap (res:int, onBmpUReady:Function, onBmpUError:Function):void
		{
			var bmpU:BitmapDataUnlimited = new BitmapDataUnlimited();
			
			bmpU.addEventListener(BitmapDataUnlimitedEvent.COMPLETE, onBmpUReady);
			bmpU.addEventListener(BitmapDataUnlimitedEvent.ERROR, onBmpUError);
			
			bmpU.create(sizeRes[_canvasSizeIndex][res].x, sizeRes[_canvasSizeIndex][res].y, true);
		}
		
		public function upScale (res:int=0):void
		{
			layers.width = sizeRes[_canvasSizeIndex][res].x; 
			layers.height = sizeRes[_canvasSizeIndex][res].y;
		}
		
		public function downScale ():void
		{
			layers.width = WIDTH; 
			layers.height = HEIGHT;
			//// // Consol.Trace(width);
		}
		
		public function newCanvasBitmap (rect:Rectangle=null):Bitmap
		{
			return new Bitmap(newCanvasBitmapData(rect), PixelSnapping.AUTO, true);
		}
		
		public function newCanvasBitmapData (rect:Rectangle=null):BitmapData
		{
			rect = (rect==null ? new Rectangle(0, 0, Canvas.WIDTH, Canvas.HEIGHT) : rect);
			return new BitmapData(rect.width, rect.height, true, 0x00000000);
		}
		
		public function copyBitmapTo (source:Bitmap, dest:Bitmap):void
		{
			dest.bitmapData.draw(source.bitmapData, null, null, null, null, true);
		}
		
		public function clearBitmap (bitmap:Bitmap):void
		{
			bitmap.bitmapData.dispose();
			bitmap.bitmapData = newCanvasBitmapData();
			bitmap.smoothing = true; // why is smoothing reset when we re-assign a bitmap?
		}
		
		public function getPixelColor (x:Number, y:Number):uint 
		{   
			return sampleLayerComp.bitmapData.getPixel(x, y);   
			//return belowLayerComp.bitmapData.getPixel(x, y);   
			//return masterComp.bitmapData.getPixel(x, y);   
		}
		
		public function getMouseColor (allLayers:Boolean=true):uint
		{
			return getPixelColor(comp.mouseX, comp.mouseY);
		}
		
		public function getColorAt (x:Number, y:Number):uint
		{
			var c:uint;
			
			if (pointWithinCanvas(x, y)) {
				c = getPixelColor(x, y);
				lastColor = c;
			} else {
				//// Consol.Trace("POINT NOT WITHIN CANVAS");
				c = lastColor;
			}
			return c; //getPixelColor(x, y);
		}
		
		public function pointWithinCanvas (x:Number, y:Number):Boolean
		{
			return (canvasRect.contains(x,y));
		}
		
	}
	
}
