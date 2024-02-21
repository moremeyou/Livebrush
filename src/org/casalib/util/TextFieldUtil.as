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
package org.casalib.util {
	import flash.text.TextField;
	
	/**
		Utilities for working with TextFields.
		
		@author Aaron Clinger
		@author Mike Creighton
		@version 04/27/08
	*/
	public class TextFieldUtil {
		
		
		/**
			Determines if textfield has more text than can be displayed at once.
			
			@param field: Textfield to check for text overflow.
			@return Returns (@code true} if textfield has text overflow; otherwise {@code false}.
		*/
		public static function hasOverFlow(field:TextField):Boolean {
			return field.maxScrollV > 1;
		}
		
		/**
			Removes text overflow on a plain text textfield with the option of an ommission indicator.

			@param field: Textfield to remove overflow.
			@param omissionIndicator: Text indication that an omission has occured; normally {@code "..."}; defaults to no indication.
			@return Returns the omitted text; if there was no text ommitted function returns a empty String ({@code ""}).
		*/
		public static function removeOverFlow(field:TextField, omissionIndicator:String = ""):String {
			if (!TextFieldUtil.hasOverFlow(field))
				return '';
			
			if (omissionIndicator == null)
				omissionIndicator = '';
			
			var originalCopy:String        = field.text;
			var lines:Array                = field.text.split('. ');
			var isStillOverflowing:Boolean = false;
			var words:Array;
			var lastSentence:String;
			var sentences:String;
			var overFlow:String;
			
			while (TextFieldUtil.hasOverFlow(field)) {
				lastSentence = String(lines.pop());
				field.text   = (lines.length == 0) ? '' : lines.join('. ') + '. ';
			}
			
			sentences   = (lines.length == 0) ? '' : lines.join('. ') + '. ';
			words       = lastSentence.split(' ');
			field.text  += lastSentence;
			
			while (TextFieldUtil.hasOverFlow(field)) {
				if (words.length == 0) {
					isStillOverflowing = true;
					break;
				} else {
					words.pop();
					
					if (words.length == 0)
						field.text = sentences.substr(0, -1) + omissionIndicator;
					else
						field.text = sentences + words.join(' ') + omissionIndicator;
				}
			}
			
			if (isStillOverflowing) {
				words = field.text.split(' ');
				
				while (TextFieldUtil.hasOverFlow(field)) {
					words.pop();
					field.text = words.join(' ') + omissionIndicator;
				}
			}
			
			overFlow = originalCopy.substring(field.text.length);
			
			return (overFlow.charAt(0) == ' ') ? overFlow.substring(1) : overFlow;
		}
	}
}