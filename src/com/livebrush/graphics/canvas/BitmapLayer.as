package com.livebrush.graphics.canvas
{
	import flash.geom.Matrix;
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
	import flash.events.IOErrorEvent;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.filters.BlurFilter;
	import flash.utils.getTimer;
	import flash.display.Loader;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import com.livebrush.data.Exchangeable;
	import com.livebrush.data.Settings;
	import com.livebrush.data.Storable;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.Line;
	import com.livebrush.data.FileManager;
	import com.livebrush.data.GlobalSettings;
	
	import flash.text.TextField;
	import com.livebrush.ui.Consol;
	
	public class BitmapLayer extends LineLayer implements Storable
	{
	
		/*public var line							:Line = null;
		public var vectors						:Sprite = null; 
		public var decos						:Sprite = null;*/
		private var staticTransformMat					:Matrix;
		private var _imageFile							:String = null; 
		//private var flattened							:Boolean = true;
		
		public function BitmapLayer (canvas:Canvas, depth:int=0):void
		{
			// Consol.Trace("BitmapLayer: BitmapLayer Constructor");
			
			super(canvas, depth);
			_type = Layer.BITMAP;
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*public function get hasDecos ():Boolean {   return (line.hasDecos);   }
		public function get hasUnCachedDecos ():Boolean {   return (decos.numChildren>0);   }
		public override function get boundingBox ():Rectangle {   return vectors.getRect(canvas).union(decos.getRect(canvas));   }
		//public override function set cached (b:Boolean):void {   _cached=b; if(line!=null)line.changed=b;   }
		// // // Consol.Trace("LineLayer.get cached: " + (line!=null?!line.changed:_cached)); */
		public override function set cached (b:Boolean):void {   _cached=b;   }
		public override function get cached ():Boolean {   return _cached;   }
		
		
		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			/*solid = new Bitmap(new BitmapData(Canvas.WIDTH, Canvas.HEIGHT, true, 0x00000000), PixelSnapping.AUTO, true);
			graphics.addChild(solid);
			vectors = new Sprite();
			decos = new Sprite();
			
			vectors.cacheAsBitmap = true;
			vectors.blendMode = BlendMode.LAYER;

			decos.cacheAsBitmap = true;
			decos.blendMode = BlendMode.LAYER;

			graphics.addChild(vectors);
			graphics.addChild(decos); */
			
			loaded = true;
			changed = false;
			
			staticTransformMat = new Matrix();
		}
		
		public override function die ():void
		{
			super.superDie();
			
			//solid.bitmapData.dispose();
			
			/*if (loaded) 
			{
				clearDecos();
				//line.die();
			}*/
		}
		
		public override function setup ():void
		{
			//redraw();
			cache();
		}
		
		private function initLayer ():void
		{
			applyInitProps();
			loaded = true;
			dispatchEvent (new Event(Event.COMPLETE, true, false));
		}
		
		
		// LAYER ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function copy ():Layer
		{
			var newLayer:BitmapLayer = new BitmapLayer(canvas);
			
			newLayer.label = label;
			newLayer.alpha = alpha;
			newLayer.blendMode = blendMode;
			newLayer.depth = depth+1;
			
			//newLayer.line = line.copy();
				
			newLayer.setup();
			
			return newLayer;
		}
		
		public override function updateDisplay (cacheGraphics:Boolean=true):void
		{
			// Consol.Trace("BitmapLayer: updateDisplay");
	
			//try {
				redraw();
			//} catch (e:Error) {
				//// Consol.Trace("BitmapLayer: updateDisply redraw ERROR: " + e);
			//}
			
			//try {
				generateThumb();
			//} catch (e:Error) {
				//// Consol.Trace("BitmapLayer: error creatng thumbnail from updateDisplay: " + e);
			//}
		}
		
		public override function redraw ():void
		{
			//// Consol.Trace("BitmapLayer: redraw");
			//try {
				cacheDecos();
			//} catch (e:Error) {
				//// Consol.Trace("BitmapLayer: redraw cacheDecos ERROR: " + e);
			//}
			
			// flatten existing to new solid
			if (staticTransformMat.toString() != transform.matrix.toString()) {
			
				//// Consol.Trace("BitmapLayer: updateDisplay: redraw to flat solid");
				
				var solidCopy:BitmapData = solid.bitmapData.clone();
				clearSolid();
				
				try 
				{   
					solid.bitmapData.draw(solidCopy, graphics.transform.matrix, null, null, null, true);
					//solid.bitmapData.draw(solidCopy, graphics.transform.matrix, graphics.transform.colorTransform, graphics.blendMode, null, true);   
				}
				catch (e:Error) 
				{   
					//// Consol.Trace("CanvasManager: BitmapLayer redraw draw ERROR: " + e);
					solid.bitmapData.draw(new BitmapData(Canvas.WIDTH, Canvas.HEIGHT, true, 0x00000000), null, null, null, null, true);
					//solid.bitmapData.draw(new BitmapData(Canvas.WIDTH, Canvas.HEIGHT, true, 0x00000000), graphics.transform.matrix, graphics.transform.colorTransform, graphics.blendMode, null, true);   
				}
				
				resetTransform();
				
				solidCopy.dispose();
				
				canvasManager.toolManager.resetTool();
			
			}
			
			//clearSolid();
			//line.draw(this);
		}
		
		public override function resetTransform (_scale:Boolean=true, _rotation:Boolean=true, _skew:Boolean=true):void
		{
			super.resetTransform();
			x = 0;
			y = 0;
		}
		
		public override function cache ():void
		{
			// Consol.Trace("BitmapLayer: cache");
			cacheVectors();
			cacheDecos();
			cached = false;
			//// // Consol.Trace("cache line layer: " + cached);
		}
		
		public override function cacheVectors ():void
		{
			if (GlobalSettings.CACHE_LAYERS)
			{
				solid.bitmapData.draw(vectors, null, null, null, null, true);
				clearVectors();
				/*while (vectors.numChildren > 0)
				{
					vectors.removeChildAt(0).cacheAsBitmap = false;
				}*/
			}
		}
		
		public override function cacheDecos ():void
		{
			if (GlobalSettings.CACHE_LAYERS)
			{
				//try {
					
					solid.bitmapData.draw(decos, null, null, null, null, true);
				/*} catch (e:Error) {
					// Consol.Trace("BitmapLayer: cacheDecos ERROR: " + e);
					// Consol.Trace("BitmapLayer: solid.bitmapData.width = " + solid.bitmapData.width);
				}*/
				clearDecos();
			}
		}
		
		public override function clearDecos ():void
		{
			while (decos.numChildren > 0)
			{
				decos.removeChildAt(0).cacheAsBitmap = false;
			}
		}
		
		public override function clearVectors ():void
		{
			vectors.graphics.clear();
		}
		
		public function setBitmapData (bmp:BitmapData):void {
		
			clearSolid();
			solid.bitmapData.draw(bmp, null, null, null, null, true);   
		
		}

		
		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function setXML (xml:String):void
		{
			//super.setXML(xml);
			//loadLine();
		}
		
		public override function getXML ():XML
		{
			//// Consol.Trace("BitmapLayer");
			
			var newLayerXML:XML = new XML (<layer enabled={enabled} type={Layer.IMAGE} label={label} matrix={transformMatrixString} blendMode={blendMode} alpha={alpha} color={color} colorPercent={colorPercent} scaleX={scaleX} scaleY={scaleY} rotation={rotation} x={x} y={y}></layer>);
			
			//FileManager.getInstance().saveFlattenedLayerImage(bmp, activeLayer.getFileName());
			
			newLayerXML.appendChild(<solid src={getImageFile()} />);
			
			return newLayerXML;
		}
		
		private function getImageFile ():String {
			if (_imageFile == null) _imageFile = FileManager.getInstance().saveFlattenedLayerImage(solid.bitmapData.clone(), label.split(" ").join("_"));
			else FileManager.getInstance().saveFlattenedLayerImage(solid.bitmapData.clone(), FileManager.getInstance().removeExtension(_imageFile), false);			
			return _imageFile;
		}
		
		public override function loadLine ():void
		{
			/*compFileName = layerXML.@comp.toString().length>0 ? layerXML.@comp : getFileName();
			
			line = Line.newLine(layerXML.line.@smooth=="true"?true:false, layerXML.line.@type, Number(layerXML.line.@lines), Number(layerXML.line.@weight));
			line.setXML (layerXML.line.toXMLString()); 
			
			if (line.hasDecos && !line.decosLoaded) line.addEventListener(Event.COMPLETE, layerLineComplete);
			else initLayer();*/
		}
		
		protected override function applyInitProps ():void
		{
			alpha = initProps.alpha;
			color = initProps.color;
			colorPercent = initProps.colorPercent;
			enabled = initProps.enabled;
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function layerLineComplete (e:Event):void
		{
			//e.target.removeEventListener(e.type, initLayerHandler);
			e.target.removeEventListener(e.type, layerLineComplete);
			initLayer();
		}
		
		
		// LEGACY ///////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function initLayerHandler (e:Event):void
		{
			//e.target.removeEventListener(e.type, initLayerHandler);
			initLayer();
		}*/
	}
}