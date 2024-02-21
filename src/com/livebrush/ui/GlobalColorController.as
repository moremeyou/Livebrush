package com.livebrush.ui
{
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.display.Sprite;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.UIUpdate;
	import com.livebrush.events.ListEvent;
	import com.livebrush.utils.ColorObj;
	import com.livebrush.data.Settings;
	
	public class GlobalColorController extends UIController
	{
		
		public function GlobalColorController (globalColorView:GlobalColorView):void
		{
			super(globalColorView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get globalColorView ():GlobalColorView {   return GlobalColorView(view);  }
		private function get uiAsset ():Object {   return globalColorView.uiAsset;  }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			//globalColorView.colorInputs.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.addEventListener(MouseEvent.MOUSE_DOWN, mouseEvent);
			uiAsset.addEventListener(MouseEvent.MOUSE_UP, mouseEvent);
			uiAsset.addEventListener(MouseEvent.CLICK, mouseEvent);
			globalColorView.colorInputs.typeInput.addEventListener(Event.CHANGE, propsChangeEvent);
			globalColorView.colorInputs.addEventListener(ListEvent.ADD, addColor);
			globalColorView.colorInputs.addEventListener(ListEvent.REMOVE, removeColor);
			globalColorView.colorInputs.addEventListener(Event.CHANGE, propsChangeEvent);
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function propsChangeEvent (e:Event):void
		{
			//try { // // Consol.Trace(e.target.name); } catch(e:Error){}
			
			// Consol.Trace("GlobalColorController: propsChangeEvent");
			
			e.stopImmediatePropagation();
			
			globalColorView.settings = globalColorView.settings; //.applyProps();
			
			ui.pushColorProps(globalColorView.settings);
			
		}
		
		private function addColor (e:ListEvent):void
		{
			try {   globalColorView.colorInputs.addItemAt(globalColorView.colorInputs.list[globalColorView.colorInputs.selectedIndex].copy(), globalColorView.colorInputs.selectedIndex);   }
			catch (e:Error) {   globalColorView.colorInputs.addItemAt(globalColorView.colorInputs.list[0].copy(), 0);   }
			catch (e:Error) {   globalColorView.colorInputs.addItemAt(new ColorObj(0xFF0000, true), 0);   }
			finally {      }
			
			ui.pushColorProps(globalColorView.settings);
		}
		
		private function removeColor (e:ListEvent):void
		{
			try {   globalColorView.colorInputs.removeItemsAt(globalColorView.colorInputs.selectedIndex, 1);   }
			catch (e:Error) {   globalColorView.colorInputs.removeItemsAt(0, 1);   }
			finally {      }
			
			ui.pushColorProps(globalColorView.settings);
		}
		
		private function mouseEvent (e:MouseEvent):void
		{
			if (e.type == MouseEvent.MOUSE_DOWN) {
			
				if (e.target.name == "bg") uiAsset.startDrag();
				
			} else if (e.type == MouseEvent.MOUSE_UP) {
			
				uiAsset.stopDrag();
				
			} else if (e.type == MouseEvent.CLICK) {
				var settings:Settings;
				
				if (e.target.name == "pullStyleBtn") {
					
					settings = ui.styleManager.activeStyle.strokeStyle.settings;
					settings.alpha = globalColorView.settings.alpha;
					globalColorView.settings = settings;
					
					globalColorView.applyProps();
					
					ui.pushColorProps(settings);
				
				} else if (e.target.name == "pushColorBtn") {
					
					var styleSettings:Settings = ui.styleManager.activeStyle.strokeStyle.settings;
					settings = globalColorView.settings;
					
					styleSettings.colorType = settings.colorType;
					styleSettings.colorObjList = settings.colorObjList;
					styleSettings.colorSteps = settings.colorSteps;
					styleSettings.colorHold = settings.colorHold;
					
					ui.styleManager.activeStyle.strokeStyle.settings = styleSettings;
					ui.styleManager.pushStyle();
					
					ui.pushColorProps(settings);
				} else if (e.target.name == "helpBtn") {
					
					_loadHelp();
					
				} else if (e.target.name == "toggleBtn") {
					
					ui.toggleGlobalColor();
					
				}
			} 
				
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

		
		
		
	}
	
}