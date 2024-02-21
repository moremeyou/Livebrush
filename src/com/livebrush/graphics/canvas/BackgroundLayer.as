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
	import com.livebrush.graphics.canvas.ColorLayer;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.Line;
	import com.livebrush.data.FileManager;
	import com.livebrush.data.GlobalSettings;
	import flash.text.TextField;
	import com.livebrush.ui.Consol;
	
	public class BackgroundLayer extends ColorLayer implements Storable
	{
		
		public static var DEFAULT_XML_STRING						:String = "<layer type=\"background\" label=\"Background [LOCKED]\" blendMode=\"layer\" alpha=\"1\" color=\"0\" colorPercent=\"1\"><solid color=\"0\"/></layer>";
		
		
		public function BackgroundLayer (canvas:Canvas, depth:int=0):void
		{
			super(canvas, depth)
			_type = Layer.BACKGROUND;
			label = "Background [LOCKED]";
			this.depth = depth;
			//init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function set linkedDepths (a:Array):void {      }
		public override function get alpha ():Number {   return 1; }
		public override function get colorPercent ():Number {   return 1;    }
		public override function get blendMode ():String {    return BlendMode.LAYER;    }
		
		// INIT & SETUP /////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// DATA MANAGEMENT & UTILS //////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function setXML (xml:String):void
		{
			super.setXML(xml);
			
			dispatchEvent (new Event(Event.COMPLETE, true, false));
			
			//applyInitProps();
		}
		
		public override function getXML ():XML
		{
			var newLayerXML:XML = new XML (<layer type={Layer.BACKGROUND} label={label} blendMode={blendMode} alpha={alpha} color={color} colorPercent={colorPercent}></layer>);
			newLayerXML.appendChild(<solid color={color} />);
			
			return newLayerXML;
		}
		
		protected override function setInitProps (settings:Settings=null):void
		{
		}
		
		protected override function applyInitProps ():void
		{
		}
		
		public static function getDefaultXML ():XML
		{
			return new XML(DEFAULT_XML_STRING);
		}

	}
}