package com.livebrush.data
{
	
	import fl.data.DataProvider;
	import com.livebrush.ui.Consol;
	
	public dynamic class Settings
	{
		
		
		public function Settings ():void
		{
		}
		
		public function traceSettings ():void
		{
			traceDynamicObject(this, "Settings Object")
		}
		
		public static function outputChars (char:String="-", n:int=1):String
		{
			var str:String = "";
			for (var i:int=0;i<n;i++)
			{
				str += char
			}
			return str;
		}
		
		public static function traceDynamicObject (o:Object, objName:String="Object Root", depth:int=0, toConsol:Boolean=true):void
		{
			// this will only work with dynamic objects
			
			var output:String = outputChars("  ", depth) + objName + traceProp(typeof o);
			
			var objCount:int = Settings.getLength(o);
			
			if (objCount == 0)
			{
				output += ("= " + o);
				
				if (!toConsol) trace(output);
				else try { 
				// Consol.Trace(output); 
				} catch(e:Error){}
			}
			else if (objCount > 0)
			{
				output += traceProp(objCount, false);
				
				if (!toConsol) trace(output);
				else try { 
				// Consol.Trace(output); 
				} catch(e:Error){}
				
				depth++;
				for (var prop:String in o)
				{
					traceDynamicObject(o[prop], prop, depth, toConsol);
				}
			}
		}
		
		public static function outputDynamicObject (o:Object, objName:String="Object Root", depth:int=0, toConsol:Boolean=false):void
		{
			traceDynamicObject(o, objName, 0, true);
		}
		
		public function copy ():Settings
		{
			var newSettings:Settings = new Settings();
			for (var prop:String in this)
			{
				newSettings[prop] = copyObject (this[prop]);
			}
			return newSettings;
		}
		
		public static function copyObject (o:Object):Object
		{
			// this will only work with dynamic objects
			
			var newObj:Object = {};
			
			var objCount:int = Settings.getLength(o);
			
			if (objCount>0)
			{
				for (var prop:String in o)
				{
					newObj[prop] = copyObject(o[prop]);
				}
			}
			else
			{
				newObj = o;
			}
			
			return newObj;
		}
		
		public static function copyArrayOfObjects (a:Array):Array
		{
			var newArray:Array = [];
			var newItem:Object;
			for (var i:int=0; i<a.length; i++)
			{
				try {   newItem = a[i].copy();   }
				catch (e:Error) {   newItem = a[i].clone();   }
				catch (e:Error) {   newItem = Settings.copyObject(a[i]);   }
				finally {   newArray.push(newItem);   }
			}
			return newArray;
		}
		
		public static function traceProp(value:Object, padding:Boolean=true):String
		{
			return (padding ? " (" + value + ") " : "(" + value + ")");
		}
		
		public function length ():int
		{
			return Settings.getLength(this);
		}
		
		public static function getLength (o:Object):int
		{
			var objCount:int = 0;
			for (var prop:String in o) objCount++;
			return objCount;
		}
	
		public static function idToIndex (s:String, a:Array, p:String=null):int
		{
			var index:int;
			for (var i:int=0; i<a.length; i++) 
			{
				if (p==null) 
				{
					if (a[i].toString() == s) index = i; //break;
					//trace(a[i] + " = " + s + " = " + (a[i].toString() == s))
				}
				else
				{
					if (a[i][p].toString() == s) index = i; //break;
					//trace(a[i][p] + " = " + s + " = " + (a[i][p].toString() == s))
				}
			}
			return index;
		}
		
		public static function objToIndex (o:Object, a:Array, p:String=null):int
		{
			var index:int;
			for (var i:int=0; i<a.length; i++) 
			{
				if (p==null) 
				{
					if (a[i] == o) index = i; //break;
					//trace(a[i] + " = " + s + " = " + (a[i].toString() == s))
				}
				else
				{
					if (a[i][p] == o) index = i; //break;
					//trace(a[i][p] + " = " + s + " = " + (a[i][p].toString() == s))
				}
			}
			return index;
		}

		public static function arrayToDataProvider (a:Array, labelProp:String="label", dataProp:String="data"):DataProvider
		{
			var dp:DataProvider = new DataProvider();
			for (var i:int=0; i<a.length; i++) dp.addItem({label:a[i][labelProp], data:a[i][dataProp]});
			return dp;
		}
		
		public static function attrToElement (xml:XML, addLength:Boolean=false):XML 
		{
			var xmlElement:XML;
			
			for each (var attr:XML in xml.@*) 
			{
				xmlElement = <{attr.name().toString()}>{attr.toString()}</{attr.name().toString()}>
				xml.appendChild(xmlElement);
			}
			//if (addLength) xml.appendChild(<length>{xml.length()}</length>); 
			
			for each (var child:XML in xml..*) 
			{
				if (child.nodeKind() == "element") 
				{
					for each (attr in child.@*) 
					{
						xmlElement = <{attr.name().toString()}>{attr.toString()}</{attr.name().toString()}>
						child.appendChild(xmlElement);
					}
					//if (addLength) child.appendChild(<length>{child.length()}</length>); 
				}
			}
			return xml;
		}
				
		public static function varStringToXML (propName:String, obj:Object, value:String=null):XML // should this be in the settings obj
		{
			var xml:XML;
			if (value == null) xml = new XML(<{propName}>{obj[propName]}</{propName}>);
			else xml = new XML(<{propName}>{value}</{propName}>);
			return xml;
		}
		
		public static function stringToBoolean (value:String):Boolean
		{
			return (value=="true" ? true : false);
		}
		
		public static function isBoolString (value:String):Boolean
		{
			return (value=="true" || value=="false");
		}

		
	}
	

	
}