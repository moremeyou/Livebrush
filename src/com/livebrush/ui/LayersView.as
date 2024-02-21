package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.display.NativeWindowDisplayState;
	import fl.controls.TextInput;
	import fl.controls.CheckBox;
	import fl.controls.ColorPicker;
	import flash.text.TextField;
	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;
	import flash.display.BlendMode;
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	
	import com.livebrush.utils.Update;
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.data.Settings;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.ui.UI;
	import com.livebrush.tools.Tool;
	import com.livebrush.tools.TransformTool;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.LayerPropsUI;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.PanelAsset;
	import com.livebrush.ui.LayersController;
	import com.livebrush.ui.ToolPropsView;
	import com.livebrush.ui.RichList;
	import com.livebrush.ui.RichListUI;
	import com.livebrush.ui.LayerListItem;
	import com.livebrush.ui.TypeInputVertical;
	import com.livebrush.ui.PropInputVertical;
	import com.livebrush.ui.ColorInput;
	//import com.livebrush.ui.ColorListItem;
	import com.livebrush.ui.Tooltip;
	
	
	public class LayersView extends UIView
	{
		
		public static var IDEAL_HEIGHT				:int = 345;
		
		public var panelAsset						:PanelAsset;
		public var state							:int = UI.OPEN;
		public var uiAsset							:LayerPropsUI;
		public var panel							:Sprite;
		private var titlebarMask					:PanelTitlebarMask;
		public var layersList						:RichList;
		public var blendInput						:TypeInputVertical;
		public var color							:ColorPicker;
		public var tintInput						:PropInputVertical;
		public var alphaInput						:PropInputVertical;
		public var colorInput						:ColorInput;
		private var _lineLayerContextMenu			:NativeMenu;
		public var otherLayerContextMenu			:NativeMenu;
		private var _decoAttachInstructMenu         :NativeMenu;
		
		public function LayersView (ui:UI):void
		{
			super(ui);
			helpID = "layerProps";
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function set visible (b:Boolean):void {   panel.visible=b;   }
		public function get height ():Number {   return panelAsset.height;   }
		public function get layerContextMenu ():NativeMenu {   return _getLayerContextMenu();   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function init ():void {}*/
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			_createLayerContextMenus();
			
			panel = new Sprite();
			uiAsset = new LayerPropsUI();
			titlebarMask = new PanelTitlebarMask();
			titlebarMask.visible = false;
			
			panelAsset = new PanelAsset();
			panelAsset.cacheAsBitmap = true;
			
			panel.addChild(panelAsset);
			panel.addChild(uiAsset);
			panel.addChild(titlebarMask);
			
			UI.UI_HOLDER.addChild(panel);
			
			layersList = new RichList(uiAsset["_layersList"], LayerListItem, 40);
			layersList.uiAsset["_scrollPane"].height = 240;
			layersList.uiAsset["_scrollPane"].width = 283;
			layersList.uiAsset["_scrollPane"].verticalScrollPolicy = ScrollPolicy.ON;
			
			blendInput = uiAsset["_blendInput"];
			blendInput.label = "Blend Mode";
			blendInput.list = [{label:"Normal", data:BlendMode.LAYER},
								{label:"Multiply", data:BlendMode.MULTIPLY},
								{label:"Darken", data:BlendMode.DARKEN},
								{label:"Lighten", data:BlendMode.LIGHTEN},
								{label:"Screen", data:BlendMode.SCREEN},
								{label:"Add", data:BlendMode.ADD},
								{label:"Subtract", data:BlendMode.SUBTRACT},
								{label:"Difference", data:BlendMode.DIFFERENCE},
								{label:"Invert", data:BlendMode.INVERT}];
			
			alphaInput = uiAsset["_alphaInput"]
			alphaInput.label = "Opacity";
			tintInput = uiAsset["_tintInput"]
			tintInput.label = "Color";
			colorInput = uiAsset["_colorInput"];
			
			panelAsset.title.htmlText = "<b>Layers</b>";
			
			panel.y = 665; //684;
			panelAsset.bg.height = IDEAL_HEIGHT;
			
			uiAsset.y = 30;
			
			Tooltip.addTip( uiAsset.upBtn, "Move layer up" );
			Tooltip.addTip( uiAsset.downBtn, "Move layer down" );
			Tooltip.addTip( uiAsset.copyBtn, "Duplicate layer" );
			Tooltip.addTip( uiAsset.flatBtn, "Flatten selected layers" );
			Tooltip.addTip( uiAsset.removeBtn, "Remove layer" );
			Tooltip.addTip( uiAsset.addBtn.addBtn, "Add new bitmap layer" );
			
		}
		
		protected override function createController ():void
		{
			controller = new LayersController(this);
		}
		
		private function _createLayerContextMenus ():void
		{
			_lineLayerContextMenu = new NativeMenu();
			_lineLayerContextMenu.addItem(new NativeMenuItem("Copy Edge Deco(s) to Layer(s)", false));
			//_lineLayerContextMenu.addItem(new NativeMenuItem("Detach Edge Deco(s) to Layer(s)", false));
			_lineLayerContextMenu.addItem(new NativeMenuItem("Remove All Edge Decorations", false));
			
			otherLayerContextMenu = new NativeMenu();
			otherLayerContextMenu.addItem(createNativeMenuItem ("Copy Layer To Line", "copyLayerToDeco"));
			//otherLayerContextMenu.addItem(createNativeMenuItem ("Attach Layer To Line", "layerToDeco"));
			otherLayerContextMenu.addItem(createNativeMenuItem ("Copy Layer To Line In-Place", "iCopyLayerToDeco"));
			//otherLayerContextMenu.addItem(createNativeMenuItem ("Attach Layer To Line In-Place", "iLayerToDeco"));
			
			_decoAttachInstructMenu = new NativeMenu();
			var item:NativeMenuItem = createNativeMenuItem ("Use the Transform Tool to Select Line Edges");
			item.enabled = false;
			_decoAttachInstructMenu.addItem(item);
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function applyProps ():void
		{
			try 
			{
				//// // Consol.Trace("LayersView.applyProps (selectedIndex) : " + layersList.selectedIndex);
				//// // Consol.Trace("LayersView.applyProps : " + layersList.selectedItem.alpha);
				//uiAsset.strokeInputs._input0._input.enabled = (uiAsset.strokeInputs.type==StrokeStyle.RAKE_STROKE || uiAsset.strokeInputs.type==StrokeStyle.PATH_STROKE);
				//uiAsset.strokeInputs._input1._input.enabled = uiAsset.strokeInputs._input0._input.enabled;
				//// // Consol.Trace(layersList.selectedItem.alpha);
				blendInput.value = layersList.selectedItem.blendMode;
				alphaInput.value = int(layersList.selectedItem.alpha * 100)//Math.floor(layersList.selectedItem.alpha * 100);
				tintInput.value = int(layersList.selectedItem.colorPercent * 100)//Math.floor(layersList.selectedItem.colorPercent * 100);
				colorInput.color = layersList.selectedItem.color;
				layersList.bottomRichItem.lockUI();
				
				if (Layer.isBackgroundLayer(layersList.selectedItem as Layer))
				{
					blendInput.enabled = false;
					alphaInput.enabled = false;
					tintInput.enabled = false;
				}
				else
				{
					blendInput.enabled = true;
					alphaInput.enabled = true
					tintInput.enabled = true;
				}
				
			}
			catch (e:Error)
			{
			}
		}
		
		public override function get settings ():Settings
		{
			var settings:Settings = new Settings();
			
			settings.layers = layersList.list;
			settings.selectedLayerDepths = getSelectedLayerDepths();
			
			return settings;
		}

		public override function set settings (settings:Settings):void
		{
			var i:int
			
			layersList.dataProvider = settings.layers.slice().sortOn("depth", Array.NUMERIC | Array.DESCENDING);
			
			/*for (i=0; i<settings.layers.length; i++) 
			{
				// // Consol.Trace(">>> LAYER (" + settings.layers[i].label + ") alpha : " + settings.layers[i].alpha);
			}*/
			
			var selectedIndices:Array = [];
			for (i=0; i<settings.activeLayerDepths.length; i++) 
			{
				selectedIndices.push(Settings.idToIndex(settings.activeLayerDepths[i].toString(), layersList.list, "depth"))
			}
			layersList.selectedIndices = selectedIndices;
			
			applyProps();
			
		}
		
		public override function update (update:Update=null):void
		{
			if (update.type == UpdateEvent.WINDOW || update.type == UpdateEvent.UI)
			{
				panel.x = UI.WIDTH - panelAsset.width - 42 - 6; // 6 = padding between toolbar
				panel.y = ui.toolPropsView.maxY;
				if (state != UI.CLOSED) panelAsset.bg.height = LayersView.IDEAL_HEIGHT
			} 
			else if (update.type == UpdateEvent.LAYER)
			{
				settings = Settings(update.data);
			}
			else if (update.type == UpdateEvent.COLOR)
			{
				//applyProps();
			}
			else if (update.type == UpdateEvent.DRAW_MODE)
			{
				//// Consol.Trace("LayersView: update > DRAW_MODE : " + update.data.mode);
				if (update.data.mode == 0) {
					uiAsset.addBtn.alpha = .35;
					uiAsset.addBtn.enabled = uiAsset.addBtn.mouseChildren = uiAsset.addBtn.mouseEnabled = false;
				} else {
					uiAsset.addBtn.alpha = 1;
					uiAsset.addBtn.enabled = uiAsset.addBtn.mouseChildren = uiAsset.addBtn.mouseEnabled = true;
				}
			}
			
		}
		
		public function toggle (force:Boolean=false):void
		{
			state = ((state==UI.CLOSED || force) ? UI.OPEN : UI.CLOSED);
			if (state == UI.CLOSED) 
			{
				panelAsset.bg.height = 22;
				uiAsset.mask = titlebarMask;
			}
			else 
			{
				panelAsset.bg.height = IDEAL_HEIGHT;
				uiAsset.mask = null;
			}
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function getSelectedLayerDepths ():Array
		{
			var selectedLayerDepths:Array = [];
			var selectedItems:Array = layersList.selectedItems;
			for (var i:int=0; i<layersList.selectedIndices.length; i++) 
			{
				selectedLayerDepths.push(selectedItems[i].depth);
			}
			return selectedLayerDepths;
		}
		
		private function _getLayerContextMenu ():NativeMenu
		{
			var menu:NativeMenu;
			
			if (Layer.isLineLayer(activeLayer) && Tool.isTransformTool(activeTool)) 
			{
				if (TransformTool(activeTool).selectedEdges.length>0) menu = otherLayerContextMenu;
				else menu = _decoAttachInstructMenu;
			}
			else
			{
				menu = _decoAttachInstructMenu;
			}
			
			return menu;
		}
		
		private function createNativeMenuItem (label:String, name:String="", primKey:String="", isSeparator:Boolean=false):NativeMenuItem
		{
			var item:NativeMenuItem = new NativeMenuItem(label, isSeparator);
			item.name = name;
			/*if (primKey == "BACKSPACE") 
			{
				// not working
				item.keyEquivalentModifiers = [Keyboard.BACKSPACE];
				item.keyEquivalent = "";
			}
			else if (primKey != "") 
			{
				item.keyEquivalent = primKey;
			}*/
			//menuItemNames.push(item.name);
			//menuItems.push(item);
			return item;
		}

		
	}
	
	
}