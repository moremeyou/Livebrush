package com.livebrush.ui
{
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import com.livebrush.tools.TransformTool;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.events.TitlebarEvent;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.UIUpdate;
	import com.livebrush.ui.MainMenuController;
	import com.livebrush.data.GlobalSettings;
	
	public class MainMenuView extends UIView
	{
		
		private var _mainMenu				:NativeMenu;
		private var _fileMenuItem			:NativeMenuItem;
		private var _editMenu				:NativeMenuItem;
		private var _modifyMenuItem			:NativeMenuItem;
		private var _layerMenuItem			:NativeMenuItem;
		private var _styleMenu				:NativeMenuItem;
		private var _controlMenu			:NativeMenuItem;
		private var _shareMenu				:NativeMenuItem;
		private var _windowMenu				:NativeMenuItem;
		private var _helpMenu				:NativeMenuItem;
		
		private var menuItemNames			:Array;
		private var menuItems				:Array;
		//private var menuNames				:Array;
		//private var menus					:Array;
		
		public function MainMenuView (ui:UI):void
		{
			super(ui);
			
			menuItemNames = [];
			menuItems = [];
			//menuNames = [];
			//menus = [];
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get mainMenu ():NativeMenu {   return _mainMenu;   }
		public function get fileMenu ():NativeMenu {   return _fileMenuItem.submenu;   }
		//public function get modifyMenu ():NativeMenu {   return _modifyMenuItem.submenu;   }
		public function get layerMenu ():NativeMenu {   return _layerMenuItem.submenu;   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			initNativeMenu();
		}
		
		protected override function createController ():void
		{
			controller = new MainMenuController(this);
		}

		private function initNativeMenu ():void
		{
			/*
			<item label=" Export Image..." name="saveImageWeb" primKey="" isSeparator="false" />
						<item label=" Export Layer(s) To Image...  " name="exportLayer" primKey="" isSeparator="false" />
						*/
			
			/*<item label=" Save As Image " name="saveAsImage" primKey="" isSeparator="false">
							<item label=" Normal Quality (72dpi)...  " name="saveImageWeb" primKey="" isSeparator="false" />
							<item label=" High Quality (150dpi)..." name="saveImageHigh" primKey="" isSeparator="false" />
							<item label=" Print Quality (300dpi)..." name="saveImagePrint" primKey="" isSeparator="false" />
							<item label=" Publish Quality (600dpi)..." name="saveImagePub" primKey="" isSeparator="false" />
						</item>*/
			// <item label=" Save As Image...  " name="saveImageWeb" primKey="S" isSeparator="false" />
					
			
			/*<item label=" Attach Layer to Edge(s)" name="layerToDeco" primKey="" isSeparator="false"/>
					<item label=" Copy Layer to Edge(s)" name="copyLayerToDeco" primKey="" isSeparator="false"/>
					<item label=" Attach Layer to Edge(s) in place" name="iCopyLayerToDeco" primKey="" isSeparator="false"/>
					<item label=" Copy Layer to Edge(s) in place" name="" primKey="" isSeparator="false"/>*/
					
			// <item label=" Cut" name="cut" primKey="x" isSeparator="false"/>
			// <item label=" Detach Edge Decorations to Layer(s)  " name="detachEdgeDecos" primKey="" isSeparator="false"/>
			
			// These were in style at bottom
			// <item label="" name="" primKey="" isSeparator="true"/>
			// <item label=" Load Tutorial Styles" name="" primKey="" isSeparator="false"/>
			// <item label=" Reset Styles" name="" primKey="" isSeparator="false"/>
			
			//{getRecentProjectList()}
			var mainMenuXML:XML = 
			<menu>
				<item label="File" name="file" primKey="" isSeparator="false">
					<item label=" New" name="new" primKey="n" isSeparator="false" />
					<item label=" Open..." name="open" primKey="o" isSeparator="false" />
					<item label="" name="" primKey="" isSeparator="true" />
					<item label=" Save" name="save" primKey="s" isSeparator="false" />
					<item label=" Save As...  " name="saveAs" primKey="S" isSeparator="false" />
					<item label=" Revert" name="revert" primKey="" isSeparator="false" />
					<item label=" Cleanup" name="cleanup" primKey="" isSeparator="false" />
					<item label="" name="" primKey="" isSeparator="true" />
					<item label=" Import" name="import" primKey="" isSeparator="false">
						<item label=" Import Project..." name="importProject" primKey="" isSeparator="false" />
						<item label=" Import Style..." name="importStyle" primKey="" isSeparator="false" />
						<item label=" Import Deco Set...  " name="importDecoSet" primKey="" isSeparator="false" />
						<item label=" Import Decoration...  " name="importDeco" primKey="" isSeparator="false" />
						<item label=" Import Image..." name="importImage" primKey="" isSeparator="false" />
						<item label=" Import Dynamic Input SWF...  " name="importInputSWF" primKey="" isSeparator="false" />
					</item>
					<item label=" Export" name="export" primKey="" isSeparator="false">
						<item label=" Export Image..." name="saveImage" primKey="" isSeparator="false" />
						<item label=" Export Layer(s) To Image...  " name="saveLayerImage" primKey="" isSeparator="false" />
						<item label="" name="" primKey="" isSeparator="true" />
						<item label=" Export Line(s) To SVG...  " name="exportSVG" primKey="" isSeparator="false" />
						<item label="" name="" primKey="" isSeparator="true" />
						<item label=" Export Style..." name="exportStyle" primKey="" isSeparator="false" />
						<item label=" Export Deco Set... " name="exportDecoSet" primKey="" isSeparator="false" />
					</item>
					<item label="" name="" primKey="" isSeparator="true" />
					<item label=" Exit" name="exit" primKey="q" isSeparator="false" />
				</item>
				<item label="Edit" name="edit" primKey="" isSeparator="false">
					<item label=" Undo" name="undo" primKey="z" isSeparator="false"/>
					<item label=" Redo" name="redo" primKey="y" isSeparator="false"/>
					<item label="" name="" primKey="" isSeparator="true"/>
					<item label=" Copy" name="copy" primKey="c" isSeparator="false"/>
					<item label=" Paste" name="paste" primKey="v" isSeparator="false"/>
					<item label=" Delete" name="delete" primKey="BACKSPACE" isSeparator="false"/>
					<item label="" name="" primKey="" isSeparator="true"/>
					<item label=" Select All" name="selectAll" primKey="a" isSeparator="false"/>
					<item label=" Deselect All" name="deselectAll" primKey="A" isSeparator="false"/>
					<item label="" name="" primKey="" isSeparator="true"/>
					<item label=" Preferences...  " name="showGlobalPrefs" primKey="" isSeparator="false"/>
				</item>
				<item label="Layer" name="layer" primKey="" isSeparator="false">
					<item label=" Duplicate Layer" name="dupLayer" primKey="d" isSeparator="false"/>
					<item label=" Flatten Layer(s) to Image Layer" name="flattenLayers" primKey="" isSeparator="false"/>
					<item label="" name="" primKey="" isSeparator="true"/>
					<item label=" Transform  " name="" primKey="" isSeparator="false">
						<item label=" Flip Horizontal" name="flipX" primKey="" isSeparator="false"/>
						<item label=" Flip Vertical" name="flipY" primKey="" isSeparator="false"/>
						<item label="" name="" primKey="" isSeparator="true"/>
						<item label=" Rotate 90° CW" name="rotateClock" primKey="" isSeparator="false"/>
						<item label=" Rotate 90° CCW" name="rotateCounter" primKey="" isSeparator="false"/>
						<item label="" name="" primKey="" isSeparator="true"/>
						<item label=" Reset Scale  " name="resetScale" primKey="" isSeparator="false"/>
						<item label=" Reset Rotation  " name="resetRotation" primKey="" isSeparator="false"/>
						<item label=" Reset Skew  " name="resetSkew" primKey="" isSeparator="false"/>
						<item label=" Reset Layer Transformations  " name="resetTransform" primKey="" isSeparator="false"/>
					</item>
					<item label="" name="" primKey="" isSeparator="true"/>
					<item label=" Simplify Line" name="simplifyLine" primKey="" isSeparator="false"/>
					<item label=" Subdivide Line" name="subdivideLine" primKey="" isSeparator="false"/>
					<item label="" name="" primKey="" isSeparator="true"/>
					<item label=" Copy Selected Decos to Layer(s)" name="copyEdgeDecos" primKey="" isSeparator="false"/>
					<item label=" Remove Selected Decos from Line  " name="removeEdgeDecos" primKey="" isSeparator="false"/>
					<item label="" name="" primKey="" isSeparator="true"/>
					<item label=" Redraw Selected Layers  " name="redrawLayers" primKey="u" isSeparator="false"/>
				</item>
				<item label="Style" name="style" primKey="" isSeparator="false">
					<item label=" Apply Current Style" name="applyStyle" primKey="" isSeparator="false"/>
					<item label=" Convert To Straight Line" name="toStraightLine" primKey="" isSeparator="false"/>
					<item label=" Convert To Smooth Line" name="toSmoothLine" primKey="" isSeparator="false"/>
					<item label="" name="" primKey="" isSeparator="true"/>
					<item label=" Create Layer from Decoration  " name="styleDecoToLayer" primKey="" isSeparator="false"/>
					<item label=" Create Decoration from Layer(s)  " name="layersToDeco" primKey="" isSeparator="false"/>
					<item label="" name="" primKey="" isSeparator="true"/>
					<item label=" Get More Styles..." name="shareStyles" primKey="" isSeparator="false"/>
					<item label=" Get More Decorations..." name="shareDecos" primKey="" isSeparator="false"/>
				</item>
				<item label="Control" name="control" primKey="" isSeparator="false">
					<item label=" Stop All Brushes  " name="stopAllBrushes" primKey="B" isSeparator="false"/>
					<item label=" Stop Last Brush  " name="stopLastBrush" primKey="b" isSeparator="false"/>
				</item>
				<item label="Share" name="share" primKey="" isSeparator="false">
					<item label=" Share Your Styles & Decorations...  " name="shareStyles" primKey="" isSeparator="false"/>
					<item label=" Develop Input Behaviors...  " name="develop" primKey="" isSeparator="false"/>
					<item label="" name="" primKey="" isSeparator="true"/>
					<item label=" Share Your Designs on Facebook...  " name="facebook" primKey="" isSeparator="false"/>
					<item label=" Follow Livebrush on Twitter...  " name="twitter" primKey="" isSeparator="false"/>
				</item>
				<item label="View" name="window" primKey="" isSeparator="false">
					<item label=" Zoom In  " name="zoomIn" primKey="=" isSeparator="false"/>
					<item label=" Zoom Out  " name="zoomOut" primKey="-" isSeparator="false"/>
					<item label="" name="" primKey="" isSeparator="true"/>
					<item label=" Brush Styles" name="toggleStyleList" primKey="w" isSeparator="false" />
					<item label=" Style Preview  " name="stylePreview" primKey="p" isSeparator="false"/>
					<item label=" Tool/Style Settings  " name="toggleToolProps" primKey="e" isSeparator="false"/>
					<item label=" Layers" name="toggleLayerProps" primKey="r" isSeparator="false"/>
					<item label="" name="" primKey="" isSeparator="true"/>
					<item label=" Hide/Show Interface  " name="toggleUI" primKey="h" isSeparator="false"/>
					<item label=" Full Screen " name="toggleFullScreen" primKey="f" isSeparator="false"/>
					<item label=" Dock/Undock Canvas " name="toggleCanvasWindow" primKey="j" isSeparator="false"/>
				</item>
				<item label="Help" name="help" primKey="" isSeparator="false">
					<item label=" LiveBrush Help..." name="helpLink" primKey="" isSeparator="false"/>
					<item label=" Troubleshooting and Support...  " name="supportLink" primKey="" isSeparator="false"/>
					<item label=" Send Feedback..." name="feedbackLink" primKey="" isSeparator="false"/>
					<item label="" name="" primKey="" isSeparator="true"/>
					<item label=" Visit the forums..." name="forumLink" primKey="" isSeparator="false"/>
					<item label=" LiveBrush.com" name="homeLink" primKey="" isSeparator="false"/>
					<item label="" name="" primKey="" isSeparator="true"/>
					<item label=" Check For Updates" name="checkForUpdates" primKey="" isSeparator="false"/>
					<item label="" name="" primKey="" isSeparator="true"/>
					<item label=" About LiveBrush..." name="about" primKey="" isSeparator="false"/>
				</item>
			</menu>;
			
			_mainMenu = xmlToNativeMenu(mainMenuXML);
			
			if (NativeWindow.supportsMenu) 
			{
				UI.UI_HOLDER.stage.nativeWindow.menu = mainMenu;
				//UI.MAIN_UI.canvasWindow.menu = mainMenu;
			}
			else if (NativeApplication.supportsMenu) 
			{
				NativeApplication.nativeApplication.menu = mainMenu;
			}
			
			_fileMenuItem = getItemByName("file");
			//_modifyMenuItem = getItemByName("modify");
			_layerMenuItem = getItemByName("layer");
			
			/* goes here
			fileMenuItem = mainMenu.addItem(new NativeMenuItem("File"));
			editMenu = mainMenu.addItem(new NativeMenuItem("Edit"));
			modifyMenuItem = mainMenu.addItem(new NativeMenuItem("Modify"));
			styleMenu = mainMenu.addItem(new NativeMenuItem("Style"));
			controlMenu = mainMenu.addItem(new NativeMenuItem("Control"));
			shareMenu = mainMenu.addItem(new NativeMenuItem("Share"));
			windowMenu = mainMenu.addItem(new NativeMenuItem("Window"));
			helpMenu = mainMenu.addItem(new NativeMenuItem("Help"));
			
			var fileSubMenu:NativeMenu = fileMenuItem.submenu = new NativeMenu();
			var newMenuItem:NativeMenuItem = fileSubMenu.addItem(new NativeMenuItem(" New")); newMenuItem.name = "newProject";
			var openMenuItem:NativeMenuItem = fileSubMenu.addItem(new NativeMenuItem(" Open...")); openMenuItem.name = "openProject";
			fileSubMenu.addItem(new NativeMenuItem("A", true)); 
			var saveMenuItem:NativeMenuItem = fileSubMenu.addItem(new NativeMenuItem(" Save")); saveMenuItem.name = "saveProject"; 
			var saveAsMenuItem:NativeMenuItem = fileSubMenu.addItem(new NativeMenuItem(" Save As...  ")); saveAsMenuItem.name = "saveProjectAs";
			var saveImageMenu:NativeMenuItem = fileSubMenu.addItem(new NativeMenuItem(" Save As Image "));
			var revertMenuItem:NativeMenuItem = fileSubMenu.addItem(new NativeMenuItem(" Revert")); revertMenuItem.name = "revertProject";
			fileSubMenu.addItem(new NativeMenuItem("A", true)); 
			var importMenu:NativeMenuItem = fileSubMenu.addItem(new NativeMenuItem(" Import")); 
			var exportMenu:NativeMenuItem = fileSubMenu.addItem(new NativeMenuItem(" Export"));
			fileSubMenu.addItem(new NativeMenuItem("A", true)); 
			var exitMenuItem:NativeMenuItem = fileSubMenu.addItem(new NativeMenuItem(" Exit")); exitMenuItem.name = "exit";
			
			var saveImageSubMenu:NativeMenu = saveImageMenu.submenu = new NativeMenu();
			saveImageSubMenu.addItem(new NativeMenuItem(" Normal Quality (72dpi)...  ")); 
			saveImageSubMenu.addItem(new NativeMenuItem(" High Quality (150dpi)...")); 
			saveImageSubMenu.addItem(new NativeMenuItem(" Print Quality (300dpi)...")); 
			
			var importSubMenu:NativeMenu = importMenu.submenu = new NativeMenu();
			var importProjectMenuItem:NativeMenuItem = importSubMenu.addItem(new NativeMenuItem(" Import Project...")); importProjectMenuItem.name = "importProject";
			var importStyleMenuItem:NativeMenuItem = importSubMenu.addItem(new NativeMenuItem(" Import Brush Style...")); importStyleMenuItem.name = "importStyle";
			var importDecoSetMenuItem:NativeMenuItem = importSubMenu.addItem(new NativeMenuItem(" Import Decoration Set (to current style)...  ")); importDecoSetMenuItem.name = "importDecoSet";
			var importDecoMenuItem:NativeMenuItem = importSubMenu.addItem(new NativeMenuItem(" Import Decoration (to current style)...  ")); importDecoMenuItem.name = "importDeco";
			var importImageMenuItem:NativeMenuItem = importSubMenu.addItem(new NativeMenuItem(" Import Image (above current layer)...")); importImageMenuItem.name = "importImage";
			
			var exportSubMenu:NativeMenu = exportMenu.submenu = new NativeMenu();
			var exportStyleMenuItem:NativeMenuItem = exportSubMenu.addItem(new NativeMenuItem(" Export Style")); exportStyleMenuItem.name = "exportStyle"; 
			var exportDecoSetMenuItem:NativeMenuItem = exportSubMenu.addItem(new NativeMenuItem(" Export Decoration Set")); exportDecoSetMenuItem.name = "exportDecoSet"; 
			var exportLayerMenuItem:NativeMenuItem = exportSubMenu.addItem(new NativeMenuItem(" Export Layer(s) To Image  ")); exportLayerMenuItem.name = "exportImage"; 
			
			var editSubMenu:NativeMenu = editMenu.submenu = new NativeMenu();
			editSubMenu.addItem(new NativeMenuItem(" Undo")); 
			editSubMenu.addItem(new NativeMenuItem(" Redo")); 
			editSubMenu.addItem(new NativeMenuItem("A", true)); 
			editSubMenu.addItem(new NativeMenuItem(" Cut")); 
			editSubMenu.addItem(new NativeMenuItem(" Copy")); 
			editSubMenu.addItem(new NativeMenuItem(" Paste")); 
			editSubMenu.addItem(new NativeMenuItem(" Delete"));
			editSubMenu.addItem(new NativeMenuItem("A", true)); 
			editSubMenu.addItem(new NativeMenuItem(" Select All")); 
			editSubMenu.addItem(new NativeMenuItem(" Deselect All"));
			editSubMenu.addItem(new NativeMenuItem("A", true));
			editSubMenu.addItem(new NativeMenuItem(" Preferences...  "));
			
			var modifySubMenu:NativeMenu = modifyMenuItem.submenu = new NativeMenu();
			var layerMenu:NativeMenuItem = modifySubMenu.addItem(new NativeMenuItem(" Layer")); layerMenu.name = "layerMenuItem"; 
			modifySubMenu.addItem(new NativeMenuItem("A", true));
			var transformMenu:NativeMenuItem = modifySubMenu.addItem(new NativeMenuItem(" Transform"));
			
			var layerSubMenu:NativeMenu = layerMenu.submenu = new NativeMenu(); //layerSubMenu.name = "layerMenuItem"; 
			layerSubMenu.addItem(new NativeMenuItem(" Flatten Layer(s) to Image Layer"));  // ghosted when only 1 image layer selected
			layerSubMenu.addItem(new NativeMenuItem(" Duplicate Layer"));
			layerSubMenu.addItem(new NativeMenuItem("A", true));
			layerSubMenu.addItem(new NativeMenuItem(" Apply Current Style")); // ghosted when line layer not selected (or last selected)
			layerSubMenu.addItem(new NativeMenuItem(" Convert To Straight Line")); // ghosted when line layer not selected (or last selected)
			layerSubMenu.addItem(new NativeMenuItem(" Convert To Smooth Line")); // ghosted when line layer not selected (or last selected)
			layerSubMenu.addItem(new NativeMenuItem("A", true));
			layerSubMenu.addItem(new NativeMenuItem(" Simplify Line")); 
			layerSubMenu.addItem(new NativeMenuItem(" Subdivide Line"));
			layerSubMenu.addItem(new NativeMenuItem(" Optimize Line"));
			layerSubMenu.addItem(new NativeMenuItem("A", true));
			var layerToDecosMenuItem:NativeMenuItem = layerSubMenu.addItem(new NativeMenuItem(" Attach Layer to Edge(s)")); layerToDecosMenuItem.name = "layerToDeco"; 
			var copyLayerToDecosMenuItem:NativeMenuItem = layerSubMenu.addItem(new NativeMenuItem(" Copy Layer to Edge(s)")); copyLayerToDecosMenuItem.name = "copyLayerToDeco";
			var iLayerToDecosMenuItem:NativeMenuItem = layerSubMenu.addItem(new NativeMenuItem(" Attach Layer to Edge(s) in place")); iLayerToDecosMenuItem.name = "iLayerToDeco"; 
			var iCopyLayerToDecosMenuItem:NativeMenuItem = layerSubMenu.addItem(new NativeMenuItem(" Copy Layer to Edge(s) in place")); iCopyLayerToDecosMenuItem.name = "iCopyLayerToDeco";
			var detachEdgeDecosMenuItem:NativeMenuItem = layerSubMenu.addItem(new NativeMenuItem(" Detach Edge Decorations to Layer(s)  "));  detachEdgeDecosMenuItem.name = "detachEdgeDecos";
			var copyEdgeDecosMenuItem:NativeMenuItem = layerSubMenu.addItem(new NativeMenuItem(" Copy Edge Decorations to Layer(s)")); copyEdgeDecosMenuItem.name = "copyEdgeDecos";
			var removeEdgeDecosMenuItem:NativeMenuItem = layerSubMenu.addItem(new NativeMenuItem(" Remove Edge Decorations from Line  "));  removeEdgeDecosMenuItem.name = "removeEdgeDecos";
			
			var transformSubMenu:NativeMenu = transformMenu.submenu = new NativeMenu();
			transformSubMenu.addItem(new NativeMenuItem(" Free Transform"));
			transformSubMenu.addItem(new NativeMenuItem(" Scale")); 
			transformSubMenu.addItem(new NativeMenuItem(" Rotate and Scale  ")); 
			transformSubMenu.addItem(new NativeMenuItem("A", true));
			transformSubMenu.addItem(new NativeMenuItem(" Rotate 90° CW")); 
			transformSubMenu.addItem(new NativeMenuItem(" Rotate 90° CCW")); 
			transformSubMenu.addItem(new NativeMenuItem("A", true));
			transformSubMenu.addItem(new NativeMenuItem(" Flip Vertical")); // ghosted when bad shit
			transformSubMenu.addItem(new NativeMenuItem(" Flip Horizontal"));
			
			var styleSubMenu:NativeMenu = styleMenu.submenu = new NativeMenu(); // these functions should also open the style list panel (so they see what's happening)
			styleSubMenu.addItem(new NativeMenuItem(" New Style via Copy"));
			styleSubMenu.addItem(new NativeMenuItem(" New Elastic Style"));
			styleSubMenu.addItem(new NativeMenuItem(" New Normal Style"));
			styleSubMenu.addItem(new NativeMenuItem("A", true));
			styleSubMenu.addItem(new NativeMenuItem(" Duplicate Decoration"));			
			styleSubMenu.addItem(new NativeMenuItem(" Create Layer(s) from Decoration(s)  ")); // in the panel, not on line edge
			styleSubMenu.addItem(new NativeMenuItem(" Attach Decoration(s) to Edge(s)"));
			styleSubMenu.addItem(new NativeMenuItem("A", true));
			styleSubMenu.addItem(new NativeMenuItem(" Reset Styles"));
			//styleSubMenu.addItem(new NativeMenuItem(" Remove Style(s)"));
			//styleSubMenu.addItem(new NativeMenuItem(" Remove Decoration(s)"));
			//styleSubMenu.addItem(new NativeMenuItem(" Remove All Styles"));
			//styleSubMenu.addItem(new NativeMenuItem(" Remove All Decorations"));
			
			var controlSubMenu:NativeMenu = controlMenu.submenu = new NativeMenu();
			controlSubMenu.addItem(new NativeMenuItem(" Stop All Brushes")); // ghosted if no brushes are running
			controlSubMenu.addItem(new NativeMenuItem(" Run Current Style(s)  "));  // ghosted if if current style isn't dynamic input
			
			var shareSubMenu:NativeMenu = shareMenu.submenu = new NativeMenu();
			shareSubMenu.addItem(new NativeMenuItem(" Get More Styles..."));
			shareSubMenu.addItem(new NativeMenuItem(" Get More Decorations..."));
			shareSubMenu.addItem(new NativeMenuItem("A", true));
			shareSubMenu.addItem(new NativeMenuItem(" Upload Your Styles..."));
			shareSubMenu.addItem(new NativeMenuItem(" Upload Your Deco Set...  "));
			shareSubMenu.addItem(new NativeMenuItem("A", true));
			shareSubMenu.addItem(new NativeMenuItem(" Collaborate...  "));
			shareSubMenu.addItem(new NativeMenuItem(" Develop...  "));
			shareSubMenu.addItem(new NativeMenuItem(" Visit LiveBrush.com"));
			
			var windowSubMenu:NativeMenu = windowMenu.submenu = new NativeMenu();
			windowSubMenu.addItem(new NativeMenuItem(" Toolbar"));
			windowSubMenu.addItem(new NativeMenuItem(" Layers"));
			var stylePanelsMenu:NativeMenuItem = windowSubMenu.addItem(new NativeMenuItem(" Styles"));
			windowSubMenu.addItem(new NativeMenuItem(" Status Bar"));
			windowSubMenu.addItem(new NativeMenuItem("A", true));
			windowSubMenu.addItem(new NativeMenuItem(" Hide/Show Interface  "));
			windowSubMenu.addItem(new NativeMenuItem(" Full Screen "));
			
			var stylePanelSubMenu:NativeMenu = stylePanelsMenu.submenu = new NativeMenu();
			stylePanelSubMenu.addItem(new NativeMenuItem(" Style Preview  "));
			stylePanelSubMenu.addItem(new NativeMenuItem(" Style List"));
			stylePanelSubMenu.addItem(new NativeMenuItem(" Input Style"));
			stylePanelSubMenu.addItem(new NativeMenuItem(" Line Style"));
			stylePanelSubMenu.addItem(new NativeMenuItem(" Stroke Style"));
			stylePanelSubMenu.addItem(new NativeMenuItem(" Decoration Style  "));

			var helpSubMenu:NativeMenu = helpMenu.submenu = new NativeMenu();
			helpSubMenu.addItem(new NativeMenuItem(" LiveBrush Help..."));
			helpSubMenu.addItem(new NativeMenuItem(" Load Tutorial Styles"));
			helpSubMenu.addItem(new NativeMenuItem("A", true));
			helpSubMenu.addItem(new NativeMenuItem(" Troubleshooting and Support...  "));			
			helpSubMenu.addItem(new NativeMenuItem(" Send Feedback...")); 
			helpSubMenu.addItem(new NativeMenuItem("A", true));
			helpSubMenu.addItem(new NativeMenuItem(" Login to forums..."));
			helpSubMenu.addItem(new NativeMenuItem(" LiveBrush.com"));
			//helpSubMenu.addItem(new NativeMenuItem(" LiveBrushPrints.com"));
			//helpSubMenu.addItem(new NativeMenuItem(" TheLiveBrushProject.org"));
			helpSubMenu.addItem(new NativeMenuItem("A", true));
			helpSubMenu.addItem(new NativeMenuItem(" Check For Updates"));
			helpSubMenu.addItem(new NativeMenuItem("A", true));
			helpSubMenu.addItem(new NativeMenuItem(" About LiveBrush..."));*/
			

		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function toggle (b:Boolean):void
		{
			setMenuItemState(mainMenu, b);
		}

		public function updateLayerMenu ():void
		{
			// this wont work until we finalize the menu item order
			// maybe have the controller tell the UI what button we clicked... instead of giving each a name
			// OR, we make  fn's to create the menu and items. Pass name, text, etc... 
			
			// ghost all
			/*setMenuItemState(layerMenu, false);
			
			setItemState(layerMenu.getItemAt(0), true);
			
			if (ui.activeLayers.length == 1)
			{
				setItemState(layerMenu.getItemAt(1), true);
				
				if (Layer.isLineLayer(ui.activeLayer))
				{
					var lineLayer:LineLayer = ui.activeLayer as LineLayer;
					
					setMenuIndexListState(layerMenu, [2, 3, 4, 5, 7, 8, 9], true);
					
					if (activeTool is TransformTool)
					{
						var transformTool:TransformTool = activeTool as TransformTool;
						 
						setItemState(layerMenu.getItemAt(11), true);
						
						if (transformTool.hasSelectedDecos)
						{
							setMenuIndexListState(layerMenu, [12, 13, 14], true);
						}
					}
				}
			}*/
			
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*public function getRecentProjectList ():XML {
			
			var xml:XML = new XML();
			
			try {
				
				xml = new XML(<item label= "Open Recent Project" name="openRecent" primeKey="true" isSeparator="false">);
				var fileStringList:Array = GlobalSettings.RECENT_PROJECTS.split(",");
				
				for (var i:int=0; i<fileStringList.length; i++) {
					xml.appendChild(<item label={i+" "+fileStringList[i].substr(fileStringList[i].lastIndexOf("/"))} name={fileStringList[i]} primKey="" isSeparator="false"/>);
				}
				
			
			} catch (e:Error) {
				xml = new XML();
			}
			
			return xml;
		}*/
		
		public function toggleEditShortcuts (b:Boolean):void
		{
			getItemByName("copy").keyEquivalent = b?"c":"";
			getItemByName("paste").keyEquivalent = b?"v":"";
			//getItemByName("undo").keyEquivalent = b?"z":"";
			//getItemByName("redo").keyEquivalent = b?"y":"";
			getItemByName("selectAll").keyEquivalent = b?"a":"";
			getItemByName("deselectAll").keyEquivalent = b?"A":"";
			//setItemStateByName("copy", b);
			//setItemStateByName("paste", b);
		}
		
		public function setMenuItemState (menu:NativeMenu, enabled:Boolean, checked:Boolean=false):void
		{
			setMenuItemListState(menu.items, enabled, checked);
			/*for (var i:int=0; i<menu.numItems; i++)
			{
				setItemState(menu.items[i], checked, enabled);
			}*/
		}
		
		public function setMenuIndexListState (menu:NativeMenu, indexList:Array, enabled:Boolean, checked:Boolean=false):void
		{
			for (var i:int=0; i<indexList.length; i++)
			{
				setItemState(menu.items[indexList[i]], enabled, checked);
			}
		}
		
		public function setMenuItemListState (itemList:Array, enabled:Boolean, checked:Boolean=false):void
		{
			for (var i:int=0; i<itemList.length; i++)
			{
				setItemState(itemList[i], enabled, checked);
			}
		}
		
		public function setItemState (item:NativeMenuItem, enabled:Boolean, checked:Boolean=false):void
		{
			item.checked = checked;
			item.enabled = enabled;
		}
		
		private function xmlToNativeMenu (xml:XML):NativeMenu
		{
			var menu:NativeMenu = new NativeMenu();
			var item:NativeMenuItem;
			var subMenu:NativeMenu;
			
			for each (var xmlItem:XML in xml.*) 
			{
				item = menu.addItem(createNativeMenuItem(xmlItem.@label, xmlItem.@name, xmlItem.@primKey, xmlItem.@isSeparator=="true"?true:false));
				//// // Consol.Trace(xmlItem.children().length());
				if (xmlItem.children().length() > 0) item.submenu = xmlToNativeMenu(xmlItem);
			}
			
			return menu;
		}
		
		private function createNativeMenuItem (label:String, name:String="", primKey:String="", isSeparator:Boolean=false):NativeMenuItem
		{
			var item:NativeMenuItem = new NativeMenuItem(label, isSeparator);
			item.name = name;
			if (primKey == "BACKSPACE") 
			{
				// not working
				item.keyEquivalentModifiers = [Keyboard.BACKSPACE];
				item.keyEquivalent = "";
			}
			else if (primKey != "") 
			{
				item.keyEquivalent = primKey;
			}
			menuItemNames.push(item.name);
			menuItems.push(item);
			return item;
		}
		
		public function getItemByName (name:String):NativeMenuItem
		{
			// setTimeout(// // Consol.Trace, 2000, menuItems[menuItemNames.indexOf("importStyle")].name);
			return menuItems[menuItemNames.indexOf(name)];
		}
		
		private function setItemStateByName (name:String, enabled=true, checked:Boolean=false):void
		{
			setItemState(getItemByName(name), enabled, checked);
		}
		
		

		// TBD / DEBUG //////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function mainMenuListener (e:MouseEvent):void
		{
			if (e.target == newProject)
			{
				trace ("new project");
			}
			else if (e.target == open)
			{
				trace ("open project");
				dispatchEvent(new TitlebarEvent(TitlebarEvent.OPEN_PROJECT)); 
				//dispatchEvent (TitlebarEvent.OPEN_PROJECT);
			}
			else if (e.target == save)
			{
				//trace("save as project");
				dispatchEvent(new TitlebarEvent(TitlebarEvent.SAVE_PROJECT)); 
			}
			else if (e.target == saveAs)
			{
				//trace("save as project");
				dispatchEvent(new TitlebarEvent(TitlebarEvent.SAVEAS_PROJECT)); 
			}
			else if (e.target == share)
			{
				trace("share");
			}
			else if (e.target == settings)
			{
				trace("settings");
			}
			else if (e.target == exit)
			{
				stage.nativeWindow.close();
			}
			else if (e.target == rightMenu.importStyle)
			{
				//trace("importStyles");
				//dispatchEvent(new TitlebarEvent(TitlebarEvent.IMPORT_STYLE)); 
			}
			else if (e.target == rightMenu.exportStyle)
			{
				trace("exportStyles");
			}
			
		}*/
		
		/*public function getMenuByName (name:String):NativeMenu
		{
			// setTimeout(// // Consol.Trace, 2000, menuItems[menuItemNames.indexOf("importStyle")].name);
			return menus[menuNames.indexOf(name)];
		}*/
		
	}
	
	
}