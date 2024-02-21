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
	import com.livebrush.data.Exchangeable;
	import com.livebrush.data.Settings;
	import com.livebrush.data.Storable;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.Line;
	import com.livebrush.data.FileManager;
	import com.livebrush.data.GlobalSettings;
	import flash.text.TextField;
	import com.livebrush.ui.Consol;
	
	public class ColorLayer extends Layer implements Storable
	{
	
		public function ColorLayer (canvas:Canvas, depth:int=0):void
		{
			super(canvas, depth);
			_type = Layer.COLOR;
			init();
		}
		
		
		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			solid = new Bitmap(new BitmapData(Canvas.WIDTH, Canvas.HEIGHT, false, 0x00000000), PixelSnapping.AUTO, true);
			graphics.addChild(solid);
			setInitProps();
		}
		
		public override function setup ():void
		{
			solid.bitmapData.floodFill(0, 0, color);
			applyInitProps();
		}
		
		
		// LAYER ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function copy ():Layer
		{
			var newLayer:ColorLayer = new ColorLayer(canvas);
			
			newLayer.label = label;
			newLayer.alpha = alpha;
			newLayer.blendMode = blendMode;
			newLayer.depth = depth+1;
			newLayer.color = color;
			setInitProps();
			newLayer.initProps = initProps;

			newLayer.setup();
			
			return newLayer;
		}
		
		
		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function setXML (xml:String):void
		{
			super.setXML(xml);
			color = parseInt(layerXML.solid.@color);
			
			//applyInitProps();
			
			setup();
			
			dispatchEvent (new Event(Event.COMPLETE, true, false));
		}
		
		public override function getXML ():XML
		{
			var newLayerXML:XML = new XML (<layer enabled={enabled} type={Layer.COLOR} label={label} matrix={transformMatrixString} blendMode={blendMode} alpha={alpha} scaleX={scaleX} scaleY={scaleY} rotation={rotation} x={x} y={y} color={color} colorPercent={colorPercent}></layer>);
			newLayerXML.appendChild(<solid color={color} />);
			
			return newLayerXML;
		}
		
		protected override function applyInitProps ():void
		{
			x = initProps.x;
			y = initProps.y;
			rotation = initProps.rotation;
			scaleX = initProps.scaleX;
			scaleY = initProps.scaleY;
			enabled = initProps.enabled;
			//// // Consol.Trace(initProps.matrix);
			if (initProps.matrix != null) transform.matrix = stringToMatrix(initProps.matrix)
			alpha = initProps.alpha;
		}

	}
}