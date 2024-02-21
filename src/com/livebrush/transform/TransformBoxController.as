package com.livebrush.transform
{
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.tools.Tool;
	import com.livebrush.tools.TransformTool;
	import com.livebrush.transform.LayerBoxView;
	import com.livebrush.transform.SyncPoint;
	import com.livebrush.ui.Consol;
	import com.livebrush.utils.Controller;
	
	public class TransformBoxController extends Controller
	{
		public static const NONE										:String = "none";
		public static const MOVE										:String = "move";
		public static const ROTATE										:String = "rotate";
		public static const SCALE										:String = "scale";
		public static const SKEW										:String = "skew";
		public static const MOVE_CENTER									:String = "moveCenter";
		
		private var action												:String;
		private var iAngleRads											:Number;
		private var iScale												:Point;
		private var iSkew												:Point;
		private var iSize												:Point;
		private var activeNode											:ControlNodeAsset2;
		private var controlNodes										:Array;
		private var scalePoints											:Object;
		private var skewPoints											:Object;
		private var controlNode											:ControlNodeAsset2;
		private var mouseEvent											:MouseEvent;
		private var iNeg												:Object;
		private var iSlope												:Number;
		private var scaleFactor											:Number;
		
		public function TransformBoxController (view:TransformBoxView):void
		{
			super(view);
			iNeg = {};
			controlNodes = [];
			iSize = new Point();
			iScale = new Point();
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get boxView ():TransformBoxView {   return TransformBoxView(view);   }
		public function get tool ():TransformTool {   return TransformTool(boxView.tool);   }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void { }
		
		public override function die ():void
		{
			if (controlNodes.length > 0)
			{
				var tempNodes:Array = controlNodes.slice();
				for (var i:int=0; i<tempNodes.length; i++)
				{
					unregisterNode(tempNodes[i]);
				}
				tempNodes = [];
				controlNodes = [];
			}
		}
		
		public function registerNode (controlNode:DisplayObjectContainer):void
		{
			controlNode.addEventListener(MouseEvent.MOUSE_DOWN, controlNodeEventHandler)
			controlNodes.push(controlNode);
		}
		
		public function unregisterNode (controlNode:DisplayObjectContainer):void
		{
			controlNode.removeEventListener(MouseEvent.MOUSE_DOWN, controlNodeEventHandler);
			controlNodes.splice(controlNodes.indexOf(controlNode),1);
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function updateModel ():void
		{
			//tool["transformLayer"](view);
		}
		
		protected function removeMoveLoop ():void
		{
			boxView.box.stage.removeEventListener (MouseEvent.MOUSE_UP, controlNodeEventHandler);
			boxView.box.stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
		}
		
		protected function initMoveLoop ():void
		{
			// begin a loop update the view (and other shit, if different kind of transforming)
			//Canvas.STAGE.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			boxView.box.stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			
			// listen for global mouse up to kill drag
			//Canvas.STAGE.addEventListener (MouseEvent.MOUSE_UP, controlNodesEventHandler);
			boxView.box.stage.addEventListener (MouseEvent.MOUSE_UP, controlNodeEventHandler);
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected function controlNodeEventHandler (e:MouseEvent):void
		{
			mouseEvent = e;
			try {
			if (e.type == MouseEvent.MOUSE_DOWN)
			{
				// this for now. it stops any other events from firing on this mouse event
				e.stopImmediatePropagation()
				
				tool.begin();

				if (e.target.name == "regNode") // determine if reg controlNodes. for final: use if e.target == RegNodeAsset. NOT the name as now
				{
					//Consol.globalOutput("Move Registration");
					
					//e.target.startDrag();
					boxView.regNode.startDrag();
					action = MOVE_CENTER;
				}
				//if (e.target is ControlNodeAsset2 && e.ctrlKey) // Rotate
				else if ((e.target is ControlNodeAsset2 && e.ctrlKey) || (e.target is ControlNodeAsset2 && !tool.scaleAllowed))
				{
					//Consol.globalOutput("Rotate");
					
					iAngleRads = rotAngle(boxView.box.rotation * Math.PI / 180);
					action = ROTATE;
				}
				else if (e.target is ControlNodeAsset2) // Scale
				{
					var controlPt:Point = new Point(boxView.controlSprite.mouseX, boxView.controlSprite.mouseY);
					activeNode = ControlNodeAsset2(e.target);
					
					// skew
					/*if (mouseEvent.shiftKey && (activeNode == boxView.topCenter.child2 || activeNode == boxView.bottomCenter.child2 || activeNode == boxView.leftCenter.child2 || activeNode == boxView.rightCenter.child2))
					{
						//// // Consol.Trace(activeNode);
						//trace(activeNode)
						
						iSkew = new Point(boxView.box.transform.matrix.c, boxView.box.transform.matrix.b);
						
						skewPoints = getSkewPoints(activeNode);
						//skewPoints = getSkewPoints();
						//trace(skewPoints.pt1)
						iSize.x = Point.distance(controlPt, skewPoints.pt1.child2Pos);
						iSize.y = Point.distance(controlPt, skewPoints.pt2.child2Pos);
						
						action = SKEW;
					}
					else
					{*/
					
					// scale
					iScale = new Point(boxView.box.scaleX, boxView.box.scaleY);
					
					if (!mouseEvent.shiftKey && !tool.constrain) scalePoints = getScalePoints(activeNode);
					else scalePoints = getScalePoints();
					
					iSize.x = Point.distance(controlPt, scalePoints.width.child2Pos);
					iSize.y = Point.distance(controlPt, scalePoints.height.child2Pos);
					
					var neg:Number = (boxView.box.mouseX - boxView.regCenter.child1X);
					iNeg.x = (neg == Math.abs(neg) ? 1 : -1);
					//iNeg.x = neg;
					neg = (boxView.box.mouseY - boxView.regCenter.child1Y);
					iNeg.y = (neg == Math.abs(neg) ? 1 : -1);
					//iNeg.y = neg;
					
					//iSlope = iNeg.y/iNeg.x;
					
					//scaleFactor = (iSlope == Math.abs(iSlope) ? 1 : -1);
					
					action = SCALE;
					
					//}

				}
				else if (boxView.box.hitTestPoint(e.stageX, e.stageY, true)) // determine if clicked inside box 
				{
					//Consol.globalOutput("LayerBox clicked");
					
					action = MOVE;
					boxView.box.startDrag();
				}
				
				initMoveLoop();
			}
			else if (e.type == MouseEvent.MOUSE_UP)
			{
				removeMoveLoop();
				boxView.box.stopDrag();
				boxView.regNode.stopDrag();
				action = NONE;
				tool.finish();
			}
			} catch (e:Error) {}
		}
		
		protected function moveHandler (e:Event):void
		{
			var controlPt:Point = new Point(boxView.controlSprite.mouseX, boxView.controlSprite.mouseY);
			var size:Point = new Point();
			var pt:Point;
			
			try {
				if (action == MOVE)
				{
					//boxView.updateBoxView(true);
				}
				else if (action == SCALE)
				{
					/*Canvas.DEBUG.graphics.clear();
					Canvas.DEBUG.graphics.lineStyle(1, 0xFF0000, 1);
					Canvas.DEBUG.graphics.moveTo(controlPt.x, controlPt.y);
					Canvas.DEBUG.graphics.lineTo(scalePoints.width.child2X, scalePoints.width.child2Y);
					Canvas.DEBUG.graphics.moveTo(controlPt.x, controlPt.y);
					Canvas.DEBUG.graphics.lineTo(scalePoints.height.child2X, scalePoints.height.child2Y);*/
					
					pt = boxView.regNode.parent.localToGlobal(boxView.regCenter.child2Pos);
					if (!boxView.box.hitTestPoint(pt.x, pt.y, true))
					{
						if (!mouseEvent.shiftKey) scalePoints = getScalePoints(activeNode);
						else scalePoints = getScalePoints();
					}
					
					size.x = Point.distance(controlPt, scalePoints.width.child2Pos);
					size.y = Point.distance(controlPt, scalePoints.height.child2Pos);
					
					var pt1 = controlPt.x - scalePoints.width.child2X;
					var pt2 = size.x
					
					var neg:Object = {};
					neg.x = boxView.box.mouseX - boxView.regCenter.child1X;
					neg.y = boxView.box.mouseY - boxView.regCenter.child1Y;
					//neg.x = activeNode.x - boxView.regCenter.child1X;
					//neg.y = activeNode.y - boxView.regCenter.child1Y;
					
					var flipped:Boolean = ((neg.x*iNeg.x != Math.abs(neg.x)) || (neg.y*iNeg.y != Math.abs(neg.y)));
					var num:Number = (neg.x*iNeg.x);
					
					num = (neg.y*iNeg.y);
					
					var scale:Number;
					if ((!isHeightNode() && !flipped) || (!isCornerNode() && !isHeightNode()))
					{
						scale = iScale.x * (size.x/iSize.x);
						boxView.box.scaleX2 = scale;
					}
					if ((!isWidthNode() && !flipped) || (!isCornerNode() && !isWidthNode()))
					{
						scale = iScale.y * (size.y/iSize.y);
						boxView.box.scaleY2 = scale;
					}
				
				}
				else if (action == SKEW)
				{
					/*Canvas.DEBUG.graphics.clear();
					Canvas.DEBUG.graphics.lineStyle(1, 0xFF0000, 1);
					Canvas.DEBUG.graphics.moveTo(controlPt.x, controlPt.y);
					Canvas.DEBUG.graphics.lineTo(scalePoints.width.child2X, scalePoints.width.child2Y);
					Canvas.DEBUG.graphics.moveTo(controlPt.x, controlPt.y);
					Canvas.DEBUG.graphics.lineTo(scalePoints.height.child2X, scalePoints.height.child2Y);*/
					
					//pt = boxView.regNode.parent.localToGlobal(boxView.regCenter.child2Pos);
					//if (!boxView.box.hitTestPoint(pt.x, pt.y, true)) skewPoints = getSkewPoints(activeNode);
					
					////size.x = Point.distance(controlPt, skewPoints.pt1.child2Pos);
					//size.x = Point.distance(controlPt, new Point(activeNode.x, activeNode.y));
					////size.y = Point.distance(controlPt, skewPoints.pt2.child2Pos);
					
					//if (activeNode != boxView.topCenter.child2 && activeNode != boxView.bottomCenter.child2) 
					////boxView.box.skewX = (size.x/iSize.x); // iSkew.x * 
					//// // Consol.Trace(iSkew.x);
					//if (activeNode != boxView.leftCenter.child2 && activeNode != boxView.rightCenter.child2) 
					//boxView.box.skewY = iSkew.y * (size.y/iSize.y); 
				
				}
				else if (action == ROTATE)
				{
					var angleRads:Number = rotAngle(iAngleRads);
					boxView.box.rotation2 = (angleRads * 180 / Math.PI);
				}
				else if (action == MOVE_CENTER)
				{
					boxView.updateRegCenter(false);
				}
				
				updateModel();
				
			} catch(e:Error){}
			
			
			
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function getSkewPoints (controlNode:ControlNodeAsset2=null):Object
		{
			var skewPoints:Object = {};
			
			switch (controlNode)
			{
				/*case boxView.topCenter.child2 : skewPoints = {pt1:boxView.topLeft, pt2:boxView.topRight}; break;
				
				case boxView.bottomCenter.child2 : skewPoints = {pt1:boxView.bottomLeft, pt2:boxView.bottomRight}; break;
				
				case boxView.leftCenter.child2 : skewPoints = {pt1:boxView.topLeft, pt2:boxView.bottomLeft}; break;
				
				case boxView.rightCenter.child2 : skewPoints = {pt1:boxView.topRight, pt2:boxView.bottomRight}; break;*/
				
				default : skewPoints = {pt1:boxView.actualCenter, pt2:boxView.actualCenter}; break;
			}
				
			return skewPoints;
		}
		
		private function getScalePoints (controlNode:ControlNodeAsset2=null):Object
		{
			var scalePoints:Object = {};
			
			//scalePoints = {width:boxView.actualCenter, height:boxView.actualCenter};
			
			switch (controlNode)
			{
				case boxView.bottomRight.child2 : scalePoints = {width:boxView.bottomReg, height:boxView.rightReg}; break;
				
				case boxView.bottomLeft.child2 : scalePoints = {width:boxView.bottomReg, height:boxView.leftReg}; break;
				
				case boxView.topLeft.child2 : scalePoints = {width:boxView.topReg, height:boxView.leftReg}; break;
				
				case boxView.topRight.child2 : scalePoints = {width:boxView.topReg, height:boxView.rightReg}; break;
				
				
				case boxView.topCenter.child2 : scalePoints = {width:boxView.topCenter, height:boxView.regCenter}; break;
				
				case boxView.bottomCenter.child2 : scalePoints = {width:boxView.bottomCenter, height:boxView.regCenter}; break;
				
				case boxView.leftCenter.child2 : scalePoints = {width:boxView.regCenter, height:boxView.leftCenter}; break;
				
				case boxView.rightCenter.child2 : scalePoints = {width:boxView.regCenter, height:boxView.rightCenter}; break;
				
				/*case boxView.topCenter.child2 : scalePoints = {width:boxView.topCenter, height:boxView.actualCenter}; break;
				
				case boxView.bottomCenter.child2 : scalePoints = {width:boxView.bottomCenter, height:boxView.actualCenter}; break;
				
				case boxView.leftCenter.child2 : scalePoints = {width:boxView.actualCenter, height:boxView.leftCenter}; break;
				
				case boxView.rightCenter.child2 : scalePoints = {width:boxView.actualCenter, height:boxView.rightCenter}; break;*/
				
				
				/*case boxView.topCenter.child2 : scalePoints = {width:boxView.actualCenter, height:boxView.actualCenter}; break;
				
				case boxView.bottomCenter.child2 : scalePoints = {width:boxView.actualCenter, height:boxView.actualCenter}; break;
				
				case boxView.leftCenter.child2 : scalePoints = {width:boxView.actualCenter, height:boxView.actualCenter}; break;
				
				case boxView.rightCenter.child2 : scalePoints = {width:boxView.actualCenter, height:boxView.actualCenter}; break;*/
				
				//default : scalePoints = {width:boxView.actualCenter, height:boxView.actualCenter}; break;
				default : scalePoints = {width:boxView.regCenter, height:boxView.regCenter}; break;
			}
				
			return scalePoints;
		}
		
		private function getControlNode (controlNode:ControlNodeAsset2):ControlNodeAsset2
		{
			switch (controlNode)
			{
				case boxView.topCenter.child2 : controlNode = ControlNodeAsset2(boxView.topReg.child2); break;
				
				case boxView.bottomCenter.child2 : controlNode = ControlNodeAsset2(boxView.bottomReg.child2); break;
				
				case boxView.leftCenter.child2 : controlNode = ControlNodeAsset2(boxView.leftReg.child2); break;
				
				case boxView.rightCenter.child2 : controlNode = ControlNodeAsset2(boxView.rightReg.child2); break;
			}
				
			return controlNode;
		}

		private function rotAngle (offset:Number=0):Number
		{
			 return Math.atan2(boxView.controlSprite.mouseY-boxView.regCenter.child2Y, boxView.controlSprite.mouseX-boxView.regCenter.child2X) - offset;
		}
		
		private function isCornerNode ():Boolean
		{
			return (activeNode != boxView.topCenter.child2 && activeNode != boxView.bottomCenter.child2 && activeNode != boxView.leftCenter.child2 && activeNode != boxView.rightCenter.child2);
		}
		
		private function isHeightNode ():Boolean
		{
			return (activeNode == boxView.topCenter.child2 || activeNode == boxView.bottomCenter.child2);
		}
		
		private function isWidthNode ():Boolean
		{
			return (activeNode == boxView.leftCenter.child2 || activeNode == boxView.rightCenter.child2);
		}
		

	}
	
}