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
	import com.livebrush.ui.SaveImageView;
	import com.livebrush.ui.SettingsUI;
	import com.livebrush.events.ListEvent;
	
	public class SaveImageController extends UIController
	{
		
		public function SaveImageController (saveImageView:SaveImageView):void
		{
			super(saveImageView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get saveImageView ():SaveImageView {   return SaveImageView(view);  }
		private function get uiAsset ():SaveImageUI {   return saveImageView.uiAsset;  }
		private function get panelAsset ():Object {   return saveImageView.panelAsset;  }
		
		
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
			else if (e.type == MouseEvent.MOUSE_DOWN && e.target.name == "titleBtn" && saveImageView.enableDrag) 
			{
				//// // Consol.Trace("Dialog titlebar clicked: start drag");
				panelAsset.startDrag();
				//ui.main.saveProject();
			}
			else if (e.type == MouseEvent.MOUSE_UP && e.target.name == "titleBtn" && saveImageView.enableDrag) 
			{
				panelAsset.stopDrag();
			}
		}
		
		private function mouseEvent (e:MouseEvent):void
		{
			switch (e.target.name) {
				case "cancelBtn" :
					ui.saveImageView = null
					ui.closeWindow(saveImageView);
				break;
				case "okBtn" :
					//ui.createSaveImage(uiAsset.sizeList.selectedIndex);
					ui.main.saveAsImage(uiAsset.sizeList.selectedIndex, saveImageView.data.allLayers);
					ui.saveImageView = null
					ui.closeWindow(saveImageView);
				break;
			}
		}
		
		private function propsChangeEvent (e:Event):void
		{
			//GlobalSettings.CACHE_REALTIME = globalSettingsView.uiAsset.cacheVectors.selected;
			//GlobalSettings.CACHE_DECOS = globalSettingsView.uiAsset.cacheDecos.selected;
			//GlobalSettings.CHECK_FOR_UPDATES = globalSettingsView.uiAsset.checkForUpdates.selected;
			//GlobalSettings.REGISTERED_EMAIL = globalSettingsView.uiAsset.email.text;
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////

		
		
		
	}
	
}