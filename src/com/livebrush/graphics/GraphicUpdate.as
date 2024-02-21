package com.livebrush.graphics
{

	import com.livebrush.events.UpdateEvent;
	import com.livebrush.utils.Update;
	
	// This object is used to specify the type of change that has ALREADY occured in a model.
	// The model pushes this object to each view, where each decides if it should respond
	// The types are specified in the Update class
	
	// On the other hand, if we want to tell something to update as a RESULT of new informaton,
	// (If we want to instruct another models or NON-VIEW object to update), we dispatch an event
	// Then it's up to the other models or objects to have registered for these events
	// There are exceptions, such as when the ToolMan calls update methods directly on an individual tools
	public class GraphicUpdate extends Update
	{
		
		public function GraphicUpdate (type:String, data:Object=null, delay:Boolean=true):void
		{
			super(type, data, delay);
		}
		
		public static function lineUpdate (data:Object=null, delay:Boolean=true):GraphicUpdate
		{
			return new GraphicUpdate(UpdateEvent.LINE, data);
		}
		
		public static function layerUpdate (data:Object=null, delay:Boolean=true):GraphicUpdate
		{
			// For example: when we select a layer, the ToolMan 
			return new GraphicUpdate(UpdateEvent.LAYER, data, delay);
		}
		
		public static function canvasUpdate (data:Object=null, delay:Boolean=true):GraphicUpdate
		{
			return new GraphicUpdate(UpdateEvent.CANVAS, data, delay);
		}
		
		
		public static function toolUpdate (data:Object=null, delay:Boolean=true):GraphicUpdate
		{
			// A tool update happens when the change in the model only affects tools
			// Ex: when we transform an line, we don't immediatly update the graphic line.
			// Instead we update the wireframe view. The wireframe view will only respond if the TOOL or LAYER was updated
			return new GraphicUpdate(UpdateEvent.TOOL, data, delay);
		}

	}
	
	
}