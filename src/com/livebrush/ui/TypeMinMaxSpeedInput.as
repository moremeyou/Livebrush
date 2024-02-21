package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import fl.controls.TextInput;
	import flash.text.TextField;
	import fl.controls.ComboBox;
	
	import com.livebrush.ui.PropInputVertical;
	
	
	
	public class TypeMinMaxSpeedInput extends Sprite
	{
		
		public var validRE								:RegExp;
		//private var input1Bak							:Number
		
		
		public function TypeMinMaxSpeedInput ():void
		{
			super();
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function set list (l:Array):void {   _typeInput.list = l;   }
		//public function get type ():String {   typeInput.selectedItem.data;   }
		public function set type (t:String):void {   _typeInput.value = t;   }
		public function get type ():String {   return String(_typeInput.value);   }
		public function set min (n:Number):void {   input0=n;   }
		public function get min ():Number {   return input0;   }
		public function set max (n:Number):void {   input1=n;;   }
		public function get max ():Number {   return input1;   }
		public function set speed (n:Number):void {   input2=n;;   }
		public function get speed ():Number {   return input2;   }
		public function set input0 (n:Number):void {   _input0.value=n;;   }
		public function get input0 ():Number {   return Number(_input0.value);   }
		public function set input1 (n:Number):void {   _input1.value=n;   }
		public function get input1 ():Number {   return Number(_input1.value);   }
		public function set input2 (n:Number):void {   _input2.value=n;;   }
		public function get input2 ():Number {   return Number(_input2.value);   }
		public function set label0 (s:String):void {   _typeInput.label=s;   }
		public function set label1 (s:String):void {   _input0.label=s;   }
		public function set label2 (s:String):void {   _input1.label=s;   }
		public function set label3 (s:String):void {   _input2.label=s;   }
		public function set minIn (n:Number):void {   _input0.min = _input1.min = n;   }
		public function set maxIn (n:Number):void {   _input0.max = _input1.max = n;   }
		public function set minSpeed (n:Number):void {   _input2.min = n;   }
		public function set maxSpeed (n:Number):void {   _input2.max = n;   }
		public function set speedEnabled (b:Boolean) {   _input2.enabled = b;   }
		public function get speedEnabled ():Boolean {   return _input2.enabled;   }
		public function set enabled (b:Boolean) {   _input0.enabled = _input1.enabled = _input2.enabled = _typeInput.enabled = b;   }
		public function get enabled ():Boolean {   return _typeInput.enabled;   }
		
		
		// SETUP ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			validRE = new RegExp("((([\\.]+(0*))$)|(([\\.]+[\\d]+0)$)|(-$))");
			
			_input0._input.restrict = _input1._input.restrict = _input2._input.restrict = "-.0123456789";
			//_input0._input.maxChars = _input1._input.maxChars = _input2._input.maxChars = 5;
			
			_typeInput.label = "Type";
			_input0.label = "Min";
			_input1.label = "Max";
			_input2.label = "Speed";
			
			
			_typeInput._list.addEventListener(Event.CHANGE, propsChange);
			//_input0.addEventListener(Event.CHANGE, propsChange);
			//_input1.addEventListener(Event.CHANGE, propsChange);
			//_input2.addEventListener(Event.CHANGE, propsChange);
			//this.addEventListener(Event.CHANGE, propsChange);
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function propsChange (e:Event):void
		{
			//if (e.target is ComboBox || e.target is TextInput)
			//{
				//e.stopImmediatePropagation();
				//// // Consol.Trace("TypeMinMaxSpeed props change");
				dispatchEvent(new Event(Event.CHANGE));
			//}
		}
		
		
		// PUBLIC ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function toggleInput (i:int, b:Boolean):void
		{
			var input:PropInputVertical = this["_input"+i];
			input.visible = b; //!input.visible;
			input._input.enabled = b; //input.visible;
		}
		
		public function addType (o:Object):void
		{
			_typeInput.addType(o);
		}
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function setMinMax (min:Number=0, max:Number=1000, minSpeed:Number=1, maxSpeed:Number=1000):void
		{
			minIn = min;
			maxIn = max;
			this.minSpeed = minSpeed;
			this.maxSpeed = maxSpeed;
		}
		
		
		// DEBUG ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////


	}
	
	
}