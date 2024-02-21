package com.livebrush.ui
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import fl.data.DataProvider;
	import flash.display.Sprite;
	import fl.controls.TextInput;
	import flash.text.TextField;
	import fl.containers.ScrollPane;
	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;
	
	import com.livebrush.data.Settings;
	import com.livebrush.ui.RichList;
	import com.livebrush.ui.RichListUI;
	import com.livebrush.ui.RichListEditorUI;
	import com.livebrush.ui.RichListItem;
	import com.livebrush.ui.RichListBg;
	import com.livebrush.events.ListEvent;
	
	
	public class RichListEditor extends RichList
	{
		
		public var richListEditorUI					:RichListEditorUI
		public var orderEditable					:Boolean = true;
		public var minListLength					:int = 1;
		
		public function RichListEditor (richListEditorUI:RichListEditorUI, richItemObject:Class=null):void
		{
			super(richListEditorUI._list, richItemObject);
			
			this.richListEditorUI = richListEditorUI;
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function get uiAsset ():Sprite {   return richListEditorUI;   }
		public override function set enabled (b:Boolean) {   super.enabled = uiAsset.mouseChildren = b;   }
		
		
		// SETUP ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			richListEditorUI.addEventListener(Event.CHANGE, changeEvent);
			richListEditorUI.addEventListener(MouseEvent.CLICK, btnClickEvent);
			//richListEditorUI.addEventListener(Event.CHANGE, changeEvent);
			
		}
		
		private function btnClickEvent (e:MouseEvent):void
		{
			//// // Consol.Trace(selectedIndex);
			//trace(e.target.name);
			var name:String = e.target.name;
			if (name.indexOf("Btn")>-1)
			{
				if (name == "removeBtn" && length > minListLength)
				{
					//removeItemsAt(selectedIndex, 1);
					//changeEvent(e);
					dispatchEvent(new ListEvent(ListEvent.REMOVE, false, false, selectedIndex));
				}
				else if (name == "addBtn")
				{
					dispatchEvent(new ListEvent(ListEvent.ADD, false, false, selectedIndex));
				}
				else if (name == "upBtn" && selectedIndex != 0)
				{
					if (orderEditable) moveItem(selectedIndex, -1);
					//dispatchEvent(new ListEvent(ListEvent.MOVE, false, false, {index:selectedIndex, dir:-1}));
					dispatchEvent(new Event(Event.CHANGE));
					//if (orderEditable) moveItem(i);
				}
				else if (name == "downBtn" && selectedIndex != length-1)
				{
					if (orderEditable) moveItem(selectedIndex, 1);
					//dispatchEvent(new ListEvent(ListEvent.MOVE, false, false, {index:selectedIndex, dir:1}));
					dispatchEvent(new Event(Event.CHANGE));
				}
				
			}
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// INTERNAL ACTIONS /////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// PUBLIC ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// DEBUG ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////


	}
	
	
}