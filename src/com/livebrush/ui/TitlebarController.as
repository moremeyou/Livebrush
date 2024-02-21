package com.livebrush.ui
{
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.display.Sprite;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	
	//import flash.display.BitmapData;
	import flash.desktop.Clipboard; 
	import flash.desktop.ClipboardFormats;
	import fl.events.ComponentEvent;
	
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.UIUpdate;
	import com.livebrush.events.ListEvent;
	import com.livebrush.data.GlobalSettings;
	
	
	public class TitlebarController extends UIController
	{
		
		public function TitlebarController (titlebarView:TitlebarView):void
		{
			super(titlebarView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get titlebarView ():TitlebarView {   return TitlebarView(view);  }
		private function get brushPropsModel ():BrushPropsModel {   return titlebarView.brushPropsModel;   }
		private function get uiAsset ():Object {   return titlebarView.uiAsset;  }
		//private function get titlebar ():RichList {   return titlebarView.titlebar;   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			uiAsset.addEventListener(Event.CHANGE, changeListener);
			//titlebar.addEventListener(ListEvent.SELECT, styleChange);
			uiAsset.addEventListener(MouseEvent.CLICK, mouseEvent);
			//titlebar.addEventListener(Event.COMPLETE, showPreview);
			//uiAsset.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClick);
			
			//uiAsset.zoomValue.addEventListener(ComponentEvent.ENTER, changeListener);
			//uiAsset.canvasZoom.addEventListener(Event.CHANGE, changeListener);
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
		
		private function changeListener (e:Event):void {
		
			//// Consol.Trace("TitlebarController: changeListener: " + e.target);
			//if (e.eventPhase == EventPhase.AT_TARGET) {
			//if (e.target == uiAsset.strokeBuffer) {
				//// Consol.Trace("TitlebarController: strokeBuffer: " + uiAsset.strokeBuffer.value);
				GlobalSettings.STROKE_BUFFER = uiAsset.strokeBuffer.value;
				//e.stopImmediatePropagation();
			//}
			
			//Consol.Trace("TitlebarController: changeListener, e.type = " + e.type);
			
			/*if (e.target.name == "canvasZoom")
			{
				//Consol.Trace("TitlebarController: changeListener, canvasZoom slider changed");
				//canvas.canvasZoom(uiAsset.canvasZoom.value);  // /100
				ui.canvasZoom(uiAsset.canvasZoom.value, true);
			}
			else if (e.target.name == "zoomValue" && e.type == ComponentEvent.ENTER)
			{
				var zoomAmount:Number = uiAsset.zoomValue.text / 100;
				//Consol.Trace("TitlebarController: changeListener, uiAsset.zoomValue = " + uiAsset.zoomValue.text);
				//Consol.Trace("TitlebarController: changeListener, zoomAmount = " + zoomAmount);
				//canvas.canvasZoom(uiAsset.zoomValue.text / 100);  // /100
				
				
				ui.canvasZoom(zoomAmount, true);
			}*/

		
		}
		
		private function mouseEvent (e:MouseEvent):void
		{
			switch (e.target.name) {
				case "saveBtn" :
					ui.main.saveProject();
				break;
				
				case "styleBtn" :
					ui.toggleToolProps();
				break;
				
				case "prefsBtn" :
					ui.showGlobalPrefs();
				break;
				
				case "quickSaveBtn" :
					// // Consol.Trace("Copying to clipboard");
					Clipboard.generalClipboard.clear(); 
					//Clipboard.generalClipboard.setData(ClipboardFormats.BITMAP_FORMAT, canvasManager.getImage(canvasManager.activeLayerDepths), false); 
					Clipboard.generalClipboard.setData(ClipboardFormats.BITMAP_FORMAT, canvasManager.getImage(canvasManager.activeLayerDepths), false); 
					//new BitmapData(rect.width, rect.height, true, 0x00000000)
				break;
				
				case "helpBtn" :
					_loadHelp();
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
			
			switch (e.target.parent.name) {
				
				case "drawVectorsBtn" :
					ui.toggleDrawMode(0);
				break;
				
				case "drawPixelsBtn" :
					ui.toggleDrawMode(1);
				break;
				
			}
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

		
		
		
	}
	
}