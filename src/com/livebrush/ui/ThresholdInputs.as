package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import fl.controls.TextInput;
	import flash.text.TextField;
	
	import org.casalib.util.StringUtil;
	import org.casalib.util.NumberUtil;
	
	
	public class ThresholdInputs extends Sprite
	{
		
		public var validRE								:RegExp;
		public var minIn								:Number = 0;
		public var maxIn								:Number = 1000;
		
		public function ThresholdInputs ():void
		{
			super();
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function set active (b:Boolean):void {   _setActive(b);   }
		public function get active ():Boolean {   return _active.selected;   }
		public function set max (n:Number):void {   _max.text = String(n);   }
		public function set min (n:Number):void {   _min.text = String(n);   }
		public function get max ():Number {   return isNaN(Number(_max.text))?minIn:NumberUtil.constrain(Number(_max.text), minIn, maxIn);   }
		public function get min ():Number {   return isNaN(Number(_min.text))?minIn:NumberUtil.constrain(Number(_min.text), minIn, maxIn);   }
		public function set enabled (b:Boolean):void {   _max.enabled = _min.enabled = _active.enabled = b;   }
		public function get enabled ():Boolean {   return _active.enabled;   }
		
		
		// SETUP ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			validRE = new RegExp("((([\\.]+(0*))$)|(([\\.]+[\\d]+0)$)|(-$))");
			
			active = false;
			
			_min.restrict = _max.restrict = "-.0123456789";
			
			//_min.restrict = _max.restrict = "0123456789";
			//_min.maxChars = _max.maxChars = 3;
			
			//_active.
			addEventListener(Event.CHANGE, activeChange);
			
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function activeChange (e:Event):void
		{
			//// // Consol.Trace(invalidInput(_min));
			if (e.target == _active) _setActive(_active.selected);
			else if (e.target == _min && !validInput(_min)) e.stopImmediatePropagation();
			else if (e.target == _max && !validInput(_max)) e.stopImmediatePropagation();
		}
		
		
		// PUBLIC ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function toggleMin ():void
		{
			toggleInputs(true);
		}
		
		public function toggleMax ():void
		{
			toggleInputs(false);
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function _setActive (b:Boolean):void
		{
			_active.selected = b;
			_max.enabled = _min.enabled = _active.selected;
		}
		
		private function toggleInputs (s:Boolean):void
		{
			var input:TextInput = s ? _min : _max;
			input.visible = !input.visible;
			input.enabled = input.visible;
		}
		
		private function validInput (input:TextInput):Boolean
		{
			//// // Consol.Trace(!validRE.test(input.text));
			// try{// // Consol.Trace(re.exec(input.text)[0]);}catch(e:Error){}
			return !validRE.test(input.text);
			
			/*var text:String = input.text;
			//text = text.indexOf(".")>-1 ? text+"0" : text;
			//trace("valid input check");
			return ((text.lastIndexOf(".") == text.length-1 && text.lastIndexOf(".") != -1) || 
					(text.lastIndexOf(".0") == text.length-2 && text.lastIndexOf(".0") != -1) || 
					(text.lastIndexOf(".00") == text.length-3 && text.lastIndexOf(".00") != -1) || 
					text == "-");*/
		}
		
		
		
		// DEBUG ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////


	}
	
	
}