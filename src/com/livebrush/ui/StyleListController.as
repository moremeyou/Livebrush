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
	
	public class StyleListController extends UIController
	{
		
		public function StyleListController (styleListView:StyleListView):void
		{
			super(styleListView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get styleListView ():StyleListView {   return StyleListView(view);  }
		private function get brushPropsModel ():BrushPropsModel {   return styleListView.brushPropsModel;   }
		private function get uiAsset ():Object {   return styleListView.uiAsset;  }
		private function get panelAsset ():Sprite {   return styleListView.panelAsset;  }
		private function get styleList ():RichList {   return styleListView.styleList;   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			panelAsset.addEventListener(MouseEvent.CLICK, mouseEvent);
			styleList.addEventListener(Event.CHANGE, styleChange);
			styleList.addEventListener(ListEvent.SELECT, styleChange);
			uiAsset.addEventListener(MouseEvent.CLICK, mouseEvent);
			//styleList.addEventListener(Event.COMPLETE, showPreview);
			uiAsset.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClick);
			styleList.addEventListener(MouseEvent.RIGHT_CLICK, rightClick);
			styleListView.styleContextMenu.addEventListener(Event.SELECT, contextMenuEvent);
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function doubleClick (e:MouseEvent):void
		{
			if (e.target.name == "_highlight") canvasManager.stylePreviewLayer.toggle();
			
		}
		
		private function styleChange (e:Event=null):void
		{
			ui.brushPropsModel.pullStyleProps();
			//brushPropsModel.changeStyle(styleListView.styleList.selectedItems);						
		}
		
		private function mouseEvent (e:MouseEvent):void
		{
			var name:String = e.target.name;
			//// // Consol.Trace(styleList.selectedIndex);
			if (name == "upBtn" && styleList.selectedIndex != 0)
			{
				//// // Consol.Trace("Move style up");
				styleList.moveItem(styleList.selectedIndex, -1);
				styleChange();
			}
			if (name == "downBtn" && styleList.selectedIndex != styleList.length-1)
			{
				//// // Consol.Trace("Move style down");
				styleList.moveItem(styleList.selectedIndex, 1);
				styleChange();
			}
			else
			{
				switch (name) 
				{
					case "previewBtn" :
						canvasManager.stylePreviewLayer.toggle();
					break;
					case "toggleBtn" :
						styleListView.toggle();
						ui.uiUpdate();
					break;
					case "helpBtn" :
						_loadHelp();
						//// // Consol.Trace("help from styles");
					break;
					case "saveBtn" :
						if (uiAsset.styleName.text!=null && uiAsset.styleName.text!="") 
						{
							styleChange();
							ui.brushPropsModel.createStyle(uiAsset.styleName.text);
						}
						uiAsset.styleName.text = "";
					break;
					case "dupBtn" :
						styleChange();
						ui.brushPropsModel.createStyle(uiAsset.styleName.text);
					break;
					case "removeBtn" :
						if (styleList.length>1) 
						{
							styleChange();
							ui.brushPropsModel.removeStyle(styleList.selectedItem.id);
						}
					break;
					case "importBtn" :
						styleChange();
						ui.brushPropsModel.importStyle();
					break;
					case "exportBtn" :
						styleChange();
						ui.brushPropsModel.exportStyle();
						//dispatchEvent (new FileEvent(FileEvent.IO_EVENT, true, false, FileEvent.EXPORT, FileManager.STYLE));
					break;
	
				}
			}
		}
		
		private function rightClick (e:MouseEvent):void
		{
			//// // Consol.Trace("StyleListController: right click: " + styleList.rightClickItemIndex);
			// if (Layer.isBoxLayer(activeLayer)) 
			styleListView.styleContextMenu.display(canvas.stage, canvas.stage.mouseX, canvas.stage.mouseY);
		}
		
		private function contextMenuEvent (e:Event):void
		{
			//// // Consol.Trace("StyleListController: context menu select");
			
			//// // Consol.Trace("StyleListController: " + brushPropsModel);
			
			switch (e.target.name)
			{
				case "copyStyle": brushPropsModel.styleManager.copyStyle(styleList.rightClickItemIndex); break;
				case "pasteStyle": brushPropsModel.styleManager.pasteStyle(styleList.rightClickItemIndex, true); break;
				case "pasteBehaveStyle": brushPropsModel.styleManager.pasteStyle(styleList.rightClickItemIndex, false, true); break;
				case "pasteLineStyle": brushPropsModel.styleManager.pasteStyle(styleList.rightClickItemIndex, false, false, true); break;
				case "pasteDecoStyle": brushPropsModel.styleManager.pasteStyle(styleList.rightClickItemIndex, false, false, false, true); break;
				case "pasteLineColors": brushPropsModel.styleManager.pasteStyle(styleList.rightClickItemIndex, false, false, false, false, true); break;
				case "pasteDecoColors": brushPropsModel.styleManager.pasteStyle(styleList.rightClickItemIndex, false, false, false, false, false, true); break;
				case "pasteDecos": brushPropsModel.styleManager.pasteStyle(styleList.rightClickItemIndex, false, false, false, false, false, false, true); break;
				case "pasteDecoThresh": brushPropsModel.styleManager.pasteStyle(styleList.rightClickItemIndex, false, false, false, false, false, false, false, true); break;
			}
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

		
		
		
	}
	
}