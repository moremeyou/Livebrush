package com.livebrush.events
{

	import flash.events.Event;
	
	
	public class FileEvent extends Event
	{
		
		public static const BEGIN_LOAD				:String = "beginLoad";
		public static const FILE_NOT_FOUND			:String = "fileNotFound";
		public static const WRONG_FILE				:String = "wrongFile";
		public static const IO_EVENT				:String = "ioEvent";
		public static const IO_ERROR				:String = "ioError";
		public static const OPEN					:String = "openFile";
		public static const BATCH_OPEN				:String = "batchOpenFile";
		public static const SAVE					:String = "saveFile";
		public static const PROJECT_SAVED			:String = "projectSaved";
		public static const CLOSE					:String = "closeFile";
		public static const IMPORT					:String = "import";
		public static const EXPORT					:String = "export";
		public static const IMPORT_STYLE			:String = "importStyle";
		public static const EXPORT_STYLE			:String = "exportStyle";
		public static const IMPORT_DECOSET			:String = "importDecoSet";
		public static const EXPORT_DECOSET			:String = "exportDecoSet";
		public static const IMPORT_DECO				:String = "importDeco";
		public static const EXPORT_DECO				:String = "exportDeco";
		public static const SAVED_FLAT				:String = "saveFlatImage";
		public static const IO_COMPLETE				:String = "ioComplete";
		public static const VERSION_UPDATE			:String = "versionUpdate";
		public static const NEW_VERSION				:String = "newVersion";
		public static const UPDATE_VERSION			:String = "updateVersion";
		public static const CURRENT_VERSION			:String = "currentVersion";
		
		
		public var fileType							:String = "";
		public var action							:String = "";
		public var data								:Object = "";
	
		public function FileEvent (type:String, bubbles:Boolean=false, cancelable:Boolean=false, action:String="", fileType:String="", data:Object=""):void
		{
			super(type, bubbles, cancelable);
			this.action = action;
			this.fileType = fileType;
			this.data = data;
		}
		
		public override function clone():Event
		{
			return new FileEvent(type,bubbles,cancelable);
		}
		
		public override function toString():String
		{
			return formatToString("FileEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
	
}