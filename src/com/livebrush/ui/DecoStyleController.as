package com.livebrush.ui
{
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	
	import com.livebrush.data.FileManager;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.UIUpdate;
	import com.livebrush.events.ListEvent;
	import com.livebrush.utils.ColorObj;
	
	public class DecoStyleController extends UIController
	{
		
		public function DecoStyleController (decoStyleView:DecoStyleView):void
		{
			super(decoStyleView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get decoStyleView ():DecoStyleView {   return DecoStyleView(view);  }
		private function get brushPropsModel ():BrushPropsModel {   return decoStyleView.brushPropsModel;   }
		private function get uiAsset ():Object {   return decoStyleView.uiAsset;  }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			uiAsset.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.positionInputs.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.angleInputs.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.sizeInputs.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.alphaInputs.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.tintInputs.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.alignInputs.addEventListener(Event.CHANGE, propsChangeEvent);
			decoStyleView.colorInputs.addEventListener(ListEvent.ADD, addColor);
			decoStyleView.colorInputs.addEventListener(ListEvent.REMOVE, removeColor);
			decoStyleView.colorInputs.addEventListener(Event.CHANGE, propsChangeEvent);
			decoStyleView.decoInputs.addEventListener(ListEvent.ADD, addDeco);
			decoStyleView.decoInputs.addEventListener(ListEvent.REMOVE, removeDeco);
			decoStyleView.decoInputs.addEventListener(Event.CHANGE, propsChangeEvent);
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function propsChangeEvent (e:Event):void
		{
			//try { // // Consol.Trace(e.target.name); } catch(e:Error){}
			
			e.stopImmediatePropagation();
			
			decoStyleView.applyProps();
			
			brushPropsModel.pullStyleProps();
			
			// brushPropsModel.pullStyleProps(BrushPropsModel.BEHAVIOR);
			// which will then know to pull the settings from the behavior view and apply them to the appropriate styles
		}
		
		private function addColor (e:ListEvent):void
		{
			try {   decoStyleView.colorInputs.addItemAt(decoStyleView.colorInputs.list[decoStyleView.colorInputs.selectedIndex].copy(), decoStyleView.colorInputs.selectedIndex);   }
			catch (e:Error) {   decoStyleView.colorInputs.addItemAt(decoStyleView.colorInputs.list[0].copy(), 0);   }
			catch (e:Error) {  decoStyleView.colorInputs.addItemAt(new ColorObj(0xFF0000, true), 0);   }
			finally {      }
			brushPropsModel.pullStyleProps();
		}
		
		private function removeColor (e:ListEvent):void
		{
			try {   decoStyleView.colorInputs.removeItemsAt(decoStyleView.colorInputs.selectedIndex, 1);   }
			catch (e:Error) {   decoStyleView.colorInputs.removeItemsAt(0, 1);   }
			finally {      }
			brushPropsModel.pullStyleProps();
		}
		
		private function addDeco (e:ListEvent):void
		{
			ui.main.importToProject(FileManager.DECO);
			//brushPropsModel.pullStyleProps();
		}
		
		private function removeDeco (e:ListEvent):void
		{
			try {   decoStyleView.decoInputs.removeItemsAt(decoStyleView.decoInputs.selectedIndex, 1);   }
			catch (e:Error) {   decoStyleView.decoInputs.removeItemsAt(0, 1);   }
			finally {      }
			brushPropsModel.pullStyleProps();
		}
		
		/*private function mouseEvent (e:MouseEvent):void
		{
			
		}*/
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

		
		
		
	}
	
}