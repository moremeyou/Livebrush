package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.EventPhase;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	import flash.geom.Point;
	
	import com.livebrush.data.Settings;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.DialogView;
	
	
	
	public class Dialog extends UIModel
	{
		
		public static var NOTICE				:String = "notice";
		public static var LOADING				:String = "loading";
		public static var QUESTION				:String = "question";
		public static var DELAY					:String = "delay";
		public static var PROCESS				:String = "process";
		
		public var ui							:UI;
		public var dialogView					:DialogView;
		public var type							:String;
		public var data							:Object;
		public var yesFunction					:Function;
		public var noFunction					:Function;
		public var id							:String = "";
		public var thisScope					:Object;
		
		
		public function Dialog (type:String, data:Object=null):void // Settings=null
		{
			super()
			
			this.ui = UI.MAIN_UI;
			this.type = type;
			this.data = data;
			this.yesFunction = data.yesFunction;
			this.noFunction = data.noFunction;
			id = data.id!=null ? data.id : "";
			thisScope = data.thisScope!=null ? data.thisScope : this;
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		
		// SETUP ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			
			dialogView = DialogView(registerView(new DialogView(this)));
			
		}
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		
		// PUBLIC ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function close ():void
		{
			ui.closeDialog(this);
			//dialogView.die();
			//try {   delete this;   } catch (e:Error) {}
		}
		
		public function yesAction ():void
		{
			//// // Consol.Trace("Dialog - yes action");
			//try{   yesFunction();   } catch(e:Error){}
			close();
			try
			{   
				if (data.yesProps != null)
				{
					//yesFunction.call(thisScope, data.yesProps);
					yesFunction.apply(thisScope, data.yesProps);   
				}
				else
				{
					yesFunction();
				}
			} 
			catch(e:Error)
			{
				// // Consol.Trace(e)
			}
			//close();
		}
		
		public function noAction ():void
		{
			//try{   noFunction();   } catch(e:Error){}
			close();
			try
			{   
				if (data.noProps != null)
				{
					//noFunction.call(thisScope, data.noProps);  
					noFunction.apply(thisScope, data.noProps);   
				}
				else
				{
					noFunction();
				}
			} 
			catch(e:Error)
			{
				// // Consol.Trace(e)
			}
			//close();
		}
		
		
		// DEBUG ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

	}
	
	
}