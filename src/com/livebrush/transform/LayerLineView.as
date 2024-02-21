package com.livebrush.transform
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import com.livebrush.ui.Consol;
	import com.livebrush.graphics.Line;
	import com.livebrush.graphics.Edge;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.tools.Tool;
	import com.livebrush.transform.LayerLineController;
	import com.livebrush.transform.TransformBoxView;
	import com.livebrush.transform.TransformSprite;
	import com.livebrush.transform.LineEdgeView;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.transform.SyncDisplay;
	import com.livebrush.utils.Selection;
	import com.livebrush.utils.Update;
	import com.livebrush.graphics.GraphicUpdate;
	import com.livebrush.events.UpdateEvent;
	import com.livebrush.transform.LineWireframeView;
	
	
	public class LayerLineView extends TransformBoxView
	{
		public var layer												:LineLayer;
		public var edgeViews											:Array;
		public var groupedEdgeIndices									:Selection; //Array;											
		private var edgeViewObjs										:Array;
		public var wireframeView										:LineWireframeView;
		private var views												:Array;
		
		public function LayerLineView (tool:Tool, layer:LineLayer, visible:Boolean=true):void
		{
			super(tool, null, visible, Canvas.GRAPHIC_REPS, Canvas.CONTROLS, Canvas.WIREFRAME);
			
			this.layer = layer;
			edgeViews = [];
			views = [];
			groupedEdgeIndices = new Selection(); // selection is just a list of indices
			init();
		}
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get line ():Line {   return layer.line;   }
		public function get allEdgeIndices ():Array {   return createIntArray(0, line.length-1);   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			createWireframeView();
			
			createEdgeViews();

			// by default, create the box view with all the edges. as if they selected all.
			selectEdges(allEdgeIndices); // always have to select all on init (because group views need the whole line bounds
		}
		
		public override function die ():void
		{
			var i:int;
			for (i=0; i<views.length; i++)
			{
				views[i].die();
			}
			
			super.die();
			
			views = [];
		}
		
		private function resetBoxView ():void
		{
			updateSelectedDisplay();
			
			if (box != null) 
			{
				super.die();
				removeEdgeViewObjs();
			}
			
		}
		
		private function removeEdgeViewObjs ():void
		{
			var tempObjs:Array = edgeViewObjs.slice();
			for (var i:int=0; i<tempObjs.length; i++)
			{
				delete tempObjs[i].c;
				delete tempObjs[i].a;
				delete tempObjs[i].b;
			}
			tempObjs = [];
			edgeViewObjs = [];
		}
		
		
		// CREATE VIEWS & CONTROLLERS ///////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			// creates a box view for the line
			// creates a graphic rep based on the bounds of all edges
			// and puts sync points in it that sync with the actual edge views
			
			// create a list of all the edge points in the group 
			var edgePoints:Array = [];
			var i:int;
			for (i=0; i<groupedEdgeIndices.length; i++)
			{
				// edge points are in the wireframe scope
				// this is needed because the box is created in the box scope, which is the same as the actual visual content (layer and wireframe)
				edgePoints = edgePoints.concat(edgeViews[groupedEdgeIndices.items[i]].edgePoints);
			}   
			
			var edgeBounds:Rectangle = getPointRect(edgePoints);
			
			box = new TransformSprite();
			Canvas.GRAPHIC_REPS.addChild(box);
			box.x = edgeBounds.x;
			box.y = edgeBounds.y;
			
			box.graphics.beginFill(0xFF0000, 1);
			//// // Consol.Trace(edgeBounds);
			//trace(edgeBounds);
			box.graphics.drawRect(0, 0, edgeBounds.width, edgeBounds.height);
			box.graphics.endFill();
			
			setupView (box);
			
			// create boxPoints object for each edge (so we know which point apply to which edge)
			var edgePointsObj:Object;
			var edgeView:LineEdgeView;
			edgeViewObjs = [];
			for (i=0; i<groupedEdgeIndices.length; i++)
			{
				edgeView = edgeViews[groupedEdgeIndices.items[i]];
				edgePointsObj = {c:new SyncDisplay(Canvas.CONTROLS, edgeView.controlC, box, new Point()),
								 a:new SyncDisplay(Canvas.CONTROLS, edgeView.controlA, box, new Point()),
								 b:new SyncDisplay(Canvas.CONTROLS, edgeView.controlB, box, new Point())};
								
				edgePointsObj.c.unregister();
				edgePointsObj.a.unregister();
				edgePointsObj.b.unregister();
				
				edgeViewObjs.push(edgePointsObj);
			}
		}
		
		private function createEdgeViews ():void
		{
			if (line.length > 0)
			{
				for (var i:int=0; i<line.length; i++)
				{
					createEdgeView(i);
				}
			}
		}
		
		private function createEdgeView (edgeIndex:int):void
		{
			var edgeView:LineEdgeView = LineEdgeView(registerView(new LineEdgeView(tool, this, layer, edgeIndex, visible)));
			edgeViews.push(edgeView);
		}
		
		private function createWireframeView ():void
		{
			wireframeView = LineWireframeView(registerView(new LineWireframeView(tool, line)));
		}
		
		private function registerView (view:Object):Object // Object for now because all the views don't extend from a main
		{
			views.push(view);
			return view;
		}
		
	
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function update (update:Update=null):void
		{
			if (update.type == UpdateEvent.GROUP) 
			{
				groupUpdate();
			}
			else
			{
				for (var i:int=0; i<views.length; i++)
				{
					views[i].update(update);
				}
			}
			
			if (groupedEdgeIndices.length > 1) updateBoxView();
			else resetBoxView();
		}
		
		private function groupUpdate ():void
		{
			//// // Consol.Trace(visible);
			for (var i:int=0; i<edgeViewObjs.length; i++)
			{
				edgeViewObjs[i].c.updateSync(false); // 'false' to update from doc2 = the box point
				edgeViewObjs[i].a.updateSync(false);
				edgeViewObjs[i].b.updateSync(false);
			}
		}
		
		public function selectEdges (list:Array, addRemoveNew:int=2):void
		{
			// 2=new selection, 0=add to selection (if not already there), 1=remove from selection
			
			resetBoxView();
			
			//Consol.globalOutput(addRemoveNew);
			if (addRemoveNew == 2) groupedEdgeIndices.clear();
			
			for (var i:int=0; i<list.length; i++)
			{
				// list should just be a list of indices
				if (addRemoveNew == 2 || addRemoveNew == 0) groupedEdgeIndices.addItem(list[i]);
				else if (addRemoveNew == 1) groupedEdgeIndices.addAndRemoveItem(list[i]);
				//else if (addRemoveNew == 0) groupedEdgeIndices.addItem(list[i]);
			}

			if (groupedEdgeIndices.length > 1 || addRemoveNew != 2) 
			{
				createView();
				
				controller = new LayerLineController(this);
				if (visible) enableControls();
			}
			
			tool["selectionChange"]();
			
			//// // Consol.Trace("LayerLineView: selected edges: " + );
			updateSelectedDisplay();
		}
		
		public function selectEdgesWithinBounds (b:Rectangle, addRemoveNew:int=2):void
		{
			var selectedEdgeIndices:Array = [];
			var selectedQualifier:int = 2; // if check all three points or not. We'll pull this from the panel view settings... or it will be passed here
			var selectedEdgePoints:int = 0;
			var i:int=0;
			for (i=0; i<edgeViews.length; i++)
			{
				selectedEdgePoints = 0;				
				if (b.containsPoint(SyncPoint.objToPoint(edgeViews[i].controlC))) selectedEdgePoints++;
				if (b.containsPoint(SyncPoint.objToPoint(edgeViews[i].controlA))) selectedEdgePoints++;
				if (b.containsPoint(SyncPoint.objToPoint(edgeViews[i].controlB))) selectedEdgePoints++;
				
				if (selectedEdgePoints >= selectedQualifier) selectedEdgeIndices.push(i);
			}  
			
			if (selectedEdgeIndices.length > 0)
			{
				selectEdges(selectedEdgeIndices, addRemoveNew);
			}
			else if (selectedEdgeIndices.length == 0)
			{
				if (addRemoveNew == 2) groupedEdgeIndices.clear();
			}
		}
		
		public function updateSelectedDisplay ():void
		{
			//// // Consol.Trace(edgeViews.length + " : " + groupedEdgeIndices.length);
			for (var i:int=0; i<edgeViews.length; i++)
			{
				//(groupedEdgeIndices.length == 1 ? 2 : 1);
				// if (groupedEdgeIndices.items.indexOf(i) > -1
				
				if (groupedEdgeIndices.items.indexOf(i) > -1 && groupedEdgeIndices.length > 1) edgeViews[i].visualState = 3;
				else if (groupedEdgeIndices.items.indexOf(i) > -1 && groupedEdgeIndices.length == 1) edgeViews[i].visualState = 2;
				else edgeViews[i].visualState = 1;
			}
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function getGroupedEdgeUpdateObjs ():Array
		{
			var list:Array = [];
			var updateObj:Object;
			for (var i:int=0; i<groupedEdgeIndices.length; i++)
			{
				updateObj = edgeViews[groupedEdgeIndices.items[i]].getUpdateObj();
				list.push(updateObj);
			}
			return list;
		}
		
		public function getSelectedEdges ():Array
		{
			var edgeList:Array = [];
			for (var i:int=0; i<groupedEdgeIndices.length; i++)
			{
				edgeList.push(edgeViews[groupedEdgeIndices.items[i]].edge);
			}
			return edgeList;
		}
		
		public function getSelectedEdgeIndices ():Array
		{
			var edgeList:Array = [];
			for (var i:int=0; i<groupedEdgeIndices.length; i++)
			{
				edgeList.push(edgeViews[groupedEdgeIndices.items[i]].edgeIndex);
			}
			return edgeList;
		}
		
		public function getSelectedDecos ():Array
		{
			var decoList:Array = [];
			var edge:Edge;
			for (var i:int=0; i<groupedEdgeIndices.length; i++)
			{
				edge = edgeViews[groupedEdgeIndices.items[i]].edge;
				if (edge.hasDecos)
				{
					decoList = decoList.concat(edge.decoGroup.decoList);
				}
			}
			return decoList;
		}
		
		private function getPointRect (pts:Array):Rectangle
		{
			var boxSize:Number = .0001;
			//trace(pts);
			var rect:Rectangle = new Rectangle(pts[0].x, pts[0].y, boxSize, boxSize);
			for (var i:int=1; i<pts.length; i++)
			{
				rect = rect.union(new Rectangle(pts[i].x, pts[i].y, boxSize, boxSize));
			}
			return rect;
		}
		
		private function createIntArray (start:int, end:int):Array
		{
			var list:Array = [];
			for (var i:int=start; i<=end; i++)
			{
				list.push(i);
			}
			return list;
		}

	}
	
}