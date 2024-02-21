package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.display.NativeWindowDisplayState;
	import flash.geom.ColorTransform;
	
	import org.casalib.util.ColorUtil;
	
	import com.livebrush.utils.Update;
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.ToolbarAsset;
	import com.livebrush.ui.ToolbarController;
	import com.livebrush.tools.BrushTool;
	import com.livebrush.tools.ColorLayerTool;
	import com.livebrush.tools.SampleTool;
	import com.livebrush.tools.TransformTool;
	import com.livebrush.tools.PenTool;
	import com.livebrush.tools.HelpTool;
	import com.livebrush.tools.HandTool;
	import com.livebrush.ui.Tooltip;
	
	
	public class ToolbarView extends UIView
	{
		
		public var uiAsset							:ToolbarAsset;
		public var toolbarAsset						:ToolbarAsset;
		public var toolBtns							:Array;
		private var _color							:uint;
		private var _colorHexValue					:String;
		private var _cf								:ColorTransform;
		
		public function ToolbarView (ui:UI):void
		{
			super(ui);
			helpID = "tools";
			init();
		}
		
		
		public function get panelAsset ():Sprite {   return toolbarAsset;   }
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function init ():void {}*/
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			uiAsset = toolbarAsset = new ToolbarAsset();
			toolbarAsset.cacheAsBitmap = true;
			
			UI.UI_HOLDER.addChild(toolbarAsset);
			
			toolbarAsset.y = 32;
			
			toolBtns = [toolbarAsset.brushBtn, toolbarAsset.penBtn, toolbarAsset.transformBtn, toolbarAsset.fillBtn, toolbarAsset.sampleBtn, toolbarAsset.handBtn];
			toolBtns[0].toolName = BrushTool.NAME;
			toolBtns[1].toolName = PenTool.NAME;
			toolBtns[2].toolName = TransformTool.NAME;
			toolBtns[3].toolName = ColorLayerTool.NAME;
			toolBtns[4].toolName = SampleTool.NAME;
			toolBtns[5].toolName = HandTool.NAME;
			
			toolbarAsset._colorBg.useHandCursor = true;
			
			_cf = new ColorTransform();
			
			uiAsset.zoomValue.text = String(Math.ceil(uiAsset.canvasZoom.value * 100)); 
			
			/*for (var i:int=0; i<toolBtns.length;i++) {
				Tooltip.addTip( toolBtns[i], toolBtns[i].toolName );
			}*/
		}
		
		protected override function createController ():void
		{
			controller = new ToolbarController(this);
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function update (update:Update=null):void
		{
			if (update.type == UpdateEvent.WINDOW)
			{
				toolbarAsset.x = UI.WIDTH - toolbarAsset.width - .7;
				toolbarAsset.bg.height = UI.HEIGHT - 32 - .7;
			}
			else if (update.type == UpdateEvent.UI)
			{
				uiAsset.canvasZoom.value = ui.canvas.zoomAmount;
				uiAsset.zoomValue.text = String(Math.ceil(uiAsset.canvasZoom.value * 100)); 
			}
			else if (update.type == UpdateEvent.COLOR) 
			{
				// Consol.Trace("ToolbarView: updateColor: " + update.data.color);
				_setColor(update.data.color);
			}
		}
		
		private function _setColor (u:uint):void
		{
			var c:Object = ColorUtil.getRGB(u);
			_colorHexValue = ColorUtil.getHexStringFromRGB(c.r, c.g, c.b);
			_cf.color = u;
			toolbarAsset._colorBg.transform.colorTransform = _cf;
			_color = u;
		}
		
		public function resetToolBtns ():void
		{
			for (var i:int=0; i<toolBtns.length; i++)
			{
				toolBtns[i].gotoAndStop(1);
				//toolBtns[i].enabled = 
				//toolBtns[i].mouseChildren = true;
			}
		}
		
		public function toggleTool(name:String):void
		{
			var toolBtn:MovieClip = toolbarAsset[name];
			//// // Consol.Trace(toolBtn);
			resetToolBtns();
			toolBtn.gotoAndStop(2);
			//toolBtn.enabled = 
			//toolBtn.mouseChildren = false;
		}
		
		public function toggleToolName(name:String):void
		{
			/*var toolBtn:MovieClip = getBtnByToolName(name);
			resetToolBtns();
			toolBtn.gotoAndStop(2);*/
			
			toggleTool(getBtnByToolName(name).name);
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function getBtnByToolName (toolName:String):MovieClip
		{
			var toolBtn:MovieClip;
			for (var i:int=0; i<toolBtns.length; i++)
			{
				if (toolBtns[i].toolName == toolName) toolBtn = toolBtns[i];
			}
			return toolBtn;
		}
		
		
	}
	
	
}