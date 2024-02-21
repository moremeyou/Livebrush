package com.livebrush.ui
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.EventPhase;
	import fl.events.ListEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.geom.ColorTransform;
	import fl.data.DataProvider;
	import flash.display.Sprite;
	import fl.controls.TextInput;
	import fl.controls.CheckBox;
	import fl.controls.ColorPicker;
	import flash.text.TextField;
	import fl.containers.ScrollPane;
	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;
	
	import com.livebrush.data.Settings;
	import com.livebrush.ui.RichList;
	import com.livebrush.ui.RichListUI;
	import com.livebrush.ui.DecoListItemUI;
	import com.livebrush.ui.RichListItem;
	import com.livebrush.ui.RichListBg;
	import com.livebrush.events.ListEvent;
	
	
	
	public class DecoListItem extends RichListItem
	{
		
		//public static var ITEM_UI					:Class = ColorListItemUI;
		//public static var DEFAULT_ITEM_UI			:Class = ColorListItemUI;
		//public static var HEIGHT					:int = 30;
		
		private var _colorValue						:uint = 0xFFFFFF;
		private var _colorHexValue					:String = "FFFFFF";
		private var _active							:Boolean = true;
		//public var colorUI							:ColorPicker;
		public var enabledUI						:CheckBox;
		//public var colorBg							:MovieClip;
		//private var _cf								:ColorTransform;
		
		public function DecoListItem (parent:DisplayObjectContainer, y:Number=0):void
		{
			super(parent, y, DecoListItemUI);
			
			init();

		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function set label (s:String):void {   uiAsset["_label"]._label.text=s;   }
		//public function get enabled ():Boolean {  return  enabledUI.selected;   }
		//public function set enabled (b:Boolean):void {   enabledUI.selected = b;   }
		
		
		// SETUP ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			//enabledUI = uiAsset["_enabled"];
			//uiAsset["_label"].enabled = uiAsset["_label"].mouseChildren = false;
			uiAsset["_label"].mouseChildren = false;
			
			uiAsset.addEventListener(Event.CHANGE, itemChange);
		}

		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function itemChange (e:Event):void
		{
			//data.enabled = enabled;
		}
		
		
		
		
		// INTERNAL ACTIONS /////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function _setData (o:Object):void
		{
			//_setColor(o.data);
			label = o.fileName;
			//enabled = o.enabled;
		}
		//, "fileName", "assetPath"
		
		
		// PUBLIC ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		
		// DEBUG ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////


	}
	
	
}