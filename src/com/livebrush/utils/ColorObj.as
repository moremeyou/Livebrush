package com.livebrush.utils
{
	import flash.geom.ColorTransform;
	import flash.display.DisplayObject;
	
	import org.casalib.util.ColorUtil;
	import org.casalib.math.Percent;
	import com.livebrush.ui.Consol;
	
	//public dynamic class ColorObj
	public dynamic class ColorObj
	{
		
		private var _colorString						:String = "FFFFFF";
		private var _color								:uint = 0xFFFFFF;
		public var enabled								:Boolean = true;
		
		public function ColorObj (o:Object, enabled:Boolean=true):void
		{
			//// // // Consol.Trace(typeof o);
			if (o is String) colorString = String(o);
			else if (o is uint) color = uint(o);
			
			this.enabled = enabled;
			
			//setPropertyIsEnumerable 
		}
		
		public function set color (u:uint):void {    _color = u; _setString(u);   } //// // // Consol.Trace("set color uint: " + u);
		public function get color ():uint {   return _color;    }
		public function set colorString (s:String):void {    _colorString = s; _setColor(s);   }//// // // Consol.Trace("set color string: " + s);
		public function get colorString ():String {   return _colorString;   } // // // // Consol.Trace(_colorString); 
		public function get value ():uint {   return color;   }
		public function set value (u:uint):void {   color = u;   }
		
		private function _setString (u:uint):void
		{
			//// // // Consol.Trace("uint set. converting from uint: " + u);
			var rgb:Object = ColorUtil.getRGB(u);
			_colorString = ColorUtil.getHexStringFromRGB(rgb.r, rgb.g, rgb.b);

		}
		
		private function _setColor (s:String):void
		{
			//// // // Consol.Trace("string set. converting from string: " + s); 
			//str = (str.indexOf("0x") > -1 ? "" : "0x") + str;
			_color = uint("0x"+s);
		}
		
		public function copy ():ColorObj
		{
			return new ColorObj(_color, enabled);
		}
		

	}
	
}