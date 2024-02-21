package com.livebrush.ui
{
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import fl.events.ComponentEvent;
	
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.UIUpdate;
	
	public class ToolbarController extends UIController
	{
		
		
		public function ToolbarController (toolbarView:ToolbarView):void
		{
			super(toolbarView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get toolbarView ():ToolbarView {   return ToolbarView(view);  }
		private function get toolbarAsset ():Sprite {   return toolbarView.toolbarAsset;  }
		private function get toolBtns ():Array {   return toolbarView.toolBtns;   }
		private function get uiAsset ():Object {   return toolbarAsset;  }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			for (var i:int=0; i<toolBtns.length; i++)
			{
				toolBtns[i].doubleClickEnabled = true;
				toolBtns[i].getChildAt(0).doubleClickEnabled = true;
				toolBtns[i].mouseEnabled = true;
				toolBtns[i].addEventListener(MouseEvent.DOUBLE_CLICK, mouseEvent);
				toolBtns[i].addEventListener(MouseEvent.MOUSE_DOWN, mouseEvent);
			}
			
			uiAsset.addEventListener(Event.CHANGE, changeListener);
			uiAsset.zoomValue.addEventListener(ComponentEvent.ENTER, changeListener);
			uiAsset.canvasZoom.addEventListener(Event.CHANGE, changeListener);
			
			toolbarAsset.addEventListener(MouseEvent.CLICK, mouseEvent);
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function changeListener (e:Event):void {
		
			
			
			//Consol.Trace("TitlebarController: changeListener, e.type = " + e.type);
			
			if (e.target.name == "canvasZoom")
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
			}

		
		}
		
		
		private function mouseEvent (e:MouseEvent):void
		{
			//Consol.Trace("ToolbarController: mouseEvent, e.target.name = " + e.target.name);
			if (e.type == MouseEvent.DOUBLE_CLICK)
			{
				if (e.target.parent.name.indexOf("Btn") > -1 || e.target.name.indexOf("Btn") > -1)
				{
					ui.toggleToolProps();
				}
			}
			else if (e.type == MouseEvent.CLICK)
			{
				// Consol.Trace("ToolbarController: mouseClickEvent: " + e.target.name);
				
				if (e.target.name == "lockColorBtn") {
					
					e.target.parent.gotoAndStop(2);
					ui.styleManager.lockColors(true);
				
				} else if (e.target.name == "unlockColorBtn") {
					
					e.target.parent.gotoAndStop(1);
					ui.styleManager.lockColors(false);
				
				} else if (e.target.name == "toggleBtn") {
					ui.togglePropsPanel();
				} else if (e.target.name == "_colorBg") {
					//// Consol.Trace("ToolbarController: colorClick");
					ui.toggleGlobalColor();
				}
				else if (e.target.name == "helpBtn")
				{
					_loadHelp();
					//ui.loadHelp(UIView(view).helpID);
				} 
				else if (e.target.name == "zoomIn") {
					
					ui.canvasZoom(.25);
				
				}
				else if (e.target.name == "zoomOut") {
					
					ui.canvasZoom(-.25);
				
				}
				
			}
			else if (e.type == MouseEvent.MOUSE_DOWN)
			{
				if (e.target.parent.name.indexOf("Btn") > -1) {
					//toolbarView.toggleTool(e.target.parent.name);
					ui.toolSelect(e.target.parent.toolName);
				}
			}
			
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
	
		
		
		
	}
	
}