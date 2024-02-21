package com.livebrush.transform
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.utils.setTimeout;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	import com.livebrush.ui.Consol;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.tools.Tool;
	import com.livebrush.transform.LayerBoxController;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.transform.TransformSprite;
	import com.livebrush.transform.TransformBoxView;
	
	public class LayerBoxView extends TransformBoxView
	{
		
		public var layer												:Layer;
		
		public function LayerBoxView (tool:Tool, layer:Layer, visible:Boolean=true):void
		{
			super(tool, layer.content, visible, Canvas.GRAPHIC_REPS, Canvas.CONTROLS, Canvas.WIREFRAME);
			
			this.layer = layer;
			
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function get bounds ():Rectangle {   return box.getBounds(Canvas.GRAPHIC_REPS);   }

		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function die ():void
		{
			super.die();
		}
	
		
		// CREATE VIEWS & CONTROLLERS ///////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function registerController ():void
		{
			controller = new LayerBoxController(this);
			if (visible) enableControls();
		}
		
		
	}
	
}