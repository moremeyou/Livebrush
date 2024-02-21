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
	import com.livebrush.styles.StrokeStyle;
	import com.livebrush.ui.SavedStylesUI;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.LineStyleUI;
	import com.livebrush.ui.BrushPropsController;
	import com.livebrush.ui.LayersView;
	import com.livebrush.ui.SequenceList;
	import com.livebrush.ui.ColorListItem;
	import com.livebrush.ui.Tooltip;
	
	
	public class LineStyleView extends UIView
	{
		public static const EDGE_ANGLE_TYPES					:Array = [{label:"Fixed", data:StrokeStyle.FIXED},
																		  {label:"Draw Speed", data:StrokeStyle.SPEED},   
																		  {label:"Stroke Width", data:StrokeStyle.WIDTH}, 
																		  {label:"Stroke Direction", data:StrokeStyle.DIR}, 
																		  {label:"Oscillate", data:StrokeStyle.OSC}, 
																		  {label:"Rotate", data:StrokeStyle.ROTATE},
																		  {label:"Random", data:StrokeStyle.RANDOM}];
		
		public static const STROKE_TYPES						:Array = [{label:"Solid", data:StrokeStyle.SOLID_STROKE}, 
																		  {label:"Rake", data:StrokeStyle.RAKE_STROKE}, 
																		  {label:"Path", data:StrokeStyle.PATH_STROKE},
																		   {label:"None", data:StrokeStyle.NONE}];
		
		public static const WIDTH_TYPES							:Array = [{label:"Fixed", data:StrokeStyle.FIXED}, 
																		  {label:"Draw Speed", data:StrokeStyle.SPEED},
																		  {label:"Oscillate", data:StrokeStyle.OSC},
																		  {label:"Random", data:StrokeStyle.RANDOM}];
		
		public static const COLOR_TYPES							:Array = [{label:"Fixed", data:StrokeStyle.FIXED}, 
																		  {label:"Multiple", data:StrokeStyle.LIST},
																		 // {label:"Draw Speed", data:StrokeStyle.SPEED},   
																		 // {label:"Stroke Width", data:StrokeStyle.WIDTH},
																		  {label:"Brush Position", data:StrokeStyle.SAMPLE_BRUSH},
																		   {label:"Mouse Position", data:StrokeStyle.SAMPLE},
																		  {label:"Random", data:StrokeStyle.RANDOM},
																		  {label:"None", data:StrokeStyle.NONE}];
		
		public static const ALPHA_TYPES							:Array = [{label:"Fixed", data:StrokeStyle.FIXED}, 
																		  {label:"Draw Speed", data:StrokeStyle.SPEED},
																		  {label:"Stroke Width", data:StrokeStyle.WIDTH}, 
																		  {label:"Oscillate", data:StrokeStyle.OSC},
																		  {label:"Random", data:StrokeStyle.RANDOM}];
		
		public static const LINE_TYPES							:Array = [{label:"Smooth", data:StrokeStyle.SMOOTH}, 
																		  {label:"Straight", data:StrokeStyle.STRAIGHT}];		
		
		
		public var uiAsset							:LineStyleUI;
		public var brushPropsModel					:BrushPropsModel;
		private var _colorInputs					:SequenceList;
		
		public function LineStyleView (brushPropsModel:BrushPropsModel):void
		{
			super(brushPropsModel.ui);
			
			this.brushPropsModel = brushPropsModel;
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get list ():List {   return uiAsset.styleList;   }
		public function get colorInputs ():SequenceList {  return _colorInputs;   };
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function init ():void {}*/
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			
			// STYLE LIST SETUP
			uiAsset = new LineStyleUI();
			//uiAsset.styleList.allowMultipleSelection = true;
			//uiAsset.styleList.labelField = "name";
			//uiAsset.styleList.iconFunction = function(){return null}; //"name";
			
			uiAsset.lineTypeHead.label.text = "Line Type".toUpperCase();
			uiAsset.lineType.dataProvider = Settings.arrayToDataProvider(LINE_TYPES);
			
			uiAsset.strokeTypeHead.label.text = "Edge Type".toUpperCase();
			uiAsset.strokeInputs.label1 = "Lines";
			uiAsset.strokeInputs.label2 = "Weight";
			uiAsset.strokeInputs.list = STROKE_TYPES;
			uiAsset.strokeInputs.toggleInput(2, false);
			
			uiAsset.lineWidthHead.label.text = "Width".toUpperCase();
			uiAsset.widthInputs.list = WIDTH_TYPES;
			
			uiAsset.lineAngleHead.label.text = "Angle".toUpperCase();
			uiAsset.angleInputs.list = EDGE_ANGLE_TYPES;
			
			_colorInputs = new SequenceList(uiAsset.colorInputs, ColorListItem);
			uiAsset.lineColorHead.label.text = "Color".toUpperCase();
			_colorInputs.speedLabel = "Tween";
			_colorInputs.typeList = COLOR_TYPES;
			//_colorInputs.orderEditable = true;
			_colorInputs.holdInput.label = "Hold";
			_colorInputs.holdInput.min = 0;
			
			uiAsset.lineAlphaHead.label.text = "Opacity".toUpperCase();
			uiAsset.alphaInputs.list = ALPHA_TYPES;
			
			
			uiAsset.strokeInputs.setMinMax(1, 500);
			uiAsset.strokeInputs._input1.min = .25;
			uiAsset.strokeInputs._input1.max = 16;
			uiAsset.widthInputs.setMinMax(0, 1000, 1, 1000);
			uiAsset.angleInputs.setMinMax(0, 360, 1, 360);
			uiAsset.alphaInputs.setMinMax(0, 100, 1, 100);
			
			Tooltip.addTip( uiAsset.colorInputs._listEditor.addBtn, "Duplicate selected color" );
			Tooltip.addTip( uiAsset.colorInputs._listEditor.removeBtn, "Remove selected color" );
			Tooltip.addTip( uiAsset.colorInputs._listEditor.upBtn, "Move color up" );
			Tooltip.addTip( uiAsset.colorInputs._listEditor.downBtn, "Move color down" );
			
		}
		
		protected override function createController ():void
		{
			controller = new LineStyleController(this);
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function applyProps ():void
		{
			try 
			{
				uiAsset.strokeInputs._input0._input.enabled = (uiAsset.strokeInputs.type==StrokeStyle.RAKE_STROKE || uiAsset.strokeInputs.type==StrokeStyle.PATH_STROKE);
				uiAsset.strokeInputs._input1._input.enabled = uiAsset.strokeInputs._input0._input.enabled;
				
				// width, angle opacity
				uiAsset.widthInputs.speedEnabled = typeInputIsAutomatic(uiAsset.widthInputs.type);
				uiAsset.angleInputs.speedEnabled = typeInputIsAutomatic(uiAsset.angleInputs.type);
				uiAsset.alphaInputs.speedEnabled = typeInputIsAutomatic(uiAsset.alphaInputs.type);
				_colorInputs.speedEnabled = (StrokeStyle.LIST == String(_colorInputs.type));
				
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
				settings = update.data.line as Settings;
			}
		}
	
		public override function get settings ():Settings
		{
			var settings:Settings = new Settings();
			
			settings.smoothing = (uiAsset.lineType.selectedIndex==0); //smooth.selected;
			//settings.smoothing = !uiAsset.straight.selected;
			
			settings.strokeType = uiAsset.strokeInputs.type;
			settings.lines = uiAsset.strokeInputs.input0;
			settings.weight = uiAsset.strokeInputs.input1;
			
			settings.angleType = uiAsset.angleInputs.type;
			settings.minAngle = uiAsset.angleInputs.min;
			settings.maxAngle = uiAsset.angleInputs.max;
			settings.angleSpeed = uiAsset.angleInputs.speed //100;
			
			settings.widthType = uiAsset.widthInputs.type;
			settings.minWidth = uiAsset.widthInputs.min;
			settings.maxWidth = uiAsset.widthInputs.max;
			settings.widthSpeed = uiAsset.widthInputs.speed/100;
			
			settings.colorType = _colorInputs.type;
			//settings.colorList = toDataList(_colorInputs.list);
			settings.colorObjList = _colorInputs.list;
			settings.colorSteps = _colorInputs.speed;
			settings.colorHold = _colorInputs.holdInput.value;
			
			settings.alphaType = uiAsset.alphaInputs.type;
			settings.minAlpha = uiAsset.alphaInputs.min / 100;
			settings.maxAlpha = uiAsset.alphaInputs.max / 100;
			settings.alphaSpeed = uiAsset.alphaInputs.speed/100;
			
			return settings;
		}
		
		public override function set settings (settings:Settings):void
		{
			//if (settings.smoothing) uiAsset.smooth.selected = true;
			//else uiAsset.straight.selected = true;
			
			uiAsset.lineType.selectedIndex = settings.smoothing?0:1;
			
			uiAsset.strokeInputs.type = settings.strokeType;
			uiAsset.strokeInputs.input0 = settings.lines;
			uiAsset.strokeInputs.input1 = settings.weight;
			
			uiAsset.angleInputs.type = settings.angleType;
			uiAsset.angleInputs.min = settings.minAngle;
			uiAsset.angleInputs.max = settings.maxAngle;
			uiAsset.angleInputs.speed = settings.angleSpeed //*100;
			
			uiAsset.widthInputs.type = settings.widthType;
			uiAsset.widthInputs.min = settings.minWidth;
			uiAsset.widthInputs.max = settings.maxWidth;
			uiAsset.widthInputs.speed = settings.widthSpeed*100;
			
			_colorInputs.type = settings.colorType;
			_colorInputs.dataProvider = settings.colorObjList; //toObjList(settings.colorList);
			_colorInputs.speed = settings.colorSteps;
			_colorInputs.holdInput.value = settings.colorHold;
			
			uiAsset.alphaInputs.type = settings.alphaType;
			uiAsset.alphaInputs.min = settings.minAlpha*100;
			uiAsset.alphaInputs.max = settings.maxAlpha*100;
			uiAsset.alphaInputs.speed = settings.alphaSpeed*100;
			
			applyProps();
		}
		
		
		
	}
	
	
}