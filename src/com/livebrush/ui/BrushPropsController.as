package com.livebrush.ui
{
	import flash.events.MouseEvent;
	import flash.events.Event;
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
	import com.livebrush.styles.*; //StyleManager;
	//import com.livebrush.styles.Style;
	import com.livebrush.data.Settings;
	
	
	public class BrushPropsController extends UIController
	{
		
		public function BrushPropsController (brushPropsView:BrushPropsView):void
		{
			super(brushPropsView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get brushPropsView ():BrushPropsView {   return BrushPropsView(view);  }
		private function get brushPropsModel ():BrushPropsModel {   return brushPropsView.brushPropsModel;   }
		private function get uiAsset ():Sprite {   return brushPropsView.uiAsset;  }
		private function get brushBehaveView ():BrushBehaveView {   return brushPropsModel.brushBehaveView;  }
		private function get lineStyleView ():LineStyleView {   return brushPropsModel.lineStyleView;  }
		private function get decoStyleView ():DecoStyleView {   return brushPropsModel.decoStyleView;  }
		public function get styleManager ():StyleManager {   return brushPropsModel.styleManager;   }
		public function get activeStyle ():Style {   return styleManager.activeStyle;   }
		private function get lineStyle ():LineStyle {   return activeStyle.lineStyle;   }
		private function get strokeStyle ():StrokeStyle {   return activeStyle.strokeStyle;   }
		private function get decoStyle ():DecoStyle {   return activeStyle.decoStyle;   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			uiAsset.addEventListener(MouseEvent.CLICK, mouseEvent);
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function mouseEvent (e:MouseEvent):void
		{
			if (e.target.name.indexOf("tab") > -1)
			{
				var tabIndex:int = int(e.target.name.substr(3));
				//// // Consol.Trace("tab click: " + e.target.name);
				//// // Consol.Trace("tab click: " + e.target.name);
				//brushPropsView.toggleProps(tabIndex);
				brushPropsModel.toggleProps(tabIndex);
			}
			else if (e.target.name.indexOf("help") > -1)
			{
				//// // Consol.Trace(e.target.parent.name);
				// if (e.type == MouseEvent.CLICK && e.target.name.indexOf("help")>-1) _loadHelp();
				//_loadHelp();
				//// // Consol.Trace("help from tool props");
				
				switch (e.target.parent.name) 
				{
					case "behaveTypeHead": ui.loadHelp("behaveType"); break;
					case "liveControlHead": ui.loadHelp("liveControls"); break;
					case "thresholdsHead": ui.loadHelp("decoThresholds"); break;
					case "drawSpeedHead": ui.loadHelp("drawSpeed"); break;
					
					case "lineTypeHead": ui.loadHelp("lineType"); break;
					case "strokeTypeHead": ui.loadHelp("strokeType"); break;
					case "lineWidthHead": ui.loadHelp("lineWidth"); break;
					case "lineAngleHead": ui.loadHelp("lineAngle"); break;
					case "lineAlphaHead": ui.loadHelp("lineOpacity"); break;
					case "lineColorHead": ui.loadHelp("lineColors"); break;
					
					case "decoListHead": ui.loadHelp("decoList"); break;
					case "decoAlignHead": ui.loadHelp("decoAlignType"); break;
					case "decoPositionHead": ui.loadHelp("decoPosition"); break;
					case "decoAngleHead": ui.loadHelp("decoAngle"); break;
					case "decoSizeHead": ui.loadHelp("decoScale"); break;
					case "decoAlphaHead": ui.loadHelp("decoOpacity"); break;
					case "decoTintHead": ui.loadHelp("decoColorAmount"); break;
					case "decoColorHead": ui.loadHelp("decoColors"); break;
				}
			}
			else if (e.target.name.indexOf("reset") > -1)
			{
				var settings:Settings;
				
				if (e.target.parent.name == "behaveTypeHead") 
				{
					settings = lineStyle.settings;
					settings.type = lineStyle.defaultSettings.type;
					lineStyle.settings = settings;
				}
				else if (e.target.parent.name == "liveControlHead") 
				{
					settings = lineStyle.settings;
					settings.elastic = lineStyle.defaultSettings.elastic;
					settings.friction = lineStyle.defaultSettings.friction;
					lineStyle.settings = settings;
				}
				else if (e.target.parent.name == "thresholdsHead") 
				{
					settings = strokeStyle.settings;
					settings.thresholds = strokeStyle.defaultSettings.thresholds;
					strokeStyle.settings = settings;
				}
				else if (e.target.parent.name == "drawSpeedHead") 
				{
					settings = lineStyle.settings;
					settings.minDrawSpeed = lineStyle.defaultSettings.minDrawSpeed;
					settings.maxDrawSpeed = lineStyle.defaultSettings.maxDrawSpeed;
					lineStyle.settings = settings;
				}
				else if (e.target.parent.name == "lineTypeHead") 
				{
					settings = lineStyle.settings;
					settings.smoothing = lineStyle.defaultSettings.smoothing;
					lineStyle.settings = settings;
				}
				else if (e.target.parent.name == "strokeTypeHead") 
				{
					settings = strokeStyle.settings;
					settings.strokeType = strokeStyle.defaultSettings.strokeType;
					settings.lines = strokeStyle.defaultSettings.lines;
					settings.weight = strokeStyle.defaultSettings.weight;
					strokeStyle.settings = settings;
				}
				else if (e.target.parent.name == "lineWidthHead") 
				{
					settings = strokeStyle.settings;
					settings.widthType = strokeStyle.defaultSettings.widthType;
					settings.minWidth = strokeStyle.defaultSettings.minWidth;
					settings.maxWidth = strokeStyle.defaultSettings.maxWidth;
					settings.widthSpeed = strokeStyle.defaultSettings.widthSpeed;
					strokeStyle.settings = settings;
				}
				else if (e.target.parent.name == "lineAngleHead") 
				{
					settings = strokeStyle.settings;
					settings.angleType = strokeStyle.defaultSettings.angleType;
					settings.minAngle = strokeStyle.defaultSettings.minAngle;
					settings.maxAngle = strokeStyle.defaultSettings.maxAngle;
					settings.angleSpeed = strokeStyle.defaultSettings.angleSpeed;
					strokeStyle.settings = settings;
				}
				else if (e.target.parent.name == "lineAlphaHead") 
				{
					settings = strokeStyle.settings;
					settings.alphaType = strokeStyle.defaultSettings.alphaType;
					settings.minAlpha = strokeStyle.defaultSettings.minAlpha;
					settings.maxAlpha = strokeStyle.defaultSettings.maxAlpha;
					settings.alphaSpeed = strokeStyle.defaultSettings.alphaSpeed;
					strokeStyle.settings = settings;
				}
				else if (e.target.parent.name == "lineColorHead") 
				{
					settings = strokeStyle.settings;
					settings.colorObjList = strokeStyle.defaultSettings.colorObjList;
					settings.colorType = strokeStyle.defaultSettings.colorType;
					settings.colorSteps = strokeStyle.defaultSettings.colorSteps;
					strokeStyle.settings = settings;
				}
				else if (e.target.parent.name == "decoListHead") 
				{
					settings = decoStyle.settings;
					settings.decos = decoStyle.defaultSettings.decos;
					settings.selectedDecoIndex = decoStyle.defaultSettings.selectedDecoIndex;
					settings.orderType = decoStyle.defaultSettings.orderType;
					settings.decoNum = decoStyle.defaultSettings.decoNum;
					decoStyle.settings = settings;
				}
				else if (e.target.parent.name == "decoAlignHead") 
				{
					settings = decoStyle.settings;
					settings.autoFlip = decoStyle.defaultSettings.autoFlip;
					settings.alignType = decoStyle.defaultSettings.alignType;
					decoStyle.settings = settings;
				}
				else if (e.target.parent.name == "decoPositionHead") 
				{
					settings = decoStyle.settings;
					settings.posType = decoStyle.defaultSettings.posType;
					settings.minPos = decoStyle.defaultSettings.minPos;
					settings.maxPos = decoStyle.defaultSettings.maxPos;
					settings.posSpeed = decoStyle.defaultSettings.posSpeed;
					decoStyle.settings = settings;
				}
				else if (e.target.parent.name == "decoAngleHead") 
				{
					settings = decoStyle.settings;
					settings.angleType = decoStyle.defaultSettings.angleType;
					settings.minAngle = decoStyle.defaultSettings.minAngle;
					settings.maxAngle = decoStyle.defaultSettings.maxAngle;
					settings.angleSpeed = decoStyle.defaultSettings.angleSpeed;
					decoStyle.settings = settings;
				}
				else if (e.target.parent.name == "decoSizeHead") 
				{
					settings = decoStyle.settings;
					settings.sizeType = decoStyle.defaultSettings.sizeType;
					settings.minSize = decoStyle.defaultSettings.minSize;
					settings.maxSize = decoStyle.defaultSettings.maxSize;
					settings.sizeSpeed = decoStyle.defaultSettings.sizeSpeed;
					decoStyle.settings = settings;
				}
				else if (e.target.parent.name == "decoAlphaHead") 
				{
					settings = decoStyle.settings;
					settings.alphaType = decoStyle.defaultSettings.alphaType;
					settings.minAlpha = decoStyle.defaultSettings.minAlpha;
					settings.maxAlpha = decoStyle.defaultSettings.maxAlpha;
					settings.alphaSpeed = decoStyle.defaultSettings.alphaSpeed;
					decoStyle.settings = settings;
				}
				else if (e.target.parent.name == "decoTintHead") 
				{
					settings = decoStyle.settings;
					settings.tintType = decoStyle.defaultSettings.tintType;
					settings.minTint = decoStyle.defaultSettings.minTint;
					settings.maxTint = decoStyle.defaultSettings.maxTint;
					settings.tintSpeed = decoStyle.defaultSettings.tintSpeed;
					decoStyle.settings = settings;
				}
				else if (e.target.parent.name == "decoColorHead") 
				{
					settings = decoStyle.settings;
					settings.colorObjList = decoStyle.defaultSettings.colorObjList;
					settings.colorType = decoStyle.defaultSettings.colorType;
					settings.colorSteps = decoStyle.defaultSettings.colorSteps;
					decoStyle.settings = settings;
				}
				
				styleManager.pushStyle();
			}
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

		
		
		
	}
	
}