package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.SimpleButton;
	
	public class PanelTitleBar extends Sprite
	{
		
		public function PanelTitleBar ():void
		{
			init();
		}
		
		private function init ():void
		{
			label.autoSize = TextFieldAutoSize.LEFT;
		}
		
		public function setWidth (w:Number):void
		{
			bg.width = w;
			closeBtn.x = bg.width - 18;
			showHelp = helpBtn.visible;
		}
		
		public function set showClose (b:Boolean):void
		{
			closeBtn.visible = b;
			if (b) helpBtn.x = closeBtn.x - helpBtn.width + 5;
			else helpBtn.x = closeBtn.x;
		}
		
		public function set showHelp (b:Boolean):void
		{
			helpBtn.visible = b;
			if (closeBtn.visible) helpBtn.x = closeBtn.x - helpBtn.width - 5;
			else helpBtn.x = closeBtn.x;
		}
		
	}
	
	
}