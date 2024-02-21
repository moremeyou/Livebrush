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
	import com.livebrush.ui.DecoStyleUI;
	import com.livebrush.ui.BrushPropsController;
	import com.livebrush.ui.LayersView;
	import com.livebrush.styles.DecoStyle;
	import com.livebrush.styles.StrokeStyle;
	import com.livebrush.ui.SequenceList;
	import com.livebrush.ui.ColorListItem;
	import com.livebrush.ui.DecoListItem;
	import com.livebrush.ui.Tooltip;
	
	
	public class DecoStyleView extends UIView
	{
		
		public static const ORDER_TYPES						:Array = [{label:"Sequence", data:DecoStyle.SEQUENCE_DECO}, 
																	  {label:"Fixed", data:DecoStyle.FIXED_DECO}, 
																	  {label:"Random", data:DecoStyle.RANDOM_DECO}];
		
		public static const POS_TYPES						:Array = [{label:"Fixed", data:DecoStyle.FIXED}, 
																	  {label:"(A) Edge", data:DecoStyle.A}, 
																	  {label:"(B) Edge", data:DecoStyle.B}, 
																	  {label:"Center", data:DecoStyle.CENTER}, 
																	  {label:"Alternate", data:DecoStyle.ALT}, 
																	  {label:"Draw Speed", data:DecoStyle.SPEED},  
																	  {label:"Stroke Width", data:DecoStyle.WIDTH}, // based on width, but with min/max
																	  {label:"Oscillate", data:DecoStyle.OSC}, // line/stroke independent values
																	  {label:"Random", data:DecoStyle.RANDOM},
																	  {label:"Scatter", data:DecoStyle.SCATTER},
																	  {label:"Orbit", data:DecoStyle.ORBIT}];
		
		public static const ANGLE_TYPES						:Array = [{label:"Fixed", data:DecoStyle.FIXED}, 
																	  {label:"Stroke Direction", data:DecoStyle.DIR}, // the actual stroke angle
																	  {label:"Draw Speed", data:DecoStyle.SPEED}, 
																	  {label:"Stroke Width", data:DecoStyle.WIDTH},
																	  {label:"Oscillate", data:DecoStyle.OSC},
																	  {label:"Rotate", data:DecoStyle.ROTATE},
																	  {label:"Point At Position", data:DecoStyle.POS_DIR},
																	  {label:"Random", data:DecoStyle.RANDOM},
																	  {label:"No Change", data:DecoStyle.NONE}];
		
		public static const SIZE_TYPES						:Array = [{label:"Fixed", data:DecoStyle.FIXED}, 
																	  {label:"Draw Speed", data:DecoStyle.SPEED},
																	  {label:"Stroke Width", data:DecoStyle.WIDTH}, 
																	  {label:"Oscillate", data:DecoStyle.OSC},
																	  {label:"Random", data:DecoStyle.RANDOM},
																	  {label:"No Change", data:DecoStyle.NONE}];
		
		public static const COLOR_TYPES						:Array = [{label:"Fixed", data:DecoStyle.FIXED},
																	  {label:"Multiple", data:DecoStyle.LIST},
																	 // {label:"Draw Speed", data:DecoStyle.SPEED}, 
																	  //{label:"Stroke Width", data:DecoStyle.WIDTH},
																	  {label:"Random", data:DecoStyle.RANDOM},
																	  {label:"No Change", data:DecoStyle.NONE},
																	  {label:"Stroke Color", data:DecoStyle.STROKE}];
		
		
		public static const ALPHA_TYPES						:Array = [{label:"Fixed", data:DecoStyle.FIXED}, 
																	  {label:"Draw Speed", data:DecoStyle.SPEED},
																	  {label:"Stroke Width", data:DecoStyle.WIDTH}, 
																	  {label:"Oscillate", data:DecoStyle.OSC},
																	  {label:"Random", data:DecoStyle.RANDOM},
																	  {label:"Stroke Opacity", data:DecoStyle.STROKE}];
		
		public static const TINT_TYPES						:Array = [{label:"Fixed", data:DecoStyle.FIXED}, 
																	  {label:"Draw Speed", data:DecoStyle.SPEED},
																	  {label:"Stroke Width", data:DecoStyle.WIDTH}, 
																	  {label:"Oscillate", data:DecoStyle.OSC},
																	  {label:"Random", data:DecoStyle.RANDOM}];
		
		public static const ALIGN_TYPES						:Array = [{label:"Bottom Left", data:DecoStyle.ALIGN_CORNER}, 
																	  {label:"Center", data:DecoStyle.ALIGN_CENTER}];
		
		
		
		public var uiAsset							:DecoStyleUI;
		public var brushPropsModel					:BrushPropsModel;
		private var _colorInputs					:SequenceList;
		private var _decoInputs						:SequenceList;
		private var _positionType					:String = "";
		
		public function DecoStyleView (brushPropsModel:BrushPropsModel):void
		{
			super(brushPropsModel.ui);
			
			this.brushPropsModel = brushPropsModel;
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get list ():List {   return uiAsset.styleList;   }
		public function get colorInputs ():SequenceList {  return _colorInputs;   };
		public function get decoInputs ():SequenceList {  return _decoInputs;   };
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function init ():void {}*/
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			
			// STYLE LIST SETUP
			uiAsset = new DecoStyleUI();
			
			uiAsset.decoListHead.label.text = "Decorations".toUpperCase();
			_decoInputs = new SequenceList(uiAsset.decoInputs, DecoListItem);
			_decoInputs.allowMultipleSelection = false;
			_decoInputs.speedLabel = "#";
			_decoInputs.typeList = ORDER_TYPES;
			_decoInputs.holdInput.label = "Hold";
			_decoInputs.holdInput.min = 1;
			
			uiAsset.decoPositionHead.label.text = "Position".toUpperCase();
			uiAsset.positionInputs.list = POS_TYPES;
			
			uiAsset.decoAngleHead.label.text = "Angle".toUpperCase();
			uiAsset.angleInputs.list = ANGLE_TYPES;
			
			uiAsset.decoSizeHead.label.text = "Scale".toUpperCase();
			uiAsset.sizeInputs.list = SIZE_TYPES;
			
			_colorInputs = new SequenceList(uiAsset.colorInputs, ColorListItem);
			uiAsset.decoColorHead.label.text = "Color".toUpperCase();
			_colorInputs.speedLabel = "Tween";
			_colorInputs.typeList = COLOR_TYPES;
			_colorInputs.holdInput.label = "Hold";
			_colorInputs.holdInput.min = 0;
			
			uiAsset.decoTintHead.label.text = "Color Amount".toUpperCase();
			uiAsset.tintInputs.list = TINT_TYPES;
			
			uiAsset.decoAlphaHead.label.text = "Opacity".toUpperCase();
			uiAsset.alphaInputs.list = ALPHA_TYPES;
			
			uiAsset.decoAlignHead.label.text = "Align".toUpperCase();
			uiAsset.alignInputs.list = ALIGN_TYPES;
			uiAsset.alignInputs.toggleInput(0, false);
			uiAsset.alignInputs.toggleInput(1, false);
			uiAsset.alignInputs.toggleInput(2, false);
			
			
			uiAsset.positionInputs.setMinMax(-100, 200);
			uiAsset.angleInputs.setMinMax(0, 360, 1, 360);
			uiAsset.sizeInputs.setMinMax(1, 1000, 1, 100);
			uiAsset.tintInputs.setMinMax(0, 100, 1, 100);
			uiAsset.alphaInputs.setMinMax(0, 100, 1, 100);
			
			Tooltip.addTip( uiAsset.decoInputs._listEditor.addBtn, "Import deco" );
			Tooltip.addTip( uiAsset.decoInputs._listEditor.removeBtn, "Remove selected deco" );
			Tooltip.addTip( uiAsset.decoInputs._listEditor.upBtn, "Move deco up" );
			Tooltip.addTip( uiAsset.decoInputs._listEditor.downBtn, "Move deco down" );
			Tooltip.addTip( uiAsset.colorInputs._listEditor.addBtn, "Duplicate selected color" );
			Tooltip.addTip( uiAsset.colorInputs._listEditor.removeBtn, "Remove selected color" );
			Tooltip.addTip( uiAsset.colorInputs._listEditor.upBtn, "Move color up" );
			Tooltip.addTip( uiAsset.colorInputs._listEditor.downBtn, "Move color down" );
			
		}
		
		protected override function createController ():void
		{
			controller = new DecoStyleController(this);
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function applyProps ():void
		{
			// labels of pos types will change depending on the pos type
			// if scatter type, min= start angle. max= max scatter radius
			// if orbit type, min= start angle. max= orbit radius
			
			try 
			{
				//uiAsset.strokeInputs._input0._input.enabled = (uiAsset.strokeInputs.type==StrokeStyle.RAKE_STROKE || uiAsset.strokeInputs.type==StrokeStyle.PATH_STROKE);
				//uiAsset.strokeInputs._input1._input.enabled = uiAsset.strokeInputs._input0._input.enabled;
				//// // Consol.Trace((uiAsset.positionInputs.type == StrokeStyle.OSC) + " : " + typeInputIsAutomatic(uiAsset.positionInputs.type))
				if (uiAsset.positionInputs.type==DecoStyle.SCATTER || uiAsset.positionInputs.type==DecoStyle.ORBIT)
				{
					uiAsset.positionInputs.label1 = "Angle";
					uiAsset.positionInputs.label2 = "Radius";
					uiAsset.positionInputs.toggleInput(2, false);
					uiAsset.positionInputs._input0.min = 0;
					uiAsset.positionInputs._input0.max = 360;
					uiAsset.positionInputs._input1.min = 0;
					uiAsset.positionInputs._input1.max = 1000;
				}
				else
				{
					//// // Consol.Trace((uiAsset.positionInputs.type == StrokeStyle.OSC) + " : " + typeInputIsAutomatic(uiAsset.positionInputs.type))
					uiAsset.positionInputs.label1 = "Min";
					uiAsset.positionInputs.label2 = "Max";
					uiAsset.positionInputs.toggleInput(2, true);
					uiAsset.positionInputs.speedEnabled = typeInputIsAutomatic(uiAsset.positionInputs.type);
					//// // Consol.Trace(uiAsset.positionInputs.speedEnabled)
					uiAsset.positionInputs.setMinMax(-100, 200);
				}
				
				uiAsset.persist.enabled = (_decoInputs.speed>1);
				//uiAsset.persist.selected = (_decoInputs.speed>1 ? uiAsset.persist.selected : true);
				uiAsset.angleInputs.speedEnabled = typeInputIsAutomatic(uiAsset.angleInputs.type);
				uiAsset.alphaInputs.speedEnabled = typeInputIsAutomatic(uiAsset.alphaInputs.type);
				uiAsset.tintInputs.speedEnabled = typeInputIsAutomatic(uiAsset.tintInputs.type);
				uiAsset.sizeInputs.speedEnabled = typeInputIsAutomatic(uiAsset.sizeInputs.type);
				_colorInputs.speedEnabled = (DecoStyle.LIST == String(_colorInputs.type));
				
			}
			catch (e:Error)
			{
			}
		}
		
		public override function update (update:Update=null):void
		{
			if (update.type == UpdateEvent.WINDOW || update.type == UpdateEvent.UI)
			{
				//uiAsset.contentHolder.height = ui.toolPropsView.panelAsset.height - 97;
				//try {   uiAsset.contentHolder.drawNow();   } catch (e:Error) {   }
			}
			//else if (update.type == UpdateEvent.DATA)
			else if (update.type == UpdateEvent.BRUSH_STYLE)
			{
				//pushProps(Settings(update.data));
				settings = update.data.deco as Settings;
			}
		}
	
		public override function get settings ():Settings
		{
			var settings:Settings = new Settings();
			
			
			settings.decos = _decoInputs.list;	
			settings.selectedDecoIndex = _decoInputs.selectedIndex;
			settings.orderType = _decoInputs.type;
			settings.decoNum = _decoInputs.speed;
			settings.decoHold = _decoInputs.holdInput.value;
			
			settings.persist = uiAsset.persist.selected;

			settings.posType = uiAsset.positionInputs.type;
			
			if (uiAsset.positionInputs.type==DecoStyle.SCATTER || uiAsset.positionInputs.type==DecoStyle.ORBIT)
			{
				settings.minPos = uiAsset.positionInputs.min;
				settings.maxPos =  uiAsset.positionInputs.max;
			}
			else
			{
				settings.minPos = uiAsset.positionInputs.min / 100;
				settings.maxPos =  uiAsset.positionInputs.max / 100;
			}
			settings.posSpeed = uiAsset.positionInputs.speed / 100;
			
			settings.angleType = uiAsset.angleInputs.type;
			settings.autoFlip = uiAsset.autoFlip.selected;
			settings.minAngle = uiAsset.angleInputs.min;
			settings.maxAngle = uiAsset.angleInputs.max;
			settings.angleSpeed = uiAsset.angleInputs.speed // 100;
			
			settings.colorType = _colorInputs.type;
			settings.colorObjList = _colorInputs.list;
			settings.colorSteps = _colorInputs.speed;
			settings.colorHold = _colorInputs.holdInput.value;
			
			settings.tintType = uiAsset.tintInputs.type;
			settings.minTint = uiAsset.tintInputs.min / 100;
			settings.maxTint = uiAsset.tintInputs.max / 100;
			settings.tintSpeed = uiAsset.tintInputs.speed / 100;
			
			settings.sizeType = uiAsset.sizeInputs.type;
			settings.minSize = uiAsset.sizeInputs.min / 100;
			settings.maxSize = uiAsset.sizeInputs.max / 100;
			settings.sizeSpeed = uiAsset.sizeInputs.speed / 100;
			
			settings.alphaType = uiAsset.alphaInputs.type;
			settings.minAlpha = uiAsset.alphaInputs.min / 100;
			settings.maxAlpha = uiAsset.alphaInputs.max / 100;
			settings.alphaSpeed = uiAsset.alphaInputs.speed / 100;
			
			settings.alignType = uiAsset.alignInputs.type;
			
			return settings;
		}
		
		public override function set settings (settings:Settings):void
		{
			//_decoInputs.dataProvider = Settings.arrayToDataProvider (settings.decos, "fileName", "assetPath").toArray();	
			_decoInputs.dataProvider = settings.decos;	
			_decoInputs.selectedIndex = settings.selectedDecoIndex;
			_decoInputs.typeInput.selectedIndex = Settings.idToIndex (settings.orderType, ORDER_TYPES, "data");
			_decoInputs.speed = settings.decoNum;
			_decoInputs.holdInput.value = settings.decoHold;
			
			uiAsset.persist.selected = settings.persist;
			
			uiAsset.positionInputs.type = settings.posType;
			_positionType = settings.posType;
			if (settings.posType==DecoStyle.SCATTER || settings.posType==DecoStyle.ORBIT)
			{
				uiAsset.positionInputs.min = settings.minPos;
				uiAsset.positionInputs.max = settings.maxPos;
			}
			else
			{
				uiAsset.positionInputs.min = settings.minPos * 100;
				uiAsset.positionInputs.max = settings.maxPos * 100;
			}
			uiAsset.positionInputs.speed = settings.posSpeed*100;
			
			uiAsset.angleInputs.type = settings.angleType;
			uiAsset.autoFlip.selected = settings.autoFlip;
			uiAsset.angleInputs.min = settings.minAngle;
			uiAsset.angleInputs.max = settings.maxAngle;
			uiAsset.angleInputs.speed = settings.angleSpeed //*100;
			
			uiAsset.sizeInputs.type = settings.sizeType;
			uiAsset.sizeInputs.min = settings.minSize*100;
			uiAsset.sizeInputs.max = settings.maxSize*100;
			uiAsset.sizeInputs.speed = settings.sizeSpeed*100;
			
			_colorInputs.type = settings.colorType;
			_colorInputs.dataProvider = settings.colorObjList;
			_colorInputs.speed = settings.colorSteps;
			_colorInputs.holdInput.value = settings.colorHold;
			
			uiAsset.tintInputs.type = settings.tintType;
			uiAsset.tintInputs.min = settings.minTint*100;
			uiAsset.tintInputs.max = settings.maxTint*100;
			uiAsset.tintInputs.speed = settings.tintSpeed*100;
			
			uiAsset.alphaInputs.type = settings.alphaType;
			uiAsset.alphaInputs.min = settings.minAlpha*100;
			uiAsset.alphaInputs.max = settings.maxAlpha*100;
			uiAsset.alphaInputs.speed = settings.alphaSpeed*100;
			
			uiAsset.alignInputs.type = settings.alignType;
			
			if (settings.decos.length>0) 
			{
				uiAsset.autoFlip.enabled = uiAsset.positionInputs.enabled = uiAsset.angleInputs.enabled = uiAsset.tintInputs.enabled = uiAsset.alignInputs.enabled = uiAsset.alphaInputs.enabled = uiAsset.sizeInputs.enabled = _colorInputs.enabled = true;
				//applyProps();
			}
			else
			{
				uiAsset.autoFlip.enabled = uiAsset.positionInputs.enabled = uiAsset.angleInputs.enabled = uiAsset.tintInputs.enabled = uiAsset.alignInputs.enabled = uiAsset.alphaInputs.enabled = uiAsset.sizeInputs.enabled = _colorInputs.enabled = false;
				//applyProps();
			}
			applyProps();
		}
		
		
	}
	
	
}