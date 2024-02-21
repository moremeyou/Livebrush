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
	
	public class LineLayer extends Layer implements Storable
	{
	
		public var line							:Line = null;
		public var vectors						:Sprite = null; 
		public var decos						:Sprite = null;

		
		public function LineLayer (canvas:Canvas, depth:int=0):void
		{
			super(canvas, depth);
			_type = Layer.LINE;
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get hasDecos ():Boolean {   return (line.hasDecos);   }
		public function get hasUnCachedDecos ():Boolean {   return (decos.numChildren>0);   }
		public override function get boundingBox ():Rectangle {   return vectors.getRect(canvas).union(decos.getRect(canvas));   }
		//public override function set cached (b:Boolean):void {   _cached=b; if(line!=null)line.changed=b;   }
		// // // Consol.Trace("LineLayer.get cached: " + (line!=null?!line.changed:_cached)); 
		public override function set cached (b:Boolean):void {   _cached=b; if (line!=null) line.changed=!b;   }
		public override function get cached ():Boolean {   return (line!=null?!line.changed:_cached);   }
		
		
		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			solid = new Bitmap(new BitmapData(Canvas.WIDTH, Canvas.HEIGHT, true, 0x00000000), PixelSnapping.AUTO, true);
			graphics.addChild(solid);
			vectors = new Sprite();
			decos = new Sprite();
			
			vectors.cacheAsBitmap = true;
			vectors.blendMode = BlendMode.LAYER;

			decos.cacheAsBitmap = true;
			decos.blendMode = BlendMode.LAYER;

			graphics.addChild(vectors);
			graphics.addChild(decos); 
		}
		
		public override function die ():void
		{
			superDie();
			
			if (loaded) 
			{
				clearDecos();
				line.die();
			}
		}
		
		public function superDie():void {
			super.die();
		}
		
		public override function setup ():void
		{
			redraw();
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
			var newLayer:LineLayer = new LineLayer(canvas);
			
			newLayer.label = label;
			newLayer.alpha = alpha;
			newLayer.blendMode = blendMode;
			newLayer.depth = depth+1;
			
			newLayer.line = line.copy();
				
			newLayer.setup();
			
			return newLayer;
		}
		
		public override function updateDisplay (cacheGraphics:Boolean=true):void
		{
			// Consol.Trace("LineLayer: updateDisplay");
			line.applyProps();
			redraw();
			//if (cacheGraphics) 
			cache();
			generateThumb();
		}
		
		public function redraw ():void
		{
			clearSolid();
			line.draw(this);
		}
		
		public function cache ():void
		{
			cacheVectors();
			cacheDecos();
			cached = true;
			//// // Consol.Trace("cache line layer: " + cached);
		}
		
		public function cacheVectors ():void
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
		
		public function cacheDecos ():void
		{
			if (GlobalSettings.CACHE_LAYERS)
			{
				solid.bitmapData.draw(decos, null, null, null, null, true);
				clearDecos();
			}
		}
		
		public function clearDecos ():void
		{
			while (decos.numChildren > 0)
			{
				decos.removeChildAt(0).cacheAsBitmap = false;
			}
		}
		
		public function clearVectors ():void
		{
			vectors.graphics.clear();
		}

		
		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function setXML (xml:String):void
		{
			super.setXML(xml);
			loadLine();
		}
		
		public override function getXML ():XML
		{
			var newLayerXML:XML = new XML (<layer enabled={enabled} type={Layer.LINE} label={label} blendMode={blendMode} alpha={alpha} color={color} colorPercent={colorPercent}></layer>);
			
			newLayerXML.@comp = getFileName();
			// LATER: WE'LL JUST GRAB THE LAYERXML VAR - WHICH WILL ALWAYS BE A REFLECTION OF THE LAYER AS IS (undo/redo state)
			if (line == null) newLayerXML = layerXML;
			else newLayerXML.appendChild(line.getXML());
			
			
			return newLayerXML;
		}
		
		public function loadLine ():void
		{
			compFileName = layerXML.@comp.toString().length>0 ? layerXML.@comp : getFileName();
			
			line = Line.newLine(layerXML.line.@smooth=="true"?true:false, layerXML.line.@type, Number(layerXML.line.@lines), Number(layerXML.line.@weight));
			line.setXML (layerXML.line.toXMLString()); 
			
			if (line.hasDecos && !line.decosLoaded) line.addEventListener(Event.COMPLETE, layerLineComplete);
			else initLayer();
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