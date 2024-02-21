package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import fl.controls.TextArea;
	import com.livebrush.ui.Panel
	import com.livebrush.data.Settings;
	import com.livebrush.data.GlobalSettings;
	import com.livebrush.ui.Consol;
	
	public class AppSettingsPanel extends Panel
	{

		public function AppSettingsPanel ():void
		{
			super.setup();
			
			titlebar.showHelp = false;
			label = "Application Settings"
			
			//init();
		}
		
		public function init ():void
		{
			//Consol.globalOutput("AppSettingsPanel INIT");
			
			cacheDecos.selected = GlobalSettings.CACHE_DECOS;
			cacheLayers.selected = GlobalSettings.CACHE_LAYERS;
			cacheDelay.text = String(GlobalSettings.CACHE_DELAY);
			
			GlobalSettings.TEMP_CACHE_LAYERS = cacheLayers.selected;
			
			addEventListener(Event.CHANGE, settingsChangeHandler);
			
		}
		
		private function settingsChangeHandler (e:Event):void
		{
			switch (e.target) 
			{ 
				case cacheDecos : 
					GlobalSettings.CACHE_DECOS = cacheDecos.selected;
				break;
				case cacheDelay : 
					GlobalSettings.CACHE_DELAY = int(cacheDelay.text);
				break;
				case cacheLayers : 
					GlobalSettings.TEMP_CACHE_LAYERS = cacheLayers.selected;
				break;
			}

		}
		
		
		
	}
	
	
}