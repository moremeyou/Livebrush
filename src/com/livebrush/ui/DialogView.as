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

	import com.livebrush.utils.Update;
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.Dialog;
	import com.livebrush.ui.DialogAsset;
	import com.livebrush.ui.DialogController;
	import com.livebrush.ui.Dialog;
	import com.livebrush.ui.NoticeDialogUI;
	import com.livebrush.ui.LoadingDialogUI;
	import com.livebrush.ui.QuestionDialogUI;
	
	
	public class DialogView extends UIView
	{
		
		public var uiAsset							:Sprite;
		public var panelAsset						:DialogAsset;
		public var enableDrag						:Boolean = true;
		
		public function DialogView (dialogModel:Dialog):void
		{
			super(dialogModel);
			
			init();
		}
		
		// GET/ SET /////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get dialogController ():DialogController {   return DialogController(controller);   }
		public function get dialogModel ():Dialog {   return Dialog(model);   }
		public function get id ():String {   return dialogModel.id;   }
		public function get type ():String {   return dialogModel.type;   }
		public function get messageField ():TextField {   return uiAsset["message"];   }
		public function set message (s:String):void {   messageField.htmlText = s;   }
		public function get loadBar ():MovieClip {   return uiAsset["bar"];   }
		public function set loadPercent (n:Number):void   {   loadBar.scaleX = Math.min(n,1);   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function die ():void
		{
			dialogController.die();
			UI.DIALOG_HOLDER.removeChild(panelAsset);
			panelAsset.removeChild(uiAsset);
			panelAsset = null;
			uiAsset = null;
		}
		
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			panelAsset = new DialogAsset();
			panelAsset.cacheAsBitmap = true;
			panelAsset.titleBtn.useHandCursor = false;
			
			if (type == Dialog.NOTICE)
			{
				uiAsset = new NoticeDialogUI();
				
				panelAsset.bg.width = 350;
				panelAsset.bg.height = 150;
				panelAsset.title.text = "";
				panelAsset.helpBtn.visible = panelAsset.helpBtn.enabled = false;
				panelAsset.toggleBtn.visible = panelAsset.toggleBtn.enabled = false;
				enableDrag = true;
				
				update(Update.dataUpdate(dialogModel.data))
				//message = "This is cool!";
			}
			else if (type == Dialog.LOADING)
			{
				uiAsset = new LoadingDialogUI();
				
				panelAsset.bg.width = 350;
				panelAsset.bg.height = 115;
				panelAsset.title.text = "";
				panelAsset.helpBtn.visible = panelAsset.helpBtn.enabled = false;
				panelAsset.toggleBtn.visible = panelAsset.toggleBtn.enabled = false;
				enableDrag = false;
				
				update(Update.loadingUpdate(dialogModel.data))
				//message = "Loading, etc...";
			}
			else if (type == Dialog.PROCESS)
			{
				uiAsset = new ProcessDialogUI();
				
				panelAsset.bg.width = 350;
				panelAsset.bg.height = 115;
				panelAsset.title.text = "";
				panelAsset.helpBtn.visible = panelAsset.helpBtn.enabled = false;
				panelAsset.toggleBtn.visible = panelAsset.toggleBtn.enabled = false;
				enableDrag = false;
				
				update(Update.dataUpdate(dialogModel.data));
				//message = "Loading, etc...";
			}
			else if (type == Dialog.QUESTION)
			{
				uiAsset = new QuestionDialogUI();
				
				panelAsset.bg.width = 350;
				panelAsset.bg.height = 150;
				panelAsset.title.text = "";
				panelAsset.helpBtn.visible = panelAsset.helpBtn.enabled = false;
				panelAsset.toggleBtn.visible = panelAsset.toggleBtn.enabled = false;
				enableDrag = true;
				
				update(Update.dataUpdate(dialogModel.data));
				//message = "This is cool!";
			}
			
			uiAsset.x = 17;
			uiAsset.y = 38;
			uiAsset.cacheAsBitmap = true;
			panelAsset.addChild(uiAsset);
			
			panelAsset.x = UI.centerX - panelAsset.width/2;
			panelAsset.y = UI.centerY - panelAsset.height/2;
			UI.DIALOG_HOLDER.addChild(panelAsset);
			
			

		}
		
		protected override function createController ():void
		{
			controller = new DialogController(this);
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function update (update:Update=null):void
		{
			try
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
			}
		}
		
	}
	
	
}