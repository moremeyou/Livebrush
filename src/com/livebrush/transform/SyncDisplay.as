package com.livebrush.transform
{

	import flash.events.Event;
	import flash.geom.Point;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	
	import com.livebrush.ui.Consol;
	
	public class SyncDisplay extends SyncPoint
	{
		
		public var child1												:Object;
		public var child2												:Object;
		
		public function SyncDisplay (parent1:DisplayObjectContainer, child1:Object, parent2:DisplayObjectContainer, child2:Object):void
		{
			super(parent1, parent2, new Point(child1.x, child1.y));
			
			this.child1 = child1;
			this.child2 = child2;
			
			updateDisplay(true); // this actually moves the objects on screen
			//child1Pos = childPos(child1); // also initializes the _docPt props of super
			
			registerListener(child1);
			registerListener(child2);
		}
		
		public function set parent1 (doc:DisplayObjectContainer) {   doc1=doc; updateDisplay(false);   }
		public function set parent2 (doc:DisplayObjectContainer) {   doc2=doc; updateDisplay(true);   }
		public function get parent1 ():DisplayObjectContainer {   return doc1;   }
		public function get parent2 ():DisplayObjectContainer {   return doc2;   }
		
		public function set child1Pos (pt:Point):void {   doc1Pt=pt; updateDisplay(true);   }
		public function set child2Pos (pt:Point):void {   doc2Pt=pt; updateDisplay(false);   }
		public function get child1Pos ():Point {   return childPos(child1);   }
		public function get child2Pos ():Point {   return childPos(child2);   }
		
		public function set child1X (n:Number):void {   x1=n; updateDisplay(true);   }
		public function set child1Y (n:Number):void {   y1=n; updateDisplay(true);   }
		public function get child1X ():Number {   return x1;   }
		public function get child1Y ():Number {   return y1;   }
		
		public function set child2X (n:Number):void {   x2=n; updateDisplay(false);   }
		public function set child2Y (n:Number):void {   y2=n; updateDisplay(false);   }
		public function get child2X ():Number {   return x2;   }
		public function get child2Y ():Number {   return y2;   }
		
		public function die ():void
		{
			unregister();
		}
		
		public function updateSync (fromChild1:Boolean):void
		{
			if (fromChild1)
			{
				child1Pos = child1Pos;
			}
			else
			{
				child2Pos = child2Pos;
			}
		}
		
		public function unregister ():void
		{
			unregisterListener(child1);
			unregisterListener(child2);
		}
		
		
		
		private function registerListener (child:Object):void
		{
			if (child is DisplayObject)
			{
				child.addEventListener(Event.ADDED, addedHandler);
				child.addEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
			}
		}

		private function addedHandler (e:Event):void
		{
			if (e.target == child1) parent1 = e.target.parent;
			else if (e.target == child2) parent2 = e.target.parent;
		}
		
		private function removedHandler (e:Event):void
		{
			unregisterListener(child1);
			unregisterListener(child2);
			
			throw new Error ("SyncDisplay child removed from display list. This SyncDisplay will no longer function.");
		}
		
		private function unregisterListener (child:Object):void
		{
			if (child is DisplayObject)
			{
				child.removeEventListener(Event.ADDED, addedHandler);
				child.removeEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
			}
		}
		
		private function childPos (child:Object):Point
		{
			var pt:Point = null;
			if (child is Point) pt = Point(child);
			else if (child is DisplayObject) pt = new Point(child.x, child.y);
			else throw new Error ("SyncScope child is neither Point nor DisplayObject.");
			
			return pt;
		}
		
		private function updateDisplay(fromChild1:Boolean):void
		{
			if (fromChild1) 
			{ 
				child1.x = doc1Pt.x; 
				child1.y = doc1Pt.y;
				child2.x = doc2Pt.x; 
				child2.y = doc2Pt.y;
			}
			else
			{
				child2.x = doc2Pt.x; 
				child2.y = doc2Pt.y;
				child1.x = doc1Pt.x; 
				child1.y = doc1Pt.y;
			}
		}
		
	}
	
}