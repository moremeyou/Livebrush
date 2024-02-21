package com.livebrush.ui
{
	import flash.events.Event;
	
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
	
	public class MainMenuController extends UIController
	{
		
		public function MainMenuController (mainMenuView:MainMenuView):void
		{
			super(mainMenuView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get mainMenuView ():MainMenuView {   return MainMenuView(view);  }
		private function get mainMenu ():NativeMenu {   return mainMenuView.mainMenu;  }
		private function get fileMenu ():NativeMenu {   return mainMenuView.fileMenu;  }
		//private function get modifyMenu ():NativeMenu {   return mainMenuView.modifyMenu;  }
		private function get layerMenu ():NativeMenu {   return mainMenuView.layerMenu;  }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			mainMenu.addEventListener(Event.SELECT, menuSelect);
			//fileMenu.addEventListener(Event.DISPLAYING, menuDisplay); // these only work on the target object
			// might be able to register with parent menus that aren't root... but haven't confirmed yet

			layerMenu.addEventListener(Event.DISPLAYING, menuDisplay);
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function menuDisplay (e:Event):void
		{
			//// // Consol.Trace(e.target);
			if (e.target == layerMenu)
			{
				//// // Consol.Trace("layer menu display");
				//ui.mainMenuEvent(e);
				mainMenuView.updateLayerMenu();
			}
		}
		
		private function menuSelect (e:Event):void
		{
			//// // Consol.Trace("menu select");
			ui.mainMenuEvent(e);
			
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

		
		
		
	}
	
}