/*
	CASA Framework for ActionScript 3.0
	Copyright (c) 2009, Contributors of CASA Framework
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	
	- Redistributions of source code must retain the above copyright notice,
	  this list of conditions and the following disclaimer.
	
	- Redistributions in binary form must reproduce the above copyright notice,
	  this list of conditions and the following disclaimer in the documentation
	  and/or other materials provided with the distribution.
	
	- Neither the name of the CASA Framework nor the names of its contributors
	  may be used to endorse or promote products derived from this software
	  without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/
package org.casalib.load {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.system.LoaderContext;
	import org.casalib.load.LoadItem;
	
	[Event(name="init", type="flash.events.Event")]
	[Event(name="open", type="flash.events.Event")]
	[Event(name="unload", type="flash.events.Event")]
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	
	/**
		Wraps {@code Loader} and extends from {@link LoadItem}, {@link BaseLoadItem} and {@link Process}.
		
		In almost all cases you will want to use {@link GraphicLoad} or {@link LibraryLoad} instead of this class.
		
		@author Aaron Clinger
		@version 01/20/09
		@example
			<code>
				package {
					import flash.display.MovieClip;
					import org.casalib.events.LoadEvent;
					import org.casalib.load.CasaLoader;
					
					
					public class MyExample extends MovieClip {
						protected var _casaLoader:CasaLoader;
						
						
						public function MyExample() {
							super();
							
							this._casaLoader = new CasaLoader("test.jpg");
							this._casaLoader.addEventListener(LoadEvent.COMPLETE, this._onComplete);
							this._casaLoader.start();
						}
						
						protected function _onComplete(e:LoadEvent):void {
							this.addChild(this._casaLoader.loader);
						}
					}
				}
			</code>
	*/
	public class CasaLoader extends LoadItem {
		protected var _context:LoaderContext;
		
		
		/**
			Creates and defines a CasaLoader.
			
			@param request: A {@code String} or an {@code URLRequest} reference to the file you wish to load.
			@param context: An optional LoaderContext object.
		*/
		public function CasaLoader(request:*, context:LoaderContext = null) {
			super(new Loader(), request);
			
			this._context = context;
			
			this._initListeners(this.loaderInfo);
		}
		
		/**
			The Loader being used to load the image or SWF.
		*/
		public function get loader():Loader {
			return this._loadItem as Loader;
		}
		
		/**
			The LoaderInfo corresponding to the object being loaded.
		*/
		public function get loaderInfo():LoaderInfo {
			return this._loadItem.contentLoaderInfo;
		}
		
		/**
			The total number of bytes of the requested file.
		*/
		override public function get bytesTotal():uint {
			return this._loadItem.contentLoaderInfo.bytesTotal;
		}
		
		/**
			The number of bytes loaded of the requested file.
		*/
		override public function get bytesLoaded():uint {
			return this._loadItem.contentLoaderInfo.bytesLoaded;
		}
		
		override public function destroy():void {
			this._dispatcher.removeEventListener(Event.INIT, this.dispatchEvent, false);
			this._dispatcher.removeEventListener(Event.OPEN, this.dispatchEvent, false);
			this._dispatcher.removeEventListener(Event.UNLOAD, this.dispatchEvent, false);
			this._dispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, this.dispatchEvent, false);
			this._dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.dispatchEvent, false);
			
			super.destroy();
		}
		
		override protected function _load():void {
			this._loadItem.load(this._request, this._context);
		}
		
		/**
			@sends Event#INIT - Dispatched when the properties and methods of a loaded SWF file are accessible.
			@sends Event#OPEN - Dispatched when a load operation starts.
			@sends Event#UNLOAD - Dispatched when {@code unload} is called.
			@sends HTTPStatusEvent#HTTP_STATUS - Dispatched if class is able to detect and return the status code for the request.
			@sends SecurityErrorEvent#SECURITY_ERROR - Dispatched if load is outside the security sandbox.
		*/
		override protected function _initListeners(dispatcher:IEventDispatcher):void {
			super._initListeners(dispatcher);
			
			this._dispatcher.addEventListener(Event.INIT, this.dispatchEvent, false, 0, true);
			this._dispatcher.addEventListener(Event.OPEN, this.dispatchEvent, false, 0, true);
			this._dispatcher.addEventListener(Event.UNLOAD, this.dispatchEvent, false, 0, true);
			this._dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, this.dispatchEvent, false, 0, true);
			this._dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.dispatchEvent, false, 0, true);
		}
	}
}