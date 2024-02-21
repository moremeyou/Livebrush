package com.livebrush.geom
{

	import flash.geom.Point;
	
	import com.livebrush.ui.Consol;
	
	public class Osc
	{
		
		public var value						:Point;
		public var center						:Point;
		public var range						:Point;
		public var speed						:Number;
		
		public var angle						:Number;
		private var iCenter						:Point;
		private var iRange						:Point;
		private var iSpeed						:Number;
		
		public function Osc (x:Number, y:Number, rangeX:Number, rangeY:Number, speed:Number)
		{
			setOsc(x, y, rangeX, rangeY, speed);
		}
		
		public function get angleDegrees ():Number {   return angle * 180 / Math.PI;   }
		
		public function update ():Point
		{
			value.x = center.x + Math.cos(angle) * range.x;
			value.y = center.y + Math.sin(angle) * range.y;
			angle += speed;
			
			//Consol.globalOutput(center.x);
			
			return value;
		}
		
		
		public function reset ():void
		{
			center = iCenter;
			range = iRange;
			speed = iSpeed;
			angle = 0;
			value = center.clone();
		}
		
		public function setOsc (x:Number, y:Number, rangeX:Number, rangeY:Number, speed:Number):void
		{
			center = iCenter = new Point (x, y);
			range = iRange = new Point (rangeX, rangeY);
			this.speed = iSpeed = speed;
			angle = 0;
			value = center.clone();
		}
		
	}
}