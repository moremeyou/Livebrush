package com.livebrush.tools
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.setTimeout
	import flash.events.TimerEvent;
	
	import com.livebrush.data.StateManager;
	import com.livebrush.data.Settings;
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.events.ToolbarEvent;
	import com.livebrush.events.HelpEvent;
	import com.livebrush.events.CanvasEvent;
	import com.livebrush.events.ControllerEvent;
	import com.livebrush.ui.Panel
	import com.livebrush.ui.UI;
	import com.livebrush.ui.Consol;
	import com.livebrush.tools.Tool;
	import com.livebrush.tools.ToolManager;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.Line;
	import com.livebrush.graphics.SmoothLine;
	import com.livebrush.graphics.Edge;
	import com.livebrush.graphics.Stroke;
	import com.livebrush.styles.StrokeStyle;
	import com.livebrush.styles.StyleManager;
	import com.livebrush.utils.Selection;
	import com.livebrush.styles.Style; 
	import com.livebrush.transform.LayerBoxView;
	import com.livebrush.transform.LayerLineView;
	import com.livebrush.transform.LayerGroupView;
	import com.livebrush.transform.LineEdgeView;
	import com.livebrush.transform.SelectionView;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.graphics.GraphicUpdate;
	import com.livebrush.utils.Update;
	import com.livebrush.events.UpdateEvent;
	
	public class TransformTool extends Tool
	{
		public static const NAME										:String = "transformTool";
		public static const KEY											:String = "T";
		
		public static const EDGE_CHANGE									:String = "edgeChange"; // transform, edit
		public static const EDGE_SELECT									:String = "edgeSelect"; // select is different from change because we're not making any changes yet. we just want everyone else to know this edge has been selected
		public static const BOX_LAYER									:String = "box";
		public static const LINE_LAYER									:String = "line";
		public static const NONE										:String = "none";
		public static const EDGE										:String = "edge";
		public static const GROUP										:String = "group";
		
		private var layerLineView										:LayerLineView;
		private var layerViews											:Array;
		private var layerGroupView										:LayerGroupView;
		private var selectionView										:SelectionView;
		private var contentType											:String;
		public var scaleAllowed											:Boolean = true;
		public var constrain											:Boolean = false;
		private var stateIndex											:int;
		
		
		public function TransformTool (toolMan:ToolManager):void
		{
			super(toolMan);
			
			//views = [];
			
			init();
		}
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get hasSelectedDecos ():Boolean {   return (layerLineView!=null ? layerLineView.getSelectedDecos().length>0 : false);   }
		public function get selectedDecos ():Array {   return layerLineView.getSelectedDecos();   }
		public function get selectedEdges ():Array {   return layerLineView.getSelectedEdges();   }
		public function get selectedEdgeIndices ():Array {   return layerLineView.getSelectedEdgeIndices();   }
		public function get mainView ():Object {   return (contentType==GROUP ? layerGroupView : layerViews[0]);   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void 
		{
			name = NAME;
		}
		
		public override function setup ():void
		{
			super.setup(); 
			
			//canvas.comp.scaleX = canvas.comp.scaleY = 1.25;
			// pen tool, brush tool, selecting, canvas visible size all don't work properly when you zoom

			layerViews = [];		
		
			if (_activeLayersValid())
			{
				if (activeLayers.length == 1)
				{
					setupLayerView(activeLayers[0], true);
				}
				else if (activeLayers.length > 1)
				{
					for (var i:int=0; i<activeLayers.length; i++)
					{
						setupLayerView(activeLayers[i], false); // false, to hide the views and DON'T register its controllers
					}
					setupLayerGroupView(); 
				}
				
				update(GraphicUpdate.layerUpdate());
				
				// this is also in toolMan dispatch method
				toolManager.ui.pushTransformProps(settings);
				// toolManager.ui.pushProps(transformPropsView);

			} else if (Layer.isBitmapLayer(activeLayer)) {
				//toolManager.ui.alert({message:"This layer must be flattened in PRO FEATURE\n\nPlease upgrade Livebrush to use this professional feature.", yesFunction:FileManager.getURL, yesProps:[Main.BUY_LINK], id:"proFeature"});			
			}
		}
		
		public override function reset ():void
		{
			//// // Consol.Trace("Transform Tool: reset");
			
			super.reset();
			
			contentType = null;
			
			layerLineView = null;
			
			Canvas.WIREFRAME.graphics.clear();
			
			// not sure if I should be killing all the objects on reset
			die();
		}
		
		private function setupLayerGroupView ():void
		{
			layerGroupView = LayerGroupView(registerView(new LayerGroupView(this, layerViews)));
			contentType = GROUP;
		}
		
		private function setupLayerView (layer:Layer, visible:Boolean=true):void
		{
			if (layer is LineLayer && !Layer.isBitmapLayer(layer))
			{
				if (LineLayer(layer).line.length > 0) 
				{
					layerLineView = LayerLineView(registerView(new LayerLineView(this, LineLayer(layer), visible)));
					layerViews.push(layerLineView);
					//var selectedLength:int = layerLineView.groupedEdgeIndices.length;
					//contentType = selectedLength==0 ? null : selectedLength==1 ? EDGE : LINE_LAYER;
					contentType = LINE_LAYER;
				}
			}
			else
			{
				layerViews.push(LayerBoxView(registerView(new LayerBoxView(this, layer, visible))));
				contentType = BOX_LAYER;
			}
		}
		
		
		// TOOL ACTIONS /////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function selectionChange ():void // // no, none of these for now. we're just letting everything else know this has changed. deselect, select, cancel
		{
			//// // Consol.Trace("Selection Change");
			toolUpdate();
		}

		public function deleteEdges (layer:LineLayer, edgeIndices:Array):void
		{
			begin();
			
			var edgeList:Array = [];
			//// // Consol.Trace(edgeIndices);
			for (var i:int=0; i<edgeIndices.length; i++)
			{
				edgeList.push(layer.line.edges[edgeIndices[i]]);
			}
			
			layer.line.deleteEdges(edgeList);
			
			//stateIndex = StateManager.currentIndex;
			// make sure there is a good reason the states are setup in the actual object
			
			reset();
			
			setup();
			
			finish(false);
			//stateIndex
			
			layerUpdate(false); // false for no delay
		}
		
		public function transformLayer (view:LayerBoxView, updateNow:Boolean=true):void
		{
			//toolManager.setQuickTool();
			//TransformTool(toolManager.quickTool).flip(x, y);
			//toolManager.finishQuickTool();
			
			try { view.layer.transform.matrix = view.box.transform.matrix; } catch (e:Error) {}
			
			layerUpdate();
		}
		
		public function transformLayerGroup (view:LayerGroupView):void
		{
			// Ideally, some of these updates would just be dispatched through an update event object
			// the canvas man would recieve this and push the update down the appropriate layer
			
			var layer:Layer;
			var layerView:Object; // Object for now because we recieve LayerBoxViews and LayerLineViews
			for (var i:int=0; i<view.layerViews.length; i++)
			{
				layerView = view.layerViews[i];
				layer = layerView.layer;
				
				if (layerView is LayerBoxView)
				{
					var mat:Matrix = layerView.box.transform.matrix;
					mat.concat(view.box.transform.matrix);
					layer.transform.matrix = mat;
				}
				else if (layerView is LayerLineView)
				{
					//LayerLineView(layerView).groupUpdate();
					LayerLineView(layerView).update(Update.groupUpdate());
					transformLine(LayerLineView(layerView).getGroupedEdgeUpdateObjs(), false);

				}
			}
			layerUpdate();
		}

		public function transformLine (edgeUpdateList:Array, updateNow:Boolean=true):void // layer:LineLayer, edgeIndices:Array,
		{
			//// // Consol.Trace("Transform Tool: Transform Line");
			
			var upObj:Object;
			var layer:LineLayer = edgeUpdateList[0].layer;
			
			for (var i:int=0; i<edgeUpdateList.length; i++)
			{
				upObj = edgeUpdateList[i];
				transformEdge(upObj, false);
			}
			
			if (updateNow) layerUpdate();
		}
		
		public function transformEdge (upObj:Object, updateNow:Boolean=true):void // 
		{
			// if no scope is passed, we assume the actual line scope
			var fromScope:Sprite = upObj.fromScope==null ? Canvas.SELECTION : upObj.fromScope;
			var layer:LineLayer = upObj.layer;
			var edgeIndex:int = upObj.index;
			var c:Object = upObj.c;
			var a:Object = upObj.a;
			var b:Object = upObj.b;
			
			if (fromScope != Canvas.WIREFRAME)
			{
				layer.line.modifyEdge(edgeIndex, 
									  SyncPoint.localToLocal(SyncPoint.objToPoint(c), fromScope, Canvas.WIREFRAME),
									  SyncPoint.localToLocal(SyncPoint.objToPoint(a), fromScope, Canvas.WIREFRAME),
									  SyncPoint.localToLocal(SyncPoint.objToPoint(b), fromScope, Canvas.WIREFRAME));
			}
			else
			{
				layer.line.modifyEdge(edgeIndex, new Point(c.x, c.y), new Point(a.x, a.y), new Point(b.x, b.y));
			}
			
			if (updateNow) 
			{
				layerUpdate();
			}
		}
		
		public function flip (x:Number, y:Number):void
		{
			if (contentType == GROUP)
			{
				layerGroupView.box.scaleX2 *= x;
				layerGroupView.box.scaleY2 *= y;
				transformLayerGroup(layerGroupView);
			}
			else if (contentType == BOX_LAYER)
			{
				
				layerViews[0].box.scaleX2 *= x;
				layerViews[0].box.scaleY2 *= y;
				transformLayer(layerViews[0]);
			}
			else if (contentType == LINE_LAYER && layerLineView.groupedEdgeIndices.length>1)
			{
				
				layerViews[0].box.scaleX2 *= x;
				layerViews[0].box.scaleY2 *= y;
				layerLineView.update(Update.groupUpdate());
				transformLine(layerLineView.getGroupedEdgeUpdateObjs(), true);
			}
			//finish(false);
		}
		
		public function rotate (deg:Number):void
		{
			if (contentType == GROUP)
			{
				layerGroupView.box.rotation2 += deg;
				transformLayerGroup(layerGroupView);
			}
			else if (contentType == BOX_LAYER)
			{
				layerViews[0].box.rotation2 += deg;
				transformLayer(layerViews[0]);
			}
			else if (contentType == LINE_LAYER && layerLineView.groupedEdgeIndices.length>1)
			{
				layerLineView.box.rotation2 += deg;
				layerLineView.update(Update.groupUpdate());
				transformLine(layerLineView.getGroupedEdgeUpdateObjs(), true);
			}
			//finish(false);
			//layerUpdate(false); // false = no delay
			// delays will be gone soon. we'll just use enter to apply.
		}
		
		public function subdivideLine ():void
		{
			layerLineView.line.subdivide();
			reset();
			//finish(false);
			setup();
			//layerUpdate(false); // false for no delay
		}
		
		public function simplifyLine ():void
		{
			layerLineView.line.simplify();
			reset();
			//finish(false);
			setup();
			//layerUpdate(false); // false for no delay
		}
		
		public function selectAllEdges ():void
		{
			if (Layer.isLineLayer(activeLayer))
			{
				layerLineView.selectEdges(layerLineView.allEdgeIndices);
			}
		}
		
		public function deselectAllEdges ():void
		{
			if (Layer.isLineLayer(activeLayer))
			{
				layerLineView.selectEdges([]);
			}
		}
		
		public function colorTransformLayerGroup (data:Settings, update:Boolean=true):void
		{
			for (var i:int=0; i<activeLayers.length; i++)
			{
				colorTransformLayer(activeLayers[i], data, false);
			}
			
			if (update) finish(false);
		}
		
		public function colorTransformLayer (layer:Layer, data:Settings, update:Boolean=true):void
		{
			layer.color = data.color;
			layer.colorPercent = data.colorPercent;
			layer.alpha = data.alpha;
			
			if (update) finish(false);
		}
		
		public function colorTransformLine (edgeUpdateList:Array, data:Settings, update:Boolean=true):void
		{
			var upObj:Object;
			var layer:LineLayer = edgeUpdateList[0].layer;
			
			for (var i:int=0; i<edgeUpdateList.length; i++)
			{
				upObj = edgeUpdateList[i];
				if (data.color !=null) layer.line.modifyEdgeColor(upObj.index, data.color);
				if (data.alpha !=null) layer.line.modifyEdgeAlpha(upObj.index, data.alpha);
			}
			
			if (update) finish(false);
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function setSelection (e:CanvasEvent):void
		{
			if (layerViews.length == 1)
			{
				if (Layer.isLineLayer(layerViews[0].layer) && !Layer.isBitmapLayer(layerViews[0].layer)) 
				{
					layerViews[0].selectEdgesWithinBounds(e.data.bounds, e.data.type);
					toolManager.ui.pushTransformProps(settings);
				}
			}
			else
			{
				//// // Consol.Trace(" set selection none ");
				selectionUpdate([activeLayer]);
			}
			
			selectionChange();
			
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function set settings (data:Settings):void
		{
			//var data:Settings = ui.transformPropsView.settings;
			//// // Consol.Trace("update tool settings");
			
			scaleAllowed = data.scaleAllowed;
			constrain = data.constrain;
			
			begin();
			
			if (contentType==GROUP || contentType==BOX_LAYER) 
			{
				mainView.box.x = data.x;
				mainView.box.y = data.y;
				mainView.box.scaleX2 = data.scaleX;
				mainView.box.scaleY2 = data.scaleY;
				mainView.box.rotation2 = data.rotation;
				
				if (contentType==GROUP) 
				{
					//colorTransformLayerGroup(data, false);
					transformLayerGroup(layerGroupView);
				}
				else if (contentType==BOX_LAYER) 
				{
					//colorTransformLayer(activeLayer, data, false);
					transformLayer(layerViews[0]);
				}
			}
			else if (contentType==LINE_LAYER) 
			{
				var edgeUpList:Array = mainView.getGroupedEdgeUpdateObjs();
				var edge:Edge;
				colorTransformLine(edgeUpList, data, false);
				
				if (edgeUpList.length > 1)
				{
					mainView.box.x = data.x;
					mainView.box.y = data.y;
					mainView.box.scaleX2 = data.scaleX;
					mainView.box.scaleY2 = data.scaleY;
					mainView.box.rotation2 = data.rotation;
					
					mainView.update(Update.groupUpdate());
					transformLine(edgeUpList, true);
				}
				else
				{
					//// // Consol.Trace("editing single edge: " + edgeUpList[0].index);
					//edge = mainView.getSelectedEdges()[0];
					//mainView.layer.line.modifyEdge(edgeUpList[0].index, new Point(data.x, data.y), edge.a, edge.b);
					edgeUpList[0].c = new Point(data.x, data.y);
					transformEdge (edgeUpList[0]);
				}

				
			}
			
			finish(false);
		}
		
		public override function get settings ():Settings
		{
			var data:Settings = new Settings();
			
			data.scaleAllowed = scaleAllowed;
			data.constrain = constrain;
			data.contentType = contentType;
			
			// what if there is no box? like when they deselect the line? try/catch? the transform panel would be disabled when this is null
			//// // Consol.Trace(mainView.box);
			
			//data.x = mainView.box.x;
			//data.y = mainView.box.y;
			//data.scaleX = mainView.box.scaleX;
			//data.scaleY = mainView.box.scaleY;
			//data.rotation = mainView.box.rotation;
			 
			//var useLayerColor:Boolean = true; 
			if (contentType==LINE_LAYER)
			{
				var edge:Edge;
				var selectedLength:int = layerLineView.groupedEdgeIndices.length;
				
				if (selectedLength > 0)
				{
					edge = layerLineView.getSelectedEdges()[0];
					data.color = edge.color;
					data.colorPercent = 1;
					data.alpha = edge.alpha;
					
					if (selectedLength > 1)
					{
						data.contentType = LINE_LAYER;
						
						data.x = mainView.box.x;
						data.y = mainView.box.y;
						data.scaleX = mainView.box.scaleX;
						data.scaleY = mainView.box.scaleY;
						data.rotation = mainView.box.rotation;
					}
					else
					{
						data.contentType = EDGE;
						
						data.x = edge.x;
						data.y = edge.y;
						data.scaleX = 1;
						data.scaleY = 1;
						data.rotation = 0;
					}
				}
				else
				{
					data.contentType = NONE;
					
					data.color = -1;
					data.colorPercent = 1;
					data.alpha = 1;
				}
			}
			else if (contentType != null)
			{
				data.x = mainView.box.x;
				data.y = mainView.box.y;
				data.scaleX = mainView.box.scaleX;
				data.scaleY = mainView.box.scaleY;
				data.rotation = mainView.box.rotation;
				
				data.color = activeLayer.color;
				data.colorPercent = (contentType==LINE_LAYER ? 100 : activeLayer.colorPercent);
				data.alpha = activeLayer.alpha;
			}
			
			return data;
		}
		
		private function _activeLayersValid ():Boolean
		{
			var valid:Boolean = true;
			for (var i:int=0; i<activeLayers.length; i++)
			{
				// if ((Layer.isBackgroundLayer(activeLayers[i]) || Layer.isBitmapLayer(activeLayers[i])) && valid) valid = false;
				if (Layer.isBackgroundLayer(activeLayers[i]) && valid) valid = false;
			}
			return valid;
		}
		
		
		// TBD / DEBUG //////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////

	}
	
}