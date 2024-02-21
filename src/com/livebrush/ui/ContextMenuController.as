package com.livebrush.ui
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
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
	
	public class ContextMenuController extends UIController
	{
		
		public function ContextMenuController (contextMenuView:ContextMenuView):void
		{
			super(contextMenuView);
			//// // Consol.Trace("context menu controller");
			init();
		}
		
		private function get contextMenuView ():ContextMenuView {   return ContextMenuView(view);  }
		private function get menu ():NativeMenu {   return contextMenuView.menu;  }
		
		
		/*protected override function init ():void
		{
			//mainMenu.addEventListener(Event.SELECT, menuSelect);
			//fileMenu.addEventListener(Event.DISPLAYING, menuDisplay); // these only work on the target object
			// might be able to register with parent menus that aren't root... but haven't confirmed yet

			//layerMenu.addEventListener(Event.DISPLAYING, menuDisplay);
			//Consol.
		}
*/

		protected override function contentRightMouseDown (e:MouseEvent):void
		{
			// // Consol.Trace("right click!");
			//menu.display(canvas.stage, e.stageX, e.stageY);
		}
		
		/*private function menuDisplay (e:Event):void
		{
			//// // Consol.Trace(e.target);
			if (e.target == layerMenu)
			{
				// // Consol.Trace("layer menu display");
				//ui.mainMenuEvent(e);
				contextMenuView.updateLayerMenu();
			}
		}
		
		private function menuSelect (e:Event):void
		{
			//// // Consol.Trace("menu select");
			
			//// // Consol.Trace(e.target.name);
			
			//switch (e.target.name) 
			//{
				//case "openProject":
					//// // Consol.Trace("got it");
					ui.mainMenuEvent(e);
				//break;
			//}

			
			
		}*/
		
		
		
	}
	
}