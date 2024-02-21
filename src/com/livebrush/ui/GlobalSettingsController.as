package com.livebrush.ui
{
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	
	import com.livebrush.data.GlobalSettings;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.UIUpdate;
	import com.livebrush.ui.GlobalSettingsView;
	import com.livebrush.ui.SettingsUI;
	import com.livebrush.events.ListEvent;
	import com.livebrush.data.FileManager;
	
	public class GlobalSettingsController extends UIController
	{
		
		public function GlobalSettingsController (globalSettingsView:GlobalSettingsView):void
		{
			super(globalSettingsView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get globalSettingsView ():GlobalSettingsView {   return GlobalSettingsView(view);  }
		private function get uiAsset ():SettingsUI {   return globalSettingsView.uiAsset;  }
		private function get panelAsset ():Object {   return globalSettingsView.panelAsset;  }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			uiAsset.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.addEventListener(MouseEvent.CLICK, mouseEvent);
			//panelAsset.addEventListener(MouseEvent.CLICK, panelMouseEvent);
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
			if (e.type == MouseEvent.CLICK && e.target.name.indexOf("help")>-1)
			{
				_loadHelp();
				//ui.loadHelp(UIView(view).helpID);
			}
			else if (e.type == MouseEvent.MOUSE_DOWN && e.target.name == "titleBtn" && globalSettingsView.enableDrag) 
			{
				//// // Consol.Trace("Dialog titlebar clicked: start drag");
				panelAsset.startDrag();
				//ui.main.saveProject();
			}
			else if (e.type == MouseEvent.MOUSE_UP && e.target.name == "titleBtn" && globalSettingsView.enableDrag) 
			{
				panelAsset.stopDrag();
			}
		}
		
		private function mouseEvent (e:MouseEvent):void
		{
			switch (e.target.name) {
				case "presetsBtn" :
					FileManager.getInstance().copyAppFiles();
				break;
				case "closeBtn" :
					ui.globalSettingsView = null
					ui.closeWindow(globalSettingsView);
				break;
			}
		}
		
		private function propsChangeEvent (e:Event):void
		{
			GlobalSettings.CACHE_REALTIME = globalSettingsView.uiAsset.cacheVectors.selected;
			GlobalSettings.CACHE_DECOS = globalSettingsView.uiAsset.cacheDecos.selected;
			GlobalSettings.CHECK_FOR_UPDATES = globalSettingsView.uiAsset.checkForUpdates.selected;
			GlobalSettings.SHOW_BUSY_WARNINGS = globalSettingsView.uiAsset.showBusyWarnings.selected;
			GlobalSettings.CACHE_DELAY = Math.min(4000, Math.max(50, Number(globalSettingsView.uiAsset.cacheDelay.text) * 1000));
			//GlobalSettings.REGISTERED_EMAIL = globalSettingsView.uiAsset.email.text;
			GlobalSettings.SHOW_MOUSE_WHILE_DRAWING = globalSettingsView.uiAsset.showMouse.selected; 
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////

		
		
		
	}
	
}