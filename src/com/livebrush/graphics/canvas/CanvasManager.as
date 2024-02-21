package com.livebrush.graphics.canvas
{
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.EventPhase;
	import flash.utils.Timer;
	import flash.utils.setTimeout
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.getTimer;
	import flash.geom.Matrix;
	
	import com.livebrush.utils.Update;
	import com.livebrush.styles.StyleManager;
	import com.livebrush.styles.Style;
	import com.livebrush.styles.DecoAsset;
	import com.livebrush.styles.DecoStyle;
	import com.livebrush.data.Exchangeable;
	import com.livebrush.data.Settings;
	import com.livebrush.data.Storable;
	import com.livebrush.data.FileManager;
	//import com.livebrush.ui.LayersPanel;
	import com.livebrush.graphics.canvas.*;
    import com.livebrush.ui.UI;
	import com.livebrush.ui.DialogWindow;
	import com.livebrush.ui.Consol;
	import com.livebrush.events.CanvasEvent;
	import com.livebrush.events.ToolbarEvent;
	import com.livebrush.data.GlobalSettings;
	import com.livebrush.graphics.Edge;
	import com.livebrush.graphics.Line;
	import com.livebrush.tools.ToolManager;
	import com.livebrush.tools.Tool;
	import com.livebrush.tools.TransformTool;
	import com.livebrush.tools.BrushTool;
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.graphics.CanvasView;
	import com.livebrush.graphics.Deco;
	import com.livebrush.graphics.canvas.ImageLayer;
	import com.livebrush.transform.SelectionView;
	import com.livebrush.tools.TransformTool;
	import com.livebrush.graphics.canvas.LineLayer
	import com.livebrush.graphics.CanvasController;
	import com.livebrush.graphics.GraphicUpdate
	import com.livebrush.utils.Model;
	import com.livebrush.Main;
	import com.livebrush.ui.LayerThumb;
	import com.livebrush.data.StateManager;
	import com.livebrush.events.StateEvent;
	
	import com.formatlos.as3.lib.display.BitmapDataUnlimited;
	
	
	public class CanvasManager extends Model implements Exchangeable, Storable
	{
		public var activeLayers						:Array;
		public var layers							:Array;
		//public var layersPanel						:LayersPanel;
		
		public var toolManager						:ToolManager;
		public var canvasView						:CanvasView;
		public var selectionView					:SelectionView;
		private var nextLayerInitProps				:Object
		private var layerLoadQueue					:Array;
		private var loadedLayers					:Array;
		private var lineLayerBuffer					:Array;
		private var main							:Main;
		private var batchLoading					:Boolean = false;
		private var batchLoadCount					:int = 0;
		private var pushDelay						:Timer;
		private var incompleteLayersCount			:int = 0;
		private var stateIndex						:int = 0;
		private var ui								:UI;
		private var _activeLayerDepths				:Array;
		public var omitBg							:Boolean;
		public var stylePreviewLayer				:StylePreviewLayer;
		public var styleManager						:StyleManager;
		private var _clipboard						:Array;
		private var _cutContent						:Object;
		public var emptyThumb						:LayerThumb;
		private var _tempLayerCount					:int = 0;
		public var _selectedObjects					:Array;
		//private var _layerProps						:Array;
		private var _canvasUpdateTimeout			:int = -1;
		private var _activeBitmapLayer				:BitmapLayer = null;
		private var _copiedBitmapData				:BitmapData;
		
		
		public function CanvasManager (main:Main, ui:UI):void
		{
			super();
			
			this.main = main;
			
			layers = [];
			_clipboard = [];
			activeLayerDepths = [];
			_selectedObjects = [];
			//_layerProps = [];
			//lineLayerBuffer = [];
			//layerLoadQueue = [];
			//loadedLayers = [];
			
			//layersPanel = ui.layersPanel;
			//layersPanel.canvasManager = this;
			this.ui = ui;

		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get allLayerDepths ():Array {   var depths:Array=[]; for (var i:int=0; i<layers.length; i++) depths.push(layers[i].depth); return depths;   };
		public function get activeLayerNum ():int {   return activeLayerDepths.length;   }
		public function get activeLayerDepths ():Array {   return _activeLayerDepths;   };
		public function set activeLayerDepths (aLs:Array):void {   _activeLayerDepths=aLs; activeLayers=[]; for (var i:int=0; i<aLs.length; i++) activeLayers.push(getLayer(aLs[i]));   }
		public function get activeLayerDepth ():int {   return activeLayerDepths[activeLayerDepths.length-1];   }
		public function get topActiveLayerDepth ():int {   return activeLayerDepth;   }
		public function get bottomActiveLayerDepth ():int {   return activeLayerDepths[0];   }
		public function get activeLayer ():Layer {   return getLayer(activeLayerDepth);   }
		public function get activeTool ():Tool {   return toolManager.activeTool;   }
		public function get canvas ():Canvas {   return canvasView.canvas;   }
		public function get selectionAllowed ():Boolean {   return (toolManager.activeTool is TransformTool);   }
		public function get transformTool ():TransformTool {   return toolManager.transformTool;   }
		public function get brushTool ():BrushTool {   return toolManager.brushTool;   }
		public function get activeBitmapLayer ():BitmapLayer {   
			if (!Layer.isBitmapLayer(activeLayer)) { 
				_activeBitmapLayer = addBitmapLayer();
			} else {
				activeLayer.resetTransform();
				_activeBitmapLayer = activeLayer as BitmapLayer; 
			}
			return _activeBitmapLayer;   
		}
		
		
		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function die ():void { }
		
		public function setup ():void { init(); }
		
		public function reset ():void
		{
			// // Consol.Trace("CanvasManager: Reset");
			//StateManager.reset();
			// do it in reverse order so we don't miss any (if the layer order is not the same as the depth order)
			// not exactly sure why this works so well
			for (var i:int=layers.length-1; i>=0; i--)
			{
				remLayer(layers[i].depth, false, false);
			}
			stylePreviewLayer.reset();
			activeLayerDepths = [];
			layers = [];
			incompleteLayersCount = 0;
			layers = [];
			layerLoadQueue = [];
			loadedLayers = [];
			lineLayerBuffer = [];
			_selectedObjects = [];
			_activeBitmapLayer = null;
			//_layerProps = [];
			_clearClipboard();
			
			Layer.LAYER_COUNT=0;
			
			canvas.canvasZoom(1);
			
			die();
		}
		
		private function init():void
		{
			setupViews();
		}
	
		private function setupViews ():void
		{
			
			emptyThumb = new LayerThumb();
			
			canvasView = CanvasView(registerView(new CanvasView(this)));
			
			canvasView.canvas.addEventListener(Event.ADDED_TO_STAGE, canvasAddedToStage);
			
			main.addChildAt(canvasView.canvas, 0);
			//main.newWindow.stage.addChildAt(canvasView.canvas, 0);
		}
		
		private function initCanvas ():void
		{
			//Consol.Trace("CanvasManager: initCanvas");
			
			canvasView.setup();
			
			selectionView = SelectionView(registerView(new SelectionView(this)));
			
			stylePreviewLayer = new StylePreviewLayer(canvas);
			//stylePreviewLayer.x = Canvas.WIDTH/2 - 400;
			//stylePreviewLayer.y = Canvas.HEIGHT/2 - 300;
			stylePreviewLayer.visible = false;
			
			/*ui.pushColorProps(ui.globalColorView.settings);
			styleManager.lockColors(false);*/
			
			dispatchEvent(new CanvasEvent(CanvasEvent.INIT));
			
			//ui.toggleCanvasWindow();
		}
		
		
		// CUT, COPY, PASTE, SELECT /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function copyContent (cut:Boolean=false):void
		{
			//// // Consol.Trace("copy");
			
			_clearClipboard();
			
			var i:int;
			var layer:Layer;
			
			//if (activeLayerDepths.length > 1 || Layer.isBoxLayer(activeLayer) || (!Tool.isTransformTool(toolManager.activeTool) && Layer.isLineLayer(activeLayer)))
			if ((Layer.isBoxLayer(activeLayer) || Layer.isBitmapLayer(activeLayer)) || (!Tool.isTransformTool(toolManager.activeTool) && Layer.isLineLayer(activeLayer)))
			{
				var groupedLayerIndices:Array = activeLayerDepths.slice();
				groupedLayerIndices.sort(Array.NUMERIC);
				
				for (i=0; i<groupedLayerIndices.length; i++) // this is redudant because we're not copying multiple layers now
				// confirmed, this is redundant
				{
					layer = getLayer(groupedLayerIndices[i]);
					if (Layer.isBitmapLayer(layer)) {
						try { _copiedBitmapData.dispose() } catch (e:Error){}
						_copiedBitmapData = layer.solid.bitmapData.clone()
						_clipboard.push({type:"bitmap", bitmapData:_copiedBitmapData});
					} else if (!Layer.isBackgroundLayer(layer)) {
						_clipboard.push({type:"layer", xml:layer.getXML().toXMLString()});
					}
				}
			}
			else if (Tool.isTransformTool(toolManager.activeTool) && Layer.isLineLayer(activeLayer))
			{
				var lineLayer:LineLayer = activeLayer as LineLayer;
				var t:TransformTool = toolManager.transformTool;
				var line:Line = lineLayer.line;
				
				if (t.selectedEdgeIndices.length > 0)
				{
					var newLine:Line = Line.newLine(Line.isSmoothLine(line), line.type, line.lines, line.weight);
					newLine.edges = t.selectedEdges.slice();
					_clipboard.push({type:"line", xml:newLine.getXML().toXMLString()});
					
					//if (cut) _cutContent = {layer:lineLayer, indices:t.selectedEdgeIndices};
				}
			}
		}
		
		public function pasteContent (clipboard:Array=null, index:int=-1):void
		{
			//// // Consol.Trace("paste");
			if (_clipboard.length > 0 || clipboard.length > 0)
			{
				
				StateManager.lock();
				
				var content:Object;
				var newLayer:Layer;
				var line:Line;
				var firstDepth:int;
				var d:int = firstDepth = (index==-1 ? activeLayerDepth : index);
				if (clipboard==null) clipboard = _clipboard;
				var remDepths:Array = [];
				
				for (var i:int=0; i<clipboard.length; i++)
				{
					//content = _clipboard[i];
					content = clipboard[i];
					d++;
					
					if (content.type == "line") 
					{
						newLayer = Layer.newLineLayer();
						LineLayer(newLayer).line = Line.xmlToLine(new XML(content.xml));
						newLayer.depth = d;
						addLayer(newLayer);
						
						/*if (_cutContent != null) 
						{
							toolManager.transformTool.deleteEdges(_cutContent.layer, _cutContent.indices);
							_clearClipboard();
							_cutContent = null;
						}*/
					
					} else if (content.type == "bitmap"){
						
						newLayer = Layer.newBitmapLayer();
						BitmapLayer(newLayer).setBitmapData(content.bitmapData);
						//newLayer.label += " Copy";
						newLayer.depth = d;
						addLayer(newLayer);
						
					} else {
						newLayer = getNewLayerType(new XML(content.xml).@type);
						newLayer.setXML(content.xml);
						newLayer.label += " Copy";
						newLayer.depth = d;
						addLayer(newLayer);
					}
					
					newLayer.changed = true;
					
					remDepths.push(d);
				}
				
				StateManager.unlock(this);
				
				remDepths.sort(Array.NUMERIC | Array.DESCENDING);
				
				StateManager.addItem(function(state:Object):void{   var depths:Array=state.data.remDepths; for(var i:int=0;i<depths.length-1;i++) remLayer(depths[i], false); remLayer(depths[depths.length-1]);   },
									 function(state:Object):void{   pasteContent(state.data.clipboard, state.data.firstDepth);   }, 
									 -1, {firstDepth:firstDepth, clipboard:_clipboard.slice(), remDepths:remDepths.slice()});
				
				StateManager.closeState();
				
				pushSettings();
				
				//selectLayer(l.depth);
				//selectLayer(d);
				
				//if (Tool.isTransformTool(toolManager.activeTool)) 
				//{
					//toolManager.activeTool.reset();
					//toolManager.activeTool.setup();
				//}
				
				//toolManager.setTool(toolManager.activeTool);
				
				setTimeout(toolManager.resetTool, 500);
				
				setTimeout(updateViews, 500, GraphicUpdate.canvasUpdate());
				
			}
		}
		
		public function deleteContent (forceLayer:Boolean=false):void
		{
			if (!forceLayer && activeLayerDepths.length == 1 && Layer.isLineLayer(activeLayer))
			{
				toolManager.setQuickTool();
				toolManager.transformTool.deleteEdges(LineLayer(activeLayer), toolManager.transformTool.selectedEdgeIndices);
				toolManager.finishQuickTool();
			}
			else if (activeLayerDepths.length == 1 && !Layer.isBackgroundLayer(activeLayer))
			{
				remLayer(activeLayerDepth);
			}
			// toolManager.resetTool();
			StateManager.closeState();
		}
		
		public function selectAll ():void
		{
			if (activeLayerDepths.length == 1)
			{
				if (Layer.isLineLayer(activeLayer) && Tool.isTransformTool(toolManager.activeTool)) 
				{
					transformTool.selectAllEdges();
				}
				else if (Layer.isLineLayer(activeLayer) && !Tool.isTransformTool(toolManager.activeTool)) 
				{
					toolManager.setTool(transformTool);
					selectAll();
				}
				else if (Tool.isTransformTool(toolManager.activeTool)) 
				{
					activeLayerDepths = allLayerDepths.slice(1);
					pushSettings();
					selectLayerGroup(activeLayerDepths);
				}
				else
				{
					toolManager.setTool(transformTool);
					selectAll();
				}
			}
			
			//toolManager.resetTool();
			
			/*if (activeLayerDepths.length == 1 && Tool.isTransformTool(toolManager.activeTool) && Layer.isLineLayer(activeLayer))
			{
				toolManager.setTool(transformTool);
				transformTool.selectAllEdges();
			}
			else if (Tool.isTransformTool(toolManager.activeTool))
			{
				activeLayerDepths = allLayerDepths.slice(1);
				pushSettings();
				selectLayerGroup(activeLayerDepths);
			}
			else if (!Tool.isTransformTool(toolManager.activeTool))
			{
				toolManager.setTool(toolManager.transformTool);
				selectAll();
			}*/
		}
		
		public function deselectAll ():void
		{
			if (activeLayerDepths.length == 1 && Tool.isTransformTool(toolManager.activeTool) && Layer.isLineLayer(activeLayer))
			{
				toolManager.transformTool.deselectAllEdges();
			}
			else if (Tool.isTransformTool(toolManager.activeTool))
			{
				activeLayerDepths = [activeLayerDepth];
				pushSettings();
				selectLayerGroup(activeLayerDepths);
			}
		}
		
		
		// LAYER CONTENT ACTIONS & ACTION STATE MEDIATORS  //////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function refreshLayers ():void
		{
			// Consol.Trace("CanvasManager: refreshLayers");
			var layer:Layer;
			for (var i:int=0; i<activeLayerNum; i++)
			{
				//layer = getLayer(activeLayerDepths[i]);
				getLayer(activeLayerDepths[i]).cached = false;
			}
			updateViews(GraphicUpdate.canvasUpdate());
		}
		
		public function layersToStyleDeco ():void
		{
			//// // Consol.Trace("CanvasManager.layersToStyleDeco - NOT DONE YET");
			flattenLayers(true);
		}
		
		public function canvasSelection (b:Rectangle, type:int):void
		{
			//// // Consol.Trace("CanvasManager: canvasSelection");
			if (!selectionAllowed) toolManager.setTool(toolManager.transformTool);
			dispatchEvent(new CanvasEvent(CanvasEvent.SELECTION_EVENT, false, false, null, activeLayer, {bounds:b, type:type}));
		}
		
		public function removeEdgeDecos (lineLayer:LineLayer=null, batch:Boolean=false):void
		{
			var layer:LineLayer = (lineLayer==null ? activeLayer : lineLayer) as LineLayer;
			
			if (Layer.isLineLayer(layer) && !Layer.isBitmapLayer(layer)) 
			{
				
				openLayerState(false);
				StateManager.lock();
				toolManager.setQuickTool();
				
				layer.line.removeEdgeDecos(transformTool.selectedEdgeIndices);
				
				//closeLayerState(false);
				
				if (!batch) 
				{
					// see notes in dupLayer method. this setTimeout isn't good.
					setTimeout(updateViews, 100, GraphicUpdate.canvasUpdate());
					//updateViews(GraphicUpdate.canvasUpdate());
				}
				
				toolManager.finishQuickTool();
				StateManager.unlock(this);
				closeLayerState(false);

			}
		}
		
		public function detachEdgeDecosToLayers (copy:Boolean=true):void
		{
			StateManager.reset();
			StateManager.lock();
			
			toolManager.setQuickTool();
			
			var selectedDecos:Array = TransformTool(activeTool).selectedDecos;
			var layer:LineLayer = LineLayer(activeLayer);
			
			batchLoading = true;
			batchLoadCount = selectedDecos.length;
			
			for (var i:int=0; i<selectedDecos.length; i++) 
			{
				 if (!selectedDecos[i].decoAsset.missing) 
				 {
					decoToLayer(selectedDecos[i]);
				 }
				 else 
				 {
					 // // Consol.Trace("CanvasManager: decoToLayer deco missing> " + selectedDecos[i].decoAsset.missing);
					 batchLoadCount--;
				 }
			}
			
			batchLoading = batchLoadCount>1;
			
			if (!copy) // this will never happen - see the note in ui.mainMenuEvent, detachEdgeDecosToLayers(false)
			{
				//StateManager.unlock(); // can't do this because the layer depth will be different after they all load
				removeEdgeDecos(layer, batchLoading);
				//StateManager.lock();
			}
			
			toolManager.finishQuickTool();
			
			if (batchLoadCount <= 0) StateManager.unlock(this);
			
			//selectLayerGroup(); // wont work for now. we dont know the depths of the new layers 
			//selectLayer(layer.depth); and this wont work yet because the layer isn't loaded yet
		}
		
		private function decoToLayer (deco:Deco):void
		{
			nextLayerInitProps = {x:deco.decoMC.x,
								  y:deco.decoMC.y,
								  rotation:deco.angle,
								  scaleX:deco.scale.x,
								  scaleY:deco.scale.y,
								  color:deco.color,
								  colorPercent:deco.colorPercent,
								  alpha:deco.alpha,
								  enabled:true//,
								//  matrix:deco.transformMatrixString
								  };
			
			FileManager.getInstance().copyDecoToLayer(deco.decoAsset.assetPath, batchLoadCount>1); 
		}
		
		public function styleDecoToLayer ():void
		{
			if (styleManager.activeStyle.decoStyle.decoSet.length > 0)
			{
				var decoAsset:DecoAsset = styleManager.activeStyle.decoStyle.selectedDecoAsset;
				
				if (!decoAsset.missing)
				{
					nextLayerInitProps = {x:0,
										  y:0,
										  rotation:0,
										  scaleX:1,
										  scaleY:1,
										  color:-1,
										  colorPercent:0,
										  alpha:1,
										  enabled:true};
					
					FileManager.getInstance().copyDecoToLayer(decoAsset.assetPath, false); 
				}
			}
		}
		
		public function layerToDeco (depth:int, copy:Boolean=true, inPlace:Boolean=true):void
		{
			// IMPORTANT NOTES AND TBD
			// it is assumed that the activeLayer is a line layer
			// and that there is at least one edge selected. where do we do this check, otherwise?
			// if there is more than one edge selected, add the parameter layer to each of them
			
			// the final way for this will be to select edges on a line layer. then right-click any other non-line layer
			// the right-click menu wont give this option if the layer is a line layer
			
			// and again, like decoToLayer, we'll need to grab the new filename from FileManager if there was rename as a result of a dup file name
			
			openLayerState(false);
			StateManager.lock();
			toolManager.setQuickTool();
			
			var selectedEdgeIndices:Array = transformTool.selectedEdgeIndices;
			var lineLayer:LineLayer = activeLayer as LineLayer; // the contect menu ensures that this will always be a line layer
			var specLayer:ImageLayer = layers[depth]; // ... and that this will always be a box layer
			var decoFileName:String = FileManager.getInstance().copyLayerToDeco(specLayer.src);  // do this first, so we can really check the deco assets
			//var decoAsset:DecoAsset = FileManager.getInstance().getDecoAsset(specLayer.src); 
			var decoAsset:DecoAsset = FileManager.getInstance().getDecoAsset(decoFileName); 
			
			var initObj:Settings = new Settings()
			initObj.color = specLayer.color,
			initObj.colorPercent = specLayer.colorPercent;
			initObj.alpha = specLayer.alpha;
			initObj.angle = specLayer.rotation;
			initObj.pos = .5;
			initObj.offset = null;
			initObj.scale = {x:specLayer.scaleX, y:specLayer.scaleY};
			initObj.align = DecoStyle.ALIGN_CENTER;
			//initObj.traceSettings();
			//// // Consol.Trace(specLayer.scaleY);
			//initObj._matrix = specLayer.transform.matrix;
			
			var edge:Edge;
			var bounds:Rectangle = specLayer.boundingBox;
			var layerCenter:Object = {x:bounds.x+(bounds.width/2), y:bounds.y+(bounds.height/2)};
			
			for (var i:int=0; i<selectedEdgeIndices.length; i++)
			{
				edge = lineLayer.line.edges[selectedEdgeIndices[i]];
				
				if (inPlace) initObj.offset = new Point(layerCenter.x-edge.x, layerCenter.y-edge.y);
				else initObj.offset = new Point();
				
				lineLayer.line.addEdgeDeco(selectedEdgeIndices[i], decoAsset, initObj);
				//lineLayer.cached = false;
			}
			
			//activeLayer.updateDisplay();
			
			if (!copy) remLayer(specLayer.depth, false); // this will never happen. 
			
			toolManager.finishQuickTool();
			StateManager.unlock(this);
			closeLayerState(false);
			
			// see notes in dupLayer method. this setTimeout isn't good.
			//setTimeout(updateViews, 1000, GraphicUpdate.canvasUpdate());
			setCanvasUpdateTimeout();
		}
		
		public function resetLayerTransform (scale:Boolean=true, rotation:Boolean=true, skew:Boolean=true):void
		{
			openLayerState();
			
			activeLayer.resetTransform(scale, rotation, skew);
			
			closeLayerState();
			
			//updateViews(GraphicUpdate.canvasUpdate());
			setCanvasUpdateTimeout();
			
			toolManager.resetTool();
			
			pushSettings();
		}
		
		public function flipLayer (x:Number=-1, y:Number=-1):void
		{
			//if (toolManager.activeTool is TransformTool)
			toolManager.setQuickTool();
			toolManager.transformTool.flip(x, y);
			toolManager.finishQuickTool();
		}
		
		public function rotateLayer (deg:Number):void
		{
			toolManager.setQuickTool();
			toolManager.transformTool.rotate(deg);
			toolManager.finishQuickTool();
		}
		
		public function simplifyLine ():void
		{
			if (activeLayer is LineLayer) 
			{
				toolManager.setQuickTool();
				toolManager.transformTool.simplifyLine();
				toolManager.finishQuickTool();
			}
		}
		
		public function subdivideLine ():void
		{
			if (activeLayer is LineLayer) 
			{
				toolManager.setQuickTool();
				toolManager.transformTool.subdivideLine();
				toolManager.finishQuickTool();
			}
		}
		
		public function convertLine (smooth:Boolean):void
		{
			if (activeLayer is LineLayer) 
			{
				openLayerState();
				
				var layer:LineLayer = LineLayer(activeLayer);
				var lineBak:Line = layer.line;
				
				layer.line = Line.convertLine(layer.line, smooth);
				
				lineBak.die();
				
				closeLayerState();
				
				activeLayer.updateDisplay();
				
				toolManager.resetTool();
				setCanvasUpdateTimeout();
				//setTimeout(updateViews, 100, GraphicUpdate.canvasUpdate());
			}
		}
		
		public function applyLineStyle ():void
		{
			if (activeLayer is LineLayer) 
			{
				openLayerState();
				
				var layer:LineLayer = LineLayer(activeLayer);
				var style:Style = styleManager.activeStyle;
				
				layer.line.applyStyle(style);
				StateManager.lock();
				convertLine(style.lineStyle.smoothing);
				StateManager.unlock(this);
				
				activeLayer.updateDisplay();
				
				closeLayerState();
				
				toolManager.resetTool();
				setCanvasUpdateTimeout();
				//setTimeout(updateViews, 100, GraphicUpdate.canvasUpdate());
			}
		}
		
		public function flattenLayers (toStyleDeco:Boolean=false):void
		{
			//// // Consol.Trace("flatten layers");
			
			//StateManager.reset();
			//StateManager.lock();
			// are these done elsehwere?
			// if not, we can't be doing this when we're just creating a style deco
			
			try
			{
			
				var bmp:BitmapData = getImage(activeLayerDepths, null, true);
				
				var fileName:String = FileManager.getInstance().saveFlattenedLayerImage(bmp, activeLayer.getFileName());
				
				// This is for positioning the cropped flattened image in the same location as the original assets
				
				
				if (!toStyleDeco)
				{
					toolManager.setQuickTool();
					var settings:Settings = transformTool.settings;
					toolManager.finishQuickTool();
					var pt:Point = new Point (settings.x, settings.y);
					
					nextLayerInitProps = {x:pt.x,
										  y:pt.y,
										  rotation:0,
										  scaleX:1,
										  scaleY:1,
										  color:-1,
										  colorPercent:0,
										  alpha:1,
										  enabled:true};
										  
					loadImageLayer(fileName);
				}
				else
				{
					fileName = FileManager.getInstance().copyLayerToDeco(fileName); 
					//var decoAsset:DecoAsset = FileManager.getInstance().getDecoAsset(fileName);
					styleManager.activeStyle.decoStyle.addDeco(fileName);
					styleManager.pushStyle();
					StateManager.unlock(this);
					//pushSettings();
				}
				
			}
			catch (e:Error)
			{
				StateManager.unlock(this);
				ui.alert({message:"Layer Error\nThere isn't enough layer data to complete this action.", id:"flattenError"});
			}
			
			
			//StateManager.unlock();
			
		}
		
		
		// LAYER ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function addLayer (layer:Layer):Layer
		{
			layers.push(layer);
			
			//if (Layer.isLineLayer(layer)) // // Consol.Trace(layer.loaded + " : " + layer.cached);
			
			if (layer.abstract) layer.toggleAbstract();
			
			activeLayerDepths = [layer.depth];
			
			// This should be part of the update system...
			// The update system allows for event dispatching. But its only updateEvents
			// If we do this, we'd need to adjust all the objs listening for this to to accept Update objs
			// I think thats just the toolMan
			dispatchEvent(new CanvasEvent(CanvasEvent.LAYER_ADD));

			pushSettings();
			
			//// // Consol.Trace("CanvasManager: addLayer -> " + layer.stringType);
			var d:int = layer.depth;
			var stringType:String = layer.stringType;//// // Consol.Trace(state.data.layer.depth);
			var label:String = layer.label;
			
			StateManager.addItem(function(state:Object):void{   remLayer(d);   },
								 function(state:Object):void{   var l:Layer = addLayer(getNewLayerType(stringType)); l.depth=d;  l.label=label; setCanvasUpdateTimeout();   },
								 -1, {}, -1, "CanvasManager: addLayer");
			
			return layer;
		}
		
		public function remLayer (depth:int, autoSelect:Boolean=true, checkBg:Boolean=false):void
		{
			try
			{
				var layerIndex:int = Settings.idToIndex (depth.toString(), layers, "depth");
				
				var stringType:String = layers[layerIndex].stringType;
				var d:int = depth;
				var layer:Layer = layers[layerIndex];
				var label:String = layer.label;
				
				if (Layer.isBitmapLayer(layer)) {
					
					try {
						var bmp:BitmapData = layer.solid.bitmapData.clone();
					StateManager.addItem(function():void{   var l:Layer = addLayer(getNewLayerType(stringType)); BitmapLayer(l).setBitmapData(bmp); l.label=label; l.depth=d; l.setup(); setCanvasUpdateTimeout(); pushSettings();   },
									 	 function():void{   remLayer(depth);   });
					} catch (e:Error) {
						// Consol.Trace("CanvasManager: remLayer ERROR: " + e);
					}
					
				} else {
				
					var xml:String = layer.getXML();
					StateManager.addItem(function():void{   var l:Layer = addLayer(getNewLayerType(stringType)); l.setXML(xml); l.label=label; l.depth=d; l.setup(); setCanvasUpdateTimeout(); pushSettings();   },
										 function():void{   remLayer(depth);   });
				
				}
				
				layers[layerIndex].die();
				
				delete layers[layerIndex];
	
				layers.splice(layerIndex, 1);
	
				dispatchEvent(new CanvasEvent(CanvasEvent.LAYER_DELETE));
				
				/* This was for debug
				var ldi = getLayerIndex(0);
				layers[ldi].die();
				layers.splice(ldi, 1); */
				
				if (layerIndex != 0) pushSettings(); // if we're deleting the background it means we're resetting to open a new project
				
				if (autoSelect) selectLayer(Math.max(depth-1, 0), false, true);
		
			}
			catch (e:Error)
			{
				var s:String = "Error removing layers: " + e.toString() + "\nIs this a batch process? Make sure you're removing layers top down ex: '.sort(Array.NUMERIC | Array.DESCENDING)'";
				// Consol.Trace(s);
				//trace(s);
			}
			finally
			{
				
				if (checkBg)
				{
					if (layers.length>0)
					{
						if (!Layer.isBackgroundLayer(getLayer(0)))
						{
							restoreBackground();
						}
					}
					else
					{
						restoreBackground();
					}
				}
														  
			}
		}
		
		private function selectLayer (depth:int, inGroup:Boolean=false, forceUpdate:Boolean=false):void //, updateCanvas:Boolean=true
		{
			var layer:Layer = getLayer(depth);
			
			if (!inGroup) activeLayerDepths = [depth];
			
			activeLayerDepths.sort(Array.NUMERIC);
		
			try { 
				layer.changed = true;
			} catch (e:Error) {
				// Consol.Trace("CanvasManager: selectLayer ERROR: " + e + "\nlayer = " + layer + " layerDepth = " + depth); 
				
			}

			if (!inGroup || forceUpdate)
			{
				if (activeTool is BrushTool || Layer.isBoxLayer(activeLayer) || Layer.isBitmapLayer(activeLayer) || forceUpdate) updateViews(GraphicUpdate.canvasUpdate()); // conditional here because we dont want the caching delay each time we click to draw
				dispatchEvent(new CanvasEvent(CanvasEvent.LAYER_SELECT));
			}
			
			//Canvas.STAGE.focus = canvas;
			
			pushSettings();
		}
		
		private function selectLayerGroup (depths:Array):void
		{
			for (var i:int=0; i<depths.length; i++) selectLayer(depths[i], true);
			
			dispatchEvent(new CanvasEvent(CanvasEvent.LAYER_SELECT));
			
			if (activeTool is BrushTool) updateViews(GraphicUpdate.canvasUpdate());
			// because selecting doesn't change anything. but if we click to draw, we need to already have the above and below layer comps in place
			// because we hide the master comp when drawing (LiveBrush)
		}
			
		public function changeLayerSelection (depthsList:Array):void
		{
			try {
				var lastActiveLayerDepths:Array = activeLayerDepths;
			
				StateManager.addItem(function(state:Object):void{   changeLayerSelection(state.data.lastDepths);   },
									 function(state:Object):void{   changeLayerSelection(state.data.depths);   },
									 -1, {lastDepths:lastActiveLayerDepths.slice(), depths:depthsList.slice()}, -1, "CanvasManager: changeLayerSelection");
				StateManager.closeState();
				
				// This is called from the Layers panel. Later it will be formalized in a layer panel controller. But they'll still be custom.
				// Model and Controller are custom for eachother other
				activeLayerDepths = depthsList;
				if (activeLayerDepths.length > 1) selectLayerGroup(depthsList);
				else selectLayer(depthsList[0]);
			} catch (e:Error) {
				// Consol.Trace("CanvasManager: changeLayerState ERROR 1: " + e);
				StateManager.clearState();
				selectLayer(depthsList[0]);
			} catch (e:Error) {
				// Consol.Trace("CanvasManager: changeLayerState ERROR 2: " + e);
				StateManager.clearState();
				selectLayer(0);
			}
		}
		
		public function moveLayer (depth:int, dir:int):void
		{
			StateManager.addItem(function(state:Object):void{   moveLayer(depth+dir, -1*dir);   },
								 function(state:Object):void{   moveLayer(depth, dir);   },
								 -1, {});
			StateManager.closeState();
			
			canvas.moveLayer(depth, depth+dir);
			activeLayerDepths = [depth+dir];
			
			updateViews(GraphicUpdate.canvasUpdate());
			
			dispatchEvent(new CanvasEvent(CanvasEvent.LAYER_MOVE));
			
			pushSettings();
		}
		
		public function adjustLayer (depth:int, props:Object):void
		{
			var layer:Layer = getLayer(depth);
			
			//if (!Layer.isBackgroundLayer(layer))
			//{
				var settings:Settings = new Settings();
				
				settings.alpha = layer.alpha;
				settings.blendMode = layer.blendMode;
				settings.color = layer.color;
				settings.colorPercent = layer.colorPercent;
				settings.label = layer.label;
				
				layer.alpha = props.alpha;
				layer.blendMode = props.blendMode;
				layer.color = props.color;
				layer.colorPercent = props.colorPercent;
				layer.label = props.label;
				
				StateManager.addItem(function(state:Object):void{   adjustLayer(depth, state.data.oldProps);   },
									 function(state:Object):void{   adjustLayer(depth, state.data.newProps);   },
									 -1, {oldProps:settings.copy(), newProps:props.copy()}, -1, "CanvasManager: adjustLayer");
				StateManager.closeState();
				
				activeLayerDepths = [depth];
				
				updateViews(GraphicUpdate.canvasUpdate());
				
				pushSettings();
			//}
			
		}
		
		public function dupLayer (depth:int):void
		{
			//var tempClipboard:Array = _clipboard;
			copyContent();
			pasteContent();
			_clearClipboard();
			//toolManager.resetTool();
			
			/*activeLayerDepths[depth+1];
			
			var newLayer:Layer = getLayer(depth).copy();
			
			StateManager.addItem(function():void{   remLayer(depth+1);   },
								 function():void{   dupLayer(depth);   });
			
			StateManager.lock();
			addLayer (newLayer);
			StateManager.unlock(this);
			
			// GOOD NOTES
			// need to delay this for img/swf layers. because they wont be loaded right away.
			// for now, just a timeout. but later - need to think of something better
			// possibly a select layer, with no canvas draw for this layer (because there would be nothing to draw yet)
			// this should just un cache the layer - which would simply show the content as soon as its loaded
			//updateViews(GraphicUpdate.canvasUpdate());
			// toolManager.resetTool();
			setTimeout(updateViews, 100, GraphicUpdate.canvasUpdate());*/
		}
		
		public function addBitmapLayer (openState:Boolean=false):BitmapLayer {
		
			if (openState) StateManager.openState();
			
			var bL:BitmapLayer = addLayer(Layer.newBitmapLayer(canvas)) as BitmapLayer;
			
			if (openState) StateManager.closeState();
		
			return bL;
		}


		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function getSVG (depthList:Array):XML
		{
			var layer:Layer;
			var svg:XML = new XML(<svg xmlns='http://www.w3.org/2000/svg' />);
			//var svgXML:XML = new XML("<?xml version='1.0'?><!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.0//EN' 'http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd'>");
			
			for (var i:int=0; i<depthList.length; i++)
			{
				layer = getLayer(depthList[i]);
				if (layer is LineLayer) if (LineLayer(layer).line.created) svg.appendChild(LineLayer(layer).line.getSVG());
			}
			
			//svgXML.appendChild(svg);
			//// Consol.Trace(svg);
			return svg//XML;
		}
		
		public function setXML (xml:String):void
		{
			StateManager.reset();
			StateManager.lock();
			
			//ui.showLoadDialog({message:"Loading Project", loadPercent:0, id:"loadProject"});
			
			canvas.hide();
			
			_tempLayerCount = 0;
			lineLayerBuffer = [];
			layerLoadQueue = [];
			loadedLayers = [];
			//layers = [];
			var layersXML:XML = new XML(xml);
			var newLayer:Layer;
			
			try
			{
				if (layersXML.layer[0].@type != Layer.BACKGROUND)
				{
					layersXML.insertChildBefore(layersXML.layer[0], BackgroundLayer.getDefaultXML());
					//// // Consol.Trace("CanvasManager: missing bg layer TRY");
				}
			}
			catch (e:Error)
			{
				// // Consol.Trace("CanvasManager: missing bg layer CATCH");
				//layersXML.appendChild(BackgroundLayer.getDefaultXML());
			}
			
			// we should make sure the order hasn't been fucked with in the xml. if it is this would crash the app.
			//layersXML = sortXML (layersXML, );
			//var depth:int = layersXML.layer.length();
			var typeString:String;
			
			for each (var layer:XML in layersXML.*) 
			{
				typeString = layer.@type
				
				if ((typeString == Layer.BACKGROUND && !omitBg) || typeString != Layer.BACKGROUND)
				{
					newLayer = getNewLayerType(typeString);
					
					newLayer.layerXML = layer;
					
					layerLoadQueue.push(newLayer);
					
					incompleteLayersCount++;
				}
			}
			
			_tempLayerCount = layerLoadQueue.length; // for predetermining the number of layers. for ui load progress.
			
			if (layerLoadQueue.length>0) loadLayer(layerLoadQueue.shift());
			else canvasComplete();
			
			//StateManager.unlock();
			
			omitBg = false;
		}
		
		public function getXML ():XML
		{
			var layersXML:XML = new XML (<layers></layers>);
			
			layers.sortOn("depth", Array.NUMERIC); //   | Array.DESCENDING
			
			for (var i:int=0;i<layers.length;i++)
			{
				layersXML.appendChild(layers[i].getXML());
			}
			
			return layersXML;
		}
		
		// only used for project loading
		private function loadLayer (layer:Layer):void
		{
			//// // Consol.Trace(_activeLayerDepths);
			//Consol.globalOutput("Loading Layer (" + layer.stringType + ") : " + layer.label);
			//Consol.globalOutput(loadedLayers.length + " :" + layerLoadQueue.length);
			ui.updateDialogs(Update.loadingUpdate({message:"Loading Project\n" + layer.layerXML.@label, loadPercent:loadedLayers.length/_tempLayerCount}));
			
			layer.addEventListener(Event.COMPLETE, layerComplete);
			layer.addEventListener(IOErrorEvent.IO_ERROR, layerError);
			layer.setXML(layer.layerXML);
		}
		
		// only used for project loading
		private function canvasComplete ():void
		{
			UI.setStatus("Ready");
			ui.closeDialogID("loadProject");
			//ui.closeDialog(ui.projectLoadDialog);
			//ui.updateDialogs({message:("Loading Layer (" + layer.depth + "): " + layer.label), loadPercent:loadedLayers.length/layerLoadQueue.length});
			
			var layer:Layer
			for (var i:int=0; i<loadedLayers.length; i++)
			{
				layer = loadedLayers[i];
				addLayer(layer);
				layer.generateThumb();
			}
			
			// selectLayer(Math.max(0, layers.length-1));
			selectLayer(layers.length-1);
			
			canvas.show();
			
			pushSettings();
	
			StateManager.unlock(this);

			updateViews(GraphicUpdate.canvasUpdate());
			
			CanvasController(canvasView.controller).resize();
			
			dispatchEvent (new Event(Event.COMPLETE, true, false));
			
			StateManager.changed = false;
			
			styleManager.selectStyle(0);
			
			//pushColorProps(globalColorView.settings);
			//styleManager.lockColors(false);
			
			// missing bg error handling. fake fix.
			/*if (layers.length>0)
			{
				if (!Layer.isBackgroundLayer(getLayer(0)))
				{
					restoreBackground();
				}
			}
			else
			{
				restoreBackground();
			}*/
		}

		// These two are called from main and flatten layers
		public function loadImageLayer (url:String, batch:Boolean=false):void
		{
			StateManager.reset();
			StateManager.lock();
			
			//// // Consol.Trace("load image layer");
			//var dialog:DialogWindow = UI.showDialog();
			var layer:ImageLayer = addLayer(Layer.newImageLayer(canvas, url, nextLayerInitProps)) as ImageLayer;
			//layer.addEventListener(Event.COMPLETE, dialog.autoCloseFn);
			layer.addEventListener(Event.COMPLETE, layerImageComplete);
			batchLoading = batch;
			
			//StateManager.unlock();
		}
		
		// These two are called from main and flatten layers
		public function loadSWFLayer (url:String, batch:Boolean=false):void
		{
			StateManager.reset();
			StateManager.lock();
			
			//var dialog:DialogWindow = UI.showDialog();
			var layer:SWFLayer = addLayer(Layer.newSWFLayer(canvas, url, nextLayerInitProps)) as SWFLayer;
			//layer.addEventListener(Event.COMPLETE, dialog.autoCloseFn);
			layer.addEventListener(Event.COMPLETE, layerImageComplete);
			batchLoading = batch;
			
			//StateManager.unlock();
		}
		
		public function getImage (depthList:Array, rect:Rectangle=null, cropAlpha:Boolean=false):BitmapData
		{
			var bitmap:Bitmap = canvas.newCanvasBitmap(rect);
			var layer:Layer;
			depthList.sort(Array.NUMERIC);
			//// // Consol.Trace(depthList);
			for (var i:int=0; i<depthList.length; i++)
			{
				layer = getLayer(depthList[i]);
				if (layer is LineLayer && layer.loaded && !layer.cached) layer.updateDisplay();
				layer.drawTo(bitmap);
			}
			
			if (cropAlpha)
			{				
				var mat:Matrix = new Matrix();
				var rect:Rectangle = bitmap.bitmapData.getColorBoundsRect(0xFFFFFFFF, 0x00000000, false);
				//// // Consol.Trace(rect);
				mat.translate(-rect.x, -rect.y);
				var cropBmp:BitmapData = canvas.newCanvasBitmapData(rect);
				cropBmp.draw(bitmap.bitmapData, mat, null, null, null, false);
				bitmap.bitmapData.dispose();
				bitmap.bitmapData = cropBmp;
			}
			
			return bitmap.bitmapData;
		}
		
		public function getCanvasImage (bmpU:BitmapDataUnlimited, res:int=0, allLayers:Boolean=true):BitmapData // 0, 1, 2
		{
			canvas.upScale(res);
		
			var layerStates:Array = [];
			var layer:Layer;
			var i:int;
			
			if (!allLayers) {
				// store the visible prop from each layer
				// hide all layers
				for (i=0; i<layers.length; i++)
				{
					layer = layers[i];
					layerStates[i] = layer.enabled;
					layer.enabled = false;
				}
				
				// show selected layers
				for (i=0; i<activeLayerDepths.length; i++)
				{
					getLayer(activeLayerDepths[i]).enabled = true;
				}
			}
		
			
			for (i=0; i<layers.length; i++)
			{
				layer = layers[i];
				if (layer is LineLayer) 
				{
					//layer.updateDisplay(false);
					//LineLayer(layer).cache(false, true);
					LineLayer(layer).redraw()
				}
				// image layers and image decos probably wont upscale, because we're scaling the parent... 
				// this even includes swf layers and swf decos :(
				// this will have to be for v1.5 or 2
				// to get around the no matrix draw on bmpU, we might be able to temporarily add the layers to a parent
				// and offset them so their in the same position... 
			}
			
			canvasView.showAllLayers();
			
			var layersHolder:Sprite = new Sprite();
			layersHolder.addChild(canvas.layers);
			
			bmpU.draw(layersHolder, null, null, true);
			
			canvas.comp.addChildAt(canvas.layers, canvas.layersDepth);
			
			canvas.downScale();

			//canvasView.update(GraphicUpdate.canvasUpdate());
			for (i=0; i<layers.length; i++)
			{
				layer = layers[i]; 
				if (layer is LineLayer) 
				{
					LineLayer(layer).cache(); //updateDisplay();
				}
			}
			canvasView.toggleMasterComp(true);
			canvasView.belowLayerComp.visible = canvasView.aboveLayerComp.visible = true;
			//updateViews(GraphicUpdate.canvasUpdate());
			
			if (!allLayers) {
				// set all the visibilities back
				for (i=0; i<layers.length; i++)
				{
					layer = layers[i];
					layer.enabled = layerStates[i];
				}
			}

			return bmpU.bitmapData;
		}
		
		public function storeSelectedObjects (transformOnly:Boolean=true):Array
		{
			if (!StateManager.global.locked)
			{
				//// // Consol.Trace("store selected objects");
				
				var selectedObjects:Array = [];
				var i:int;
				var layer:Layer;
				
				/*if ( Layer.isBitmapLayer(activeLayer) )//  && toolManager.activeTool == brushTool
				{
					//// Consol.Trace("CanvasManager: storeSelectedObjects: bitmap layer while using brushTool");
					selectedObjects.push({transformOnly:false, type:"bitmap", layerDepth:activeLayerDepths[i], bitmapData:activeLayer.solid.bitmapData.clone()});
				} 
				else */
				if ((activeLayerDepths.length > 1 || (activeLayerDepths.length == 1 && (Layer.isBoxLayer(activeLayer) || Layer.isBitmapLayer(activeLayer))))   )//||
				{
					//// // Consol.Trace(activeLayerDepths.length);
					for(i=0; i<activeLayerDepths.length; i++)
					{
						layer = getLayer(activeLayerDepths[i]);
						if (Layer.isBitmapLayer(layer)) selectedObjects.push({transformOnly:false, type:"bitmap", layerDepth:layer.depth, bitmapData:layer.solid.bitmapData.clone()});
						else selectedObjects.push({transformOnly:transformOnly, type:"layer", layerDepth:layer.depth, xml:layer.getXML().toXMLString()});
						//selectedObjects.push({transformOnly:transformOnly, type:"layer", layerDepth:activeLayerDepths[i], xml:getLayer(activeLayerDepths[i]).getXML().toXMLString()});
					}
				}
				else if ((toolManager.activeTool == transformTool || toolManager.quickTool == transformTool))
				{
					try 
					{
						if (activeLayerDepths.length == 1 && Layer.isLineLayer(activeLayer) && transformTool.selectedEdges.length==LineLayer(activeLayer).line.length)
						{
							selectedObjects.push({transformOnly:transformOnly, type:"layer", layerDepth:activeLayer.depth, xml:activeLayer.getXML().toXMLString()});
						}
						else // it will have to be a single line layer with less edges selected than the line length
						{
							var line:Line = LineLayer(activeLayer).line;
							var edgeIndices:Array = transformTool.selectedEdgeIndices;
							for(i=0; i<edgeIndices.length; i++)
							{
								selectedObjects.push({transformOnly:transformOnly, type:"edge", layerDepth:activeLayer.depth, edgeIndex:edgeIndices[i], xml:line.edges[edgeIndices[i]].getXML().toXMLString()});
							}
						}
					}
					catch (e:Error)
					{
						// // Consol.Trace("No edges to select.");
					}
					
				}
				
				if (selectedObjects.length == 0)
				{
					// This works when we draw to create a new bitmap layer, and then draw another line because the first time gave the layer the xml it needed
					//// Consol.Trace("CanvasManager: No selected objects");
					selectedObjects.push({transformOnly:transformOnly, type:"layer", layerDepth:activeLayer.depth, xml:activeLayer.getXML().toXMLString()});
				}
			}
			else
			{
				selectedObjects = _selectedObjects;
			}
				
			return selectedObjects;
		}
		
		public function setObjectsXML (objs:Array, transformOnly:Boolean=true):void
		{
			var i:int;
			var o:Object;
			var layer:Layer;
			
			for (i=0; i<objs.length; i++)
			{
				o = objs[i];
				layer = getLayer(o.layerDepth);
				
				if (o.type == "layer")
				{
					if (Layer.isBoxLayer(layer) && o.transformOnly) layer.setTransformXML(o.xml);
					else layer.setXML(o.xml);
				}
				else if (o.type == "edge")
				{
					LineLayer(layer).line.setEdgeXML(o.edgeIndex, o.xml, !o.transformOnly);
				} 
				else if (o.type == "bitmap") 
				{
					BitmapLayer(layer).setBitmapData(o.bitmapData);
				}
				
				//getLayer(o.layerDepth).updateDisplay();
			}
			
			// Might be able to use this when importing image and swf layers (or attach, detatch decos)
			/*StateManager.addItem(function(state:Object):void{   setObjectsXML(state.data.beginObjectsXML);   },
								 function(state:Object):void{   setObjectsXML(state.data.finishObjectsXML);   },
								 -1, {beginObjectsXML:_selectedObjects.slice(), finishObjectsXML:storeSelectedObjects().slice()});
			StateManager.closeState();*/
			
			//updateViews(GraphicUpdate.canvasUpdate());
			setCanvasUpdateTimeout();
			
			pushSettings();
		}
		
		public function openLayerState (transformOnly:Boolean=true):void
		{
			StateManager.openState();
			_selectedObjects = storeSelectedObjects(transformOnly);
		}
		
		public function closeLayerState (transformOnly:Boolean=true):void
		{
			StateManager.addItem(function(state:Object):void{   setObjectsXML(state.data.beginObjectsXML);   },
								 function(state:Object):void{   setObjectsXML(state.data.finishObjectsXML);   },
								 -1, {beginObjectsXML:_selectedObjects.slice(), finishObjectsXML:storeSelectedObjects(transformOnly).slice()}, -1, "CanvasManager: closeLayerState");
			StateManager.closeState();
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function stateChange (e:StateEvent):void
		{
			toolManager.stateChange(e);
		}
		
		private function canvasAddedToStage (e:Event):void
		{
			canvasView.canvas.removeEventListener(Event.ADDED_TO_STAGE, canvasAddedToStage);
			initCanvas();
		}

		public function canvasMouseEvent (e:CanvasEvent):void
		{
			dispatchEvent(e.clone());
		}
		
		public function canvasKeyEvent (e:CanvasEvent):void
		{
			dispatchEvent(e.clone());
		}

		public function selectionUpdate (e:UpdateEvent):void
		{
			selectLayer(activeLayerDepth);
		}
		
		public function updateLayers (e:UpdateEvent):void
		{
			//// // Consol.Trace("CanMan: updateLayers");
			/*for (var i:int=0; i<e.data.layers.length; i++)
			{
				e.data.layers[i].updateDisplay();
			}*/
			//setCanvasComps();
		}
		
		public function toolUpdate (e:UpdateEvent):void
		{
			//// // Consol.Trace("CanvasManager: " + e);
			
			var i:int;
			if (e.type == UpdateEvent.BEGIN)
			{
				// // Consol.Trace("CanvasManager: ToolMan.BEGIN event");
				
				//_selectedObjects = storeSelectedObjects();
				
				//StateManager.openState(); // just in case there is an other open state - this will close it first.
				
				if (Layer.isBoxLayer(activeLayer)) updateViews(GraphicUpdate.canvasUpdate());
				canvasView.toggleMasterComp(false);
			}
			else if (e.type == UpdateEvent.FINISH)
			{
				// // Consol.Trace("CanvasManager: ToolMan.FINISH event");
				
				/*for (i=0; i<layers.length; i++)
				{
					if (!layers[i].cached) layers[i].updateDisplay();
				}*/
				
				/*StateManager.openState();
				StateManager.addItem(function(state:Object):void{   setObjectsXML(state.data.beginObjectsXML);   },
									 function(state:Object):void{   setObjectsXML(state.data.finishObjectsXML);   },
									 -1, {beginObjectsXML:_selectedObjects.slice(), finishObjectsXML:storeSelectedObjects().slice()});
				StateManager.closeState();*/
				
				UI.setStatus("Busy");
				
				//if (!StateManager.global.locked) updateViews(GraphicUpdate.canvasUpdate());
				if (!StateManager.global.locked) setCanvasUpdateTimeout();
			}
		}
		
		// only used for project loading
		private function layerComplete (e:Event):void
		{
			var layer:Layer = e.target as Layer;
			
			//Consol.globalOutput("CanvasManager: Layer Loaded: " + layer.label);
			
			layer.removeEventListener(e.type, layerComplete);
			
			loadedLayers.push(layer);
			
			incompleteLayersCount--;
			
			if (layer is LineLayer) layer.setup();
			
			if (incompleteLayersCount == 0) canvasComplete();
			else setTimeout(loadLayer, 50, layerLoadQueue.shift());
			
		}
		
		private function layerError (e:IOErrorEvent):void
		{
			var layer:Layer = e.target as Layer;
			
			//Consol.globalOutput("CanvasManager: Layer Error> Possible missing asset> " + layer["src"]);
			
			layer.removeEventListener(e.type, layerComplete);
			layer.removeEventListener(e.type, layerError);
			
			//loadedLayers.push(layer);
			_tempLayerCount--;
			
			layer.die();
			
			incompleteLayersCount--;
			
			if (incompleteLayersCount == 0) canvasComplete();
			else setTimeout(loadLayer, 50, layerLoadQueue.shift());
			
		}
		
		private function layerImageComplete (e:Event):void
		{
			//Consol.globalOutput("Image Layer Loaded!");
			e.target.removeEventListener(e.type, layerImageComplete);
			//Consol.globalOutput("Batch Loading: " + batchLoading);
			if (batchLoading)
			{
				batchLoadCount--;
				if (batchLoadCount == 0)
				{
					updateViews(GraphicUpdate.canvasUpdate());
					selectLayer(activeLayerDepth);
					StateManager.unlock(this);
				}
			}
			else
			{
				updateViews(GraphicUpdate.canvasUpdate());
				selectLayer(activeLayerDepth);
				StateManager.unlock(this);
			}
			
			// BAH - This action resets the undo state. 
			// This is because we could be adding an unknown number of layers async.
			// Otherwise, this would ultimatly affect the other objects undo information (depth position mainly).
			/*StateManager.addItem(function(state:Object):void{   remLayer(state.data.layerDepth);   },
								 function(state:Object):void{   var l:Layer = state.data.layer; l.setXML(state.data.layerXML); l.setup(); updateViews(GraphicUpdate.canvasUpdate()); pushSettings();   },
								 -1, {layerDepth:activeLayerDepth, layerXML:activeLayer.getXML().toXMLString()}, activeLayerDepth);
			if ((batchLoading && batchLoadCount == 0) || batchLoading != true) StateManager.closeState();*/
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function restoreBackground ():void
		{
			// // Consol.Trace("CanvasManager: restoreBackground");
			//layers.unshift(Layer.createBackgroundLayer());
			StateManager.unlock(this);
			StateManager.reset();
			StateManager.lock();
			addLayer(Layer.createBackgroundLayer());
			StateManager.unlock(this);
			StateManager.reset();
			pushSettings();
		}
		
		private function setCanvasUpdateTimeout ():void
		{
			//// // Consol.Trace("setCanvasUpdateTimeout");
			if (_canvasUpdateTimeout != -1) clearTimeout(_canvasUpdateTimeout);
			_canvasUpdateTimeout = setTimeout(updateViews, 100, GraphicUpdate.canvasUpdate());
			//_canvasUpdateTimeout = setTimeout(updateViews, 100, GraphicUpdate.canvasUpdate());
		}
		
		private function _clearClipboard ():void
		{
			for (var i:int=0; i<_clipboard.length; i++)
			{
				if (_clipboard[i] is Line) _clipboard[i].die();
			}
			_clipboard = [];
		}
		
		private function getNewLayerType (typeString:String):Layer
		{
			var newLayer:Layer;
			
			switch (typeString)
			{
				case Layer.LINE: newLayer = new LineLayer(canvas); break;
				case Layer.IMAGE: newLayer = new ImageLayer(canvas); break;
				case FileManager.LAYER_IMAGE: newLayer = new ImageLayer(canvas); break;
				case Layer.SWF: newLayer = new SWFLayer(canvas); break;
				case Layer.COLOR: newLayer = new ColorLayer(canvas); break;
				case Layer.BITMAP: newLayer = new BitmapLayer(canvas); break;
				case Layer.BACKGROUND: newLayer = new BackgroundLayer(canvas); break;
			}
			
			return newLayer;
		}
		
		public function getLayer(depth:int):Layer
		{
			var layer:Layer;			
			for (var i:int=0; i<layers.length; i++) if (layers[i].depth == depth) layer = layers[i]; 
			return layer;
		}
		
		private function getLayerIndex(depth:int):int
		{
			var listIndex:int;			
			for (var i:int=0; i<layers.length; i++) if (layers[i].depth == depth) listIndex = i;
			return listIndex;
		}
		
		public function get settings ():Settings
		{
			var settings:Settings = new Settings();
		 
			settings.layers = layers.slice(); // create the raw object here
			// keep undo/redo in mind. ideally we can just store an array of settings objects. 
			// but this will get weird when we delete object that we store references from in the settings object
			// all objects (layers, lines, strokes, etc) should always have a settings object that detatches itself from the object
			// so we can just assign that settings object back to it to restore the object... 
			//trace(">>>>>> sdffd : " + activeLayerDepths[0]);
			settings.activeLayerDepths = activeLayerDepths;
			
			return settings;
		}
		
		public function set settings (settings:Settings):void
		{
			//
		}
	
		private function pushSettings ():void
		{
			ui.pushLayerProps(settings);
		}
		

	}
	
	
}