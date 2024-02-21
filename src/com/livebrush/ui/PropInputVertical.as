package com.livebrush.ui
{
	
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import fl.controls.TextInput;
	import flash.text.TextField;
	
	import org.casalib.util.StringUtil;
	import org.casalib.util.NumberUtil;
	
	
	public class PropInputVertical extends Sprite
	{
		
		public static var upperCaseLabels			:Boolean = true;
		public var validRE							:RegExp;
		public var min								:Number = 0;
		public var max								:Number = 1000;
		private var _labelStr						:String = "";
		
		
		public function PropInputVertical ():void
		{
			super();
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function set value (n:Number):void {   _input.text=String(n);   }
		public function get value ():Number {   return isNaN(Number(_input.text))?min:NumberUtil.constrain(Number(_input.text), min, max);   }
		public function get label ():String {   return _label.text;   }
		public function set label (s:String):void {   _labelStr=s; _label.text=(upperCaseLabels?s.toUpperCase():s);   }
		public function set enabled (b:Boolean) {   _input.enabled = b;   }
		public function get enabled ():Boolean {   return _input.enabled;   }
		
		
		// SETUP ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			validRE = new RegExp("((([\\.]+(0*))$)|(([\\.]+[\\d]+0)$)|(-$))");
			
			_input.restrict = "-.0123456789";
			
			//value = 0;
			
			_input.addEventListener(Event.CHANGE, changeEvent);
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function changeEvent (e:Event):void
		{
			if (e.target == _input && !validInput(_input)) e.stopImmediatePropagation();
		}
		
		
		// PUBLIC ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function validInput (input:TextInput):Boolean
		{
			//// // Consol.Trace(!validRE.test(input.text));
			return !validRE.test(input.text);
		}
		
		
		// DEBUG ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////


	}
	
	
}