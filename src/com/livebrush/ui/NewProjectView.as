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
	import com.livebrush.ui.NewProjectUI;
	import com.livebrush.ui.WindowAssetUI;
	import com.livebrush.ui.NewProjectController;
	import com.livebrush.graphics.canvas.Canvas;
	
	
	public class NewProjectView extends UIView
	{
		
		public var uiAsset							:NewProjectUI;
		public var panelAsset						:WindowAssetUI;
		public var enableDrag						:Boolean = true;
		public var data								:Object;
		
		
		public function NewProjectView (ui:UI, data:Object=null):void
		{
			super(ui);
			
			helpID = "newProject";
			this.data = data;
			
			init();
		}
		
		// GET/ SET /////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get newProjectController ():NewProjectController {   return NewProjectController(controller);   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function die ():void
		{
			newProjectController.die();
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
			
			uiAsset = new NewProjectUI();
				
			panelAsset.bg.width = 420;
			panelAsset.bg.height = 225;
			panelAsset.title.text = "Start A New Livebrush Project";
			panelAsset.helpBtn.visible = panelAsset.helpBtn.enabled = false;
			panelAsset.toggleBtn.visible = panelAsset.toggleBtn.enabled = false;
			enableDrag = true;
			
			uiAsset.sizeList.rowCount = 10;
			
			var i:int;
			var sizeObj:Object = Canvas.sizeRes[0][0];
			uiAsset.sizeList.addItem({label:sizeObj.label, data:0});
			for (i=1; i<Canvas.sizeRes.length; i++)
			{
				sizeObj = Canvas.sizeRes[i][0];
				uiAsset.sizeList.addItem({label:sizeObj.x+" x "+sizeObj.y+(sizeObj.label!=""?" - "+sizeObj.label:""), data:i});
			}
			
			uiAsset.sizeList.selectedIndex = 0;
			uiAsset.cWidth.text = Canvas.sizeRes[uiAsset.sizeList.selectedIndex][0].x;
			uiAsset.cHeight.text = Canvas.sizeRes[uiAsset.sizeList.selectedIndex][0].y;
			
			for (i=0; i<Canvas.defaultBackgrounds.length; i++)
			{
				uiAsset.bgList.addItem({label:Canvas.defaultBackgrounds[i].label, data:i});
			}
			
			uiAsset.bgList.selectedIndex = 1;
			
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
			controller = new NewProjectController(this);
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