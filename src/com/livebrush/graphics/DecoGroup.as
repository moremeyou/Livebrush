package com.livebrush.graphics
{

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.EventPhase;
	import flash.events.EventDispatcher;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.styles.Style;
	import com.livebrush.ui.Consol;
	import com.livebrush.tools.LiveBrush;
	import com.livebrush.graphics.Line;
	import com.livebrush.data.Settings;
	import com.livebrush.styles.DecoAsset;
	import com.livebrush.graphics.Deco;
	
	public class DecoGroup extends EventDispatcher
	{
		private var decos							:Array;
		private var decoLoadCount					:int;
		
		public function DecoGroup ()
		{
			decos = [];
			decoLoadCount = 0;
		}
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get decoList ():Array {   return decos.slice();   }
		public function get latest ():Deco {   return decos[decos.length-1];   }
		public function get length ():int {   return decos.length;   }
		public function get loaded ():Boolean 
		{   
			var loaded:Boolean = true;
			for (var i:int=0; i<decos.length; i++)
			{
				loaded = decos[i].loaded;
			}
			return loaded;
		}
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function groupComplete ():void
		{
			//_loaded = true;
			dispatchEvent (new Event(Event.COMPLETE, true, false));
		}
		
		private function decoComplete ():void
		{
			//// // Consol.Trace("decoGroup newDeco loaded!");
			decoLoadCount++;
			if (decoLoadCount == length) groupComplete();
		}
		
		
		// PUBLIC ACTIONS ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function addDeco (decoAsset:DecoAsset, initObj:Settings):void
		{
			var newDeco:Deco = new Deco (decoAsset, initObj);
			//// // Consol.Trace("decoGroup newDeco loaded: " + newDeco.loaded);
			if (!newDeco.loaded) newDeco.addEventListener(Event.COMPLETE, decoCompleteHandler);
			else decoComplete();
			decos.push(newDeco);
		}
		
		public function addDecoObj (deco:Deco):void
		{
			if (!deco.loaded) deco.addEventListener(Event.COMPLETE, decoCompleteHandler);
			else decoComplete();
			decos.push(deco);
		}
		
		public function removeAllDecos ():void
		{
			while (length > 0)
			{
				removeDecoIndex(0);
			}
		}
		
		public function removeDeco (id:int):void
		{
			removeDecoIndex(Settings.idToIndex(id.toString(), decos, "id"));
		}
		
		public function removeDecoIndex (index:int):void
		{
			decos[index].die();
			delete decos[index];
			decos.splice(index, 1);
		}
	
	
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function decoCompleteHandler (e:Event):void
		{
			e.target.removeEventListener(e.type, decoCompleteHandler);
			decoComplete();
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function getDeco (index:int):Deco
		{
			return decos[index];
		}
		
		public function copy ():DecoGroup
		{
			var newDecoGroup:DecoGroup = new DecoGroup();
			for (var i:int=0; i<decos.length; i++)
			{
				newDecoGroup.addDeco(decos[i].decoAsset.copy(), decos[i].initObj);
			}
			return newDecoGroup;
		}
		
		
		// TBD / DEBUG //////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////

		
	}
}