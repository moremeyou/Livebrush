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
	//import com.livebrush.ui.TransformPropsController;
	//import com.livebrush.ui.TransformPropsModel;
	import com.livebrush.ui.LayersView;
	import com.livebrush.tools.TransformTool;
	
	
	public class TransformPropsView extends UIView
	{
		public var uiAsset							:TransformPropsUI;
		public var noColor							:Boolean;
		private var _contentType					:String;
		public var alphaChanged						:Boolean = false;
		public var colorChanged						:Boolean = false;
		
		public function TransformPropsView (ui:UI):void
		{
			super(ui);
			
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
			uiAsset = new TransformPropsUI();
			uiAsset.cacheAsBitmap = true;
			
			uiAsset.transformControlHead.label.text = "Control".toUpperCase();
			uiAsset.scaleHead.label.text = "Transform".toUpperCase();
			uiAsset.colorHead.label.text = "Color".toUpperCase();
			
			uiAsset.xInput.label = "Position".toUpperCase();
			uiAsset.scaleXInput.label = "Scale".toUpperCase();
			uiAsset.rotationInput.label = "Rotation".toUpperCase();
			
			//uiAsset.percentInput.label = "Amount".toUpperCase();
			uiAsset.alphaInput.label = "Opacity".toUpperCase();
		}
		
		protected override function createController ():void
		{
			controller = new TransformPropsController(this);
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function applyProps ():void
		{
			alphaChanged = colorChanged = false;
			
			uiAsset.alphaInput.enabled = uiAsset.colorInput.enabled = (_contentType == TransformTool.LINE_LAYER || _contentType == TransformTool.EDGE);
			uiAsset.rotationInput.enabled = uiAsset.scaleXInput.enabled = uiAsset.scaleYInput.enabled = (_contentType == TransformTool.LINE_LAYER || _contentType == TransformTool.BOX_LAYER || _contentType == TransformTool.GROUP);
			uiAsset.xInput.enabled = uiAsset.yInput.enabled = (_contentType != null && _contentType != TransformTool.NONE);
			//// // Consol.Trace(_contentType);
		}
		
		public override function update (update:Update=null):void
		{
			if (update.type == UpdateEvent.WINDOW || update.type == UpdateEvent.UI)
			{
			}
			else if (update.type == UpdateEvent.TRANSFORM)
			{
				settings = Settings(update.data);
			}
			else if (update.type == UpdateEvent.COLOR)
			{
				//pushColor(Settings(update.data));
			}
		}
	
		public override function set settings (data:Settings):void
		{
			uiAsset.scale.selected = data.scaleAllowed;
			uiAsset.constrain.selected = data.constrain;
			_contentType = data.contentType;
			
			if (data.contentType != null)
			{
				uiAsset.xInput.value = data.x;
				uiAsset.yInput.value = data.y;
			
				if (data.contentType == TransformTool.LINE_LAYER || data.contentType == TransformTool.BOX_LAYER || data.contentType == TransformTool.GROUP)
				{
					uiAsset.scaleXInput.value = data.scaleX * 100;
					uiAsset.scaleYInput.value = data.scaleY * 100;
				
					uiAsset.rotationInput.value = data.rotation;
				}
				
				if (data.contentType == TransformTool.LINE_LAYER || data.contentType == TransformTool.EDGE)
				{
					uiAsset.colorInput.value = data.color;
					uiAsset.alphaInput.value = data.alpha * 100;
				}
			}
			
			applyProps();
			
		}
		
		public override function get settings ():Settings
		{
			var settings:Settings = new Settings();
			
			settings.scaleAllowed = uiAsset.scale.selected;
			settings.constrain = uiAsset.constrain.selected;
			
			settings.x = uiAsset.xInput.value;
			settings.y = uiAsset.yInput.value;
			
			settings.scaleX = Number(uiAsset.scaleXInput.value) / 100;
			settings.scaleY = Number(uiAsset.scaleYInput.value) / 100;
			
			settings.rotation = uiAsset.rotationInput.value;
			//// // Consol.Trace(colorChanged);
			settings.color = (colorChanged ? uiAsset.colorInput.color : null);
			//settings.colorPercent = Number(uiAsset.percentInput.value)/100;
			settings.alpha = (alphaChanged ? uiAsset.alphaInput.value/100 : null);
			
			
			return settings;
		}
		
	}
	
	
}