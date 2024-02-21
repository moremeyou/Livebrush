package com.livebrush.transform
{

	import flash.geom.Point;
	import flash.display.DisplayObjectContainer;
	
	public class SyncPoint
	{
		
		private var _doc1									:DisplayObjectContainer;
		private var _doc2									:DisplayObjectContainer;
		private var _doc1Pt									:Point;
		private var _doc2Pt									:Point;
		
		
		public function SyncPoint (doc1:DisplayObjectContainer, doc2:DisplayObjectContainer, doc1Pt:Point=null, doc2Pt:Point=null):void
		{
			_doc1 = doc1;
			_doc2 = doc2;
			
			_doc1Pt = doc1Pt!=null ? doc1Pt : new Point();
			// shouldn't be passing a second point - because it will be created from the first...
			// will need to update all the other clases that use this class...
	
			//_doc2Pt = doc2Pt!=null ? doc2Pt : new Point();

			this.doc1Pt = doc1Pt;
			
			//update(doc2Pt!=null);
			
			// this is bad... hopefully we can just do this normally when all the other tools are fixed
			//if (doc2Pt == null) this.doc1Pt = doc1Pt;
			
			//init();
		}
		
		public function set doc1 (doc:DisplayObjectContainer) {   _doc1=doc; update(false);   }
		public function set doc2 (doc:DisplayObjectContainer) {   _doc2=doc; update(true);   }
		public function get doc1 ():DisplayObjectContainer {   return _doc1;   }
		public function get doc2 ():DisplayObjectContainer {   return _doc2;   }
		
		public function set doc1Pt (pt:Point):void {   _doc1Pt=pt; update(true);   }
		public function set doc2Pt (pt:Point):void {   _doc2Pt=pt; update(false);   }
		public function get doc1Pt ():Point {   return _doc1Pt;   }
		public function get doc2Pt ():Point {   return _doc2Pt;   }
		
		// I'm changing the pt in doc1 scope
		public function set x1 (n:Number):void {   _doc1Pt.x=n; update(true);   }
		public function set y1 (n:Number):void {   _doc1Pt.y=n; update(true);   }
		// I want the position within doc1
		public function get x1 ():Number {   return _doc1Pt.x;   }
		public function get y1 ():Number {   return _doc1Pt.y;   }
		
		// I'm changing the pt in doc2 scope
		public function set x2 (n:Number):void {   _doc2Pt.x=n; update(false);   }
		public function set y2 (n:Number):void {   _doc2Pt.y=n; update(false);   }
		// I want the position within doc2
		public function get x2 ():Number {   return _doc2Pt.x;   }
		public function get y2 ():Number {   return _doc2Pt.y;   }
		
		
		private function init():void { }

		public function update (fromDoc1:Boolean):void
		{
			// set one of my points to exactly the same position as the other - regardless of scope. IOW, visually where we see it on-screen
			
			if (fromDoc1) _doc2Pt = _localToLocal(_doc1Pt, _doc1, _doc2);
			else _doc1Pt = _localToLocal(_doc2Pt, _doc2, _doc1);
		}
		
		public static function objToPoint (obj:Object):Point
		{
			return new Point(obj.x, obj.y);
		}
		
		public static function localToLocal (pt:Point, fromScope:DisplayObjectContainer, toScope:DisplayObjectContainer):Point
		{
			return _localToLocal(pt, fromScope, toScope);
		}
		
		private static function _localToLocal (pt:Point, fromScope:DisplayObjectContainer, toScope:DisplayObjectContainer):Point
		{
			if (fromScope.stage == null || toScope.stage == null) 
			{
				throw new Error ("SyncPoint display objects containers need to be on the display list. (fromScope.stage=" + fromScope.stage + ", toScope.stage=" + toScope.stage + ")");
			}
			else
			{
				pt = fromScope.localToGlobal(pt);
				pt = toScope.globalToLocal(pt);
			}
			
			return pt;
		}
		
	}
	
}