package com.livebrush.styles
{
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import fl.motion.Color;
	
	import com.livebrush.data.Settings;
	import com.livebrush.data.Exchangeable;
	import com.livebrush.data.Storable;
	import com.livebrush.styles.Style;
	import com.livebrush.styles.StyleManager;
	//import com.livebrush.ui.StrokePanel;
	import com.livebrush.ui.Consol;
	import com.livebrush.utils.ColorObj;
	
	public class StrokeStyle implements Exchangeable, Storable 
	{
		
		public static const SOLID_STROKE			:String = "solid";
		public static const RAKE_STROKE				:String = "rake";
		public static const PATH_STROKE				:String = "path";
		
		public static const WIDTH					:String = "width";
		public static const DIR						:String = "direction";
		public static const ROTATE					:String = "rotate";
		
		public static const FIXED					:String = "fixed";
		public static const NONE					:String = "none";
		public static const OSC						:String = "osc";
		public static const RANDOM					:String = "random";
		public static const SPEED					:String = "speed";
		public static const LIST					:String = "list";
		public static const SAMPLE					:String = "sample";
		public static const SAMPLE_BRUSH			:String = "sampleBrush";
		public static const PRESSURE				:String = "pressure";
		
		public static const SMOOTH					:String = "smooth";
		public static const STRAIGHT				:String = "straight";
		
		public var defaultSettings					:Settings;
		public var style 							:Style;
		public var styleManager						:StyleManager;
		//public var strokePanel						:StrokePanel;
		public var strokeType						:String = SOLID_STROKE;
		public var lines							:int = 2;
		public var weight							:Number = 1;
		public var angleType						:String = DIR;		
		public var minAngle							:Number = 0;
		public var maxAngle							:Number = 180;
		public var angleSpeed						:Number = 50;
		public var widthType						:String = SPEED;
		public var minWidth							:Number = 2;
		public var maxWidth							:Number = 75;
		public var widthSpeed						:Number = 50;
		
		private var _colorType						:String = LIST;
		private var _colorList						:Array;
		public var colorSteps						:int = 50;
		public var _colorObjList					:Array;
		private var _colorHold						:int = 1;
		
		public var alphaType						:String = FIXED;
		public var minAlpha							:Number = 1;
		public var maxAlpha							:Number = 1;
		public var alphaSpeed						:Number = 10;
		public var thresholds						:Object;
		private var _decorate						:Boolean = true;

		
		public function StrokeStyle (style:Style):void
		{
			this.style = style;
			colorObjList = [new ColorObj(0x000000), new ColorObj(0xFFFFFF)];
			styleManager = style.styleManager;
			thresholds = {speed:{min:50, max:100, enabled:false}, width:{min:50, max:100, enabled:false}, angle:{min:0, max:180, enabled:false}, distance:{min:100, max:500, enabled:false}, random:{min:10, max:10, enabled:false}, interval:{min:1000, max:1000, enabled:false}};
			defaultSettings = settings;
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		//public function get colorType ():String {   return ((_colorList.length==1 && (_colorType != NONE || _colorType != FIXED || _colorType != SAMPLE)) ? FIXED : _colorType);   }
		public function get colorHold ():Number {   return _colorHold;   }
		public function set colorHold (n:Number):void {   _colorHold = Math.max(1, n);   }
		public function get colorType ():String {   return _colorType;  }
		public function set colorType (s:String):void {   _colorType = s;   }
		public function get colorList ():Array {   return _colorList;   }
		public function get colorObjList ():Array {   return _colorObjList;   }
		public function get colorStringObjList ():Array {   var stringObjList:Array=[]; for(var i:int=0; i<colorObjList.length; i++) stringObjList.push({value:colorObjList[i].colorString, enabled:colorObjList[i].enabled}); return stringObjList;   }
		public function set colorObjList (list:Array):void {   _colorObjList=list; _colorList=[]; for(var i:int=0; i<list.length; i++) if (list[i].enabled) _colorList.push(list[i].color);   }
		public function get selectedColor ():Number {   return colorList[0];   } // colorList.length-1
		public function get decorate ():Boolean {   return (style.decoStyle.decoSet.activeLength>0 ? _decorate : false);   }
		public function set decorate (b:Boolean):void {   _decorate = b;   }
		
		public function get settings ():Settings
		{
			var settings:Settings = new Settings();
		 	
			settings.strokeType = strokeType;
			settings.lines = lines;
			settings.weight = weight;
			settings.angleType = angleType;
			settings.minAngle = minAngle;
			settings.maxAngle = maxAngle;
			settings.angleSpeed = angleSpeed;
			settings.widthType = widthType;
			settings.minWidth = minWidth;
			settings.maxWidth = maxWidth;
			settings.widthSpeed = widthSpeed;
			
			settings.colorType = colorType;
			settings.colorSteps = colorSteps;
			settings.colorObjList = Settings.copyArrayOfObjects(colorObjList);
			settings.colorHold = colorHold;
			
			settings.alphaType = alphaType;
			settings.minAlpha = minAlpha;
			settings.maxAlpha = maxAlpha;
			settings.alphaSpeed = alphaSpeed;
			
			settings.thresholds = Settings.copyObject(thresholds);
			
			return settings;
		}
		
		public function set settings (settings:Settings):void
		{

			for (var propT:String in settings.thresholds)
			{
				this.thresholds[propT] = settings.thresholds[propT];
			}
			
			setDecorate();
			
			for (var prop:String in settings)
			{
				
				if (prop != "thresholds") 
				{
					//// // Consol.Trace(prop);
					try {   this[prop] = settings[prop];   } catch (e:Error) {}
				}
			}
			
			lines = strokeType==SOLID_STROKE ? Math.max(2, lines) : Math.max(1, lines);
			
			//// // Consol.Trace(widthSpeed);
			
			//colorListToHex();
		}
		

		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function die ():void
		{
			delete this;
		}
		
		
		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function getXML ():XML
		{
			var strokeXML:XML = new XML(<stroke/>);
			
			strokeXML.appendChild(varStringToXML("strokeType"));
			strokeXML.appendChild(<minWidth>{minWidth}</minWidth>);
			strokeXML.appendChild(<minAlpha>{minAlpha}</minAlpha>);
			strokeXML.appendChild(<angleType>{angleType}</angleType>);
			strokeXML.appendChild(<minAngle>{minAngle}</minAngle>);
			strokeXML.appendChild(<maxAngle>{maxAngle}</maxAngle>);
			strokeXML.appendChild(<angleSpeed>{angleSpeed}</angleSpeed>);
			
			strokeXML.appendChild(<widthSpeed>{widthSpeed}</widthSpeed>);
			strokeXML.appendChild(<maxWidth>{maxWidth}</maxWidth>);
			strokeXML.appendChild(<lines>{lines}</lines>);
			strokeXML.appendChild(<weight>{weight}</weight>);
			strokeXML.appendChild(<alphaType>{alphaType}</alphaType>);
			
			strokeXML.appendChild(<colorType>{colorType}</colorType>);
			strokeXML.appendChild(<colorSteps>{colorSteps}</colorSteps>);
			strokeXML.appendChild(Style.propEnabledListToXML(colorStringObjList, "value", "enabled", "color"));
			strokeXML.appendChild(<colorHold>{colorHold}</colorHold>);
			
			strokeXML.appendChild(<maxAlpha>{maxAlpha}</maxAlpha>);
			strokeXML.appendChild(<widthType>{widthType}</widthType>);
			strokeXML.appendChild(<alphaSpeed>{alphaSpeed}</alphaSpeed>);
			
			strokeXML.appendChild(<thresholds />);
			// make this a function?
			strokeXML.thresholds.appendChild(<speed enabled={thresholds.speed.enabled}>{thresholds.speed.min+","+thresholds.speed.max}</speed>);
			strokeXML.thresholds.appendChild(<width enabled={thresholds.width.enabled}>{thresholds.width.min+","+thresholds.width.max}</width>);
			strokeXML.thresholds.appendChild(<angle enabled={thresholds.angle.enabled}>{thresholds.angle.min+","+thresholds.angle.max}</angle>);
			strokeXML.thresholds.appendChild(<distance enabled={thresholds.distance.enabled}>{thresholds.distance.min+","+thresholds.distance.max}</distance>);
			strokeXML.thresholds.appendChild(<random enabled={thresholds.random.enabled}>{"null,"+thresholds.random.max}</random>);
			strokeXML.thresholds.appendChild(<interval enabled={thresholds.interval.enabled}>{thresholds.interval.min}</interval>);

			return strokeXML;
			
		}
		
		public function setXML (xml:String):void
		{
			
			var strokeXML:XML = new XML (xml);
			
			try
			{
				strokeType = strokeXML.strokeType;
				lines = strokeXML.lines;
				weight = strokeXML.weight;
				
				angleType = strokeXML.angleType;
				minAngle = strokeXML.minAngle;
				maxAngle = strokeXML.maxAngle;
				angleSpeed = strokeXML.angleSpeed;
				
				widthType = strokeXML.widthType;
				minWidth = strokeXML.minWidth;
				maxWidth = strokeXML.maxWidth;
				widthSpeed = strokeXML.widthSpeed;
				
				colorType = strokeXML.colorType;
				colorSteps = strokeXML.colorSteps;
				colorObjList = Style.objListToColorObjList(Style.propEnabledXMLToList(strokeXML.colorList.color));
				colorHold = strokeXML.colorHold;
				
				alphaType = strokeXML.alphaType;
				minAlpha = strokeXML.minAlpha;
				maxAlpha = strokeXML.maxAlpha;
				alphaSpeed = strokeXML.alphaSpeed;
			} catch (e:Error){}
			
			if (colorObjList == null || colorObjList.length == 0) colorObjList = [new ColorObj(0xFF0000, true)]
			
			for each (var element:XML in strokeXML.thresholds.*)
			{
				try
				{
					var values:Array = element.text().split(",");
					thresholds[element.name()] = {enabled:element.enabled=="true"?true:false, min:values[0], max:values[1]};
				} catch (e:Error){}
			}
			
			setDecorate();
			
			//colorListToHex();
			
		}
		
		
		// STYLE ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function setDecorate ():void
		{
			//// // Consol.Trace("set decorate")
			decorate = false;
			
			for (var propT:String in thresholds)
			{
				decorate = decorate ? true : thresholds[propT].enabled;
			}
			//// // Consol.Trace(style.decoStyle.decoSet.activeLength)
			decorate = decorate ? (style.decoStyle.decoSet.activeLength>0) : false;
		}
		
		public function clone (style:Style):StrokeStyle
		{
			var strokeStyle:StrokeStyle = new StrokeStyle(style);
			//var settings:Settings = settings;
			//settings
			strokeStyle.settings = settings;
			
			return strokeStyle;
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		function varStringToXML (str:String, value:String=null):XML // should this be in the settings obj
		{
			var xml:XML;
			if (value == null) xml = new XML(<{str}>{this[str]}</{str}>);
			else xml = new XML(<{str}>{value}</{str}>);
			return xml;
		
		}
		
		/*
		public function strToHex (str:String):uint
		{
			//trace(str);
			str = (str.indexOf("0x") > -1 ? "" : "0x") + str;
			return uint(str)
		}
		
		private function colorListToHex ():void
		{
			hexColorList = [];
			for (var i:int=0; i<colorList.length; i++)
			{
				hexColorList.push(strToHex(colorList[i]));
			}
			
		}*/
		
		
	}
}