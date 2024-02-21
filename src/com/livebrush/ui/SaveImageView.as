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
	import com.livebrush.ui.SaveImageUI;
	import com.livebrush.ui.WindowAssetUI;
	import com.livebrush.ui.SaveImageController;
	import com.livebrush.graphics.canvas.Canvas;
	
	
	public class SaveImageView extends UIView
	{
		
		public var uiAsset							:SaveImageUI;
		public var panelAsset						:WindowAssetUI;
		public var enableDrag						:Boolean = true;
		public var data								:Object;
		
		
		public function SaveImageView (ui:UI, data:Object=null):void
		{
			super(ui);
			
			helpID = "saveImage";
			this.data = data;
			
			init();
		}
		
		// GET/ SET /////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get saveImageController ():SaveImageController {   return SaveImageController(controller);   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function die ():void
		{
			saveImageController.die();
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
			
			uiAsset = new SaveImageUI();
				
			panelAsset.bg.width = 420;
			panelAsset.bg.height = 150;
			panelAsset.title.text = "Save Image";
			panelAsset.helpBtn.visible = panelAsset.helpBtn.enabled = false;
			panelAsset.toggleBtn.visible = panelAsset.toggleBtn.enabled = false;
			enableDrag = true;
			
			uiAsset.sizeList.rowCount = 3;
			
			//var sizeObj:Object;
			for (var i:int=0; i<Canvas.sizeDPI.length; i++)
			{
				//sizeObj = Canvas.sizeDPI[i][0];
				uiAsset.sizeList.addItem(Canvas.sizeDPI[i]);
			}
			
			uiAsset.sizeList.selectedIndex = 0;
			
			//uiAsset.cacheVectors.selected = SaveImage.CACHE_REALTIME;
			//uiAsset.cacheDecos.selected = SaveImage.CACHE_DECOS;
			//uiAsset.checkForUpdates.selected = SaveImage.CHECK_FOR_UPDATES;
			//uiAsset.email.text = SaveImage.REGISTERED_EMAIL;
			
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
			controller = new SaveImageController(this);
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