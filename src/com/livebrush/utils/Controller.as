package com.livebrush.utils
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import com.livebrush.ui.Consol;
	import com.livebrush.utils.Model;
	import com.livebrush.utils.View;
	import com.livebrush.utils.Update;
	
	public class Controller
	{

		public var view						:View;
		
		public function Controller (view:View):void
		{
			this.view = view;
		}
		
		
		
		public function die ():void
		{
		}
		
		protected function init ():void
		{
			
		}
		
		protected function updateModel ():void
		{
			// model["change"]();
		}
		
	}
}