package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.display.NativeWindowDisplayState;
	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;
	import fl.data.DataProvider;
	
	import com.livebrush.utils.Update;
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.data.Settings;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.SavedStylesUI;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.BrushToolPropsUI;
	import com.livebrush.ui.LayersView;
	
	public class BucketPropsView extends UIView
	{
		public var uiAsset							:BucketPropsUI;
		
		public function BucketPropsView (ui:UI):void
		{
			super(ui);
			
			helpID = "bucketTool";
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function init ():void {}*/
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			uiAsset = new BucketPropsUI();
			uiAsset.cacheAsBitmap = true;
			
			uiAsset.colorHead.label.text = "Color".toUpperCase();
			uiAsset.alphaInput.label = "Opacity".toUpperCase();
			uiAsset.alphaInput.value = 100;
		}
		
		protected override function createController ():void
		{
			controller = new BucketPropsController(this);
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function update (update:Update=null):void
		{
			if (update.type == UpdateEvent.COLOR)
			{
				settings = Settings(update.data);
			}
		}
	
		public override function set settings (data:Settings):void
		{
			
			uiAsset.colorInput.color = data.color;
			
		}
		
		public override function get settings ():Settings
		{
			var settings:Settings = new Settings();
			
			settings.color = uiAsset.colorInput.color;
			settings.alpha = Number(uiAsset.alphaInput.value) / 100;
			//settings.hexValue = uiAsset.color.hexValue;
			
			return settings;
		}

		
		
	}
	
	
}