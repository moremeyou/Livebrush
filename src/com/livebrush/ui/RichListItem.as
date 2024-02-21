package com.livebrush.ui
{
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
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
	import com.livebrush.ui.RichListItem;
	import com.livebrush.ui.RichListBg;
	import com.livebrush.events.ListEvent;
	import com.livebrush.utils.ColorUtils;
	
	
	public class RichListItem extends EventDispatcher
	{
		
		public static var ITEM_UI					:Class = RichListItemUI;
		//public static var HEIGHT					:int = 30;
		
		public var listItemUIObject					:Class
		public var listItemUI						:Sprite;
		private var _parent							:DisplayObjectContainer;
		protected var _selected						:Boolean = false;
		protected var _data							:Object;
		public var index							:int;
		private var _lastMouseEvent					:MouseEvent;
		private var _moveTimeout					:int;
		private var _moving							:Boolean = false;
		public var parentList						:RichList;
	
		public function RichListItem (parent:DisplayObjectContainer, y:Number=0, listItemUIObject:Class=null):void
		{
			_parent = parent;
			if (listItemUIObject == null) this.listItemUIObject = ITEM_UI;
			else this.listItemUIObject = listItemUIObject;
			
			init();
			
			this.y = y;
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected function get highlight ():Sprite {   return uiAsset["_highlight"];   }
		public function get uiAsset ():Sprite {   return listItemUI;   }
		public function set y (y:Number):void {   listItemUI.y=y;   }
		public function set data (o:Object):void {   _data=o; _setData(o);   }
		public function get data ():Object {   return _data;   }
		public function set label (s:String):void {   uiAsset["_label"].text=s;   }
		public function set visible (b:Boolean):void {   _setVisible(b);   }
		public function get visible ():Boolean {   return _parent.contains(uiAsset);   }
		public function set selected (b:Boolean):void {   _setSelected(b);   }
		public function get selected ():Boolean {   return _selected;   }
		public function get lastMouseEvent ():MouseEvent {   return _lastMouseEvent;   }
		
		
		// SETUP ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			listItemUI = new listItemUIObject();
			
			_lastMouseEvent = new MouseEvent(MouseEvent.MOUSE_MOVE);
	
			listItemUI.addEventListener(MouseEvent.MOUSE_OVER, mouseEvent);
			listItemUI.addEventListener(MouseEvent.MOUSE_OUT, mouseEvent);
			listItemUI.addEventListener(MouseEvent.MOUSE_DOWN, mouseEvent);
			listItemUI.addEventListener(MouseEvent.MOUSE_UP, mouseEvent);
			listItemUI.addEventListener(MouseEvent.CLICK, mouseEvent);
		}

		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function mouseEvent (e:MouseEvent):void
		{
			//trace(e.target);
			_lastMouseEvent = e;
			if (e.type == MouseEvent.MOUSE_OVER)
			{
				_mouseOver();
			}
			else if (e.type == MouseEvent.MOUSE_OUT)
			{
				_mouseOut();
			}
			else if (e.type == MouseEvent.MOUSE_DOWN)
			{
				_mouseClick(e);
				//if (e.target == highlight || e.target == uiAsset["_label"]) _moveTimeout = setTimeout(initMove, 200);
			}
			else if (e.type == MouseEvent.MOUSE_UP)
			{
				//clearTimeout(_moveTimeout);
				//if (_moving) dispatchEvent(new Event(Event.COMPLETE));
				//_moving = false;
			}
			else if (e.type == MouseEvent.CLICK)
			{
				//_mouseClick(e);
			}
		}
		
		protected function _mouseOver ():void
		{
			if (!selected) highlight.alpha = .5;
			try {   parentList.hoverItem = this;   } catch(e:Error){};
		}
		
		protected function _mouseOut ():void
		{
			if (!selected) highlight.alpha = 0;
		}
		
		protected function _mouseClick (e:MouseEvent):void
		{
			if (e.target == highlight || e.target == uiAsset["_label"]) dispatchEvent(new ListEvent(ListEvent.SELECT));
		}
		
		/*private function initMove ():void
		{
			clearTimeout(_moveTimeout);
			_moving = true;
			dispatchEvent(new Event(Event.RESIZE));
		}*/
		
		
		// INTERNAL ACTIONS /////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected function _setData (o:Object):void
		{
			//_data = o;
			label = o.label;
		}
		
		protected function _setVisible (b:Boolean):void
		{
			try 
			{
				if (b) _parent.addChild(listItemUI);
				else _parent.removeChild(listItemUI);
			}
			catch (e:Error)
			{
			}
		}
		
		protected function _setSelected (b:Boolean):void
		{
			if (b)
			{
				highlight.alpha = 1;
				ColorUtils.tintObject(highlight, 0x0066CC, .25);
				_selected = b;
			}
			else
			{
				_selected = b;
				ColorUtils.resetColor(highlight);
				_mouseOut();
			}
		}
		
		
		// PUBLIC ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function lockUI (b:Boolean=true):void
		{
			//enabledUI.enabled = labelUI.enabled = !b;
			//enabledUI.visible = !b;
			//labelUI.mouseChildren = !b;
			//labelUI.doubleClickEnabled = !b;
			//labelUI.removeEventListener(MouseEvent.DOUBLE_CLICK, doubleClickEvent);
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// DEBUG ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////


	}
	
	
}