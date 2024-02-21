package com.livebrush.utils
{
	import flash.geom.ColorTransform;
	import flash.display.DisplayObject;
	
	import org.casalib.util.ColorUtil;
	import org.casalib.math.Percent;
	
	
	public class ColorUtils
	{
		
		public function ColorUtils ():void
		{
		}
		
		public static function getNewColorTransform ():ColorTransform
		{
			return new ColorTransform();
		}
		
		public static function tintObject (displayObj:DisplayObject, color:uint, percent:Number=1):void
		{
			var toCTF:ColorTransform = getNewColorTransform();
			toCTF.color = color;
			displayObj.transform.colorTransform = ColorUtil.interpolateColor(getNewColorTransform(), toCTF, new Percent(percent));
		}
		
		public static function resetColor (displayObj:DisplayObject):void
		{
			displayObj.transform.colorTransform = getNewColorTransform();
		}
		
	}
	
}