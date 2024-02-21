package com.wacom.maxi.flash
{
	import com.gugga.events.LocaleEvent;
	
	import flash.display.MovieClip;

	public class BambooFlashMaxi extends MovieClip
	{
		private var impl : BambooFlashMaxiImpl;
		
		public function BambooFlashMaxi()
		{
			super();
		
			impl = new BambooFlashMaxiImpl(this);
			impl.addEventListener(LocaleEvent.LOCALE_CHANGED, impl_localeChangedHandler);
		}
		
		/**
		 * Called each time when the current language is changed (including the initial launch).
		 * 
		 * @param language The code of currently selected language.
		 */
		protected function languageChanged(language : String) : void 
		{ 
		}
		
		private function impl_localeChangedHandler(event : LocaleEvent) : void
		{
			languageChanged(event.language);
		}
	}
}