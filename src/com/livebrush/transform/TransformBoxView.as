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
	
	import com.livebrush.ui.Consol;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.tools.Tool;
	import com.livebrush.transform.LayerBoxController;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.transform.SyncDisplay;
	import com.livebrush.transform.TransformSprite;
	import com.livebrush.utils.Update;
	import com.livebrush.utils.View;
	import com.livebrush.utils.Controller;

	
	public class TransformBoxView extends View
	{
		public var wireframeSprite										:Sprite;
		public var boxSprite											:Sprite;
		public var controlSprite										:Sprite;
		public var box													:TransformSprite;
		public var content												:DisplayObjectContainer;
		protected var controlObjs										:Array;
		protected var regObjs											:Array;
		public var visible												:Boolean;
		private var _actualCenter										:SyncDisplay;

		public function TransformBoxView (tool:Tool, content:Sprite=null, visible:Boolean=true, boxSprite:Sprite=null, controlSprite:Sprite=null, wireframeSprite:Sprite=null):void
		{
			super(tool);
			
			this.visible = visible;
				
			this.wireframeSprite = wireframeSprite==null ? Sprite(content.parent) : wireframeSprite;
			this.boxSprite = boxSprite==null ? Sprite(content.parent) : boxSprite;
			this.controlSprite = controlSprite==null ? Sprite(content.parent) : controlSprite;
			this.content = content;
			
			controlObjs = [];
			regObjs = [];
			
			if (content != null) init();
		}
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get tool ():Tool {   return Tool(model);   }
		public function get bounds ():Rectangle {   return box.getBounds(boxSprite);   }
		public function get topLeft ():SyncDisplay {   return controlObjs[0];   }
		public function get topCenter ():SyncDisplay {   return controlObjs[1];   }
		public function get topRight ():SyncDisplay {   return controlObjs[2];   }
		public function get rightCenter ():SyncDisplay {   return controlObjs[3];   }
		public function get bottomRight ():SyncDisplay {   return controlObjs[4];   }
		public function get bottomCenter ():SyncDisplay {   return controlObjs[5];   }
		public function get bottomLeft ():SyncDisplay {   return controlObjs[6];   }
		public function get leftCenter ():SyncDisplay {   return controlObjs[7];   }
		public function get regCenter ():SyncDisplay {   return controlObjs[8];   }
		
		public function get actualCenter ():SyncDisplay {   return _actualCenter;   }
		public function get regNode ():ControlNodeAsset2 {   return ControlNodeAsset2(regCenter.child2);   }
		
		public function get topReg ():SyncDisplay {   return regObjs[0];   }
		public function get rightReg ():SyncDisplay {   return regObjs[1];   }
		public function get bottomReg ():SyncDisplay {   return regObjs[2];   }
		public function get leftReg ():SyncDisplay {   return regObjs[3];   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			createView();
			
			registerController();
			
			updateRegCenter(true);
			
			updateBoxView();
		}
		
		public override function die ():void
		{
			//Consol.globalOutput("TransformBoxView.die");
			if (box != null)
			{
				box.parent.removeChild(box);
				box = null;
				
				var tempObjs:Array = controlObjs.slice();
				for (var i:int=0; i<tempObjs.length; i++)
				{
					tempObjs[i].die();
					tempObjs[i].child2.parent.removeChild(tempObjs[i].child2);
					delete tempObjs[i];
				}
				tempObjs = [];
				controlObjs = null;
				regObjs = [];
				
				controller.die();
				controller = null;
			}
		}
		
		public function setupView (box:Sprite):void
		{
			// this method used to pass existing transformation boxes
			// this is useful when there isn't a box display object. 
			// in other words, use this method if you have created your own box from other content (grouping, vectors, etc)
		
			controlObjs = [];
			regObjs = [];
			
			createControls();
			
			updateRegCenter(true);
			
			updateBoxView();
		}
		
		
		// CREATE VIEW & CONTROLLER /////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function createView ():void
		{
			// reset the box transformation in case it already has transformations applied
			// we'll restore them to the box and after we create the rep
			
			// store the layer.graphics transformation
			//// // Consol.Trace(content.scaleY + " : " + content.transform.matrix);
			//var scaleY = content.scaleY; // no idea why the below lines work and this doesn't.
			var mat:Matrix = content.transform.matrix.clone();
			content.rotation = 0;
			//var scaleX = content.scaleX==0?content.transform.matrix.a:content.scaleX;
			//var scaleY = content.scaleY==0?content.transform.matrix.d:content.scaleY;
			var scaleX = content.scaleX==0?1:content.scaleX;
			var scaleY = content.scaleY==0?1:content.scaleY;
			content.transform.matrix = new Matrix();
			content.scaleX = 1;
			content.scaleY = 1; // no idea why I have to do this!

			// create the box based on the un-transformed layer.graphics
			box = new TransformSprite();
			boxSprite.addChild(box);
			box.graphics.beginFill(0x000000, 1);
			box.graphics.drawRect(0, 0, content.width, content.height);
			box.graphics.endFill();
			
			createControls();
			
			// apply the transformations back onto the layer.graphics AND box
			content.transform.matrix = mat.clone(); // for some reason this isn't working... it's not assigning the scaleY(d) matrix prop. it always comes back as 0
			content.scaleX = scaleX;
			content.scaleY = scaleY;
			box.transform.matrix = content.transform.matrix.clone(); // layer.transform.matrix;
			box.scaleX = scaleX;
			box.scaleY = scaleY; // no idea
			//// // Consol.Trace(content.scaleY + " : " + content.transform.matrix);
		}
		
		protected override function registerController ():void
		{
			controller = new TransformBoxController(this);
			enableControls();
		}
		
		protected function createControls ():void
		{
			// control nodes - starting at top left.
			createControlPoint(new Point(0,0));
			createControlPoint(new Point(box.width/2,0)); // side
			createControlPoint(new Point(box.width,0));
			createControlPoint(new Point(box.width,box.height/2)); // side
			createControlPoint(new Point(box.width,box.height));
			createControlPoint(new Point(box.width/2,box.height)); // side
			createControlPoint(new Point(0,box.height));
			createControlPoint(new Point(0,box.height/2)); // side
			
			// registration pt node
			createControlPoint(new Point(box.width/2, box.height/2), "regNode");
			
			// these don't get registered with the controller.
			// they're updated when we change the registration point
			// side points - controlled by reg pt
			regObjs.push(createControlPoint(new Point(box.width/2,0), "topReg"));
			regObjs.push(createControlPoint(new Point(box.width,box.height/2), "rightReg"));
			regObjs.push(createControlPoint(new Point(box.width/2,box.height), "bottomReg"));
			regObjs.push(createControlPoint(new Point(0,box.height/2), "leftReg"));
			//regObjs.push(createControlPoint(new Point(box.width/2, box.height/2), "centerReg"));
			for (var i:int=0; i<regObjs.length; i++) regObjs[i].child2.visible = false;
			
			// actual center
			_actualCenter = createControlPoint(new Point(box.width/2, box.height/2), "actualCenter");
			//_actualCenter.child2.scaleX=.5;
			_actualCenter.child2.visible = false;
		}
		
		private function createControlPoint (pt:Point, name:String=null):SyncDisplay
		{
			var newNode:ControlNodeAsset2;
			
			newNode = new ControlNodeAsset2();
			//newNode.gotoAndStop(1);
			newNode.scaleX = newNode.scaleY = 1.5;
			controlSprite.addChild(newNode);
			if (name != null) newNode.name = name;
		
			var syncDisplay:SyncDisplay = new SyncDisplay(box, pt, controlSprite, newNode)

			controlObjs.push(syncDisplay);
			
			return syncDisplay;
		}
		
		
		// UPDATE/MODIFY VIEW ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public override function update (update:Update=null):void
		{
			// this method gets overwritten in group view and line view... though not exactly sure how yet...
			// in line, so we update the edge views (sub views)
			
			updateBoxView()
		}
		
		protected function updateBoxView (includeReg:Boolean=true):void
		{
			if (includeReg && visible) updateRegCenter(true);
			
			_actualCenter.updateSync(true);
			
			for (var i:int=0; i<9; i++) // all sides, corners. NOT center reg. that is above
			{
				if (visible) controlObjs[i].updateSync(true);
				controlObjs[i].child2.visible = visible;
			}
			
			if (visible) drawBox();
		}
		
		public function updateRegCenter (fromBox:Boolean=true):void
		{
			//if (fromBox) regCenter.child2Pos = regCenter.child2Pos;
			//var pt:Point = regCenter.child2.parent.localToGlobal(regCenter.child2Pos);
			//if (box.hitTestPoint(pt.x, pt.y, true)) regCenter.updateSync(fromBox);
			regCenter.updateSync(fromBox);
			
			box.setRegistrationPoint(regCenter.child1Pos);
			
			topReg.child1X = regCenter.child1X;
			//topReg.child1X = actualCenter.child1X;
			
			rightReg.child1Y = regCenter.child1Y;
			//rightReg.child1Y = actualCenter.child1Y;
			
			bottomReg.child1X = regCenter.child1X;
			//bottomReg.child1X = actualCenter.child1X;
			
			leftReg.child1Y = regCenter.child1Y;
			//leftReg.child1Y = actualCenter.child1Y;
		}
		
		protected function enableControls ():void
		{
			for (var i:int=0; i<9; i++) // all sides, corners and center(reg)
			{
				TransformBoxController(controller).registerNode(controlObjs[i].child2);
			}
			TransformBoxController(controller).registerNode(box);
		}
		
		protected function drawBox ():void
		{
			if (content != null) if (wireframeSprite == content.parent) wireframeSprite.graphics.clear(); // clear the box border if draw target is somewhere else (and presumably managed independantly)
			wireframeSprite.graphics.lineStyle(1, 0xFFFFFF, 1, false, "none");
			var pts:Array = [SyncPoint.localToLocal(topLeft.child2Pos, controlSprite, wireframeSprite),
    						 SyncPoint.localToLocal(topRight.child2Pos, controlSprite, wireframeSprite),
							 SyncPoint.localToLocal(bottomRight.child2Pos, controlSprite, wireframeSprite),
							 SyncPoint.localToLocal(bottomLeft.child2Pos, controlSprite, wireframeSprite)]
			wireframeSprite.graphics.moveTo(pts[0].x, pts[0].y);
			wireframeSprite.graphics.lineTo(pts[1].x, pts[1].y);
			wireframeSprite.graphics.lineTo(pts[2].x, pts[2].y);
			wireframeSprite.graphics.lineTo(pts[3].x, pts[3].y);
			wireframeSprite.graphics.lineTo(pts[0].x, pts[0].y);
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		
		// TBD / DEBUG //////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		
		// LEGACY ///////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////

		
	}
	
}