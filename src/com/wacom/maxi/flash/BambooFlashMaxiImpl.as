package com.wacom.maxi.flash
{
	import com.gugga.events.LocaleEvent;
	import com.wacom.managers.PressureManager;
	import com.wacom.maxi.core.DockConnectionManager;
	import com.wacom.mini.core.tablet.TabletBridge;
	import com.wacom.mini.core.tablet.TabletManager;
	import com.wacom.mini.flash.BambooMiniGlobals;
	
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	[Event(name="locale_changed", type="com.gugga.events.LocaleEvent")]
	
	public class BambooFlashMaxiImpl extends EventDispatcher
	{
		public static const DOCK_LAUNCH_TIME_ESTIMATE : int = 2200;
		public static const MAXI_CLOSE_DELAY : int = 200;
		
		public var PM : PressureManager;
	
		private var document : DisplayObject;
		
		private var dockConnection : DockConnectionManager;
		
		private var waitForDockLaunchTimer : Timer;
		
		public function BambooFlashMaxiImpl(document : DisplayObject)
		{
			super();
			
			this.document = document;
			
			var tabletManager : TabletManager = new TabletManager();
			tabletManager.stage = document.stage;
			tabletManager.initializeGestureMapping(false);

			PM = PressureManager.getInstance();
			PM.start();

			TabletBridge.getInstance().pressureProvider = PressureManager.getInstance();
			TabletBridge.getInstance().sensorProvider = PressureManager.getInstance();

			BambooMiniGlobals.registerReference("application", this);
			BambooMiniGlobals.registerReference("tabletManager", tabletManager);
			BambooMiniGlobals.registerReference("tabletState", TabletBridge.getInstance());
			
			var window : NativeWindow = document.stage.nativeWindow;
			
			dockConnection = new DockConnectionManager({ nativeWindow : window, nativeApplication : NativeApplication.nativeApplication }, true);
			dockConnection.addEventListener(NativeWindowBoundsEvent.MOVE, dockConnection_moveHanlder);
			dockConnection.addEventListener(LocaleEvent.LOCALE_CHANGED, dockConnection_localeChangedHandler, false, 0, true);
			dockConnection.addEventListener(Event.CLOSE, dockConnection_closeHanlder, false, 0, true);
					
			waitForDockLaunchTimer = new Timer(DOCK_LAUNCH_TIME_ESTIMATE, 1);
			waitForDockLaunchTimer.addEventListener(TimerEvent.TIMER, waitForDockLaunchTimer_timerHandler);
			waitForDockLaunchTimer.start();
		}
		
		private function dockConnection_moveHanlder(event : NativeWindowBoundsEvent) : void
		{
			if(waitForDockLaunchTimer != null) 
			{
				waitForDockLaunchTimer.stop();
				waitForDockLaunchTimer = null;
			}
	
			var window : NativeWindow = document.stage.nativeWindow;
			window.visible = true;
		}
		
		private function dockConnection_localeChangedHandler(event : LocaleEvent) : void
		{
			dispatchEvent(event.clone());
		}
		
		private function dockConnection_closeHanlder(event : Event) : void
		{
			PressureManager.getInstance().stop();
			
			setTimeout(NativeApplication.nativeApplication.exit, MAXI_CLOSE_DELAY);
		}
		
		private function waitForDockLaunchTimer_timerHandler(event : TimerEvent) : void
		{
			var window : NativeWindow = document.stage.nativeWindow;
			window.visible = true;
			
			//dispatchEvent(Event.COMPLETE);
			
		}
	}
}