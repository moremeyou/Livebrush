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
package org.casalib.process {
	import org.casalib.events.ProcessEvent;
	import org.casalib.process.Process;
	
	
	/**
		Manages and threads {@link Process processes}.
		
		@author Aaron Clinger
		@version 12/23/08
		@example
			<code>
				package {
					import fl.motion.easing.Linear;
					import flash.display.MovieClip;
					import flash.display.Sprite;
					import org.casalib.events.ProcessEvent;
					import org.casalib.process.ProcessGroup;
					import org.casalib.transitions.PropertyTween;
					
					
					public class MyExample extends MovieClip {
						protected var _processGroup:ProcessGroup;
						
						
						public function MyExample() {
							super();
							
							this._processGroup = new ProcessGroup();
							this._processGroup.addEventListener(ProcessEvent.COMPLETE, this._onProcessComplete);
							
							var i:int = -1;
							var box:Sprite;
							while (++i < 10) {
								box   = new Sprite();
								box.y = 30 * i;
								box.graphics.beginFill(0xFF00FF);
								box.graphics.drawRect(0, 0, 25, 25);
								box.graphics.endFill();
								
								this.addChild(box);
								
								this._processGroup.addProcess(new PropertyTween(box, 'x', Linear.easeNone, 500, 1));
							}
							
							this._processGroup.start();
						}
						
						protected function _onProcessComplete(e:ProcessEvent):void {
							this._processGroup.destroyProcesses();
							this._processGroup.destroy();
							
							trace("Done!");
						}
					}
				}
			</code>
	*/
	public class ProcessGroup extends Process {
		public static var NORM_THREADS:int = 1; /**< The default amount of threads for all ProcessGroup instances. */
		protected var _threads:uint;
		protected var _processes:Array;
		protected var _autoStart:Boolean;
		
		
		/**
			Creates a new ProcessGroup.
		*/
		public function ProcessGroup() {
			super();
			
			this.threads    = ProcessGroup.NORM_THREADS;
			this._processes = new Array();
		}
		
		override public function start():void {
			super.start();
			
			this._checkThreads();
		}
		
		override public function stop():void {
			var l:uint = this._processes.length;
			while (l--) {
				if (this._processes[l].running) {
					this._processes[l].stop();
					return;
				}
			}
			
			super.stop();
		}
		
		/**
			Instructs the ProcessGroup to {@link #start} automatically with each {@link #addProcess added} uncompleted Process {@code true}, or wait for a implicit {@link #start} {@code false}. Defaults to {@code false}.
		*/
		public function get autoStart():Boolean {
			return this._autoStart;
		}
		
		public function set autoStart(autoStart:Boolean):void {
			this._autoStart = autoStart;
		}
		
		/**
			Adds a process to be threaded and run by the ProcessGroup.
			
			@param process: The process to be added and run by the group.
			@usageNote You can add a different instance of ProcessGroup to another ProcessGroup.
			@throws Error if you try add the same Process to itself.
		*/
		public function addProcess(process:Process):void {
			if (process == this)
				throw new Error('You cannot add the same Process to itself.');
			
			this.removeProcess(process);
			
			process.addEventListener(ProcessEvent.STOP, this._processStopped);
			process.addEventListener(ProcessEvent.COMPLETE, this._processCompleted);
			
			this._hasCompleted = process.completed;
			
			if (this._processes.length == 0) {
				this._processes.push(process);
			} else {
				var i:int = -1;
				var l:int = this._processes.length - 1;
				var hasAdded:Boolean;
				var p:Process;
				
				while (++i < this._processes.length) {
					p = this._processes[i];
					
					if (!p.completed) {
						this._hasCompleted = false;
						
						if (hasAdded)
							break;
					}
					
					if (!hasAdded) {
						if (process.priority > p.priority) {
							this._processes.splice(i, 0, process);
							hasAdded = true;
						} else if (i == l) {
							this._processes.push(process);
							hasAdded = true;
						}
						
						if (hasAdded && !this._hasCompleted)
							break;
					}
				}
			}
			
			if (this.autoStart && !this.completed) {
				if (this.running)
					this._checkThreads();
				else
					this.start();
			}
		}
		
		/**
			Removes a process from the ProcessGroup.
			
			@param process: The process to be removed.
		*/
		public function removeProcess(process:Process):void {
			this._removeProcessListeners(process);
			
			this._hasCompleted = true;
			
			var l:uint = this._processes.length;
			while (l--) {
				if (this._processes[l] == process)
					this._processes.splice(l, 1);
				else if (!this._processes[l].completed)
					this._hasCompleted = false;
			}
		}
		
		/**
			The processes that compose the group.
		*/
		public function get processes():Array {
			return this._processes.slice();
		}
		
		/**
			The number of simultaneous processes to run at once.
		*/
		public function get threads():uint {
			return this._threads;
		}
		
		public function set threads(threadAmount:uint):void {
			this._threads = threadAmount;
		}
		
		/**
			Calls {@link Process#destroy destroy} on all processes in the group and removes them from the ProcessGroup.
		*/
		public function destroyProcesses():void {
			var l:uint = this._processes.length;
			while (l--)
				this._processes[l].destroy();
			
			this._processes = new Array();
		}
		
		override public function destroy():void {
			var l:uint = this._processes.length;
			while (l--)
				this._removeProcessListeners(this._processes[l]);
			
			this._processes = new Array();
			
			super.destroy();
		}
		
		protected function _checkThreads():void {
			var t:uint = this.threads;
			var i:int  = -1;
			var p:Process;
			
			while (++i < this._processes.length) {
				if (t == 0)
					return;
				
				p = this._processes[i];
				
				if (p.running) {
					t--;
				} else if (!p.completed) {
					this._startProcess(p);
					t--;
				}
			}
			
			if (t == this.threads)
				this._complete();
		}
		
		protected function _startProcess(process:Process):void {
			process.start();
		}
		
		protected function _processStopped(e:ProcessEvent):void {
			this._checkThreads();
		}
		
		protected function _processCompleted(e:ProcessEvent):void {
			this._checkThreads();
		}
		
		protected function _removeProcessListeners(process:Process):void {
			process.removeEventListener(ProcessEvent.STOP, this._processStopped);
			process.removeEventListener(ProcessEvent.COMPLETE, this._processCompleted);
		}
	}
}