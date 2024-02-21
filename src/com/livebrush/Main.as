package com.livebrush
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.filesystem.*;
	import flash.utils.setTimeout;
	import flash.events.InvokeEvent;
	import flash.desktop.NativeApplication;
	
	/*import flash.display.StageDisplayState;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.Stage;*/
	
	import com.livebrush.utils.Update;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.Window;
	import com.livebrush.events.*
	import com.livebrush.data.Settings;
	import com.livebrush.data.GlobalSettings;
	import com.livebrush.data.FileManager;
	import com.livebrush.styles.StyleManager;
	import com.livebrush.ui.Consol;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.tools.ToolManager;
	import com.livebrush.events.CanvasEvent;
	import com.livebrush.data.StateManager;
	
	import com.formatlos.as3.lib.display.BitmapDataUnlimited;
	import com.formatlos.as3.lib.display.events.BitmapDataUnlimitedEvent;
	
	//import com.wacom.maxi.flash.*;
	//import com.wacom.events.*;
	import com.wacom.Tablet;
	
	import com.adobe.licensing.LicenseManager;
	
	
	public class Main extends MovieClip
	{
		
		public static const ABOUT_INFO						:String = "<font size='16'><b>Livebrush</b></font>\n<font size='10'>Version 1.5</font>\n\n<b>Created By:</b> David Fasullo (MoreMeYou.com)\n\n<b>Libraries Used:</b> CASA Lib, Core Lib\n\n<font size='11'>Copyright(c) 2007-2011 David Fasullo.</font>";
		
		private static const MY_UNIQUE_32_HEX_NUM			:String = "ef0fb095-59d6-41ff-a143-1a47535a7520";
		private static var UPDATE_MODE						:Boolean = false;
		private static var DEBUG_MODE						:Boolean = false;

		
		public static const MAJOR_VERSION					:int = 1;
		public static const HELP_LINK						:String = "http://www.livebrush.com/help/index.html";
		public static const SUPPORT_LINK					:String = "http://www.livebrush.com/support.html";
		public static const FEEDBACK_LINK					:String = "http://www.livebrush.com/feedback.html";
		public static const FORUM_LINK						:String = "http://www.livebrush.com/forumCommunity.html";
		public static const FORUM_STYLES_LINK				:String = "http://www.livebrush.com/forumCommunity.html";
		public static const FORUM_DECOS_LINK				:String = "http://www.livebrush.com/forumCommunity.html";
		public static const FORUM_REMIX_LINK				:String = "http://www.livebrush.com/forumCommunity.html";
		public static const FORUM_DEVELOP_LINK				:String = "http://www.livebrush.com/forumCommunity.html";
		public static const HOME_LINK						:String = "http://www.livebrush.com";
		public static const UPDATE_LINK						:String = "http://www.livebrush.com/update.aspx";
		public static const FACEBOOK_LINK					:String = "http://www.facebook.com/Livebrush";
		public static const TWITTER_LINK					:String = "http://www.twitter.com/Livebrush";
		public static const BUY_LINK						:String = "http://www.Livebrush.com/Buy.aspx";
		
		//public static var WACOM								:BambooFlashMaxiImpl;
		
		private var ui										:UI;
		private var canvasManager							:CanvasManager;
		private var fileManager								:FileManager;
		private var styleManager							:StyleManager;
		private var toolManager								:ToolManager;
		private var _outputRes								:int = 0;
		private var _allLayers								:Boolean = true;
		private var invokeFilePath							:String = "";	
		private var fnAfterSave								:Function = null;
		private var propsAfterSave							:Array = null;
		private var _invokeEnabled							:Boolean = false;
		private var _stateManager							:StateManager;
		
		
		public function Main ()
		{
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, appInvoked);
			initUI();
			//mainInit();
			stage.stageFocusRect = false;
			setTimeout(mainInit, 1000);
			
			//WACOM = new BambooFlashMaxiImpl(this);
			var tablet:Tablet = Tablet.getInstance(this);
			tablet.addEventListener(Event.COMPLETE, wacomListener);
			//wacomListener(); // force call for now. when we get the real event from WACOM, that's where we'll call this
			
			// Melrose
			//var licenseManager:LicenseManager = new LicenseManager();
			//licenseManager.checkLicense( this, MY_UNIQUE_32_HEX_NUM, UPDATE_MODE, DEBUG_MODE );
			
		}
		
		private function get invokeEnabled ():Boolean {   var b:Boolean; try { b=(_invokeEnabled && !_stateManager.locked && !ui.locked); } catch (e:Error) { b=false; } return b;   };
		private function set invokeEnabled (b:Boolean):void {   _invokeEnabled = b;   }
		
		private function creationCompleteHandler():void
		{
			trace("creation complete");
			var licenseManager:LicenseManager = new LicenseManager();
			licenseManager.checkLicense( this, MY_UNIQUE_32_HEX_NUM, UPDATE_MODE, DEBUG_MODE ); 
		}
		
		
		// APP SETUP & PROJECT LOAD /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function initUI ():void
		{
			ui = new UI(this);
			
			ui.addEventListener (FileEvent.IO_EVENT, fileIOListener);
			stage.nativeWindow.addEventListener (Event.CLOSE, windowClose);
		}
		
		private function mainInit ():void
		{
			//createNewWindow();
			
			canvasManager = new CanvasManager(this, ui);
			canvasManager.addEventListener(Event.COMPLETE, projectInit);
			////////// This next listener is important because it completes the app setup (on project load)
			canvasManager.addEventListener(CanvasEvent.INIT, canvasManagerInit);
			///////////////////////////////////////////////////////////////////////////////////////////////
			
			styleManager = new StyleManager(ui);

			initFileManager();
			
			canvasManager.setup();
			
			//addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownEvent, false, 0, true);
			//addEventListener(MouseEvent.MOUSE_UP, onMouseUpEvent, false, 0, true);

		}
		
		private function wacomListener (e:Event=null):void
		{
			// set the global setting that wacom is cool:
			GlobalSettings.WACOM_DOCK = true;
			
			ui.enableWacom();
			
			// this will be in the brush tool
			// WACOM.PM.addEventListener(PressureEvent.PRESSURE, onPressureEvent, false, 0, true);
		}
		
		
		private function initFileManager ():void
		{
			fileManager = FileManager.getInstance(); 
			fileManager.addEventListener(FileEvent.BEGIN_LOAD, fileIOListener); 
			fileManager.addEventListener(FileEvent.FILE_NOT_FOUND, fileIOListener); 
			fileManager.addEventListener(FileEvent.WRONG_FILE, fileIOListener); 
			fileManager.addEventListener(FileEvent.IO_EVENT, fileIOListener, false, 1); // lower priorety because project object will be loading any supporting files
			//fileManager.addEventListener(FileEvent.IO_EVENT, ui.fileIO);
			fileManager.addEventListener(FileEvent.IO_EVENT, ui.fileIO);
			fileManager.addEventListener(FileEvent.SAVE, fileIOListener);
			fileManager.addEventListener(FileEvent.IO_ERROR, fileIOListener);
			fileManager.addEventListener(FileEvent.VERSION_UPDATE, ui.promptForNewVersion);
		}

		private function canvasManagerInit (e:CanvasEvent):void 
		{
			// The project has loaded and the canvas is ready.
			
			canvasManager.removeEventListener(CanvasEvent.INIT, canvasManagerInit);
			
			initToolManager();
	
			canvasManager.toolManager = toolManager;
			canvasManager.styleManager = styleManager;
			
			ui.toolManager = toolManager;
			ui.canvasManager = canvasManager;
			ui.styleManager = styleManager;
			ui.initCanvasDependantViews();
			
			fileManager.loadAppSettings();
			fileManager.checkFirstRun();
			
			ui.showLoadDialog({message:"Opening Project", loadPercent:.1, id:"loadProject"});
			//if (invokeFilePath != "") fileManager.loadProject(invokeFilePath);
			//else fileManager.loadProject(fileManager.getRecentProjectPath());
			if (invokeFilePath != "") setTimeout(fileManager.loadProject, 1000, invokeFilePath);
			else setTimeout(fileManager.loadProject, 1000, fileManager.getRecentProjectPath());
		}
		
		private function initToolManager ():void
		{
			toolManager = new ToolManager (ui, canvasManager, styleManager); 
			toolManager.addEventListener(UpdateEvent.LAYER, canvasManager.updateLayers);
			toolManager.addEventListener(UpdateEvent.SELECTION, canvasManager.selectionUpdate);
			toolManager.addEventListener(UpdateEvent.BEGIN, canvasManager.toolUpdate);
			toolManager.addEventListener(UpdateEvent.FINISH, canvasManager.toolUpdate);
		}
		
		private function projectInit (e:Event):void
		{
			// Is this called every time a project is loaded? (even after launch)? No.
			
			ui.toggleDrawMode(GlobalSettings.DRAW_MODE);
			// // Consol.Trace("Main: PROJECT LOADED");
			//ui.setProject(fileManager.projectName);
			ui.toggle(true);

			_stateManager = StateManager.getInstance(this, canvasManager);
			//sM.addEventListener(
			
			// un-comment this on launch - NO, this is in FileManager now
			//if (GlobalSettings.CHECK_FOR_UPDATES) setTimeout(FileManager.checkForUpdates, 10000);
			
			invokeEnabled = true;
			
		}
		
		
		// MAIN ACTIONS /////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function importToProject (type:String):void
		{
			switch (type)
			{
				case FileManager.DECO : fileManager.openDeco(); break;
				case FileManager.DECOSET : fileManager.openDecoSet(); break;
				case FileManager.STYLE : fileManager.openStyle(); break;
				case FileManager.LAYER_IMAGE : fileManager.openLayerImage(); break;
				case FileManager.PROJECT : canvasManager.omitBg=true; fileManager.importProject(); break;
			}
		}
		
		public function importInputSWF ():void
		{
			fileManager.openInputSWF();
		}
		
		public function export (type:String):void
		{
			if ((type == FileManager.DECOSET && GlobalSettings.FIRST_DECOSET_EXPORT) || (type == FileManager.STYLE && GlobalSettings.FIRST_STYLE_EXPORT))
			{
				var name:String = (type==FileManager.DECOSET?"current style decoration list":"current style");
				ui.alert({message:"TIP: Your " + name + " and its assets will be created within a folder. Livebrush will always create this structure for you.",
						 yesFunction:_exportAssets, yesProps:[type], id:"firstExportAlert"});
				if (type==FileManager.DECOSET) GlobalSettings.FIRST_DECOSET_EXPORT = false;
				else GlobalSettings.FIRST_STYLE_EXPORT = false;
			}
			else
			{
				_exportAssets(type);
			}
		}
		
		private function _exportAssets (type:String):void
		{
			switch (type)
			{
				case FileManager.DECOSET : fileManager.saveDecoSet(styleManager.activeStyle.decoStyle.decoSet.getXML()); break;
				case FileManager.STYLE : fileManager.saveStyle(styleManager.activeStyle.getXML()); break;
				case FileManager.LAYER_IMAGE : fileManager.saveImage(canvasManager.getImage(canvasManager.activeLayerDepths)); break; // canvasManager.allLayerDepths
				//case FileManager.SVG : fileManager.saveSVG(canvasManager.getSVG(canvasManager.activeLayerDepths)); break;
				case FileManager.SVG : ui.alert({message:"PRO FEATURE\n\nPlease upgrade Livebrush to use this professional feature.", yesFunction:FileManager.getURL, yesProps:[Main.BUY_LINK], id:"proFeature"});
			}
		}
		
		public function cleanupProject ():void
		{
			saveFirst(fileManager.cleanupProject, [canvasManager.getXML(), styleManager.getStyleXML()]);
					 // fileManager.cleanupProject(canvasManager.getXML(), styleManager.getStyleXML());
		}
		
		public function saveAsImage (res:int, allLayers:Boolean):void
		{
			//// Consol.Trace(allLayers);
			_outputRes = res;
			_allLayers = allLayers;
			ui.toggle(false);
			
			ui.showProcessDialog({message:"Preparing Image", id:"saveImage"})
			
			setTimeout(canvasManager.canvas.generateCanvasBitmap, 100, res, bitmapReady, bitmapError);
			//canvasManager.canvas.generateCanvasBitmap(res, bitmapReady, bitmapError);
		}

		public function newProject (sizeIndex:int=0, bgIndex:int=1):void // This is called from UI. Is there a better event way?
		{
			//saveFirst(function():void{closeProject(); fileManager.newProject();});
			
			closeProject();
			fileManager.newProject(sizeIndex, bgIndex);
		}
		
		public function openProject ():void // This is called from UI. Is there a better event way?
		{
			// The path is passed here so the open dialogue box has a starting directory
			//fileManager.openProject();
			saveFirst(fileManager.openProject);
		}
		
		public function saveProject ():void // This is called from UI. Is there a better event way?
		{
			if (GlobalSettings.FIRST_SAVE)
			{
				ui.alert({message:"Your first Livebrush project!\nTIP: Your project file will be created within a project folder. Livebrush will always create this structure for you.",
						 yesFunction:fileManager.saveProject, yesProps:[canvasManager.getXML(), styleManager.getStyleXML()], id:"firstSaveAlert"});
				GlobalSettings.FIRST_SAVE = false;
			}
			else
			{
				fileManager.saveProject(canvasManager.getXML(), styleManager.getStyleXML());
			}
		}
		
		public function saveProjectAs ():void // This is called from UI. Is there a better event way?
		{
			if (GlobalSettings.FIRST_SAVE)
			{
				ui.alert({message:"Your first Livebrush project!\nTIP: Your project file will be created within a project folder. Livebrush will always create this structure for you.",
						 yesFunction:fileManager.saveAsProject, yesProps:[canvasManager.getXML(), styleManager.getStyleXML()], id:"firstSaveAlert"});
				GlobalSettings.FIRST_SAVE = false;
			}
			else
			{
				fileManager.saveAsProject(canvasManager.getXML(), styleManager.getStyleXML());
			}
		}
		
		public function revertProject ():void // This is called from UI. Is there a better event way?
		{
			//closeProject();
			// ask to save?
			
			//saveFirst(fileManager.revertProject);
			
			ui.confirmActionDialog({message:"This action cannot be undone.\n\nWould you like to continue?",
									   yesFunction:fileManager.revertProject, id:"revertConfirm"});
			//fileManager.revertProject();
		}
		
		public function exit ():void // This is called from UI. Is there a better event way?
		{
			saveFirst(closeAndExit);
			
			
			//closeProject(); // In this method, this is where we'll do the check for saving. if session prop.changeSinceSave, then prompt for saving
			
			// need to delay these actions until after a save changes dialogue box
			// can we just pass a function to the dialogue box? a function we define in here...? should work...
	
			//stage.nativeWindow.close();
		}
		
		private function closeProject ():void
		{
			// this is where we'll do the check for saving
			// if session prop.changeSinceSave, then prompt for saving
			// // Consol.Trace("Main: Close Project");
			
			StateManager.lock();
			reset();
		}
		
		private function reset():void
		{
			// // Consol.Trace("Main: Reset");
			StateManager.reset();
			canvasManager.reset();
			styleManager.reset();
		}
		
		private function closeAndExit ():void
		{
			closeProject();
			stage.nativeWindow.close();
		}
		
		public function saveFirst (fnAfterSave:Function, props:Array=null):void
		{
			// if we do yes, then this var is called after the save (in the main io event listener).
			this.fnAfterSave = fnAfterSave;
			propsAfterSave = props;
			
			if (StateManager.changed) 
			{
				ui.confirmActionDialog({message:"There have been changes since you last saved.\n\nWould you like save first?",
									   yesFunction:saveProject, noFunction:runFnAfterSave, id:"saveConfirm"});
			}
			else
			{
				runFnAfterSave();
			}
		}
		
		private function runFnAfterSave ():void
		{
			if (fnAfterSave != null)
			{
				if (propsAfterSave != null) fnAfterSave.apply(this, propsAfterSave);
				else fnAfterSave();
				
				fnAfterSave = null;
				propsAfterSave = null;
			}
		}
		
		
		// MAIN EVENT LISTENERS /////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function stateChange (e:StateEvent):void
		{
			canvasManager.stateChange(e);
		}
		
		private function appInvoked (e:InvokeEvent)
		{
			//// // Consol.Trace("Application opened with: "+e.arguments[0]);
			if (e.arguments[0] is String) 
			{
				invokeFilePath = e.arguments[0];
				if (invokeEnabled) 
				{
					closeProject();
					saveFirst(fileManager.loadProject, [invokeFilePath]);
				}
			}
		}
		
		private function windowClose (e:Event):void
		{
			// This is automatically called when the window closes
			ui.closeCanvasWindow(true);
			
			fileManager.saveGlobalSettings();
			fileManager.cleanup();

		}
		
		private function fileIOListener (e:FileEvent):void
		{
			// // // Consol.Trace("MAIN : FILE IO LISTENER : " + e.action + " : " + e.fileType);
			var data:XML;
			if (e.type == FileEvent.SAVE)
			{
				switch (e.fileType)
				{
					case FileManager.PROJECT :
						ui.toggle(true);
						ui.setProject(fileManager.projectName);
						// // Consol.Trace("Main: Project Saved");
						StateManager.changed = false;
						
						runFnAfterSave();
					break;
				}
			}
			else if (e.type == FileEvent.IO_ERROR)
			{
				switch (e.fileType)
				{
					case FileManager.PROJECT :
						ui.toggle(true);
						//ui.closeDialogs();
						ui.showErrorDialog({message:"SAVE ERROR\nProject assets open or in-use by another application.\nA backup has been saved to your desktop."});
					break;
				}
			}
			/*else if (e.type == FileEvent.IO_COMPLETE)
			{
				switch (e.fileType)
				{
					case FileManager.PROJECT :
						ui.toggle(true);
						//ui.closeDialogs();
						//projectLoadDialog = ui.showLoadDialog({message:"Loading Project", loadPercent:0});
					break;
				}
			}*/
			else if (e.type == FileEvent.BEGIN_LOAD)
			{
				switch (e.fileType)
				{
					case FileManager.PROJECT :
						UI.setStatus("Loading...");
						ui.showLoadDialog({message:"Checking Project...", loadPercent:0, id:"loadProject"});
						ui.toggle(false);
						//ui.projectLoadDialog = ui.showLoadDialog({message:"Loading Project", loadPercent:0});
					break;
				}
			}
			else if (e.type == FileEvent.FILE_NOT_FOUND)
			{
				// // Consol.Trace("FILE NOT FOUND (" + e.fileType + "): " + e.data);
			}
			else if (e.type == FileEvent.WRONG_FILE)
			{
				// // Consol.Trace("WRONG FILE, " + e.data + ". EXPECTED " + e.fileType + ".");
			}
			else if (e.action == FileEvent.OPEN || e.action == FileEvent.BATCH_OPEN)
			{
				switch (e.fileType)
				{
					case FileManager.PROJECT :
						// // Consol.Trace("PROJECT LOADED. PROCESSING.");
						ui.setProject(fileManager.projectName);
						data = new XML(e.data);
						//// // Consol.Trace(data.@size.length()>0);
						if (data.@size.length()>0) {   canvasManager.canvas.setSize(int(data.@size));   }
						else {   canvasManager.canvas.setSize(0);   }
						setTimeout(canvasManager.setXML, 100, data.layers);
					break;
					case FileManager.STYLE :
						styleManager.setStyleXML(new XML(e.data), (fileManager.lastFileLoaded==FileManager.STYLE));
					break;
					case FileManager.INPUT_SWF :
						styleManager.setDynamicInput(new File(e.data.url).name);
					break;
					case FileManager.DECO :
						styleManager.activeStyle.decoStyle.addDeco(new File(e.data.url).name);
						styleManager.pushStyle();
					break;
					case FileManager.LAYER_IMAGE :
						//canvasManager.addLayer(Layer.newImageLayer(canvas, String(e.data)));
						canvasManager.loadImageLayer(String(e.data), (e.action == FileEvent.BATCH_OPEN));
					break;
					case FileManager.SWF :
						canvasManager.loadSWFLayer(String(e.data), (e.action == FileEvent.BATCH_OPEN));
					break;
				}
			}
			else if (e.action == FileEvent.CLOSE) // This might be how to do the UI direct calls (for openProject, etc). But is there are less code-heavy way?
			{
				closeProject();
			}
			else if (e.action == FileEvent.IMPORT)
			{
				//// // Consol.Trace(e.data)
				switch (e.fileType)
				{
					
					case FileManager.PROJECT :
						// // Consol.Trace("PROJECT IMPORTED. PROCESSING.");
						setTimeout(canvasManager.setXML, 100, new XML(e.data).layers);
					break;
					/*case FileManager.LAYER_IMAGE :
						fileManager.openLayerImage();
					break;
					case FileManager.STYLE :
						fileManager.openStyle();
					break;
					case FileManager.DECOSET :
						fileManager.openDecoSet();
					break;
					case FileManager.DECO :
						fileManager.openDeco();
					break;*/
				}
			}
			/*else if (e.action == FileEvent.EXPORT)
			{
				switch (e.fileType)
				{
					case FileManager.STYLE :
						fileManager.saveStyle(styleManager.activeStyle.getXML());
					break;
					case FileManager.DECOSET :
						fileManager.saveDecoSet(styleManager.activeStyle.decoStyle.decoSet.getXML());
					break;
				}
			}*/
			
		}
		
		public function bitmapReady (e:BitmapDataUnlimitedEvent):void
		{
			//ui.updateDialogs(Update.dataUpdate({message:"Saving Image"}));
			ui.closeDialogID("saveImage");
			
			// // Consol.Trace("CANVAS BITMAP CREATED");
			ui.toggle(true);
			
			//fileManager.saveImage(canvasManager.getCanvasImage(e.target.bitmapData, _outputRes));
			// fileManager.saveImage(canvasManager.getCanvasImage(e.target as BitmapDataUnlimited, _outputRes));
			setTimeout(fileManager.saveImage, 100, canvasManager.getCanvasImage(e.target as BitmapDataUnlimited, _outputRes, _allLayers));
			
			_outputRes = 0;
		}
		
		public function bitmapError (e:BitmapDataUnlimitedEvent):void
		{
			// // Consol.Trace("CANVAS BITMAP CREATION ERROR");
			ui.toggle(true);
		}
		
		
	}
	
}