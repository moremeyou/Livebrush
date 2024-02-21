package com.livebrush.graphics.canvas
{
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.EventPhase;
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
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.events.IOErrorEvent;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.filters.BlurFilter;
	import flash.utils.getTimer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.IOErrorEvent;
	import flash.display.SWFVersion;
	import flash.display.ActionScriptVersion;
	import flash.text.TextField;
	
	import com.livebrush.data.Exchangeable;
	import com.livebrush.data.Settings;
	import com.livebrush.data.Storable;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.graphics.canvas.SWFLayer;
	import com.livebrush.graphics.Line;
	import com.livebrush.data.FileManager;
	import com.livebrush.data.GlobalSettings;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UI;
	
	
	public class SWFLayer extends ImageLayer implements Storable
	{
		
		public function SWFLayer (canvas:Canvas, depth:int=0):void
		{
			super(canvas, depth);
			_type = Layer.SWF;
			init();
		}

		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
		}
		
		public override function setup ():void
		{
			loader = FileManager.loadLayerImage(src, contentLoadListener);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
		}

		private function layerComplete ():void
		{
			if (initProps != null) applyInitProps();
			
			dispatchEvent (new Event(Event.COMPLETE, true, false));
		}
		
		
		// LAYER ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function setupContent (loader:Loader, info:LoaderInfo):void
		{
			var content:Sprite;
			//var str:String = "Right Version (" + info.url + "): " + (info.actionScriptVersion == ActionScriptVersion.ACTIONSCRIPT3 && info.swfVersion == SWFVersion.FLASH9)
			//// // Consol.Trace(str);
			//trace(str);
			if (loader.content is MovieClip && info.actionScriptVersion == ActionScriptVersion.ACTIONSCRIPT3 && info.swfVersion == SWFVersion.FLASH9)
			{
				if (MovieClip(loader.content).numChildren > 0)
				{
					var swf:MovieClip = loader.content as MovieClip;
	
					if (swf.getChildAt(0) is Sprite)
					{
						content = swf.getChildAt(0) as Sprite
					}
					else
					{
						content = Sprite(new DefaultDeco());
						UI.MAIN_UI.alert({message:"<b>Missing SWF Asset</b>\nYour SWF should have a MovieClip on the first frame of the main timeline. <b><a href='http://www.Livebrush.com/help/SWF_Support.html' target='_blank'>Click here</a></b> for Livebrush Help.", id:"layerSWFAlert"});
					}
					
					graphics.addChild(content);
					content.transform.matrix = new Matrix;
					
					var bounds:Rectangle = content.getBounds(content);
					content.x -= bounds.x;
					content.y -= bounds.y;
					
					assetCenter = {x:bounds.width/2, y:bounds.height};
				}
			}
			else
			{
				content = Sprite(new DefaultDeco());
				graphics.addChild(content);
				UI.MAIN_UI.alert({message:"<b>Invalid Layer Asset</b>\nSWF assets must be exported for Flash Player 9 using Actionscript 3. <b><a href='http://www.Livebrush.com/help/SWF_Support.html' target='_blank'>Click here</a></b> for Livebrush Help.", id:"layerSWFAlert"});
			}
			
			loaded = true;
			layerComplete();
		}
		
		public override function copy ():Layer
		{
			var newLayer:SWFLayer = new SWFLayer(canvas);
			
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


		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function getXML ():XML
		{
			var newLayerXML:XML = new XML (<layer enabled={enabled} type={Layer.SWF} label={label} matrix={transformMatrixString} blendMode={blendMode} alpha={alpha} color={color} colorPercent={colorPercent} scaleX={scaleX} scaleY={scaleY} rotation={rotation} x={x} y={y}></layer>);
			
			newLayerXML.appendChild(<solid src={src} />);
			
			return newLayerXML;
		}
		
		/*private function swfErrorAlert ():void
		{
			UI.MAIN_UI.alert({message:"Invalid Layer Content\nSWF Layers must be exported for Flash Player 9 using Actionscript 3. Visit <b><a href='http://www.Livebrush.com/help/SWF_Support.html' target='_blank'>Livebrush Help</a></b> for more details.", id:"layerSWFAlert"});
		}*/
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function contentLoadListener (e:Event):void
		{
			setupContent(e.target.loader, e.target as LoaderInfo);
		}
		
		private function layerCompleteHandler (e:Event):void
		{
			loaded = true;
			layerComplete();
		}
		
		private function loadErrorHandler (e:IOErrorEvent):void
		{
			var child:Sprite = new DebugDeco ();
			graphics.addChild(child);
			
			//loaded = true;
			//layerComplete();
			dispatchEvent (new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function drawTo (bitmap:Bitmap):void
		{
			bitmap.bitmapData.draw(graphics, graphics.transform.matrix, graphics.transform.colorTransform, graphics.blendMode, null, true);
		}
		
		public override function hitTest (x:Number, y:Number):Boolean
		{
			return graphics.hitTestPoint(x, y, true);
		}
		
		public override function mouseHitTest ():Boolean
		{
			//return solid.bitmapData.hitTest(new Point(0, 0), 0x00, new Point(solid.mouseX, solid.mouseY));
			return graphics.hitTestPoint(graphics.stage.mouseX, graphics.stage.mouseY, true);
		}
		

	}
}