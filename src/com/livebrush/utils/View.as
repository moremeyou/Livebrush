package com.livebrush.utils
{

	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import com.livebrush.ui.Consol;
	import com.livebrush.utils.Model;
	import com.livebrush.utils.Controller;
	import com.livebrush.utils.Update;
	
	public class View
	{
		public var model												:Model; 
		public var controller											:Controller;
		
		public function View (model:Model):void
		{
			this.model = model;
		}
		
		public function die ():void
		{
		}
		
		protected function init ():void
		{
			createView();
			
			createController();
			
			registerController();
		}
		
		protected function createView ():void
		{
			

		}
		
		protected function createController ():void
		{
			

		}
		
		protected function registerController ():void
		{
			

		}
		
		public function update (update:Update=null):void
		{
			
		}
		
	}
	
}