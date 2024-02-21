package com.livebrush.transform
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import com.livebrush.ui.Consol;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.tools.Tool;
	import com.livebrush.transform.LayerBoxController;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.transform.TransformBoxView;
	import com.livebrush.transform.TransformSprite;
	
	public class LayerGroupView extends TransformBoxView
	{
		public var layer												:Layer;
		public var layerViews											:Array;
	
		
		public function LayerGroupView (tool:Tool, layerViews:Array):void
		{
			super(tool, null, true, Canvas.GRAPHIC_REPS, Canvas.CONTROLS, Canvas.WIREFRAME);
			
			this.layerViews = layerViews;
		
			init();
		}
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			//Consol.globalOutput("LAYER GROUP VIEW");
			
			createView();
			
			controller = new LayerGroupController(this);
			
			enableControls();
		}
		
		public override function die ():void
		{
			super.die();
			
			// should be killing all the layerViews
			
			//Canvas.GRAPHIC_REPS.removeChild(box);
			//box = null;
		}
		
		
		// CREATE VIEWS & CONTROLLERS ///////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			var i:int;
			
			// combine the bounds of all layerViews
			var bounds:Rectangle = layerViews[0].bounds;
			for (i=1; i<layerViews.length; i++)
			{
				bounds = bounds.union(layerViews[i].bounds);
			}

			// create group sprite at bounds topLeft
			box = new TransformSprite();
			Canvas.GRAPHIC_REPS.addChild(box);
			box.x = bounds.x;
			box.y = bounds.y;
			
			// add and position each of the views in the group sprite
			var layerViewBox:Sprite;
			var pt:SyncPoint;
			for (i=0; i<layerViews.length; i++)
			{
				layerViewBox = layerViews[i].box;
				pt = new SyncPoint(Canvas.GRAPHIC_REPS, box, new Point(layerViewBox.x, layerViewBox.y));
				box.addChild(layerViewBox);
				layerViewBox.x = pt.x2;
				layerViewBox.y = pt.y2;
			}
			
			box.graphics.beginFill(0xFF0000, 1); // you can make a method to toggle the layer reps layer in canvas
			box.graphics.drawRect(0, 0, bounds.width, bounds.height);
			box.graphics.endFill();
			
			setupView (box);
		}
		
	
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function updateBoxView (includeReg:Boolean=true):void
		{
			if (includeReg) updateRegCenter(true);
		
			for (var i:int=0; i<8; i++) // all sides, corners. NOT center reg. that is above
			{
				controlObjs[i].updateSync(true);
			}

			drawBox();
		}
		
		
	}
	
}