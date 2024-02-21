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
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	
	import com.livebrush.utils.Update;
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.data.Settings;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.SavedStylesUI;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.BrushToolPropsUI;
	import com.livebrush.ui.BrushPropsController;
	import com.livebrush.ui.LayersView;
	import com.livebrush.ui.RichList;
	import com.livebrush.ui.StyleListItem;
	import com.livebrush.ui.Tooltip;
	
	
	public class StyleListView extends UIView
	{
		public static var IDEAL_HEIGHT				:int = 237;
		
		public var panelAsset						:PanelAsset;
		public var state							:int = UI.OPEN;
		public var panel							:Sprite;
		private var titlebarMask					:PanelTitlebarMask;
		
		public var uiAsset							:SavedStylesUI;
		public var brushPropsModel					:BrushPropsModel;
		public var styleList						:RichList;
		private var _styleContextMenu				:NativeMenu
		
		public function StyleListView (ui:UI):void
		{
			super(ui);
			helpID = "styleProps";
			brushPropsModel = ui.brushPropsModel;
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function set visible (b:Boolean):void {   panel.visible=b;   }
		public function get maxY ():Number {   return (panelAsset.height+panel.y);   }
		public function get height ():Number {   return panelAsset.height;   }
		public function get styleContextMenu ():NativeMenu {   return _getStyleContextMenu();   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			_createStyleContextMenus();
			
			panel = new Sprite();
			uiAsset = new SavedStylesUI();
			titlebarMask = new PanelTitlebarMask();
			titlebarMask.visible = false;
			
			panelAsset = new PanelAsset();
			panelAsset.cacheAsBitmap = true;
			
			panel.addChild(panelAsset);
			panel.addChild(uiAsset);
			panel.addChild(titlebarMask);
			
			//UI.UI_HOLDER.addChild(panel);
			UI.WINDOW_HOLDER.addChild(panel);
			
			// STYLE LIST SETUP
			//uiAsset.styleListHead.label.text = "Styles".toUpperCase();
			//uiAsset.newStyleHead.label.text = "New Style".toUpperCase();
			
			styleList = new RichList(uiAsset["_styleList"], StyleListItem);
			styleList.uiAsset["_scrollPane"].height = 145;
			uiAsset.styleName.restrict = "^`~!@#$%&*+=/|\':;,.?{}[]<>\"";
			uiAsset.styleName.maxChars = 26;
			
			panelAsset.title.htmlText = "<b>Styles</b>";
			
			panel.y = 32;
			panelAsset.bg.height = IDEAL_HEIGHT;
			
			Tooltip.addTip( uiAsset.importBtn, "Import style" );
			Tooltip.addTip( uiAsset.exportBtn, "Export style" );
			Tooltip.addTip( uiAsset.previewBtn, "Preview style" );
			Tooltip.addTip( uiAsset.dupBtn, "Duplicate selected style" );
			Tooltip.addTip( uiAsset.removeBtn, "Remove style from project" );
			Tooltip.addTip( uiAsset.upBtn, "Move style up" );
			Tooltip.addTip( uiAsset.downBtn, "Move style down" );
			Tooltip.addTip( uiAsset.saveBtn, "Duplicate selected style" );
			
			
		}
		
		protected override function createController ():void
		{
			controller = new StyleListController(this);
		}
		
		private function _createStyleContextMenus ():void
		{
			_styleContextMenu = new NativeMenu();
			_styleContextMenu.addItem(createNativeMenuItem ("Copy Style", "copyStyle"));
			_styleContextMenu.addItem(new NativeMenuItem("", true));
			_styleContextMenu.addItem(createNativeMenuItem ("Paste Style", "pasteStyle"));
			_styleContextMenu.addItem(new NativeMenuItem("", true));
			_styleContextMenu.addItem(createNativeMenuItem ("Paste Behavior Style", "pasteBehaveStyle"));
			_styleContextMenu.addItem(createNativeMenuItem ("Paste Line Style", "pasteLineStyle"));
			_styleContextMenu.addItem(createNativeMenuItem ("Paste Deco Style", "pasteDecoStyle"));
			_styleContextMenu.addItem(createNativeMenuItem ("Paste Line Style Colors", "pasteLineColors"));
			_styleContextMenu.addItem(createNativeMenuItem ("Paste Deco Style Colors", "pasteDecoColors"));
			_styleContextMenu.addItem(createNativeMenuItem ("Paste Decorations", "pasteDecos"));
			_styleContextMenu.addItem(createNativeMenuItem ("Paste Deco Thresholds", "pasteDecoThresh"));
			
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function applyProps ():void
		{
		}
		
		public override function update (update:Update=null):void
		{
			if (update.type == UpdateEvent.WINDOW || update.type == UpdateEvent.UI)
			{
				//// // Consol.Trace("fuck twat");
				//panel.x = UI.WIDTH - panelAsset.width - (ui.panelState==UI.OPEN?ui.toolPropsView.width:0) - 42 - (ui.panelState==UI.OPEN?12:6); // 6 = padding between toolbar
				panel.x = UI.WIDTH - panelAsset.width - 42 - 6;
				//panel.y = ui.toolPropsView.maxY;
				//if (state != UI.CLOSED) panelAsset.bg.height = LayersView.IDEAL_HEIGHT
			}
			else if (update.type == UpdateEvent.BRUSH_STYLE)
			{
				settings = update.data as Settings;
			}
		}
		
		public override function set settings (data:Settings):void
		{
			styleList.dataProvider = data.styles as Array;
			//styleList.selectItems(data.styleGroup as Array);
			styleList.selectedItems = data.styleGroup as Array;
			
			applyProps();
		}
		
		public override function get settings ():Settings
		{
			var settings:Settings = new Settings();
			
			settings.styles = styleList.list;
			settings.styleGroup = styleList.selectedItems;
			
			//// // Consol.Trace("StyleListView: " + styleList.selectedItem.name + " : " + styleList.selectedItem.strokeStyle.strokeType);
			
			return settings;
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
		
		private function _getStyleContextMenu ():NativeMenu
		{
			/*var menu:NativeMenu;
			
			if (Layer.isLineLayer(activeLayer) && Tool.isTransformTool(activeTool)) 
			{
				if (TransformTool(activeTool).selectedEdges.length>0) menu = otherLayerContextMenu;
				else menu = _decoAttachInstructMenu;
			}
			else
			{
				menu = _decoAttachInstructMenu;
			}*/
			
			return _styleContextMenu;
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