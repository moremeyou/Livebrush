package com.livebrush.graphics.canvas
{
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.setTimeout;
	import flash.display.MovieClip;
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
	import com.livebrush.data.Exchangeable;
	import com.livebrush.data.Settings;
	import com.livebrush.data.Storable;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.graphics.Line;
	import com.livebrush.data.FileManager;
	import com.livebrush.data.GlobalSettings;
	
	import flash.text.TextField;
	import com.livebrush.ui.Consol;
	
	public class BitmapLayer extends ImageLayer implements Storable
	{
		
		public var src											:String;
		public var assetCenter									:Object;
		
		public function BitmapLayer (canvas:Canvas, depth:int=0):void
		{
			super(canvas, depth);
			_type = Layer.IMAGE;
			init();
		}

		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
		}
		
		public override function setup ():void
		{
			//// // Consol.Trace(); missingLayerFile
			loader = FileManager.loadLayerImage(src, contentLoad, loadError);
			// we should handle errors in the file manager (but not yet)
		}
		
		private function initLayer ():void
		{
			if (initProps != null) applyInitProps();
			dispatchEvent (new Event(Event.COMPLETE, true, false));
		}
		
		
		// LAYER ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function updateDisplay (cacheGraphics:Boolean=true):void
		{
			super.updateDisplay();
		}
		
		public override function copy ():Layer
		{
			var newLayer:BitmapLayer = new BitmapLayer(canvas);
			
			newLayer.label = label;
			newLayer.alpha = alpha;
			newLayer.blendMode = blendMode;
			newLayer.depth = depth+1;
			newLayer.src = src;
			setInitProps();
			newLayer.initProps = initProps;
			
			newLayer.setup();
			
			return newLayer;
		}
		
		public override function updateDisplay (cacheGraphics:Boolean=true):void
		{
			/*line.applyProps();
			redraw();
			//if (cacheGraphics) 
			cache();*/
			generateThumb();
		}
		
		public function redraw ():void
		{
			/*clearSolid();
			line.draw(this);*/
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
			src = layerXML.solid.@src;
			
			setup();
		}
		
		public override function setTransformXML (xml:String):void
		{
			super.setXML(xml);
			//src = layerXML.solid.@src;
			if (initProps != null) applyInitProps();
		}
		
		public override function getXML ():XML
		{
			var newLayerXML:XML = new XML (<layer enabled={enabled} type={Layer.IMAGE} label={label} matrix={transformMatrixString} blendMode={blendMode} alpha={alpha} color={color} colorPercent={colorPercent} scaleX={scaleX} scaleY={scaleY} rotation={rotation} x={x} y={y}></layer>);
			
			newLayerXML.appendChild(<solid src={src} />);
			
			return newLayerXML;
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function contentLoad (e:Event):void
		{
			var loader:Loader = e.target.loader;
			
			solid = duplicateImage(Bitmap(loader.content));
			
			graphics.addChild(solid);
			
			assetCenter = {x:solid.width/2, y:solid.height};
			
			loaded = true;

			initLayer();
		}
		
		private function loadError (e:IOErrorEvent):void
		{
			//loader = FileManager.loadImage(FileManager.missingLayerFile, contentLoad);
			dispatchEvent (new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function duplicateImage (original:Bitmap):Bitmap 
		{
            var image:Bitmap = new Bitmap(original.bitmapData.clone(), PixelSnapping.AUTO, true);
            return image;
        }
		
		
		// LEGACY ///////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function layerComplete (e:Event):void
		{
			//e.target.removeEventListener(e.type, layerComplete);
			loaded = true;
			initLayer();
		}*/
	}
}