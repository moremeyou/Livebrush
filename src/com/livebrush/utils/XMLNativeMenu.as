package com.livebrush.utils
{
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	
	public class XMLNativeMenu extends NativeMenu
	{
		
		private var _xml								:XML;
		
		public function XMLNativeMenu (xml:XML):void
		{
			super();
			
			_xml = xml;
			
			init();
		}
		
		private function init ():void
		{
			topMenu = xmlToNativeMenu(xml);
		}
		
		public static function xmlToNativeMenu (xml:XML):NativeMenu
		{
			
		}
		
	}
		
	
}