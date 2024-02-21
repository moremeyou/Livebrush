package com.livebrush.utils
{
	//import flash.events.Event;
	//import flash.events.MouseEvent;
	import com.livebrush.events.UpdateEvent;
	
	// This object is used to specify the type of change that has occured in a model.
	// The model pushes this object to each view, where each decides if it should respond
	// The types are specified in the Update class
	// If we want to instruct another models or NON-VIEW object to update, we dispatch an event
	// Then it's up to the other models or objects to have registered for these events
	// There are exceptions, such as when the ToolMan calls update methods directly on an individual tools
	
	public class Update
	{
		
		//public var source							:Object; // source will be in the data object if its needed
		public var type								:String;
		public var data								:Object;
		public var delay							:Boolean;
	
		public function Update (type:String, data:Object=null, delay:Boolean=true):void
		{
			//this.source = source;
			this.type = type;
			this.data = data;
			this.delay = delay;
		}
		
		public function generateEvent ():UpdateEvent // data:Object=null -- update.data prop is already in this object
		{
			return new UpdateEvent(type, false, false, data, delay);												  
		}
		
		public static function drawModeUpdate (data:Object=null, delay:Boolean=false):Update
		{
			return new Update(UpdateEvent.DRAW_MODE, data, delay);
		}
		
		public static function projectUpdate (data:Object=null, delay:Boolean=false):Update
		{
			return new Update(UpdateEvent.PROJECT, data, delay);
		}
		
		public static function layerUpdate (data:Object=null, delay:Boolean=false):Update
		{
			return new Update(UpdateEvent.LAYER, data, delay);
		}
		
		public static function brushStyleUpdate (data:Object=null, delay:Boolean=false):Update
		{
			return new Update(UpdateEvent.BRUSH_STYLE, data, delay);
		}
		
		public static function colorUpdate (data:Object=null, delay:Boolean=false):Update
		{
			return new Update(UpdateEvent.COLOR, data, delay);
		}
		
		public static function transformUpdate (data:Object=null, delay:Boolean=false):Update
		{
			return new Update(UpdateEvent.TRANSFORM, data, delay);
		}
		
		public static function loadingUpdate (data:Object=null, delay:Boolean=false):Update
		{
			return new Update(UpdateEvent.LOADING, data, delay);
		}
		
		public static function dataUpdate (data:Object=null, delay:Boolean=false):Update
		{
			return new Update(UpdateEvent.DATA, data, delay);
		}
		
		public static function uiUpdate (data:Object=null, delay:Boolean=false):Update
		{
			return new Update(UpdateEvent.UI, data, delay);
		}
		
		public static function windowUpdate (data:Object=null, delay:Boolean=false):Update
		{
			return new Update(UpdateEvent.WINDOW, data, delay);
		}
		
		public static function groupUpdate (data:Object=null, delay:Boolean=true):Update
		{
			return new Update(UpdateEvent.GROUP, data, delay);
		}
		
		public static function selectionUpdate (data:Object=null, delay:Boolean=true):Update
		{
			return new Update(UpdateEvent.SELECTION, data, delay);
		}
		
		public static function beginUpdate (data:Object=null, delay:Boolean=false):Update
		{
			return new Update(UpdateEvent.BEGIN, data, delay);
		}
		
		public static function finishUpdate (data:Object=null, delay:Boolean=false):Update
		{
			return new Update(UpdateEvent.FINISH, data, delay);
		}
		
	}
	
	
}