package com.livebrush.ui
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import com.livebrush.events.HelpEvent;
	import com.livebrush.events.ConsolEvent;
	
	public class Panel extends Sprite 
	{
		private var _titlebar					:PanelTitleBar;
		private var _bg							:Sprite;
		public var _label						:String = "Panel";
		public var isDragable					:Boolean = true;
		private var _isRemovable				:Boolean = true;
		public var helpID						:String;
		
		
		public function Panel ():void
		{
		}
		
		internal function setup():void
		{
			_bg = Sprite(getChildByName("bg"));
			_titlebar = PanelTitleBar(getChildByName("titlebar"));
			
			_titlebar.setWidth (_bg.width);
			
			
			_titlebar.closeBtn.addEventListener(MouseEvent.CLICK, closeBtnListener);
			_titlebar.helpBtn.addEventListener(MouseEvent.CLICK, helpBtnListener);
			_titlebar.bg.addEventListener(MouseEvent.MOUSE_DOWN, titlebarDownListener);
			_titlebar.bg.addEventListener(MouseEvent.MOUSE_UP, titlebarUpListener);
		}
		
		public function outputToConsol (output:String):void
		{
			dispatchEvent (new ConsolEvent(ConsolEvent.OUTPUT, true, false, output));
		}
		
		public function set isRemovable (b:Boolean):void
		{
			_isRemovable = _titlebar.showClose = b;
		}
		
		public function set label (l:String):void
		{
			_titlebar.label.text = _label = l.toUpperCase();
		}
		
		public function get label ():String
		{
			return _label;
		}
		
		private function closeBtnListener (e:MouseEvent):void 
		{ 
			if (e.eventPhase == EventPhase.AT_TARGET)
			{
				if (_isRemovable) close();
			}
		}
		
		public function close ():void
		{
			parent.removeChild(this); 
		}
		
		private function helpBtnListener (e:MouseEvent):void 
		{ 
			if (e.eventPhase == EventPhase.AT_TARGET)
			{
				getHelp ({context:label, id:helpID});
			}
		}
		
		private function titlebarDownListener (e:MouseEvent):void
		{
			if (isDragable) startDrag();
		}
		private function titlebarUpListener (e:MouseEvent):void
		{
			if (isDragable) stopDrag();
		}
		
		public function getHelp (o:Object):void
		{
			//dispatchEvent (new HelpEvent (HelpEvent.GET_HELP, true, false, o.context, o.id));
		}
		
	}
	
	
}