package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fl.events.SliderEvent; 
	/*import flash.display.Shape;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.EventPhase;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	import flash.geom.Point;
	import flash.geom.Rectangle;*/
	import fl.controls.TextInput;
	import flash.text.TextField;
	
	/*import com.livebrush.utils.Update;
	import com.livebrush.data.FileManager;
	import com.livebrush.data.Settings;
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
	
	import com.livebrush.ui.Consol;
	
	
	public class SliderInput extends Sprite
	{
		
		public static var upperCaseLabels			:Boolean = true;
		
		
		private var _value							:String = "";
		
		
		public function SliderInput ():void
		{
			super();
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		//public function get input ():Object {   return _input.text;   }
		public function set value (s:Object):void {   _setSlider(s);   }
		public function get value ():Object {   return _slider.value;   }
		//public function set input (s:Object):void {   _setInput();   }
		public function get label ():String {   return _label.text;   }
		public function set label (s:String):void {   _label.text=(upperCaseLabels?s.toUpperCase():s);   }
		public function set max (n:Number):void {   _slider.maximum = n;   }
		public function set min (n:Number):void {   _slider.minimum = n;   }
		public function get max ():Number {   return _slider.maximum;   }
		public function get min ():Number {   return _slider.minimum;   }
		public function set enabled (b:Boolean):void {   _setEnabled(b);   }
		public function get enabled ():Boolean {   return _slider.enabled;   }
		
		
		// SETUP ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			_slider.liveDragging = true;
			//_setSlider(50);
			_input.restrict = ".0123456789";
			_input.maxChars = 3;
			
			_slider.addEventListener(Event.CHANGE, sliderChange);
			_slider.addEventListener(SliderEvent.THUMB_RELEASE, sliderChanged);
			_input.addEventListener(Event.CHANGE, inputChange);
			//_input.addEventListener(MouseEvent.MOUSE_MOVE, sliderChange);
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function sliderChange (e:Event):void
		{
			_setInput();
			//dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function sliderChanged (e:SliderEvent):void
		{
			//// // Consol.Trace("slider changed");
			_setInput();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function inputChange (e:Event):void
		{
			value = Number(_input.text);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		//private quiteChange (e:MouseEvent)
		
		
		// PUBLIC ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function _setSlider (s:Object):void
		{
			_slider.value = Number(s);
			_setInput();
		}
		
		private function _setInput (s:Object=null):void
		{
			s = s==null ? _slider.value : s;
			_input.text = String(s).substr(0,5);
		}
	
		private function _setEnabled (b:Boolean):void
		{
			_slider.enabled = _input.enabled = b;
		}
		
		
		// DEBUG ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////


	}
	
	
}