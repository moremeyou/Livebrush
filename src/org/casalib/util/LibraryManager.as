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
package org.casalib.util {
	import org.casalib.load.LibraryLoad;
	import flash.utils.Dictionary;
	import org.casalib.util.ClassUtil;
	
	
	/**
		Creates an easy way to store multiple {@link LibraryLoad LibraryLoads} in groups and perform centralized retrieval of assets.
		
		@author Aaron Clinger
		@version 02/10/09
		@example
			<code>
				package {
					import flash.display.MovieClip;
					import flash.display.DisplayObject;
					import org.casalib.load.LibraryLoad;
					import org.casalib.load.GroupLoad;
					import org.casalib.events.LoadEvent;
					import org.casalib.util.LibraryManager;
					
					
					public class MyExample extends MovieClip {
						protected var _redLibLoad:LibraryLoad;
						protected var _greenLibLoad:LibraryLoad;
						protected var _groupLoad:GroupLoad;
						
						
						public function MyExample() {
							super();
							
							this._redLibLoad   = new LibraryLoad("redExternalLib.swf");
							this._greenLibLoad = new LibraryLoad("greenExternalLib.swf");
							
							LibraryManager.addLibraryLoad(this._redLibLoad);
							LibraryManager.addLibraryLoad(this._greenLibLoad);
							
							this._groupLoad = new GroupLoad();
							this._groupLoad.addLoad(this._redLibLoad);
							this._groupLoad.addLoad(this._greenLibLoad);
							this._groupLoad.addEventListener(LoadEvent.COMPLETE, this._onComplete);
							this._groupLoad.start();
						}
						
						protected function _onComplete(e:LoadEvent):void {
							var red:DisplayObject   = LibraryManager.createClassByName("RedBox");
							var green:DisplayObject = LibraryManager.createClassByName("GreenBox");
							
							green.x = 100;
							
							this.addChild(red);
							this.addChild(green);
						}
					}
				}
			</code>
	*/
	public class LibraryManager {
		public static const GROUP_DEFAULT:String = 'groupDefault';
		protected static var _groupMap:Dictionary;
		
		
		/**
			Adds a LibraryLoad to LibraryManager.
			
			@param libLoad: The LibraryLoad you wish to add.
			@param groupId: The identifier of the group you wish to add the LibraryLoad to.
		*/
		public static function addLibraryLoad(libLoad:LibraryLoad, groupId:String = LibraryManager.GROUP_DEFAULT):void {
			LibraryManager._getGroup(groupId)[libLoad] = libLoad;
		}
		
		/**
			Removes a LibraryLoad from LibraryManager.
			
			@param libLoad: The LibraryLoad you wish to remove.
			@param groupId: The identifier of the group you wish to remove the LibraryLoad from.
		*/
		public static function removeLibraryLoad(libLoad:LibraryLoad, groupId:String = LibraryManager.GROUP_DEFAULT):void {
			if (LibraryManager._hasGroup(groupId))
				if (libLoad in LibraryManager._groupMap[groupId])
					delete LibraryManager._groupMap[groupId][libLoad];
		}
		
		/**
			Removes all LibraryLoads from a group.
			
			@param groupId: The identifier of the group you wish to empty.
		*/
		public static function removeGroup(groupId:String):void {
			LibraryManager._initGroup();
			
			if (groupId in LibraryManager._groupMap)
				delete LibraryManager._groupMap[groupId];
		}
		
		/**
			Gets a public definition from a library group.
			
			@param name: The name of the definition.
			@param groupId: The identifier of the group you wish to retrieve the definition from.
			@return The object associated with the definition or {@code null} if the {@code name} doesn't exist.
		*/
		public static function getDefinition(name:String, groupId:String = LibraryManager.GROUP_DEFAULT):Object {
			if (LibraryManager._hasGroup(groupId)) {
				var lib:Dictionary = LibraryManager._getGroup(groupId);
				
				for each (var l:LibraryLoad in lib)
					if (l.loaded)
						if (l.hasDefinition(name))
							return l.getDefinition(name);
			}
			
			return null;
		}
		
		/**
			Checks to see if a public definition exists within the library group.
			
			@param name: The name of the definition.
			@param groupId: The identifier of the group in which to search for the definition.
			@return Returns {@code true} if the specified definition exists; otherwise {@code false}.
		*/
		public static function hasDefinition(name:String, groupId:String = LibraryManager.GROUP_DEFAULT):Boolean {
			if (LibraryManager._hasGroup(groupId)) {
				var lib:Dictionary = LibraryManager._getGroup(groupId);
				
				for each (var l:LibraryLoad in lib)
					if (l.loaded)
						if (l.hasDefinition(name))
							return true;
			}
			
			return false;
		}
		
		/**
			Retrieves a class from a library group.
			
			@param className: The full name of the class you wish to receive from the loaded SWF.
			@param groupId: The identifier of the group you wish to retrieve the class from.
			@return A Class reference or {@code null} if the {@code className} doesn't exist.
		*/
		public static function getClassByName(className:String, groupId:String = LibraryManager.GROUP_DEFAULT):Class {
			return LibraryManager.getDefinition(className, groupId) as Class;
		}
		
		/**
			Instatiates a class from a library group.
			
			@param className: The full name of the class you wish to instantiate from the loaded SWF.
			@param arguments: The optional parameters to be passed to the class constructor.
			@param groupId: The identifier of the group you wish to instantiate the class from.
			@return A reference to the newly instantiated class or {@code null} if the {@code className} doesn't exist.
		*/
		public static function createClassByName(className:String, arguments:Array = null, groupId:String = LibraryManager.GROUP_DEFAULT):* {
			var c:Class = LibraryManager.getClassByName(className);
			
			if (c == null)
				return null;
			
			arguments ||= new Array();
			arguments.unshift(c);
			
			return ClassUtil.construct.apply(null, arguments);
		}
		
		protected static function _initGroup():void {
			if (LibraryManager._groupMap == null)
				LibraryManager._groupMap = new Dictionary();
		}
		
		protected static function _hasGroup(groupId:String):Boolean {
			LibraryManager._initGroup();
			
			return groupId in LibraryManager._groupMap;
		}
		
		protected static function _getGroup(groupId:String):Dictionary {
			LibraryManager._initGroup();
			
			return LibraryManager._groupMap[groupId] ||= new Dictionary();
		}
	}
}