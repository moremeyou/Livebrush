package com.livebrush.ui
{
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.display.Sprite;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import fl.controls.TextInput;
	import fl.controls.RadioButton;
	import fl.controls.CheckBox;
	import fl.controls.ColorPicker;
	import fl.events.ComponentEvent;
	
	import com.livebrush.data.StateManager;
	import com.livebrush.data.Settings;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.UIUpdate;
	
	public class TransformPropsController extends UIController
	{
		
		//public var lastPropChanged						:Object = null;
		
		
		public function TransformPropsController (transformPropsView:TransformPropsView):void
		{
			super(transformPropsView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get transformPropsView ():TransformPropsView {   return TransformPropsView(view);  }
		private function get uiAsset ():Object {   return transformPropsView.uiAsset;  }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			uiAsset.addEventListener(MouseEvent.CLICK, mouseEvent);
			uiAsset.scale.addEventListener(MouseEvent.CLICK, mouseEvent);
			uiAsset.rotate.addEventListener(MouseEvent.CLICK, mouseEvent);
			uiAsset.constrain.addEventListener(MouseEvent.CLICK, mouseEvent);
			uiAsset.addEventListener(ComponentEvent.ENTER, applyEvent);
			uiAsset.addEventListener(Event.CHANGE, changeEvent);
			//uiAsset.addEventListener(Event.CHANGE, changeEvent);
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function mouseEvent (e:MouseEvent):void
		{
			//// // Consol.Trace(e.target);
			if (e.target.name.indexOf("help")>-1)
			{
				switch (e.target.parent.name) 
				{
					case "transformControlHead": ui.loadHelp("transformControl"); break;
					case "scaleHead": ui.loadHelp("transformInput"); break;
					case "colorHead": ui.loadHelp("transformColor"); break;
				}
			}
			else if (e.target is RadioButton || e.target is CheckBox)
			{
				StateManager.lock();
				transformPropsView.colorChanged = transformPropsView.alphaChanged = false;
				ui.pullToolProps(transformPropsView);
				StateManager.unlock(this);
			}
		}
		
		private function changeEvent (e:Event):void
		{
			//// // Consol.Trace(e.target);
			if (e.target is ColorPicker) 
			{
				transformPropsView.colorChanged = true;
				ui.pullToolProps(transformPropsView);
			}
			else if (e.target.parent == uiAsset.alphaInput) 
			{
				transformPropsView.alphaChanged = true;
			}
			else 
			{
				transformPropsView.colorChanged = transformPropsView.alphaChanged = false;
			}
		}
		
		private function applyEvent (e:ComponentEvent):void
		{
			
			if (e.target is TextInput) 
			{
				ui.pullToolProps(transformPropsView);
				transformPropsView.colorChanged = transformPropsView.alphaChanged = false;
			}
		}
		
	
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

		
		
		
	}
	
}