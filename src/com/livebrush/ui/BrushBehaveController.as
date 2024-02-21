package com.livebrush.ui
{
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	
	import com.livebrush.styles.LineStyle;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.UIUpdate;
	import com.livebrush.ui.BrushBehaveView;
	import com.livebrush.ui.BrushPropsModel;
	import com.livebrush.styles.LineStyle;
	
	
	public class BrushBehaveController extends UIController
	{
		
		public function BrushBehaveController (brushBehaveView:BrushBehaveView):void
		{
			super(brushBehaveView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get brushBehaveView ():BrushBehaveView {   return BrushBehaveView(view);  }
		private function get brushPropsModel ():BrushPropsModel {   return brushBehaveView.brushPropsModel;   }
		private function get uiAsset ():Object {   return brushBehaveView.uiAsset;  }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			uiAsset.behaveTypes.addEventListener(Event.CHANGE, openInputSWF);
			
			registerTypeControl(uiAsset.behaveTypes, BrushBehaveView.INPUT_TYPES, propsChangeEvent);
			registerSliderControl(uiAsset.velocityInput, propsChangeEvent, "Velocity");
			registerSliderControl(uiAsset.frictionInput, propsChangeEvent, "Friction");
			//registerTextInput (uiAsset.minSpeedInput._input, propsChangeEvent);
			//registerTextInput (uiAsset.maxSpeedInput._input, propsChangeEvent);
			
			//textInput.addEventListener (Event.CHANGE, changeHandler);
			
			uiAsset.addEventListener(Event.CHANGE, propsChangeEvent);
			uiAsset.addEventListener(MouseEvent.CLICK, mouseEvent);
			
			//propsChangeEvent();
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function propsChangeEvent (e:Event):void
		{
			//try { // // Consol.Trace(e.target.name); } catch(e:Error){}
			
			e.stopImmediatePropagation();
			
			brushBehaveView.applyProps();
			
			brushPropsModel.pullStyleProps();
			
			//brushPropsModel.pullStyleProps(BrushPropsModel.BEHAVIOR);
			// which will then know to pull the settings from the behavior view and apply them to the appropriate styles
		}
		
		private function mouseEvent (e:MouseEvent):void
		{
			switch (e.target.name) {
				case "loadInputBtn" :
					ui.main.importInputSWF();
				break;
			}
		}
		
		private function openInputSWF (e:Event=null):void
		{
			if (uiAsset.behaveTypes.selectedItem.data == LineStyle.DYNAMIC && uiAsset._dynamicFile.text == "")
			{
				ui.main.importInputSWF();
			}
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

		
		
		
	}
	
}