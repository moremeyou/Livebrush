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
	//import com.livebrush.ui.BrushToolPropsUI;
	//import com.livebrush.ui.PenPropsController;
	import com.livebrush.ui.BrushPropsModel;
	import com.livebrush.ui.LayersView;
	
	public class EmptyPropsView extends UIView
	{
		public var uiAsset							:Sprite;
		
		public function EmptyPropsView (ui:UI):void
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
			uiAsset = new Sprite();
			uiAsset.cacheAsBitmap = true;
			
		}
		
		protected override function createController ():void
		{
			//controller = new PenPropsController(this);
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function update (update:Update=null):void
		{
			/*if (update.type == UpdateEvent.WINDOW || update.type == UpdateEvent.UI)
			{
				try 
				{   
					uiAsset.contentHolder.height = ui.toolPropsView.panelAsset.height - 97;
					uiAsset.contentHolder.drawNow();   
				} catch (e:Error) {   }
				
				try {   
					toggleTab(brushPropsModel.currentGroup);
					uiAsset.contentHolder.source = brushPropsModel.propGroups[brushPropsModel.currentGroup].uiAsset;
				} catch (e:Error) {   }
			}
			else if (update.type == UpdateEvent.DATA)
			{
				pushProps(Settings(update.data));
			}*/
		}
	
		/*private function pushProps (data:Settings):void
		{
			if (data.styleGroup.length > 1) uiAsset.styleName.text = "Multiple Styles Selected".toUpperCase();
			else uiAsset.styleName.text = data.styleGroup[0].name; //.toUpperCase();
		}*/
		
		
	}
	
	
}