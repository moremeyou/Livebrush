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
	import com.livebrush.ui.ThresholdInputs;
	import com.livebrush.ui.SavedStylesUI;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.BrushBehaveUI;
	import com.livebrush.ui.BrushPropsController;
	import com.livebrush.ui.LayersView;
	import com.livebrush.styles.LineStyle;
	import com.livebrush.ui.Tooltip;
	
	import org.casalib.util.StringUtil;
	import org.casalib.util.NumberUtil;
	
	public class BrushBehaveView extends UIView
	{
		
		public static const INPUT_TYPES						:Array = [{label:"Normal", data:LineStyle.NORMAL}, 
																	  {label:"Live", data:LineStyle.ELASTIC}, 
																	  {label:"Dynamic", data:LineStyle.DYNAMIC}];
		
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
			uiAsset.behaveTypeHead.label.text = "Behavior Type".toUpperCase();
			//uiAsset.brushBehav
			uiAsset.liveControlHead.label.text = "Live Controls Settings".toUpperCase();
			uiAsset.thresholdsHead.label.text = "Decoration Attach Thresholds".toUpperCase();
			uiAsset.tRand.toggleMin();
			uiAsset.tInterval.toggleMax();
			
			uiAsset.drawSpeedHead.label.text = "Draw Speed".toUpperCase();
			uiAsset.maxSpeedInput.label = "Maximum";
			uiAsset.minSpeedInput.label = "Minimum";
			
			uiAsset.tAngle.maxIn = 1;
			
			uiAsset.tAngle.minIn = 0;
			uiAsset.tAngle.maxIn = 360;
			
			uiAsset.tInterval.minIn = 0;
			uiAsset.tInterval.maxIn = 60;
			
			Tooltip.addTip( uiAsset.loadInputBtn, "Load dynamic input SWF" );
			
			
			
		}
		
		protected override function createController ():void
		{
			controller = new BrushBehaveController(this);
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function applyProps ():void
		{
			var isDynamicInput:Boolean = (uiAsset.behaveTypes.selectedItem.data == LineStyle.DYNAMIC);
			
			uiAsset.velocityInput.enabled = uiAsset.frictionInput.enabled = (uiAsset.behaveTypes.selectedItem.data == LineStyle.ELASTIC);
			uiAsset.loadInputBtn.enabled = uiAsset._dynamicFile.visible = isDynamicInput;
			uiAsset.loadInputBtn.alpha = uiAsset.loadInputBtn.enabled ? 1 : 0;
			 
			uiAsset.lockMouse.enabled = isDynamicInput;
			uiAsset.mouseUpComplete.enabled = (isDynamicInput || (uiAsset.behaveTypes.selectedItem.data == LineStyle.ELASTIC));
			
		}
		
		public override function update (update:Update=null):void
		{
			if (update.type == UpdateEvent.WINDOW || update.type == UpdateEvent.UI)
			{
				//uiAsset.contentHolder.height = ui.toolPropsView.panelAsset.height - 97;
				//try {   uiAsset.contentHolder.drawNow();   } catch (e:Error) {   }
			}
			else if (update.type == UpdateEvent.BRUSH_STYLE)
			{
				update.data.behavior.enabledDecos = (update.data.deco.decos.length>0);
				settings = update.data.behavior as Settings;
			}
		}
		
		public override function set settings (settings:Settings):void
		{
			lastSettings = settings;
			uiAsset.behaveTypes.selectedIndex = Settings.idToIndex(settings.type, INPUT_TYPES, "data");
			//// // Consol.Trace(uiAsset.behaveTypes.selectedItem);
			uiAsset.velocityInput.value = settings.elastic*100;
			uiAsset.frictionInput.value = 100 - (settings.friction * 100);
			uiAsset._dynamicFile.text = settings.inputSWF;
			
			uiAsset.mouseUpComplete.selected = settings.mouseUpComplete;
			uiAsset.lockMouse.selected = settings.lockMouse;
			
			if (settings.enabledDecos)
			{
				uiAsset.tSpeed.enabled = uiAsset.tWidth.enabled = uiAsset.tAngle.enabled = uiAsset.tDist.enabled = uiAsset.tRand.enabled = uiAsset.tInterval.enabled = true;
				
				uiAsset.tSpeed.min = settings.thresholds.speed.min;
				uiAsset.tSpeed.max = settings.thresholds.speed.max;
				uiAsset.tSpeed.active = settings.thresholds.speed.enabled;
				
				uiAsset.tWidth.min = settings.thresholds.width.min;
				uiAsset.tWidth.max = settings.thresholds.width.max;
				uiAsset.tWidth.active = settings.thresholds.width.enabled;
				
				uiAsset.tAngle.min = settings.thresholds.angle.min;
				uiAsset.tAngle.max = settings.thresholds.angle.max;
				uiAsset.tAngle.active = settings.thresholds.angle.enabled;
				
				uiAsset.tDist.min = settings.thresholds.distance.min;
				uiAsset.tDist.max = settings.thresholds.distance.max;
				uiAsset.tDist.active = settings.thresholds.distance.enabled;
				
				uiAsset.tRand.max = settings.thresholds.random.max;
				uiAsset.tRand.active = settings.thresholds.random.enabled;
				
				uiAsset.tInterval.min = Number(settings.thresholds.interval.min) / 1000;
				//uiAsset.tInterval.max = Number(settings.thresholds.interval.max) / 1000;
				uiAsset.tInterval.active = settings.thresholds.interval.enabled;
			}
			else
			{
				uiAsset.tSpeed.enabled = uiAsset.tWidth.enabled = uiAsset.tAngle.enabled = uiAsset.tDist.enabled = uiAsset.tRand.enabled = uiAsset.tInterval.enabled = false;
			}
			
			uiAsset.minSpeedInput.value = settings.minDrawSpeed;
			uiAsset.maxSpeedInput.value = settings.maxDrawSpeed;
			
			applyProps();
			
		}
		
		public override function get settings ():Settings
		{
			var settings:Settings = lastSettings; //new Settings();
			
			//try { settings.type = uiAsset.behaveTypes.selectedItem.data; } catch (e:Error) {};
			
			settings.mouseUpComplete = uiAsset.mouseUpComplete.selected;
			settings.lockMouse = uiAsset.lockMouse.selected;
			//// // Consol.Trace(uiAsset.mouseUpComplete.selected);
			settings.type = uiAsset.behaveTypes.selectedItem.data;
			settings.elastic = toFraction(uiAsset.velocityInput.value);
			settings.friction = 1 - toFraction(uiAsset.frictionInput.value);
			
			settings.minDrawSpeed = uiAsset.minSpeedInput.value;
			settings.maxDrawSpeed = uiAsset.maxSpeedInput.value;
			
			settings.thresholds = {speed:{}, width:{}, angle:{}, distance:{}, random:{}, interval:{}};
			settings.thresholds.speed = getThresholdObj(uiAsset.tSpeed);
			settings.thresholds.width = getThresholdObj(uiAsset.tWidth);
			settings.thresholds.angle =  getThresholdObj(uiAsset.tAngle);
			settings.thresholds.distance = getThresholdObj(uiAsset.tDist);
			settings.thresholds.random = getThresholdObj(uiAsset.tRand);
			settings.thresholds.interval.min = uiAsset.tInterval.min * 1000;
			//settings.thresholds.interval.max = uiAsset.tInterval.max * 1000;
			settings.thresholds.interval.enabled = uiAsset.tInterval.active
			
			//// // Consol.Trace(settings.mouseUpComplete);
			return settings;
		}
		
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function getThresholdObj (tInput:ThresholdInputs):Object
		{
			return {min:tInput.min, max:tInput.max, enabled:tInput.active};
		}
		
		
	}
	
	
}