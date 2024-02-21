package com.livebrush.ui
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import fl.data.DataProvider;
	import flash.display.Sprite;
	import fl.controls.TextInput;
	import flash.text.TextField;
	import fl.containers.ScrollPane;
	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;
	
	import com.livebrush.ui.Consol;
	import com.livebrush.data.Settings;
	import com.livebrush.ui.RichListUI;
	import com.livebrush.ui.RichListItem;
	import com.livebrush.ui.RichListBg;
	import com.livebrush.events.ListEvent;
	
	import org.casalib.util.ArrayUtil;
	
	
	public class RichList extends EventDispatcher
	{
		
		public static var DEFAULT_RICH_ITEM			:Class = RichListItem;
		public static var BACKGROUND_ASSET			:Class = RichListBg;
		
		public var richListUI						:RichListUI
		private var richItemObject					:Class;
		private var _listHolder						:Sprite;
		private var _parent							:DisplayObjectContainer;
		private var _items							:Array;
		private var _itemHolder						:Sprite;
		private var _moveLines						:Sprite;
		private var _richItems						:Array;
		private var _selectedIndex					:int = 0;
		private var _selectedIndices				:Array;
		public var itemHeight						:Number;// = 30;
		private var bg								:Sprite;
		public var allowMultipleSelection			:Boolean = true;
		private var _moving							:Boolean = false;
		public var hoverItem						:RichListItem;
		public var rightClickItemIndex				:int;
		
		
		public function RichList (richListUI:RichListUI, richItemObject:Class=null, itemHeight:int=24):void
		{
			this.itemHeight = itemHeight;
			this.richListUI = richListUI;
			if (richItemObject == null) this.richItemObject = DEFAULT_RICH_ITEM;
			else this.richItemObject = richItemObject;
			_items=[];
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get uiAsset ():Sprite {   return richListUI;   }
		public function set dataProvider (l:Array):void {   _setList(l);   }
		//public function set list (l:Array):void {   _setList(l);   }
		public function get list ():Array {   return _items;   }
		public function set selectedIndex (i:int):void {   _setSelected([i], true, true);   }
		public function get selectedIndex ():int {   return _selectedIndex;   }
		public function set selectedIndices (a:Array):void {   if (a.length>0) _setSelected(a, true, true);   }
		public function get selectedIndices ():Array {   return _selectedIndices;   }
		public function set size (o:Object):void {   richListUI._holder.width=o.x; richListUI._holder.height=o.y;   }
		public function get length ():int {   return _items.length;   }
		private function get scrollPane ():ScrollPane {   return richListUI._scrollPane;   }
		private function get holder ():Sprite {   return _listHolder;   };
		public function get dataList ():Array {   return _getDataList();   }
		public function get selectedItems ():Array {   var selectedItems:Array=[]; for(var i:int=0;i<selectedIndices.length;i++) selectedItems.push(_items[selectedIndices[i]]); return selectedItems;   }
		public function get selectedItem ():Object {   return _items[selectedIndex];   }
		public function get topRichItem ():RichListItem {   return getRichItem(0);   }
		public function get bottomRichItem ():RichListItem {   return getRichItem(length-1);   }
		//public function set selectedItem (o:Object):void {   for (var i:int=0;i<length;i++) if (o == _items[i]) selectedIndex = i;   }
		public function set selectedItem (o:Object):void {   selectedIndex = Settings.objToIndex(o, _items);   }
		public function set selectedItems (list:Array):void {   var selectedIndices:Array=[]; for (var i:int=0;i<length;i++) for (var j:int=0;j<list.length;j++) if (list[j] == _items[i]) selectedIndices.push(i); this.selectedIndices=selectedIndices;   }
		public function set enabled (b:Boolean) {   scrollPane.enabled = uiAsset.mouseChildren = b;   }
		public function get enabled ():Boolean {   return scrollPane.enabled;   }
		
		
		// SETUP ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			_items = [];
			_selectedIndices = [];
			_richItems = [];
			
			_setupListHolder();
			
			_setupScrollPane();
			
			richListUI.addEventListener(Event.CHANGE, changeEvent);
		}
		
		private function _setupListHolder ():void
		{
			_listHolder = new Sprite();
			bg = _listHolder.addChild(new BACKGROUND_ASSET()) as Sprite;
			_itemHolder = _listHolder.addChild(new Sprite()) as Sprite;
			_moveLines = _listHolder.addChild(new Sprite()) as Sprite;
			_addRequiredAssets();
			
		}
		
		private function _addRichItem ():RichListItem
		{
			var index:int = _richItems.length;
			//trace(index);
			var richItem:RichListItem = new richItemObject(_itemHolder, index*itemHeight);
			richItem.parentList = this;
			_richItems.push(richItem);
			return richItem;
		}
		
		private function _setupScrollPane ():void
		{
			scrollPane.horizontalScrollPolicy = ScrollPolicy.OFF;
			scrollPane.verticalScrollPolicy = ScrollPolicy.ON;
			scrollPane.useBitmapScrolling = true;
			scrollPane.verticalLineScrollSize = itemHeight;
			scrollPane.source = holder;
			
			//refresh();
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function selectEvent (e:Event):void
		{
			_setSelected([e.target.index]);
			dispatchEvent(new ListEvent(ListEvent.SELECT));
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function changeEvent (e:Event):void
		{
			//e.stopImmediatePropagation();
			
			for (var i:int=0; i<length; i++)
			{
				_items[i] = _richItems[i].data;
			}
			//dispatchEvent(new ListEvent(ListEvent.CHANGE));
			dispatchEvent(new Event(Event.CHANGE));
			
			//trace("change");
			//// // Consol.Trace("change");
		}
		
		public function labelChange (e:ListEvent):void
		{
			
			dispatchEvent(new ListEvent(ListEvent.LABEL_CHANGE));

		}
		
		/*private function moveEvent (e:Event):void
		{
			if (e.type == Event.RESIZE)
			{
				trace("init move");
				_lockAllItemsExcept(e.target.index);
			}
			else if (e.type == Event.COMPLETE)
			{
				trace("move complete");
				_unlockAllItems();
			}
		}*/
		
		public function rightClick (e:MouseEvent):void
		{
			//e.stopImmediatePropagation();
			//// // Consol.Trace("right click in RichList");
			//// // Consol.Trace(hoverItem.data.label);
			dispatchEvent(new MouseEvent(MouseEvent.RIGHT_CLICK));
		}
		
		
		// INTERNAL ACTIONS /////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function _addRequiredAssets ():void
		{
			if (Math.max(10, length) > _richItems.length) 
			{
				var richItemLength:int = _richItems.length;
				var addNum:int = Math.max((length-richItemLength), 10);
				var richItem:RichListItem;
				
				//trace("adding rich item asset");
				for (var i:int=0; i<addNum; i++) 
				{
					richItem = _addRichItem()
					//richItem.addEventListener(Event.SELECT, selectEvent);
					//richItem.addEventListener(Event.CHANGE, changeEvent);
					richItem.addEventListener(ListEvent.LABEL_CHANGE, labelChange);
					richItem.addEventListener(ListEvent.SELECT, selectEvent);
					richItem.addEventListener(Event.CHANGE, changeEvent);
					richItem.addEventListener(MouseEvent.RIGHT_CLICK, rightClick);
					//richItem.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, rightClick);
					//richItem.addEventListener(Event.RESIZE, moveEvent);
					//richItem.addEventListener(Event.COMPLETE, moveEvent);
					//_addRichItem().addEventListener(ListEvent.ITEM_CLICK, selectEvent);
					
				}
			}
		}
		
		private function _assignItemData ():void
		{
			var richItem:RichListItem;
			
			_addRequiredAssets();
			
			for (var i:int=0; i<_richItems.length; i++)
			{
				richItem = _richItems[i];
				
				if (i < length)
				{
					richItem.index = i;
					if (!richItem.visible) richItem.visible = true;
					richItem.data = _items[i];
					richItem.lockUI(false);
				}
				else
				{
					richItem.visible = false;
				}
			}
		}
		
		/*private function _lockAllItemsExcept (index:int):void
		{
			for (var i:int=0; i<length; i++)
			{
				_richItems[i].uiAsset.mouseEnabled = _richItems[i].uiAsset.mouseChildren = false;
			}
			_richItems[index].uiAsset.mouseEnabled = _richItems[index].uiAsset.mouseChildren = true;
		}
		
		private function _unlockAllItems ():void
		{
			for (var i:int=0; i<length; i++)
			{
				_richItems[i].uiAsset.mouseEnabled = _richItems[i].uiAsset.mouseChildren = true;
			}
			//_richItems[index].uiAsset.mouseEnabled = _richItems[index].uiAsset.mouseChildren = true;
		}*/
		
		private function _setList (l:Array):void
		{
			//try { // // Consol.Trace(l.length); } catch(e:Error){}
			
			_items = l.slice();
			
			_assignItemData();
			
			refresh();
		}
		
		private function _setSelected (list:Array, force:Boolean=false, reset:Boolean=false):void
		{
			_selectedIndex = list[0];
			var selectedIndices:Array = [_selectedIndex];
			var richItem:RichListItem = _richItems[_selectedIndex];
			var i:int;
			
			if (force)
			{
				if (reset) 
				{
					for (i=0; i<length; i++) _richItems[i].selected = false;
					_selectedIndices = [];
				}
				selectedIndices = [];
				for (i=0; i<list.length; i++)
				{
					_richItems[list[i]].selected = true;
					selectedIndices.push(list[i])
				}
			}
			else if (!allowMultipleSelection || (!richItem.lastMouseEvent.ctrlKey && !richItem.lastMouseEvent.shiftKey)) 
			{
				for (i=0; i<_richItems.length; i++) _richItems[i].selected = false;
				_richItems[_selectedIndex].selected = true;
			}
			else //if (allowMultipleSelection && (richItem.lastMouseEvent.ctrlKey || richItem.lastMouseEvent.shiftKey)) 
			{
				if (richItem.lastMouseEvent.ctrlKey) 
				{
					var selected:Boolean = !_richItems[_selectedIndex].selected;
					_richItems[_selectedIndex].selected = selected;
					if (selected) 
					{
						selectedIndices = _selectedIndices.concat(selectedIndices);
					}
					else 
					{
						ArrayUtil.removeItem(_selectedIndices, _selectedIndex);
						selectedIndices = _selectedIndices;
					}
				}
				else if (richItem.lastMouseEvent.shiftKey) 
				{
					selectedIndices = _selectedIndices.concat(selectedIndices);
					selectedIndices.sort(Array.NUMERIC);
					
					var temp:Array = [];
					
					for (i=selectedIndices[0]; i<=selectedIndices[selectedIndices.length-1]; i++)
					{
						_richItems[i].selected = true;
						temp.push(i)
					}
					
					selectedIndices = temp.slice();
				}
			}

			_selectedIndices = selectedIndices.slice();
			
			//trace(_selectedIndices);
		}
		
		private function _updateBg ():void
		{
			//trace(length);
			bg.height = Math.max((scrollPane.height, itemHeight*length)) //- itemHeight;
		}
		
		
		// PUBLIC ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function selectItems (list:Array):void
		{
			var selectedIndices:Array=[]; 
			for (var i:int=0;i<length;i++) for (var j:int=0;j<list.length;j++) if (list[j] == _items[i]) selectedIndices.push(i);
			if (list.length>0) _setSelected(selectedIndices, true, true)
		}
		
		public function getRichItem (index:int):RichListItem
		{
			return _richItems[index];
		}
		
		public function addItem (o:Object):void
		{
			_items.push(o);
			//_addRequiredAssets();
			_assignItemData();
			
			refresh();
			
		}
		
		public function addItemAt (o:Object, index:int):void
		{
			_items.splice(index, 0, o);
			_assignItemData();
			refresh();
		}
		
		public function addItems (a:Array):void
		{
			_items = _items.concat(a);
			//_addRequiredAssets();
			_assignItemData();
			
			refresh();
		}
		
		public function moveItem (index:int, dir:Number):void
		{
			var item:Object = _items[index];
			_items.splice(index, 1);
			_items.splice(index+dir, 0, item);
			
			selectedIndex = index+dir;
			
			_assignItemData();
			refresh();
			// then the rich list editor notifies the change
		}
		
		public function removeItemsAt (index:int, count:int):void
		{
			//trace(length)
			_items.splice(index, count);
			_assignItemData();
			//trace(length)
			refresh();
		}
		
		public function refresh ():void
		{
			try 
			{
				_updateBg();
				scrollPane.update();
				scrollPane.refreshPane();
				scrollPane.validateNow();
			}
			catch (e:Error)
			{
			}
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function _getDataList ():Array
		{
			var l:Array = [];
			
			for (var i:int=0; i<length; i++)
			{
				l.push(_items[i].data);
			}
			
			return l;
		}
		
		
		
		// DEBUG ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////


	}
	
	
}