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
	
	public class ToolPropsController extends UIController
	{
		
		public function ToolPropsController (toolPropsView:ToolPropsView):void
		{
			super(toolPropsView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get toolPropsView ():ToolPropsView {   return ToolPropsView(view);  }
		private function get panelAsset ():Sprite {   return toolPropsView.panelAsset;  }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			panelAsset.addEventListener(MouseEvent.CLICK, mouseEvent);
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function mouseEvent (e:MouseEvent):void
		{
			if (e.target.name == "toggleBtn")
			{
				toolPropsView.toggle();
				ui.uiUpdate();
			}
			else if (e.target.name == "helpBtn")
			{
				//if (e.type == MouseEvent.CLICK && e.target.name.indexOf("help")>-1) 
				_loadHelp();
				//// // Consol.Trace("help from tool props");
			}
			
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

		
		
		
	}
	
}