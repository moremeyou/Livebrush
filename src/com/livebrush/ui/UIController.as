package com.livebrush.ui
{
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fl.controls.TextInput;
	import fl.controls.ComboBox;
	import fl.controls.Slider;
	import fl.data.DataProvider;
	
	import com.livebrush.styles.StrokeStyle;
	import com.livebrush.ui.SliderInput;
	import com.livebrush.ui.Consol;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.events.CanvasEvent;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.UIView;
	import com.livebrush.utils.View;
	import com.livebrush.utils.Model;
	import com.livebrush.utils.Controller;
	import com.livebrush.utils.Update;
	
	import org.casalib.util.StringUtil;
	import org.casalib.util.NumberUtil;
	
	public class UIController extends Controller
	{
		
		public function UIController (uiView:UIView):void
		{
			super(uiView);
			//// // Consol.Trace(uiView.panelSprite);
			//try {   // // Consol.Trace(uiView.panelSprite); uiView.panelSprite.addEventListener(MouseEvent.CLICK, _panelClick);   } catch (e:Error) {}
		}
		
		protected function get ui ():UI {   return UIView(view).ui;   }
		//public function get styleManager ():StyleManager {   return ui.styleManager;   }
		public function get canvasManager ():CanvasManager {   return ui.canvasManager;   }
		public function get canvas ():Canvas {   return canvasManager.canvas;   }
		public function get activeLayer ():Layer {   return canvasManager.activeLayer;   }
		public function get activeLayers ():Array {   return canvasManager.activeLayers;   }
		
		public override function die ():void
		{
			canvasManager.removeEventListener(CanvasEvent.MOUSE_EVENT, canvasMouseEvent);
		}
		
		protected override function init ():void
		{
			canvasManager.addEventListener(CanvasEvent.MOUSE_EVENT, canvasMouseEvent);
			
		}
		
		protected function _loadHelp ():void
		{
			//if (e.type == MouseEvent.CLICK && e.target.name.indexOf("help")>-1)
			//{
				ui.loadHelp(UIView(view).helpID);
			//}
		}
		
		protected function canvasMouseEvent (e:CanvasEvent):void
		{
			// CanvasEvent.MOUSE_EVENT - all MouseEvents except when MOUSE_DOWN is OUTSIDE the canvas (ex: the canvas matte)
			
			if (!Layer.isBackgroundLayer(activeLayer))
			{
				var mouseEvent:MouseEvent = e.triggerEvent as MouseEvent;
				var clickedContent:Boolean = activeLayer.mouseHitTest();
				//// // Consol.Trace(!Layer.isBackgroundLayer(activeLayer));
				if (mouseEvent.type == MouseEvent.MOUSE_DOWN)
				{
					if (clickedContent) contentMouseDown(mouseEvent);
					else openCanvasMouseDown(mouseEvent);
				}
				else if (mouseEvent.type == MouseEvent.MOUSE_UP)
				{
					canvasMouseUp(mouseEvent);
				}
				else if (mouseEvent.type == MouseEvent.RIGHT_MOUSE_DOWN)
				{
					if (clickedContent) contentRightMouseDown(mouseEvent);
				}
			}
		}
		
		protected function canvasMouseUp (e:MouseEvent):void
		{
			//if (Layer.isLineLayer(activeLayer)) // // Consol.Trace("line MouseDown");
			//else // // Consol.Trace("other MouseDown");
		}
		
		protected function contentRightMouseDown (e:MouseEvent):void
		{
			//if (Layer.isLineLayer(activeLayer)) // // Consol.Trace("line MouseDown");
			//else // // Consol.Trace("other MouseDown");
		}
		
		protected function contentMouseDown (e:MouseEvent):void
		{
			//if (Layer.isLineLayer(activeLayer)) // // Consol.Trace("line MouseDown");
			//else // // Consol.Trace("other MouseDown");
		}
		
		protected function openCanvasMouseDown (e:MouseEvent):void
		{
			//// // Consol.Trace("open canvas MouseDown");
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		public static function typeInputIsAutomatic (s:String):Boolean
		{
			return (s == StrokeStyle.ROTATE || s == StrokeStyle.OSC);
		}
		
		public static function toNumber (value:Object):Number
		{
			return Number(value);
		}
		
		public static function toFraction (value:Object, div:Number=100):Number
		{
			return (toNumber(value)/div);
		}
		
		public static function minMax (value:Object, min:Number=1, max:Number=1000):Number
		{
			value = toNumber(value);
			//value = Math.max(min, toNumber(value));
			//if (!isNaN(max)) value = Math.min(max, toNumber(value));
			return NumberUtil.constrain(Number(value), min, max);
		}
		
		public static function speed (value:Object):Number
		{
			return toFraction(minMax(toNumber(value)));
		}
		
		public static function time (value:Object):Number
		{
			return (toNumber(value)*1000);
		}
		
		public static function toObjList (l:Array):Array
		{
			var dL:Array = [];
			for (var i:int=0; i<l.length; i++)
			{
				dL.push({data:l[i]});
			}
			
			return dL;
		}
		
		public static function toDataList (l:Array):Array
		{
			var dL:Array = [];
			for (var i:int=0; i<l.length; i++)
			{
				dL.push(l[i].data);
			}
			
			return dL;
		}
		
		
		public function toNumber (value:Object):Number
		{
			return UIController.toNumber(value);
		}
		
		public function toFraction (value:Object, div:Number=100):Number
		{
			return UIController.toFraction(value, div);
		}

		public function minMax (value:Object, min:Number=1, max:Number=NaN):Number
		{
			return UIController.minMax(value, min, max);
		}
		
		public function speed (value:Object):Number
		{
			return UIController.speed(value);
		}
		
		public function time (value:Object):Number
		{
			return UIController.time(value);
		}
		
		public function toObjList (l:Array):Array
		{
			return UIController.toObjList(l);
		}
		
		public function toDataList (l:Array):Array
		{
			return UIController.toDataList(l);
		}
		
		
		//protected function registerTextInput (textInput:TextInput, changeHandler:Function, notifyPanel:Boolean=true, restrict:String="0123456789", maxChars:int=3):void
		protected function registerTextInput (textInput:TextInput, changeHandler:Function, restrict:String="0123456789", maxChars:int=3):void
		{
			textInput.restrict = restrict;
			textInput.addEventListener (Event.CHANGE, changeHandler);
			textInput.maxChars = maxChars;
			//if (notifyPanel) textInput.addEventListener (Event.CHANGE, panelChangeListener);
		}
		
		protected function registerMinMaxInput (name:String, changeHandler:Function, notifyPanel:Boolean=true, restrict:String="0123456789", maxChars:int=3):void
		{
			//registerTextInput(this["min"+name], changeHandler, true, restrict, maxChars);
			//registerTextInput(this["max"+name], changeHandler, true, restrict, maxChars);
		}
		
		protected function registerSliderControl (slider:SliderInput, changeHandler:Function, label:String="Slider Control", min:Number=0.01, max:Number=100, mid:Number=50):void
		{
			slider.label = label;
			slider.max = max;
			slider.min = min;
			slider.value = mid;
			slider.addEventListener(Event.CHANGE, changeHandler);
		}
		
		public function registerTypeControl (comboBox:ComboBox, dataSet:Array, changeHandler:Function, notifyPanel:Boolean=true, rowCount:int=10):void
		{
			UIController.registerTypeControl(comboBox, dataSet, changeHandler);
		}
		
		public static function registerTypeControl (comboBox:ComboBox, dataSet:Array, changeHandler:Function, notifyPanel:Boolean=true, rowCount:int=10):void
		{
			comboBox.dataProvider = new DataProvider (dataSet);
			comboBox.rowCount = rowCount;
			comboBox.addEventListener (Event.CHANGE, changeHandler);
			//if (notifyPanel) comboBox.addEventListener (Event.CHANGE, panelChangeListener);
		}
		
	}
	
}