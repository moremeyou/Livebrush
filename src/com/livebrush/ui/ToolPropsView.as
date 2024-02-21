package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.display.NativeWindowDisplayState;
	
	import com.livebrush.utils.Update;
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.PanelAsset;
	import com.livebrush.ui.ToolPropsController;
	import com.livebrush.ui.LayersView;
	
	public class ToolPropsView extends UIView
	{
		
		public static var IDEAL_HEIGHT				:int = 508;
		
		public var panelAsset						:PanelAsset;
		public var content							:Sprite;
		public var panel							:Sprite;
		//public var height							:Number;
		public var state							:int = UI.OPEN;
		private var titlebarMask					:PanelTitlebarMask;
		
		
		public function ToolPropsView (ui:UI):void
		{
			super(ui);
			helpID = "toolProps";
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function set visible (b:Boolean):void {   panel.visible=b;   }
		public function get maxY ():Number {   return (panelAsset.height+panel.y);   }
		//private function get _height ():Number {   return (UI.HEIGHT - 32) - ui.layersView.height - 1;   }
		private function get _height ():Number {   return (UI.HEIGHT - 32) - ui.layersView.height - ui.styleListView.height - 1;   }
		public function get width ():Number {   return panelAsset.bg.width;   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function init ():void {}*/
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			panel = new Sprite();
			content = new Sprite();
			titlebarMask = new PanelTitlebarMask();
			titlebarMask.visible = false;
			
			panelAsset = new PanelAsset();
			panelAsset.cacheAsBitmap = true;
			
			panel.addChild(panelAsset);
			panel.addChild(content);
			panel.addChild(titlebarMask);
			
			//UI.UI_HOLDER.addChild(panelAsset);
			UI.UI_HOLDER.addChild(panel);
			
			panelAsset.title.htmlText = "<b>Tool Settings</b>";
			
			panel.y = 32;
			panelAsset.bg.height = IDEAL_HEIGHT;
			
			content.y = 30;
		}
		
		protected override function createController ():void
		{
			controller = new ToolPropsController(this);
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function update (update:Update=null):void
		{
			if (update.type == UpdateEvent.WINDOW || update.type == UpdateEvent.UI)
			{
				panel.x = UI.WIDTH - panelAsset.width - 42 - 6; // 6 = padding between toolbar
				panel.y = ui.styleListView.maxY;
				if (state != UI.CLOSED) panelAsset.bg.height = _height;
			}
			else if (update.type == UpdateEvent.UI)
			{
				//if (content != null) content.resize();
			}
		}
	
		public function toggle (force:Boolean=false):void
		{
			state = ((state==UI.CLOSED || force) ? UI.OPEN : UI.CLOSED);
			if (state == UI.CLOSED) 
			{
				panelAsset.bg.height = 22;
				content.mask = titlebarMask;
			}
			else 
			{
				panelAsset.bg.height = _height; //(UI.HEIGHT - 32) - ui.layersView.height - 1;
				content.mask = null;
			}
		}
		
		public function setContent (propsContent:Sprite):void
		{
			try {   content.removeChildAt(0);   } catch (e:Error) {   }
			content.addChild(propsContent);
		}
		
		
	}
	
	
}