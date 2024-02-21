package com.livebrush.utils
{
	import flash.events.EventDispatcher;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import com.livebrush.ui.Consol;
	import com.livebrush.utils.Update;
	
	public class Model extends EventDispatcher
	{
		public var views												:Array;
		
		public function Model ():void
		{
			views = [];
			init();
		}
		
		private function init ():void
		{
		}
		
		protected function die ():void
		{
			for (var i:int=0; i<views.length; i++)
			{
				if (views[i].die != null) views[i].die();
				//unregisterView(views[i]);
			}
			views = [];
		}
		
		protected function registerView (view:View):View // Object for now because all the views don't extend from a main
		{
			// does not account for duplicates
			views.push(view);
			return view;
		}
		
		protected function unregisterView (view:View):View // Object for now because all the views don't extend from a main
		{
			var viewIndex:int = views.indexOf(view);
			if (viewIndex > -1) views.splice(viewIndex, 1);
			return view;
		}

		protected function updateViews (update:Update):void
		{
			for (var i:int=0; i<views.length; i++)
			{
				views[i].update(update);
			}
		}
	
		public function update (update:Update, views:Boolean=true, dispatch:Boolean=false):void
		{
			if (views) updateViews(update);
			
			//if (dispatch) toolManager.dispatchEvent(update.generateEvent(update.data));
			// toolMan will re-create the even and dispatch again
			// we have to recreate because other object register with the toolMan - not individual tools
			if (dispatch) dispatchEvent(update.generateEvent());
		}

	}
	
}