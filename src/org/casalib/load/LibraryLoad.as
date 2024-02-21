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
	import org.casalib.load.CasaLoader;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import org.casalib.util.ClassUtil;
	
	
	/**
		Provides an easy and standardized way to load external SWF of class assets and instatiate them.
		
		@author Aaron Clinger
		@author Mike Creighton
		@version 02/04/09
		@example
			<code>
				package {
					import flash.display.MovieClip;
					import flash.display.DisplayObject;
					import org.casalib.load.LibraryLoad;
					import org.casalib.events.LoadEvent;
					
					
					public class MyExample extends MovieClip {
						protected var _libraryLoad:LibraryLoad;
						
						
						public function MyExample() {
							super();
							
							this._libraryLoad = new LibraryLoad("myExternalLib.swf");
							this._libraryLoad.addEventListener(LoadEvent.COMPLETE, this._onComplete);
							this._libraryLoad.start();
						}
						
						protected function _onComplete(e:LoadEvent):void {
							var externalAsset:DisplayObject = this._libraryLoad.createClassByName("RedBox");
							
							this.addChild(externalAsset);
						}
					}
				}
			</code>
			
			For embeded SWFs:
			<code>
				package {
					import flash.display.MovieClip;
					import flash.display.DisplayObject;
					import org.casalib.load.LibraryLoad;
					import org.casalib.events.LoadEvent;
					
					
					public class MyExample extends MovieClip {
						protected var _libraryLoad:LibraryLoad;
						
						[Embed(source="myExternalLib.swf", mimeType="application/octet-stream")]
						protected const Boxes:Class;
						
						
						public function MyExample() {
							super();
							
							this._libraryLoad = new LibraryLoad(Boxes);
							this._libraryLoad.addEventListener(LoadEvent.COMPLETE, this._onComplete);
							this._libraryLoad.start();
						}
						
						protected function _onComplete(e:LoadEvent):void {
							var externalAsset:DisplayObject = this._libraryLoad.createClassByName("RedBox");
							
							this.addChild(externalAsset);
						}
					}
				}
			</code>
	*/
	public class LibraryLoad extends CasaLoader {
		protected var _classRequest:Class;
		
		
		/**
			Creates and defines a LibraryLoad.
			
			@param request: A {@code String} or an {@code URLRequest} reference to the SWF you wish to load or the {@code Class} of the embeded SWF.
			@param context: An optional LoaderContext object.
		*/
		public function LibraryLoad(request:*, context:LoaderContext = null) {
			super(request, context);
		}
		
		/**
			Gets a public definition from the loaded SWF.
			
			@param name: The name of the definition.
			@return The object associated with the definition.
			@throws Error if method is called before SWF has loaded.
		*/
		public function getDefinition(name:String):Object {
			if (!this.loaded)
				throw new Error('Cannot access an external asset until the SWF has loaded.');
			
			return this.loaderInfo.applicationDomain.getDefinition(name);
		}
		
		/**
			Checks to see if a public definition exists within the loaded SWF.
			
			@param name: The name of the definition.
			@return Returns {@code true} if the specified definition exists; otherwise {@code false}.
			@throws Error if method is called before SWF has loaded.
		*/
		public function hasDefinition(name:String):Boolean {
			if (!this.loaded)
				throw new Error('Cannot access an external asset until the SWF has loaded.');
			
			return this.loaderInfo.applicationDomain.hasDefinition(name);
		}
		
		/**
			Retrieves an externally loaded class.
			
			@param className: The full name of the class you wish to receive from the loaded SWF.
			@return A Class reference.
			@throws Error if method is called before SWF has loaded.
		*/
		public function getClassByName(className:String):Class {
			return this.getDefinition(className) as Class;
		}
		
		/**
			Instatiates an externally loaded class.
			
			@param className: The full name of the class you wish to instantiate from the loaded SWF.
			@param arguments: The optional parameters to be passed to the class constructor.
			@return A reference to the newly instantiated class.
			@throws Error if method is called before SWF has loaded.
		*/
		public function createClassByName(className:String, arguments:Array = null):* {
			arguments ||= new Array();
			arguments.unshift(this.getClassByName(className));
			
			return ClassUtil.construct.apply(null, arguments);
		}
		
		override protected function _load():void {
			if (this._classRequest == null)
				this._loadItem.load(this._request);
			else
				this._loadItem.loadBytes(new this._classRequest() as ByteArray);
		}
		
		override protected function _createRequest(request:*):void {
			if (request is Class)
				this._classRequest = request;
			else
				super._createRequest(request);
		}
	}
}