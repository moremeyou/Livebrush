package com.livebrush.ui
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.EventPhase;
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
	import fl.controls.ScrollPolicy;
	
	import com.livebrush.data.Settings;
	import com.livebrush.ui.RichList;
	import com.livebrush.ui.RichListUI;
	import com.livebrush.ui.ColorListItemUI;
	import com.livebrush.ui.RichListItem;
	import com.livebrush.ui.RichListBg;
	import com.livebrush.ui.ColorInput;
	import com.livebrush.events.ListEvent;
	
	
	public class ColorListItem extends RichListItem
	{
		
		//public static var ITEM_UI					:Class = ColorListItemUI;
		//public static var DEFAULT_ITEM_UI			:Class = ColorListItemUI;
		//public static var HEIGHT					:int = 30;
		
		private var _colorValue						:uint = 0xFFFFFF;
		private var _colorHexValue					:String = "FFFFFF";
		private var _active							:Boolean = true;
		//public var colorUI							:ColorPicker;
		public var colorInput						:ColorInput;
		public var enabledUI						:CheckBox;
		public var colorBg							:MovieClip;
		private var _cf								:ColorTransform;
		
		
		public function ColorListItem (parent:DisplayObjectContainer, y:Number=0):void
		{
			super(parent, y, ColorListItemUI);
			
			init();

		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get color ():uint {  return  colorInput.color;   }
		public function set color (u:uint):void {   _setColor(u);   }
		public function get enabled ():Boolean {  return  enabledUI.selected;   }
		public function set enabled (b:Boolean):void {   enabledUI.selected = b;   }
		
		
		// SETUP ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			colorInput = uiAsset["_colorInput"]
			enabledUI = uiAsset["_enabled"];
			colorBg = uiAsset["_colorBg"];
			
			uiAsset.addEventListener(Event.CHANGE, itemChange);
		}

		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function itemChange (e:Event):void
		{
			if (e.target is ColorPicker) _setColor(colorInput.color); // HexString
			
			//data.color = data.data = color;
			data.value = color;
			
			data.enabled = enabled;
		}
		
		protected override function _mouseClick (e:MouseEvent):void
		{
			//// // Consol.Trace("mouse click color item");
			if (e.target == highlight || e.target == colorBg || e.target == uiAsset["_label"]) dispatchEvent(new ListEvent(ListEvent.SELECT));
		}
		
		protected override function _mouseOver ():void
		{
			//if (!selected) highlight.alpha = .5;
			//try {   parentList.hoverItem = this;   } catch(e:Error){};
		}
		
		
		// INTERNAL ACTIONS /////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function _setData (o:Object):void
		{
			//_setColor(o.data);
			_setColor(o.value);
			enabled = o.enabled;
		}
		
		private function _setColor (c:uint):void
		{
			colorInput.color = c; // HexString
			colorBg.transform.colorTransform = colorInput.colorTransform;
		}
		
		protected override function _setSelected (b:Boolean):void
		{
			if (b)
			{
				highlight.alpha = 1;
				//ColorUtils.tintObject(highlight, 0x0066CC, .25);
				_selected = b;
			}
			else
			{
				_selected = b;
				//ColorUtils.resetColor(highlight);
				_mouseOut();
			}
		}
		
		
		// PUBLIC ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// DEBUG ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////


	}
	
	
}