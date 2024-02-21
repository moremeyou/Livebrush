package com.livebrush.ui
{
	import flash.display.Sprite;
	
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.data.Settings;
	import com.livebrush.tools.ToolManager;
	import com.livebrush.tools.Tool;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.Consol;
	import com.livebrush.utils.View;
	import com.livebrush.utils.Model;
	import com.livebrush.utils.Controller;
	import com.livebrush.utils.Update;
	
	public class UIView extends View
	{
		
		public var lastSettings								:Settings;
		public var helpID									:String = "";
		
		public function UIView (uiModel:UIModel):void
		{
			super(uiModel);
		}
		
		public function get ui ():UI {   return UI(model);   }
		public function get toolManager ():ToolManager {   return ui.toolManager;   }
		public function get activeTool ():Tool {   return toolManager.activeTool;   }
		public function get activeLayer ():Layer {   return UIController(controller).activeLayer;   }
		public function get settings ():Settings {   return new Settings();   }
		public function set settings (data:Settings):void {   }
		//public function get panelSprite ():Sprite {   var asset:Sprite=(this["panelAsset"]==null || this["panelAsset"]==undefined)?this["uiAsset"]:this["panelAsset"]; return asset;   }
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		public function typeInputIsAutomatic (s:String):Boolean
		{
			return UIController.typeInputIsAutomatic(s);
		}
		
		public function toNumber (value:Object):Number
		{
			return UIController.toNumber(value);
		}
		
		public function toFraction (value:Object, div:Number=100):Number
		{
			return UIController.toFraction(value, div);
		}
		
		public function minMax (value:Object, min:Number=1, max:Number=NaN):Number
		{
			return UIController.minMax(value, min, max);
		}
		
		public function speed (value:Object):Number
		{
			return UIController.speed(value);
		}
		
		public function time (value:Object):Number
		{
			return UIController.time(value);
		}
		
		public function toObjList (l):Array
		{
			return UIController.toObjList(l);
		}
		
		public function toDataList (l):Array
		{
			return UIController.toDataList(l);
		}
		
	}
	
}