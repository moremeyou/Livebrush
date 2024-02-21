package com.livebrush.ui
{
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	
	import com.livebrush.data.Settings;
	import com.livebrush.graphics.canvas.Layer;
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UI;
	import com.livebrush.ui.UIView;
	import com.livebrush.ui.UIModel;
	import com.livebrush.ui.UIController;
	import com.livebrush.ui.UIUpdate;
	import com.livebrush.ui.RichList;
	import com.livebrush.events.ListEvent;
	import com.livebrush.data.StateManager;
	
	
	public class LayersController extends UIController
	{
		
		public var selectedLayerIndex				:int;
		
		
		public function LayersController (layersView:LayersView):void
		{
			super(layersView);
			
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function get layersView ():LayersView {   return LayersView(view);  }
		private function get layersList ():RichList {   return layersView.layersList;  }
		private function get panelAsset ():Sprite {   return layersView.panelAsset;  }
		private function get uiAsset ():Object {   return layersView.uiAsset;  }
		
		
		// INIT / SETUP / RESET / DESTROY ///////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		protected override function init ():void
		{
			selectedLayerIndex = 0;
			
			panelAsset.addEventListener(MouseEvent.CLICK, mouseEvent);
			uiAsset.addEventListener(MouseEvent.CLICK, mouseEvent);
			uiAsset.addEventListener(Event.CHANGE, propsChangeEvent);
			layersView.blendInput._list.addEventListener(Event.CHANGE, propsChangeEvent);
			layersList.addEventListener(ListEvent.SELECT, selectEvent);
			layersList.addEventListener(ListEvent.LABEL_CHANGE, listItemChange);
			layersList.addEventListener(MouseEvent.RIGHT_CLICK, rightClick);
			layersView.otherLayerContextMenu.addEventListener(Event.SELECT, contextMenuEvent);
		}
		
		
		// CONTROLLER ACTIONS ///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// EVENT LISTENERS //////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function contextMenuEvent (e:Event):void
		{
			switch (e.target.name)
			{
				case "layerToDeco": canvasManager.layerToDeco(layersList.hoverItem.data.depth, false, false); break;
				case "copyLayerToDeco": canvasManager.layerToDeco(layersList.hoverItem.data.depth, true, false); break;
				case "iLayerToDeco": canvasManager.layerToDeco(layersList.hoverItem.data.depth, false); break;
				case "iCopyLayerToDeco": canvasManager.layerToDeco(layersList.hoverItem.data.depth, true); break;	
			}
		}
		
		private function rightClick (e:MouseEvent):void
		{
			//// // Consol.Trace("right click from LayersController");
			// if (Layer.isBoxLayer(activeLayer)) 
			if (Layer.isBoxLayer(layersList.hoverItem.data as Layer) && Layer.isLineLayer(activeLayer)) 
			{
				layersView.layerContextMenu.display(canvas.stage, canvas.stage.mouseX, canvas.stage.mouseY);
			}
		}
		
		private function selectEvent (e:Event):void
		{
			if (selectedLayerIndex != layersView.layersList.selectedIndex)
			{
				canvasManager.changeLayerSelection(layersView.getSelectedLayerDepths());
				selectedLayerIndex = layersView.layersList.selectedIndex;
			}
		}
		
		private function propsChangeEvent (e:Event):void
		{
			e.stopImmediatePropagation();
			var layerSettings:Settings = new Settings();
			var layer:Layer = layersView.layersList.selectedItem as Layer;
			var depth:int = layer.depth;
			//// // Consol.Trace("Layers Controller: propsChangeEvent: " + layersView.layersList.selectedItem.label);
			
			//if (!Layer.isBackgroundLayer(layer))
			//{
				layerSettings.blendMode = layersView.blendInput.value;
				layerSettings.alpha = Number(layersView.alphaInput.value)/100;
				layerSettings.colorPercent = Number(layersView.tintInput.value)/100;
				layerSettings.label = layersView.layersList.selectedItem.label;
			//}
			
			layerSettings.color = layersView.colorInput.color;

			canvasManager.adjustLayer(layersView.layersList.selectedItem.depth, layerSettings);
			
			
		}
		
		private function listItemChange (e:ListEvent):void
		{
			
			//// // Consol.Trace("Layers Controller: listItemChange");
			propsChangeEvent(e as Event);
			//selectedLayerIndex = layersView.layersList.selectedIndex;
			//// // Consol.Trace("Layers Controller: " + layersView.layersList.selectedItem.depth);
			//canvasManager.editLayerName(layersView.layersList.selectedItem.depth, layersView.layersList.selectedItem.label);
			
			
		}
		
		private function mouseEvent (e:MouseEvent):void
		{
			var name:String = e.target.name;
			
			if (e.target.name == "toggleBtn")
			{
				layersView.toggle();
				ui.uiUpdate();
			}
			else if (e.target.name == "helpBtn")
			{
				//// // Consol.Trace("help from layers");
				_loadHelp();
			}
			else if (name.indexOf("Btn")>-1)
			{
				if (name == "copyBtn" && (layersList.selectedIndex < layersList.length-1))
				{
					canvasManager.dupLayer(canvasManager.activeLayerDepth);
				}
				else if (name == "flatBtn") // need to make sure none of the layers are the background? or do we? we just create a flattened copy don't we?
				{
					ui.confirmActionDialog({message:"This action will clear your undo history.\nThe source layers will remain intact.\nWould you like to continue?",
										   yesFunction:canvasManager.flattenLayers, id:"flattenConfirm"}) // thisScope:canvasManager, 
					//canvasManager.flattenLayers();
				}
				else if (name == "upBtn" && (layersList.selectedIndex > 0 && layersList.selectedIndex < layersList.length-1))
				{
					canvasManager.moveLayer(layersList.selectedItem.depth, 1);
				}
				else if (name == "downBtn" && (layersList.selectedIndex < layersList.length-2))
				{
					canvasManager.moveLayer(layersList.selectedItem.depth, -1);
				}
				else if (name == "removeBtn" && (layersList.selectedIndex < layersList.length-1))
				{
					//canvasManager.remLayer(layersList.selectedItem.depth);
					//StateManager.closeState();
					canvasManager.deleteContent(true);
				}
				else if (name == "addBtn")
				{
					//// Consol.Trace("LayersController: mouseEvent: " + name);
					canvasManager.addBitmapLayer(true);
				}
			}
			
		}
		

		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		

		
		
		
	}
	
}