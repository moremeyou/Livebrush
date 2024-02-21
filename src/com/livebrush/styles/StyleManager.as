package com.livebrush.styles
{
	import com.livebrush.utils.Update;
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.data.FileManager;
	import com.livebrush.data.Settings;
	import com.livebrush.data.Exchangeable;
	import com.livebrush.data.Storable;
	import com.livebrush.styles.*;
	//import com.livebrush.ui.SavedStylesPanel;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.Consol;
	import com.livebrush.tools.BrushGroup;
	import com.livebrush.graphics.canvas.StylePreviewLayer;
	
	public class StyleManager implements Exchangeable
	{

		public var styles							:Array;
		public var ui								:UI;
		//public var stylesPanel						:SavedStylesPanel;
		public var styleGroup						:Array;
		public var stylePreview						:StylePreviewLayer;
		public var showStylePreview					:Boolean = false;
		public var stylePreviewAutoRefresh			:Boolean = true;
		private var _locked							:Boolean = false;
		private var _copiedStyle					:Style = null
		public var lockedColorSettings				:Settings;
		public var colorsLocked						:Boolean = false;
		public var alphaLocked						:Boolean = false;
		
		
		public function StyleManager (ui:UI):void
		{
			styleGroup = [];
			styles = [];
			this.ui = ui;
			
			lockColors(false);
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get stylePreviewLayer ():StylePreviewLayer {   return ui.canvasManager.stylePreviewLayer;   }
		public function set activeStyle (s:Style):void {   setStyleGroup([s]);   }
		public function get activeStyle ():Style {   return styleGroup[0];   }
		public function set settings (settings:Settings):void
		{
			styles = settings.styles;
			//// // Consol.Trace("StyleManager: styles.length = " + styles.length);
			setStyleGroup(settings.styleGroup);
		}
		public function get settings ():Settings
		{
			var settings:Settings = new Settings();
			settings.styles = styles;
			//settings.activeStyle = activeStyle;
			settings.styleGroup = styleGroup;
			
			return settings;
		}
		public function get activeStyleId ():int
		{
			return activeStyle.id;
		}
		
		
		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function reset ():void
		{
			for (var i:int=0; i<styles.length; i++)
			{
				styles[i].die();
				delete styles[i];
			}
			for (var j:int=0; j<styleGroup.length; j++)
			{
				delete styleGroup[j];
			}
			//activeStyle = null;
			styles = [];
			styleGroup = [];
		}
		
		
		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function setStyleXML (xml:XML, importBool:Boolean=false):Style
		{
			_locked = true;
			
			var styleXML:XML = xml.copy();
			
			var style:Style = new Style(this);
			
			style.setXML(Settings.attrToElement(styleXML));
			
			style.name = FileManager.createNameDup(styles, style.name, "name");
			
			//// // Consol.Trace(style.name + " : " + style.stroke.strokeType);
			
			//styles.push(style);
			/*try
			{
				styles.splice(styles.indexOf(activeStyle), 0, style);
			}
			catch (e:Error)
			{*/
				styles.push(style);
			//}
			
			setStyleGroup([styleGroup.length==0 ? styles[0] : importBool ? styles[styles.length-1] : activeStyle]);
			//// // Consol.Trace("StyleManager: importBool = " + importBool);
			//setStyleGroup([styleGroup.length==0 ? styles[0] : importBool ? styles[styles.indexOf(style)+1] : styles[0]]);
			
			
			_locked = false;
			
			return style;
		}
		
		public function getStyleXML ():XML 
		{
			var stylesXML:XML = new XML(<styles></styles>);
			
			for (var i:int=0;i<styles.length;i++)
			{
				stylesXML.appendChild(styles[i].getXML());
			}
			
			return stylesXML;
		}
		
		public function copyStyle (i:int):void
		{
			if (_copiedStyle != null) _copiedStyle.die();
			
			_copiedStyle = styles[i].clone();
		}
		
		public function pasteStyle (i:int, all:Boolean, b:Boolean=false, l:Boolean=false, d:Boolean=false, lc:Boolean=false, dc:Boolean=false, dl:Boolean=false, t:Boolean=false):void
		{
			//// // Consol.Trace("StyleManager: paste style");
			var style:Style = styles[i];
			var settingsMix:Settings;
			
			if (_copiedStyle != null)
			{
				if (all)
				{
					style.settings = _copiedStyle.settings;
				}
				else if (b)
				{
					style.strokeStyle.thresholds = _copiedStyle.strokeStyle.settings.thresholds
					style.lineStyle.settings = _copiedStyle.lineStyle.settings;
				}
				else if (l)
				{
					style.lineStyle.smoothing = _copiedStyle.lineStyle.settings.smoothing;
					style.strokeStyle.settings = _copiedStyle.strokeStyle.settings // _copiedStyle.strokeStyle.settings;
				}
				else if (d)
				{
					style.decoStyle.settings = _copiedStyle.decoStyle.settings;
				}
				else if (lc)
				{
					settingsMix = style.strokeStyle.settings;
					settingsMix.colorObjList = _copiedStyle.strokeStyle.settings.colorObjList;
					style.strokeStyle.settings = settingsMix;
				}
				else if (dc)
				{
					settingsMix = style.decoStyle.settings;
					settingsMix.colorObjList = _copiedStyle.decoStyle.settings.colorObjList;
					style.decoStyle.settings = settingsMix;
				}
				else if (dl)
				{
					settingsMix = style.decoStyle.settings;
					settingsMix.decos = _copiedStyle.decoStyle.settings.decos;
					style.decoStyle.settings = settingsMix;
				}
				else if (t)
				{
					style.strokeStyle.thresholds = _copiedStyle.strokeStyle.settings.thresholds
				}
				
				if (style == activeStyle) pushStyle();
			}
			
		}
		
		
		// STYLE ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function lockColors (b:Boolean):void {
		
			//// Consol.Trace("StyleManager: lockColors = " + b);
			
			colorsLocked = b;
			if (b) lockedColorSettings = ui.globalColorView.settings;
			try { 
				alphaLocked = lockedColorSettings.alphaLocked;
			} catch (e:Error) { 
				alphaLocked = false; 
			}
			
			// Consol.Trace("StyleManager: alphaLocked = " + alphaLocked);
			
		}
		
		public function pullStyle (settings:Settings):void
		{
			if (!_locked)
			{
			
				activeStyle.decoStyle.settings = settings.deco;
				
				var settingsMix:Settings = settings.behavior;
				settingsMix.smoothing = settings.line.smoothing;
				activeStyle.lineStyle.settings = settingsMix;
				
				settingsMix = settings.line;
				settingsMix.thresholds = settings.behavior.thresholds;
				activeStyle.strokeStyle.settings = settingsMix;
	
				this.settings = settings.list;
			
			}
			else
			{
				//// // Consol.Trace("StyleManager: wups! style ui is trying to push it's setting while the styleMan is pushing!");
			}
			
			//ui.brushPropsModel.update(Update.brushStyleUpdate(settings));
			//pushStyle();
		}
		
		public function pushStyle ():void
		{
			
			_locked = true;
			
			var settings:Settings = this.settings; //.copy();
			settings.behavior = activeStyle.lineStyle.settings;
			settings.behavior.thresholds = activeStyle.strokeStyle.thresholds;
			
			settings.line = activeStyle.strokeStyle.settings;
			settings.line.smoothing = settings.behavior.smoothing;
			
			settings.deco = activeStyle.decoStyle.settings;
			
			//// // Consol.Trace("StyleManager: " + styleList.selectedItem.name + " : " + styleList.selectedItem.strokeStyle.strokeType);
			//activeStyle.strokeStyle.settings.traceSettings();
			
			//// // Consol.Trace("<<< PUSH STYLE FROM STYLE MANAGER >>>");
			//ui.brushPropsModel.update(Update.brushStyleUpdate(settings));
			ui.update(Update.brushStyleUpdate(settings));
			
			_locked = false;
		}
		
		public function updateStylePreview (style:Style):void
		{
			//// // Consol.Trace("style update");
			//if (showStylePreview) stylePreviewLayer.drawStyle(style);
			if (showStylePreview) stylePreviewLayer.drawStyle();
		}
		
		private function getStyle (id:int):Style
		{
			var style:Style;			
			for (var i:int=0; i<styles.length; i++) 
			{
				if (styles[i].id == id) style = styles[i];
			}
			return style;
		}
		
		public function createStyle (name:String):void
		{
			var style:Style = activeStyle.clone();
			style.name = FileManager.createNameDup(styles, name, "name"); // checkNameDup(name); 
			//styles.push(style);
			styles.splice(styles.indexOf(activeStyle)+1, 0, style);
			activeStyle = style;
			//activeStyle = styles[styles.length-1];
			pushStyle();
		}
		
		public function removeStyle(id:int):void
		{
			var index:int;
			for (var i:int=0; i<styles.length; i++) 
			{
				if (styles[i].id == id) 
				{
					index = i;
					styles[i].die();
					styles.splice(i,1);
				}
			}
			// activeStyle = getStyle(styles[0].id);
			activeStyle = styles[Math.min(styles.length-1, index)];
			pushStyle();
		}
		
		public function removeDeco(index:int):void
		{
			activeStyle.decoStyle.decoSet.removeDeco(index);
			pushStyle();
		}
		
		public function moveDeco(index:int, dir:int):void
		{
			activeStyle.decoStyle.decoSet.moveDeco(index, dir);
			pushStyle();
		}
		
		public function setDynamicInput (fileName:String):void
		{
			activeStyle.lineStyle.setDynamicInput(fileName);
			setStyleGroup([activeStyle])
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function setStyleGroup (bGroup:Array):void
		{
			var style:Style;
			try 
			{ 
				for (var i:int=0; i<styleGroup.length; i++)
				{
					style = getStyle(styleGroup[i].id);
					if (style.lineStyle.type == LineStyle.DYNAMIC) style.lineStyle.unloadInputSWF(); 
				}
			} 
			catch(error:Error) 
			{
				//// // Consol.Trace("no unload. this is first set style: " + activeStyle);
			}
			finally
			{
				styleGroup = [];
				for (i=0; i<bGroup.length; i++)
				{
					style = getStyle(bGroup[i].id);
					//// // Consol.Trace("StyleManager: " + style.name + " : " + style.strokeStyle.strokeType);
					if (style.lineStyle.type == LineStyle.DYNAMIC) style.lineStyle.loadInputSWF();
					styleGroup.push(style);
				}
				pushStyle();
			}
			//// // Consol.Trace("style update");
			if (stylePreviewAutoRefresh) updateStylePreview(activeStyle);
		}
		
		public function selectStyle (i:int):void
		{
			activeStyle = styles[i];
		}
		

	}

}