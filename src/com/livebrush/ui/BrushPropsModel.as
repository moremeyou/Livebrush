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
	
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	
	import com.livebrush.data.FileManager;
	import com.livebrush.data.Settings;
	import com.livebrush.utils.Update;
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.data.FileManager;
	import com.livebrush.ui.*;
	import com.livebrush.events.*;
	import com.livebrush.Main;
	import com.livebrush.styles.StyleManager;
	import com.livebrush.tools.ToolManager;
	import com.livebrush.styles.StyleManager;
	import com.livebrush.graphics.canvas.CanvasManager
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.StylePreviewLayer;
	import com.livebrush.styles.StrokeStyle;

	
	public class BrushPropsModel extends UIModel
	{
		public static const	BEHAVIOR						:String = "behavorProps";
		
		
		public var ui										:UI;
		public var propGroups								:Array;
		public var currentGroup								:int = 0;
		
		public var brushPropsView							:BrushPropsView;
		//public var styleListView							:StyleListView;
		public var brushBehaveView							:BrushBehaveView;
		public var lineStyleView							:LineStyleView;
		public var decoStyleView							:DecoStyleView;
		
		public static var TABLET_PRESSURE					:Object = {label:"Tablet Pressure", data:StrokeStyle.PRESSURE};
		
		
		public function BrushPropsModel (ui:UI):void
		{
			super()
			
			this.ui = ui;
			
			//// // Consol.Trace("Brush Props Model");
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get styleManager ():StyleManager {   return ui.styleManager;   }
		
		
		// SETUP ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			
			brushPropsView = BrushPropsView(registerView(new BrushPropsView(this)));
			//styleListView = StyleListView(registerView(new StyleListView(this)));
			brushBehaveView = BrushBehaveView(registerView(new BrushBehaveView(this)));
			lineStyleView = LineStyleView(registerView(new LineStyleView(this)));
			decoStyleView = DecoStyleView(registerView(new DecoStyleView(this)));
			
			propGroups = [brushBehaveView, lineStyleView, decoStyleView]; // styleListView, 
			
			toggleProps(0);
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// PUBLIC ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function pullStyleProps ():void
		{
			//Consol.Clear();
			//// // Consol.Trace("--------------------------");
			//// // Consol.Trace("<<< PULL STYLE FROM UI >>>");
			
			var settings:Settings = new Settings();
			settings.list = ui.styleListView.settings;
			settings.behavior = brushBehaveView.settings;
			settings.line = lineStyleView.settings;
			settings.deco = decoStyleView.settings;
			
			//settings.traceSettings();
			
			styleManager.pullStyle(settings);
		}
		
		public function toggleProps (index:int):void
		{
			currentGroup = index;
			updateViews(Update.uiUpdate());
		}
		
		public function createStyle (name:String=null):void
		{
			styleManager.createStyle((name==null||name=="")?styleManager.activeStyle.name:name);
		}
		
		public function removeStyle (id:int):void
		{
			ui.styleManager.removeStyle(id);
		}
		
		public function importStyle ():void
		{
			ui.main.importToProject(FileManager.STYLE);
			//ui.dispatchEvent (new FileEvent(FileEvent.IO_EVENT, true, false, FileEvent.IMPORT, FileManager.STYLE));
		}
		
		public function exportStyle ():void
		{
			ui.main.export(FileManager.STYLE);
			//ui.dispatchEvent (new FileEvent(FileEvent.IO_EVENT, true, false, FileEvent.EXPORT, FileManager.STYLE));
		}
		
		public function enabledTabletInput ():void
		{
			lineStyleView.uiAsset.widthInputs.addType(TABLET_PRESSURE);
			lineStyleView.uiAsset.alphaInputs.addType(TABLET_PRESSURE);
			decoStyleView.uiAsset.positionInputs.addType(TABLET_PRESSURE);
			decoStyleView.uiAsset.sizeInputs.addType(TABLET_PRESSURE);
			decoStyleView.uiAsset.alphaInputs.addType(TABLET_PRESSURE);
			decoStyleView.uiAsset.tintInputs.addType(TABLET_PRESSURE);
		}
		
		// DEBUG ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

	}
	
	
}