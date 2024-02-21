package com.livebrush.tools
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.getTimer
	import flash.display.MovieClip;
	
	import com.livebrush.data.Settings;
	import com.livebrush.graphics.canvas.LineLayer;
	import com.livebrush.graphics.canvas.Canvas;
	import com.livebrush.styles.Style;
	import com.livebrush.styles.StyleManager;
	import com.livebrush.graphics.Line;	
	import com.livebrush.graphics.Edge;
	import com.livebrush.geom.Osc;
	import com.livebrush.geom.Counter;
	import com.livebrush.geom.ColorSequence;
	import com.livebrush.styles.LineStyle;	
	import com.livebrush.styles.StrokeStyle;
	import com.livebrush.styles.DecoStyle;	
	import com.livebrush.ui.Consol;
	import com.livebrush.ui.UI;	
	import com.livebrush.styles.DecoAsset;
	import com.livebrush.graphics.Deco;
	import com.livebrush.graphics.canvas.CanvasManager;
	import com.livebrush.graphics.DecoGroup;
	import com.livebrush.data.StateManager;
	
	import com.wacom.Tablet;
	
	
	public class LiveBrush extends EventDispatcher
	{
		public static var idList							:Array = [];

		public static const DRAWING							:String = "drawing";
		public static const FINISHED						:String = "finished";
		public static const FINISHING						:String = "finishing";
		//public static const PAUSED							:String = "paused";
		
		public var id										:int;
		public var state									:String = DRAWING;
		public var style									:Style;
		public var layer									:LineLayer;
		public var line										:Line;
		private var accelPt									:Point;
		private var velPt									:Point;
		public var pos										:Point;
		public var lastPos									:Point;
		public var lastMousePos								:Point;
		public var inPt										:Point;
		public var lastInPt									:Point;
		private var lastAngle								:Number = 0;
		private var counterObjs								:Object;
		private var oscObjs									:Object;
		private var colorSequenceObjs						:Object;
		private var width									:Number;
		private var tSuccess								:String;
		private var lastDecoPt								:Point;
		private var lastDecoTime							:Number;
		private var decoSuccess								:Boolean;
		private var edgeAngle								:Number;
		private var strokeAlpha								:Number;
		private var strokeColor								:Number = -1;
		public var dynamicMove								:Function;
		public var showCursor								:Boolean = true;
		public var cacheBuffer								:int=10; // will be set in settings. or based on stroke type. rake gets 1
		public var cache									:int=0;
		private var _angleRads								:Number = 0;
		//private var _angleList								:Array;
		private var _lastAnglePos							:Point;
		//private var _lastLineLength							:int;
		public var stateIndex								:int;
		private var edge									:Edge;
		private var decoPos									:Object;
		private var forceDeco 								:Boolean = false;
		private var decoKey									:int = 1;
		private var strokeColorHoldCount					:Counter;
		private var decoColorHoldCount						:Counter;
		private var decoHoldCount							:Counter;
		private var decoColor								:Number = -1;
		private var decoIndex								:Number = -1;
		private var pressureWidth							:Number = 0;
		private var pressureAlpha							:Number = 0;
		private var pressureDecoPos							:Number = 0;
		private var pressureDecoScale						:Number = 0;
		private var pressureDecoAlpha						:Number = 0;
		private var pressureDecoTint						:Number = 0;
		private var pressureSpeed							:Number = 0;
		private var pressureLocked							:Boolean = false;
		
		
		// debug
		public var dotMc									:MovieClip
		
		public function LiveBrush (style:Style, layer:LineLayer, pos:Point)
		{
			id = getNewID();
			
			oscObjs = {};
			counterObjs = {};
			colorSequenceObjs = {};
			
			this.style = style;
			this.layer = layer;
			this.pos = pos.clone();
		
			init();
		}
		
		
		// GET/SET PROPS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get x ():Number { return pos.x; }
		public function get y ():Number { return pos.y; }
		public function get vx ():Number { return velPt.x; }
		public function get vy ():Number { return velPt.y; }
		//public function get speed ():Number { return line.length<=2?layer.canvas.speed:Math.sqrt(vx*vx+vy*vy); }
		//public function get angle ():Number { return (line.length<=2?canvasAngleRads:angleRads) * 180 / Math.PI; }
		public function get speed ():Number { return Math.sqrt(vx*vx+vy*vy); }
		public function get angle ():Number { return angleRads * 180 / Math.PI; }
		public function get angleRads ():Number { return _angleRads  }
		public function get canvas ():Canvas {   return layer.canvas;   }
		public function get canvasAngleRads ():Number { return layer.canvas.angleRads;  }
		public function get mousePos ():Point {   return layer.canvas.mousePt;   }
		public function get mouseSpeed ():Number {   return layer.canvas.mouseSpeed;   }
		public function get speedMax ():Number {   return Math.min(speed, lineStyle.maxDrawSpeed);   }
		public function get drawSpeedPercent ():Number {   return (speedMax-lineStyle.minDrawSpeed) / Math.max(1,(lineStyle.maxDrawSpeed-lineStyle.minDrawSpeed));   }
		public function get strokeWidthPercent ():Number {   return  (width-strokeStyle.minWidth) / Math.max(1,(strokeStyle.maxWidth-strokeStyle.minWidth));   }
		public function get strokeStyle ():StrokeStyle {   return style.strokeStyle;   }
		public function get lineStyle ():LineStyle {   return style.lineStyle;   }
		public function get decoStyle ():DecoStyle {   return style.decoStyle;   }
		public function get lastDecoDistance ():Number {   return Point.distance(lastDecoPt, pos);   }
		public function get canvasManager ():CanvasManager {   return layer.canvas.canvasManager;   }
		public function get isDynamic ():Boolean {   return (lineStyle.type==LineStyle.DYNAMIC);   }
		public function get isElastic ():Boolean {   return (lineStyle.type==LineStyle.ELASTIC);   }
		public function get styleManager ():StyleManager {   return style.styleManager;   }
		
		
		// INIT & DESTROY ///////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function init ():void
		{
			//// // Consol.Trace(style)
			setNewLine();
			
			/*velPt = new Point();
			accelPt = new Point ();
			this.pos = pos.clone();
			inPt = pos.clone();
			lastPos = pos.clone();
			lastMousePos = mousePos;
			lastDecoPt = pos.clone();
			lastDecoTime = 0;*/
			
			if (styleManager.colorsLocked) {
				strokeColorHoldCount = new Counter(1, styleManager.lockedColorSettings.colorHold, 1);
			} else {
				strokeColorHoldCount = new Counter(1, strokeStyle.colorHold, 1);
			}
			decoColorHoldCount = new Counter(1, decoStyle.colorHold, 1);
			decoHoldCount = new Counter(1, decoStyle.decoHold, 1);
			
			
			if (isDynamic) 
			{
				try 
				{
					dynamicMove = lineStyle.getDynamicControl().move;
				}
				catch (e:Error)
				{
					dynamicMove = move;
					lineStyle.type = LineStyle.NORMAL;
					lineStyle.inputSWF = "";
				}
				//registerInputComplete();
				//lineStyle.swf.start(pos.clone());
			}

			// debug
			/*if (showCursor) 
			{
				dotMc = new EdgeDeco();
				layer.canvas.addCursor(dotMc);
			}*/
			
		}
		
		public function setNewLine (_pos:Point=null):void
		{
			line = Line.newLine(style.lineStyle.smoothing, strokeStyle.strokeType, strokeStyle.lines, strokeStyle.weight);
			line.changed = true;
			line.style = style;
			layer.line = line;
			
			//_angleList = [];
			velPt = new Point();
			accelPt = new Point ();
			this.pos = (_pos != null) ? _pos.clone() : pos.clone();
			inPt = pos.clone();
			lastPos = pos.clone();
			lastMousePos = mousePos;
			lastDecoPt = pos.clone();
			lastDecoTime = 0;
			_lastAnglePos = pos;
			//_lastLineLength = 0;
		}
		
		public function die ():void
		{
			// kill any osc loops
			
			//Consol.globalOutput(layer);
			//dotMc.parent.removeChild(dotMc);
			//delete this;
		}
		
		
		// BRUSH ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		public function queueFinish ():void
		{
			state = (style.lineStyle.type == LineStyle.NORMAL || (lineStyle.mouseUpComplete && isElastic)) ? FINISHED : FINISHING;
		}
		
		public function move ():Boolean
		{
			var moving:Boolean = false;
			
			//var speed:Number; // = mouseSpeed;
			
			if (state == DRAWING && !lineStyle.lockMouse) inPt = mousePos;
			
			var targetPt:Point = inPt;
			
			if (lineStyle.type == LineStyle.ELASTIC || lineStyle.type == LineStyle.NORMAL || state == FINISHING)
			{
				if ((style.lineStyle.type == LineStyle.ELASTIC || state == FINISHING) && style.lineStyle.elastic > 0)
				{
					accelPt.x = (targetPt.x - pos.x) * style.lineStyle.elastic;
					accelPt.y = (targetPt.y - pos.y) * style.lineStyle.elastic;
					velPt = velPt.add(accelPt);
					velPt.x *= style.lineStyle.friction;
					velPt.y *= style.lineStyle.friction;
				}
				else if ((style.lineStyle.type == LineStyle.ELASTIC || state == FINISHING) && style.lineStyle.friction > 0)
				{
					velPt.x = (targetPt.x - pos.x) * style.lineStyle.friction;
					velPt.y = (targetPt.y - pos.y) * style.lineStyle.friction;
				}
				else // either the first two conditions fail or type==Normal
				{
					velPt.x = (targetPt.x - pos.x);
					velPt.y = (targetPt.y - pos.y);
					//velPt.x = canvas.vx;
					//velPt.y = canvas.vy;
				}
				
				pos = pos.add(velPt);
				
			}
			else if (style.lineStyle.type == LineStyle.DYNAMIC)
			{
				//// // Consol.Trace(style.lineStyle.type);
				try
				{
					pos = dynamicMove(targetPt.clone(), pos.clone()).clone();
					velPt = pos.subtract(lastPos);
				}
				catch (e:Error)
				{
					//// // Consol.Trace("Dynamic Input Function Error: " + e);
					
					//UI.MAIN_UI.alert({message:"<b>Dynamic Input Actionscript Error</b>\n\n<b><a href='http://www.Livebrush.com/help/SWF_Support.html' target='_blank'>Click here</a></b> for Livebrush Help.", id:"inputSWFAlert"});
			
					//velPt.x = (targetPt.x - pos.x);
					//velPt.y = (targetPt.y - pos.y);
					
					lineStyle.type = LineStyle.NORMAL;
					//pos = pos.add(velPt);
					
					move();
				}
			}

			var speed:Number = this.speed;
			//var speed:Number = mouseSpeed;
			//// // Consol.Trace(Canvas.VY);
			if ((speed >= lineStyle.minDrawSpeed) || line.length == 0)
			{
				moving = true;
				
				var angle:Number = Math.atan2(vy, vx);
				//var angle:Number = canvas.angleRads;
				//// // Consol.Trace(speed);
				if (speed > 4 || line.length < 7 || state == FINISHING || style.lineStyle.type == LineStyle.DYNAMIC) //  || slowSpeed > 25//  || Math.abs(angle-lastAngle)>(Math.PI/2)  //  || Math.abs(angle-_angleRads)>4 //  || (_lastLineLength+35)==line.length
				{
					_angleRads = angle;
					_lastAnglePos = pos;
					lastAngle = angle;
					//_lastLineLength = line.length;
				}
				else 
				{
					var slowVX:Number = (pos.x-_lastAnglePos.x);
					var slowVY:Number = (pos.y-_lastAnglePos.y);
					var dist:Number = Point.distance(pos, _lastAnglePos);
					
					if (dist > 10) 
					{
						_angleRads = Math.atan2(slowVY, slowVX);
						_lastAnglePos = pos.clone();
					}
				}

				//// // Consol.Trace(vx + " : " + vy);
				
				line.addEdge(createEdge());

				lastPos = pos.clone();
				
				/*if (showCursor)
				{
					dotMc.x = pos.x;
					dotMc.y = pos.y;
					dotMc.rotation = angle;
				}*/
			}
			
			
			if (speed <= lineStyle.minDrawSpeed && state == FINISHING)
			{
				state = FINISHED;
				moving = false;
			}
			
			return moving;
		}
		
		private function createEdge ():Edge // merge this class with Stroke
		{
			width = getStrokeEdgeWidth();
			
			edgeAngle = getStrokeEdgeAngle();
			strokeAlpha = getStrokeAlpha();
			strokeColor = getStrokeColor();
			
			edge = new Edge (pos.x, pos.y, width, edgeAngle, style.strokeStyle.lines, strokeColor, strokeAlpha, null); //decoGroup
			
			//var decoGroup:DecoGroup = getDecoGroup();
			
			edge.decoGroup = getDecoGroup();
			
			return edge;
			//new Edge (pos.x, pos.y, width, edgeAngle, style.strokeStyle.lines, strokeColor, strokeAlpha, decoGroup); 

			// decorate
		}
		
		public function addDeco (key:int=1):void {
			forceDeco = true;
			if (key == 0) key=10;
			decoKey = key;
		}

		
		// STYLE ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function getDecoGroup ():DecoGroup
		{
			var deco:DecoGroup = null;
			
			if ((strokeStyle.decorate || forceDeco) && line.length > 1)
			{
				
				var t:Object = strokeStyle.thresholds;
				//tSuccess = "";
				decoSuccess = true;
				
				if (t.speed.enabled)
				{
					successCheck(speed >= t.speed.min);
					successCheck(speed <= t.speed.max);
				}
				if (t.width.enabled)
				{
					successCheck(width >= t.width.min);
					successCheck(width <= t.width.max);
				}
				if (t.angle.enabled)
				{
					successCheck(edgeAngle >= t.angle.min);
					successCheck(edgeAngle <= t.angle.max);
				}
				if (t.distance.enabled)
				{
					successCheck(lastDecoDistance >= t.distance.min);
					successCheck(lastDecoDistance <= t.distance.max);
				}
				if (t.random.enabled)
				{
					successCheck(randNum(0, t.random.max, true) == 1);
					//Consol.globalOutput(randNum(0, t.random.max, true));
				}
				if (t.interval.enabled)
				{
					successCheck((getTimer()-lastDecoTime) >= t.interval.min);
					//Consol.globalOutput(t.interval.min);
				}
				//// // Consol.Trace(decoSuccess);
				//// Consol.Trace(forceDeco);
				if (decoSuccess || forceDeco)
				{
					//// Consol.Trace(forceDeco);
					
					
					lastDecoPt = pos.clone();
					lastDecoTime = getTimer();
					
					
					
					//deco = new Deco(getDecoAsset(), getDecoProps());
					
					
					var decoGroup:DecoGroup = new DecoGroup();
					for (var i:int=0; i<decoStyle.decoNum; i++)
					{
						//var decoAsset:DecoAsset = getDecoAsset();
						//if (!CanvasManager.CACHE_DECOS) decoAssetdecoAsset.copy(true);
						decoGroup.addDeco(getDecoAsset(), getDecoProps());
					}
					
					//deco = decoGroup.latest;
					
					counterObj("decoOffsetPos").reset();
					//// // Consol.Trace("LiveBrush: deco props persist = " + decoStyle.persist);
					if (!decoStyle.persist)
					{
						//try {   counterObj("decoOffsetPos").reset();   } catch(e:Error) {}
						try {   oscObj("decoAlpha").reset();   } catch(e:Error) {}
						try {   oscObj("decoTint").reset();   } catch(e:Error) {}
						try {   counterObj("decoAngle").reset();   } catch(e:Error) {}
						try {   oscObj("decoAngle").reset();   } catch(e:Error) {}
						try {   oscObj("decoSize").reset();   } catch(e:Error) {}
						try {   colorSequence("decoColor").reset();   } catch(e:Error) {}
						try {   oscObj("decoPos").reset();   } catch(e:Error) {}
						try {   counterObj("decoPos").reset();   } catch(e:Error) {}
						try {   counterObj("decoSequence").reset();   } catch(e:Error) {}
						try {   decoColorHoldCount.reset();   } catch(e:Error) {}
						try {   decoHoldCount.reset();   } catch(e:Error) {}
						decoColor = -1;
						decoIndex = -1;
					}
					
					forceDeco = false;
					
					// when attaching multiple, and colors and/or alphas are also being adjusted
					// the colors aren't being reset
					// for v1.5 - maybe any and all properties have the option to be oscillated, etc...
					
					// initObj gets passed to deco - where the props are formalized.
					
					//CanvasManager.pushAssetLoadCount(1);
					//Consol.globalOutput(decoAsset.fileName);
				}
			}
			
			return decoGroup;
		}
		
		private function getDecoProps ():Settings
		{
			var initObj:Settings = new Settings ();
			
			var position:Object = decoPos = getDecoPosition();
			var scaleXY:Number = getDecoScale();
			
			decoColor = initObj.color = getDecoColor();
			initObj.colorPercent = getDecoColorPercent();
			//Consol.globalOutput(initObj.color);
			initObj.alpha = getDecoAlpha();
			initObj.angle = getDecoAngle();
			//// // Consol.Trace("LiveBrush: deco angle = " + initObj.angle);
			
			initObj.pos = position.relative;
			initObj.offset = position.offset;

			initObj.scale = {x:scaleXY*(decoStyle.xFlip?-1:1), y:scaleXY*(((position.relative>=.5 && decoStyle.autoFlip) || decoStyle.yFlip)?-1:1)};
			
			initObj.align = decoStyle.alignType;
			
			// pass to swf decos if generate function exists
			initObj.brushState = {x:x, y:y,
								  vx:vx, vy:vy,
								  speed:speed, 
								  angleRads:angleRads, 
								  width:width,
								  edgeAngle:edgeAngle}//,
								  //color:strokeColor,
								 // alpha:strokeAlpha};
								  // strokeWidthPercent
								  // drawSpeedPercent
								  // all styles?
								  // lastDecoDistance
								  // lastDecoDistance
								  // lastDecoTime
								  // lastDecoPt

			
			return initObj;
		}
		
		private function getDecoAlpha ():Number
		{
			var alpha:Number;
			
			switch (decoStyle.alphaType)
			{
				case DecoStyle.FIXED :
					alpha = decoStyle.minAlpha;
					//Consol.globalOutput(alpha);
				break;
				
				case DecoStyle.SPEED :
					alpha = percentOf(drawSpeedPercent, (decoStyle.maxAlpha-decoStyle.minAlpha)) + decoStyle.minAlpha;
					//Consol.globalOutput(alpha);
				break;
				
				case DecoStyle.WIDTH :
					alpha = percentOf(strokeWidthPercent, (decoStyle.maxAlpha-decoStyle.minAlpha)) + decoStyle.minAlpha;
				break;
				
				case DecoStyle.OSC :
					alpha = oscObj("decoAlpha", decoStyle.minAlpha, decoStyle.maxAlpha, decoStyle.alphaSpeed).update().x;
				break;
				
				case DecoStyle.STROKE :
					alpha = strokeAlpha;
				break;
	
				case DecoStyle.RANDOM :
					alpha = randNum(decoStyle.minAlpha, decoStyle.maxAlpha);
				break;
				
				case StrokeStyle.PRESSURE : 
					
						if (Tablet.PRESSURE_STARTED && !pressureLocked) 
						{
							pressureDecoAlpha = alpha = percentOf(Tablet.PRESSURE_PERCENT, (decoStyle.maxAlpha-decoStyle.minAlpha)) + decoStyle.minAlpha
							pressureSpeed = speed;
						}
						else 
						{
							alpha = Math.max(decoStyle.minAlpha, pressureDecoAlpha * (speed / pressureSpeed));
							pressureLocked = true;
						}
					
				break;
				
			}
			
			return alpha;
		}
		
		private function getDecoColorPercent ():Number
		{
			var percent:Number;
			
			switch (decoStyle.tintType)
			{
				case DecoStyle.FIXED :
					percent = decoStyle.minTint;
					//Consol.globalOutput(alpha);
				break;
				
				case DecoStyle.SPEED :
					percent = percentOf(drawSpeedPercent, (decoStyle.maxTint-decoStyle.minTint)) + decoStyle.minTint;
					//Consol.globalOutput(alpha);
				break;
				
				case DecoStyle.WIDTH :
					percent = percentOf(strokeWidthPercent, (decoStyle.maxTint-decoStyle.minTint)) + decoStyle.minTint;
				break;
				
				case DecoStyle.OSC :
					percent = oscObj("decoTint", decoStyle.minTint, decoStyle.maxTint, decoStyle.tintSpeed).update().x;
				break;
				
				case DecoStyle.RANDOM :
					percent = randNum(decoStyle.minTint, decoStyle.maxTint);
				break;
				
				
				case StrokeStyle.PRESSURE : 
					
						if (Tablet.PRESSURE_STARTED && !pressureLocked) 
						{
							pressureDecoTint = percent = percentOf(Tablet.PRESSURE_PERCENT, (decoStyle.maxTint-decoStyle.minTint)) + decoStyle.minTint
							pressureSpeed = speed;
						}
						else 
						{
							percent = Math.max(decoStyle.minTint, pressureDecoTint * (speed / pressureSpeed));
							pressureLocked = true;
						}
					
				break;
				
			}
			
			return percent;
		}
		
		private function getDecoAngle ():Number
		{
			var angle:Number;
			
			switch (decoStyle.angleType)
			{
				case DecoStyle.FIXED :
					angle = decoStyle.minAngle;
				break;
				
				case DecoStyle.WIDTH :
					angle = percentOf(strokeWidthPercent, (decoStyle.maxAngle-decoStyle.minAngle)) + decoStyle.minAngle;
					//Consol.globalOutput(angle);
				break;
				
				case DecoStyle.DIR :
					angle = this.angle + decoStyle.minAngle;
					//Consol.globalOutput(angle);
				break;
				
				case DecoStyle.SPEED :
					angle = percentOf(drawSpeedPercent, (decoStyle.maxAngle-decoStyle.minAngle)) + decoStyle.minAngle;
					//Consol.globalOutput(angle);
				break;
				
				case DecoStyle.OSC :
					angle = oscObj("decoAngle", decoStyle.minAngle, decoStyle.maxAngle, decoStyle.angleSpeed/100).update().x;
					//Consol.globalOutput(angle);
				break;
				
				case DecoStyle.ROTATE :
					//var angleOscObj:Osc = oscObj("decoAngle", decoStyle.minAngle, decoStyle.maxAngle, decoStyle.angleSpeed);
					//angleOscObj.update();
					//angle = angleOscObj.angleDegrees;
					angle = counterObj("decoAngle", decoStyle.minAngle, decoStyle.maxAngle, decoStyle.angleSpeed).count();
					//Consol.globalOutput(angle);
				break;
				
				case DecoStyle.POS_DIR :
					var decoPosPt:Point = edge.midPoint(decoPos.relative);
					var decoOffsetPt:Point = decoPosPt.add(decoPos.offset);
					var dirPt:Point = decoOffsetPt.subtract(decoPosPt);
					var angleRads:Number = Math.atan2(dirPt.y, dirPt.x) + (Math.PI/2);
					angle = angleRads * 180 / Math.PI;
					//Consol.globalOutput("LiveBrush: deco pos dir: " + angle);
				break;
				
				case DecoStyle.RANDOM :
					angle = randNum(decoStyle.minAngle, decoStyle.maxAngle);
					//Consol.globalOutput(angle);
				break;
				
				case DecoStyle.NONE :
					angle = 0;
				break;
			}
			
			return angle;
		}
		
		private function getDecoScale ():Number
		{
			var size:Number;
			
			switch (decoStyle.sizeType)
			{
				case DecoStyle.FIXED :
					size = decoStyle.minSize;
					//Consol.globalOutput(size);
				break;
				
				case DecoStyle.SPEED :
					size = percentOf(drawSpeedPercent, (decoStyle.maxSize-decoStyle.minSize)) + decoStyle.minSize;
					//Consol.globalOutput(size);
				break;
				
				case DecoStyle.WIDTH :
					size = percentOf(strokeWidthPercent, (decoStyle.maxSize-decoStyle.minSize)) + decoStyle.minSize;
				break;
				
				case DecoStyle.OSC :
					size = oscObj("decoSize", decoStyle.minSize, decoStyle.maxSize, decoStyle.sizeSpeed).update().x;
				break;
	
				case DecoStyle.RANDOM :
					size = randNum(decoStyle.minSize, decoStyle.maxSize);
				break;
				
				case DecoStyle.NONE :
					size = 1;
				break;
				
				
				case StrokeStyle.PRESSURE : 
					
						if (Tablet.PRESSURE_STARTED && !pressureLocked) 
						{
							pressureDecoScale = size = percentOf(Tablet.PRESSURE_PERCENT, (decoStyle.maxSize-decoStyle.minSize)) + decoStyle.minSize
							pressureSpeed = speed;
						}
						else 
						{
							size = Math.max(decoStyle.minSize, pressureDecoScale * (speed / pressureSpeed));
							pressureLocked = true;
						}
					
				break;
				
				
			}
			
			return size;
		}
		
		private function getDecoColor ():Number
		{
			var color:Number ;
			
			switch (decoStyle.colorType)
			{
				case DecoStyle.FIXED :
					//// // Consol.Trace(decoStyle.selectedColor);
					color = decoStyle.selectedColor;
				break;
				
				case DecoStyle.LIST :
					//// Consol.Trace(decoColorHoldCount.count() + " == " + decoStyle.colorHold + " : " + decoColor);
					if (decoColorHoldCount.value == decoStyle.colorHold || decoColor==-1) {
						color = colorSequence("decoColor", decoStyle.colorList, decoStyle.colorSteps).nextColor();
						//// Consol.Trace("NEW COLOR: " + color);
					} else {
						color = decoColor;
						//// Consol.Trace("LAST COLOR: " + color);
					}
				break;
				
				case DecoStyle.SPEED :
					if (decoColorHoldCount.count() == decoStyle.colorHold || decoColor==-1) {
						color = colorSequence("decoColor", decoStyle.colorList, decoStyle.colorSteps).interpolate(0,1,drawSpeedPercent);
					} else {
						color = decoColor;
					}
				break;
				
				case DecoStyle.WIDTH :
					if (decoColorHoldCount.count() == decoStyle.colorHold || decoColor==-1) {
						color = colorSequence("decoColor", decoStyle.colorList, decoStyle.colorSteps).interpolate(0,1,strokeWidthPercent);
					} else {
						color = decoColor;
					}
				break;

				case DecoStyle.RANDOM :
					if (decoColorHoldCount.count() == decoStyle.colorHold || decoColor==-1) {
						color = colorSequence("decoColor", decoStyle.colorList, decoStyle.colorSteps).randomColor();
					} else {
						color = decoColor;
					}
				break;
				
				case DecoStyle.STROKE :
					//if (decoColorHoldCount.count() == decoStyle.colorHold || decoColor==-1) {
						color = strokeColor;
					//} else {
						//color = decoColor;
					//}
				break;
				
				case DecoStyle.NONE :
					color = -1;
				break;
			}
			
			return color;
		}
		
		private function getDecoPosition ():Object
		{
			var pos:Number;
			var offset:Point = new Point ();
			var angle:Number;
			
			switch (decoStyle.posType)
			{
				case DecoStyle.FIXED :
					pos = decoStyle.minPos;
				break;
				
				case DecoStyle.RANDOM :
					pos = randNum(decoStyle.minPos, decoStyle.maxPos);
				break;
				
				case DecoStyle.A :
					pos = 0;
				break;
				
				case DecoStyle.B :
					pos = 1;
				break;
				
				case DecoStyle.CENTER :
					pos = .5;
				break;
				
				case DecoStyle.ALT :
					pos = counterObj("decoPos", decoStyle.minPos, decoStyle.maxPos, decoStyle.maxPos-decoStyle.minPos).count();
					// Math.abs(decoStyle.maxPos-decoStyle.minPos)
				break;
				
				case DecoStyle.SPEED :
					pos = percentOf(drawSpeedPercent, (decoStyle.maxPos-decoStyle.minPos)) + decoStyle.minPos;
				break;
				
				case DecoStyle.WIDTH :
					pos = percentOf(strokeWidthPercent, (decoStyle.maxPos-decoStyle.minPos)) + decoStyle.minPos;
				break;
				
				case DecoStyle.OSC :
					pos = oscObj("decoPos", decoStyle.minPos, decoStyle.maxPos, decoStyle.posSpeed).update().x;
				break;
				
				case DecoStyle.SCATTER :
					pos = .5;
					var maxRadius:Number = Math.max(1, decoStyle.maxPos);
					var radius:Number = Math.sqrt(Math.random()) * maxRadius;
					angle = degreesToRadians(decoStyle.minPos) + angleRads + counterObj("decoOffsetPos", 0, Math.PI*2, (Math.PI*2)/decoStyle.decoNum).count();
					//Consol.globalOutput(angle);
					offset.x = Math.cos(angle) * radius; // + decoStyle.minPos;
					offset.y = Math.sin(angle) * radius; // + decoStyle.minPos;
					
					//Consol.globalOutput(offset);
				break;
				
				case DecoStyle.ORBIT :
					pos = .5;
					angle = degreesToRadians(decoStyle.minPos) + angleRads + counterObj("decoOffsetPos", 0, Math.PI*2, (Math.PI*2)/decoStyle.decoNum).count();
					// orbit should not follow the draw direction
					//angle = degreesToRadians(decoStyle.minPos) + counterObj("decoOffsetPos", 0, Math.PI*2, (Math.PI*2)/decoStyle.decoNum).count();
					//Consol.globalOutput(decoStyle.maxPos);
					offset.x = Math.cos(angle) * Math.max(1, decoStyle.maxPos);
					offset.y = Math.sin(angle) * Math.max(1, decoStyle.maxPos);
					
					//Consol.globalOutput(offset);
				break;
				
				case StrokeStyle.PRESSURE : 
					
						if (Tablet.PRESSURE_STARTED && !pressureLocked) 
						{
							pressureDecoPos = pos = percentOf(Tablet.PRESSURE_PERCENT, (decoStyle.maxPos-decoStyle.minPos)) + decoStyle.minPos
							pressureSpeed = speed;
						}
						else 
						{
							pos = Math.max(decoStyle.minPos, pressureDecoPos * (speed / pressureSpeed));
							pressureLocked = true;
						}
					
				break;
				
				
			}
			
			return {relative:pos, offset:offset};
		}
		
		private function getDecoAsset ():DecoAsset
		{
			var decoAsset:DecoAsset;
			
			if (forceDeco) {
				decoIndex = Math.min(decoKey, decoStyle.decoSet.activeLength)-1;
				decoAsset = decoStyle.decoSet.getDecoByIndex(decoIndex);
			} else {
				switch (decoStyle.orderType)
				{
					case DecoStyle.SEQUENCE_DECO :
						if (decoHoldCount.count() == decoStyle.decoHold || decoIndex==-1) {
							decoIndex = counterObj("decoSequence", 0, decoStyle.decoSet.activeLength-1, 1).count()
							decoAsset = decoStyle.decoSet.getActiveDecoByIndex(decoIndex);
						} else {
							decoAsset = decoStyle.decoSet.getActiveDecoByIndex(decoIndex);
						}
					break;
					
					case DecoStyle.FIXED_DECO :
						if (decoHoldCount.count() == decoStyle.decoHold || decoIndex==-1) {
							decoIndex = decoStyle.selectedDecoIndex;
							decoAsset = decoStyle.decoSet.getDecoByIndex(decoIndex);
						} else {
							decoAsset = decoStyle.decoSet.getActiveDecoByIndex(decoIndex);
						}
					break;
					
					case DecoStyle.RANDOM_DECO :
						if (decoHoldCount.count() == decoStyle.decoHold || decoIndex==-1) {
							decoIndex = randNum(0, decoStyle.decoSet.activeLength, true);
							decoAsset = decoStyle.decoSet.getActiveDecoByIndex(decoIndex);
						} else {
							decoAsset = decoStyle.decoSet.getActiveDecoByIndex(decoIndex);
						}
					break;
				}
			}
			
			//Consol.globalOutput(decoAsset.fileName);
			
			return decoAsset;
		}
		
		private function getStrokeAlpha ():Number
		{
			var alpha:Number;// = 0; styleManager.lockedColorSettings.alpha;

			// !styleManager.colorsLocked && 
			if (!styleManager.alphaLocked) {
				
				switch (strokeStyle.alphaType)
				{
					case StrokeStyle.FIXED :
						alpha = strokeStyle.minAlpha;
					break;
					
					case StrokeStyle.SPEED :
						alpha = percentOf(drawSpeedPercent, (strokeStyle.maxAlpha-strokeStyle.minAlpha)) + strokeStyle.minAlpha;
						//Consol.globalOutput(alpha);
					break;
					
					case StrokeStyle.WIDTH :
						alpha = percentOf(strokeWidthPercent, (strokeStyle.maxAlpha-strokeStyle.minAlpha)) + strokeStyle.minAlpha;
					break;
					
					case StrokeStyle.OSC :
						alpha = oscObj("strokeAlpha", strokeStyle.minAlpha, strokeStyle.maxAlpha, strokeStyle.alphaSpeed).update().x;
					break;
		
					case StrokeStyle.RANDOM :
						alpha = randNum(strokeStyle.minAlpha, strokeStyle.maxAlpha);
					break;
					
					case StrokeStyle.NONE :
						alpha = 0;
					break;
					
					case StrokeStyle.PRESSURE : 
					
						if (Tablet.PRESSURE_STARTED && !pressureLocked) 
						{
							pressureAlpha = alpha = percentOf(Tablet.PRESSURE_PERCENT, (strokeStyle.maxAlpha-strokeStyle.minAlpha)) + strokeStyle.minAlpha
							pressureSpeed = speed;
						}
						else 
						{
							alpha = Math.max(strokeStyle.minAlpha, pressureAlpha * (speed / pressureSpeed));
							pressureLocked = true;
						}
					
					break;
					
				}
			} else {
				alpha = styleManager.lockedColorSettings.alpha;
			}
			
			//// Consol.Trace("Livebrush: strokeAlpha = " + alpha);
			
			return alpha;
		}
		
		private function getStrokeColor ():uint
		{
			var color:Number;
			var colorHold:int;
			var colorSteps:int;
			var colorList:Array;
			var colorType:String;
			var selectedColor:Number;
			var settings:Settings;

			if (styleManager.colorsLocked) {
				settings = styleManager.lockedColorSettings;
				colorHold = settings.colorHold;
				colorSteps = settings.colorSteps;
				colorList = settings.colorList;
				colorType = settings.colorType;
				selectedColor = settings.color;
			} else {
				colorHold = strokeStyle.colorHold;
				colorSteps = strokeStyle.colorSteps;
				colorList = strokeStyle.colorList;
				colorType = strokeStyle.colorType;
				selectedColor = strokeStyle.selectedColor;
			}
				
			switch (colorType)
			{
				case StrokeStyle.FIXED :
					color = selectedColor; //hexColor;
				break;
				
				case StrokeStyle.LIST :
					if (strokeColorHoldCount.count() == colorHold || strokeColor==-1) {
						color = colorSequence("strokeColor", colorList, colorSteps).nextColor();
					} else {
						color = strokeColor;
					}
				break;
				
				case StrokeStyle.SPEED :
					if (strokeColorHoldCount.count() == colorHold || strokeColor==-1) {
						color = colorSequence("strokeColor", colorList, colorSteps).interpolate(0,1,drawSpeedPercent);
					} else {
						color = strokeColor;
					}
				break;
				
				case StrokeStyle.WIDTH :
					if (strokeColorHoldCount.count() == colorHold || strokeColor==-1) {
						color = colorSequence("strokeColor", colorList, colorSteps).interpolate(0,1,strokeWidthPercent);
					} else {
						color = strokeColor;
					}
				break;

				case StrokeStyle.RANDOM :
					if (strokeColorHoldCount.count() == colorHold || strokeColor==-1) {
						color = colorSequence("strokeColor", colorList, colorSteps).randomColor();
					} else {
						color = strokeColor;
					}
				break;
				
				case StrokeStyle.SAMPLE :
					if (strokeColorHoldCount.count() == colorHold || strokeColor==-1) {
						color = layer.canvas.getMouseColor();
					} else {
						color = strokeColor;
					}
				break;
				
				case StrokeStyle.SAMPLE_BRUSH :
					strokeColorHoldCount.count()
					//// Consol.Trace (strokeColorHoldCount.value + " : " + colorHold);
					if (strokeColorHoldCount.value == colorHold || strokeColor==-1) {
						color = layer.canvas.getColorAt(x, y);
					} else {
						color = strokeColor;
					}
				break;
				
				case StrokeStyle.NONE :
					color = 0x00000000;
				break;
			}
				
			/*switch (strokeStyle.colorType)
			{
				case StrokeStyle.FIXED :
					color = strokeStyle.selectedColor; //hexColor;
				break;
				
				case StrokeStyle.LIST :
					if (strokeColorHoldCount.count() == strokeStyle.colorHold || strokeColor==-1) {
						color = colorSequence("strokeColor", strokeStyle.colorList, strokeStyle.colorSteps).nextColor();
					} else {
						color = strokeColor;
					}
				break;
				
				case StrokeStyle.SPEED :
					if (strokeColorHoldCount.count() == strokeStyle.colorHold || strokeColor==-1) {
						color = colorSequence("strokeColor", strokeStyle.colorList, strokeStyle.colorSteps).interpolate(0,1,drawSpeedPercent);
					} else {
						color = strokeColor;
					}
				break;
				
				case StrokeStyle.WIDTH :
					if (strokeColorHoldCount.count() == strokeStyle.colorHold || strokeColor==-1) {
						color = colorSequence("strokeColor", strokeStyle.colorList, strokeStyle.colorSteps).interpolate(0,1,strokeWidthPercent);
					} else {
						color = strokeColor;
					}
				break;

				case StrokeStyle.RANDOM :
					if (strokeColorHoldCount.count() == strokeStyle.colorHold || strokeColor==-1) {
						color = colorSequence("strokeColor", strokeStyle.colorList, strokeStyle.colorSteps).randomColor();
					} else {
						color = strokeColor;
					}
				break;
				
				case StrokeStyle.SAMPLE :
					if (strokeColorHoldCount.count() == strokeStyle.colorHold || strokeColor==-1) {
						color = layer.canvas.getMouseColor();
					} else {
						color = strokeColor;
					}
				break;
				
				case StrokeStyle.SAMPLE_BRUSH :
					strokeColorHoldCount.count()
					//// Consol.Trace (strokeColorHoldCount.value + " : " + strokeStyle.colorHold);
					if (strokeColorHoldCount.value == strokeStyle.colorHold || strokeColor==-1) {
						color = layer.canvas.getColorAt(x, y);
					} else {
						color = strokeColor;
					}
				break;
				
				case StrokeStyle.NONE :
					color = 0x00000000;
				break;
			}*/
			
			//// Consol.Trace("Livebrush: strokeColor = " + color);
			
			return color;
		}
		
		private function getStrokeEdgeAngle ():Number
		{
			var angle:Number;
			//if (line.length==0) Consol.globalOutput(this.angle);
			switch (strokeStyle.angleType)
			{
				case StrokeStyle.FIXED :
					angle = strokeStyle.minAngle;
				break;
				
				case StrokeStyle.WIDTH :
					angle = percentOf(strokeWidthPercent, (strokeStyle.maxAngle-strokeStyle.minAngle)) + strokeStyle.minAngle;
					//Consol.globalOutput(angle);
				break;
				
				case StrokeStyle.DIR :
					angle = this.angle + strokeStyle.minAngle;
					//Consol.globalOutput(angle);
				break;
				
				case StrokeStyle.SPEED :
					angle = percentOf(drawSpeedPercent, (strokeStyle.maxAngle-strokeStyle.minAngle)) + strokeStyle.minAngle;
					//Consol.globalOutput(angle);
				break;
				
				case StrokeStyle.OSC :
					angle = oscObj("strokeAngle", strokeStyle.minAngle, strokeStyle.maxAngle, strokeStyle.angleSpeed/100).update().x;
					//Consol.globalOutput(angle);
				break;
				
				case StrokeStyle.ROTATE :
					//var angleOscObj:Osc = oscObj("strokeAngle", strokeStyle.minAngle, strokeStyle.maxAngle, strokeStyle.angleSpeed);
					//angleOscObj.update();
					//angle = angleOscObj.angleDegrees;
					angle = counterObj("edgeAngle", strokeStyle.minAngle, strokeStyle.maxAngle, strokeStyle.angleSpeed).count()
					//Consol.globalOutput(angle);
				break;
				
				case StrokeStyle.RANDOM :
					angle = randNum(strokeStyle.minAngle, strokeStyle.maxAngle);
					//Consol.globalOutput(angle);
				break;
			}
			
			return angle;
		}
		
		private function getStrokeEdgeWidth ():Number
		{
			var width:Number;
			
			if (strokeStyle.widthType == StrokeStyle.FIXED)
			{
				width = style.strokeStyle.minWidth;
			}
			else if (strokeStyle.widthType == StrokeStyle.SPEED)// || (strokeStyle.widthType == StrokeStyle.PRESSURE && !Tablet.PRESSURE_STARTED)) 
			{
				width = percentOf(drawSpeedPercent, (strokeStyle.maxWidth-strokeStyle.minWidth)) + strokeStyle.minWidth;
			}
			else if (strokeStyle.widthType == StrokeStyle.OSC) 
			{
				width = oscObj("strokeWidth", strokeStyle.minWidth, strokeStyle.maxWidth, strokeStyle.widthSpeed).update().x;
			}
			else if (strokeStyle.widthType == StrokeStyle.RANDOM) 
			{
				width = randNum(strokeStyle.minWidth, strokeStyle.maxWidth);
			}
			else if (strokeStyle.widthType == StrokeStyle.PRESSURE) 
			{
				if (Tablet.PRESSURE_STARTED && !pressureLocked) 
				{
					pressureWidth = width = percentOf(Tablet.PRESSURE_PERCENT, (strokeStyle.maxWidth-strokeStyle.minWidth)) + strokeStyle.minWidth
					pressureSpeed = speed;
				}
				else 
				{
					width = Math.max(strokeStyle.minWidth, pressureWidth * (speed / pressureSpeed));
					pressureLocked = true;
				}
			}

			return width;
		}
		
		
		// EVENT ACTIONS ////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/*private function inputComplete (e:Event):void
		{
			lineStyle.removeEventListener(Event.COMPLETE, inputComplete); 
			queueFinish();
		}*/
		
		
		// UTILS ////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		private function successCheck (condition:Boolean):Boolean
		{
			decoSuccess = decoSuccess ? condition : false;
			return condition;
		}
		
		private function degreesToRadians (degrees:Number):Number
		{
			return degrees * Math.PI / 180;
		}
		
		private function oscObj (id:String, center:Number=.5, range:Number=50, speed:Number=10):Osc
		{
			if (oscObjs[id] == null) 
			{
				var realRange:Number = range-center
				range = (realRange/2);
				center = range+center;
				oscObjs[id] = new Osc (center, center, range, range, speed);
				//Consol.globalOutput(center + " : " + range + " : " + speed);
			}
			return oscObjs[id];
		}
		
		private function counterObj (id:String, start:Number=1, end:Number=2, speed:Number=1):Counter
		{
			if (counterObjs[id] == null) 
			{
				counterObjs[id] = new Counter (start, end, speed);
				//Consol.globalOutput(start + " : " + end + " : " + speed);
			}
			return counterObjs[id];
		}
		
		private function colorSequence (id:String, colorList:Array=null, strokeColorSteps:int=1):ColorSequence
		{
			if (colorSequenceObjs[id] == null) colorSequenceObjs[id] = new ColorSequence (colorList, strokeColorSteps);
			return colorSequenceObjs[id];
		}
	
		private function percentOf (percent:Number, value:Number):Number
		{
			return (value * percent);
		}
		
		private function randNum (min:Number, max:Number, floor:Boolean=false):Number
		{
			var rand:Number = min + (Math.random() * max);
			rand = floor ? Math.floor(rand) : rand;
			return rand;
		}
		
		public static function getNewID ():int
		{
			var highestID:int = 0;
			var newID:int;
			for (var i:int=0; i<idList.length; i++)
			{
				if (idList[i] >= highestID) highestID = idList[i];
			}
			newID = highestID+1;
			idList.push(newID);
			return newID;
		}
		
	}
}