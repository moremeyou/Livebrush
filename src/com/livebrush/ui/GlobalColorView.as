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
	import com.livebrush.styles.Style;
	import com.livebrush.styles.StrokeStyle;
	import com.livebrush.ui.SavedStylesUI;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.GlobalColorUI;
	import com.livebrush.ui.BrushPropsController;
	import com.livebrush.ui.LayersView;
	import com.livebrush.ui.SequenceList;
	import com.livebrush.ui.ColorListItem;
	import com.livebrush.ui.Tooltip;
	
	
	public class GlobalColorView extends UIView
	{
		
		public static const COLOR_TYPES							:Array = [{label:"Fixed", data:StrokeStyle.FIXED}, 
																		  {label:"Multiple", data:StrokeStyle.LIST},
																		  // {label:"Draw Speed", data:StrokeStyle.SPEED},   
																		  // {label:"Stroke Width", data:StrokeStyle.WIDTH},
																		  {label:"Brush Position", data:StrokeStyle.SAMPLE_BRUSH},
																		   {label:"Mouse Position", data:StrokeStyle.SAMPLE},
																		  {label:"Random", data:StrokeStyle.RANDOM},
																		  {label:"None", data:StrokeStyle.NONE}];
		
		public var uiAsset										:GlobalColorUI;
		private var _colorInputs								:SequenceList;
		public var visible										:Boolean = false;
		public var colorType									:String = StrokeStyle.LIST;
		private var _colorList									:Array;
		public var _colorObjList								:Array;
		public var colorSteps									:int = 40;
		public var colorHold									:int = 1;
		public var alpha										:Number = 0;
		public var alphaLocked									:Boolean = false;
		
		public function GlobalColorView (ui:UI):void
		{
			super(ui);
			helpID = "globalColor";
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get colorInputs ():SequenceList {  return _colorInputs;   }; 
		public function get colorList ():Array {   return _colorList;   }
		public function get colorObjList ():Array {   return _colorObjList;   }
		public function set colorObjList (list:Array):void {   _colorObjList=list; _colorList=[]; for(var i:int=0; i<list.length; i++) if (list[i].enabled) _colorList.push(list[i].color);   }
		public function get selectedColor ():Number {   return colorList[0];   } // colorList.length-1
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function init ():void {}*/
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			
			uiAsset = new GlobalColorUI();
			
			_colorInputs = new SequenceList(uiAsset.colorInputs, ColorListItem);
			_colorInputs.speedLabel = "Tween";
			_colorInputs.speed = colorSteps;
			_colorInputs.typeList = COLOR_TYPES;
			//_colorInputs.orderEditable = true;
			_colorInputs.holdInput.label = "Hold";
			_colorInputs.holdInput.min = 1;
			_colorInputs.holdInput.value = colorHold;
			uiAsset._alpha.label = "Alpha";
			uiAsset._alpha.min = 0;
			uiAsset._alpha.max = 100;
			uiAsset.alphaLocked.selected = alphaLocked;
			
			colorObjList = Style.objListToColorObjList([{value:0x000000, enabled:true}]);
			_colorInputs.dataProvider = colorObjList;
			uiAsset._alpha.value = 100;
			
			Tooltip.addTip( uiAsset.colorInputs._listEditor.addBtn, "Duplicate selected color" );
			Tooltip.addTip( uiAsset.colorInputs._listEditor.removeBtn, "Remove selected color" );
			Tooltip.addTip( uiAsset.colorInputs._listEditor.upBtn, "Move color up" );
			Tooltip.addTip( uiAsset.colorInputs._listEditor.downBtn, "Move color down" );
			
			Tooltip.addTip( uiAsset.pullStyleBtn, "Retrieve colors from style" );
			Tooltip.addTip( uiAsset.pushColorBtn, "Assign colors to style" );
			
			uiAsset.x = UI.WIDTH - uiAsset.width - 6;
			uiAsset.y = 269;
			
			//uiAsset.alphaInputs.setMinMax(0, 100, 1, 100);
		}
		
		protected override function createController ():void
		{
			controller = new GlobalColorController(this);
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function toggle ():void {
		
			if (visible) {
			
				//try { 
				UI.TOP_UI_HOLDER.removeChild(uiAsset);
				//} catch (e:Error{}
				
				visible = false;
	
			} else  {
			
				//try { 
				
				UI.TOP_UI_HOLDER.addChild(uiAsset); 
				//} catch (e:Error{}
				
				visible = true;
	
			}
			
			//// Consol.Trace("GlobalColorView: UI.WIDTH = " + UI.WIDTH);
			//uiAsset.x = UI.WIDTH - uiAsset.width - 42 - 6;
			//uiAsset.y = 269;
		}
		
		public function applyProps ():void
		{
			try 
			{
				
				_colorInputs.speedEnabled = (StrokeStyle.LIST == String(_colorInputs.type));
				
			}
			catch (e:Error)
			{
			}
		}
		
		public override function update (update:Update=null):void
		{
			if (update.type == UpdateEvent.WINDOW) // || update.type == UpdateEvent.UI)
			{
				//// Consol.Trace("GlobalColorView: update window");
				
				uiAsset.x = UI.WIDTH - uiAsset.width - 42 - 6; // 6 = padding between toolbar
				uiAsset.y = 269;
				//if (state != UI.CLOSED) panelAsset.bg.height = _height;
			}
			//else if (update.type == UpdateEvent.DATA)
			else if (update.type == UpdateEvent.BRUSH_STYLE)
			{
				//settings = update.data.line as Settings;
			}
		}
	
		public override function get settings ():Settings
		{
			var settings:Settings = new Settings();
			
			try { settings.colorType = _colorInputs.type; } catch (e:Error) {   settings.colorType = colorType;   }
			settings.colorObjList = _colorInputs.list;
			settings.colorList = colorList;
			try { settings.colorSteps = _colorInputs.speed; } catch (e:Error) {      }
			try { settings.colorHold = _colorInputs.holdInput.value; } catch (e:Error) {      }
			try { settings.alpha = uiAsset._alpha.value/100; } catch (e:Error) {      }
			settings.color = colorList[0];
			settings.alphaLocked = uiAsset.alphaLocked.selected;
			
			//// Consol.Trace("GlobalColorView: get settings: alphaLocked: " + settings.alphaLocked);
			
			return settings;
		}
		
		public override function set settings (settings:Settings):void
		{
			_colorInputs.type = colorType = settings.colorType;
			_colorInputs.dataProvider = colorObjList = settings.colorObjList; //toObjList(settings.colorList);
			_colorInputs.speed = colorSteps = settings.colorSteps;
			_colorInputs.holdInput.value = colorHold = settings.colorHold;
			uiAsset._alpha.value = alpha = settings.alpha*100;
			alphaLocked = uiAsset.alphaLocked.selected = settings.alphaLocked;
			
			applyProps();
		}
		
		
		
	}
	
	
}