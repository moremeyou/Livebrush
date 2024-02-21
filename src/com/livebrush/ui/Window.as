package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import fl.controls.TextArea;	
	import com.livebrush.events.*;
	import com.livebrush.ui.PanelTitleBar;
	
	public class Window extends Sprite
	{
		
		public static const TEXT				:String = "htmlText";
		public static const EXTERNAL			:String = "swf,jpg,png,gif";
		public static const INTERNAL			:String = "linkageID";
		
		private var bg							:Sprite;
		private var titlebar					:PanelTitleBar;
		private var textArea					:TextArea;
		private var contentHolder				:Sprite;
		private var contentType					:String;
		private var contentSrc					:String;
		private var size						:Object;
		private var title						:String;
		
		public function Window (title:String="New Window", contentSrc:String="", contentType:String=Window.TEXT, width:int=400, height:int=400)
		{
			this.contentSrc = contentSrc;
			this.contentType = contentType;
			size = {width:width, height:height};
			this.title = title;
			
			init();
			
		}
		
		private function init ():void
		{
			
			bg = new WindowBg().bg;
			setSize(size);
			
			titlebar = new PanelTitleBar();
			titlebar.setWidth(size.width);
			titlebar.label.text = title.toUpperCase();
			titlebar.showHelp = false;
			titlebar.y = 1;

			addChild(bg);
			addChild(titlebar);
			
			titlebar.bg.addEventListener (MouseEvent.MOUSE_DOWN, clickDragListener);
			titlebar.closeBtn.addEventListener(MouseEvent.CLICK, clickToCloseListener);
			
		}
		
		public function setSize (s:Object):void
		{
			bg.width = s.width;
			bg.height = s.height;
		}
		
		private function clickToCloseListener (e:MouseEvent):void
		{
			parent.removeChild(this);
		}
		
		private function clickDragListener (e:MouseEvent):void
		{
			startDrag();
			titlebar.bg.addEventListener (MouseEvent.MOUSE_UP, stopDragListener);
		}
		
		private function stopDragListener (e:MouseEvent):void
		{
			stopDrag();
			titlebar.bg.removeEventListener (MouseEvent.MOUSE_UP, stopDragListener);
		}
		
	}
}