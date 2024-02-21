package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import fl.controls.TextArea;
	import com.livebrush.ui.Panel
	import com.livebrush.data.Settings;
	
	public class DialogWindow extends Panel
	{
		
		public function DialogWindow ():void
		{
			super.setup();
			
			titlebar.showHelp = false;
			label = "Alert"
			
		}
		
		
		public function autoCloseFn (e:Event):void
		{
			parent.removeChild(this);
			delete this;
		}
		
	}
	
	
}