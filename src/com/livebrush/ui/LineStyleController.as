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
	
	public class LineStyleController extends UIController
	{
		
		public function LineStyleController (lineStyleView:LineStyleView):void
		{
			super(lineStyleView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get lineStyleView ():LineStyleView {   return LineStyleView(view);  }
		private function get brushPropsModel ():BrushPropsModel {   return lineStyleView.brushPropsModel;   }
		private function get uiAsset ():Object {   return lineStyleView.uiAsset;  }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			uiAsset.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.lineType.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.strokeInputs.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.widthInputs.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.angleInputs.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.alphaInputs.addEventListener(Event.CHANGE, propsChangeEvent);
			lineStyleView.colorInputs.typeInput.addEventListener(Event.CHANGE, propsChangeEvent);
			lineStyleView.colorInputs.addEventListener(ListEvent.ADD, addColor);
			lineStyleView.colorInputs.addEventListener(ListEvent.REMOVE, removeColor);
			//lineStyleView.colorInputs.addEventListener(ListEvent.MOVE, propsChangeEvent);
			lineStyleView.colorInputs.addEventListener(Event.CHANGE, propsChangeEvent);
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function propsChangeEvent (e:Event):void
		{
			//try { // // Consol.Trace(e.target.name); } catch(e:Error){}
			
			e.stopImmediatePropagation();
			
			lineStyleView.applyProps();
			
			brushPropsModel.pullStyleProps();
			
		}
		
		private function addColor (e:ListEvent):void
		{
			try {   lineStyleView.colorInputs.addItemAt(lineStyleView.colorInputs.list[lineStyleView.colorInputs.selectedIndex].copy(), lineStyleView.colorInputs.selectedIndex);   }
			catch (e:Error) {   lineStyleView.colorInputs.addItemAt(lineStyleView.colorInputs.list[0].copy(), 0);   }
			catch (e:Error) {   lineStyleView.colorInputs.addItemAt(new ColorObj(0xFF0000, true), 0);   }
			finally {      }
			brushPropsModel.pullStyleProps();
		}
		
		private function removeColor (e:ListEvent):void
		{
			try {   lineStyleView.colorInputs.removeItemsAt(lineStyleView.colorInputs.selectedIndex, 1);   }
			catch (e:Error) {   lineStyleView.colorInputs.removeItemsAt(0, 1);   }
			finally {      }
			brushPropsModel.pullStyleProps();
		}
		
		private function mouseEvent (e:MouseEvent):void
		{
			
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

		
		
		
	}
	
}