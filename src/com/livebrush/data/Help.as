package com.livebrush.data
{
	
	//import com.livebrush.data.Settings;
	import com.livebrush.ui.Consol;
	import com.livebrush.data.FileManager
	
	
	public class Help
	{
		private static var singleton				:Help = null;
		public static var helpRoot					:String = "http://www.livebrush.com/help/";
		
		private var fileManager						:FileManager;
		public var xml								:XML;
		
		public function Help (fileManager:FileManager):void
		{
			this.fileManager = fileManager;
			xml = fileManager.loadHelp();
		}
		
		public static function getInstance (fileManager:FileManager=null):Help
		{
			var instance:Help;
			if (singleton == null) 
			{
				singleton = new Help(fileManager);
				instance = singleton;
			}
			else 
			{
				instance = singleton;
			}
			
			return instance;
		}
		
		public static function loadHelp (id:String):void
		{
			var helpURL:String = Help.getInstance().xml.ITEM.(@ID==id);
			//// // Consol.Trace("HELP (" + id + " : " + helpURL + ")")
			FileManager.getURL(helpRoot+helpURL);
		}
	}
	
}