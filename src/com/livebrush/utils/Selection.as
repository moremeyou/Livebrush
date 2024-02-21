package com.livebrush.utils
{
	import flash.events.EventDispatcher;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.setTimeout;
	import flash.events.EventPhase;
	
	
	public class Selection extends EventDispatcher 
	{
		//public static const SELECTED							:String = "selected";
		//public static const BRUSH_TOOL							:String = BrushTool;
		

		private var _items										:Array;
	
		
		public function Selection ():void
		{
			
			init();
		}
		
		private function init ():void
		{
			_items = [];
		}
		
		public function get length ():int {   return _items.length;   }
		public function get items ():Array {   return _items;   }
		
		public function addAndRemoveItem (o:Object):Boolean
		{
			var index:int = selectionIndex(o);
			var alreadySelected:Boolean = (index > -1);
			if (alreadySelected) removeItemNum(index);
			else _items.push(o);
			return !alreadySelected; // if added, return true, otherwise false
		}
		
		public function addAndRemoveItems (items:Array):void
		{
			for (var i:int=0; i<items.length; i++)
			{
				addAndRemoveItem(items[i]);
			}
		}
		
		public function removeItemNum (i:int):Object
		{
			return _items.splice(i, 1)[0];
		}
		
		public function push (o:Object):void
		{
			addItem(o);
		}
		
		public function addItem (o:Object):void
		{
			var alreadySelected:Boolean = isSelected(o);
			if (!alreadySelected) _items.push(o);
			//return alreadySelected;
		}
		
		public function addItems (items:Array):void
		{
			for (var i:int=0; i<items.length; i++)
			{
				addItem(items[i]);
			}
		}
		
		public function addSelection (s:Selection, removeDuplicates:Boolean=false):void
		{
			var i:int=0;
			
			if (removeDuplicates)
			{
				for (; i<s.items.length; i++)
				{
					addAndRemoveItem(s.items[i]);
				}
			}
			else 
			{
				for (; i<s.items.length; i++)
				{
					addItem(s.items[i]);
				}
			}
		}
		
		
		public function isSelected (o:Object):Boolean
		{
			return (selectionIndex(o) > -1);
		}
		
		private function selectionIndex (o:Object):int
		{
			/*var index:int = -1;
			for (var i:int=0; i<_items.length; i++) 
			{
				if (_items[i] == o) 
				{
					index = i;
					break; 
				}
			}
			return index;*/
			return _items.indexOf(o);
		}
		
		public function getItem (i:int):Object
		{
			return _items[i];
		}
		
		public function clone ():Selection
		{
			var newSelection:Selection = new Selection();
			newSelection.addItems(items);
			return newSelection;
		}
		
		public function clear ():void
		{
			_items = [];
		}
		
		
	
		
	}
	
}