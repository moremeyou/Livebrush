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
	import fl.controls.List;
	
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
	import com.livebrush.ui.LayersView;
	
	public class BrushBehaveView extends UIView
	{
		
		public var uiAsset							:BrushBehaveUI;
		public var brushPropsModel					:BrushPropsModel;
		
		
		public function BrushBehaveView (brushPropsModel:BrushPropsModel):void
		{
			super(brushPropsModel.ui);
			
			this.brushPropsModel = brushPropsModel;
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get list ():List {   return uiAsset.styleList;   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function init ():void {}*/
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			
			// STYLE LIST SETUP
			uiAsset = new BrushBehaveUI();
			//uiAsset.styleList.allowMultipleSelection = true;
			//uiAsset.styleList.labelField = "name";
			//uiAsset.styleList.iconFunction = function(){return null}; //"name";
			
			uiAsset.styleListHead.label.text = "Styles".toUpperCase();
			uiAsset.newStyleHead.label.text = "New Style".toUpperCase();
			
		}
		
		protected override function createController ():void
		{
			controller = new BrushBehaveController(this);
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function update (update:Update=null):void
		{
			/*if (update.type == UpdateEvent.WINDOW || update.type == UpdateEvent.UI)
			{
				//uiAsset.contentHolder.height = ui.toolPropsView.panelAsset.height - 97;
				//try {   uiAsset.contentHolder.drawNow();   } catch (e:Error) {   }
			}
			else if (update.type == UpdateEvent.DATA)
			{
				pushProps(Settings(update.data));
			}*/
		}
	
		private function pushProps (data:Settings):void
		{
			/*uiAsset.styleList.dataProvider = new DataProvider();
			
			for (var i:int=0; i<data.styles.length; i++) 
			{
				var style:Object = data.styles[i];
				uiAsset.styleList.dataProvider.addItem (style);
			}
			
			uiAsset.styleList.selectedItems = data.styleGroup;*/
		}
		
		
	}
	
	
}