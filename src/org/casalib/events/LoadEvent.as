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
package org.casalib.events {
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import org.casalib.math.Percent;
	
	/**
		An event dispatched during loading.
		
		@author Aaron Clinger
		@version 10/27/08
	*/
	public class LoadEvent extends ProgressEvent {
		public static const COMPLETE:String = 'complete';
		public static const PROGRESS:String = 'progress';
		public static const START:String    = 'start';
		public static const STOP:String     = 'stop';
		protected var _progress:Percent;
		protected var _Bps:int;
		
		
		/**
			Creates a new LoadEvent.
			
			@param type: The type of event.
			@param bubbles: Determines whether the Event object participates in the bubbling stage of the event flow.
			@param cancelable: Determines whether the Event object can be canceled.
		*/
		public function LoadEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
		
		/**
			The percent that the requested file has loaded.
		*/
		public function get progress():Percent {
			return this._progress.clone();
		}
		
		public function set progress(per:Percent):void {
			this._progress = per.clone();
		}
		
		/**
			The current download speed of the requested file in bytes per second.
		*/
		public function get Bps():int {
			return this._Bps;
		}
		
		public function set Bps(bytes:int):void {
			this._Bps = bytes;
		}
		
		/**
			@return A string containing all the properties of the event.
		*/
		override public function toString():String {
			return formatToString('LoadEvent', 'type', 'bubbles', 'cancelable', 'Bps', 'bytesLoaded', 'bytesTotal', 'progress');
		}
		
		/**
			@return Duplicates an instance of the event.
		*/
		override public function clone():Event {
			var e:LoadEvent = new LoadEvent(this.type, this.bubbles, this.cancelable);
			e.progress      = this.progress;
			e.Bps           = this.Bps;
			e.bytesLoaded   = this.bytesLoaded;
			e.bytesTotal    = this.bytesTotal;
			
			return e;
		}
	}
}