package com.livebrush.utils
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import com.livebrush.ui.Consol;
	
	public class SelectionBox// extends EventDispatcher 
	{
		public var box												:Sprite;
		public var iPos												:Point;
		public var rect												:Rectangle;
		private var doc												:DisplayObjectContainer;
		
		public function SelectionBox (doc:DisplayObjectContainer):void
		{
			this.doc = doc;
			
			init();
		}
		
		private function init ():void
		{
			begin();
		}
		
		public function die ():void
		{
			finish();
			clear();
		}
		
		public function begin ():void
		{
			iPos = new Point (doc.mouseX, doc.mouseY);
			box = doc.addChild(new Sprite()) as Sprite;
			
			doc.addEventListener(Event.ENTER_FRAME, update);
			doc.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		public function update (e:Event):void
		{
			rect = new Rectangle(iPos.x, iPos.y, doc.mouseX-iPos.x, doc.mouseY-iPos.y);
			
			drawBox(rect);
			
			rect = box.getBounds(doc);
		}
		
		public function mouseUpHandler (e:Event):void
		{
			
			finish();
		}
		
		public function finish ():void
		{
			//rect = box.getBounds(doc);
			
			doc.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			doc.removeEventListener(Event.ENTER_FRAME, update);
			//clear();
		}
		
		public function containsPoint (pt:Point):Boolean
		{
			//Consol.globalOutput(rect);
			return rect.containsPoint(pt);
		}
		
		public function clear ():void
		{
			box.graphics.clear();
			doc.removeChild(box);
			box = null;
		}
		
		private function drawBox (rect:Rectangle):void
		{
			box.graphics.clear();
			box.graphics.lineStyle(0, 0xFFFFFF, 1);
			box.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
		}
		
	}
	
}