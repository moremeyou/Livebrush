package com.livebrush.transform
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Matrix;

	/**
	 * Extends MovieClip adding a dynamic registration point
	 *
	 * Based on AS2 work by Darron Schall (www.darronschall.com)
	 * Original AS1 code by Robert Penner (www.robertpenner.com)
	 *
	 * @author Oscar Trelles
	 * @version 1.0
	 * @created 12-Mar-2007 11:53:50 AM
	 */
	 
	 
	public class TransformSprite extends Sprite
	{
		private var _rp:Point;

		function TransformSprite()
		{
			setRegistration();
		}

		public function get x2():Number {   var p:Point = this.parent.globalToLocal(this.localToGlobal(_rp)); return p.x;   }
		public function set x2(value:Number):void {   var p:Point = this.parent.globalToLocal(this.localToGlobal(_rp)); this.x += value - p.x;   }
		public function get y2():Number {   var p:Point = this.parent.globalToLocal(this.localToGlobal(_rp)); return p.y;   }
		public function set y2(value:Number):void {   var p:Point = this.parent.globalToLocal(this.localToGlobal(_rp)); this.y += value - p.y;   }
		public function get scaleX2():Number {   return this.scaleX;   }
		public function set scaleX2(value:Number):void {   this.setProperty2("scaleX", value);   }
		public function get scaleY2():Number {   return this.scaleY;   }
		public function set scaleY2(value:Number):void {   this.setProperty2("scaleY", value);   }
		public function get rotation2():Number {   return this.rotation;   }
		public function set rotation2(value:Number):void {   this.setProperty2("rotation", value);   }
		public function get mouseX2():Number {   return Math.round(this.mouseX - _rp.x);   }
		public function get mouseY2():Number {   return Math.round(this.mouseY - _rp.y);   }
		
		/*public function skew (x:Number, y:Number):void 
		{
			var p:Point = this.parent.globalToLocal(this.localToGlobal(_rp));
			this.x += x - p.x;
			this.y += y - p.y;
		}*/
		
		public function set skewX (n:Number):void 
		{
			var a:Point = this.parent.globalToLocal(this.localToGlobal(_rp));
			
			var mat:Matrix = transform.matrix;
			mat.c = n;
			transform.matrix = mat;
			
			var b:Point = this.parent.globalToLocal(this.localToGlobal(_rp));
			
			this.x -= b.x - a.x;
		}
		
		public function translate (x:Number, y:Number):void 
		{
			var p:Point = this.parent.globalToLocal(this.localToGlobal(_rp));
			this.x += x - p.x;
			this.y += y - p.y;
		}
		
		public function scale (x:Number, y:Number):void 
		{
			var a:Point = this.parent.globalToLocal(this.localToGlobal(_rp));

			this.scaleX = x;
			this.scaleY = y;

			var b:Point = this.parent.globalToLocal(this.localToGlobal(_rp));

			this.x -= b.x - a.x;
			this.y -= b.y - a.y;
		}
		
		public function setRegistration(x:Number=0, y:Number=0):void
		{
			_rp = new Point(x, y);
		}
		
		public function setRegistrationPoint(pt:Point):void
		{
			_rp = pt;
		}
		
		public function setProperty2(prop:String, n:Number):void 
		{
			var a:Point = this.parent.globalToLocal(this.localToGlobal(_rp));

			this[prop] = n;

			var b:Point = this.parent.globalToLocal(this.localToGlobal(_rp));

			this.x -= b.x - a.x;
			this.y -= b.y - a.y;
		}
	}
}