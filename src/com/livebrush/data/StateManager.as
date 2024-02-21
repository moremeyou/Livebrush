package com.livebrush.data
{
	//import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import com.livebrush.data.Settings;
	import com.livebrush.ui.Consol;
	import com.livebrush.data.FileManager
	import com.livebrush.Main;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.graphics.canvas.Layer;
	//import com.livebrush.graphics.canvas.
	import com.livebrush.events.StateEvent;
	
	public class StateManager extends EventDispatcher
	{
		public static const CLOSED						:String = "closeState";
		public static const OPENED						:String = "openState";
		public static const APPLYING					:String = "applyState";
		//public static const LOCKED					:String = "applyState"; // not used
		
		/*public static const ADD_CHILD					:String = "addChild";
		public static const REMOVE_CHILD				:String = "removeChild";
		public static const CHANGE_PROPS				:String = "changeProps";
		public static const APPLY_PROPS					:String = "applyProps";*/
		
		private static var _singleton					:StateManager = null;
		public static var global						:StateManager = null;
		public static var changed						:Boolean = true;
		public static var state							:String = CLOSED;
		
		private var _index								:int = 0; // where we are in the history
		private var _history							:Array = null;
		private var _currentState						:Array = null;
		private var _applying							:Boolean = false;
		private var _main								:Main;
		private var _statePos							:int = 0;
		public var locked								:Boolean = false;
		private var _canMan								:CanvasManager;
		
		
		public function StateManager (main:Main, canMan:CanvasManager):void
		{
			_main = main;
			_canMan = canMan;
			//_main.addEventListener(StateEvent.CHANGE, _changeHandler);
			addEventListener(StateEvent.CHANGE, _main.stateChange);
			StateManager.global = this;
			reset();
		}
		
		public static function getInstance (main:Main, canMan:CanvasManager):StateManager
		{
			var instance:StateManager;
			if (_singleton == null) 
			{
				_singleton = new StateManager(main, canMan);
				instance = _singleton;
			}
			else 
			{
				instance = _singleton;
			}
			
			return instance;
		}
		
		public static function get currentState ():Array
		{
			return global._currentState;
		}
		
		public static function get currentIndex ():int
		{
			return global._index;
		}
		
		public static function reset ():void
		{
			try 
			{
				// // Consol.Trace("StateManager: reset");
				
				changed = true;
				
				global._history = [];
				global._index = 0;
				global._statePos = 0;
				
				state = CLOSED;
				global._currentState = null;
				
			} 
			catch (e:Error)
			{
				// // Consol.Trace("StateManager: reset error");
			}
		}
		
		private function _changeHandler (e:StateEvent):void
		{
			// // Consol.Trace("state change");
		}
		
		public static function openState ():void
		{
			if (global != null && !global._applying && !global.locked)
			{
				// Consol.Trace("-------------------------------");
				// Consol.Trace("Open State");
				
				state = OPENED;
				
				changed = true;
				
				if (global._currentState != null) closeState();
				
				
				global._history.push([]);
				global._currentState = [];
				
				if (global._statePos == 1) global._index++;
				//else global._statePos = 1;
				
				if (global._history.length-1 > global._index) 
				{
					global._history = global._history.slice(0, global._index+1); 
					global._statePos = 0;
				}
				// This was added to limit the undo to 10. f
				else if (global._history.length >= 10)
				{
					var removedState:Array = global._history.shift();
					global._index--;
					
					//// Consol.Trace("StateManager: openState: remove old state. length = " + removedState.length);
					
					// this is where we'll check if the shifted item is a bitmap. if so, fuck it up!
					for (var i:int=0; i<removedState.length; i++) {
						//Settings.traceDynamicObject(removedState[i], "RemovedState");
						//Settings.traceDynamicObject(removedState[i].documentState.data.beginObjectsXML, "RemovedState");
						try { 
						
							if (removedState[i].documentState.data.finishObjectsXML[0].type == "bitmap") {
								removedState[i].documentState.data.beginObjectsXML[0].bitmapData.dispose();
								removedState[i].documentState.data.finishObjectsXML[0].bitmapData.dispose();
							}
							//// Consol.Trace(removedState[i].documentState.data.finishObjectsXML[0].type);
						
						} catch (e:Error) {}
					}
					
				}
				
				//// // Consol.Trace(global._index + " : " + global._history.length)
			}
		}
		
		
		/*public static function addItem (type:String, values:Array, parent:*, props:Array):void
		{
			//if ((global != null && !global._applying) || (global != null && global._history.length==1))
			if (global != null && !global._applying)
			{
				if (global._currentState == null) openState();
				
				//{
					global._currentState.push({type:type, values:values, parent:parent, props:props});
					
				//}
				//else
				//{
					//global._currentState[global._index+1] = {type:type, values:values, parent:parent, props:props};
				//}
				//if (!global._applying) 
				if (global._currentState.length == 1) global._index++;
			}
		}*/
		
		
		public static function addItem (undo:Function, redo:Function, index:int=-1, data:Object=null, layerDepth:int=-1, label:String=""):void
		{
			//if ((global != null && !global._applying) || (global != null && global._history.length==1))
			if (global != null && !global._applying && !global.locked)
			{
				changed = true;
				
				var docState:Object = global.getDocumentState();
				/*if (data==null) 
				{
					docState.data = {layer:layerDepth};
				}
				else
				{
					data.layer = layerDepth;
					docState.data = data;
				}*/
				docState.data = (data==null?{}:data);
				layerDepth = (layerDepth==-1 ? global._canMan.activeLayer.depth : layerDepth); 
				if (index == -1)
				{
					if (global._currentState == null) openState();
					global._currentState.push({undo:undo, redo:redo, documentState:docState, layerDepth:layerDepth});
					// Consol.Trace("State: Add Item to current> " + label);
					//// // Consol.Trace("State: Add Item to current> ");
					//Settings.traceDynamicObject(data);
				}
				else
				{
					//if (global._history[index] == null) openState();
					//// Consol.Trace("StateManager: addItem: index = " + index + ", global._history[index] = " + global._history[index]);
					global._history[index].push({undo:undo, redo:redo, documentState:docState, layerDepth:layerDepth});
					// Consol.Trace("State: Add Item to " + index);
				}
			}
		}
		
		public static function closeState (allowEmptyState:Boolean=false):void
		{
			if (global != null && global._currentState != null && !global._applying && !global.locked)
			{
				state = CLOSED;
				
				changed = true;
				
				// Consol.Trace("Close State");
				if (global._currentState.length == 0 && !allowEmptyState) 
				{
					//Consol("clearing empty state");
					global._history.pop();
					global._statePos = 0;
					//global._index
				}
				else 
				{
					global._history[global._history.length-1] = global._currentState.slice();
					global._statePos = 1;
					//// // Consol.Trace("Removing Empty State. Subtracting from index.");
					//global._history = global._history.slice(0, global._index); 
					//global._index--;
				}
				global._currentState = null;
				//// // Consol.Trace("Current Index: " + global._index + ". History Length: " + global._history.length);
			}
		}
		
		public static function clearState ():void
		{
			global._currentState = [];
			closeState();
		}
		
		public static function lock ():void
		{
			 try 
			 {  
			 	if (!global._applying && !global.locked) 
				{
					// // Consol.Trace("StateManager: Lock"); 
					global.locked = true;  
				}
			} 
			catch (e:Error){};
		}
		
		public static function unlock (caller:Object):void
		{
			try 
			{   
				if (!global._applying && global.locked) 
				{
					// // Consol.Trace("StateManager: Unlock from> " + caller); 
					global.locked = false; 
				}
			} catch (e:Error){};
		}
		
		public static function stepBack ():void
		{
			//// // Consol.Trace(global._statePos); // ALWAYS INCLUDE A REFERENCE TO WHERE THE TRACE IS COMING FROM! IS THERE AN AUTO WAY TO DO THIS?
			if (global._currentState != null) closeState();
			
			if (global._statePos == 1) 
			{
				global._applyState(1);
				global._statePos = 0;
			}
			else
			{
				if (global._index > 0)
				{
					global._index--; // move to the previous state
					global._applyState(1); // 1 because we want to run the UNDO method of the previous state
					global._statePos = 0; // set the pos to 0 because we moved back to another state group by UNDOING
				}
			}
		}
		
		public static function stepForward ():void
		{
			if (global._currentState != null) closeState();
			
			if (global._statePos == 0 && global._history.length>0) 
			{
				try
				{
					global._applyState(0);
					global._statePos = 1;
				}
				catch (e:Error)
				{
					// // Consol.Trace("StateManager: Step forward error -> " + e.toString()); 
					global._statePos = 0;
					global._applying = false;
				}
			}
			// Disable this so we only have one level of redo.
			else if (global._history.length>0)
			{
				if (global._index < global._history.length-1)
				{
					global._index++; // move to the next state
					global._applyState(0); // 0 because we want to run the REDO method of the next state
					global._statePos = 1; // set the pos back to 1 because we moved back to another state group
				}
			}
		}
		
		/*private function _applyState ():void
		{
			// // Consol.Trace("Applying State");
			
			_applying = true;
			
			var state:Array = _history[_index];
			var item:Object;
			
			for (var i:int=0; i<state.length; i++)
			{
				item = state[i];
				//// // Consol.Trace(item);
				if (item.type == ADD_CHILD || item.type == REMOVE_CHILD || item.type == APPLY_PROPS)
				{
					item.parent[item.props[0]].apply(null, item.values);
				}
			}
			
			_applying = false;
		}*/
		
		private function _applyState (statePos:int):void
		{
			var undo:Boolean = statePos==1;
			
			changed = true;
			
			state = APPLYING;
			
			// // Consol.Trace(">>>>>>>>>>[Applying " + (undo?"UNDO":"REDO") +"] History Length: " + _history.length + " Index: " + _index);
			
			_applying = true;
			
			var stateObj:Array = _history[_index];
			var item:Object;
			
			//dispatchEvent(new StateEvent(StateEvent.CHANGE));
			
			for (var i:int=0; i<stateObj.length; i++)
			{
				item = stateObj[i];
				//item.documentState.data.layer = (item.layerDepth!=-1 ? getLayer(item.layerDepth) : null);
				//// // Consol.Trace(item.documentState.data.layer=item.layerDepth)
				if (item.layerDepth!=-1) item.documentState.data.layer = getLayer(item.layerDepth);
				
				if (undo) item.undo(item.documentState);
				else item.redo(item.documentState);
			}
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE));
			
			_applying = false;
			
			state = CLOSED;
		}
		
		private function getDocumentState ():Object
		{
			return {canvasManager:_canMan, activeLayer:_canMan.activeLayer, activeLayerDepth:_canMan.activeLayerDepth};
		}
		
		public static function getLayer (depth:int):Layer
		{
			return global._canMan.getLayer(depth);
		}
		
		public static function getLineLayer (depth:int):LineLayer
		{
			return LineLayer(getLayer(depth));
		}
		
	}
	
}