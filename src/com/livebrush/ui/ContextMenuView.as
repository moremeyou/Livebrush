package com.livebrush.ui
{
	import flash.display.NativeWindowDisplayState;
	
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	
	import com.livebrush.tools.TransformTool;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.events.TitlebarEvent;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.UIUpdate;
	import com.livebrush.ui.ContextMenuController;
	
	public class ContextMenuView extends UIView
	{
		
		public var menu					:NativeMenu;
		
		public function ContextMenuView (ui:UI):void
		{
			super(ui);
			
			init();
		}
		
		
		protected override function createView ():void
		{
			createContextMenu();
		}
		
		private function createContextMenu ():void
		{
			menu = new NativeMenu(); 
			
			var testMenuItem = menu.addItem(new NativeMenuItem("Test Menu Item"));
		}
		
		protected override function createController ():void
		{
			controller = new ContextMenuController(this);
		}
		
		// Utils
		public function setMenuItemState (menu:NativeMenu, enabled:Boolean, checked:Boolean=false):void
		{
			setMenuItemListState(menu.items, enabled, checked);
		}
		
		public function setMenuIndexListState (menu:NativeMenu, indexList:Array, enabled:Boolean, checked:Boolean=false):void
		{
			for (var i:int=0; i<indexList.length; i++)
			{
				setItemState(menu.items[indexList[i]], enabled, checked);
			}
		}
		
		public function setMenuItemListState (itemList:Array, enabled:Boolean, checked:Boolean=false):void
		{
			for (var i:int=0; i<itemList.length; i++)
			{
				setItemState(itemList[i], enabled, checked);
			}
		}
		
		public function setItemState (item:NativeMenuItem, enabled:Boolean, checked:Boolean=false):void
		{
			item.checked = checked;
			item.enabled = enabled;
		}
		
	}
	
	
}