package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import fl.controls.TextArea;
	import com.livebrush.ui.Panel
	import com.livebrush.data.Settings;
	
	public class Consol extends Panel
	{
		public static var messageTypes						:Array = [{id:"default", color:0x000000, indent:0, prefix:"", suffix:"", newline:true, bold:false},
																	  {id:"warning", color:0xDD0000, indent:0, prefix:"", suffix:"", newline:true, bold:false},
																	  {id:"app", color:0x000000, indent:0, prefix:"", suffix:"", newline:true, bold:true},
																	  {id:"file", color:0x00DD00, indent:2, prefix:"", suffix:"", newline:true, bold:false}
																	  ];
		
		//private static var textField						:TextArea;
		public static var globalConsol						:Consol;
		public static var recentConsol						:Consol;
		
		public function Consol ():void
		{
			super.setup();
			
			titlebar.showHelp = false;
			label = "Consol"
			
			//textField = this["tf"];
			recentConsol = this;
			
			clearBtn.addEventListener(MouseEvent.CLICK, clearConsole);
		}
		
		public function output (str:Object, addReplace:Boolean=true):void // ... options
		{
			//textField.htmlText += <format> public static function idToIndex (s:String, a:Array, p:String=null):int
			try
			{
			
				if (addReplace) tf.text += (str.toString() + "\n");
				else tf.text = str.toString();

			
			}
			catch (e:Error)
			{
				output("Consol: Object passed to Consol is null or undefined -> " + e.toString());
			}
			
			tf.verticalScrollPosition = tf.maxVerticalScrollPosition;
			
			recentConsol = this;
			
		}
		
		public static function Trace (str:Object, addReplace:Boolean=true):void
		{
			Consol.globalOutput(str, addReplace);
		}
		
		public static function globalOutput (str:Object, addReplace:Boolean=true):void
		{
			if (globalConsol == null) globalConsol = recentConsol;
			globalConsol.output(str, addReplace);
		}
		
		public static function Clear ():void
		{
			Consol.globalConsol.tf.text = "";
		}
		
		public function clearConsole (e:MouseEvent=null):void
		{
			Consol.Clear();
		}
		
		
	}
	
	
}