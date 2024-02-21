package com.livebrush.ui
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import com.livebrush.events.*;
	
	public class StylePanelGroup extends Sprite
	{
		
		public var activeStylePanel					:String = null;
		public var styleBar							:StylebarPanel;
		public var stylesPanel						:SavedStylesPanel;
		public var linePanel						:LinePanel;
		public var strokePanel						:StrokePanel;
		public var layerPanel						:LayerStylePanel;
		public var decoPanel						:DecoPanel;
		private var stylePanelContainer				:Sprite;
		
		public function StylePanelGroup ():void
		{
			//trace("Styles Panel")
			//cacheAsBitmap = true;
			
			init();
		}
		
		private function init ():void
		{
			styleBar = new StylebarPanel();
			stylesPanel = new SavedStylesPanel();
			linePanel = new LinePanel();
			strokePanel = new StrokePanel();
			layerPanel = new LayerStylePanel();
			decoPanel = new DecoPanel();
			stylePanelContainer = new Sprite();
			
			
			addChild(styleBar);
			addChild(stylePanelContainer);
			//stylePanelContainer.addChild(decoPanel);
			
			
			styleBar.x = 250+34
			
			// Stylebar init
			styleBar.styles.buttonMode = styleBar.line.buttonMode = styleBar.stroke.buttonMode = styleBar.layer.buttonMode = styleBar.deco.buttonMode = true;
			styleBar.addEventListener (MouseEvent.CLICK, toggleStylePanel);
			
			addEventListener (Event.REMOVED, closePanel, true);
		}
		
		private function closePanel (e:Event):void
		{
			//trace(e.target);
			if (e.eventPhase != EventPhase.AT_TARGET && e.target is Panel) //  && e.target is StylePanel
			{
				resetStyleBar();
				activeStylePanel = null;
			}
		}
		
		private function toggleStylePanel (e:MouseEvent):void
		{
			//trace(e.target.name);
			
			if (e.eventPhase != EventPhase.AT_TARGET && e.target.name != "bg" && activeStylePanel != e.target.name)
			{
				var showStylePanel:Panel;
							
				resetStyleBar();
				
				switch (e.target.name) {
					case "styles" : showStylePanel = stylesPanel; break;
					case "line" : showStylePanel = linePanel; break;
					case "stroke" : showStylePanel = strokePanel; break;
					case "layer" : showStylePanel = layerPanel; break;
					case "deco" : showStylePanel = decoPanel; break;
				}
				//Panel(stylePanelContainer.getChildByName(activeStylePanel)).close();
				if (stylePanelContainer.numChildren > 0) stylePanelContainer.removeChildAt(0);
				stylePanelContainer.addChildAt(showStylePanel, 0);
				
				activeStylePanel = e.target.name;
				
				e.target.enabled = false;
				e.target.gotoAndStop("_locked");
				
				
			}
			else if (e.eventPhase != EventPhase.AT_TARGET && e.target.name != "bg" && activeStylePanel == e.target.name)
			{
				var hideStylePanel:Panel;
				resetStyleBar();
				
				switch (e.target.name) {
					case "styles" : hideStylePanel = stylesPanel; break;
					case "line" : hideStylePanel = linePanel; break;
					case "stroke" : hideStylePanel = strokePanel; break;
					case "layer" : hideStylePanel = layerPanel; break;
					case "deco" : hideStylePanel = decoPanel; break;
				}
				
				//
				
				stylePanelContainer.removeChild(hideStylePanel);
				
				//activeStylePanel = null;
			}
			
		}
		
		private function resetStyleBar ():void
		{
			//trace("resetting")
			//MovieClip(styleBar.getChildByName(activeStylePanel)).gotoAndStop("_up");
			// Reset all stylebar buttons.
			for (var i:int=0; i<styleBar.numChildren; i++)
			{
				if (styleBar.getChildAt(i) is MovieClip)
				{
					MovieClip(styleBar.getChildAt(i)).gotoAndStop("_up");
					MovieClip(styleBar.getChildAt(i)).enabled = true;
				}
			}
		}
		
	}
	
	
}