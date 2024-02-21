package com.livebrush.ui
{
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.UIUpdate;
	
	public class BucketPropsController extends UIController
	{
		
		public function BucketPropsController (bucketPropsView:BucketPropsView):void
		{
			super(bucketPropsView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get bucketPropsView ():BucketPropsView {   return BucketPropsView(view);  }
		private function get uiAsset ():Sprite {   return bucketPropsView.uiAsset;  }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			uiAsset.addEventListener(MouseEvent.CLICK, mouseEvent);
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function mouseEvent (e:MouseEvent):void
		{
			/*if (e.target.name.indexOf("tab") > -1)
			{
				var tabIndex:int = int(e.target.name.substr(3));
				//// // Consol.Trace("tab click: " + e.target.name);
				//// // Consol.Trace("tab click: " + e.target.name);
				//bucketPropsView.toggleProps(tabIndex);
				bucketPropsModel.toggleProps(tabIndex);
			}*/
			if (e.target.name == "helpBtn")
			{
				_loadHelp();
				//// // Consol.Trace("help from tool props");
			}
			
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

		
		
		
	}
	
}