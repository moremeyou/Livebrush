package com.livebrush.styles
{
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.events.IOErrorEvent;
	
	import com.livebrush.data.FileManager;
	import com.livebrush.data.Settings;
	import com.livebrush.data.Exchangeable;
	import com.livebrush.data.Storable;
	import com.livebrush.styles.Style;
	import com.livebrush.styles.StyleManager;
	//import com.livebrush.ui.LinePanel;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UI;
	
	
	public class LineStyle extends EventDispatcher implements Exchangeable, Storable 
	{
		public static const	NORMAL				:String = "normal";
		public static const	ELASTIC				:String = "elastic";
		public static const	DYNAMIC				:String = "dynamic";

		public var defaultSettings				:Settings;
		public var style 						:Style;
		public var styleManager					:StyleManager;
		//public var linePanel					:LinePanel;
		public var inputSWF						:String = "";
		private var _mouseUpComplete			:Boolean = false;
		public var moveFunction					:Function;
		private var _lockMouse					:Boolean = false;
		private var _type						:String = ELASTIC;
		private var _swf						:MovieClip;
		public var elastic						:Number = .52;
		public var friction						:Number = .47
		//public var expression					:String;
		//public var drawSpeed					:int = 100;
		public var smoothing					:Boolean = true;
		public var minDrawSpeed					:Number = .01;
		public var maxDrawSpeed					:Number = 100;
		private var inputLoader					:Loader;
		//public var maxStrokes					:int = 50;
		private var elasticMouseUpComplete		:Boolean = false;
		
		
		public function LineStyle (style:Style):void
		{
			this.style = style;
			styleManager = style.styleManager;
			
			defaultSettings = settings;
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get lockMouse	():Boolean {   return ((type == DYNAMIC) ? _lockMouse : false);   }
		public function set lockMouse (b:Boolean):void {   _lockMouse=b;   }
		public function get mouseUpComplete	():Boolean {   return ((type == DYNAMIC && !_mouseUpComplete) ? false : _mouseUpComplete);   } //return (((type == DYNAMIC || type == ELASTIC)) ? _mouseUpComplete : false);
		public function set mouseUpComplete (b:Boolean):void {   _mouseUpComplete=b;   }
		public function get type ():String {   return (_type!=DYNAMIC ? _type : ((_type==DYNAMIC && inputSWF != null && inputSWF != "null" && inputSWF != "") ? DYNAMIC : NORMAL))   };
		public function set type (t:String):void {   _type = t;   };
		public function get settings ():Settings
		{
			var settings:Settings = new Settings();
		 
		 	settings.lockMouse = lockMouse;
			settings.inputSWF = inputSWF;
			settings.mouseUpComplete = mouseUpComplete;
			settings.type = type;
			settings.elastic = elastic;
			settings.friction = friction;
			settings.minDrawSpeed = minDrawSpeed;
			settings.maxDrawSpeed = maxDrawSpeed;
			settings.smoothing = smoothing;
			
			return settings;
		}
		
		public function set settings (settings:Settings):void
		{
			//// // Consol.Trace("Current type: " + type + " : New Type: " + settings.type);
			
			inputSWF = settings.inputSWF;
			mouseUpComplete = settings.mouseUpComplete
			
			if (settings.type == ELASTIC && type != ELASTIC) mouseUpComplete = elasticMouseUpComplete;
			else if (settings.type != ELASTIC && type == ELASTIC) elasticMouseUpComplete = mouseUpComplete;
			
			// this is just for when they change the input type
			if (settings.type != DYNAMIC && type == DYNAMIC) unloadInputSWF();
			else if (settings.type == DYNAMIC && type != DYNAMIC) mouseUpComplete = true;
			
			type = settings.type;
			
			// this is just for when they change the input type
			if (type == DYNAMIC) loadInputSWF();
			
			lockMouse = settings.lockMouse;
			elastic = settings.elastic;
			friction = settings.friction;
			minDrawSpeed = settings.minDrawSpeed;
			maxDrawSpeed = settings.maxDrawSpeed;
			smoothing = settings.smoothing;

			
		}
		
		
		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function die ():void
		{
			unloadInputSWF();
			delete this;
		}
		
		
		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function getXML ():XML
		{
			var lineXML:XML = new XML(<line/>);
			
			lineXML.appendChild(<type>{type}</type>);
			lineXML.appendChild(<inputSWF>{(type==DYNAMIC?inputSWF:"")}</inputSWF>);
			lineXML.appendChild(<elastic>{elastic}</elastic>);
			lineXML.appendChild(<friction>{friction}</friction>);
			//lineXML.appendChild(<expression>{expression}</expression>);
			lineXML.appendChild(<drawSpeed>{minDrawSpeed+","+maxDrawSpeed}</drawSpeed>);
			lineXML.appendChild(<smoothing>{smoothing}</smoothing>);
			lineXML.appendChild(<mouseUpComplete>{mouseUpComplete}</mouseUpComplete>);
			
			return lineXML;
			
		}
		
		public function setXML (xml:String):void
		{
			var lineXML:XML = new XML (xml);
			for each (var element:XML in lineXML.*)
			{
				try
				{
					
					if (element.name() == "drawSpeed") 
					{
						var drawSpeed:Array = element.toString().split(",");
						minDrawSpeed = drawSpeed[0];
						maxDrawSpeed = drawSpeed[1];
					}
					else if (element.name() == "smoothing") 
					{
						smoothing = element=="true" ? true : false;
					}
					else if (element.name() == "mouseUpComplete") 
					{
						mouseUpComplete = element=="true" ? true : false;
					}
					else 
					{
						this[element.name()] = element;
					}
					
				} catch (e:Error){}
			}
		}
		
		public function setDynamicInput (path:String):void
		{
			inputSWF = path;
			type = DYNAMIC;
			//// // Consol.Trace(inputSWF + " : " + type);
		}
		
		public function loadInputSWF ():void
		{
			//// // Consol.Trace("Loading SWF " + inputSWF);
			//// // Consol.Trace("Loading SWF type " + (inputSWF == null));
			if (inputLoader != null) unloadInputSWF();
			inputLoader = FileManager.getInstance().loadInputSWF(inputSWF, inputSWFLoaded, loadErrorHandler);
		}
		
		public function unloadInputSWF ():void
		{
			try 
			{
				inputLoader.unload();
				inputLoader = null;
				//// // Consol.Trace("Unloading SWF " + inputSWF);
			}
			catch(e:Error)
			{
			}
			finally
			{
			}
		}
		
		
		// STYLE ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function clone (style:Style):LineStyle
		{
			var lineStyle:LineStyle = new LineStyle(style);
			lineStyle.settings = settings;
			
			return lineStyle;
		}
		
		public function getDynamicControl ():Object
		{
			var o:Object;
			
			try 
			{
				o = _swf.getBrushControl();
			}
			catch (e:Error)
			{
				UI.MAIN_UI.alert({message:"<b>Dynamic Input Actionscript Error</b>\n\n<b><a href='http://www.Livebrush.com/help/SWF_Support.html' target='_blank'>Click here</a></b> for Livebrush Help.", id:"inputSWFAlert"});
				inputSWF = "";
				type = NORMAL;
				//styleManager.pushStyle();
			}
			
			return o;
		}
		
		
		// EVENT ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function inputSWFLoaded (e:Event)
		{
			try
			{
				_swf = MovieClip(e.target.content); // as MovieClip;
				//moveFunction = _swf.getBrushControl().move;
				//swf.addEventListener(Event.COMPLETE, inputComplete);
				//// // Consol.Trace(e.target.content);
				//// // Consol.Trace("Dyamic Input SWF Loaded");
			}
			catch (e:Error)
			{
				//// // Consol.Trace("Dyamic Input SWF is NOT Flash 9 AS3 MovieClip Object");
				
				UI.MAIN_UI.alert({message:"<b>Invalid Dynamic Input SWF</b>\nSWF's must be exported for Flash Player 9 using Actionscript 3. <b><a href='http://www.Livebrush.com/help/SWF_Support.html' target='_blank'>Click here</a></b> for Livebrush Help.", id:"inputSWFAlert"});
				inputSWF = "";
				type = NORMAL;
			}
				//D:\Working\Projects\LiveBrush\App\dev\SWF Assets
		}
		
		private function loadErrorHandler (e:IOErrorEvent):void
		{
			//// // Consol.Trace("Dyamic Input SWF Missing");
			type = NORMAL;
			
			UI.MAIN_UI.alert({message:"<b>Missing Dynamic Input SWF</b>\n\n<b><a href='http://www.Livebrush.com/help/SWF_Support.html' target='_blank'>Click here</a></b> for Livebrush Help.", id:"inputSWFAlert"});
			inputSWF = "";
			type = NORMAL;
			
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////

		
		
	}
}