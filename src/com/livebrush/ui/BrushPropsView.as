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
	import com.livebrush.ui.BrushPropsController;
	import com.livebrush.ui.BrushPropsModel;
	import com.livebrush.ui.LayersView;
	
	public class BrushPropsView extends UIView
	{
		public var uiAsset							:BrushToolPropsUI;
		public var tabs								:Array;
		public var brushPropsModel					:BrushPropsModel;
		
		public function BrushPropsView (brushPropsModel:BrushPropsModel):void
		{
			super(brushPropsModel.ui);
			
			helpID = "brushTool";
			this.brushPropsModel = brushPropsModel;
			
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
			uiAsset = new BrushToolPropsUI();
			uiAsset.cacheAsBitmap = true;
			
			tabs = [uiAsset.tab0, uiAsset.tab1, uiAsset.tab2]; // uiAsset.tab0, 
			//uiAsset.swapChildrenAt(0, uiAsset.getChildIndex(uiAsset.tab0));
			uiAsset.swapChildrenAt(0, uiAsset.getChildIndex(uiAsset.tab0));
			uiAsset.swapChildrenAt(1, uiAsset.getChildIndex(uiAsset.tab1));
			uiAsset.swapChildrenAt(2, uiAsset.getChildIndex(uiAsset.tab2));

			uiAsset.contentHolder.horizontalScrollPolicy = ScrollPolicy.OFF;
			uiAsset.contentHolder.verticalScrollPolicy = ScrollPolicy.ON;

		}
		
		protected override function createController ():void
		{
			controller = new BrushPropsController(this);
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function update (update:Update=null):void
		{
			if (update.type == UpdateEvent.WINDOW || update.type == UpdateEvent.UI)
			{
				try 
				{   
					uiAsset.contentHolder.height = ui.toolPropsView.panelAsset.height - 52; //- 57; //97;
					uiAsset.contentHolder.drawNow();   
				} catch (e:Error) {   }
				
				try {   
					toggleTab(brushPropsModel.currentGroup);
					uiAsset.contentHolder.source = brushPropsModel.propGroups[brushPropsModel.currentGroup].uiAsset;
				} catch (e:Error) {   }
			}
			// else if (update.type == UpdateEvent.DATA)
			else if (update.type == UpdateEvent.BRUSH_STYLE)
			{
				pushProps(Settings(update.data));
			}
		}
	
		private function pushProps (data:Settings):void
		{
			//if (data.styleGroup.length > 1) uiAsset.styleName.text = "Multiple Styles Selected".toUpperCase();
			//else uiAsset.styleName.text = data.styleGroup[0].name; //.toUpperCase();
		}
	
		private function toggleTab (index:int):void
		{
			/*for (var i:int=0; i<4; i++)
			{
				uiAsset.addChildAt(tabs[i], 3-i);
			}
			uiAsset.addChildAt(tabs[index], 3);*/
			for (var i:int=0; i<3; i++)
			{
				uiAsset.addChildAt(tabs[i], 2-i);
			}
			uiAsset.addChildAt(tabs[index], 2);
		}
		
		
	}
	
	
}