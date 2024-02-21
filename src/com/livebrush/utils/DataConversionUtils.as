package com.livebrush.utils
{

	
	public class DataConversionUtils
	{

		public function DataConversionUtils ():void
		{
			
		}
		
		private static function toNumber (value:Object):Number
		{
			return Number(value);
		}
		
		private static function toFraction (value:Object, div:Number=100):Number
		{
			return (toNumber(value)/div);
		}
		
		private static function minMax (value:Object, min:Number=1, max:Number=NaN):Number
		{
			value = toNumber(value);
			value = Math.max(min, toNumber(value));
			if (!isNaN(max)) value = Math.min(max, toNumber(value));
			return toNumber(value);
		}
		
		private static function speed (value:Object):Number
		{
			return toFraction(minMax(toNumber(value)));
		}
		
		private static function time (value:Object):Number
		{
			return (toNumber(value)*1000);
		}
		
		/*private static function registerTextInput (textInput:TextInput, changeHandler:Function, notifyPanel:Boolean=true, restrict:String="0123456789", maxChars:int=3):void
		{
			textInput.restrict = restrict;
			textInput.addEventListener (Event.CHANGE, changeHandler);
			textInput.maxChars = maxChars;
			if (notifyPanel) textInput.addEventListener (Event.CHANGE, panelChangeListener);
		}
		
		private static function registerMinMaxInput (name:String, changeHandler:Function, notifyPanel:Boolean=true, restrict:String="0123456789", maxChars:int=3):void
		{
			registerTextInput(this["min"+name], changeHandler, true, restrict, maxChars);
			registerTextInput(this["max"+name], changeHandler, true, restrict, maxChars);
		}
		
		private static function registerControlType (comboBox:ComboBox, dataSet:Array, changeHandler:Function, notifyPanel:Boolean=true, rowCount:int=10):void
		{
			comboBox.dataProvider = new DataProvider (dataSet);
			comboBox.rowCount = rowCount;
			comboBox.addEventListener (Event.CHANGE, changeHandler);
			if (notifyPanel) comboBox.addEventListener (Event.CHANGE, panelChangeListener);
		}*/
	}
	
	
}