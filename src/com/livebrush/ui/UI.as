package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.EventPhase;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.StageDisplayState;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.display.NativeWindowDisplayState
	
	import com.livebrush.utils.Update;
	import com.livebrush.data.GlobalSettings;
	import com.livebrush.data.FileManager;
	import com.livebrush.data.Settings;
	import com.livebrush.ui.*;
	//import com.livebrush.ui.Dialog;
	import com.livebrush.tools.*;
	import com.livebrush.events.*;
	import com.livebrush.Main;
	import com.livebrush.styles.StyleManager;
	import com.livebrush.tools.ToolManager;
	import com.livebrush.graphics.canvas.CanvasManager
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.StylePreviewLayer;
	import com.livebrush.data.Help;
	import com.livebrush.data.StateManager;
	import com.livebrush.tools.Tool;
	
	
	public class UI extends UIModel
	{
		
		public static const WINDOW_MENU_HEIGHT		:int = 19;
		
		public static const OPEN					:int = 1;
		public static const CLOSED					:int = 0;
		public static const CONSOL_DEPTH			:int = 2;
		public static var UI_HOLDER					:Sprite;
		public static var DIALOG_HOLDER				:Sprite;
		public static var WINDOW_HOLDER				:Sprite;
		public static var PREVIEW_HOLDER			:Sprite;
		public static var MAIN_UI					:UI;
		public static var TOOLTIP_HOLDER			:Sprite;
		public static var TOP_UI_HOLDER				:Sprite;
		
		public static var HEIGHT					:int = 1280;
		public static var WIDTH						:int = 1024;
		
		public var titlebarView						:TitlebarView;
		public var toolbarView						:ToolbarView;
		public var toolPropsView					:ToolPropsView;
		public var layersView						:LayersView;
		public var styleListView					:StyleListView;
		
		public var brushPropsModel					:BrushPropsModel;
		public var brushPropsView					:BrushPropsView;
		public var emptyPropsView					:EmptyPropsView;
		public var transformPropsView				:TransformPropsView;
		public var bucketPropsView					:BucketPropsView;
		public var samplePropsView					:SamplePropsView;
		public var globalColorView					:GlobalColorView;
		
		public var consol							:Consol;
		public var visibleState						:Number = 0;
		public var canvasManager					:CanvasManager;
		public var styleManager						:StyleManager;
		public var toolManager						:ToolManager;
		public var contextMenu						:ContextMenuView;
		private var holder							:Sprite;
		private var mainMenu						:MainMenuView;
		private var _state							:int; // = FULL_MODE;
		public var main								:Main;
		public var panelState						:int = OPEN;
		public var projectLoadDialog				:Dialog;
		public var globalSettingsView				:GlobalSettingsView;
		public var aboutView						:BasicWindowView;
		public var newProjectView					:NewProjectView;
		public var saveImageView					:SaveImageView;
		//public var aboutView						:BasicWindowView;
		public var registeredDialogIDList			:Array;
		public var locked							:Boolean = false;
		public var windowDialogHolder				:Sprite;
		private var _stateManLocked					:Boolean = true;
		private var stylePreviewHolder				:Sprite;
		private var activeTool						:Tool;
		private var onCanvas						:Boolean = true;
		private var tooltipHolder					:Sprite;
		public var canvasWindow						:NativeWindow = null;
		private var forceCanvasWindowClose			:Boolean = false;
		
		
		public function UI (owner:Main):void
		{
			super()
			
			main = owner;
			
			stylePreviewHolder = PREVIEW_HOLDER = Sprite(main.addChild(new Sprite()));
			
			
			// putting this here is less than ideal. because then the whole ui will be above dialogs and alerts
			// but this will only be apparent if they have a small screen. don't disable drag, because they'd need to if they can't see.
			windowDialogHolder = DIALOG_HOLDER = WINDOW_HOLDER = Sprite(main.addChild(new Sprite()));
			
			holder = Sprite(owner.addChild(new Sprite()));
			
			TOP_UI_HOLDER = Sprite(main.addChild(new Sprite()));
			
			tooltipHolder = TOOLTIP_HOLDER = Sprite(main.addChild(new Sprite()));
			
			UI_HOLDER = holder;
			
			MAIN_UI = this;
			
			registeredDialogIDList = [];
			
			//main.stageFocusRect = false;
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get canvas ():Canvas {   return canvasManager.canvas;   }
		public function get activeLayer ():Layer {   return canvasManager.activeLayer;   }
		public function get activeLayers ():Array {   return canvasManager.activeLayers;   }
		public function get state ():int { return _state; }
		public static function get centerX ():Number {   return UI.MAIN_UI.main.stage.stageWidth/2;   }
		public static function get centerY ():Number {   return UI.MAIN_UI.main.stage.stageHeight/2;   }
		public static function get windowCenter ():Point {   return new Point(centerX, centerY);   }
		public function set state (s:int):void
		{
			_state = s;
			/*switch (s) 
			{
				case UI.FULL_MODE:
					toolbar.visible = layersPanel.visible = stylePanelGroup.visible = true;
				break;
				case UI.MID_MODE:
					toolbar.visible = true;
					layersPanel.visible = stylePanelGroup.visible = false;
				break;
				case UI.HIDE_MODE:
					toolbar.visible = layersPanel.visible = stylePanelGroup.visible = false;
				break;
			}*/
		}
		
		
		// SETUP ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function initCanvasDependantViews ():void
		{
			main.stage.nativeWindow.maximize(); // possibly just for debug
			
			contextMenu = ContextMenuView(registerView(new ContextMenuView(this)));
			
			
			canvas.addEventListener(MouseEvent.MOUSE_DOWN, canvasMouseDown);
			canvas.addEventListener(MouseEvent.MOUSE_OVER, canvasMouseDown);
			
			pushColorProps(globalColorView.settings);
			//styleManager.lockColors(false);
			//setTimeout(pushColorProps, 1000, globalColorView.settings);
			//setTimeout(styleManager.lockColors, 1100, false);
			
			//new Dialog(Dialog.LOADING, {message:"Yo dawg!"});
			//var d:Dialog = new Dialog(Dialog.QUESTION, {message:"aww hell na dawg."});
			//openWindow(GlobalSettingsView);
			
			/*var settings:NativeWindowInitOptions = new NativeWindowInitOptions();
			//settings.maximizable = false;
			//settings.minimizable = false;
			settings.resizable = false;
			settings.systemChrome = NativeWindowSystemChrome.STANDARD;
			settings.transparent = false;
			//settings.owner = main.stage.nativeWindow;
			
			var newWindow:NativeWindow = new NativeWindow(settings);
			newWindow.title = "A title";
			newWindow.width = 600;
			newWindow.height = 400;
			
			newWindow.stage.align = StageAlign.TOP_LEFT;
			newWindow.stage.scaleMode = StageScaleMode.NO_SCALE;
			//newWindow.activate();*/
		}
		
		private function init ():void
		{
			
			
			setupAppWindow();
			
			Tooltip.getInstance();
			
			holder.stage.addEventListener (Event.RESIZE, resizeListener);
			
			brushPropsModel = new BrushPropsModel(this);
			
			// CREATE VIEWS
			styleListView = StyleListView(registerView(new StyleListView(this)));
			transformPropsView = TransformPropsView(registerView(new TransformPropsView(this)));
			emptyPropsView = EmptyPropsView(registerView(new EmptyPropsView(this)));
			bucketPropsView = BucketPropsView(registerView(new BucketPropsView(this)));
			samplePropsView = SamplePropsView(registerView(new SamplePropsView(this)));
			brushPropsView = BrushPropsView(registerView(brushPropsModel.brushPropsView));
			toolPropsView = ToolPropsView(registerView(new ToolPropsView(this)));
			layersView = LayersView(registerView(new LayersView(this)));
			toolbarView = ToolbarView(registerView(new ToolbarView(this)));
			titlebarView = TitlebarView(registerView(new TitlebarView(this)));
			globalColorView = GlobalColorView(registerView(new GlobalColorView(this)));
			
			
			// FILE MENU
			mainMenu = MainMenuView(registerView(new MainMenuView(this)));
			//mainMenu.addEventListener(Event.SELECT, mainMenuEventHandler);
			holder.addEventListener(MouseEvent.MOUSE_DOWN, guiMouseDown);
			styleListView.panel.addEventListener(MouseEvent.MOUSE_DOWN, guiMouseDown);
			
			
			
			// CONSOL (DEBUG)
			/*consol = new Consol();
			showConsol();
			consol.x = 10;
			consol.y =  main.stage.stageHeight -consol.height-8;*/
			
			setStatus ("Loading...");
			
			toggle(false);
			
			resizeInterface();
			//setTimeout(resizeInterface, 5000);
			
			
			
			//toggleToolProps(); // this is for final
			// for debug
			//layersView.toggle();
			//styleListView.toggle();
			
			createCanvasWindow();
			
			//canvasWindow.menu = mainMenu.mainMenu;
			// works, but the menu is all wierd and ghosted
			
		}
		
		private function setupAppWindow ():void
		{
			main.stage.scaleMode = StageScaleMode.NO_SCALE;
			main.stage.align = StageAlign.TOP_LEFT;
			main.stage.nativeWindow.x = 50
			main.stage.nativeWindow.y = 40;
			main.stage.nativeWindow.minSize = new Point(1280,700);
			
			//main.stage.nativeWindow.maximize(); // can't do this here, or yet
			// because the canvas also needs to be updated when we maximize
			// but this event is on the canvas object
			// this stuff should be centralized. events from the ui
			// canvas view listens for ui events
		
		}
		
		public function enableWacom ():void
		{
			brushPropsModel.enabledTabletInput();
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function mainMenuEvent (e:Event):void
		{
			// these should all be events!
			
			//// // Consol.Trace("UI: mainMenuEvent, StateManager.state = " + StateManager.state);
			//// // Consol.Trace("UI: mainMenuEvent, !locked = " + !locked);
			//// // Consol.Trace("UI: mainMenuEvent, !toolManager.activeTool.isRunning = " + !toolManager.activeTool.isRunning);
			//// // Consol.Trace("UI: mainMenuEvent, registeredDialogIDList.length==0 = " + (registeredDialogIDList.length==0));
			//case "saveImageWeb": main.saveAsImage(0); break;
			//case "saveImageHigh": main.saveAsImage(1); break;
			//case "saveImagePrint": main.saveAsImage(2); break;
			//case "saveImagePub": main.saveAsImage(3); break;
																									// || e.target.name=="save" 
			if (((StateManager.state == StateManager.CLOSED && !toolManager.activeTool.isRunning) || e.target.name=="togglePreview") 
				&& (registeredDialogIDList.length==0 && !locked) || e.target.name=="stopAllBrushes" || e.target.name=="stopLastBrush")
			{
			
				switch (e.target.name) 
				{
					case "new": main.saveFirst(main.newProject); break;
					//case "new": main.saveFirst(showNewProject); break;
					case "open": main.openProject(); break;
					case "save": main.saveProject(); break;
					case "saveAs": main.saveProjectAs(); break;
					//case "saveImage": saveImage(); break;
					//case "saveLayerImage": saveLayerImage(); break;
					case "saveImage": main.saveAsImage(0,true); break;
					case "saveLayerImage": main.export(FileManager.LAYER_IMAGE); break;
					
					case "revert": main.revertProject(); break;
					case "cleanup": 
						confirmActionDialog({message:"This action removes project assets that are not being used. This action cannot be undone.\nWould you like to continue?",
											 yesFunction:main.cleanupProject, id:"cleanupConfirm"});
					break;
					case "exit": main.exit(); break;
					
					case "importProject": 
						confirmActionDialog({message:"This action will also cause your undo-history to be reset.\n\nWould you like to continue?",
											   yesFunction:main.importToProject, yesProps:[FileManager.PROJECT], id:"importConfirm"});
						//main.importToProject(FileManager.PROJECT); 
					break;
					case "importDeco": main.importToProject(FileManager.DECO); break;
					case "importDecoSet": main.importToProject(FileManager.DECOSET); break;
					case "importImage": 
						confirmActionDialog({message:"This action will also cause your undo-history to be reset.\n\nWould you like to continue?",
											   yesFunction:main.importToProject, yesProps:[FileManager.LAYER_IMAGE], id:"importConfirm"});
						//main.importToProject(FileManager.LAYER_IMAGE); 
					break;
					case "importStyle": main.importToProject(FileManager.STYLE); break;
					case "importInputSWF": main.importInputSWF(); break;
					
					case "exportSVG": main.export(FileManager.SVG); break;
					
					case "exportDecoSet": main.export(FileManager.DECOSET); break;
					case "exportStyle": main.export(FileManager.STYLE); break;
					case "exportLayer": main.export(FileManager.LAYER_IMAGE); break;
					
					case "undo": activeTool=toolManager.activeTool; StateManager.stepBack(); toolManager.setTool(activeTool); break;
					case "redo": activeTool=toolManager.activeTool; StateManager.stepForward(); toolManager.setTool(activeTool); break;
					case "cut": canvasManager.copyContent(true); break;
					case "copy": canvasManager.copyContent(); break;
					case "paste": canvasManager.pasteContent(); break;
					case "delete": canvasManager.deleteContent(); break;
					
					case "selectAll": canvasManager.selectAll(); break;
					case "deselectAll": canvasManager.deselectAll(); break;
			
					case "showGlobalPrefs": showGlobalPrefs(); break;
					
					case "flattenLayers": canvasManager.flattenLayers(); break;
					case "dupLayer": canvasManager.dupLayer(canvasManager.activeLayerDepth); break;
					case "applyStyle": canvasManager.applyLineStyle(); break;
					case "simplifyLine": canvasManager.simplifyLine(); break;
					case "subdivideLine": canvasManager.subdivideLine(); break;
					case "toStraightLine": canvasManager.convertLine(false); break;
					case "toSmoothLine": canvasManager.convertLine(true); break;
					case "redrawLayers": canvasManager.refreshLayers(); break;
					
					case "copyEdgeDecos": 
						confirmActionDialog({message:"This action will also cause your undo-history to be reset.\nThe source layers will remain intact.\nWould you like to continue?",
											   yesFunction:canvasManager.detachEdgeDecosToLayers, yesProps:[true], id:"detachConfirm"});
						//canvasManager.detachEdgeDecosToLayers(true); 
					break;
					case "removeEdgeDecos": canvasManager.removeEdgeDecos(); break;
					// commented this out because it removes the line decos, and then there's no easy easy way to return them
					// better to make them copy to layers and then remove
					//case "detachEdgeDecos":
						//confirmActionDialog({message:"This action will clear your undo history.\nYou will be able to restore the source layer only.\nWould you like to continue?",
											// yesFunction:canvasManager.detachEdgeDecosToLayers, yesProps:[false], id:"detachConfirm"})
						//canvasManager.detachEdgeDecosToLayers(false); 
					break;
					case "layerToDeco": canvasManager.layerToDeco(canvasManager.activeLayerDepth+1, false, false); break;
					case "copyLayerToDeco": canvasManager.layerToDeco(canvasManager.activeLayerDepth+1, true, false); break;
					case "iLayerToDeco": canvasManager.layerToDeco(canvasManager.activeLayerDepth+1, false); break;
					case "iCopyLayerToDeco": canvasManager.layerToDeco(canvasManager.activeLayerDepth+1, true); break;
					
					case "rotateClock": canvasManager.rotateLayer(90); break;
					case "rotateCounter": canvasManager.rotateLayer(-90); break;
					case "flipX": canvasManager.flipLayer(-1, 1); break;
					case "flipY": canvasManager.flipLayer(1, -1); break;
					case "resetScale": canvasManager.resetLayerTransform(true, false, false); break;
					case "resetRotation": canvasManager.resetLayerTransform(false, true, false); break;
					case "resetSkew": canvasManager.resetLayerTransform(false, false, true); break;
					case "resetTransform": canvasManager.resetLayerTransform(); break;
					
					case "styleDecoToLayer": canvasManager.styleDecoToLayer(); break;
					case "layersToDeco": canvasManager.layersToStyleDeco(); break;
					
					case "toggleStyleList": styleListView.toggle(); uiUpdate(); break;
					case "stylePreview": toggleStylePreview(); break;
					case "toggleToolProps": toggleToolProps(); break;
					case "toggleLayerProps": layersView.toggle(); uiUpdate(); break;
					
					case "toggleFullScreen": toggleFullScreen(); break;
					case "toggleUI": toggleUI(); break;
					case "toggleCanvasWindow": toggleCanvasWindow(); break;
					
					case "stopAllBrushes": canvasManager.toolManager.brushTool.stopAllBrushes(); break;
					case "stopLastBrush": canvasManager.toolManager.brushTool.stopLastBrush(); break;
					
					case "shareStyles": FileManager.getURL(Main.FORUM_STYLES_LINK); break;
					case "develop": FileManager.getURL(Main.FORUM_DEVELOP_LINK); break;
					case "facebook": FileManager.getURL(Main.FACEBOOK_LINK); break;
					case "twitter": FileManager.getURL(Main.TWITTER_LINK); break;
					
					case "zoomIn": canvasZoom(.25); break;
					case "zoomOut": canvasZoom(-.25); break;
					// this will be calling a ui function. that will also update the titlebar (or wherever we put the zoomer)
					
					case "helpLink": loadHelp("main"); break;
					case "supportLink": FileManager.getURL(Main.SUPPORT_LINK); break;
					case "feedbackLink": FileManager.getURL(Main.SUPPORT_LINK); break;
					case "forumLink": FileManager.getURL(Main.FORUM_LINK); break;
					case "homeLink": FileManager.getURL(Main.HOME_LINK); break;
					case "checkForUpdates": FileManager.checkForUpdates(true); break;
					case "about": showAbout(); break;
				}
			
			}
			else
			{
				busyAlert();
			}
			
		}
		
		public function fileIO (e:FileEvent):void
		{
			if (e.action == FileEvent.OPEN || e.action == FileEvent.BATCH_OPEN)
			{
				var data:XML;
				switch (e.fileType)
				{
					case FileManager.PROJECT :
						//toggle(false)
					break;
					/*case FileManager.STYLE :
						styleManager.setStyleXML(new XML(e.data), (fileManager.lastFileLoaded==FileManager.STYLE));
					break;
					case FileManager.DECO :
						styleManager.activeStyle.decoStyle.addDeco(new File(e.data.url).name);
					break;
					case FileManager.LAYER_IMAGE :
						//canvasManager.addLayer(Layer.newImageLayer(canvas, String(e.data)));
						canvasManager.addImageLayer(String(e.data), (e.action == FileEvent.BATCH_OPEN));
					break;
					case FileManager.SWF :
						canvasManager.addSWFLayer(String(e.data), (e.action == FileEvent.BATCH_OPEN));
					break;*/
				}
			}
		}
		
		private function resizeListener (e:Event):void
		{
			resizeInterface();
		}
		
		private function guiMouseDown (e:MouseEvent):void
		{
			if (onCanvas)
			{	
				onCanvas = false;
				mainMenu.toggleEditShortcuts(onCanvas);
			}
			//// // Consol.Trace("UI: guiMouseDown: onCanvas = " + onCanvas);
			//if (locked)
			if (!holder.mouseChildren) 
			{
				//alert({message:"Processing your last request. Please wait.", id:"busyAlert"});
				busyAlert(true);
			}
		}
		
		private function canvasMouseDown (e:MouseEvent):void
		{
			//if (e.target == canvas || canvas.pointWithinCanvas(e.stageX, e.stageY))
			//{
			if (!onCanvas)
			{
				onCanvas = true;
				mainMenu.toggleEditShortcuts(onCanvas);
			}
				
			//}
			//// // Consol.Trace("UI: canvasMouseDown: onCanvas = " + onCanvas);
		}
		
		/*private function canvasMouseOver (e:MouseEvent):void
		{
			//onCanvas = true;
			//mainMenu.toggleCopyPaste(onCanvas);
			//// // Consol.Trace("UI: canvasMouseOver: onCanvas = " + onCanvas);
			
		}
		private function canvasMouseOut (e:MouseEvent):void
		{
			//onCanvas = false;
			//mainMenu.toggleCopyPaste(onCanvas);
			//// // Consol.Trace("UI: canvasMouseOut: onCanvas = " + onCanvas);
			
		}*/
		
		//canvasWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, canvasWindowStateListener);
			
		
		
		private function canvasWindowClosingListener (e:Event):void
		{
			if (!forceCanvasWindowClose) 
			{
				e.preventDefault();
				closeCanvasWindow();
			}
		}
		
		private function canvasWindowCloseListener (e:Event):void
		{
			main.addChildAt(canvasManager.canvasView.canvas, 0);
		}
		
		private function canvasWindowStateListener (e:NativeWindowDisplayStateEvent):void
		{
			if (canvasWindow.displayState == NativeWindowDisplayState.MAXIMIZED) canvasWindow.stage.displayState = StageDisplayState.FULL_SCREEN;
			//main.stage.displayState = (main.stage.displayState==StageDisplayState.FULL_SCREEN_INTERACTIVE ? StageDisplayState.NORMAL : StageDisplayState.FULL_SCREEN_INTERACTIVE);
			
		}
		
	
		// TOGGLES //////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function toggleCanvasWindow ():void
		{
			//toolManager.setTool(toolManager.brushTool);
			
			if (canvasWindow.visible) closeCanvasWindow();
			else openCanvasWindow();
		}
		
		public function toggleGlobalColor ():void
		{
			//// Consol.Trace("UI: toggleGlobalColor");
			globalColorView.toggle();
		}
		
		public function toggleDrawMode (mode:int):void
		{
			//// Consol.Trace("UI: toggleDrawMode: " + mode);
			
			GlobalSettings.DRAW_MODE = mode;
			
			update(Update.drawModeUpdate({mode:mode}));
		}
		
		public function toggleFullScreen ():void
		{
			main.stage.displayState = (main.stage.displayState==StageDisplayState.FULL_SCREEN_INTERACTIVE ? StageDisplayState.NORMAL : StageDisplayState.FULL_SCREEN_INTERACTIVE);
			//main.stage.focus = main.stage;
		}
		
		public function toggleUI ():void
		{
			holder.visible = !holder.visible;
			globalColorView.visible = holder.visible;
		}
		
		public function toggleToolProps ():void
		{
			if (panelState == OPEN) toolPropsView.toggle();
			else toolPropsView.toggle(true);
			togglePropsPanel(true);
			updateViews(Update.uiUpdate());
		}
		
		public function toggle (b:Boolean, mainMenuToggle:Boolean=true, canvasToggle:Boolean=true, guiToggle:Boolean=true):void
		{
			//// // Consol.Trace("UI: toggle> " + b);
			//Main(holder.parent).enabled = b;
			//main.enabled = main.mouseChildren = b;
			locked = !b;
			try { if (canvasToggle) canvasManager.canvas.mouseChildren = b; } catch (e:Error){}
			if (guiToggle) {
				TOP_UI_HOLDER.mouseChildren = b;
				holder.mouseChildren = b;
			}
			if (mainMenuToggle) mainMenu.toggle(b);
			try { 
				// Do we even need to lock the state man on dialogs?
				// we really just need to lock inputs. and i think we're already doing that.
				/*if (!toolManager.activeTool.isRunning)
				{
					if (b && !_stateManLocked) StateManager.unlock(this);
					else if (!b) StateManager.lock();
					//if (b) StateManager.unlock();
					//else StateManager.lock();
					_stateManLocked = StateManager.global.locked;
				}*/
			} catch (e:Error){}
			
		}
		
		// if (canvasManager.stylePreviewLayer.visible) toggleStylePreview();
		public function toggleStylePreview ():void
		{
			//toggle(canvasManager.stylePreviewLayer.visible, false, true, false)
			//// // Consol.Trace("UI: toggleStylePreview> " + windowDialogHolder.numChildren);
			//if (StateManager.state == StateManager.CLOSED && !toolManager.activeTool.isRunning 
				//) //&& (canvasManager.stylePreviewLayer.visible)) // stylePreviewHolder.numChildren == 0 || 
			//{
				canvasManager.stylePreviewLayer.toggle();
				if (canvasManager.stylePreviewLayer.visible) canvas.lockContent();
				else canvas.unlockContent(true);
				
				//toggle(!canvasManager.stylePreviewLayer.visible); // can't toggle all, because we have to be able to edit styles
				// but we should disable the canvas
			//}
		}
		
		public function togglePropsPanel (force:Boolean=false):void
		{
			//// // Consol.Trace("ui: toggle props panel");
			panelState = ((panelState==CLOSED || force) ? OPEN : CLOSED);
			toolPropsView.visible = (panelState==OPEN);
			layersView.visible = (panelState==OPEN);
			styleListView.visible = (panelState==OPEN);
			updateViews(Update.uiUpdate());
		}
		
		public function showToolProps (toolProps:UIView):void
		{
			if (toolProps != null) 
			{
				toolPropsView.setContent(toolProps["uiAsset"]);
				// this should be where we get the new content for the tool props
			}
		}
		
		
		// PUBLIC ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function canvasZoom(amount:Number, abs:Boolean=false):void
		{
			canvas.canvasZoom(Math.max(Canvas.MIN_ZOOM, Math.min(Canvas.MAX_ZOOM, abs?amount:canvas.zoomAmount+amount))); 
			
			toolManager.resetTool();
			updateViews(Update.uiUpdate());
			// case "zoomIn": canvas.canvasZoom(Math.min(Canvas.MAX_ZOOM, canvas.zoomAmount+.25)); break;
			// case "zoomOut": canvas.canvasZoom(Math.max(Canvas.MIN_ZOOM, canvas.zoomAmount-.25)); break;
		}
		
		public static function setStatus (s:String):void
		{
			UI.MAIN_UI.titlebarView.status = s;
		}
		
		public function toolSelect (toolName:String):void
		{
			toolManager.setToolByName(toolName);
			showToolProps(getToolPropsByName(toolName));
		}
		
		public function selectTool (toolName:String):void
		{
			toolbarView.toggleTool(toolbarView.getBtnByToolName(toolName).name);
			showToolProps(getToolPropsByName(toolName));
		}
		
		public function resizeInterface ():void
		{
			WIDTH = holder.stage.stageWidth;
			HEIGHT = holder.stage.stageHeight;

			updateViews(Update.windowUpdate());
			
			
			//border.width = stageWidth;
			//border.height = stageHeight;

			//stylePanelGroup.x = stageWidth-250-36;
			//stylePanelGroup.styleBar.bg.height = stageHeight - 50;
		}
		
		public function setProject (name:String):void
		{
			updateViews(Update.projectUpdate({project:name}));
		}
		
		public function loadHelp (id:String):void
		{
			if (id != "") Help.loadHelp(id)
		}
		
		
		// WINDOWS & DIALOGS ////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function createCanvasWindow ():void
		{
			var settings:NativeWindowInitOptions = new NativeWindowInitOptions();
			//settings.maximizable = false;
			//settings.minimizable = false;
			settings.resizable = true;
			settings.systemChrome = NativeWindowSystemChrome.STANDARD;
			settings.transparent = false;
			//settings.owner = main.stage.nativeWindow;
			
			canvasWindow = new NativeWindow(settings);
			canvasWindow.title = "Livebrush Canvas";
			canvasWindow.width = 1024;
			canvasWindow.height = 768;
			canvasWindow.stage.align = StageAlign.TOP_LEFT;
			canvasWindow.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			canvasWindow.addEventListener(Event.CLOSING, canvasWindowClosingListener);
			canvasWindow.addEventListener(Event.CLOSE, canvasWindowCloseListener);
			canvasWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, canvasWindowStateListener);
		
		}
		
		public function openCanvasWindow ():void
		{
			toolManager.setTool(toolManager.brushTool);
			
			toolManager.activeTool.reset();
			
			canvasWindow.stage.addChildAt(canvasManager.canvasView.canvas, 0);
			
			Canvas.STAGE = canvasWindow.stage;

			canvasWindow.activate();
			canvasWindow.orderToFront();
			
			toolManager.resetTool();
			
			
		}
		
		public function closeCanvasWindow (exit:Boolean=false):void
		{

			//main.addChildAt(canvasManager.canvasView.canvas, 0);
			
			toolManager.setTool(toolManager.brushTool);
			
			toolManager.activeTool.reset();

			if (exit) 
			{
				forceCanvasWindowClose = true;
				canvasWindow.close();
			}
			else 
			{
				canvasWindow.stage.displayState = NativeWindowDisplayState.NORMAL;
				canvasWindow.visible = false;
				main.addChildAt(canvasManager.canvasView.canvas, 0);
				
				Canvas.STAGE = main.stage;
			}
			
			toolManager.resetTool();
			
		}
		
		public function createNewProject (sizeIndex:int, bgIndex:int):void
		{
			//main.saveFirst(function():void{main.closeProject(); FileManager.getInstance().newProject();});
			main.newProject(sizeIndex, bgIndex);
		}
		
		public function promptForNewVersion (e:FileEvent):void
		{
			var message:String = "";
			if (e.fileType == FileEvent.NEW_VERSION)
			{
				message = "There is a new major version of LiveBrush.\nWould you like more information?";
				newDialog(Dialog.QUESTION, {message:message, yesFunction:function(){FileManager.getURL(Main.HOME_LINK)}});
				// do the function to load lb home - same as main menu
			}
			else if (e.fileType == FileEvent.UPDATE_VERSION)
			{
				message = "There is a free update available (" + e.data.newVersion + ").\n" + "Your current version is: " + e.data.currentVersion;
				message += "\nWould you like to download and install this update?";
				newDialog(Dialog.QUESTION, {message:message, yesFunction:function(){FileManager.getURL(Main.UPDATE_LINK)}});
			}
			else if (e.fileType == FileEvent.CURRENT_VERSION)
			{
				message = "You have the most recent version of Livebrush\nVersion " + e.data.currentVersion;
				//message += "\nWould you like to download and install this update?";
				newDialog(Dialog.NOTICE, {message:message});
			}
		}
		
		/*public function downloadUpdate ():void
		{
			//if (
			
		}*/
		
		public function showGlobalPrefs ():void
		{
			if (globalSettingsView == null) globalSettingsView = GlobalSettingsView(openWindow(GlobalSettingsView));
		}
		
		public function showAbout ():void
		{
			if (aboutView == null) aboutView = BasicWindowView(openWindow(BasicWindowView, {message:Main.ABOUT_INFO}));
		}
		
		public function showNewProject ():void
		{
			if (newProjectView == null) newProjectView = NewProjectView(openWindow(NewProjectView));
		}
		
		public function saveImage ():void
		{
			if (saveImageView == null) saveImageView = SaveImageView(openWindow(SaveImageView, {allLayers:true}));
		}
		
		public function saveLayerImage ():void
		{
			if (saveImageView == null) saveImageView = SaveImageView(openWindow(SaveImageView, {allLayers:false}));
		}
		
		public function openWindow (type:Class, data:Object=null):UIView
		{
			toggle(false);
			var v:UIView = new type(this, data);
			registerView(v);
			return v;
		}
		
		public function closeWindow (view:UIView):void
		{
			toggle(true);
			if (view == aboutView) aboutView = null;
			unregisterView(view);
			view.die();
		}
		
		public function closeDialog (dialog:Dialog):void
		{
			toggle(true);
			unregisterView(dialog.dialogView);
			var regIndex:int = registeredDialogIDList.indexOf(dialog.id);
			if (regIndex > -1) registeredDialogIDList.splice(regIndex, 1);
			dialog.dialogView.die();
			//try {   delete dialog;   } catch (e:Error) {}
			
		}
		
		public function closeDialogID (id:String):void
		{
			var d:Dialog;
			for (var i:int=0; i<views.length; i++) if (views[i] is DialogView) if (views[i].id == id) d = views[i].dialogModel;
			try {   closeDialog(d);   } catch(e:Error) {}
		}
		
		public function updateDialogs (update:Update):void
		{
			for (var i:int=0; i<views.length; i++)
			{
				if (views[i] is DialogView) views[i].update(update);
			}
		}
		
		public function showLoadDialog (data:Object=null):Dialog
		{
			//var d:Dialog = new Dialog(Dialog.LOADING, data);
			//registerView(d.dialogView);
			return newDialog(Dialog.LOADING, data);
		}
		
		public function showProcessDialog (data:Object=null):Dialog
		{
			//var d:Dialog = new Dialog(Dialog.LOADING, data);
			//registerView(d.dialogView);
			return newDialog(Dialog.PROCESS, data);
		}
		
		public function busyAlert (generic:Boolean=false):void
		{
			/*
			if (((StateManager.state == StateManager.CLOSED && !toolManager.activeTool.isRunning) || e.target.name=="save" || e.target.name=="togglePreview") 
				&& (registeredDialogIDList.length==0 && !locked) || e.target.name=="stopAllBrushes" || e.target.name=="stopLastBrush")
			*/
			
			// // Consol.Trace("------ (UI) TOOL BUSY -------");
			// // Consol.Trace("(StateManager.state == StateManager.CLOSED && !toolManager.activeTool.isRunning) = " + (StateManager.state == StateManager.CLOSED && !toolManager.activeTool.isRunning));
			// // Consol.Trace("StateManager.state == StateManager.CLOSED = " + StateManager.state == StateManager.CLOSED);
			// // Consol.Trace("!toolManager.activeTool.isRunning = " + !toolManager.activeTool.isRunning);
			// // Consol.Trace("(registeredDialogIDList.length==0 && !locked) = " + (registeredDialogIDList.length==0 && !locked));
			// // Consol.Trace("registeredDialogIDList.length==0 = " + (registeredDialogIDList.length==0));
			// // Consol.Trace("!locked = " + !locked);
			
			if (GlobalSettings.SHOW_BUSY_WARNINGS)
			{
				var message:String;
				if (generic) message = "This action cannot be performed at this time.";
				else if (toolManager.activeTool == toolManager.brushTool) message = "Brush Tool is busy. Please wait.\n\nUse CTRL+SHIFT+B to stop all brushes.";
				else if (toolManager.activeTool == toolManager.penTool) message = "Pen Tool is busy. Please wait.";
				else if (toolManager.activeTool == toolManager.transformTool) message = "Transform Tool is busy. Please wait.";
				else message = "Processing your last request. Please wait.";
				alert({message:message, id:"busyAlert"});
			}
		}
		
		public function showErrorDialog (data:Object=null):Dialog
		{
			return newDialog(Dialog.NOTICE, data);
		}
		
		public function newDialog (type:String, data:Object=null):Dialog
		{
			//toggle(false);
			var d:Dialog;
			
			if (data.id == null || (data.id != null && registeredDialogIDList.indexOf(data.id) == -1))
			{
				toggle(false);
				d = new Dialog(type, data);
				registerView(d.dialogView);
				if (data.id != null) registerDialog(d);
			}
			
			return d;
		}
		
		private function registerDialog (d:Dialog):void
		{
			registeredDialogIDList.push(d.id);
		}
		
		public function alert (data:Object=null):Dialog
		{
			return newDialog(Dialog.NOTICE, data);
		}
		
		public function confirmActionDialog (data:Object):Dialog
		{
			return newDialog(Dialog.QUESTION, data);
		}
		
		
		// UPDATES //////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function pushTransformProps (data:Settings):void
		{
			updateViews(Update.transformUpdate(data));
		}
		 
		public function pushLayerProps (data:Settings):void
		{
			updateViews(Update.layerUpdate(data));
		}
		
		public function pushColorProps (data:Settings):void
		{
			styleManager.lockedColorSettings = globalColorView.settings;
			styleManager.alphaLocked = styleManager.lockedColorSettings.alphaLocked;
			updateViews(Update.colorUpdate(data));
		}
		
		public function pullToolProps (uiView:UIView):void
		{
			toolManager.activeTool.settings = uiView.settings;
			pushColorProps (uiView.settings);
		}
		
		public function uiUpdate ():void
		{
			updateViews(Update.uiUpdate());
		}
		
		protected override function updateViews (update:Update):void
		{
			super.updateViews(update);
			
			brushPropsModel.update(update);
		}

		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function getToolPropsByName (toolName:String):UIView
		{
			var toolProps:UIView;
			switch (toolName)
			{
				case BrushTool.NAME : toolProps = brushPropsView; break;
				case ColorLayerTool.NAME : toolProps = bucketPropsView; break;
				case SampleTool.NAME : toolProps = bucketPropsView; break;
				//case SampleTool.NAME : toolProps = samplePropsView; break;
				case TransformTool.NAME : toolProps = transformPropsView; break;
				case PenTool.NAME : toolProps = brushPropsView; break;
			}
			return toolProps;
		}
		
		
		// DEBUG ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function showConsol ():void
		{
			//holder.addChildAt(consol, CONSOL_DEPTH);
			holder.addChild(consol);
		}

	}
	
	
}