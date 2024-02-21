package com.livebrush.styles
{
	
	import com.livebrush.data.Settings;
	import com.livebrush.data.Exchangeable;
	import com.livebrush.data.Storable;
	import com.livebrush.styles.Style;
	import com.livebrush.styles.StyleManager;
	import com.livebrush.styles.DecoAsset;
	//import com.livebrush.ui.DecoPanel;
	import com.livebrush.ui.Consol;
	import com.livebrush.utils.ColorObj;
	
	
	public class DecoStyle implements Exchangeable, Storable 
	{
		
		
		public static const SEQUENCE_DECO			:String = "sequence";
		public static const FIXED_DECO				:String = "fixed";
		public static const RANDOM_DECO				:String = "random";
		
		public static const A						:String = "a";
		public static const B						:String = "b";
		public static const CENTER					:String = "center";
		public static const ALT						:String = "alt";
		public static const WIDTH					:String = "strokeWidth";
		public static const DIR						:String = "strokeDirection";
		public static const SCATTER					:String = "scatter";
		public static const ORBIT					:String = "orbit";
		
		public static const POS_DIR					:String = "posDir";
		public static const ROTATE					:String = "rotate";
		public static const FIXED					:String = "fixed";
		public static const NONE					:String = "none";
		public static const OSC						:String = "osc";
		public static const RANDOM					:String = "random";
		public static const SPEED					:String = "speed";
		public static const LIST					:String = "list";
		public static const STROKE					:String = "stroke";
		public static const SAMPLE					:String = "sample";
		
		// Should these be in a special alignment class?
		public static const ALIGN_CENTER			:String = "center";
		public static const ALIGN_CORNER			:String = "corner";
		public static const ALIGN_TL				:String = "TL";
		public static const ALIGN_TR				:String = "TR";
		public static const ALIGN_BL				:String = "BL";
		public static const ALIGN_BR				:String = "BR";
		
		
		public var defaultSettings					:Settings;
		public var decoSet							:DecoSet
		public var style 							:Style;
		public var styleManager						:StyleManager;
		//public var decoPanel						:DecoPanel;
		public var selectedDecoIndex				:int = 0;
		public var decoNum							:int = 1;
		public var alignType						:String = ALIGN_CORNER;
		public var decoHold							:int = 1;
		
		public var decoset							:XML;
		public var orderType						:String = SEQUENCE_DECO;
		
		public var posType							:String = ALT;
		public var minPos							:Number = 0;
		public var maxPos							:Number = 1;
		public var posSpeed							:Number = 25;
		
		public var angleType						:String = DIR;
		public var xFlip							:Boolean = false;
		public var yFlip							:Boolean = false;
		public var autoFlip							:Boolean = true;
		public var minAngle							:Number = 90;
		public var maxAngle							:Number = 360;
		public var angleSpeed						:Number = 25;
		
		private var _colorType						:String = LIST;
		private var _colorList						:Array; // this list of objects, excluding any not enabled. and just the uint values
		public var _colorObjList					:Array;
		public var colorSteps						:int = 50;
		public var colorHold						:int = 1;
		
		public var tintType							:String = FIXED;
		public var minTint							:Number = 0;
		public var maxTint							:Number = 0;
		public var tintSpeed						:Number = 1;
		
		public var alphaType						:String = STROKE;
		public var minAlpha							:Number = 0;
		public var maxAlpha							:Number = 1;
		public var alphaSpeed						:Number = 10;
		
		public var sizeType							:String = SPEED;
		public var minSize							:Number = .1;
		public var maxSize							:Number = 1;
		public var sizeSpeed						:Number = 10;
		
		public var persist							:Boolean = true;
		
		
		
		public function DecoStyle (style:Style):void
		{
			this.style = style;
			styleManager = style.styleManager;
			decoSet = new DecoSet();
			decoSet.addDeco("Default"); // , true, true
			colorObjList = [new ColorObj(0x000000), new ColorObj(0xFFFFFF)];
			defaultSettings = settings;
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get selectedDecoAsset ():DecoAsset {   return decoSet.getDecoByIndex(selectedDecoIndex);   }
		//public function get colorType ():String {   return ((_colorList.length==1 && (_colorType != NONE || _colorType != FIXED || _colorType != SAMPLE)) ? FIXED : _colorType);   }
		public function get colorType ():String {   return _colorType;   }
		public function set colorType (s:String):void {   _colorType = s;   }
		public function get colorList ():Array {   return _colorList;   }
		public function get colorObjList ():Array {   return _colorObjList;   }
		public function get colorStringObjList ():Array {   var stringObjList:Array=[]; for(var i:int=0; i<colorObjList.length; i++) stringObjList.push({value:colorObjList[i].colorString, enabled:colorObjList[i].enabled}); return stringObjList;   }
		public function set colorObjList (list:Array):void {   _colorObjList=list; _colorList=[]; for(var i:int=0; i<list.length; i++) if (list[i].enabled) _colorList.push(list[i].color);   }
		public function get selectedColor ():Number {   return colorList[0];   } // colorList.length-1
		
		public function get settings ():Settings
		{
			var settings:Settings = new Settings();
		 
			settings.decos = decoSet.decos.slice();
			settings.selectedDecoIndex = decoSet.selectedDecoIndex;

			settings.orderType = orderType;
			settings.posType = posType;
			settings.minPos = minPos;
			settings.maxPos = maxPos;
			settings.posSpeed = posSpeed;
			
			settings.angleType = angleType;
			settings.autoFlip = autoFlip;
			settings.minAngle = minAngle;
			settings.maxAngle = maxAngle;
			settings.angleSpeed = angleSpeed;
			
			settings.colorType = colorType;
			settings.colorSteps = colorSteps;
			settings.colorObjList = Settings.copyArrayOfObjects(colorObjList);
			settings.colorHold = colorHold;
			
			settings.alphaType = alphaType;
			settings.minAlpha = minAlpha;
			settings.maxAlpha = maxAlpha;
			settings.alphaSpeed = alphaSpeed;
			
			settings.tintType = tintType;
			settings.minTint = minTint;
			settings.maxTint = maxTint;
			settings.tintSpeed = tintSpeed;
			
			settings.sizeType = sizeType;
			settings.minSize = minSize;
			settings.maxSize = maxSize;
			settings.sizeSpeed = sizeSpeed;
		
			settings.decoNum = decoNum;
			settings.decoHold = decoHold;
			
			settings.persist = persist;
			
			settings.alignType = alignType;
			
			return settings;
		}
		
		public function set settings (settings:Settings):void
		{
			// deco's are handled through StyleManager/this/DecoSet
			decoSet.decos = settings.decos;
			selectedDecoIndex = settings.selectedDecoIndex;
			decoSet.selectedDecoIndex = selectedDecoIndex;
			
			
			orderType = settings.orderType;
			posType = settings.posType;
			minPos = settings.minPos;
			maxPos = settings.maxPos;
			posSpeed = settings.posSpeed;
			
			angleType = settings.angleType;
			autoFlip = settings.autoFlip;
			minAngle = settings.minAngle;
			maxAngle = settings.maxAngle;
			angleSpeed = settings.angleSpeed;
			
			sizeType = settings.sizeType;
			minSize = settings.minSize;
			maxSize = settings.maxSize;
			sizeSpeed = settings.sizeSpeed;
			
			colorType = settings.colorType;
			colorObjList = settings.colorObjList.slice();
			colorSteps = settings.colorSteps;
			colorHold = settings.colorHold;
			
			tintType = settings.tintType;
			minTint = settings.minTint;
			maxTint = settings.maxTint;
			tintSpeed = settings.tintSpeed;
			
			alphaType = settings.alphaType;
			minAlpha = settings.minAlpha;
			maxAlpha = settings.maxAlpha;
			alphaSpeed = settings.alphaSpeed;
			
			decoNum = settings.decoNum;
			decoHold = settings.decoHold;
			
			persist = settings.persist;
			
			alignType = settings.alignType;

			
		}
		
		
		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function die ():void
		{
			decoSet.die();
			delete this;
		}
		
		
		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function getXML ():XML
		{
			var decoXML:XML = new XML(<deco/>);
			
			//decoXML.appendChild(decoSet.getXML());
			decoXML.appendChild(Style.propEnabledListToXML(decoSet.decos, "value", "enabled", "deco"));
			
			decoXML.appendChild(Settings.varStringToXML("orderType", this));
			decoXML.appendChild(Settings.varStringToXML("selectedDecoIndex", this));
			decoXML.appendChild(Settings.varStringToXML("decoNum", this));
			decoXML.appendChild(Settings.varStringToXML("decoHold", this));
			decoXML.appendChild(Settings.varStringToXML("alignType", this));
			decoXML.appendChild(Settings.varStringToXML("persist", this));
			
			decoXML.appendChild(Settings.varStringToXML("posType", this));
			decoXML.appendChild(Settings.varStringToXML("minPos", this));
			decoXML.appendChild(Settings.varStringToXML("maxPos", this));
			decoXML.appendChild(Settings.varStringToXML("posSpeed", this));
			
			decoXML.appendChild(Settings.varStringToXML("angleType", this));
			decoXML.appendChild(Settings.varStringToXML("autoFlip", this));
			decoXML.appendChild(Settings.varStringToXML("minAngle", this));
			decoXML.appendChild(Settings.varStringToXML("maxAngle", this));
			decoXML.appendChild(Settings.varStringToXML("angleSpeed", this));
			
			decoXML.appendChild(Settings.varStringToXML("sizeType", this));
			decoXML.appendChild(Settings.varStringToXML("minSize", this));
			decoXML.appendChild(Settings.varStringToXML("maxSize", this));
			decoXML.appendChild(Settings.varStringToXML("sizeSpeed", this));
			
			decoXML.appendChild(Settings.varStringToXML("sizeType", this));
			decoXML.appendChild(Settings.varStringToXML("minSize", this));
			decoXML.appendChild(Settings.varStringToXML("maxSize", this));
			decoXML.appendChild(Settings.varStringToXML("sizeSpeed", this));
			
			decoXML.appendChild(Settings.varStringToXML("colorType", this));
			decoXML.appendChild(Settings.varStringToXML("colorSteps", this));
			decoXML.appendChild(Style.propEnabledListToXML(colorStringObjList, "value", "enabled", "color"));
			decoXML.appendChild(Settings.varStringToXML("colorHold", this));
			
			decoXML.appendChild(Settings.varStringToXML("tintType", this));
			decoXML.appendChild(Settings.varStringToXML("minTint", this));
			decoXML.appendChild(Settings.varStringToXML("maxTint", this));
			decoXML.appendChild(Settings.varStringToXML("tintSpeed", this));

			decoXML.appendChild(Settings.varStringToXML("alphaType", this));
			decoXML.appendChild(Settings.varStringToXML("minAlpha", this));
			decoXML.appendChild(Settings.varStringToXML("maxAlpha", this));
			decoXML.appendChild(Settings.varStringToXML("alphaSpeed", this));

			return decoXML;
		}
		
		public function setXML (xml:String):void
		{
			var decoXML:XML = new XML (xml);
			var element:XML
			
			// force everything except decos to be setup first
			for each (element in decoXML.*)
			{
				try
				{
					if (element.name() != "colorList" && element.name() != "decoList")
					{
						if (element == "true" || element == "false") this[element.name()] = element=="true"?true:false;
						else this[element.name()] = element;
					}
					else if (element.name() == "colorList")
					{
						colorObjList = Style.objListToColorObjList(Style.propEnabledXMLToList(decoXML.colorList.color));
					}
				} catch (e:Error) {}
			}
			
			if (colorObjList == null || colorObjList.length == 0) colorObjList = [new ColorObj(0xFF0000, true)]
			
			decoSet.die();
			decoSet = new DecoSet();
			decoSet.selectedDecoIndex = selectedDecoIndex;
			
			try { var decoList:Array = Style.propEnabledXMLToList(decoXML.decoList.deco) } catch (e:Error){}
			for (var i:int=0; i<decoList.length; i++)
			{
				try { addDeco(decoList[i].value, decoList[i].enabled); } catch (e:Error){}
				
			}
			try { decoSet.decos = decoSet.decos; } catch (e:Error){}
			//colorListToHex();
			
		}
		
		
		// STYLE ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function addDeco (assetPath:String, enabled:Boolean=true):void
		{
			decoSet.addDeco(assetPath, enabled, false, selectedDecoIndex);
		}
		
		public function clone (style:Style):DecoStyle
		{
			
			var decoStyle:DecoStyle = new DecoStyle(style);
			
			decoStyle.settings = settings;
			
			decoStyle.decoSet = decoSet.clone();
			//// // Consol.Trace(decoSet.clone().activeLength);
			return decoStyle;
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		
	}
	
	
}