package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.display.NativeWindowDisplayState;
	import fl.controls.Button;
	import flash.geom.ColorTransform;

	import com.livebrush.utils.Update;
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.TitlebarAsset;
	import com.livebrush.ui.TitlebarController;
	import com.livebrush.data.GlobalSettings;
	
	import org.casalib.util.ColorUtil;
	import org.casalib.math.Percent;
	
	
	public class TitlebarView extends UIView
	{
		
		public var uiAsset						:TitlebarAsset;
		public var brushPropsModel				:BrushPropsModel;
		public var applyBtn						:Button;
		public var statusColors					:Array = [ 0xC1C1C1, 0x65FF00, 0xFF3300 ]; // 33CC00
		private var emptyCTF					:ColorTransform;
		
		public function TitlebarView (ui:UI):void
		{
			super(ui);
			
			helpID = "main";
			brushPropsModel = ui.brushPropsModel;
			
			
			init();
		}
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function set style (s:String):void {   uiAsset.right._style.text = s;   }
		//public function get styleName ():String {   return uiAsset.styleName.text;   }
		public function set status (s:String):void {   uiAsset._status.text = s; setStatusColor(s);   }
		public function set project (s:String):void {   uiAsset._project.text = s;   }
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			uiAsset = new TitlebarAsset();
			uiAsset.cacheAsBitmap = true;
			
			applyBtn = uiAsset["applyBtn"];
			toggleApplyBtn();
			
			uiAsset.strokeBuffer.label = "Buffer";
			uiAsset.strokeBuffer.min = 1;
			uiAsset.strokeBuffer.max = 99;
			
			//uiAsset.zoomValue.text = String(Math.ceil(uiAsset.canvasZoom.value * 100)); 
			
			UI.UI_HOLDER.addChild(uiAsset);
			
			emptyCTF = new ColorTransform();
		}
		
		protected override function createController ():void
		{
			controller = new TitlebarController(this);
		}

		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function setStatusColor (s:String="Ready"):void {
			
			/*var c:Object = ColorUtil.getRGB(u);
			_colorHexValue = ColorUtil.getHexStringFromRGB(c.r, c.g, c.b);
			_cf.color = u;
			_colorBg.transform.colorTransform = _cf;
			_color = u;*/
			
			if (s == "Ready") {
				emptyCTF.color = statusColors[0];
			} else if (s == "Drawing") {
				emptyCTF.color = statusColors[1];
			} else if (s == "Busy" || s.indexOf("Saving") > -1) {
				emptyCTF.color = statusColors[2];
			} else {
				emptyCTF.color = statusColors[0];
			}
			
			uiAsset.statusBg.transform.colorTransform = ColorUtil.interpolateColor(new ColorTransform(), emptyCTF, new Percent(.5));
			
		}
		
		
		public override function update (update:Update=null):void
		{
			if (update.type == UpdateEvent.WINDOW)
			{
				uiAsset.bg.width = UI.WIDTH - .7;
				uiAsset.right.x = UI.WIDTH - uiAsset.right.width;
				
			}
			/*else if (update.type == UpdateEvent.UI)
			{
				uiAsset.canvasZoom.value = ui.canvas.zoomAmount;
				uiAsset.zoomValue.text = String(Math.ceil(uiAsset.canvasZoom.value * 100)); 
			}*/
			else if (update.type == UpdateEvent.BRUSH_STYLE)
			{
				//// // Consol.Trace("Titlebar got style update");
				var length:int = update.data.styleGroup.length;
				if (length > 1) style = (length + " Styles Selected").toUpperCase();
				else style = update.data.styleGroup[0].name; //.toUpperCase();
			}
			else if (update.type == UpdateEvent.PROJECT)
			{
				project = update.data.project;
			}
			else if (update.type == UpdateEvent.DRAW_MODE)
			{
				//// Consol.Trace("TitlebarView: update > DRAW_MODE : " + update.data.mode);
				_toggleDrawMode(update.data.mode);
			}
		}
		
		public function toggleApplyBtn ():void
		{
			//applyBtn.visible = !applyBtn.visible;
			//applyBtn.enabled = applyBtn.enabled;
		}
		
		private function _toggleDrawMode (mode:int):void {
		
			//// Consol.Trace("TitlebarView: _toggleDrawMode : " + mode);
			if (mode == 0) {
				uiAsset.strokeBuffer.visible = false;
				uiAsset.drawVectorsBtn.gotoAndStop(2);
				uiAsset.drawPixelsBtn.gotoAndStop(1);
				uiAsset.drawVectorsBtn.mouseEnabled = uiAsset.drawVectorsBtn.enabled = uiAsset.drawVectorsBtn.mouseChildren = false;
				uiAsset.drawPixelsBtn.mouseEnabled = uiAsset.drawPixelsBtn.enabled = uiAsset.drawPixelsBtn.mouseChildren = true;
			}
			else if (mode == 1) {
				uiAsset.strokeBuffer.visible = true;
				uiAsset.drawVectorsBtn.gotoAndStop(1);
				uiAsset.drawPixelsBtn.gotoAndStop(2);
				uiAsset.drawVectorsBtn.mouseEnabled = uiAsset.drawVectorsBtn.enabled = uiAsset.drawVectorsBtn.mouseChildren = true;
				uiAsset.drawPixelsBtn.mouseEnabled = uiAsset.drawPixelsBtn.enabled = uiAsset.drawPixelsBtn.mouseChildren = false;
			}
			
			uiAsset.strokeBuffer.value = GlobalSettings.STROKE_BUFFER;
		
		}
		
		
	}
	
	
}