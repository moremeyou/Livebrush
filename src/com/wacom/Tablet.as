package com.wacom
{
	
	import flash.events.EventDispatcher;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.events.Event;
	
	import com.livebrush.ui.Consol;
	
	import com.wacom.managers.AirAppConnectionManager; 
	import com.wacom.managers.PressureManager;
	import com.wacom.maxi.flash.BambooFlashMaxiImpl;
	import com.wacom.events.PressureEvent;
	
	public class Tablet extends EventDispatcher
	{
		
		public static const MAX_PRESSURE			:int = 1023;
		
		private static var singleton				:Tablet;
		public static var DOCK						:BambooFlashMaxiImpl;
		public static var PRESSURE_STARTED			:Boolean = false;
		public static var PRESSURE					:Number = 0;
		private var connected						:Boolean = false;
		private var interval						:int;
		private var initTime						:int;
		
		public function Tablet (mainStage:*):void
		{
			DOCK = new BambooFlashMaxiImpl(mainStage);
			PM.addEventListener(PressureEvent.PRESSURE, onPressureEvent, false, 0, true);
			//Consol.Trace(AirAppConnectionManager.getInstance().connected()); 
			interval = setInterval(initCheck, 100);
			initTime = getTimer();
			//Consol.Trace("Tablet: initTime: " + initTime);
		}
		
		public static function get PM ():PressureManager {   return DOCK.PM;   }
		public static function get PRESSURE_PERCENT ():Number {   return PRESSURE/MAX_PRESSURE;   }
		
		public static function getInstance (mainStage:*):Tablet
		{
			var instance:Tablet;
			if (singleton == null) 
			{
				singleton = new Tablet(mainStage);
				instance = singleton;
			}
			else 
			{
				instance = singleton;
			}
			
			return instance;
		}
		
		private function initCheck ():void
		{
			var _connected:Boolean = AirAppConnectionManager.getInstance().connected(); 
			
			//Consol.Trace("Tablet: getTimer: " + getTimer());
			//Consol.Trace(("Tablet: " + getTimer() + " > " + (initTime+10000) + " = " + (getTimer() > initTime+10000))):
			
			if (!connected && _connected) 
			{
				//Consol.Trace(_connected); 
				dispatchEvent(new Event(Event.COMPLETE));
				connected = true;
				clearInterval(interval);
			}
			else if (getTimer() > (initTime+10000) && !_connected)
			{
				//Consol.Trace("Dock not installed"); 
				clearInterval(interval);
			}
		}
		
		private function onPressureEvent (e:PressureEvent):void
		{
			PRESSURE = e.pressure;
		}
		
		public static function startPressure ():void
		{
			if (!PRESSURE_STARTED) {
				
				//Consol.Trace("Tablet: startPressure");
				
				PRESSURE_STARTED = true;
				try 
				{ 
					PM.startPressure(); 
					//PM.addEventListener(PressureEvent.PRESSURE, getInstance().onPressureEvent, false, 0, true);
				} 
				catch(e:Error) 
				{
					//Consol.Trace("Tablet: error: " + e);
				}
			}
		}
		
		public static function stopPressure ():void
		{
			if (PRESSURE_STARTED) {
				
				//Consol.Trace("Tablet: stopPressure");
				
				PRESSURE_STARTED = false;
				try 
				{ 
					PM.stopPressure(); 
					//PM.removeEventListener(PressureEvent.PRESSURE, getInstance().onPressureEvent, false, 0, true);
				} 
				catch(e:Error) 
				{
					//Consol.Trace("Tablet: error: " + e);
				}
			}
		}
		
		
	}
	
}