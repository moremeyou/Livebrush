package com.livebrush.tools
{

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.EventPhase;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.styles.Style;
	import com.livebrush.ui.Consol;
	import com.livebrush.tools.LiveBrush;
	import com.livebrush.graphics.Line;
	import com.livebrush.data.Settings;
	import com.livebrush.data.StateManager;
	
	public class BrushGroup
	{
		
		
		public var brushes							:Array;

		
		
		public function BrushGroup ()
		{
			brushes = [];
		}
		
		public function get lastBrush ():LiveBrush {   return brushes[brushes.length-1];   }
		
		public function merge (brushGroup:BrushGroup):void
		{
			brushes = brushes.concat(brushGroup.brushes);
		}
		
		public function addBrush (type:String, style:Style, layer:LineLayer):LiveBrush
		{
			var newBrush:LiveBrush;
			
			newBrush = new LiveBrush (style, layer, layer.canvas.mousePt);
			
			//StateManager.openState();
			
			
			brushes.push(newBrush);
			
			return newBrush;
		}
		
		public function removeBrush (id:int):void
		{
			var index:int = Settings.idToIndex(id.toString(), brushes, "id");
			
			//brushes[index].
			
			brushes[index].die();
			delete brushes[index];
			brushes.splice(index, 1);
			
		}
		
		
		
	}
}