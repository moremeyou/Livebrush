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
	import com.livebrush.ui.BasicWindowView;
	import com.livebrush.ui.BasicWindowUI;
	import com.livebrush.events.ListEvent;
	
	public class BasicWindowController extends UIController
	{
		
		public function BasicWindowController (basicWindowView:BasicWindowView):void
		{
			super(basicWindowView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get basicWindowView ():BasicWindowView {   return BasicWindowView(view);  }
		private function get uiAsset ():BasicWindowUI {   return basicWindowView.uiAsset;  }
		private function get panelAsset ():Object {   return basicWindowView.panelAsset;  }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			uiAsset.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.addEventListener(MouseEvent.CLICK, mouseEvent);
			panelAsset.addEventListener(MouseEvent.MOUSE_DOWN, panelMouseEvent);
			panelAsset.addEventListener(MouseEvent.MOUSE_UP, panelMouseEvent);
		}
		
		public override function die ():void
		{
			panelAsset.stopDrag();
			uiAsset.removeEventListener(MouseEvent.CLICK, mouseEvent);
			uiAsset.removeEventListener(Event.CHANGE, propsChangeEvent);
			panelAsset.removeEventListener(MouseEvent.MOUSE_DOWN, panelMouseEvent);
			panelAsset.removeEventListener(MouseEvent.MOUSE_UP, panelMouseEvent);
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function panelMouseEvent (e:MouseEvent):void
		{
			if (e.type == MouseEvent.MOUSE_DOWN && e.target.name == "titleBtn" && basicWindowView.enableDrag) 
			{
				//// // Consol.Trace("Dialog titlebar clicked: start drag");
				panelAsset.startDrag();
				//ui.main.saveProject();
			}
			else if (e.type == MouseEvent.MOUSE_UP && e.target.name == "titleBtn" && basicWindowView.enableDrag) 
			{
				panelAsset.stopDrag();
			}
		}
		
		private function mouseEvent (e:MouseEvent):void
		{
			switch (e.target.name) {
				case "closeBtn" :
					ui.closeWindow(basicWindowView);
				break;
			}
		}
		
		private function propsChangeEvent (e:Event):void
		{
			//BasicWindow.CACHE_REALTIME = basicWindowView.uiAsset.cacheVectors.selected;
			//BasicWindow.CACHE_DECOS = basicWindowView.uiAsset.cacheDecos.selected;
			//BasicWindow.CHECK_FOR_UPDATES = basicWindowView.uiAsset.checkForUpdates.selected;
			
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////

		
		
		
	}
	
}