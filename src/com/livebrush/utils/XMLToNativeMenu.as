package com.livebrush.utils
{
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	
	public class XMLToNativeMenu extends NativeMenu
	{
		
		private var _xml								:XML;
		private var _topMenu							:NativeMenu;
		
		public function XMLToNativeMenu (xml:XML):void
		{
			super();
			
			_xml = xml;
			
			init();
		}
		
		public function get topMenu ():NativeMenu {   return _topMenu;   }
		
		private function init ():void
		{
			topMenu = doIt(xml);
		}
		
		public static function doIt (xml:XML):NativeMenu
		{
			
		}
		
	}
		
	
}