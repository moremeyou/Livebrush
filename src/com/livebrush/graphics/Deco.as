package com.livebrush.graphics
{

	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.IOErrorEvent;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.PixelSnapping
	import flash.geom.Matrix;
	import flash.geom.Transform;
	import flash.filters.BlurFilter;
	import flash.filters.BitmapFilterQuality;
	import com.livebrush.geom.ColorMatrix;
	import com.livebrush.data.Storable;
	import com.livebrush.data.FileManager;
	import com.livebrush.styles.DecoStyle;
	import com.livebrush.styles.DecoAsset;
	import com.livebrush.ui.Consol;
	import com.livebrush.data.Settings;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.data.GlobalSettings;
	import com.livebrush.transform.TransformSprite;
	
	import org.casalib.util.ColorUtil;
	import org.casalib.math.Percent;
	
	
	public class Deco extends EventDispatcher implements Storable
	{
		
		public static const STATIC					:String = "static";
		public static const DYNAMIC					:String = "dynamic";
		
		public static var idList					:Array = [];
		public var id								:int;
		private var ctf								:ColorTransform;
		public var type								:String = STATIC;
		public var pos								:Number; // the position on the edge 
		public var offset							:Object; // x,y offsets from the pos - only edited when we're editing the deco
		public var decoAsset						:DecoAsset;
		public var align							:String;
		public var initObj							:Settings
		private var brushState						:Object = null;
		private var drawn							:Boolean = false;
		private var bmp								:BitmapData;
		private var decoSprite						:Sprite; // this is the master object we apply color transformations to
		public var decoMC							:TransformSprite; // this is where we apply tr
		private var decoBitmap						:Bitmap = null;
		public var colorPercent						:Number = 1;
		public var scale							:Object;
		public var angle							:Number;
		public var x								:Number;
		public var y								:Number;
		public var alpha							:Number;
		public var color							:Number = -1;
		private var drawQueue						:Object = null;
		private var _matrix							:Matrix;
		private var emptyCTF						:ColorTransform;
		
		
		public function Deco (_decoAsset:DecoAsset, initObj:Settings=null):void
		{
			id = getNewID();
			
			brushState = {};

			decoAsset = _decoAsset;

			this.initObj = initObj;

			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get loaded ():Boolean {   return decoAsset.loaded;   }
		//public function get matrix ():Matrix {   return decoBitmap.transform.matrix;   }
		//public function get matrix ():Matrix {   return _matrix;   }
		//public function get transformMatrixString ():String {   var m:Matrix=matrix; return (m.a + "," + m.b + "," + m.c + "," + m.d + "," + m.tx + "," + m.ty);   }
		//public function set matrix (m:Matrix):void {   _matrix = m;   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			decoMC = new TransformSprite();
			decoSprite = new Sprite();
			
			offset = {x:0,y:0};
			
			applyProps();
			
			brushState.id = id;
			brushState.color = color;
			brushState.alpha = alpha;
			
			emptyCTF = new ColorTransform();
			
			decoAsset.addEventListener(Event.COMPLETE, decoAssetLoad);
		}
		
		public function die ():void
		{
			removeDeco();
		}
		
		private function applyProps ():void
		{
			for (var prop:String in initObj)
			{
				this[prop] = initObj[prop];
			}
		}
		
		
		// DECO ACTIONS /////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function draw (decos:Sprite):void
		{
			if (loaded) 
			{
				removeDeco();
				
				decoMC = new TransformSprite();
				
				decoMC.addChild(decoAsset.graphic);
				
				if (align == DecoStyle.ALIGN_CENTER) decoMC.setRegistration(decoMC.width/2, decoMC.height/2);
				else if (align == DecoStyle.ALIGN_TL) decoMC.setRegistration(0, 0);
				else decoMC.setRegistration(0, decoMC.height);
				
				decos.addChild(decoMC);
				var bounds:Rectangle;
				
				if (scale.y == 0) scale.y = scale.x;
				decoMC.scale(scale.x, scale.y);
				
				decoMC.rotation2 = angle;
				decoMC.translate(x, y);
				
				bounds = decoMC.getBounds(decos);
				//bounds.width = Math.min()
				var b:Point = new Point(int(Math.max(2,bounds.width)), int(Math.max(2,decoMC.height)));
				try { bmp = new BitmapData(b.x, b.y, true, 0x00FF0000); }
				catch (e:Error) { bmp = new BitmapData(b.x, b.x, true, 0x00FF0000); }
				catch (e:Error) { bmp = new BitmapData(b.y, b.y, true, 0x00FF0000); } // // Consol.Trace("2 - " + e);
				catch (e:Error) { bmp = new BitmapData(50, 50, true, 0x00FF0000); } // // Consol.Trace("3 - " + e);
				catch (e:Error) { return }
				decoBitmap = new Bitmap(bmp, PixelSnapping.AUTO, true);
				decoBitmap.x = bounds.x;
				decoBitmap.y = bounds.y;
				decos.addChild(decoBitmap);
				//// // Consol.Trace("deco success")
				decoSprite = new Sprite();
				decoSprite.transform.matrix = decoBitmap.transform.matrix;
				decoSprite.addChild(decoMC);
				decos.addChild(decoSprite);
				
				bounds = decoSprite.getBounds(decoSprite);
				var mat:Matrix = decoSprite.transform.matrix;
				mat.tx = -bounds.x;
				mat.ty = -bounds.y;
				bmp.draw(decoSprite, mat);

				decos.removeChild(decoSprite);
 
				// apply color and color tint, and alpha to bitmap holder
				setColor();
				
				decoBitmap.alpha = alpha;
			}
			else
			{
				drawQueue = {target:decos};
			}
		}
		
		public function removeDeco ():void
		{
			//if (graphic.numChildren > 0) graphic.removeChild(graphic.getChildAt(0));
			if (decoSprite.numChildren > 0) decoSprite.removeChild(decoSprite.getChildAt(0));
			if (decoMC.numChildren > 0) decoMC.removeChild(decoMC.getChildAt(0));
			if (decoBitmap != null) 
			{
				bmp.dispose();
				decoBitmap.bitmapData = null;
				decoBitmap = null;
				bmp = null;
			}
			decoMC = null;
		}
		
		
		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function setXML (xml:String):void { }
		
		public static function xmlToDeco (xml:String):Deco
		{
			var decoXML:XML = new XML (xml);
			
			var decoAsset = FileManager.getInstance().getDecoAsset(decoXML.@asset);
			
			var initObj:Settings = new Settings ();
			
			initObj.pos = Number(decoXML.@pos);
			
			initObj.offset = {x:Number(decoXML.@offsetX), y:Number(decoXML.@offsetY)};
			
			initObj.scale = {x:Number(decoXML.@scaleX), y:Number(decoXML.@scaleY)}
			
			initObj.angle = Number(decoXML.@angle);
			initObj.color = Number(decoXML.@color);
			if (decoXML.@colorPercent != null) initObj.colorPercent = Number(decoXML.@colorPercent);
			initObj.alpha = Number(decoXML.@alpha);
			initObj.align = String(decoXML.@align);
			
			var deco:Deco = new Deco (decoAsset, initObj);
			
			return deco;
		}
		
		public function getXML ():XML
		{
			var decoXML:XML = new XML (<deco id={id} asset={decoAsset.fileName} pos={pos} offsetX={offset.x} offsetY={offset.y} scaleX={scale.x} scaleY={scale.y} angle={angle} color={color} colorPercent={colorPercent} alpha={alpha} align={align}/>);
			return decoXML;
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function decoAssetLoad (e:Event):void
		{
			if (drawQueue != null) 
			{
				//trace("UN CACHED DECO LOADED. DRAWING FROM QUEUE.");
				draw(drawQueue.target);
				drawQueue = null;
			}
			
			dispatchEvent (new Event(Event.COMPLETE, true, false));
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function copy ():Deco
		{
			// pass true to copy if global setting is don't cache decos
			return new Deco(decoAsset.copy(), initObj);
		}
		
		protected function setColor ():void
		{
			//// // Consol.Trace(colorPercent);
			if (color != -1)
			{
				var newCTF:ColorTransform = new ColorTransform();
				newCTF.color = color;
				ctf = decoBitmap.transform.colorTransform = ColorUtil.interpolateColor(new ColorTransform(), newCTF, new Percent(colorPercent));
				//graphics.transform.colorTransform = 
			}
		}
		
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
		
		public static function stringToMatrix (str:String):Matrix
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
		
		
		// TBD / DEBUG //////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

	}
	
	
}