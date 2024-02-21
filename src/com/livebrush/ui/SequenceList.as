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
	import fl.controls.ComboBox;
	
	import com.livebrush.data.Settings;
	import com.livebrush.ui.PropInputHorizontal;
	import com.livebrush.ui.RichList;
	import com.livebrush.ui.RichListUI;
	import com.livebrush.ui.RichListEditor;
	import com.livebrush.ui.RichListEditorUI;
	import com.livebrush.ui.SequenceListUI;
	import com.livebrush.ui.RichListItem;
	import com.livebrush.ui.RichListBg;
	import com.livebrush.events.ListEvent;
	
	
	public class SequenceList extends RichListEditor
	{
		
		public var sequenceListUI						:SequenceListUI
		//private var _itemHeight						:Number = 30;
		public var typeInput							:ComboBox;
		public var speedInput							:PropInputHorizontal;
		public var holdInput							:PropInputHorizontal;
		
		
		
		public function SequenceList (sequenceListUI:SequenceListUI, richItemObject:Class=null):void
		{
			super(sequenceListUI._listEditor, richItemObject);
			
			this.sequenceListUI = sequenceListUI;
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function get uiAsset ():Sprite {   return sequenceListUI;   }
		public function set typeList (l:Array):void {   typeInput.dataProvider = new DataProvider(l);   }
		public function set type (o:Object):void {   typeInput.selectedIndex = Settings.idToIndex(String(o), typeInput.dataProvider.toArray(), "data");   }
		public function get type ():Object {   return typeInput.selectedItem.data;   }
		public function set speed (n:Number) {   speedInput.value = n;   }
		public function get speed ():Number {   return speedInput.value;   }
		public function set speedLabel (s:String) {   speedInput.label = s;   }
		public function set speedEnabled (b:Boolean) {   speedInput.enabled = b;   }
		public function get speedEnabled ():Boolean {   return speedInput.enabled;   }
		public override function set enabled (b:Boolean) {   super.enabled = typeInput.enabled = speedInput.enabled = holdInput.enabled = b;   }
		
		
		// SETUP ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			
			typeInput = uiAsset["_type"];
			speedInput = uiAsset["_speed"];
			holdInput = uiAsset["_hold"];
			
			//sequenceListUI.addEventListener(Event.CHANGE, changeEvent);
			typeInput.addEventListener(Event.CHANGE, changeEvent);
			
		}
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function typeChange (e:Event):void
		{
			//dispatchEvent(new Event(Event.CHANGE));
		}*/
		
		
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