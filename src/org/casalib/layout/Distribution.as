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
package org.casalib.layout {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
		Creates the mechanism to distribute DisplayObjects to a vertical or horzontal grid of columns and rows.
		
		@author Aaron Clinger
		@author Jon Adams
		@version 10/26/08
		@example
			<code>
				package {
					import flash.display.MovieClip;
					import flash.display.Sprite;
					import org.casalib.layout.Distribution;
					
					
					public class MyExample extends MovieClip {
						public var dist:Distribution;
						
						public function MyExample() {
							super();
							
							this.dist = new Distribution(315);
							this.dist.setMargin(0, 5, 5, 0);
							
							this.addChild(this.dist);
							
							var l:uint = 10;
							var s:Sprite;
							
							while (l--) {
								s = new Sprite();
								s.graphics.beginFill(0xFF00FF);
								s.graphics.drawRect(0, 0, 100, 100);
								s.graphics.endFill();
								
								this.dist.addChild(s);
							}
							
							this.dist.position();
						}
					}
				}
			</code>
	*/
	public class Distribution extends Sprite {
		protected var _marginTop:Number;
		protected var _marginRight:Number;
		protected var _marginBottom:Number;
		protected var _marginLeft:Number;
		protected var _size:Number;
		protected var _isSnap:Boolean;
		protected var _isVert:Boolean;
		
		
		/**
			Creates a Distribution.
			
			@param size: The maximum width or height of the distrubution. If {@code isVertical} argument is {@code false} you are setting the width of the distrubution before wrapping, if {@code true} you're setting the height before wrapping.
			@param isVertical: Indicates to position children left-to-right top-to-bottom {@code false}, or to position children top-to-bottom left-to-right {@code true}.
			@param snapToPixel: Force the position of all children to whole pixels {@code true}, or to let items be positioned on sub-pixels {@code false}.
		*/
		public function Distribution(size:Number = Number.POSITIVE_INFINITY, isVertical:Boolean = false, snapToPixel:Boolean = true) {
			super();
			
			this.size          = size;
			this.vertical      = isVertical;
			this._isSnap       = snapToPixel;
			this._marginTop    = 0;
			this._marginRight  = 0;
			this._marginBottom = 0;
			this._marginLeft   = 0;
		}
		
		/**
			Defines the spacing between children in the distribution.
			
			@param top: Sets the top spacing of the children.
			@param right: Sets the right spacing of the children.
			@param bottom: Sets the bottom spacing of the children.
			@param left: Sets the left spacing of the children.
		*/
		public function setMargin(top:Number = 0, right:Number = 0, bottom:Number = 0, left:Number = 0):void {
			this.marginTop    = top;
			this.marginRight  = right;
			this.marginBottom = bottom;
			this.marginLeft   = left;
		}
		
		/**
			The top spacing of the children.
		*/
		public function set marginTop(top:Number):void {
			this._marginTop = top;
		}
		
		public function get marginTop():Number {
			return this._marginTop;
		}
		
		/**
			The right spacing of the children.
		*/
		public function set marginRight(right:Number):void {
			this._marginRight = right;
		}
		
		public function get marginRight():Number {
			return this._marginRight;
		}
		
		/**
			The bottom spacing of the children.
		*/
		public function set marginBottom(bottom:Number):void {
			this._marginBottom = bottom;
		}
		
		public function get marginBottom():Number {
			return this._marginBottom;
		}
		
		/**
			The left spacing of the children.
		*/
		public function set marginLeft(left:Number):void {
			this._marginLeft = left;
		}
		
		public function get marginLeft():Number {
			return this._marginLeft;
		}
		
		/**
			The maximum width or height of the distrubution. If {@link #vertical} is {@code false} you are setting the width of the distrubution before wrapping, if {@code true} you're setting the height before wrapping.
		*/
		public function set size(s:Number):void {
			this._size = s;
		}
		
		public function get size():Number {
			return this._size;
		}
		
		/**
			Indicates to position children left-to-right top-to-bottom {@code false}, or to position children top-to-bottom left-to-right {@code true}.
		*/
		public function set vertical(isVertical:Boolean):void {
			this._isVert = isVertical;
		}
		
		public function get vertical():Boolean {
			return this._isVert;
		}
		
		/**
			Arranges the children of the Distribution.
		*/
		public function position():void {
			var i:int          = -1;
			var column:Number  = 0;
			var row:Number     = 0;
			var largest:Number = 0;
			var item:DisplayObject;
			var xPo:Number;
			var yPo:Number;
			var w:Number;
			var h:Number;
			
			while (++i < this.numChildren) {
				item = this.getChildAt(i);
				
				w = item.width  + this._marginLeft + this._marginRight;
				h = item.height + this._marginTop + this._marginBottom;
				
				if (!this.vertical) {
					column += w;
					
					if (column > this.size) {
						row += (largest == 0) ? row : largest;
						
						largest = 0;
						column  = w;
					}
					
					if (h > largest)
						largest = h;
					
					xPo = column - item.width - this._marginRight;
					yPo = row + this._marginTop;
				} else {
					row += h;
					
					if (row > this.size) {
						column += (largest == 0) ? column : largest;
						
						largest = 0;
						row     = h;
					}
					
					if (w > largest)
						largest = w;
					
					xPo = column + this._marginLeft;
					yPo = row - item.height - this._marginBottom;
				}
				
				this._positionItem(item, this._isSnap ? Math.round(xPo) : xPo, this._isSnap ? Math.round(yPo) : yPo);
			}
		}
		
		protected function _positionItem(target:DisplayObject, xPo:Number, yPo:Number):void {
			target.x = xPo;
			target.y = yPo;
		}
	}
}