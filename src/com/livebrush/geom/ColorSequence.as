package com.livebrush.geom
{
	import fl.motion.Color;
	import com.livebrush.ui.Consol;
	
	public class ColorSequence
	{
		
		public var colorList					:Array;
		public var steps						:int;
		private var index						:int;
		private var fraction					:Number; 
		private var fStep						:Number; 
		
		private var loop						:Boolean;
		private var back						:Boolean;
		
		public function ColorSequence (list:Array, steps:int, loop:Boolean=true, back:Boolean=true)
		{
			this.loop = loop;
			this.back = back;
			
			startSequence(list, steps);
		}
		
		public function nextColor ():uint
		{
			var color1:uint = colorList[index];
			var color2:uint = colorList[index+1];
			
			var tweenColor:uint = Color.interpolateColor(color1, color2, fraction);
			
			//fraction = (fraction + fStep) % 1;
			
			fraction += fStep;
			
			if (fraction > 1)
			{
				if (index == colorList.length-2) index=0;
				else index++;
				fraction = 0;
			}
	
			return tweenColor;
		}
		
		public function reset ():void
		{
			startSequence(colorList, steps);
		}
		
		public function interpolate (index1:int, index2:int, f:Number):uint
		{
			return Color.interpolateColor(colorList[index1], colorList[index2], f);
		}
		
		public function randomColor ():uint
		{
			var rand:int = Math.floor(Math.random()*colorList.length);
			return colorList[rand];
		}
		
		public function startSequence (list:Array, steps:int):void
		{
			colorList = list;
			this.steps = steps;
			index = 0;
			fraction = 0;
			fStep = 1 / steps;
		}
		
	}
}