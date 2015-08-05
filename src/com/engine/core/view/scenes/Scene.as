package com.engine.core.view.scenes
{
	import com.engine.core.AvatarUnitTypes;
	import com.engine.core.Engine;
	import com.engine.core.RecoverUtils;
	import com.engine.core.model.map.SquareMapData;
	import com.engine.core.tile.square.SquareGroup;
	import com.engine.core.view.DisplaySprite;
	import com.engine.core.view.avatar.Avatar;
	import com.engine.core.view.avatar.AvatarAssetManager;
	import com.engine.core.view.avatar.AvatarManager;
	import com.engine.core.view.items.InstancePool;
	import com.engine.core.view.quadTree.NodeTree;
	import com.engine.core.view.role.Char;
	import com.engine.core.view.role.MainChar;
	import com.engine.core.view.world.MapLayer;
	import com.engine.interfaces.display.IAvatar;
	import com.engine.interfaces.display.IInteractiveObject;
	import com.engine.interfaces.display.IScene;
	import com.engine.interfaces.display.ISceneItem;
	import com.engine.namespaces.coder;
	import com.engine.utils.FPSUtils;
	import com.engine.utils.Hash;
	import com.engine.utils.SuperKey;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class Scene extends DisplaySprite implements IScene
	{

		public static var scene:Scene;
		public static var clickEnbeled:Boolean = true;
		public static var isDepthChange:Boolean;
		
		public static var stageRect:Rectangle = new Rectangle();
		public static var stagePoint:Point = new Point();

		public var $topLayer:Sprite;
		public var $middleLayer:Sprite;
		public var $bottomLayer:Sprite;
		public var $itemLayer:Sprite;
		public var $mapLayer:MapLayer;
		
		public var mouseDownPoint:Point;
		public var mapData:SquareMapData;
		public var isReady:Boolean = false;
		public var onSceneReadyFunc:Function;
		
		protected var $mainChar:MainChar;
		protected var $nodeTree:NodeTree;
		protected var stageIntersectsHash:Hash;
		protected var charWalkTime:int;
		protected var isMouseDown:Boolean = false;
		protected var mouseDownTime:int = 0;
		
		protected var _shiftKey:Boolean;
		private var _container:DisplayObjectContainer;
		private var _selectAvatar:Avatar;
		private var _depthTime:int;
		private var _durTime:int;

		public function Scene()
		{
			super();
			this.mouseDownPoint = new Point();
			this.stageIntersectsHash = new Hash();
			Scene.scene = this;
			this.init();
		}

		override protected function init():void
		{
			super.init();
			this.drawShadow();
			
			this.$nodeTree = new NodeTree(Engine.SCENE_ITEM_NODER);
			this.$nodeTree.build(new Rectangle(0, 0, 15000, 15000), 80);
			
			this.mouseChildren = this.mouseEnabled = false;
			this.tabChildren = this.tabEnabled = false;
			
			this.$topLayer = new Sprite();
			this.$topLayer.name = SceneConst.TOP_LAYER;
			this.$topLayer.mouseEnabled = this.$topLayer.mouseChildren = false;
			this.$topLayer.tabChildren = this.$topLayer.tabEnabled = false;
			
			this.$middleLayer = new Sprite();
			this.$middleLayer.name = SceneConst.MIDDLE_LAYER;
			this.$middleLayer.mouseEnabled = this.$middleLayer.mouseChildren = false;
			this.$middleLayer.tabChildren = this.$middleLayer.tabEnabled = false;
			
			this.$bottomLayer = new Sprite();
			this.$bottomLayer.name = SceneConst.BOTTOM_LAYER;
			this.$bottomLayer.mouseEnabled = this.$bottomLayer.mouseChildren = false;
			this.$bottomLayer.tabChildren = this.$bottomLayer.tabEnabled = false;
			
			this.$itemLayer = new Sprite();
			this.$itemLayer.name = SceneConst.ITEM_LAYER;
			this.$itemLayer.mouseChildren = this.$itemLayer.mouseEnabled = false;
			this.$itemLayer.tabChildren = this.$itemLayer.tabEnabled = false;
			
			this.addChild(this.$bottomLayer);
			this.addChild(this.$itemLayer);
			this.addChild(this.$middleLayer);
			this.addChild(this.$topLayer);
			
			this.$mapLayer = new MapLayer();
			this.$mapLayer.name = SceneConst.MAP_LAYER;
			
			this.$mainChar = new MainChar();
			this.$mainChar.showBodyShoadw(true);
			this.addItem(this.$mainChar, SceneConst.MIDDLE_LAYER);
		}

		public function setup(container:DisplayObjectContainer):void
		{
			_container = container;
			_container.addChildAt(this.$mapLayer, 0);
			_container.addChildAt(this, 1);
			
			this.stage.addEventListener("rightMouseDown", _EngineMouseRightDownFunc_);
			this.stage.addEventListener("rightMouseUp", _EngineMouseRightUpFunc_);
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, _EngineMouseDownFunc_);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, _EngineMouseUpFunc_);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, _EngineKeyDownFunc_);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, _EngineKeyUpFunc_);
			this.stage.addEventListener(Event.ENTER_FRAME, _EngineEnterFrameFunc_);
			
			SuperKey.getInstance().addEventListener(SuperKey.DEBUG, _saiman_debug_);
			SuperKey.getInstance().addEventListener(SuperKey.GM, _saiman_GM_);
			
			var timer:Timer = new Timer(0);
			timer.addEventListener(TimerEvent.TIMER, enterFrameFunc);
			timer.start();
		}

		public function updateMainChar(modelId:String, weaponId:String=null, mountId:String=null, wingId:String=null):void
		{
			this.updateCharAvatarPart($mainChar, modelId, weaponId, mountId, wingId);
		}

		public function updateCharAvatarPart(char:Char, modelId:String, weaponId:String=null, mountId:String=null, wingId:String=null):void
		{
			if (char) {
				if (mountId) {
					char.hp_height = 120;
				} else {
					char.hp_height = 150;
				}
				char.loadAvatarPart(AvatarUnitTypes.BODY_TYPE, modelId);
				char.loadAvatarPart(AvatarUnitTypes.WEAPON_TYPE, weaponId);
				char.loadAvatarPart(AvatarUnitTypes.FLY_TYPE, wingId);
				char.loadAvatarPart(AvatarUnitTypes.MOUNT_TYPE, mountId);
				char.avatarParts.bodyRender(true);
				this.addItem(char, SceneConst.MIDDLE_LAYER);
			}
		}

		public function setupReady():void
		{
			this.isReady = true;
			this.mapData = $mapLayer.mapData;
			var char:Char = null;
			var idx:int = 0;
			while (idx < $middleLayer.numChildren) {
				char = $middleLayer.getChildAt(idx) as Char;
				if (char) {
					char.updateAlpha();
				}
				idx++;
			}
			if (this.onSceneReadyFunc != null) {
				this.onSceneReadyFunc();
			}
		}
		
		public function miniMapReady(bmd:BitmapData):void
		{
		}

		public function changeScene(scene_id:String):void
		{
			SquareGroup.getInstance().unload();
			SquareGroup.getInstance().reset(null);
			AvatarManager.coder::getInstance().clean();
			AvatarAssetManager.getInstance().clean();
			InstancePool.coder::getInstance().reset();
			this.clean();
			this.$mapLayer.changeScene(scene_id);
			this.isReady = false;
		}

		public function find(area:Rectangle, exact:Boolean, definition:int=100):Array
		{
			return this.$nodeTree.find(area, exact, definition);
		}

		public function addItem(sceneItem:ISceneItem, layerName:String):void
		{
			if (sceneItem == null || sceneItem.char_id == null) {
				log("saiman", "char_id属性不能为null!");
			}
			
			sceneItem.layer = layerName;
			switch (layerName) {
				case SceneConst.TOP_LAYER:
					this.$topLayer.addChild(sceneItem as DisplayObject);
					break;
				case SceneConst.MIDDLE_LAYER:
					this.$middleLayer.addChild(sceneItem as DisplayObject);
					break;
				case SceneConst.BOTTOM_LAYER:
					this.$bottomLayer.addChild(sceneItem as DisplayObject);
					break;
				case SceneConst.ITEM_LAYER:
					this.$itemLayer.addChild(sceneItem as DisplayObject);
					break;
			}
		}
		
		public function removeItem(sceneItem:ISceneItem):void
		{
		}
		
		public function takeItem(char_id:String):ISceneItem
		{
			return null;
		}

		protected function _EngineKeyDownFunc_(evt:KeyboardEvent):void
		{
			_shiftKey = evt.shiftKey;
			Engine.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this._EngineKeyDownFunc_);
			Engine.stage.addEventListener(KeyboardEvent.KEY_DOWN, this._EngineKeyDownFunc_);
		}

		protected function _EngineKeyUpFunc_(evt:KeyboardEvent):void
		{
			_shiftKey = evt.shiftKey;
			Engine.stage.removeEventListener(KeyboardEvent.KEY_UP, this._EngineKeyUpFunc_);
			Engine.stage.addEventListener(KeyboardEvent.KEY_UP, this._EngineKeyUpFunc_);
		}
		
		protected function _saiman_GM_(evt:Event):void
		{
		}
		
		protected function _saiman_debug_(evt:Event):void
		{
		}

		protected function _EngineMouseRightDownFunc_(evt:MouseEvent):void
		{
		}
		
		protected function _EngineMouseRightUpFunc_(evt:MouseEvent):void
		{
		}
		
		protected function _EngineMouseDownFunc_(evt:MouseEvent):void
		{
		}

		protected function _EngineMouseUpFunc_(evt:MouseEvent):void
		{
		}
		
		protected function _EngineEnterFrameFunc_(evt:Event):void
		{
			if (!this.isReady) {
				return;
			}
			var gPoint:Point = this.globalToLocal(Scene.stagePoint);
			Scene.stageRect.setTo(gPoint.x, gPoint.y, this.stage.stageWidth, this.stage.stageHeight);
			this.charQueueMove();
			var passTime:int = 300;
			if ($mainChar.runing) {
				passTime = 500;
			}
			if (FPSUtils.fps < 10) {
				passTime = 2000;
			}
			if (getTimer() - _depthTime > passTime && FPSUtils.fps > 5) {
				_depthTime = getTimer();
				this.autoDepth();
			}
		}
		
		private function charQueueMove():void
		{
			if (getTimer()-_durTime < 15) {
				return;
			}
			_durTime = getTimer();
			
			var display:IInteractiveObject = null;
			var idx:int = $middleLayer.numChildren - 1;
			while (idx >= 0) {
				display = $middleLayer.getChildAt(idx) as IInteractiveObject;
				if (display && display != $mainChar) {
					display.loopMove();
					if (display as Char) {
						Char(display).loop();
					}
				}
				idx--;
			}
			
			idx = $itemLayer.numChildren - 1;
			while (idx >= 0) {
				display = $itemLayer.getChildAt(idx) as IInteractiveObject;
				if (display) {
					display.loopMove();
					if (display as Char) {
						Char(display).loop();
					}
				}
				idx--;
			}
		}
		
		public function get mainChar():MainChar
		{
			return $mainChar;
		}
		
		public function get shiftKey():Boolean
		{
			return _shiftKey;
		}
		
		public function get selectAvatar():Avatar
		{
			return _selectAvatar;
		}
		public function set selectAvatar(target:Avatar):void
		{
			_selectAvatar = target;
		}

		public function sceneMoveTo(px:Number, py:Number):void
		{
			var focusP:Point = this.getCameraFocusTo(x, y);
			this.scenedMove(new Point(this.x, this.y), focusP);
		}

		public function sceneMoveTo2(px:Number, py:Number):void
		{
			var pt_focus:Point = this.getCameraFocusPoint(px, py);
			var pt_curr:Point = new Point(this.x, this.y);
			this.scenedMove(pt_focus, pt_focus);
		}

		protected function scenedMove(pt_from:Point, pt_to:Point):void
		{
			var dis:Number = Point.distance(pt_from, pt_to);
			if (dis > 0) {
				this.x = this.$mapLayer.x = pt_to.x >> 0;
				this.y = this.$mapLayer.y = pt_to.y >> 0;
			}
		}

		/** 场景目标（不带偏移） */
		public function getCameraFocusTo(px:Number, py:Number):Point
		{
			var fx:Number;
			var fy:Number;
			var stageW:int = Engine.stage.stageWidth;
			var stageH:int = Engine.stage.stageHeight;
			var mapW:int = 4000;
			var mapH:int = 4000;
			if (this.mapData && this.mapData.width > 0 && this.mapData.height > 0) {
				mapW = this.mapData.width;
				mapH = this.mapData.height;
			}
			var centerX:Number = stageW / 2;
			var centerY:Number = stageH / 2;
			if ((px>=centerX) && (px<=mapW-centerX)) {	// 地图之间
				fx = centerX - px;
			} else {	//　地图两端
				if (px <= centerX) {
					fx = 0;
				} else {
					fx = stageW - mapW;
				}
			}
			if ((py>=centerY) && (py <= mapH-centerY)) {	// 地图之间
				fy = centerY - py;
			} else {	//　地图两端
				if (py <= centerY) {
					fy = 0;
				} else {
					fy = stageH - mapH;
				}
			}
			return new Point(fx, fy);
		}

		/** 场景目标（带偏移） */
		public function getCameraFocusPoint(px:Number, py:Number):Point
		{
			var fx:Number;
			var fy:Number;
			var stageW:int = Engine.stage.stageWidth;
			var stageH:int = Engine.stage.stageHeight;
			var mapPW:int = 4000;
			var mapPH:int = 4000;
			if (this.mapData && this.mapData.width > 0 && this.mapData.height > 0) {
				mapPW = this.mapData.pixel_width;
				mapPH = this.mapData.pixel_height;
			}
			var p:Point = new Point();
			p.x = px;
			p.y = py;
			var gp:Point = this.localToGlobal(p);
			var centerX:Number = stageW / 2;
			var centerY:Number = stageH / 2;
			p.x = centerX;
			p.y = centerY;
			var dis:int = Point.distance(p, gp);
			
			var size:int = 70;	// 中心点偏移值
			var dis_:int = size;
			var scale:Number = scaleX;
			var dx:Number = gp.x - centerX;
			var dy:Number = gp.y - centerY;
			var angle:Number = Number(Math.atan2(dy, dx).toFixed(2));
			gp.x = Number((centerX + Math.cos(angle) * size * scale).toFixed(2));
			gp.y = Number((centerY + Math.sin(angle) * size * scale).toFixed(2));
			var dW:Number = stageW - mapPW;
			var dH:Number = stageH - mapPH;
			if (px >= (centerX+size) && px <= (mapPW-centerX-size)) {
				if (dis >= (dis_*scale)) {
					fx = gp.x - px;
					if (fx > 0) {
						fx = 0;
					}
					if (fx < dW) {
						fx = dW;
					}
				}
			} else {
				if (px <= (centerX+size)) {
					fx = gp.x - px;
					if (fx > 0) {
						fx = 0;
					}
				} else {
					fx = gp.x - px;
					if (fx < dW) {
						fx = dW;
					}
				}
			}
			if (py >= (centerY+size) && py <= (mapPH-centerY-size)) {
				if (dis >= (dis_*scale)) {
					fy = gp.y - py;
					if (fy > 0) {
						fy = 0;
					}
					if (fy < dH) {
						fy = dH;
					}
				}
			} else {
				if (py <= (centerY+size)) {
					fy = gp.y - py;
					if (fy > 0) {
						fy = 0;
					}
				} else {
					fy = gp.y - py;
					if (fy < dH) {
						fy = dH;
					}
				}
			}
			return new Point(fx, fy);
		}

		protected function enterFrameFunc(evt:Event):void
		{
			$mainChar.loopMove();
			$mainChar.loop();
			this.sceneMoveTo($mainChar.x, $mainChar.y);
		}

		public function clean():void
		{
			var char:DisplayObject = null;
			var displayQueue:Array = [$middleLayer, $itemLayer, $bottomLayer, $topLayer];
			for each (var tarx:Sprite in displayQueue) {
				var i:int = tarx.numChildren - 1;
				while (i >= 0) {
					char = tarx.removeChildAt(i);
					if (char as IAvatar && char != $mainChar) {
						IAvatar(char).dispose();
					}
					i--;
				}
			}
			
			this.addItem($mainChar, $mainChar.layer);
		}

		private function autoDepth():void
		{
			if (!this.isReady || !Scene.isDepthChange) {
				return;
			}
			Scene.isDepthChange = false;
			
			this.stageIntersectsHash.reset();
			var array:Array = [];
			var item:ISceneItem = null;
			var i:int = $middleLayer.numChildren - 1;
			while (i >= 0) {
				item = $middleLayer.getChildAt(i) as ISceneItem;
				if (item) {
					if (item.stageIntersects) {
						if (stageIntersectsHash[item.char_id] == null) {
							stageIntersectsHash[item.char_id] = item;
							array.push(item);
						}
					} else {
						this.$middleLayer.removeChild(item as DisplayObject);
					}
				}
				i--;
			}
			
			array.sortOn(["y", "type"], [Array.NUMERIC, Array.NUMERIC]);
			var len:int = array.length;
			var k:int = 0;
			while (k < len) {
				item = array[k];
				if (k < this.$middleLayer.numChildren) {
					this.$middleLayer.addChildAt(item as DisplayObject, k);
				} else {
					this.$middleLayer.addChild(item as DisplayObject);
				}
				k++;
			}
		}

		private function drawShadow():void
		{
			if (Engine.char_shadow == null) {
				var w:Array = [30, 80, 120];
				var h:Array = [20, 30, 50];
				var bw:Array = [60, 120, 150];
				var bh:Array = [40, 40, 60];
				var tx:Array = [15, 15, 15];
				var ty:Array = [5, 2, 2];
				var shape:Shape = new Shape();
				
				var rect:Rectangle = null;
				var bmd:BitmapData = null;
				var mat:Matrix = null;
				var index:int = 0;
				while (index < w.length) {
					shape.graphics.clear();
					shape.graphics.beginGradientFill(GradientType.LINEAR, [0, 0, 0, 0], [0.9, 0.8, 0.7, 0.6], [1, 1, 1, 1]);
					shape.graphics.drawEllipse(0, 0, w[index], h[index]);
					shape.filters = [new BlurFilter(20, 10)];
					
					rect = shape.getBounds(shape);
					bmd = new BitmapData(bw[index], bh[index], true, 0);
					mat = RecoverUtils.matrix;
					mat.tx = tx[index];
					mat.ty = ty[index];
					bmd.draw(shape, mat);
					Engine.char_shadow_arr.push(bmd);
					index++;
				}
				Engine.char_shadow = Engine.char_shadow_arr[0];
			}
		}
		
	}
}
