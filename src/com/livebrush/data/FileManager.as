package com.livebrush.data
{
	
	// singleton
	import flash.display.Sprite
	import flash.filesystem.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import flash.net.FileFilter;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.data.EncryptedLocalStore;
	import flash.utils.ByteArray;
	import flash.display.BitmapData;
	import flash.desktop.NativeApplication;
	import flash.system.LoaderContext;
	import flash.system.ApplicationDomain;
	import flash.utils.setTimeout;
	
	import com.adobe.images.PNGEncoder;
	import com.adobe.images.JPGEncoder;
	
	import com.livebrush.events.FileEvent;
	import com.livebrush.events.ConsolEvent;
	import com.livebrush.data.*;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.styles.DecoAsset;
	import com.livebrush.data.Settings;
	import com.livebrush.data.GlobalSettings;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UI;
	import com.livebrush.Main;
	import com.livebrush.utils.Update;
	
	import org.casalib.util.NavigateUtil;
	import org.casalib.util.DateUtil;
	
	
	public class FileManager extends EventDispatcher
	{

		private static var singleton				:FileManager;

		public static const PROJECT					:String = "project";
		public static const DECOSET					:String = "decoList";
		public static const STYLE					:String = "style";
		public static const DECO					:String = "deco";
		public static const LAYER_IMAGE				:String = "layerImage";
		public static const INPUT_SWF				:String = "inputSWF";
		public static const SWF						:String = "SWF";
		public static const SVG						:String = "SVG";
		public static const ONLINE_VERSION_PATH		:String = "http://www.livebrush.com/version.txt";
		
		private var appSettings						:Settings;
		private var firstRun						:Boolean;
		private var _projectIsTemp					:Boolean;
		private var sessionProjectDir				:String;
		private var tempProjectDir					:String;
		private var decoFilesLoaded					:Array;
		private var decoAssetsLoaded				:Array;
		private var activeFile						:File;
		
		private var _bitmapData						:BitmapData;
		//public var imageRes							:int = 0;
		public var lastFileLoaded 					:String;
		public var layerData						:XML;
		public var projectStyles					:XML;
		public var decoSetData						:XML;
		public var styleData						:XML;
		private var svgData							:XML;
		private var help							:Help;
		private var _recentOpenDir					:String = "";
		private var _recentSaveDir					:String = "";
		private var _canvasSizeIndex				:int = -1;
		private var _canvasBgIndex					:int = -1;
		//public var globalSettings					:GlobalSettings;
		private var showVersionCheckResult			:Boolean = false;
		
		
		public function FileManager ():void
		{
			help = Help.getInstance(this);
		}
		
		
		public static function getInstance ():FileManager
		{
			var instance:FileManager;
			if (singleton == null) 
			{
				singleton = new FileManager();
				instance = singleton;
			}
			else 
			{
				instance = singleton;
			}
			
			return instance;
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get projectIsTemp ():Boolean {   return _projectIsTemp;   }
		private function get recentProject ():String { return loadLocalString("recentProject"); }
		private function get recentProjectDir ():String { return new File (loadLocalString("recentProject")).parent.nativePath; }
		private function get openRecentProjectDir ():String { return (projectIsTemp ? File.documentsDirectory.nativePath : new File (loadLocalString("recentProject")).parent.nativePath); }
		public function get projectName ():String { return removeExtension(new File (loadLocalString("recentProject")).name); }
		public function get projectFileName ():String {   return projectName+".lbp";   }
		private function get currentProject ():String { return sessionProjectDir+"/"+projectName+".lbp"; }
		private function get currentProjectDir ():String { return sessionProjectDir; }
		private function get layerImagesDir ():String { return sessionProjectDir+"/Layer Images"; }
		private function get decoAssetsDir ():String { return sessionProjectDir+"/Styles/Assets"; }
		private function get appFiles ():File {  return File.applicationDirectory.resolvePath("AppFiles");  }
		private function get helpFile ():File {  return File.applicationDirectory.resolvePath("AppFiles/Help.xml");  }
		private function get lbUserDocsDir ():File {  return File.documentsDirectory.resolvePath("LiveBrush");  }
		public static function get missingLayerFile ():File {   return File.applicationDirectory.resolvePath("AppFiles/Assets/Layer Images/missingLayer.jpg");   }
		private function get appAssetsDir  ():File {   return File.applicationStorageDirectory.resolvePath("Assets");   }
		private function get appLayerImagesDir  ():File {   return appAssetsDir.resolvePath("Layer Images");   }
		
		// UI INTERFACE /////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////

		
		// APPLICATION SETUP ////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function checkFirstRun ():void
		{
			firstRun = !File.applicationStorageDirectory.exists;
			var versionType:String = compareVersion();
			//firstRun = true;
			// Consol.Trace("VERSION TYPE: " + versionType);
			//copyAppFiles();
			if (firstRun)
			{
				// Consol.Trace("FIRST RUN. COPY FILES FROM APP DIR: " + appFiles.nativePath);
				copyAppFiles();
				saveLocalString ("version", appSettings.version);
				setTimeout(UI.MAIN_UI.confirmActionDialog, 20000, {message:"Would like to automatically check for updates?\nYou can change this setting at any time.", 
						 										   yesFunction:function(){GlobalSettings.CHECK_FOR_UPDATES=true; checkForUpdates();},
						 										   noFunction:function(){GlobalSettings.CHECK_FOR_UPDATES=false}});				
			}
			else if (!firstRun && versionType=="newer")
			{
				// Consol.Trace("FIRST RUN (NEW VERSION). COPY FILES FROM APP DIR: " + appFiles.nativePath);
				// don't over-write previous 'New Project' files?
				copyAppFiles();
				//createBaseProject();
				saveLocalString ("version", appSettings.version);
				if (GlobalSettings.CHECK_FOR_UPDATES) setTimeout(checkForUpdates, 20000);
			}
			else if (!firstRun && versionType=="current")
			{
				// Consol.Trace("NOT FIRST RUN. MOST RECENT VERSION.");
				//copyAppFiles(); // for debug
				if (GlobalSettings.CHECK_FOR_UPDATES) setTimeout(checkForUpdates, 20000);
			}
			else if (!firstRun && versionType=="older") // I don't think this is used anymore
			{
				// Consol.Trace("NOT FIRST RUN. NEED TO UPGRADE.");
				//saveLocalString ("version", appSettings.version); // for testing. to reset the version
			}
			else if (versionType=="newMajor") // I don't think this is used anymore
			{
				if (GlobalSettings.CHECK_FOR_UPDATES) setTimeout(checkForUpdates, 20000);
			}
		}
		
		public function copyAppFiles ():void
		{
			// // Consol.Trace("COPY FILES TO APP STORAGE: " + File.applicationStorageDirectory.nativePath);
			appFiles.copyTo(File.applicationStorageDirectory, true);
		}
	
		private function compareVersion (s:String=null):String // newer, older, current
		{
			var version:String = "newer";
			var storedVersion:String
			if (s == null)
			{
				storedVersion = loadLocalString ("version");
				// // Consol.Trace("LOCAL VERSION: " + storedVersion);
			}
			else
			{
				storedVersion = s;
				// // Consol.Trace("OTHER VERSION: " + storedVersion);
			}
			if (storedVersion != null)
			{
				var pointVersion:Array = appSettings.version.split(".");
				var pointStoredVersion:Array = storedVersion.split(".");
				if (pointVersion[0] > pointStoredVersion[0]) 
				{
					//version = "newer";
					version = "newMajor";
				}
				else if (pointVersion[0] == pointStoredVersion[0]) 
				{
					if (pointVersion[1] > pointStoredVersion[1])
					{
						version = "newer";
					}
					else if (pointVersion[1] == pointStoredVersion[1])
					{
						if (pointVersion[2] > pointStoredVersion[2]) version = "newer";
						else if (pointVersion[2] == pointStoredVersion[2]) version = "current";
						else version = "older";
					}
					else
					{
						version = "older";
					}
				}
				else
				{
					version = "older";
				}
			}
			
			return version;			
		}
		
		public function loadAppSettings ():void
		{
		
			var settingsXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
			
			var ns:Namespace = settingsXML.namespace();
			appSettings = new Settings();
			appSettings.version = settingsXML.ns::version;

			getGlobalSettings();
			
			// // Consol.Trace("LIVEBRUSH (version " + appSettings.version + ")");
			
		}
		
		private function getGlobalSettings ():void
		{
			GlobalSettings.setProperty ("CACHE_LAYERS", loadLocalString ("TEMP_CACHE_LAYERS"));
			GlobalSettings.setProperty ("CACHE_DECOS", loadLocalString ("CACHE_DECOS"));
			GlobalSettings.setProperty ("CACHE_DELAY", loadLocalString ("CACHE_DELAY"));
			GlobalSettings.setProperty ("CACHE_REALTIME", loadLocalString ("CACHE_REALTIME"));
			GlobalSettings.setProperty ("FIRST_SAVE", loadLocalString ("FIRST_SAVE"));
			GlobalSettings.setProperty ("FIRST_DECOSET_EXPORT", loadLocalString ("FIRST_DECOSET_EXPORT"));
			GlobalSettings.setProperty ("FIRST_STYLE_EXPORT", loadLocalString ("FIRST_STYLE_EXPORT"));
			GlobalSettings.setProperty ("CHECK_FOR_UPDATES", loadLocalString ("CHECK_FOR_UPDATES"));
			GlobalSettings.setProperty ("REGISTERED_EMAIL", loadLocalString ("REGISTERED_EMAIL"));
			GlobalSettings.setProperty ("SHOW_BUSY_WARNINGS", loadLocalString ("SHOW_BUSY_WARNINGS"));
			GlobalSettings.setProperty ("DRAW_MODE", loadLocalString ("DRAW_MODE"));
			GlobalSettings.setProperty ("STROKE_BUFFER", loadLocalString ("STROKE_BUFFER"));
			GlobalSettings.setProperty ("SHOW_MOUSE_WHILE_DRAWING", loadLocalString ("SHOW_MOUSE_WHILE_DRAWING"));
		}
		
		public function saveGlobalSettings ():void
		{
			saveLocalString("TEMP_CACHE_LAYERS", String(GlobalSettings.TEMP_CACHE_LAYERS));
			saveLocalString("CACHE_DECOS", String(GlobalSettings.CACHE_DECOS));
			saveLocalString("CACHE_DELAY", String(GlobalSettings.CACHE_DELAY));
			saveLocalString("CACHE_REALTIME", String(GlobalSettings.CACHE_REALTIME));
			saveLocalString("FIRST_SAVE", String(GlobalSettings.FIRST_SAVE));
			saveLocalString("FIRST_DECOSET_EXPORT", String(GlobalSettings.FIRST_DECOSET_EXPORT));
			saveLocalString("FIRST_STYLE_EXPORT", String(GlobalSettings.FIRST_STYLE_EXPORT));
			saveLocalString("CHECK_FOR_UPDATES", String(GlobalSettings.CHECK_FOR_UPDATES));
			saveLocalString("REGISTERED_EMAIL", String(GlobalSettings.REGISTERED_EMAIL));
			saveLocalString("SHOW_BUSY_WARNINGS", String(GlobalSettings.SHOW_BUSY_WARNINGS));
			saveLocalString("DRAW_MODE", String(GlobalSettings.DRAW_MODE));
			saveLocalString("STROKE_BUFFER", String(GlobalSettings.STROKE_BUFFER));
			saveLocalString("SHOW_MOUSE_WHILE_DRAWING", String(GlobalSettings.SHOW_MOUSE_WHILE_DRAWING));
		}

		public function cleanup ():void
		{
			deleteSessionProject();
			deleteTempProject();
		}
		
		public static function checkForUpdates (showResult:Boolean=false):void
		{
			getInstance().showVersionCheckResult = showResult;
			// Consol.Trace("CHECKING FOR UPDATES");
			FileManager.getInstance().checkVersionOnline();
		}
		
		
		// APPLICATION INTERFACE & DIALOGUES ////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function newProject (sizeIndex:int=0, bgIndex:int=1):void
		{
			_canvasSizeIndex = sizeIndex;
			_canvasBgIndex = bgIndex;
			
			cleanup()
			
			createBaseProject();
			
			loadProject(getRecentProjectPath());
		}
		
		public function openProject (path:String=""):void
		{
			//path = (path==null ? openRecentProjectDir : path);
			
			//activeFile = new File(); //File.desktopDirectory.resolvePath("Presets/BaseProject/");
			//activeFile.nativePath = path;
			
			//activeFile.browseForOpen("Open A LiveBrush Project", [new FileFilter("LiveBrush Project (*.lbp)", "*.lbp;")]);
			//activeFile.addEventListener(Event.SELECT, openProjectListener);
			
			
			//path = (path=="" ? "" : new File(path).parent.parent.nativePath);
			if (projectIsTemp) path = File.desktopDirectory.nativePath;
			else path = new File(getRecentProjectPath()).parent.nativePath;
			initOpenFile (path, "Open A LiveBrush Project", openProjectListener, [new FileFilter("LiveBrush Project (*.lbp)", "*.lbp;")]);
		}
		
		public function importProject (path:String=""):void
		{
			//path = (path==null ? openRecentProjectDir : path);
			
			//activeFile = new File(); //File.desktopDirectory.resolvePath("Presets/BaseProject/");
			//activeFile.nativePath = path;
			
			//activeFile.browseForOpen("Import A LiveBrush Project", [new FileFilter("LiveBrush Project (*.lbp)", "*.lbp;")]);
			//activeFile.addEventListener(Event.SELECT, importProjectListener);
			
			//path = (path=="" ? "" : new File(path).parent.parent.nativePath);
			path = new File(getRecentProjectPath()).parent.nativePath;
			initOpenFile (path, "Import A LiveBrush Project", importProjectListener, [new FileFilter("LiveBrush Project (*.lbp)", "*.lbp;")]);
		}
		
		public function cleanupProject (layerXML:XML, stylesXML:XML):void
		{
			// // Consol.Trace("FileManager: cleanup project");
			
			var tempDir:File = File.createTempDirectory();
			
			layerData = layerXML;
			projectStyles = stylesXML;
			
			exportProject(new File(tempDir.nativePath+"/"+projectFileName));
			var projectDir:File = new File(recentProjectDir);
			var projectBackup:File = writeProjectBackup();
			
			try
			{
				projectDir.deleteDirectory(true);
				
				projectDir.createDirectory();
				tempDir.copyTo(projectDir, true);
				
				// another exception
				tempDir.deleteDirectory(true);
			}
			catch (e:Error)
			{
				//writeProjectBackup();
				UI.MAIN_UI.showErrorDialog({message:"CLEANUP ERROR\nProject assets open or in-use by another application.\nA backup has been saved to your desktop."});
			}
			
			revertProject();
			
			try
			{
				projectBackup.deleteDirectory(true);
			} 
			catch (e:Error)
			{
				// // Consol.Trace("FileManager: Unable to delete redundant product backup.");
			}
			
			//return tempDir;
		}
		
		public function saveProject (layerXML:XML, stylesXML:XML):void
		{
			if (projectIsTemp)
			{
				saveAsProject(layerXML, stylesXML);
			}
			else
			{
				layerData = layerXML;
				projectStyles = stylesXML;
				
				UI.setStatus("Saving Project...");
				setTimeout(writeProject, 25, new File(recentProjectDir));
			}
		}
		
		public function saveAsProject (layerXML:XML, stylesXML:XML):void
		{
			layerData = layerXML;
			projectStyles = stylesXML;
			// get file ref from save window
			initSaveFile ("Save As Project", saveProjectListener);
		}
		
		public function revertProject ():void
		{
			if (!projectIsTemp)
			{
				dispatchEvent (new FileEvent(FileEvent.IO_EVENT, true, false, FileEvent.CLOSE, PROJECT));
				loadProject(recentProject);
			}
		}
		
		public function openStyle (path:String=null):void
		{
			path = (path==null ? openRecentProjectDir : path);
			initOpenFile (path, "Import Style", openStyleListener, [new FileFilter("LiveBrush Style (*.xml)", "*.xml;")]);
		}
		
		public function saveStyle (style:XML):void
		{
			styleData = style;
			initSaveFile ("Export Style", saveStyleListener);
		}
		
		public function openDecoSet (path:String=null):void
		{
			path = (path==null ? openRecentProjectDir : path);
			initOpenFile (path, "Import Decoration Set", openDecoSetListener, [new FileFilter("LiveBrush DecoSet (*.xml)", "*.xml;")]);
		}
		
		public function openDeco (path:String=null):void
		{
			path = (path==null ? openRecentProjectDir : path);
			initOpenFile (path, "Import Decoration", openDecoListener, [new FileFilter("All Formats (*.jpg,*.gif,*.png,*.swf)", "*.jpg;*.gif;*.png;*.swf", "JPEG;jp2_;GIFF;SWFL")]);
		}
		
		public function openLayerImage (path:String=null):void
		{
			path = (path==null ? openRecentProjectDir : path);
			initOpenFile (path, "Import Layer Image", openLayerImageListener, [new FileFilter("All Formats (*.jpg,*.gif,*.png,*.swf)", "*.jpg;*.gif;*.png;*.swf;", "JPEG;jp2_;GIFF;")]);
		}
		
		public function openInputSWF (path:String=null):void
		{
			//path = (path==null ? openRecentProjectDir : path);
			path = appFiles.nativePath + "/Presets/Behaviors/SmoothRandom-AS3-F9.swf";
			// Consol.Trace("FileManager: Behaviors path = " + path);
			try {
				initOpenFile (path, "Import Flash Player 9 (ActionScript 3) File", importInputSWFListener, [new FileFilter("Flash Player 9 SWF (*.swf)", "*.swf;")]);
			} catch (e:Error) {
				// Consol.Trace("FileManager: missing newest appFiles. Copying now.");
				copyAppFiles();
				initOpenFile (path, "Import Flash Player 9 (ActionScript 3) File", importInputSWFListener, [new FileFilter("Flash Player 9 SWF (*.swf)", "*.swf;")]);
			}
		}
		
		public function saveDecoSet (decoSet:XML):void
		{
			decoSetData = decoSet;
			initSaveFile ("Export Decoration Set", saveDecoSetListener);
		}
		
		public function saveImage (bmp:BitmapData):void
		{
			_bitmapData = bmp;
			initSaveFile ("Save Image", saveImageListener);
		}
		
		public function saveSVG (svg:XML):void
		{
			svgData = svg;
			initSaveFile ("Export SVG", saveSVGListener);
		}
		
		private function initSaveFile(title:String, listener:Function):void
		{
			// Open window to select file
			activeFile = (_recentSaveDir=="" ? File.desktopDirectory : new File(_recentSaveDir).parent);
			activeFile.browseForSave(title);
			activeFile.addEventListener(Event.SELECT, checkValidSavePath);
			//activeFile.addEventListener(Event.SELECT, setRecentSaveDir); // This is now done in the checkValidSavePath method
			activeFile.addEventListener(Event.SELECT, listener);
		}
		
		private function initOpenFile(path:String, title:String, listener:Function, fileFilters:Array):void
		{
			// Open window to select file
			//activeFile = new File(); //File.desktopDirectory.resolvePath("Presets/BaseProject/");
			if (path != "") activeFile = new File(path).parent;
			else activeFile = new File(_recentOpenDir=="" ? getRecentProjectPath() : _recentOpenDir).parent; //path;
			activeFile.browseForOpen(title, fileFilters);
			activeFile.addEventListener(Event.SELECT, setRecentOpenDir);
			activeFile.addEventListener(Event.SELECT, listener);
		}
		
		public function getRecentProjectPath():String
		{
			if (recentProject == null)
			{
				// // Consol.Trace ("NO RECENT PROJECT. USING BASE PROJECT: " + File.applicationStorageDirectory.resolvePath("Projects/New Project").nativePath);
				_canvasBgIndex = 1;
				createBaseProject();
			}
			else
			{
				if (!new File(recentProject).exists)
				{
					// // Consol.Trace ("RECENT PROJECT MISSING: " + new File(recentProject).nativePath);
					_canvasBgIndex = 1;
					createBaseProject();
				}
				else
				{
					// // Consol.Trace ("RECENT PROJECT FOUND: " + new File(recentProject).nativePath);
					//loadProject(recentProject);
				}
			}
			
			return recentProject;
		}
		
		public static function getURL (s:String):void
		{
			NavigateUtil.openUrl(s);
		}
		
		
		// PROJECT MANAGEMENT ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function createBaseProject ():void
		{
			//_canvasBgIndex = 1;
			
			// Grab reference to project template
			var baseProjectDir:File = new File();
			baseProjectDir.nativePath = File.applicationStorageDirectory.nativePath+"/Presets/BaseProject";
			
			// Copy project template to default projects directory - no - to temp directory
			// var newProjectDir:File = lbUserDocsDir.resolvePath("Projects/New Project");
			var newProjectDir:File = createTempProjectDir();
			baseProjectDir.copyTo(newProjectDir, true);
			
			// Rename BaseProject.lbp to New Project.lbp
			var baseProjectFile:File = newProjectDir.resolvePath("BaseProject.lbp");
			var newProjectFile = newProjectDir.resolvePath("New Project.lbp");
			baseProjectFile.moveTo(newProjectFile);
			
			// Set recent project vars.
			setProject(newProjectFile);
			
			
			
			
			// // Consol.Trace ("CREATING BASE PROJECT: " + new File(recentProject).nativePath);
			
		}
		
		private function setProject (file:File):void
		{
			saveLocalString ("recentProject", file.nativePath);
		}
		
		private function createSessionProjectDir ():void
		{
			sessionProjectDir = loadLocalString("sessionProjectDir");
			if (sessionProjectDir != "deleted" && sessionProjectDir != null) cleanup(); // in case of crash, or when we're loading a new project in the same session.
			saveLocalString ("sessionProjectDir", File.createTempDirectory().nativePath);
			sessionProjectDir = loadLocalString("sessionProjectDir");
		}
		
		private function createTempProjectDir ():File
		{
			var tempDir:File = File.createTempDirectory();
			saveLocalString ("tempProjectDir", tempDir.nativePath);
			tempProjectDir = loadLocalString("tempProjectDir");
			_projectIsTemp = true;
			return tempDir;
		}
		
		public function deleteSessionProject ():void
		{
			// // Consol.Trace ("DELETE SESSION PROJECT DIR: " + new File(sessionProjectDir).nativePath);
			var sessionDir:File = new File(sessionProjectDir)
			if (sessionDir.exists) sessionDir.deleteDirectory(true);
			saveLocalString ("sessionProjectDir", "deleted");
		}
		
		public function deleteTempProject ():void
		{
			tempProjectDir = loadLocalString("tempProjectDir");
			_projectIsTemp = false;
			if (tempProjectDir != "deleted" && tempProjectDir != null)
			{
				// // Consol.Trace ("DELETE TEMP PROJECT DIR: " + new File(tempProjectDir).nativePath);
				var tempDir:File = new File(tempProjectDir)
				if (tempDir.exists) tempDir.deleteDirectory(true);
				saveLocalString ("tempProjectDir", "deleted");
			}
		}
		
		
		// LOAD METHODS /////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function loadProject (path:String, force:Boolean=false):String
		{
			var projectFile:File = new File(path); // this was previously below
			
			// this event is just for the UI
			dispatchEvent(new FileEvent(FileEvent.BEGIN_LOAD, true, false, FileEvent.OPEN, PROJECT));
			
			// check if project intact
			var stylesFolderExists:Boolean = new File(projectFile.parent.nativePath+"/Styles").exists;
			var styleAssetsFolderExists:Boolean = new File(projectFile.parent.nativePath+"/Styles/Assets").exists;
			if ((!stylesFolderExists || !styleAssetsFolderExists) && !force)
			{
				UI.MAIN_UI.confirmActionDialog({message:"Livebrush has detected missing assets in this project.\nThis may cause instability and/or further project corruption.\nWould you like to continue loading this project?",
											    yesFunction:FileManager.getInstance().loadProject, yesProps:[path, true], noFunction:FileManager.getInstance().newProject, id:"projectLoadError"});
				return "";
			}
			else if ((stylesFolderExists && styleAssetsFolderExists) || force)
			{
				// if all good
				// CanvasManager will update the load display
			}
			

			lastFileLoaded = PROJECT;
			
			decoFilesLoaded = [];
			decoAssetsLoaded = [];
			
			// var projectFile:File = new File(path);
			
			var layerData:String;

			setProject (projectFile);
			
			createSessionProjectDir();
			// // Consol.Trace("LOADING PROJECT: " + path);
			//trace("LOADING PROJECT: " + path);
			// copy project to sessionProjectDir
			new File(recentProjectDir).copyTo(new File(sessionProjectDir), true);
			// all future references to recent project will now use current project - because current project refers to the temp store
			// then we only ever save copies of this to the real location
			
			layerData = loadXML (path);
			//trace(layerData);
			var projectXML:XML = new XML(layerData);
			//Consol.Trace("FileManager: loadProject, _canvasSizeIndex = " + _canvasSizeIndex);
			//Consol.Trace("FileManager: loadProject, Canvas.sizeRes[0][0].x = " + Canvas.sizeRes[0][0].x);
			//Consol.Trace("FileManager: loadProject, Canvas.WIDTH = " + Canvas.WIDTH);
			if (_canvasSizeIndex != -1) 
			{
				projectXML.@size = _canvasSizeIndex;
				_canvasSizeIndex = -1; // reset so the check works next time
			}
			else 
			{
				Canvas.sizeRes[0][0].x = int(projectXML.@width);
				Canvas.sizeRes[0][0].y = int(projectXML.@height);
			}
			//Consol.Trace("FileManager: loadProject, Canvas.sizeRes[0][0].x = " + Canvas.sizeRes[0][0].x);
			// this wouldn't be different yet, because we haven't updated the size index in Canvas
			// This is done from Main.
			//Consol.Trace("FileManager: loadProject, Canvas.WIDTH = " + Canvas.WIDTH);
			
			// if _canvasBgIndex != -1 (then this a new project we're loading)
			// copy bg image to project directory (Layer Images)
			// then add the layer to the layer data xml
			// reset _canvasBgIndex = -1
			if (_canvasBgIndex != -1 && _canvasBgIndex != 0)
			{
				var bgFileName:String = Canvas.defaultBackgrounds[_canvasBgIndex].data;
				//Consol.Trace("FileManager: loadProject: " + appLayerImagesDir.resolvePath(bgFileName).nativePath);
				appLayerImagesDir.resolvePath(bgFileName).copyTo(new File(sessionProjectDir+"/Layer Images/"+bgFileName), true);
				
				projectXML.layers.appendChild(<layer enabled="true" type="image" label={Canvas.defaultBackgrounds[_canvasBgIndex].label} matrix="1,0,0,1,0,0" blendMode="layer" alpha="1" color="4294967295" colorPercent="0" scaleX="1" scaleY="1" rotation="0" x="0" y="0"><solid src={bgFileName}/></layer>);
				
				
			}
			
			_canvasBgIndex = -1;
			
			for (var styleChild:String in projectXML.styles.style)
			{
				var stylePath:String = projectXML.styles.style[styleChild].@xml;
				
				
				var styleFile:File = new File(currentProjectDir+"/Styles/"+stylePath);
				if (styleFile.exists)
				{
					var styleData:String = loadStyle(styleFile.nativePath);
				}
				
				// var styleData:String = loadStyle(currentProjectDir+"/Styles/"+stylePath);
			}
			
			layerData = projectXML.toXMLString();
			
			dispatchEvent (new FileEvent(FileEvent.IO_EVENT, true, false, FileEvent.OPEN, PROJECT, layerData));

			return layerData;
			
		}
		
		public function loadStyle (path:String="", dispatch:Boolean=true):String
		{
			if (new File(path).exists)
			{
				lastFileLoaded = STYLE;
				
				var styleData:String = loadXML(path);
				var styleXML:XML = new XML(styleData);
				var checkStyleXML:XML = new XML(styleData);
				
				// load them all here once so they're cached
				for (var decoChild:String in styleXML.deco.decoList.deco) // xml.* 
				{
					var decoPath:String = styleXML.deco.decoList.deco[decoChild].@value;
					//var assetLoaded:String = loadDeco(currentProjectDir+"/Styles/Assets/"+decoPath); // , initDecoListener
					// we don't need to respond to the deco being loaded
					// because the reference will be added through the decostyle
					// we're just loading the deco here to cache it.
					
					// disabled both of these. this might cause problems if they try to load a style with many huge decos...
					// not sure though. does the deco style preload the decos?
					
					// remove the deco asset from the style xml (so we don't add it)
					//if (assetLoaded == FileEvent.FILE_NOT_FOUND) delete checkStyleXML.deco.decoList.deco[decoChild];
				}
				
				styleXML = checkStyleXML;
				
				if (dispatch) dispatchEvent (new FileEvent(FileEvent.IO_EVENT, true, false, FileEvent.OPEN, STYLE, styleXML.toString()));
				
				return styleXML.toString();
			}
			else
			{
				//trace("file not found");
				dispatchEvent (new FileEvent(FileEvent.FILE_NOT_FOUND, true, false, FileEvent.OPEN, STYLE, "Styles/"+new File(path).name));
				return FileEvent.FILE_NOT_FOUND;
			}
		}
		
		public function decoLoader (fileName:String):Loader
		{
			// this method is redundant. but the other deco load methods are fpo right now.
			// not redundant any more. because we check if we've already loaded the deco.
			decoFilesLoaded.push(fileName); // path is JUST the filename // new File(path).
			return _loadMedia(currentProjectDir+"/Styles/Assets/"+fileName);
		}
		
		public function getDecoAsset (path:String, enabled:Boolean=true, forceNew:Boolean=false):DecoAsset
		{
			// for now, this is different than the deco assets imported, project loaded, style loaded, etc
			// we should combine them all though. but for now, we just use the special array
			// also, consider this when/if we re-implement the no-caching, motion stuff
			// not anymore - because they all use DecoAsset. And DecoAsset does all the checks.
			// i think the other ones are just so we do a preload for decos in styles.. can we eliminate this now?
			
			var decoAsset:DecoAsset = null;
			//// // Consol.Trace(decoAssetsLoaded.length);
			if (decoAssetsLoaded.length == 0 || forceNew)
			{
				//// // Consol.Trace(decoAssetsLoaded);
				decoAsset = new DecoAsset(path);
				decoAsset.enabled = enabled;
				decoAssetsLoaded.push({fileName:path, asset:decoAsset});
			}
			else
			{
				for (var i:int=0; i<decoAssetsLoaded.length; i++)
				{
					if (decoAssetsLoaded[i].fileName == path)
					{
						decoAsset = decoAssetsLoaded[i].asset;
						break;
					}
				}
				if (decoAsset == null) 
				{
					decoAsset = new DecoAsset(path);
					decoAsset.enabled = enabled;
					decoAssetsLoaded.push({fileName:path, asset:decoAsset});
				}
			}
			return decoAsset;
		}
		
		public function loadDeco (path:String="", listener:Function=null):String
		{
			var decoFile:File = new File (path);
			
			if (decoFile.exists)
			{
				var loader:Loader = _loadMedia (decoFile.nativePath);
				if (listener != null) loader.contentLoaderInfo.addEventListener(Event.INIT, listener);
				// we listen for a deco being loaded here only when we're adding a deco to an existing style
				//decoFilesLoaded.push(decoFile.name); // ** very important. this keeps track of the decos loaded, so we know how to rename
				// DecoAsset sets this when it called fileManager.decoLoader. This ensures we dont add duplicates.
				return decoFile.name;
			}
			else
			{
				dispatchEvent (new FileEvent(FileEvent.FILE_NOT_FOUND, true, false, FileEvent.OPEN, DECO, "Assets/"+decoFile.name));
				return FileEvent.FILE_NOT_FOUND;
			}
		}
		
		// For layer background
		public static function loadImage (path:String="", completeListener:Function=null, errorListener:Function=null):Loader
		{
			return FileManager.getInstance()._loadMedia(path, completeListener, errorListener);
		}
		
		public static function loadLayerImage (path:String="", completeListener:Function=null, errorListener:Function=null):Loader
		{
			//// // Consol.Trace("FileManager: loadImageLayer> " + FileManager.getInstance().currentProjectDir+"/Layer Images/"+path);
			return loadImage(FileManager.getInstance().currentProjectDir+"/Layer Images/"+path, completeListener, errorListener);
		}
		
		private function _loadMedia (path:String, completeListener:Function=null, errorListener:Function=null):Loader
		{
			var file:File = new File(path);
			var loader:Loader = new Loader();
			//var appDomain:ApplicationDomain = new ApplicationDomain(
			//var loaderContext:LoaderContext = new LoaderContext(false, 
			// // // Consol.Trace(file.nativePath);
			
			if (completeListener != null) loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeListener);
			if (errorListener != null) loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorListener);
			
			if (file.exists)
			{
				try 
				{  
					//Consol.globalOutput(file.url);
					loader.load(new URLRequest(file.url));
				} 
				catch (error:Error) 
				{  
					trace ("Unable to load requested document.");  
				}  
			}
			else
			{
				// // Consol.Trace("FileManager: Missing media> " + file.nativePath);
				//// // Consol.Trace("FileManager: Need to handle this error properly. Ex: load a dummy image layer from our app files dir");
				loader.load(new URLRequest(file.url));
				return loader;
			}
			
			return loader;
		}
		
		public static function loadAsset (path:String, listener:Function=null):Loader
		{
			return FileManager.getInstance()._loadMedia(path, listener);
		}
		
		public function loadInputSWF (fileName:String, completeListener:Function=null, errorListener:Function=null):Loader
		{
			//// // Consol.Trace(currentProjectDir+"/Styles/Assets/"+fileName);
			return _loadMedia(currentProjectDir+"/Styles/Assets/"+fileName, completeListener, errorListener);
		}
		
		private function loadXML (path:String):String
		{
			var file:File = new File(path);
			
			var fileData:String = "no file: " + path;
			if (file.exists) fileData = open(file);
			
			return fileData;
		}
		
		private function checkVersionOnline ():void
		{
			var versionLoader:URLLoader = new URLLoader();
			versionLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			
			versionLoader.addEventListener(Event.COMPLETE, versionCheckComplete);
			
			versionLoader.load(new URLRequest(ONLINE_VERSION_PATH));
		}
		
		public function loadHelp ():XML
		{
			return new XML(open(helpFile));
		}
		
		
		// IMPORT METHODS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function _importProject (path:String):String
		{
			lastFileLoaded = PROJECT;
			
			var projectFile:File = new File(path); 
			var layerData:String;

			// // Consol.Trace("IMPORTING PROJECT: " + path);
			// // Consol.Trace(currentProjectDir);
			layerData = loadXML (path);
			var projectXML:XML = new XML(layerData);

			//var layerNameDup
			for (var layer:String in projectXML.layers.layer)
			{
				var layerType:String = projectXML.layers.layer[layer].@type
				if (layerType == "image" || layerType == "swf") 
				{
					/*//// // Consol.Trace("FileManager: importing image or swf layer");
					//// // Consol.Trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FileManager: importing image or swf layer");
					var layerFile:File = new File(projectFile.parent.nativePath+"/Layer Images/"+projectXML.layers.layer[layer].solid.@src);
					var currentLayerFileNames:Array = [];
					var list:Array = new File(currentProjectDir+"/Layer Images").getDirectoryListing();
					for (var i:uint=0;i<list.length;i++) currentLayerFileNames.push(removeExtension(list[i].name));
					//// // Consol.Trace(currentLayerFileNames);
					var newLayerFileName:String = createFileNameDup(currentLayerFileNames, layerFile);
					//// // Consol.Trace("FileManager: " + newLayerFileName);
					var newFile:File = new File(currentProjectDir+"/Layer Images/"+newLayerFileName);
					//// // Consol.Trace("New file path: " + newFile.nativePath);
					layerFile.copyTo(new File(currentProjectDir+"/Layer Images/"+newLayerFileName), true);*/
					
					var layerFile:File = new File(projectFile.parent.nativePath+"/Layer Images/"+projectXML.layers.layer[layer].solid.@src);
					var newFile:File = new File(currentProjectDir+"/Layer Images/"+layerFile.name);
					
					if (layerFile.exists)
					{
						var fileName:String = copyFileToUnique(layerFile, newFile);
						newFile = new File(currentProjectDir+"/Layer Images/"+fileName);
					}
					
					// If the file doesn't exist, we just handle it normally - loadError > layer is never added
					//projectXML.layers.layer[layer].solid.@src = newLayerFileName;
					//projectXML.layers.layer[layer].@label = newLayerFileName;
					projectXML.layers.layer[layer].solid.@src = newFile.name;
					projectXML.layers.layer[layer].@label = newFile.name;
				}
			}
			layerData = projectXML.toXMLString();
			
			for (var styleChild:String in projectXML.styles.style)
			{
				var stylePath:String = projectXML.styles.style[styleChild].@xml;
				//var styleData:String = loadStyle(currentProjectDir+"/Styles/"+stylePath);
				//// // Consol.Trace(projectFile.parent.nativePath+"/Styles/"+stylePath)
				
				var styleFile:File = new File(projectFile.parent.nativePath+"/Styles/"+stylePath);
				if (styleFile.exists)
				{
					var styleData:String = importStyle(styleFile.nativePath);
				}
			}
			
			dispatchEvent (new FileEvent(FileEvent.IO_EVENT, true, false, FileEvent.IMPORT, PROJECT, layerData));
			
			return layerData;
		}
		
		public function importStyle (path:String="", dispatch:Boolean=true):String
		{
			lastFileLoaded = STYLE;
			
			var styleData:String;
			var styleXML:XML;
			styleData = loadXML(path);
			styleXML = new XML(styleData);
			//var checkStyleXML:XML = new XML(styleData);
			var decoSetXML:XML = new XML(<decoList></decoList>);
			
			if (styleXML.name() != STYLE)
			{
				dispatchEvent (new FileEvent(FileEvent.WRONG_FILE, true, false, FileEvent.OPEN, STYLE, styleXML.name()));
			}
			else
			{
				// import inputSWF if lineStyle.type is dynamic
				//// // Consol.Trace("inputSWF exists (" + new File(path).name + "): >" + styleXML.line.inputSWF.length() + "< : " + (styleXML.line.inputSWF=="" || styleXML.line.inputSWF==null || styleXML.line.inputSWF=="null") + "");
				if (styleXML.line.inputSWF.length()>0 && styleXML.line.inputSWF.toString() != "" && styleXML.line.inputSWF.toString() != "null")
				{
					//// // Consol.Trace("<<< LOADING INPUT  SWF >>>");
					var inputSWFFile:File = new File().resolvePath(new File(path).parent.nativePath + "/Assets/" + styleXML.line.inputSWF);
					styleXML.line.inputSWF = importInputSWF(inputSWFFile.nativePath, null, false);
				}
				
				
				for (var decoChild:String in styleXML.deco.decoList.deco) // xml.* 
				{
					var decoPath:String = styleXML.deco.decoList.deco[decoChild].@value;
					
					var sourceDecoFile:File = new File();
					sourceDecoFile = sourceDecoFile.resolvePath(new File(path).parent.nativePath+"/Assets/"+decoPath);
					
					var assetLoaded:String = importDeco (sourceDecoFile.nativePath);
					
					// remove the deco asset from the style xml (so we don't add it)
					if (assetLoaded != FileEvent.FILE_NOT_FOUND) 
					{ 
						// add the decoset to the new decoset xml - to be used instead of the imported style deco xml
						// update the xml deco asset file reference (in case it needed to be renamed)
						decoSetXML.appendChild(<deco value={assetLoaded}></deco>);
					}
				}
				
				styleXML.deco.decoList = decoSetXML;
				
				if (dispatch) dispatchEvent (new FileEvent(FileEvent.IO_EVENT, true, false, FileEvent.OPEN, STYLE, styleXML.toString()));
			}
			
			return styleXML;
		}
		
		public function importDecoSet (path:String="", listener:Function=null):void
		{
			lastFileLoaded = DECOSET;
			
			var decoSetData:String;
			var decoSetXML:XML;
			decoSetData = loadXML (path);
			decoSetXML = new XML(decoSetData);
		
			if (decoSetXML.name() != DECOSET)
			{
				dispatchEvent (new FileEvent(FileEvent.WRONG_FILE, true, false, FileEvent.OPEN, DECOSET, decoSetXML.name()));
			}
			else
			{
		
				for (var decoChild:String in decoSetXML.deco) // xml.* 
				{
					var decoPath:String = decoSetXML.deco[decoChild].@value;
					
					var sourceDecoFile:File = new File(new File(path).parent.nativePath+"/Assets/"+decoPath);
					
					importDeco (sourceDecoFile.nativePath, listener);
	
				}
			}

		}
		
		public function importDeco(path:String="", listener:Function=null):String
		{
			lastFileLoaded = DECO;
			
			var decoFile:File = new File (path);
			
			if (decoFile.exists)
			{
				var newFile = new File(currentProjectDir+"/Styles/Assets/"+decoFile.name);
				
				var fileName:String = copyFileToUnique(decoFile, newFile);
				newFile = new File(currentProjectDir+"/Styles/Assets/"+fileName);
				
				
				loadDeco(newFile.nativePath, listener)
					
				return newFile.name; 
			}
			else
			{
				return loadDeco(decoFile.nativePath);
			}
		}
		
		public function importInputSWF(path:String="", listener:Function=null, dispatch:Boolean=true):String
		{
			var swfFile:File = new File (path);
			var newName:String = swfFile.name;
			
			if (swfFile.exists)
			{
				var newFile = new File(currentProjectDir+"/Styles/Assets/"+swfFile.name);
				
				//var decoNamesLoaded:Array = [];
				//for (var i:int=0;i<decoAssetsLoaded.length; i++) decoNamesLoaded.push(removeExtension(decoAssetsLoaded[i].fileName));
				
				//// // Consol.Trace(newFile.nativePath);
				//if (newFile.exists)
				//{
					//// // Consol.Trace("file exists in assets");
					// decoFilesLoaded should be styleAssetsLoaded. for now we'll assume this but use it as is.
					//var newFileName:String = createFileNameDup (decoFilesLoaded, newFile);
					//var newFileName:String = createFileNameDup (decoNamesLoaded, newFile);
					//// // Consol.Trace("new name: " + newFileName);
					//newFile = new File(currentProjectDir+"/Styles/Assets/"+newFileName);
					
					//newName = newFile.name;
				//}
				
				//swfFile.copyTo(newFile, true);
				
				var fileName:String = copyFileToUnique(swfFile, newFile);
				newFile = new File(currentProjectDir+"/Styles/Assets/"+fileName);
				
				newName = newFile.name;
				
				// decoFilesLoaded should be styleAssetsLoaded. for now we'll assume this but use it as is.
				//decoAssetsLoaded.push(newFile.name);
				decoAssetsLoaded.push({fileName:newName, asset:null});
				
				if (dispatch) dispatchEvent (new FileEvent(FileEvent.IO_EVENT, true, false, FileEvent.OPEN, INPUT_SWF, newFile)); // .content, .url
			
				return newName; 
			}
			
			return "";
		}
		
		
		// WRITE/EXPORT METHODS /////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function writeProject(file:File):void
		{
			try 
			{
				if (file.extension!=null) file = file.resolvePath(removeExtension(file.nativePath));
				file.createDirectory();
				
				// save everything to local store
				var recentProjectFile:File = new File(recentProject);
				var newProjectFile:File = (recentProjectFile.name != file.name+".lbp") ? renameFile(new File(currentProject), file.name+".lbp") : new File(currentProject); //recentProjectFile;
				
				var projectXML:XML = new XML(<LiveBrushProject size={Canvas.SIZE_INDEX} width={Canvas.WIDTH} height={Canvas.HEIGHT} name={file.name} version="1"></LiveBrushProject>);
				projectXML.appendChild(<styles></styles>); // this is for the short list of style asset paths. not style definitions.
				
				projectXML.appendChild(layerData);

				for (var style:String in projectStyles.style)
				{
					var styleFile:File = new File(currentProjectDir).resolvePath(currentProjectDir+"/Styles/"+projectStyles.style[style].@name+".xml");
					
					save (styleFile, projectStyles.style[style].toString());
					
					projectXML.styles.appendChild(<style xml={styleFile.name} />);
				}
				
				save (newProjectFile, projectXML.toString());
			
				new File(currentProjectDir).copyTo(file, true);
				// This stuff used to be outside of the try
				// but I'm putting it in to possibly save a project if there is a problem writing to it
				setProject(file.resolvePath(file.name+".lbp"));
				deleteTempProject();
				// // Consol.Trace("FileManager: Project Saved");
				dispatchEvent(new FileEvent(FileEvent.SAVE, true, false, FileEvent.PROJECT_SAVED, PROJECT));
			}
			catch (error:Error)
			{
				// This error would happen when the user has one of the files in the project subfolder open. Or My Documents...
				// There's no way around this, because we can't/shouldn't close that file. 
				// So save a backup on the users desktop.
				/*var dup:int = 0;
				var desktopProject:File;
				do
				{
				  desktopProject = File.desktopDirectory.resolvePath((projectName + " Backup " + (dup+1)));
				  dup++;
				} while (desktopProject.exists);
				desktopProject.createDirectory();
				new File(currentProjectDir).copyTo(desktopProject, true);*/
				writeProjectBackup();
				// // Consol.Trace("FileManager: Project save error");
				dispatchEvent (new FileEvent(FileEvent.IO_ERROR, true, false, FileEvent.SAVE, PROJECT));
			}
			
			UI.setStatus("Ready");

		}
		
		private function writeProjectBackup ():File
		{
			// copyFileToUnique(decoFile, newFile);
			var dup:int = 0;
			var desktopProject:File;
			do
			{
			  desktopProject = File.desktopDirectory.resolvePath((projectName + " Backup " + (dup+1)));
			  dup++;
			} while (desktopProject.exists);
			desktopProject.createDirectory();
			new File(currentProjectDir).copyTo(desktopProject, true);
			return desktopProject;
		}
		
		private function exportProject(file:File):void
		{
			// this method should never be used to actually export a project. just use save.
			// instead, this is part of the clean-up project method.
			
			//if (file.extension!=null) file = file.resolvePath(removeExtension(file.nativePath));
			//file.createDirectory();
			
			// save everything to local store
			//var recentProjectFile:File = new File(recentProject);
			//var newProjectFile:File = (recentProjectFile.name != file.name+".lbp") ? renameFile(new File(currentProject), file.name+".lbp") : new File(currentProject); //recentProjectFile;
			var newProjectFile:File = file;
			
			var projectXML:XML = new XML(<LiveBrushProject size={Canvas.SIZE_INDEX} width={Canvas.WIDTH} height={Canvas.HEIGHT} name={file.name} date="08/03/82" version="1"></LiveBrushProject>);
			projectXML.appendChild(<styles></styles>); // this is for the short list of style asset paths. not style definitions.
			
			projectXML.appendChild(layerData);
			
			for (var style:String in projectStyles.style)
			{
				var styleFile:File = new File(currentProjectDir).resolvePath(currentProjectDir+"/Styles/"+projectStyles.style[style].@name+".xml");
				
				//save (styleFile, projectStyles.style[style].toString());
				styleData = projectStyles.style[style];
				exportStyle(new File(file.parent.nativePath+"/Styles/"+styleFile.name), false);
				
				projectXML.styles.appendChild(<style xml={styleFile.name} />);
			}
			
			save (newProjectFile, projectXML.toString());

			new File(file.parent.nativePath + "/Layer Images").createDirectory();
			new File(file.parent.nativePath + "/Styles").createDirectory();
			new File(file.parent.nativePath + "/Styles/Assets").createDirectory();
			
			for (var layer:String in projectXML.layers.layer)
			{
				var layerType:String = projectXML.layers.layer[layer].@type
				if (layerType == "image" || layerType == "swf") 
				{
					// currentProjectDir+"/Layer Images/"
					var layerFile:File = new File(currentProjectDir+"/Layer Images/"+projectXML.layers.layer[layer].solid.@src);
					var newFile:File = new File(file.parent.nativePath+"/Layer Images/"+layerFile.name);
					
					if (layerFile.exists)
					{
						try {   var fileName:String = copyFileToUnique(layerFile, newFile);   } catch(e:Error){} 
						// it should always be unique in this case
						//newFile = new File(currentProjectDir+"/Layer Images/"+fileName);
					}
				}
			}

		}
		
		private function exportStyle(file:File, createDirectory:Boolean=true):void
		{
			// // Consol.Trace("FileManager: exporting style");
			
			if (createDirectory)
			{
				if (file.extension!=null) file = file.resolvePath(removeExtension(file.nativePath));
				file.createDirectory();
				file = new File(file.nativePath+"/"+file.name);
				if(!file.extension || file.extension.toLowerCase() != "xml") file.nativePath += ".xml";
			}
			
			decoSetData = XML(styleData.deco.decoList);
			
			var styleAssetDir:File;
			if (createDirectory) styleAssetDir = exportDecoSet(file.parent);
			else styleAssetDir = exportDecoSet(file, false);
			
			if (styleData.line.inputSWF.length()>0 && styleData.line.inputSWF.toString() != "" && styleData.line.inputSWF.toString() != "null")
				exportDynamicInput(styleAssetDir, styleData.line.inputSWF);
			
			save (file, styleData);
		}
		
		private function exportDynamicInput (file:File, inputFileName:String):void
		{
			// // Consol.Trace("FileManager: exporting dynamic input SWF");
			
			try {   new File(currentProjectDir+"/Styles/Assets/"+inputFileName).copyTo(new File(file.nativePath+"/"+inputFileName));   } catch(e:Error){}
		}
		
		private function exportDecoSet(file:File, createDirectory:Boolean=true):File
		{
			// // Consol.Trace("FileManager: exporting decoset");
			
			if (createDirectory)
			{
				if (file.extension!=null) file = file.resolvePath(removeExtension(file.nativePath));
				file.createDirectory();
				file = new File(file.nativePath+"/"+file.name);
				if(!file.extension || file.extension.toLowerCase() != "xml") file.nativePath += ".xml";
			}
			
			var decoSourceFile:File;
			var decoDestFile:File = new File(file.parent.nativePath+"/Assets/"+file.name);
			for (var decoChild:String in decoSetData.deco)
			{
				decoSourceFile = new File(currentProjectDir+"/Styles/Assets/"+decoSetData.deco[decoChild].@value);
				decoDestFile = new File(file.parent.nativePath+"/Assets/"+decoSourceFile.name);
				try {   decoSourceFile.copyTo(decoDestFile);   } catch(e:Error){}
			}
			
			if (createDirectory) save (file, decoSetData);
			
			return decoDestFile.parent;
		}

		public function exportImage (file:File):void
		{
			if (file.extension != null) file = file.resolvePath(removeExtension(file.nativePath));
			file = new File(file.nativePath+".png");
			try {
				writeImage(_bitmapData, file);
			} catch (e:Error) {
				UI.MAIN_UI.alert({message:"Error Saving: Out of memory.\nPlease close any other applications and try again.", id:"saveImageError"});
			} finally {
				_bitmapData.dispose();
			}
		}
		
		public function saveFlattenedLayerImage (bmp:BitmapData, name:String, unique:Boolean=true):String
		{
			var file:File = new File(layerImagesDir + "/" + name + ".png");
			if (unique) file = getUniqueFile(file);
			
			writeImage(bmp, file);
			bmp.dispose();
			return file.name;
		}
		
		private function exportSVG(file:File):void
		{
			if(!file.extension || file.extension.toLowerCase() != "xml") file.nativePath += ".svg";
			
			save (file, svgData);
		}

		
		// FILE SYSTEM ACCESS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function open (file:File):String
		{
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			var fileData:String = stream.readUTFBytes(stream.bytesAvailable);
			stream.close();
			return fileData;
		}
		
		private function save (file:File, data:String):void
		{
			data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" + data;
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(data);
			stream.close();
		}
		
		private function saveLocalString (label:String, data:String):void
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(data);
			EncryptedLocalStore.setItem(label, bytes);
		}
		
		private function loadLocalString (label:String):String
		{
			var storedValue:ByteArray = EncryptedLocalStore.getItem(label);
			if (storedValue != null) return storedValue.readUTFBytes(storedValue.length);
			else return null;
		}
		
		private function deleteLocalString (label:String):void
		{
			EncryptedLocalStore.removeItem(label);
		}
		
		private function writeImage (bmp:BitmapData, file:File):void
		{
			var png = PNGEncoder.encode(bmp);

			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeBytes(png, 0, 0);
			stream.close(); 
		}
		
		
		// LISTENERS ////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function versionCheckComplete (e:Event):void
		{
			var currentMajorVersion:int =  int(e.target.data.currentMajorVersion);
			var version:String = String(e.target.data["version"+Main.MAJOR_VERSION]);
			var vString:String = compareVersion(version);
			
			// Consol.Trace("FileManager: Version Check Complete: vString = " + vString);
			
			if (vString == "older") 
			{
				// Consol.Trace("FileManager: OLDER VERSION");
				dispatchEvent(new FileEvent(FileEvent.VERSION_UPDATE, false, false, null, FileEvent.UPDATE_VERSION, {currentVersion:appSettings.version, newVersion:version}));
			}
			else if (vString == "current") 
			{
				// Consol.Trace("FileManager: NEXT MAJOR VERSION OR CURRENT");
				if (currentMajorVersion > Main.MAJOR_VERSION) dispatchEvent(new FileEvent(FileEvent.VERSION_UPDATE, false, false, null, FileEvent.NEW_VERSION, {currentVersion:Main.MAJOR_VERSION, newVersion:currentMajorVersion}));
				else if (showVersionCheckResult) dispatchEvent(new FileEvent(FileEvent.VERSION_UPDATE, false, false, null, FileEvent.CURRENT_VERSION, {currentVersion:appSettings.version, newVersion:version}));
			} else if (vString=="newer") {
				// Consol.Trace("FileManager: THIS VERSION IS NEWER");
				//if (showVersionCheckResult) dispatchEvent(new FileEvent(FileEvent.VERSION_UPDATE, false, false, null, FileEvent.CURRENT_VERSION, {currentVersion:appSettings.version, newVersion:version}));
			}
			
			showVersionCheckResult = false;
		}
		
		private function openProjectListener (e:Event):void
		{
			dispatchEvent (new FileEvent(FileEvent.IO_EVENT, true, false, FileEvent.CLOSE, PROJECT));
			activeFile.removeEventListener(Event.SELECT, openProjectListener);
			loadProject(File(e.target).nativePath);
		}
		
		private function importProjectListener (e:Event):void
		{
			//dispatchEvent (new FileEvent(FileEvent.IO_EVENT, true, false, FileEvent.CLOSE, PROJECT));
			activeFile.removeEventListener(Event.SELECT, importProjectListener);
			_importProject(File(e.target).nativePath);
		}
		
		private function openStyleListener (e:Event):void
		{
			activeFile.removeEventListener(Event.SELECT, openStyleListener);
			importStyle(File(e.target).nativePath);
		}
		
		private function openDecoSetListener (e:Event):void
		{
			activeFile.removeEventListener(Event.SELECT, openDecoSetListener);
			importDecoSet(File(e.target).nativePath, initDecoImportListener);
		}
		
		private function openDecoListener (e:Event):void
		{
			activeFile.removeEventListener(Event.SELECT, openDecoListener);
			importDeco(File(e.target).nativePath, initDecoImportListener);
		}
		
		private function importInputSWFListener (e:Event):void
		{
			e.target.removeEventListener(Event.INIT, importInputSWFListener);
			importInputSWF(File(e.target).nativePath);
		}
		
		private function initDecoImportListener (e:Event):void
		{
			e.target.removeEventListener(Event.INIT, initDecoImportListener);
			dispatchEvent (new FileEvent(FileEvent.IO_EVENT, true, false, FileEvent.OPEN, DECO, e.target)); // .content, .url
		}
		
		private function saveImageListener (e:Event):void
		{
			e.target.removeEventListener(Event.SELECT, saveImageListener);	
			exportImage(e.target as File);
		}
		
		private function saveDecoSetListener (e:Event):void
		{
			e.target.removeEventListener(Event.SELECT, saveDecoSetListener);	
			exportDecoSet(e.target as File);
		}
		
		private function saveStyleListener (e:Event):void
		{
			e.target.removeEventListener(Event.SELECT, saveStyleListener);	
			exportStyle(e.target as File);
		}
		
		private function saveSVGListener (e:Event):void
		{
			e.target.removeEventListener(Event.SELECT, saveSVGListener);	
			exportSVG(e.target as File);
		}
		
		private function saveProjectListener (e:Event):void
		{
			e.target.removeEventListener(Event.SELECT, saveProjectListener);	
			UI.setStatus("Saving Project...");
			setTimeout(writeProject, 25, e.target as File);
			//writeProject(e.target as File);
		}
		
		private function openLayerImageListener (e:Event):void
		{
			
			activeFile.removeEventListener(Event.SELECT, openLayerImageListener);
			//loadImage(File(e.target).nativePath, layerImageImportListener);
			// we don't load the layer image here. the layer object takes care of this
			// but we still copy the image to our project Layer Images directory
			// so the relative path passed to the layer object will work.
			// We always copy and load media assets from the project directory.
			
			
			
			
			
			
			//activeFile.copyTo(new File(layerImagesDir+"/"+activeFile.name), true);
			
			var fileName:String = copyFileToUnique(activeFile, new File(layerImagesDir+"/"+activeFile.name));
			// For all copying, we need to make duplicate file names
			// create a method to do this - it would be a wrapper for copyTo
			// each time you replace this method throughout - THOROUGHLY CONSIDER THE consequences and TEST
			// DONE!
			
			var type:String = activeFile.extension.toUpperCase();//decoFile.type.toUpperCase();
			//// // Consol.Trace("FileManager: decoToLayer file type> " + type);
			type = (type.indexOf("SWF")>-1 ? SWF : LAYER_IMAGE);
			
			dispatchEvent (new FileEvent(FileEvent.IO_EVENT, true, false, FileEvent.OPEN, type, fileName)); // .content, .url
			// (activeFile.type.indexOf("swf")>-1?SWF:LAYER_IMAGE)
			
		}
		
		private function setRecentOpenDir (e:Event):void
		{
			activeFile.removeEventListener(Event.SELECT, setRecentOpenDir);
			_recentOpenDir = e.target.nativePath;
		}
		
		private function checkValidSavePath (e:Event):void
		{
			var file:File = e.target as File;
			var projectDir:File = new File(recentProjectDir);
			var layersDir:File = new File(recentProjectDir+"/Layer Images");
			var stylesDir:File = new File(recentProjectDir+"/Styles");
			var styleAssetsDir:File = new File(recentProjectDir+"/Styles/Assets");
			
			//// // Consol.Trace("FileManager: file = " + file.parent.nativePath + " : " + projectDir.nativePath);
			
			if (file.parent.nativePath == projectDir.nativePath || 
				file.parent.nativePath == layersDir.nativePath || 
				file.parent.nativePath == stylesDir.nativePath || 
				file.parent.nativePath == styleAssetsDir.nativePath)
			{
				e.stopImmediatePropagation();
				UI.MAIN_UI.alert({message:"Save Location Error\nYou can't save to a project folder (or its subfolders). Please save to another location.", id:"saveLocationAlert"});
			}
			else
			{
				_recentOpenDir = e.target.nativePath;
			}
		}
		
		private function setRecentSaveDir (e:Event):void
		{
			activeFile.removeEventListener(Event.SELECT, setRecentSaveDir);
			_recentSaveDir = e.target.nativePath;
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public static function copyFileToUnique (fromFile:File, toFile:File, dupNameSuffix:String=""):String
		{
			if (toFile.exists)
			{
				/*var dirFileNames:Array = [];
				var list:Array = toFile.parent.getDirectoryListing();
				for (var i:uint=0;i<list.length;i++) dirFileNames.push(FileManager.getInstance().removeExtension(list[i].name));
				var newFileName:String = FileManager.getInstance().createFileNameDup(dirFileNames, toFile);*/
				//var newFile:File = new File(toFile.parent.nativePath + "/" + newFileName);
				var newFile:File = getUniqueFile(toFile);
				fromFile.copyTo(newFile, true);
				toFile = newFile;
			}
			else
			{
				fromFile.copyTo(toFile, true);
			}
			
			return toFile.name;
		}
		
		public static function getUniqueFile (file:File, dupNameSuffix:String=""):File
		{
			var newFileName:String = file.name;
			if (file.exists)
			{
				var dirFileNames:Array = [];
				var list:Array = file.parent.getDirectoryListing();
				for (var i:uint=0;i<list.length;i++) dirFileNames.push(FileManager.getInstance().removeExtension(list[i].name));
				newFileName = FileManager.getInstance().createFileNameDup(dirFileNames, file);
			}
			return new File(file.parent.nativePath+"/"+newFileName);
		}
		
		public function copyDecoToLayer (path:String, batch:Boolean=false):void
		{
			//// // Consol.Trace(path);
			var decoFile:File = new File(decoAssetsDir+"/"+path);
			//// // Consol.Trace("FileManager: decoToLayer file> " + path);
			//decoFile.copyTo(new File(layerImagesDir+"/"+decoFile.name), true);
			var fileName:String = copyFileToUnique(decoFile, new File(layerImagesDir+"/"+decoFile.name));
			var type:String = decoFile.extension.toUpperCase();//decoFile.type.toUpperCase();
			//// // Consol.Trace("FileManager: decoToLayer file type> " + type);
			type = (type.indexOf("SWF")>-1 ? SWF : LAYER_IMAGE);
			//// // Consol.Trace("FileManager: decoToLayer file type> " + type);
			dispatchEvent (new FileEvent(FileEvent.IO_EVENT, true, false, batch?FileEvent.BATCH_OPEN:FileEvent.OPEN, type, fileName));
			//  (decoFile.type.indexOf("swf")>-1?SWF:LAYER_IMAGE)
		}
		
		public function copyLayerToDeco (path:String):String
		{
			
			var layerFile:File = new File(layerImagesDir+"/"+path);
			
			// not sure about doing this one - how does the app know the new file name?
			//layerFile.copyTo(new File(decoAssetsDir+"/"+layerFile.name), true);
			var fileName:String = copyFileToUnique(layerFile, new File(decoAssetsDir+"/"+layerFile.name));
			
			//// // Consol.Trace(new File(decoAssetsDir+"/"+layerFile.name).nativePath);
			//dispatchEvent (new FileEvent(FileEvent.IO_EVENT, true, false, FileEvent.OPEN, (decoFile.type.indexOf("swf")>-1?SWF:LAYER_IMAGE), decoFile.name));
		
			return fileName;
		}
		
		private function renameFile(file:File, newName:String):File
		{
			var newFile:File = file.resolvePath("../"+newName);
			file.moveTo(newFile, true);
			return newFile;
		}
		
		public static function removeWhiteSpace (str:String, replace:String="-"):String
		{
			return str.split(" ").join(replace);
		}
		
		public static function createNameDup (list:Array=null, name:String=null, prop:String=null):String
		{
			//// // Consol.Trace(list + " : " + name)
			var dup:int = 0;
			var rootName:String = name;
			for (var i:int=0;i<list.length; i++) 
			{
				if (prop == null) 
				{
					//if (list[i].substr(0,name.length) == name) dup++;
					if (list[i] == name) dup++;
				}
				else 
				{
					//// // Consol.Trace(list[i][prop].substr(0,name.length) + " : " + name)
					//if (list[i][prop].substr(0,name.length) == name) dup++;
					if (list[i][prop] == name) dup++;
				}
			}
			//// // Consol.Trace("Duplicates: " + dup)
			//if (dup > 0) name = name + " (" + (dup+1) + ")";
			if (dup > 0) 
			{
				do
				{
					name = rootName + " (" + (dup+1) + ")";
					dup++
				} while (name != createNameDup(list, name, prop))
				// create the new name. try to create a dup of it. If it comes back the same, we're good. otherwise, try again!
			}
			
			return name;
		}
		
		public function removeExtension (fileName:String):String
		{
			return fileName.substring(0, fileName.lastIndexOf("."));
		}
		
		public function getExtension (fileName:String):String
		{
			return fileName.substr(fileName.lastIndexOf("."));
		}

		public function createFileNameDup (list:Array, file:File, prop:String=null):String
		{
			return createNameDup (list, removeExtension(file.name), prop) + getExtension(file.name);
		}
	
	}
	
}