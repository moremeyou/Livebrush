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
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.UIUpdate;
	import com.livebrush.ui.NewProjectView;
	import com.livebrush.ui.SettingsUI;
	import com.livebrush.events.ListEvent;
	
	public class NewProjectController extends UIController
	{
		
		public function NewProjectController (newProjectView:NewProjectView):void
		{
			super(newProjectView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get newProjectView ():NewProjectView {   return NewProjectView(view);  }
		private function get uiAsset ():NewProjectUI {   return newProjectView.uiAsset;  }
		private function get panelAsset ():Object {   return newProjectView.panelAsset;  }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			uiAsset.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.sizeList.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.bgList.addEventListener(Event.CHANGE, propsChangeEvent);
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
			uiAsset.sizeList.removeEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.bgList.removeEventListener(Event.CHANGE, propsChangeEvent);
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
			else if (e.type == MouseEvent.MOUSE_DOWN && e.target.name == "titleBtn" && newProjectView.enableDrag) 
			{
				//// // Consol.Trace("Dialog titlebar clicked: start drag");
				panelAsset.startDrag();
				//ui.main.saveProject();
			}
			else if (e.type == MouseEvent.MOUSE_UP && e.target.name == "titleBtn" && newProjectView.enableDrag) 
			{
				panelAsset.stopDrag();
			}
		}
		
		private function mouseEvent (e:MouseEvent):void
		{
			switch (e.target.name) {
				case "cancelBtn" :
					ui.newProjectView = null
					ui.closeWindow(newProjectView);
				break;
				case "okBtn" :
					//Consol.Trace("NewProjectController: mouseEvent, sizeList.selectedIndex = " + uiAsset.sizeList.selectedIndex);
					//Consol.Trace("NewProjectController: mouseEvent, Canvas.sizeRes[0][0].x = " + Canvas.sizeRes[uiAsset.sizeList.selectedIndex][0].x);
					//Consol.Trace("NewProjectController: mouseEvent, Canvas.WIDTH = " + Canvas.WIDTH);
					
					//Canvas.sizeRes[0][0].x = Math.max(100, Math.min(3000, int(uiAsset.cWidth.text)));
					//Canvas.sizeRes[0][0].y = Math.max(100, Math.min(3000, int(uiAsset.cHeight.text)));
					
					var checkWidth:int = Math.max(100, Math.min(3000, int(uiAsset.cWidth.text)));
					var checkHeight:int = Math.max(100, Math.min(3000, int(uiAsset.cHeight.text)));
					
					if (checkWidth != int(uiAsset.cWidth.text) || checkHeight != int(uiAsset.cHeight.text))
					{
						
						ui.alert({message:"Canvas size must be greater than 100px \nand less than 3000px.", id:"newCanvasSizeError"});
						return;
					}
					else
					{
						Canvas.sizeRes[0][0].x = checkWidth;
						Canvas.sizeRes[0][0].y = checkHeight;
					}
					
					ui.createNewProject(uiAsset.sizeList.selectedIndex, uiAsset.bgList.selectedIndex);
					ui.newProjectView = null
					ui.closeWindow(newProjectView);
				break;
			}
		}
		
		private function propsChangeEvent (e:Event):void
		{
			//newProjectView.update();
			
			// if txt boxes change, 
			// switch to custom in drop down, 
			// update custom Canvas static var
			var tName:String = e.target.name;
			//Consol.Trace("NewProjectController: propsChangeEvent, e.target.name = " + tName);
			
			if (tName == "cWidth" || tName == "cHeight")
			{
				uiAsset.sizeList.selectedIndex = 0;
				//Canvas.sizeRes[0][0].x = int(uiAsset.cWidth.text);
				//Canvas.sizeRes[0][0].y = int(uiAsset.cHeight.text);
				
				//Consol.Trace("NewProjectController: propsChangeEvent, sizeList.selectedIndex = " + uiAsset.sizeList.selectedIndex);
				//Consol.Trace("NewProjectController: propsChangeEvent, Canvas.sizeRes[0][0].x = " + Canvas.sizeRes[uiAsset.sizeList.selectedIndex][0].x);
			}
			else if (tName == "sizeList")
			{
				uiAsset.cWidth.text = Canvas.sizeRes[uiAsset.sizeList.selectedIndex][0].x;
				uiAsset.cHeight.text = Canvas.sizeRes[uiAsset.sizeList.selectedIndex][0].y;
			}
			/*else if (tName == "bgList")
			{
				uiAsset.cWidth.text = Canvas.sizeRes[uiAsset.sizeList.selectedIndex][0].x;
				uiAsset.cHeight.text = Canvas.sizeRes[uiAsset.sizeList.selectedIndex][0].y;
			}*/

			

		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////

		
		
		
	}
	
}