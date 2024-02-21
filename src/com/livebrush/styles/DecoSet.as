package com.livebrush.styles
{
	
	//import com.livebrush.graphics.Deco;
	import com.livebrush.styles.DecoAsset;
	import com.livebrush.data.FileManager;
	//import com.livebrush.styles.Style;
	import com.livebrush.ui.Consol;
	
	public dynamic class DecoSet //implements Storable
	{
		
		public static var index					:int = 0;
		
		private var _decos						:Array;
		public var name							:String;
		public var data							:String; // the data reference in the style decoset list. 
		private var _activeDecos				:Array;
		public var selectedDecoIndex			:int = 0;
		
		public function DecoSet ():void
		{
			_decos = [];
			_activeDecos = [];
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get length ():int {   return decos.length;   }
		//public function get activeLength ():int {   return _activeDecos.length;   }
		public function get activeLength ():int {   return _decos.length;   }
		public function get decos ():Array {   return _decos;   }
		//public function set decos (a:Array):void {   _decos=a; _activeDecos=[]; for(var i:int=0; i<length; i++) if (a[i].enabled) _activeDecos.push(a[i]);   }
		public function set decos (a:Array):void {   _decos=a;   }
		//public function get activeDecos ():Array {   return _activeDecos;   }
		public function get activeDecos ():Array {   return _decos;   }
		
		
		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function die ():void
		{
			_decos = [];
			delete this;
		}
		
		
		// DATA MANAGEMENT //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		// This is only used for exporting
		public function getXML ():XML
		{
			var decoSetXML:XML = new XML(<decoList></decoList>);
			for (var i:int=0; i<decos.length; i++)
			{
				decoSetXML.appendChild(<deco value={decos[i].fileName} enabled={true}></deco>);
			}
			return decoSetXML;
		}
		
		
		// STYLE ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function clone ():DecoSet
		{
			var decoSet:DecoSet = new DecoSet();
			for (var i:int=0; i<decos.length; i++)
			{
				decoSet.addDeco(decos[i].assetPath, true); // decos[i].enabled
			}
			decoSet.name = name;
			//// // Consol.Trace("From within decoSet: " + activeLength);
			//decoSet.decos = decoSet.decos;
			return decoSet;
		}
		
		public function addDeco (assetPath:String, enabled:Boolean=true, forceNew:Boolean=false, index:Number=0):void
		{
			//decos.push({decoStyle:decoStyle, assetPath:assetPath, fileName:assetPath.substr(assetPath.lastIndexOf("/")+1)});
			//decos.push(new DecoAsset (assetPath));
			var decoAsset:DecoAsset = FileManager.getInstance().getDecoAsset(assetPath, enabled, forceNew);
			//_decos.push(FileManager.getInstance().getDecoAsset(assetPath, enabled, forceNew));
			_decos.splice(index+1, 0, decoAsset);
		}
		
		public function removeDeco(index:int):void
		{
			selectedDecoIndex = index;
			decos.splice(index,1);
			selectedDecoIndex = selectedDecoIndex>0 ? index-1 : 0;
		}
		
		public function moveDeco (index:int, dir:int):void
		{
			var moveDeco:Object = decos[index];
			var inTheWayDeco:Object = decos[index+dir];
			decos[index+dir] = moveDeco;
			decos[index] = inTheWayDeco;
			selectedDecoIndex = index+dir;
		}
		
		public function removeAllDecos():void
		{
			decos = [];
		}
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function getDecoByIndex (index:int):DecoAsset
		{
			return _decos[index];
		}
		
		public function getActiveDecoByIndex (index:int):DecoAsset
		{
			return activeDecos[index];
		}

		
	}
	
	
}