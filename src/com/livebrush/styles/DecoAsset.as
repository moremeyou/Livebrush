package com.livebrush.styles
{
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.Bitmap;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.IOErrorEvent;
	import flash.display.Sprite;
	import flash.display.PixelSnapping;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.display.SWFVersion;
	import flash.display.ActionScriptVersion;
	
	import com.livebrush.data.FileManager;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UI;
	
	public class DecoAsset extends EventDispatcher
	{
		
		public static const JPG						:String = "image/jpeg";
		public static const GIF						:String = "image/gif";
		public static const PNG						:String = "image/png";
		public static const SWF						:String = "application/x-shockwave-flash";
		
		public static var idList					:Array = [];
		public var id								:int;
		public var assetPath						:String;
		public var fileName							:String;
		public var loaded							:Boolean;
		public var graphic							:Sprite;
		public var bitmap							:Bitmap;
		private var fileManager						:FileManager;
		private var loader							:Loader;
		public var contentType						:String;// = PNG;
		public var enabled							:Boolean = true;
		public var missing							:Boolean = true;
		
		
		public function DecoAsset (assetPath:String, asset:Sprite=null, contentType:String=SWF):void
		{
			//var msg:String = "This will not load a new deco asset. This will only be used when copying existing assets. Use fileManager.getDecoAsset(path)";
			//trace(msg + " : " + assetPath);
			//// // Consol.Trace(msg + " : " + assetPath);
			//throw(new Error("sdf"));
			id = getNewID();
			
			loaded = false;
			this.assetPath = assetPath;
			fileName = assetPath.substr(assetPath.lastIndexOf("/")+1);
			
			fileManager = FileManager.getInstance();
			
			if (asset == null) 
			{
				graphic = new Sprite();
				loadAsset();
			}
			else
			{
				graphic = asset;
				this.contentType = contentType;
				if (contentType != SWF) bitmap = graphic.getChildAt(0) as Bitmap;
				loaded = true;
			}
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get value ():String {   return fileName;   }
		//public function get enabled ():Boolean {   return true;   }
		
		
		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void { }
		
		public function die ():void {}
		
		
		// ACTIONS //////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function setup (loader:Loader, info:LoaderInfo):void
		{
			contentType = info.contentType;
			var swf:MovieClip;
			var child:Sprite;
			
			if (contentType != SWF) 
			{
				bitmap = loader.content as Bitmap;
				bitmap.smoothing = true;
				graphic.addChild(bitmap);
				missing = false;
			}
			else if (loader.content is MovieClip && info.actionScriptVersion == ActionScriptVersion.ACTIONSCRIPT3 && int(info.swfVersion) >= int(SWFVersion.FLASH9))
			{
				if (MovieClip(loader.content).numChildren > 0)
				{
					swf = MovieClip(loader.content);
					
					if (swf.getChildAt(0) is Sprite)
					{
						child = Sprite(swf.getChildAt(0));
						//child.transform = new Transform()
						child.x = child.y = 0;
					}
					else
					{
						child = Sprite(graphic.addChild(new DefaultDeco()));
						UI.MAIN_UI.alert({message:"<b>Missing SWF Asset</b>\nYour SWF should have a MovieClip on the first frame of the main timeline. <b><a href='http://www.livebrush.com/help/start.html#import' target='_blank'>Click here</a></b> for Livebrush Help.", id:"decoSWFAlert"});
					}
					
					var bounds:Rectangle = child.getBounds(child);
					child.x -= bounds.x;
					child.y -= bounds.y;
					
					graphic.addChild(child);
					missing = false;
				}
			}
			else
			{
				child = Sprite(new DefaultDeco());
				graphic.addChild(child);
				UI.MAIN_UI.alert({message:"<b>Invalid Layer Asset</b>\nSWF assets must be exported for Flash Player 9+ using Actionscript 3. <b><a href='http://www.livebrush.com/help/start.html#import' target='_blank'>Click here</a></b> for Livebrush Help.", id:"decoSWFAlert"});
			}
			
			loaded = true;
			
			dispatchEvent (new Event(Event.COMPLETE, true, false));
		}
		
		public function loadAsset ():void
		{
			loader = fileManager.decoLoader(fileName);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			loader.contentLoaderInfo.addEventListener(Event.INIT, loadInitHandler);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);
		}

		public function copy (reload:Boolean=false):DecoAsset
		{
			return new DecoAsset (assetPath, reload?null:graphic, contentType);
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function loadInitHandler (e:Event):void { }
		
		private function loadCompleteHandler (e:Event):void
		{
			removeLoadHandlers (e.target as LoaderInfo);
			
			loader = e.target.loader; //.content;
		
			setup(loader, e.target as LoaderInfo);
		}
		
		private function loadErrorHandler (e:IOErrorEvent):void
		{
			contentType = SWF;
			loaded = true;
			removeLoadHandlers (e.target as LoaderInfo);
			// // Consol.Trace("DecoAsset: deco load error");
			var child:Sprite = new MissingDeco ();
			graphic.addChild(child);
			
			dispatchEvent (new Event(Event.COMPLETE, true, false));
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public static function getNewID ():int
		{
			var highestID:int = 0;
			var newID:int;
			for (var i:int=0; i<idList.length; i++)
			{
				if (idList[i] >= highestID) highestID = idList[i];
			}
			newID = highestID+1;
			idList.push(newID);
			return newID;
		}
		
		private function removeLoadHandlers (loaderInfo:LoaderInfo):void
		{
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			loaderInfo.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			loaderInfo.removeEventListener(Event.INIT, loadInitHandler);
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	}
	
}