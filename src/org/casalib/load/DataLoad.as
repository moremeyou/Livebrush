/*
	CASA Lib for ActionScript 3.0
	Copyright (c) 2009, Aaron Clinger & Contributors of CASA Lib
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	
	- Redistributions of source code must retain the above copyright notice,
	  this list of conditions and the following disclaimer.
	
	- Redistributions in binary form must reproduce the above copyright notice,
	  this list of conditions and the following disclaimer in the documentation
	  and/or other materials provided with the distribution.
	
	- Neither the name of the CASA Lib nor the names of its contributors
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
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLVariables;
	import org.casalib.load.LoadItem;
	
	[Event(name="id3", type="flash.events.Event")]
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	
	/**
		Provides an easy and standardized way to load data.
		
		@author Aaron Clinger
		@version 11/02/08
		@example
			<code>
				package {
					import flash.display.MovieClip;
					import org.casalib.events.LoadEvent;
					import org.casalib.load.DataLoad;
					
					
					public class MyExample extends MovieClip {
						protected var _dataLoad:DataLoad;
						
						
						public function MyExample() {
							super();
							
							this._dataLoad = new DataLoad("data.xml");
							this._dataLoad.addEventListener(LoadEvent.COMPLETE, this._onComplete);
							this._dataLoad.start();
						}
						
						protected function _onComplete(e:LoadEvent):void {
							trace(this._dataLoad.dataAsXml.toXMLString());
						}
					}
				}
			</code>
	*/
	public class DataLoad extends LoadItem {
		
		
		/**
			Creates and defines a DataLoad.
			
			@param request: A {@code String} or an {@code URLRequest} reference to the file you wish to load.
		*/
		public function DataLoad(request:*) {
			super(new URLLoader(), request);
			
			this._initListeners(this._loadItem);
		}
		
		/**
			The URLLoader being used to download the data.
		*/
		public function get urlLoader():URLLoader {
			return this._loadItem as URLLoader;
		}
		
		/**
			The data received from the DataLoad. Available after load is complete.
		*/
		public function get data():* {
			if (!this.loaded)
				return null;
			
			return this._loadItem.data;
		}
		
		/**
			The data received from the DataLoad data typed as XML. Available after load is complete.
		*/
		public function get dataAsXml():XML {
			if (!this.loaded || this._loadItem.dataFormat != URLLoaderDataFormat.TEXT)
				return null;
			
			return new XML(this.data);
		}
		
		/**
			The data received from the DataLoad data typed as URLVariables. Available after load is complete.
		*/
		public function get dataAsUrlVariables():URLVariables {
			if (!this.loaded || this._loadItem.dataFormat != URLLoaderDataFormat.VARIABLES)
				return null;
			
			return new URLVariables(this.data);
		}
		
		override public function destroy():void {
			this._dispatcher.removeEventListener(Event.OPEN, this.dispatchEvent, false);
			this._dispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, this.dispatchEvent, false);
			this._dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.dispatchEvent, false);
			
			super.destroy();
		}
		
		/**
			@sends Event#OPEN - Dispatched when a load operation starts.
			@sends HTTPStatusEvent#HTTP_STATUS - Dispatched if class is able to detect and return the status code for the request.
			@sends SecurityErrorEvent#SECURITY_ERROR - Dispatched if load is outside the security sandbox.
		*/
		override protected function _initListeners(dispatcher:IEventDispatcher):void {
			super._initListeners(dispatcher);
			
			this._dispatcher.addEventListener(Event.OPEN, this.dispatchEvent, false, 0, true);
			this._dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, this.dispatchEvent, false, 0, true);
			this._dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.dispatchEvent, false, 0, true);
		}
	}
}