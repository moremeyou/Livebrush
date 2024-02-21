package com.livebrush.styles
{
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	import com.livebrush.data.Settings;
	import com.livebrush.data.Exchangeable;
	import com.livebrush.data.Storable;
	import com.livebrush.styles.*
	import com.livebrush.ui.Consol;
	import com.livebrush.utils.ColorObj;
	
	public class Style extends EventDispatcher implements Storable 
	{
		public static var idList				:Array = [];
		
		public var id							:int;
		public var decoStyle					:DecoStyle;
		public var lineStyle					:LineStyle;
		public var strokeStyle					:StrokeStyle;
		public var styleManager 				:StyleManager;
		public var name							:String;
		//private var _linkedStyles				:Array;
		
		public function Style (styleManager:StyleManager):void
		{
			id = getNewID();
			
			name = "Style_"+id;
			
			this.styleManager = styleManager;
			
			decoStyle = new DecoStyle(this);
			lineStyle = new LineStyle(this);
			strokeStyle = new StrokeStyle(this);
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*public function get isLinked ():Boolean {   return (_linkedStyles.length>0);   }
		public function set linkedStyles (a:Array):void {   _linkedStyles=a.slice();   }
		public function get linkedStyles ():Array {   return _linkedStyles;   }*/
		public function get settings ():Settings
		{
			var settings:Settings = new Settings();
			
			settings.line = lineStyle.settings;
			settings.stroke = strokeStyle.settings;
			settings.deco = decoStyle.settings;
			
			return settings;
		}
		
		public function set settings (settings:Settings):void
		{
			lineStyle.settings = settings.line;
			strokeStyle.settings = settings.stroke;
			decoStyle.settings = settings.deco;
		}
		
		
		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function die ():void
		{
			lineStyle.die();
			strokeStyle.die();
			decoStyle.die();
		}
		
		
		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function getXML ():XML
		{
			var styleXML:XML = new XML (<style name={name} type="style" />); // should be fileType
			
			styleXML.appendChild(lineStyle.getXML());
			styleXML.appendChild(strokeStyle.getXML());
			styleXML.appendChild(decoStyle.getXML());
			
			return styleXML;
		}
		
		public function setXML (xml:String):void
		{
			var styleXML:XML = new XML (xml);
			
			name = styleXML.name;
			
			decoStyle.setXML(styleXML.deco);
			lineStyle.setXML(styleXML.line);
			strokeStyle.setXML(styleXML.stroke);
			
			//// // Consol.Trace(name + " : " + strokeStyle.strokeType + " : " + id);
			
		}
		
		
		// STYLE ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function clone ():Style
		{
			var style:Style = new Style(styleManager);
			style.lineStyle = lineStyle.clone(style);
			style.strokeStyle = strokeStyle.clone(style);
			style.decoStyle = decoStyle.clone(style);
			return style;
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public static function objToColorObj (o:Object):ColorObj
		{
			return new ColorObj(o.value, o.enabled);
		}
		
		public static function objListToColorObjList (list:Array):Array
		{
			var colorList:Array = [];
			for (var i:int=0; i<list.length; i++)
			{
				//// // Consol.Trace(list[i].value);
				colorList.push(objToColorObj(list[i]));
			}
			return colorList;
		}
	
		public static function propEnabledListToXML (list:Array, valuePropName:String="value", enabledPropName:String="enabled", propName:String="Properties", groupSuffix:String="List"):XML
		{
			var propXML:XML = new XML(<{propName+groupSuffix} />);
			//propXML.name = propName+groupSuffix;
			
			for (var i:int=0; i<list.length; i++)
			{
				propXML.appendChild(<{propName} {valuePropName}={list[i][valuePropName]} {enabledPropName}={list[i][enabledPropName]} />); 
			}
			//// // Consol.Trace(propXML);
			
			return propXML;
		}
		
		public static function propEnabledXMLToList (xml:XMLList):Array
		{
			var list:Array = [];
			
			for each (var element:XML in xml)
			{
				//// // Consol.Trace(element);
				list.push({value:String(element.@value), enabled:element.@enabled=="true"?true:false});
			}
				
			return list;
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
		

		
	}
	
	
}