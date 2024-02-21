package com.livebrush.ui
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.FocusEvent;
	import flash.events.EventPhase;
	//import fl.events.ListEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.ui.Keyboard;
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	/*import flash.display.Shape;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.EventPhase;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.Stage;
	import flash.utils.setTimeout;
	import flash.geom.Point;
	import flash.geom.Rectangle;*/
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
	import flash.text.TextFieldType;
	
	
	import com.livebrush.data.Settings;
	import com.livebrush.ui.RichList;
	import com.livebrush.ui.RichListUI;
	import com.livebrush.ui.StyleListItemUI;
	import com.livebrush.ui.RichListItem;
	import com.livebrush.ui.StyleListItem;
	import com.livebrush.ui.RichListBg;
	import com.livebrush.events.ListEvent;
	/*import com.livebrush.utils.Update;
	import com.livebrush.data.FileManager;
	import com.livebrush.ui.*;
	//import com.livebrush.tools.BrushTool;
	import com.livebrush.tools.*;
	import com.livebrush.events.*;
	import com.livebrush.Main;
	import com.livebrush.styles.StyleManager;
	import com.livebrush.tools.ToolManager;
	import com.livebrush.graphics.canvas.CanvasManager
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.StylePreviewLayer;*/
	
	
	public class StyleListItem extends RichListItem
	{
		
		private var _colorValue						:uint = 0xFFFFFF;
		private var _colorHexValue					:String = "FFFFFF";
		private var _active							:Boolean = true;
		public var enabledUI						:CheckBox;
		private var thumb							:MovieClip;
		private var thumbBmp						:Bitmap;
		private var labelUI							:TextField;
		private var editing							:Boolean = false;
		private var bg								:MovieClip;
		
		public function StyleListItem (parent:DisplayObjectContainer, y:Number=0):void
		{
			super(parent, y, StyleListItemUI);
			
			init();

		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function set label (s:String):void {   labelUI.text = s;   }
		public function get label ():String {   return labelUI.text;   }
		
		
		// SETUP ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			labelUI = uiAsset["_label"];
			//bg = uiAsset["_bg"];
			highlight.doubleClickEnabled = true;
			
			_toggleLabelEdit();
			_toggleLabelEdit();
			
			//highlight.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickEvent);
			labelUI.addEventListener(KeyboardEvent.KEY_DOWN, keyEvent);
			labelUI.addEventListener(Event.CHANGE, changeEvent);
			labelUI.addEventListener(MouseEvent.RIGHT_CLICK, rightClick);
		}

		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function _mouseClick (e:MouseEvent):void
		{
			//if (e.target == labelUI) 
			dispatchEvent(new ListEvent(ListEvent.SELECT));
		}
		
		private function doubleClickEvent (e:MouseEvent):void
		{
			//if (e.target == labelUI) _toggleLabelEdit();
			
			//else dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function keyEvent (e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER && e.type == KeyboardEvent.KEY_DOWN && e.target == labelUI)
			{
				applyLabel();
			}
			else if (e.type == KeyboardEvent.KEY_DOWN && e.target == labelUI)
			{
				e.stopImmediatePropagation();
			}
		}
		
		private function changeEvent (e:Event):void
		{
			if (e.target == labelUI)
			{
				e.stopImmediatePropagation();
			}
		}
		
		private function rightClick (e:MouseEvent):void
		{
			//// // Consol.Trace("right click in RichListItem");
			e.stopImmediatePropagation();
			parentList.rightClickItemIndex = index;
			dispatchEvent(new MouseEvent(e.type));
			
		}
		
		
		// INTERNAL ACTIONS /////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function _setData (o:Object):void
		{
			label = o.name;
		}
		
		private function _toggleLabelEdit ():void
		{
			editing = !editing;
			
			labelUI.doubleClickEnabled = !editing;
			labelUI.selectable = editing;
			labelUI.border = labelUI.background = editing;
			
			if (!editing)
			{
				labelUI.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickEvent);
				labelUI.removeEventListener(FocusEvent.FOCUS_OUT, applyLabel);
				labelUI.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, applyLabel);
				labelUI.type = TextFieldType.DYNAMIC;
			}
			else
			{
				labelUI.removeEventListener(MouseEvent.DOUBLE_CLICK, doubleClickEvent);
				labelUI.addEventListener(FocusEvent.FOCUS_OUT, applyLabel);
				labelUI.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, applyLabel);
				labelUI.type = TextFieldType.INPUT;
				labelUI.setSelection(0, labelUI.length);
			}
		}
		
		private function applyLabel (e:Event=null):void
		{
			try {   e.stopImmediatePropagation();   } catch(e:Error){ }
			data.name = label;
			_toggleLabelEdit();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		
		// PUBLIC ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// DEBUG ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////


	}
	
	
}