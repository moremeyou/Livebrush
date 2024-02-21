package com.livebrush.graphics.canvas
{
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject
	import flash.display.PixelSnapping;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import flash.events.IOErrorEvent;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.filters.BlurFilter;
	import flash.utils.getTimer;
	import flash.display.Loader;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import fl.controls.CheckBox;
	
	import com.livebrush.data.Exchangeable;
	import com.livebrush.data.Settings;
	import com.livebrush.data.Storable;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.Line;
	import com.livebrush.data.FileManager;
	import com.livebrush.data.GlobalSettings;
	import com.livebrush.styles.*
	import com.livebrush.tools.LiveBrush;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.ColorInput;
	import com.livebrush.styles.StrokeStyle;
	
	import org.casalib.util.ColorUtil;
	import org.casalib.math.Percent;
	
	
	public class StylePreviewLayer extends LineLayer
	{
		
		public static var IDLE						:String = "idle";
		public static var RUNNING					:String = "running";
		
		private var _rand							:Number;
		private var _angle							:int;
		private var _velPt							:Point;
		private var _brush							:LiveBrush;
		private var _interval						:int = 0;
		private var _parent							:Sprite;
		public var style							:Style;
		public var state							:String = IDLE;
		public var bg								:Bitmap;
		public var bgColor							:uint = 0x1e1e1e;
		public var lastPos							:Point;
		private var colorInput						:ColorInput;
		private var checkbox						:CheckBox;
		
		public function StylePreviewLayer (canvas:Canvas, depth:int=0):void
		{
			super(canvas, depth);
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get styleManager ():StyleManager {   return canvasManager.styleManager;   }
		
		
		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			lastPos = new Point(400, 300)
			_angle = Math.random()*(Math.PI*2);
			
			parent.removeChildAt(depth);
			//graphics = canvas.stylePreviewLayer;
			graphics = new Sprite();
			_parent = UI.PREVIEW_HOLDER;
			//_parent = parent;
			solid = new Bitmap(new BitmapData(800, 600, true, 0x00000000), PixelSnapping.AUTO, true);
			solid.scrollRect = new Rectangle(0,0,800,600);
			graphics.addChild(solid);
			vectors = new Sprite();
			decos = new Sprite();
			
			vectors.cacheAsBitmap = true;
			vectors.blendMode = BlendMode.LAYER;

			decos.cacheAsBitmap = true;
			decos.blendMode = BlendMode.LAYER;

			bg = new Bitmap(new BitmapData(800, 600, false, bgColor));
			
			var maskShape:Shape = new Shape();
			maskShape.graphics.beginFill(0xFF0000); // needs this
			maskShape.graphics.drawRect(0,0,800,600);
			graphics.addChild(maskShape);
			decos.mask = maskShape;
			
			//graphics.addChild(bg);			
			graphics.addChild(vectors);
			graphics.addChild(decos); 
			graphics.addChildAt(bg, 0);
			colorInput = ColorInput(graphics.addChild(new ColorInput()));
			checkbox = CheckBox(graphics.addChild(new CheckBox()));
			checkbox.x = 22;
			checkbox.y = 1;
			checkbox.selected = true;
			checkbox.label = "";
			
			colorInput.addEventListener(Event.CHANGE, bgColorChange);
			checkbox.addEventListener(Event.CHANGE, toggleBg);
			
			//graphics.mouseChildren = false;
			
			//visible = false;
			
			Canvas.STAGE.addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		public function reset ():void
		{
			try {   clearInterval(_interval); style.lineStyle.type=LineStyle.NORMAL;   } catch(e:Error){}
			//try {   lastPos = new Point(_brush.x, _brush.y);   } catch (e:Error) {}
			//try {   clearInterval(_interval); style.lineStyle.type=LineStyle.NORMAL; style.die();   } 
			//catch (e:Error) {}
			//finally 
			//{
				_rand = Math.max(5, Math.random()*10)
				//_angle = Math.random()*(Math.PI*2);
				_velPt = new Point();
				clearSolid();
				_clearLine();
				_brush = null;
				state = IDLE;
			//}
		}
		
		
		// DRAW ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function drawStyle ():void //_style:Style
		{
			reset();
			//// // Consol.Trace(_style.decoStyle.decoSet.activeLength);
			//if (_style != null) 
			//{
				//// // Consol.Trace(_style.decoStyle.decoSet.activeLength);
				//style = _style.clone();
				//_style.die();
				//// // Consol.Trace(style.decoStyle.decoSet.activeLength);
			//}
			//else 
			//{
				//// // Consol.Trace(styleManager.activeStyle.decoStyle.decoSet.activeLength);
				try {   style.die();   } catch (e:Error){}
				style = styleManager.activeStyle.clone();
				//// // Consol.Trace(this.style.decoStyle.decoSet.activeLength);
			//}
			//// // Consol.Trace(this.style.strokeStyle.decorate);
			
			//style.lineStyle.setDynamicInput("preview");
			//style.strokeStyle.decorate = false;
			style.lineStyle.type = LineStyle.NORMAL;
			style.lineStyle.mouseUpComplete = false;
			style.lineStyle.lockMouse = true;
			
			if (_brush == null) 
			{
				_brush = new LiveBrush(style, this, lastPos);
				_brush.showCursor = false;
			}
			_brush.style = style;
			
			
			_newLine();
			
			//_angle = Math.random()*(Math.PI*2);
			//_velPt = new Point();
			
			state = RUNNING;
			
			// set new line interval
			//_interval = setInterval(drawStyle, 5000, style);
			//_interval = setInterval(stop, 5000);
			_interval = setTimeout(queueNext, 2000);
		}
		
		public function move (inPt:Point, currentPt:Point):Point
		{
			//_velPt.x = Math.sin(_angle/23.5+2.5) * Math.sin(_angle/5.5+2) * Math.sin(_angle/15+.5) * 400;
			//_velPt.y = Math.sin(_angle/27.5+1.75) * Math.sin(_angle/6+1) * Math.sin(_angle/7+2) * 400;
			_velPt.x = Math.sin(_angle/23.5+2.5) * Math.sin(_angle/_rand+.5) * 400;
			_velPt.y = Math.sin(_angle/27.5+1.75) * Math.sin(_angle/_rand+2) * 300;
			
			inPt = inPt.add(_velPt);
			
			_angle += 1;	
			
			return inPt;
		}
		
		
		// LAYER ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function toggle ():void
		{
			visible = styleManager.showStylePreview = !visible;
			//// // Consol.Trace(visible);
			if (visible) 
			{
				_parent.addChild(graphics);
				drawStyle();
			}
			else
			{
				_parent.removeChild(graphics);
				reset();
			}
		}
		
		private function _clearLine ():void
		{
			try {   _brush.line.die();   }
			catch (e:Error) { }
			finally 
			{
				clearVectors();
				clearDecos();
			}
		}
		
		private function _newLine ():void
		{
			//_brush.style.lineStyle.type = LineStyle.DYNAMIC
			_brush.style.lineStyle.setDynamicInput("preview");
			
			if (_brush.style.strokeStyle.widthType == StrokeStyle.PRESSURE) _brush.style.strokeStyle.widthType = StrokeStyle.SPEED;
			if (_brush.style.strokeStyle.alphaType == StrokeStyle.PRESSURE) _brush.style.strokeStyle.alphaType = StrokeStyle.SPEED;
			if (_brush.style.decoStyle.alphaType == StrokeStyle.PRESSURE) _brush.style.decoStyle.alphaType = DecoStyle.STROKE;
			if (_brush.style.decoStyle.posType == StrokeStyle.PRESSURE) _brush.style.decoStyle.posType = DecoStyle.CENTER;
			if (_brush.style.decoStyle.sizeType == StrokeStyle.PRESSURE) _brush.style.decoStyle.sizeType = DecoStyle.SPEED;
			if (_brush.style.decoStyle.tintType == StrokeStyle.PRESSURE) _brush.style.decoStyle.tintType = DecoStyle.FIXED;
			
			_brush.style = style;
			_brush.dynamicMove = move;
			_brush.setNewLine(lastPos);
			//// // Consol.Trace(_brush.style.lineStyle.type);
		}
		
		public override function clearSolid (recreate:Boolean=true):void
		{
			solid.bitmapData.dispose();
			if (recreate) 
			{
				//solid.bitmapData = new BitmapData(Canvas.WIDTH, Canvas.HEIGHT, true, 0x00000000);
				//solid.smoothing = true;
				
				solid.bitmapData = new BitmapData(800, 600, true, 0x00000000);
				//solid.scrollRect = new Rect_angle(0,0,800,600);
				//graphics.addChild(solid);
			}
		}
		
		private function queueNext ():void
		{
			_brush.style.lineStyle.type = LineStyle.ELASTIC;
			_brush.inPt = Point.interpolate(new Point(_brush.x, _brush.y), _brush.inPt, .5);
			//_brush.style.lineStyle.elastic = .7;
			//_brush.style.lineStyle.friction = .6;
			_brush.queueFinish();
			_interval = setTimeout(drawStyle, 2000); // , style
		}
		
		
		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function enterFrameLoop (e:Event):void
		{
			if (state == RUNNING)
			{
				_brush.move();
				_brush.line.drawNew(this);
			
				cacheVectors();
				//cacheDecos();
				//if (GlobalSettings.CACHE_DECOS) brush.layer.cacheDecos();
			}
		}
		
		private function bgColorChange (e:Event):void
		{
			var newCTF:ColorTransform = new ColorTransform();
			newCTF.color = colorInput.color;
			//// // Consol.Trace(colorInput.color);
			bg.transform.colorTransform = newCTF; //ColorUtil.interpolateColor(new ColorTransform(), newCTF, new Percent(100));
		}
		
		private function toggleBg (e:Event=null):void
		{
			bg.visible = !bg.visible;
		}
		
		
	}
}