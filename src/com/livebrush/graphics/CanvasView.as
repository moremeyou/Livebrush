package com.livebrush.graphics
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.ui.Consol;
	import com.livebrush.graphics.Line;
	import com.livebrush.graphics.Edge;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.graphics.canvas.BitmapLayer;
	import com.livebrush.tools.Tool;
	import com.livebrush.transform.LayerLineController;
	import com.livebrush.transform.TransformBoxView;
	import com.livebrush.transform.TransformSprite;
	import com.livebrush.transform.LineEdgeView;
	import com.livebrush.utils.View;
	import com.livebrush.graphics.GraphicUpdate;
	import com.livebrush.graphics.CanvasController;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.utils.Selection;
	import com.livebrush.utils.Update;
	import com.livebrush.utils.Model;
	import com.livebrush.ui.UI;
	
	public class CanvasView extends View
	{
		
		public var canvas						:Canvas;
		
		public function CanvasView (canvasManager:Model):void
		{
			super(canvasManager);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get canvasManager ():CanvasManager {   return CanvasManager(model);   }
		public function get layers ():Array {   return canvasManager.layers;   }
		public function get masterComp ():Bitmap {   return canvas.masterComp;   }
		public function get aboveLayerComp ():Bitmap {   return canvas.aboveLayerComp;   }
		public function get belowLayerComp ():Bitmap {   return canvas.belowLayerComp;   }
		public function get sampleLayerComp ():Bitmap {   return canvas.sampleLayerComp;   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			createView();
		}
		
		public override function die ():void
		{
			//Consol.globalOutput("canvasView die");
			controller.die();
		}
		
		public function setup ():void
		{
			createController();
			registerController();
		}
		
		protected override function createView ():void
		{
			// the canvas view is just a conceptual view
			// it determines how the content is rendered and seen on the canvas

			canvas = new Canvas (canvasManager);
		}
		
		protected override function createController ():void
		{
			// the controller is the canvas responding to mouse events
			controller = new CanvasController(this);
		}
		
		protected override function registerController ():void { }
		
		
		// UPDATE ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function update (update:Update=null):void
		{
			//// // Consol.Trace(update.type);
			if (update.type == UpdateEvent.CANVAS) 
			{
				updateCanvasDisplay();
			}
		}
		
		private function updateCanvasDisplay ():void
		{
			//// // Consol.Trace("Canvas View: SET CANVAS COMPS");
			
			
			var s:int = getTimer();
			var d:int;
			var layer:Layer;
			var layersChanged:Boolean = false;
			
			// does this need to be here? why did we take it out? did that fix something? if bugs appear, try adding it back
			// activeLayerDepths.sort(Array.NUMERIC);
			
			canvas.clearBitmap(masterComp);
			canvas.clearBitmap(belowLayerComp);
			canvas.clearBitmap(aboveLayerComp);
			canvas.clearBitmap(sampleLayerComp);
			
			
			//// Consol.Trace("CanvasView: update: layers.length = " + layers.length);
			
			for (d=0; d<layers.length; d++)
			{
				layer = getLayer(d);
				
				//try { // Consol.Trace("CanvasView: update: layer.label = " + layer.label); }
				//catch (e:Error) { // Consol.Trace("CanvasView: MISSING LAYER ERROR: " + e); }
				
				// caching should also be for swf layers
				
				//if (layer.abstract) layer.toggleAbstract();
				try { 
					
					//// Consol.Trace("CanvasView: updateCanvas");
					
					if (layer is LineLayer)  //&& !layer.cached  && !Layer.isBitmapLayer(layer)
					{
						//// Consol.Trace("CanvasView: updateCanvas: layer is LineLayer");
						if (layer.enabled) 
						{
							//// Consol.Trace("CanvasView: updateCanvas: layer is enabled");
							if (Layer.isLineLayer(layer)) cacheLayer(layer as LineLayer);
							else cacheLayer(layer as BitmapLayer);
							layersChanged = true;
						}
					}/* else if (Layer.isBitmapLayer(layer)) {
						
						if (layer.loaded) if (!layer.cached) BitmapLayer(layer).redraw(); 
						//
					}*/
					
					layer.visible = true;
					
				} catch (e:Error) 
				{ 
					// Consol.Trace("CanvasView: ERROR: " + e + "\nlayer = " + layer + " layerDepth = " + d); 
				}
					
					if (layer.enabled) layer.drawTo(masterComp);
					
					if (d < canvasManager.bottomActiveLayerDepth)
					{
						if (layer.enabled) layer.drawTo(belowLayerComp);
						if (layer.enabled) layer.drawTo(sampleLayerComp);
						layer.visible = false;
					}
					else if (d >= canvasManager.bottomActiveLayerDepth && d <= canvasManager.topActiveLayerDepth) // now we're in active group
					{
						if (layer.enabled) layer.drawTo(sampleLayerComp);
						layer.visible = true; 
					}
					else if (d > canvasManager.topActiveLayerDepth) // out of the active layers
					{
						if (layer.enabled) layer.drawTo(aboveLayerComp);
						layer.visible = false;
					}
				
			}
	
			belowLayerComp.visible = true;
			aboveLayerComp.visible = true;
			
			toggleMasterComp(true);
			
			
			UI.setStatus("Ready");
		}
		
		private function cacheLayer (layer:Layer):void
		{
			//// Consol.Trace("CanvasView: trying to cache layer");
			//// // Consol.Trace(layer.loaded + " : " + layer.cached + " : " + layer.line.changed);
			/*if (Layer.isBitmapLayer(layer)) {
				BitmapLayer(layer).updateDisplay();
			} else if (Layer.isLineLayer(layer)) {*/
				if (layer.loaded) {
					//// Consol.Trace("CanvasView: layer loaded");
					if (!layer.cached) {
						//try { 
							//// Consol.Trace("CanvasView: layer NOT cached");
							layer.updateDisplay(); 
						//} catch (e:Error) {
							//// Consol.Trace("CanvasView: cacheLayer ERROR: " + e);
						//}
					}
				}
			//}
		}
		
		public function toggleMasterComp (b:Boolean):void
		{
			//Consol.globalOutput("TOGGLE MASTER COMP: " + b);
			canvas.masterComp.visible = b;
		}
		
		public function showAllLayers ():void
		{
			var layer:Layer;
			
			toggleMasterComp(false);
			belowLayerComp.visible = aboveLayerComp.visible = false;
			
			for (var d:int=0; d<layers.length; d++)
			{
				getLayer(d).visible = true;
			}
		}
		
		public function resize ():void
		{
			//canvas.x = ((canvas.stage.nativeWindow.width - Canvas.WIDTH) / 2) + canvas.offset.x;
			//canvas.y = ((canvas.stage.nativeWindow.height - Canvas.HEIGHT) / 2) + canvas.offset.y;
			canvas.x = .7 + canvas.offset.x;
			canvas.y = 30.7 + canvas.offset.y; //((canvas.stage.nativeWindow.height - Canvas.HEIGHT) / 2) + canvas.offset.y;
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function getLayer(depth:int):Layer
		{
			var layer:Layer;			
			for (var i:int=0; i<layers.length; i++) if (layers[i].depth == depth) layer = layers[i]; 
			return layer;
		}
		
		
		// TBD / DEBUG //////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////

		
	}
	
}