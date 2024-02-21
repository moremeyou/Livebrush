package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.display.NativeWindowDisplayState;
	import fl.controls.Button;
	import flash.text.TextField;

	import com.livebrush.data.GlobalSettings;
	import com.livebrush.utils.Update;
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.Dialog;
	import com.livebrush.ui.SettingsUI;
	import com.livebrush.ui.WindowAssetUI;
	import com.livebrush.ui.GlobalSettingsController;
	
	
	public class GlobalSettingsView extends UIView
	{
		
		public var uiAsset							:SettingsUI;
		public var panelAsset						:WindowAssetUI;
		public var enableDrag						:Boolean = true;
		public var data								:Object;
		
		
		public function GlobalSettingsView (ui:UI, data:Object=null):void
		{
			super(ui);
			
			helpID = "prefs";
			this.data = data;
			
			init();
		}
		
		// GET/ SET /////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get globalSettingsController ():GlobalSettingsController {   return GlobalSettingsController(controller);   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function die ():void
		{
			globalSettingsController.die();
			UI.WINDOW_HOLDER.removeChild(panelAsset);
			panelAsset.removeChild(uiAsset);
			panelAsset = null;
			uiAsset = null;
		}
		
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			panelAsset = new WindowAssetUI();
			panelAsset.cacheAsBitmap = true;
			panelAsset.titleBtn.useHandCursor = false;
			
			uiAsset = new SettingsUI();
				
			panelAsset.bg.width = 420;
			panelAsset.bg.height = 375;
			panelAsset.title.text = "Settings";
			panelAsset.helpBtn.visible = panelAsset.helpBtn.enabled = false;
			panelAsset.toggleBtn.visible = panelAsset.toggleBtn.enabled = false;
			enableDrag = true;
			uiAsset.cacheDelay.restrict = "0123456789.";
			
			uiAsset.cacheVectors.selected = GlobalSettings.CACHE_REALTIME;
			uiAsset.cacheDecos.selected = GlobalSettings.CACHE_DECOS;
			uiAsset.checkForUpdates.selected = GlobalSettings.CHECK_FOR_UPDATES;
			uiAsset.showBusyWarnings.selected = GlobalSettings.SHOW_BUSY_WARNINGS;
			uiAsset.cacheDelay.text = String(GlobalSettings.CACHE_DELAY / 1000);
			//uiAsset.email.text = GlobalSettings.REGISTERED_EMAIL;
			uiAsset.showMouse.selected = GlobalSettings.SHOW_MOUSE_WHILE_DRAWING;
			
			if (GlobalSettings.WACOM_DOCK) uiAsset.wacomStatus.text = "Tablet Enabled (via Wacom Dock)";
			
			uiAsset.x = 17;
			uiAsset.y = 38;
			uiAsset.cacheAsBitmap = true;
			panelAsset.addChild(uiAsset);
			
			panelAsset.x = UI.centerX - panelAsset.width/2;
			panelAsset.y = UI.centerY - panelAsset.height/2;
			UI.WINDOW_HOLDER.addChild(panelAsset);
		}
		
		protected override function createController ():void
		{
			controller = new GlobalSettingsController(this);
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function update (update:Update=null):void
		{
			/*try
			{
				if (update.type == UpdateEvent.DATA)
				{
					message = update.data.message;
				}
				else if (update.type == UpdateEvent.LOADING)
				{
					loadPercent = update.data.loadPercent;
					message = update.data.message;
				}
				else if (update.type == UpdateEvent.WINDOW)
				{
					//uiAsset.bg.width = UI.WIDTH - .7;
					//uiAsset.right.x = UI.WIDTH - uiAsset.right.width;
				}
				else if (update.type == UpdateEvent.BRUSH_STYLE)
				{
					//// // Consol.Trace("Titlebar got style update");
					//var length:int = update.data.styleGroup.length;
					//if (length > 1) style = (length + " Styles Selected").toUpperCase();
					//else style = update.data.styleGroup[0].name; //.toUpperCase();
				}
				else if (update.type == UpdateEvent.PROJECT)
				{
					//project = update.data.project;
				}
			}
			catch (e:Error)
			{
			}*/
		}
		
	}
	
	
}