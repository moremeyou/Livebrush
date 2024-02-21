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
	import com.livebrush.events.ListEvent;
	
	public class DialogController extends UIController
	{
		
		public function DialogController (dialogView:DialogView):void
		{
			super(dialogView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get dialogView ():DialogView {   return DialogView(view);  }
		private function get dialogModel ():Dialog {   return dialogView.dialogModel;  }
		private function get uiAsset ():Object {   return dialogView.uiAsset;  }
		private function get panelAsset ():Object {   return dialogView.panelAsset;  }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			//titlebar.addEventListener(Event.CHANGE, styleChange);
			//titlebar.addEventListener(ListEvent.SELECT, styleChange);
			uiAsset.addEventListener(MouseEvent.CLICK, mouseEvent);
			panelAsset.addEventListener(MouseEvent.MOUSE_DOWN, panelMouseEvent);
			panelAsset.addEventListener(MouseEvent.MOUSE_UP, panelMouseEvent);
			//titlebar.addEventListener(Event.COMPLETE, showPreview);
			//uiAsset.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClick);
			//toggleBtn, helpBtn, titleBtn
		}
		
		public override function die ():void
		{
			panelAsset.stopDrag();
			uiAsset.removeEventListener(MouseEvent.CLICK, mouseEvent);
			panelAsset.removeEventListener(MouseEvent.MOUSE_DOWN, panelMouseEvent);
			panelAsset.removeEventListener(MouseEvent.MOUSE_UP, panelMouseEvent);
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function doubleClick (e:MouseEvent):void
		{
			if (e.target.name == "_highlight") canvasManager.stylePreviewLayer.toggle();
		}
		
		private function styleChange (e:Event=null):void
		{
			brushPropsModel.pullStyleProps();
			//brushPropsModel.changeStyle(titlebarView.titlebar.selectedItems);						
		}
		*/
		
		private function panelMouseEvent (e:MouseEvent):void
		{
			if (e.type == MouseEvent.MOUSE_DOWN && e.target.name == "titleBtn" && dialogView.enableDrag) 
			{
				//// // Consol.Trace("Dialog titlebar clicked: start drag");
				panelAsset.startDrag();
				//ui.main.saveProject();
			}
			else if (e.type == MouseEvent.MOUSE_UP && e.target.name == "titleBtn" && dialogView.enableDrag) 
			{
				panelAsset.stopDrag();
			}
		}
		
		private function mouseEvent (e:MouseEvent):void
		{
			switch (e.target.name) {
				case "yesBtn" :
					dialogModel.yesAction();
				break;
				
				case "noBtn" :
					dialogModel.noAction();
				break;
				
				case "saveBtn" :
					//ui.main.saveProject();
				break;
				
				case "styleBtn" :
					//ui.toggleToolProps();
				break;
				
				/*case "importBtn" :
					styleChange();
					brushPropsModel.importStyle();
				break;
				
				case "exportBtn" :
					styleChange();
					brushPropsModel.exportStyle();
					//dispatchEvent (new FileEvent(FileEvent.IO_EVENT, true, false, FileEvent.EXPORT, FileManager.STYLE));
				break;*/
			}
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

		
		
		
	}
	
}