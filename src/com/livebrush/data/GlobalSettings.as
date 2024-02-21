package com.livebrush.data
{
	
	import com.livebrush.data.Settings;
	import com.livebrush.ui.Consol;
	
	
	public class GlobalSettings extends Settings
	{
		
		//private static var settings							:GlobalSettings = null;

		public static var CACHE_LAYERS						:Boolean = true;
		public static var TEMP_CACHE_LAYERS					:Boolean = CACHE_LAYERS;
		public static var CACHE_DECOS						:Boolean = false;
		public static var CACHE_DELAY						:int = 500;
		public static var CACHE_REALTIME					:Boolean = true;
		public static var FIRST_SAVE						:Boolean = true;
		public static var FIRST_DECOSET_EXPORT				:Boolean = true;
		public static var FIRST_STYLE_EXPORT				:Boolean = true;
		public static var CHECK_FOR_UPDATES					:Boolean = true;
		public static var UPDATE_CHECK_COUNT				:int = 0;
		public static var REGISTERED_EMAIL					:String = "";
		public static var SHOW_BUSY_WARNINGS				:Boolean = false;
		public static var DRAW_MODE							:int = 0;
		public static var STROKE_BUFFER						:int = 5;
		public static var SHOW_MOUSE_WHILE_DRAWING			:Boolean = true;
		public static var WACOM_DOCK						:Boolean = false;
		public static var RESTRICT_CANVAS					:Boolean = true; // not setup yet
		
		
		public function GlobalSettings ():void
		{
		}
		
		/*public static function getInstance ():GlobalSettings
		{
			if (settings != null) settings = new GlobalSettings();
			return settings;
		}
		*/
		public static function setProperty (propName:String, value:Object):void
		{
			//trace(">>>>>>>>>>>>> " + value)
			if (value != null) 
			{
				value = Settings.isBoolString(String(value)) ? Settings.stringToBoolean(String(value)) : value;
				
				GlobalSettings[propName] = value;
				
				//Consol.globalOutput("GLOBAL SETTING > " + propName + " = " + value);
			}
		}
		
	}
	
}