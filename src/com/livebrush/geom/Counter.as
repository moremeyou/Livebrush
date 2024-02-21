package com.livebrush.geom
{

	import com.livebrush.ui.Consol;
	
	public class Counter
	{
		
		public var value						:Number;
		public var speed						:Number;
		public var start						:Number;
		public var end							:Number;
		private var iSpeed						:Number;
		private var iStart						:Number;
		private var iEnd						:Number;
		
		private var loop						:Boolean;
		private var back						:Boolean;
		
		private var firstCount					:Boolean = true;
		
		public function Counter (start:Number, end:Number, speed:Number, loop:Boolean=true, back:Boolean=true)
		{
			
			this.loop = loop;
			this.back = back;
			
			setCounter(start, end, speed);
			
			
		}
		
		public function update ():Number
		{
			value += speed;
			
			
			/*if (((value > end && speed==Math.abs(speed)) || (value > end && speed!=Math.abs(speed))) && loop) 
			{
				if (back) 
				{
					value--;
					speed *= -1;
					value += speed;
				}
				else
				{
					value = start;
				}
			}*/
			
			if (value > end) value = start;
			
			return value;
		}
		
		public function count (firstCheck:Boolean=true):Number
		{
			if (firstCount && firstCheck) firstCount = false;
			else update();
			
			return value;
			
		}
		
		public function get floorValue ():Number
		{
			return Math.floor(value);
		}
		
		public function reset ():void
		{
			start = iStart;
			end = iEnd;
			speed = iSpeed;
			value = start;
			firstCount = true;
		}
		
		public function setCounter (start:Number, end:Number, speed:Number):void
		{
			this.start = iStart = start;
			this.end = iEnd = end;
			this.speed = iSpeed = speed;
			value = start;
		}
		
	}
}