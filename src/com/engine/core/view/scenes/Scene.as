package com.engine.core.view.scenes
{
	import com.engine.core.AvatarTypes;
	import com.engine.core.Engine;
	import com.engine.core.RecoverUtils;
	import com.engine.core.controls.wealth.WealthPool;
	import com.engine.core.controls.wealth.loader.DisplayLoader;
	import com.engine.core.model.map.SquareMapData;
	import com.engine.core.tile.square.SquareGroup;
	import com.engine.core.view.BaseSprite;
	import com.engine.core.view.items.HeadShowShape;
	import com.engine.core.view.items.IItem;
	import com.engine.core.view.items.InstancePool;
	import com.engine.core.view.avatar.Avatar;
	import com.engine.core.view.avatar.AvatarAssetManager;
	import com.engine.core.view.avatar.AvatarManager;
	import com.engine.core.view.avatar.AvatartParts;
	import com.engine.core.view.avatar.HeadShape;
	import com.engine.core.view.avatar.IAvatar;
	import com.engine.core.view.avatar.ItemAvatar;
	import com.engine.core.view.avatar.ShoawdBitmap;
	import com.engine.core.view.quadTree.INoder;
	import com.engine.core.view.quadTree.NodeTree;
	import com.engine.core.view.role.Char;
	import com.engine.core.view.role.MainChar;
	import com.engine.core.view.world.MapLayer;
	import com.engine.namespaces.coder;
	import com.engine.utils.DisplayObjectUtil;
	import com.engine.utils.Hash;
	import com.engine.utils.HitTest;
	import com.engine.utils.SuperKey;
	import com.greensock.TweenLite;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class Scene extends BaseSprite 
	{

		public static var scene:Scene;
		public static var clickEnbeled:Boolean = true;

		public var $topLayer:Sprite;
		public var $middleLayer:Sprite;
		public var $mapLayer:MapLayer;
		public var $itemLayer:Sprite;
		public var $flyLayer:Sprite;
		public var $cloudLayer:Shape;
		
		public var mouseDownPoint:Point;
		public var mapData:SquareMapData;
		public var changing:Boolean = false;
		public var isReady:Boolean = false;
		public var lockSceneMove:Boolean;
		public var onSceneReadyFunc:Function;
		public var shadowShape:Shape;
		
		protected var $nodeTree:NodeTree;
		protected var _shiftKey:Boolean;
		protected var _flying:Boolean = false;
		protected var _mainChar:MainChar;
		protected var charWalkTime:int;
		protected var stop:Boolean;
		protected var isMouseDown:Boolean = false;
		protected var avatarHash:Hash;
		protected var maskShape:Sprite;
		protected var shoawdBitmapArray:Array;
		protected var mouseDownTime:int = 0;
		protected var overAvatar:IAvatar;
		protected var headArray:Dictionary;
		
		private var _sceneFlyMode:Boolean;
		
		private var _container:DisplayObjectContainer;
		private var _selectAvatar:Avatar;
		private var _cleanTime:int;
		private var _depthTime:int = 0;

		public function Scene()
		{
			this.mouseDownPoint = new Point();
			this.shoawdBitmapArray = [];
			this.headArray = new Dictionary();
			Scene.scene = this;
			super();
			this.init();
			
			SuperKey.getInstance().addEventListener(SuperKey.DEBUG, _saiman_debug_);
			SuperKey.getInstance().addEventListener(SuperKey.GM, _saiman_GM_);
		}

		public function get flying():Boolean
		{
			return _flying;
		}

		public function getSceneFlyMode():Boolean
		{
			return _sceneFlyMode;
		}
		public function setSceneFlyMode(value:Boolean, playEndFunc:Function=null):Boolean
		{
			if (_flying) {
				return false;
			}
			if (value) {
				this.mainChar.layer = SceneConstant.FLY_LAYER;
				this.mainChar.sceneFlyMode = true;
				this.$flyLayer.addChild(this.mainChar);
			} else {
				this.mainChar.layer = SceneConstant.MIDDLE_LAYER;
				this.mainChar.sceneFlyMode = false;
				this.$middleLayer.addChild(this.mainChar);
			}
			
			var char:Char;
			var data:Object;
			var chars:Array = this.avatarHash.coder::values();
			var i:int;
			while (i < chars.length) {
				char = chars[i] as Char;
				if (char != this.mainChar && char && char.sceneFlyMode) {
					char.layer = SceneConstant.FLY_LAYER;
					this.$flyLayer.addChild(this.mainChar);
					if (value) {
						char.scaleX = char.scaleY = 2;
					} else {
						char.scaleX = char.scaleY = 1;
					}
				}
				i++;
			}
			if (_sceneFlyMode != value) {
				if (value) {
					_flying = true;
					data = {"zoon":1}
					clickEnbeled = false;
					scene.mainChar.isFlyMode = true;
					this.$cloudLayer.alpha = 0.5;
					TweenLite.to(data, 1, {
						"zoon":0.5,
						"onUpdate":function ():void
						{
							zoon(data.zoon);
						},
						"onComplete":function ():void
						{
							_flying = false;
							clickEnbeled = true;
							if (playEndFunc != null) {
								playEndFunc();
							}
						}
					});
				} else {
					data = {"zoon":0.5}
					clickEnbeled = false;
					_flying = true;
					TweenLite.to(data, 1, {
						"zoon":1,
						"onUpdate":function ():void
						{
							zoon(data.zoon);
						},
						"onComplete":function ():void
						{
							clickEnbeled = true;
							_flying = false;
							$cloudLayer.alpha = 0;
							if ($cloudLayer.parent) {
								$cloudLayer.parent.removeChild($cloudLayer);
							}
							scene.mainChar.isFlyMode = false;
							if (playEndFunc != null) {
								playEndFunc();
							}
						}
					});
				}
			}
			_sceneFlyMode = value;
			return true;
		}

		protected function _saiman_GM_(_arg_1:Event):void
		{
		}

		protected function _saiman_debug_(_arg_1:Event):void
		{
//			MonsterDebugger.enabled = !MonsterDebugger.enabled;
		}

		public function get selectAvatar():Avatar
		{
			return _selectAvatar;
		}
		public function set selectAvatar(target:Avatar):void
		{
			_selectAvatar = target;
		}

		private function init():void
		{
			if (Engine.char_shadow == null) {
				this.drawShadow();
			}
			
			this.$nodeTree = new NodeTree(Engine.SCENE_ITEM_NODER);
			
			this.mouseChildren = this.mouseEnabled = false;
			this.tabChildren = this.tabEnabled = false;
			
			this.$topLayer = new Sprite();
			this.$topLayer.mouseEnabled = this.$topLayer.mouseChildren = false;
			this.$topLayer.tabChildren = this.$topLayer.tabEnabled = false;
			
			this.$middleLayer = new Sprite();
			this.$middleLayer.mouseEnabled = this.$middleLayer.mouseChildren = false;
			this.$middleLayer.tabChildren = this.$middleLayer.tabEnabled = false;
			
			this.$flyLayer = new Sprite();
			this.$flyLayer.mouseEnabled = this.$flyLayer.mouseChildren = false;
			this.$flyLayer.tabChildren = this.$flyLayer.tabEnabled = false;
			
			this.$itemLayer = new Sprite();
			this.$itemLayer.mouseChildren = this.$itemLayer.mouseEnabled = false;
			this.$itemLayer.tabChildren = this.$itemLayer.tabEnabled = false;
			
			this.$cloudLayer = new Shape();
			this.shadowShape = new Shape();
			
			this.maskShape = new Sprite();
			this.maskShape.graphics.beginFill(0, 0.6);
			this.maskShape.graphics.drawRect(0, 0, 10000, 10000);
			this.maskShape.mouseChildren = this.maskShape.mouseEnabled = false;
			this.maskShape.tabChildren = this.maskShape.tabEnabled = false;
			this.maskShape.addChild(this.shadowShape);
			
			this.$mapLayer = new MapLayer();
			
			this.addChild(this.$itemLayer);
			this.addChild(this.$middleLayer);
			this.addChild(this.$topLayer);
			this.avatarHash = new Hash();
		}

		public function setup(stage:Stage, container:DisplayObjectContainer):void
		{
			Engine.stage = stage;
			_container = container;
			_container.addChild(this);
			_container.addChildAt(this.$mapLayer, 0);
			
			this.stage.addEventListener("rightMouseDown", _EngineMouseRightDownFunc_);
			this.stage.addEventListener("rightMouseUp", _EngineMouseRightUpFunc_);
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, _EngineMouseDownFunc_);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, _EngineMouseUpFunc_);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, _EngineKeyDownFunc_);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, _EngineKeyUpFunc_);
			
			var timer:Timer = new Timer(0);
			timer.addEventListener(TimerEvent.TIMER, enterFrameFunc);
			timer.start();
		}

		public function updateMainChar(modelId:String, weaponId:String=null, mountId:String=null, wingId:String=null):void
		{
			if (_mainChar == null) {
				_mainChar = new MainChar();
				_mainChar.type = SceneConstant.CHAR;
				_mainChar.showBodyShoadw(true);
			}
			this.updateCharAvatarPart(_mainChar, modelId, weaponId, mountId, wingId);
		}

		public function updateCharAvatarPart(char:Char, modelId:String, weaponId:String=null, mountId:String=null, wingId:String=null):void
		{
			if (char) {
				if (mountId) {
					char.hp_height = 120;
				} else {
					char.hp_height = 150;
				}
				char.loadAvatarPart(AvatarTypes.BODY_TYPE, modelId);
				char.loadAvatarPart(AvatarTypes.WEAPON_TYPE, weaponId);
				char.loadAvatarPart(AvatarTypes.FLY_TYPE, wingId);
				char.loadAvatarPart(AvatarTypes.MOUNT_TYPE, mountId);
				char.avatarParts.bodyRender(true);
				if (_sceneFlyMode) {
					this.addItem(char, SceneConstant.FLY_LAYER);
				} else {
					this.addItem(char, SceneConstant.MIDDLE_LAYER);
				}
			}
		}

		public function setupReady():void
		{
			this.isReady = true;
			this.changing = false;
			
			this.$mapLayer.inited = true;
			if (this.onSceneReadyFunc != null) {
				this.onSceneReadyFunc();
			}
		}

		public function get mainChar():MainChar
		{
			return _mainChar;
		}

		private function cleanMemory():void
		{
			var ram:int = System.totalMemory / 0x100000;
			if (ram > 150) {
				AvatarManager.coder::getInstance().clean();
				AvatarAssetManager.getInstance().clean();
			}
		}

		public function changeScene(sceneID:int):void
		{
			SquareGroup.getInstance().unload();
			SquareGroup.getInstance().reset(null);
			this.cleanMemory();
			InstancePool.coder::getInstance().reset();
			if (this.$mapLayer) {
				this.$mapLayer.clean(sceneID);
			}
			this.changing = true;
			this.isReady = false;
			this.unload();
		}

		public function fineMainCharNearChar(radius:int=400, type:String=null):Char
		{
			var area:Rectangle = new Rectangle(this.mainChar.x-radius, this.mainChar.y-radius, radius*2, radius*2);
			var items:Array = this.find(area, true);
			var arr:Array = [];
			var idx:int;
			while (idx < items.length) {
				var char:Char = items[idx] as Char;
				if (char && (type == null || type == char.type)) {
					var dis:int = Point.distance(this.mainChar.point, new Point(char.x, char.y));
					arr.push({
						"dis":dis,
						"char":char
					});
				}
				idx++;
			}
			arr.sortOn("dis", Array.NUMERIC);
			if (arr.length) {
				return arr[0].char;
			}
			return null;
		}

		public function find(area:Rectangle, exact:Boolean, definition:int=100):Array
		{
			return this.$nodeTree.find(area, exact, definition);
		}

		public function buildTree(area:Rectangle, size:int=50, subNodes:Vector.<INoder>=null):void
		{
			if (subNodes == null) {
				subNodes = new Vector.<INoder>();
			}
			this.$nodeTree.build(area, size, subNodes);
		}

		public function get shiftKey():Boolean
		{
			return _shiftKey;
		}

		public function addNumShow(_arg_1:HeadShowShape, _arg_2:int, _arg_3:int):void
		{
			_arg_1.y = _arg_3;
			var _local_4:Rectangle = _arg_1.getBounds(null);
			if (_arg_1.type == 0) {
				_arg_1.x = (_arg_2 - ((_arg_1.width + _local_4.left) / 2));
			}
			_arg_1.playEndFunc = this.removeHeadShow;
			this.headArray[_arg_1.id] = _arg_1;
			this.$topLayer.addChild(_arg_1);
		}

		protected function playNumShape():void
		{
			for each (var _local_1:HeadShowShape in this.headArray) {
				_local_1.moving();
			}
		}

		private function removeHeadShow(_arg_1:String):void
		{
			var _local_2:HeadShowShape = (this.headArray[_arg_1] as HeadShowShape);
			if (_local_2) {
				if (_local_2.parent) {
					_local_2.parent.removeChild(_local_2);
				}
				if (_local_2) {
					_local_2.dispose();
				}
				delete this.headArray[_arg_1];
			}
			_local_2 = null;
		}

		public function unload():void
		{
			var _local_4:IAvatar;
			var _local_7:DisplayLoader;
			var _local_8:IItem;
			var _local_9:ShoawdBitmap;
			for each (var _local_1:HeadShowShape in this.headArray) {
				_local_1.dispose();
			}
			this.headArray = new Dictionary();
			var _local_3:Dictionary = WealthPool.getIntance().coder::hash;
			for (var _local_2:String in _local_3) {
				if (((((((!((_local_2.indexOf("mid_") == -1))) || (!((_local_2.indexOf("wid_") == -1))))) || (!((_local_2.indexOf("midm_") == -1))))) || (!((_local_2.indexOf("eid_") == -1))))) {
					_local_7 = (_local_3[_local_2] as DisplayLoader);
					if (_local_7) {
						_local_7.unloadAndStop();
						_local_7.dispose();
					}
					_local_7 = null;
					WealthPool.getIntance().remove(_local_2);
				}
			}
			while (this.$itemLayer.numChildren) {
				this.$itemLayer.removeChildAt((this.$itemLayer.numChildren - 1));
			}
			_local_3 = this.avatarHash;
			for (_local_2 in _local_3) {
				_local_8 = _local_3[_local_2];
				if (((_local_8) && (!((_local_8 == this.mainChar))))) {
					if ((_local_8 as Avatar)) {
						Avatar(_local_8).recover();
					} else {
						if ((_local_8 as ItemAvatar)) {
							if (_local_8.oid != this.mainChar.char_id) {
								ItemAvatar(_local_8).dispose();
							}
						} else {
							_local_8.dispose();
						}
					}
				}
			}
			_local_3 = null;
			this.avatarHash.dispose();
			this.avatarHash = new Hash();
			if (((this.mainChar) && (this.mainChar.char_id))) {
				this.avatarHash.put(this.mainChar.char_id, this.mainChar);
			}
			this.$mapLayer.graphics.clear();
			while (this.$middleLayer.numChildren) {
				_local_4 = (this.$middleLayer.removeChildAt(0) as IAvatar);
				if (((_local_4) && (!((_local_4 == this.mainChar))))) {
					_local_4.dispose();
				}
			}
			while (this.$topLayer.numChildren) {
				_local_4 = (this.$topLayer.removeChildAt(0) as IAvatar);
				if (_local_4) {
					_local_4.dispose();
				}
			}
			var _local_5:int = this.shoawdBitmapArray.length;
			var _local_6:int;
			while (_local_6 < _local_5) {
				_local_9 = this.shoawdBitmapArray[_local_6];
				_local_9.dispose();
				_local_6++;
			}
			this.shoawdBitmapArray = [];
			this.$mapLayer.unload();
			this.overAvatar = null;
			this.selectAvatar = null;
		}

		public function get nodeTree():NodeTree
		{
			return this.$nodeTree;
		}

		public function addShoawdBitmap(bmp:ShoawdBitmap):void
		{
			this.shoawdBitmapArray.push(bmp);
		}

		public function removeShoawdBitmap(bmp:ShoawdBitmap):void
		{
			var idx:int = this.shoawdBitmapArray.indexOf(bmp);
			if (idx != -1) {
				this.shoawdBitmapArray.splice(idx, 1);
			}
			bmp.dispose();
		}

		public function addItem(sceneItem:IItem, layerName:String):void
		{
			if (sceneItem == null || sceneItem.char_id == null) {
				log("saiman", "char_id属性不能为null!");
			}
			
			sceneItem.isSceneItem = true;
			sceneItem.layer = layerName;
			if (layerName == null && sceneItem.type == null) {
				sceneItem.type = SceneConstant.MIDDLE_LAYER;
			}
			var disItem:DisplayObject = sceneItem as DisplayObject;
			disItem.scaleX = disItem.scaleY = 1;
			switch (layerName) {
				case SceneConstant.TOP_LAYER:
					this.$topLayer.addChild(disItem);
					break;
				case SceneConstant.MIDDLE_LAYER:
					this.$middleLayer.addChild(disItem);
					break;
				case SceneConstant.BOTTOM_LAYER:
					this.$itemLayer.addChild(disItem);
					break;
				case SceneConstant.ITEM_LAYER:
					this.$itemLayer.addChild(disItem);
					break;
				case SceneConstant.FLY_LAYER:
					var charItem:Char = sceneItem as Char;
					if (_sceneFlyMode) {
						disItem.scaleX = disItem.scaleY = 2;
						charItem.hp_height = 140;
					} else {
						charItem.hp_height = 80;
					}
					this.$flyLayer.addChild(disItem);
					break;
			}
			this.avatarHash.put(sceneItem.char_id, sceneItem);
		}

		public function getChar(charID:String):IAvatar
		{
			return this.avatarHash.take(charID) as IAvatar;
		}

		coder function removeRepeatObjectInAvatarHash(avatar:IAvatar):void
		{
			if (avatar == null) {
				return;
			}
			if ((avatar is Char) || (avatar is SceneItem) || (avatar as ItemAvatar && ItemAvatar(avatar).isSkillEffect)) {
				this.avatarHash.remove(avatar.char_id);
			}
		}

		public function remove(avatar:IAvatar, isClear:Boolean=false):void
		{
			if (avatar == null) {
				return;
			}
			this.coder::removeRepeatObjectInAvatarHash(avatar);
			if (DisplayObject(avatar).parent) {
				DisplayObject(avatar).parent.removeChild(avatar as DisplayObject);
			}
			if (isClear) {
				if (avatar.isDisposed == false) {
					avatar.dispose();
				}
			} else {
				if ((avatar as ItemAvatar) || (avatar as SceneItem)) {
					if (avatar.isDisposed == false) {
						avatar.dispose();
					}
				} else {
					Char(avatar).stopMove();
					Char(avatar).recover();
				}
			}
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

		public function getSkillTile(p:Point):Avatar
		{
			var area:Rectangle = new Rectangle(this.mouseX-100, this.mouseY-100, 200, 200);
			var items:Array = this.find(area, false, 150);
			return HitTest.getChildUnderPoint(this, p, items, Avatar) as Avatar;
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

		public function sceneMoveTo(px:Number, py:Number):void
		{
			var pt_focus:Point = this.getCameraFocusTo(px, py);
			var pt_curr:Point = new Point(this.x, this.y);
			var dis:Number = Point.distance(pt_focus, pt_curr);
			if (dis > 0) {
				this.scenedMove(pt_curr, pt_focus);
			}
		}

		public function drawCloud(bmd:BitmapData, px:int, py:int):void
		{
			if (this.$cloudLayer) {
				var mtx:Matrix = RecoverUtils.matrix;
				mtx.tx = px;
				mtx.ty = py;
				this.$cloudLayer.graphics.beginBitmapFill(bmd, mtx);
				this.$cloudLayer.graphics.drawRect(px, py, bmd.width, bmd.height);
			}
		}

		protected function scenedMove(pt_from:Point, pt_to:Point):void
		{
//			this.x = this.$mapLayer.x = pt_to.x >> 0;
//			this.y = this.$mapLayer.y = pt_to.y >> 0;
			
			var pt_inter:Point = pt_to;
			var mapX:Number = (1 - this.$mapLayer.scaleX) * pt_inter.x;
			var mapY:Number = (1 - this.$mapLayer.scaleY) * pt_inter.y;
			pt_inter.x = (pt_inter.x - mapX) + (Engine.stage.stageWidth / 2) * (1 - this.$mapLayer.scaleX);
			pt_inter.y = (pt_inter.y - mapY) + (Engine.stage.stageHeight / 2) * (1 - this.$mapLayer.scaleY);
			pt_inter.x = Number(pt_inter.x.toFixed(1));
			pt_inter.y = Number(pt_inter.y.toFixed(1));
			this.x = pt_inter.x;
			this.y = pt_inter.y;
			this.$mapLayer.x = pt_inter.x;
			this.$mapLayer.y = pt_inter.y;
			if (this.$flyLayer.parent) {
				this.$flyLayer.x = pt_inter.x;
				this.$flyLayer.y = pt_inter.y;
			}
		}

		public function zoon(scale:Number):void
		{
			this.scaleX = this.scaleY = scale;
			this.$mapLayer.scaleX = this.$mapLayer.scaleY = scale;
			if (this.$flyLayer.parent) {
				this.$flyLayer.scaleX = this.$flyLayer.scaleY = scale;
			}
			this.sceneMoveTo(this.mainChar.x, this.mainChar.y);
			var _local_2:Number = 1 + (1-scale)*2;
			this.mainChar.hp_height = 140 * _local_2;
			this.mainChar.scaleX = this.mainChar.scaleY = _local_2;
		}

		public function uniformSpeedMoveTo(px:Number, py:Number):void
		{
			var pt_focus:Point = this.getCameraFocusPoint(px, py);
			var pt_curr:Point = new Point(this.x, this.y);
			var dis:Number = Point.distance(pt_focus, pt_curr);
			if (dis > 0) {
				this.scenedMove(pt_curr, pt_focus);
			}
		}

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

		protected function fill(px:int, py:int, pw:int=500, ph:int=300):void
		{
			var colors:Array = [0, 0, 0];
			var alphas:Array = [1, 0.8, 0];
			var ratios:Array = [0, 85, 0xFF];
			var tx:Number = px-pw/2;
			var ty:Number = (py-ph/2)-20;
			var mtx:Matrix = RecoverUtils.matrix;
			mtx.createGradientBox(pw, ph, 0, tx, ty);
			this.shadowShape.graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, mtx, SpreadMethod.PAD);
			this.shadowShape.graphics.drawEllipse(tx, ty, pw, ph);
		}

		protected function enterFrameFunc(evt:Event):void
		{
			if (!this.mainChar) {
				return;
			}
			if (this.$flyLayer.parent && _sceneFlyMode && !this.$cloudLayer.parent) {
				_container.addChild(this.$cloudLayer);
				_container.addChild(this.$flyLayer);
			} else if (!_sceneFlyMode && this.$cloudLayer.parent && !this.flying) {
				this.$cloudLayer.parent.removeChild(this.$cloudLayer);
			}
			if (_sceneFlyMode && !this.$flyLayer.parent) {
				_container.addChild(this.$flyLayer);
			}
			
			var area:Rectangle = new Rectangle(this.mouseX-200, this.mouseY-280, 400, 560);
			var items:Array = this.find(area, false, 150);
			var dis:DisplayObject = HitTest.getChildUnderPoint(this, new Point(this.mouseX, this.mouseY), items);
			var avatar:IAvatar = dis as IAvatar;
			if (dis as HeadShape) {
				if (HeadShape(dis).owner) {
					avatar = HeadShape(dis).owner as IAvatar;
				}
			}
			if (avatar != this.overAvatar) {
				if (this.overAvatar && Object(this.overAvatar).filters) {
					Object(this.overAvatar).filters = [];
				}
				this.overAvatar = avatar;
				if (this.overAvatar && this.overAvatar != this.mainChar) {
					if (Object(this.overAvatar).filters == null || Object(this.overAvatar).filters.length == 0) {
						Object(this.overAvatar).filters = [
							new ColorMatrixFilter(DisplayObjectUtil.liangdu(50)), 
							new GlowFilter(0xCACACA, 0.5)
						];
					}
				}
			}
			
			var interval:int;
			if (Engine.fps < 12) {
				interval = 2000;
			} else {
				interval = 600;
				if (this.mainChar.runing || this.mainChar.jumping) {
					interval = 1200;
				}
			}
			if ((getTimer() - _depthTime) > interval) {
				_depthTime = getTimer();
				this.checkOut();
				this.sortDepth();
			}
			
			if (Engine.screenShaking == false) {
				try {
					TweenLite.killTweensOf(this);
					TweenLite.killTweensOf(this.$mapLayer);
				} catch(e:Error) {
				}
			}
			
			this.charMove();
			this.playNumShape();
			if ((getTimer() - _cleanTime) > 150) {
				this.$mapLayer.loadImage(this.x, this.y);
				_cleanTime = getTimer();
			}
			
			if (this.shoawdBitmapArray && this.shoawdBitmapArray.length) {
				var len:int = this.shoawdBitmapArray.length;
				var idx:int = 0;
				while (idx < len) {
					var shoawBmp:ShoawdBitmap = this.shoawdBitmapArray[idx];
					if (shoawBmp) {
						shoawBmp.reander();
					}
					idx++;
				}
			}
		}

		public function clean():void
		{
			if (this.changing == false) {
				var list:Vector.<AvatartParts> = new Vector.<AvatartParts>();
				var dict:Dictionary = this.avatarHash;
				for each (var avatar:IAvatar in dict) {
					if (avatar as Avatar) {
						if (AvatarAssetManager.getInstance().checkCleanAbled(Object(avatar).avatarParts)) {
							list.push(Object(avatar).avatarParts);
						}
					}
				}
				AvatarAssetManager.getInstance().cleanItems(list);
			}
		}

		public function charMove():void
		{
			if (!this.stop && this.mainChar) {
				this.mainChar.moving();
				var dict:Dictionary = this.avatarHash;
				for each (var item:IItem in dict) {
					if (item is Char) {
						Char(item).moving();
					}
				}
				if (!this.lockSceneMove) {
					if (_sceneFlyMode) {
						this.sceneMoveTo(this.mainChar.x, this.mainChar.y);
					} else {
						this.uniformSpeedMoveTo(this.mainChar.x, this.mainChar.y);
					}
				}
			}
		}

		private function checkOut():void
		{
			var avatar:Avatar;
			var dict:Dictionary = this.avatarHash;
			for each (var item:IAvatar in dict) {
				if (item.type != SceneConstant.ICON_EFFECT) {
					continue;
				}
				if (!item.stageIntersects) {
					if (!item.stop) {
						item.stop = true;
					}
					if (DisplayObject(item).parent) {
						DisplayObject(item).parent.removeChild(item as DisplayObject);
					}
					if (item as Avatar) {
						avatar = item as Avatar;
						if (avatar.shadowShape && avatar.shadowShape.parent) {
							avatar.shadowShape.parent.removeChild(avatar.shadowShape);
						}
						if (avatar.headShape && avatar.headShape.parent) {
							avatar.headShape.parent.removeChild(avatar.headShape);
						}
					}
				} else {
					if (item.stop) {
						item.stop = false;
					}
					if (Object(item).parent == null) {
						if (item.isDisposed == false) {
							this.addItem(item, item.layer);
							if (item as Avatar) {
								avatar = item as Avatar
								avatar.headShape.reander();
								avatar.openShadow = true;
							}
						} else {
							coder::removeRepeatObjectInAvatarHash(item);
						}
					}
				}
			}
		}

		private function sortDepth():void
		{
			var child:DisplayObject;
			var index:int;
			var list:Array = [];
			var len:int = this.$middleLayer.numChildren;
			var idx:int;
			while (idx < len) {
				child = this.$middleLayer.getChildAt(idx);
				if ((child as Avatar) || (child as SceneItem)) {
					if (child) {
						list.push(child);
					}
				}
				idx++;
			}
			len = list.length;
			list.sortOn(["y", "x"], [Array.NUMERIC, Array.NUMERIC]);
			while (len--) {
				child = list[len];
				if (len <= this.$middleLayer.numChildren-1 && (child as Object).stageIntersects) {
					index = child.parent.getChildIndex(child);
					if (index != len) {
						this.$middleLayer.addChildAt(child, len);
					}
				}
			}
			
			list.length = 0;
			len = this.$flyLayer.numChildren;
			idx = 0;
			while (idx < len) {
				child = this.$flyLayer.getChildAt(idx);
				if (child as Char) {
					if (child) {
						list.push(child);
					}
				}
				idx++;
			}
			len = list.length;
			list.sortOn(["y", "x"], [Array.NUMERIC, Array.NUMERIC]);
			while (len--) {
				child = list[len];
				if (len <= this.$flyLayer.numChildren-1 && (child as Object).stageIntersects) {
					index = child.parent.getChildIndex(child);
					if (index != len) {
						this.$flyLayer.addChildAt(child, len);
					}
				}
			}
		}

		private function drawShadow():void
		{
			var pen:Shape = new Shape();
			pen.graphics.beginGradientFill(GradientType.LINEAR, [0, 0, 0, 0], [0.8, 0.7, 0.6, 0.6], [1, 1, 1, 1]);
			pen.graphics.drawEllipse(0, 0, 60, 30);
			pen.filters = [new BlurFilter(20, 10)];
			var rect:Rectangle = pen.getBounds(pen);
			var bmd:BitmapData = new BitmapData(80, 50, true, 0);
			var mtx:Matrix = RecoverUtils.matrix;
			mtx.tx = 10;
			mtx.ty = 5;
			bmd.draw(pen, mtx);
			Engine.char_shadow = bmd;
			pen.graphics.clear();
			pen.graphics.beginGradientFill(GradientType.LINEAR, [0, 0, 0, 0], [0.8, 0.7, 0.6, 0.6], [1, 1, 1, 1]);
			pen.graphics.drawEllipse(0, 0, 100, 40);
			pen.filters = [new BlurFilter(20, 10)];
			rect = pen.getBounds(pen);
			bmd = new BitmapData(120, 60, true, 0);
			mtx = RecoverUtils.matrix;
			mtx.tx = 10;
			mtx.ty = 5;
			bmd.draw(pen, mtx);
			Engine.char_big_shadow = bmd;
			pen.graphics.clear();
		}
		
	}
}
