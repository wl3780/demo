package com.engine.core.view.scenes
{
	import com.engine.core.Core;
	import com.engine.core.RecoverUtils;
	import com.engine.core.controls.wealth.WealthPool;
	import com.engine.core.controls.wealth.loader.DisplayLoader;
	import com.engine.core.model.map.SquareMapData;
	import com.engine.core.tile.square.Square;
	import com.engine.core.tile.square.SquareGroup;
	import com.engine.core.tile.square.SquarePt;
	import com.engine.core.view.BaseSprite;
	import com.engine.core.view.items.HeadShowShape;
	import com.engine.core.view.items.IItem;
	import com.engine.core.view.items.InstancePool;
	import com.engine.core.view.items.avatar.Avatar;
	import com.engine.core.view.items.avatar.AvatarAssetManager;
	import com.engine.core.view.items.avatar.AvatarManager;
	import com.engine.core.view.items.avatar.AvatartParts;
	import com.engine.core.view.items.avatar.HeadShape;
	import com.engine.core.view.items.avatar.IAvatar;
	import com.engine.core.view.items.avatar.ItemAvatar;
	import com.engine.core.view.items.avatar.ShoawdBitmap;
	import com.engine.core.view.quadTree.INoder;
	import com.engine.core.view.quadTree.NodeTree;
	import com.engine.core.view.role.Char;
	import com.engine.core.view.role.MainChar;
	import com.engine.core.view.world.MapLayer;
	import com.engine.namespaces.coder;
	import com.engine.utils.Bezier;
	import com.engine.utils.Hash;
	import com.engine.utils.HitTest;
	import com.engine.utils.SuperKey;
	import com.engine.utils.astar.SquareAstar;
	import com.engine.utils.gome.SquareUitls;
	import com.engine.utils.gome.TileUtils;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
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
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class Scene extends BaseSprite 
	{

		public static var scene:Scene;
		public static var clickEnbeled:Boolean = true;

		public var $topLayer:Sprite;
		public var $middleLayer:Sprite;
		public var $bottomLayer:MapLayer;
		public var $itemLayer:Sprite;
		public var $flyLayer:Sprite;
		public var $cloudLayer:Shape;
		
		public var mouseDownPoint:Point;
		public var mapData:SquareMapData;
		public var mainPet:Char;
		public var changing:Boolean = false;
		public var isReady:Boolean = false;
		public var lockSceneMove:Boolean;
		public var onSceneReadyFunc:Function;
		public var shadowShape:Shape;
		
		protected var $nodeTree:NodeTree;
		protected var _shiftKey:Boolean;
		protected var _flying:Boolean = false;
		protected var _mainChar:MainChar;
		protected var time:int;
		protected var stop:Boolean;
		protected var isMouseDown:Boolean = false;
		protected var avatarHash:Hash;
		protected var maskShape:Sprite;
		protected var shoawdBitmapArray:Array;
		protected var mouseDownTime:int = 0;
		protected var _walkEndFunc_:Function;
		protected var overAvatar:IAvatar;
		protected var autoWalk:Boolean = false;
		protected var headArray:Dictionary;
		
		coder var astar:SquareAstar;
		
		private var _sceneFlyMode:Boolean;
		private var _lingthMode:int;
		
		private var container:DisplayObjectContainer;
		private var timeNum:int = 0;
		private var _time:int = 0;
		private var _selectAvatar:*;
		private var time_1:Number;
		private var time_2:Number;
		private var timeCounter:int;
		private var timeBool:Boolean = false;
		private var $point:Point;
		private var cleanTime:int;
		private var checkTime:int = 0;
		private var depthTime:int = 0;
		private var _outsideRect:Rectangle;

		public function Scene()
		{
			this.mouseDownPoint = new Point();
			this.shoawdBitmapArray = [];
			this.$point = new Point(-1, -1);
			this.headArray = new Dictionary();
			_outsideRect = new Rectangle();
			Scene.scene = this;
			super();
			this.init();
			
			SuperKey.getInstance().addEventListener(SuperKey.DEBUG, _saiman_debug_);
			SuperKey.getInstance().addEventListener(SuperKey.GM, _saiman_GM_);
		}

		public function get flying():Boolean
		{
			return (_flying);
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

		public function get walkEndFunc():Function
		{
			return _walkEndFunc_;
		}
		public function set walkEndFunc(val:Function):void
		{
			_walkEndFunc_ = val;
		}

		public function get selectAvatar():*
		{
			return _selectAvatar;
		}
		public function set selectAvatar(target:*):void
		{
			_selectAvatar = target;
		}

		public function get lingthMode():int
		{
			return _lingthMode;
		}
		public function set lingthMode(val:int):void
		{
			_lingthMode = val;
			if (val <= 0) {
				this.shadowShape.blendMode = BlendMode.NORMAL;
				this.maskShape.blendMode = BlendMode.NORMAL;
				if (this.maskShape.parent) {
					this.maskShape.parent.removeChild(this.maskShape);
				}
			} else {
				this.shadowShape.blendMode = BlendMode.ERASE;
				this.maskShape.blendMode = BlendMode.LAYER;
				if (this.contains(this.maskShape) == false && this.contains(this.$middleLayer) == true) {
					var idx:int = this.getChildIndex(this.$middleLayer);
					this.addChildAt(this.maskShape, (idx + 1));
				}
			}
		}

		public function liangdu(num:Number):Array
		{
			return [
				1, 0, 0, 0, num, 
				0, 1, 0, 0, num, 
				0, 0, 1, 0, num, 
				0, 0, 0, 1, 0];
		}

		private function init():void
		{
			if (Core.char_shadow == null) {
				this.drawShadow();
			}
			
			coder::astar = new SquareAstar();
			this.$nodeTree = new NodeTree(Core.SCENE_ITEM_NODER);
			
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
			
			this.$cloudLayer = new Shape();
			
			this.$itemLayer = new Sprite();
			this.$itemLayer.mouseChildren = this.$itemLayer.mouseEnabled = false;
			this.$itemLayer.tabChildren = this.$itemLayer.tabEnabled = false;
			
			this.shadowShape = new Shape();
			
			this.maskShape = new Sprite();
			this.maskShape.graphics.beginFill(0, 0.6);
			this.maskShape.graphics.drawRect(0, 0, 10000, 10000);
			this.maskShape.mouseChildren = this.maskShape.mouseEnabled = false;
			this.maskShape.tabChildren = this.maskShape.tabEnabled = false;
			this.maskShape.addChild(this.shadowShape);
			
			this.lingthMode = 0;
			this.$bottomLayer = new MapLayer();
			
			this.addChild(this.$itemLayer);
			this.addChild(this.$middleLayer);
			this.addChild(this.$topLayer);
			this.avatarHash = new Hash();
		}

		public function setup(stage:Stage, container:DisplayObjectContainer):void
		{
			Core.stage = stage;
			this.container = container;
			this.container.addChild(this);
			this.container.addChildAt(this.$bottomLayer, 0);
			Core.stage.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownFunc);
			Core.stage.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpFunc);
			Core.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.keyDownFunc);
			Core.stage.addEventListener(KeyboardEvent.KEY_UP, this.keyUpFunc);
			Core.stage.addEventListener(Event.ENTER_FRAME, this.enterFrameFunc);
		}

		public function movePointChangeFunc(_arg_1:Point, _arg_2:Point):void
		{
		}

		public function updateMainChar(avatarID:int, weaponID:int=0, mountID:int=0, wingID:int=0):void
		{
			if (_mainChar == null) {
				_mainChar = new MainChar();
				_mainChar.type = SceneConstant.CHAR;
				_mainChar.char_id = Core.mainCharId;
				_mainChar.showBodyShoadw(true);
				_mainChar.movePointChangeFunc = this.movePointChangeFunc;
			}
			this.updateCharAvatarPart(_mainChar, avatarID, weaponID, mountID, wingID);
		}

		public function updateCharAvatarPart(char:Char, avatarID:int, weaponID:int=0, mountID:int=0, wingID:int=0):void
		{
			if (char) {
				if (mountID == 0) {
					char.hp_height = 120;
				} else {
					char.hp_height = 150;
				}
				char.loadAvatarPart(Core.hostPath + Core.avatarAssetsPath + "clothes/mid_" + avatarID + Core.TMP_FILE + "?version=" + Core.version);
				char.loadAvatarPart(Core.hostPath + Core.avatarAssetsPath + "weapons/wid_" + weaponID + Core.TMP_FILE + "?version=" + Core.version);
				char.loadAvatarPart(Core.hostPath + Core.avatarAssetsPath + "flys/fid_" + wingID + Core.TMP_FILE + "?version=" + Core.version);
				char.loadAvatarPart(Core.hostPath + Core.avatarAssetsPath + "mounts/midm_" + mountID + Core.TMP_FILE + "?version=" + Core.version);
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
			if (this.mainChar) {
				this.mainChar.reLoadHaloBuffEffect();
			}
			this.$bottomLayer.inited = true;
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
			this.$point = new Point(-1, -1);
			if (this.$bottomLayer) {
				this.$bottomLayer.clean(sceneID);
			}
			this.changing = true;
			this.isReady = false;
			this.unload();
		}

		public function fineMainCharNearChar(_arg_1:int=400, _arg_2:String=null):Char
		{
			var _local_7:Char;
			var _local_8:int;
			var _local_3:Rectangle = new Rectangle((this.mainChar.x - _arg_1), (this.mainChar.y - _arg_1), (_arg_1 * 2), (_arg_1 * 2));
			var _local_4:Array = this.fine(_local_3, true);
			var _local_5:Array = [];
			var _local_6:int;
			while (_local_6 < _local_4.length) {
				_local_7 = (_local_4[_local_6] as Char);
				if (((_local_7) && ((((_arg_2 == null)) || ((_arg_2 == _local_7.type)))))) {
					_local_8 = Point.distance(this.mainChar.point, new Point(_local_7.x, _local_7.y));
					_local_5.push({
						"dis":_local_8,
						"char":_local_7
					});
				}
				_local_6++;
			}
			_local_5.sortOn("dis", Array.NUMERIC);
			if (_local_5.length) {
				return (_local_5[0].char);
			}
			return (null);
		}

		public function fine(area:Rectangle, exact:Boolean, definition:int=100):Array
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
			var _local_1:HeadShowShape;
			for each (_local_1 in this.headArray) {
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
			var _local_1:HeadShowShape;
			var _local_2:String;
			var _local_3:Dictionary;
			var _local_4:IAvatar;
			var _local_7:DisplayLoader;
			var _local_8:IItem;
			var _local_9:ShoawdBitmap;
			for each (_local_1 in this.headArray) {
				_local_1.dispose();
			}
			this.headArray = new Dictionary();
			_local_3 = WealthPool.getIntance().coder::hash;
			for (_local_2 in _local_3) {
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
			_local_3 = this.avatarHash.hash;
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
			this.$bottomLayer.graphics.clear();
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
			this.$bottomLayer.unload();
			this.overAvatar = null;
			this.selectAvatar = null;
		}

		public function get nodeTree():NodeTree
		{
			return (this.$nodeTree);
		}

		public function addShoawdBitmap(_arg_1:ShoawdBitmap):void
		{
			this.shoawdBitmapArray.push(_arg_1);
		}

		public function removeShoawdBitmap(_arg_1:ShoawdBitmap):void
		{
			var _local_2:int = this.shoawdBitmapArray.indexOf(_arg_1);
			if (_local_2 != -1) {
				this.shoawdBitmapArray.splice(_local_2, 1);
			}
			_arg_1.dispose();
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

		coder function removeRepeatObjectInAvatarHash(_arg_1:IAvatar):void
		{
			if (_arg_1 == null) {
				return;
			}
			var _local_2:Dictionary = this.avatarHash.hash;
			if ((((((_arg_1 is Char)) || ((_arg_1 is SceneItem)))) || ((((_arg_1 as ItemAvatar)) && (ItemAvatar(_arg_1).isSkillEffect))))) {
				if ((((_arg_1 as ItemAvatar)) && (ItemAvatar(_arg_1).isSkillEffect))) {
				}
				this.avatarHash.remove(_arg_1.char_id);
			}
		}

		public function remove(_arg_1:IAvatar, _arg_2:Boolean=false):void
		{
			if (_arg_1 == null) {
				return;
			}
			var _local_3 = this;
			(_local_3.coder::removeRepeatObjectInAvatarHash(_arg_1));
			if (DisplayObject(_arg_1).parent) {
				DisplayObject(_arg_1).parent.removeChild((_arg_1 as DisplayObject));
			}
			if (_arg_2) {
				if (_arg_1.isDisposed == false) {
					_arg_1.dispose();
				}
			} else {
				if ((((_arg_1 as ItemAvatar)) || ((_arg_1 as SceneItem)))) {
					if (_arg_1.isDisposed == false) {
						_arg_1.dispose();
					}
				} else {
					Char(_arg_1).stopMove();
					Char(_arg_1).recover();
				}
			}
		}

		protected function keyDownFunc(_arg_1:KeyboardEvent):void
		{
			_shiftKey = _arg_1.shiftKey;
			Core.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.keyDownFunc);
			Core.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.keyDownFunc);
		}

		protected function keyUpFunc(_arg_1:KeyboardEvent):void
		{
			_shiftKey = false;
			Core.stage.removeEventListener(KeyboardEvent.KEY_UP, this.keyUpFunc);
			Core.stage.addEventListener(KeyboardEvent.KEY_UP, this.keyUpFunc);
		}

		public function getSkillTile(_arg_1:Point):Avatar
		{
			var _local_2:Rectangle = new Rectangle((this.mouseX - 100), (this.mouseY - 100), 200, 200);
			var _local_3:Array = this.fine(_local_2, false, 150);
			return ((HitTest.getChildUnderPoint(this, _arg_1, _local_3) as Avatar));
		}

		protected function mouseDownFunc(_arg_1:MouseEvent):void
		{
			var _local_3:Point;
			var _local_4:Point;
			var _local_5:Point;
			var _local_6:Array;
			var _local_7:Rectangle;
			var _local_8:Array;
			if (clickEnbeled == false) {
				return;
			}
			this.isMouseDown = true;
			this.mouseDownTime = getTimer();
			var _local_2:Point = new Point();
			_local_2.x = mouseX;
			_local_2.y = mouseY;
			this.mouseDownPoint = _local_2;
			if (_shiftKey) {
				_local_3 = new Point(this.mainChar.x, this.mainChar.y);
				_local_4 = this.mouseDownPoint;
				_local_5 = new Point(this.mouseX, 0);
				_local_6 = Bezier.drawBezier(_local_3, _local_4, _local_5);
			} else {
				_local_7 = new Rectangle((this.mouseX - 100), (this.mouseY - 100), 200, 200);
				_local_8 = this.fine(_local_7, false, 100);
				this.selectAvatar = (HitTest.getChildUnderPoint(this, this.mouseDownPoint, _local_8) as Avatar);
				if ((getTimer() - this.time) > 500) {
					this.mainCharWalk(this.mouseDownPoint);
					this.time = getTimer();
				}
			}
		}

		public function mainCharWalk(_arg_1:Point, _arg_2:Function=null, _arg_3:int=1000, _arg_4:int=1, _arg_5:Boolean=true, _arg_6:Boolean=false):void
		{
			if (this.mainChar.lockMove) {
				return;
			}
			Core.sceneClickAbled = true;
			_walkEndFunc_ = _arg_2;
			this.charMoveTo(this.mainChar, _arg_1.x, _arg_1.y);
		}

		public function charMoveTo(_arg_1:Char, _arg_2:Number, _arg_3:Number, _arg_4:Function=null):Array
		{
			var _local_5:Point;
			var _local_6:Array;
			if (_arg_1) {
				_local_5 = new Point();
				_local_5.x = _arg_2;
				_local_5.y = _arg_3;
				_local_6 = this.getPath(_arg_1.point, _local_5);
				if (_local_6.length > 0) {
					_arg_1.walk(_local_6);
					if (_arg_4 != null) {
						_arg_1.walkEndFunc = _arg_4;
					}
					return (_local_6);
				}
				if (_arg_4 != null) {
					(_arg_4());
				}
			}
			return ([]);
		}

		public function charMovePath(_arg_1:Char, _arg_2:Array, _arg_3:Function=null):void
		{
			if (_arg_2.length > 1) {
				_arg_1.walk(_arg_2);
				if (_arg_3 != null) {
					_arg_1.walkEndFunc = _arg_3;
				}
			} else {
				if (_arg_3 != null) {
					_arg_1.walkEndFunc = _arg_3;
				}
			}
		}

		public function cleanPath(_arg_1:Array):Array
		{
			var _local_2:int;
			var _local_3:Point;
			var _local_4:Point;
			var _local_5:Point;
			var _local_6:Number;
			var _local_7:Number;
			if (_arg_1.length > 2) {
				_local_2 = 1;
				while (_local_2 < (_arg_1.length - 1)) {
					_local_3 = _arg_1[(_local_2 - 1)];
					_local_4 = _arg_1[_local_2];
					_local_5 = _arg_1[(_local_2 + 1)];
					_local_6 = ((_local_3.y - _local_4.y) / (_local_3.x - _local_4.x));
					_local_7 = ((_local_4.y - _local_5.y) / (_local_4.x - _local_5.x));
					if (_local_6 == _local_7) {
						_arg_1.splice(_local_2, 1);
						_local_2--;
					}
					_local_2++;
				}
			}
			return (_arg_1);
		}

		public function getPath(_arg_1:Point, _arg_2:Point):Array
		{
			var _local_3:Array;
			var _local_6:Point;
			var _local_7:Point;
			var _local_4:SquarePt = SquareUitls.pixelsToSquare(_arg_1);
			var _local_5:SquarePt = SquareUitls.pixelsToSquare(_arg_2);
			if (_local_4.key == _local_5.key) {
				return ([_arg_1, _arg_2]);
			}
			if (this.checkPointType(_arg_1, _arg_2)) {
				_local_3 = [_arg_1, _arg_2];
			} else {
				_local_3 = this.coder::astar.getPath(SquareGroup.getInstance().hash.hash, _local_4, _local_5);
				if (_local_3.length) {
					_local_6 = _local_3[(_local_3.length - 1)];
					if (TileUtils.getIndex(_local_6).key == _local_5.key) {
						_local_3[(_local_3.length - 1)] = _arg_2;
					}
					_local_7 = _local_3[0];
					if (TileUtils.getIndex(_local_7).key == _local_4.key) {
						if (_local_4.toString() != _arg_1.toString()) {
							_local_3[0] = _arg_1;
						}
					}
				}
				_local_3 = this.cleanPath(_local_3);
				if (_local_3.length == 1) {
					_local_3.push(_local_3[0]);
				}
			}
			return (_local_3);
		}

		public function walkPathDecode(_arg_1:Point, _arg_2:Point):Array
		{
			var _local_3:Array;
			var _local_6:Point;
			var _local_7:Point;
			var _local_4:SquarePt = SquareUitls.pixelsToSquare(_arg_1);
			var _local_5:SquarePt = SquareUitls.pixelsToSquare(_arg_2);
			_local_3 = this.coder::astar.getPath(SquareGroup.getInstance().hash.hash, _local_4, _local_5);
			if (_local_3.length) {
				_local_6 = _local_3[(_local_3.length - 1)];
				if (TileUtils.getIndex(_local_6).key == _local_5.key) {
					_local_3[(_local_3.length - 1)] = _arg_2;
				}
				_local_7 = _local_3[0];
				if (TileUtils.getIndex(_local_7).key == _local_4.key) {
					if (_local_4.toString() != _arg_1.toString()) {
						_local_3[0] = _arg_1;
					}
				}
			}
			return (_local_3);
		}

		public function walkPathUncode(_arg_1:ByteArray):Array
		{
			return ([]);
		}

		protected function getLinePaths(_arg_1:Point, _arg_2:Point, _arg_3:int=10):Array
		{
			var _local_9:Point;
			var _local_10:SquarePt;
			var _local_11:Square;
			var _local_4:Array = [];
			var _local_5:Dictionary = new Dictionary();
			var _local_6:Number = Point.distance(_arg_1, _arg_2);
			var _local_7:int = Math.ceil((_local_6 / _arg_3));
			var _local_8:int;
			while (_local_8 < _local_7) {
				_local_9 = Point.interpolate(_arg_1, _arg_2, (1 - (_local_8 / _local_7)));
				_local_10 = SquareUitls.pixelsToSquare(_local_9);
				_local_11 = SquareGroup.getInstance().take(_local_10.key);
				if (_local_5[_local_11.key] == null) {
					_local_4.push(SquareUitls.squareTopixels(_local_10));
				}
				_local_8++;
			}
			return (_local_4);
		}

		protected function checkPointType(_arg_1:Point, _arg_2:Point, _arg_3:int=10):Boolean
		{
			var _local_8:Point;
			var _local_9:SquarePt;
			var _local_10:Square;
			var _local_4:Number = Point.distance(_arg_1, _arg_2);
			var _local_5:int = Math.ceil((_local_4 / _arg_3));
			var _local_6:Boolean = true;
			var _local_7:int;
			while (_local_7 < _local_5) {
				_local_8 = Point.interpolate(_arg_1, _arg_2, (_local_7 / _local_5));
				_local_9 = SquareUitls.pixelsToSquare(_local_8);
				_local_10 = SquareGroup.getInstance().take(_local_9.key);
				if (((!(_local_10)) || ((((_local_10.type < 1)) && (!((_local_10.type == this.coder::astar.mode))))))) {
					_local_6 = false;
					break;
				}
				_local_7++;
			}
			return (_local_6);
		}

		public function sceneMoveTo(_arg_1:Number, _arg_2:Number):void
		{
			var _local_3:Point = this.getCameraFocusTo(_arg_1, _arg_2);
			var _local_4:Number = _local_3.x;
			var _local_5:Number = _local_3.y;
			var _local_6:Number = ((1 - this.$bottomLayer.scaleX) * _local_4);
			var _local_7:Number = ((1 - this.$bottomLayer.scaleY) * _local_5);
			_local_4 = ((_local_4 - _local_6) + ((Core.stage.stageWidth / 2) * (1 - this.$bottomLayer.scaleX)));
			_local_5 = ((_local_5 - _local_7) + ((Core.stage.stageHeight / 2) * (1 - this.$bottomLayer.scaleY)));
			this.x = _local_4;
			this.y = _local_5;
			_local_4 = Number(_local_4.toFixed(1));
			_local_5 = Number(_local_5.toFixed(1));
			this.$bottomLayer.x = _local_4;
			this.$bottomLayer.y = _local_5;
			if (this.$flyLayer.parent) {
				this.$flyLayer.x = _local_4;
			}
			if (this.$flyLayer.parent) {
				this.$flyLayer.y = _local_5;
			}
		}

		public function drawCloud(_arg_1:BitmapData, _arg_2:int, _arg_3:int):void
		{
			var _local_4:Matrix;
			if (this.$cloudLayer) {
				_local_4 = RecoverUtils.matrix;
				_local_4.tx = _arg_2;
				_local_4.ty = _arg_3;
				this.$cloudLayer.graphics.beginBitmapFill(_arg_1, _local_4);
				this.$cloudLayer.graphics.drawRect(_arg_2, _arg_3, _arg_1.width, _arg_1.height);
			}
		}

		protected function uniformSpeedMove(_arg_1:Point, _arg_2:Point):void
		{
			var _local_6:Point;
			var _local_7:Number;
			var _local_8:Number;
			var _local_3:Number = Point.distance(_arg_2, _arg_1);
			var _local_4:int = 20;
			var _local_5:int = 1;
			while (_local_5 <= _local_4) {
				_local_6 = Point.interpolate(_arg_2, _arg_1, 1);
				_local_7 = ((1 - this.$bottomLayer.scaleX) * _local_6.x);
				_local_8 = ((1 - this.$bottomLayer.scaleY) * _local_6.y);
				_local_6.x = ((_local_6.x - _local_7) + ((Core.stage.stageWidth / 2) * (1 - this.$bottomLayer.scaleX)));
				_local_6.y = ((_local_6.y - _local_8) + ((Core.stage.stageHeight / 2) * (1 - this.$bottomLayer.scaleY)));
				_local_6.x = Number(_local_6.x.toFixed(1));
				_local_6.y = Number(_local_6.y.toFixed(1));
				this.x = _local_6.x;
				this.y = _local_6.y;
				this.$bottomLayer.x = _local_6.x;
				this.$bottomLayer.y = _local_6.y;
				if (this.$flyLayer.parent) {
					this.$flyLayer.x = _local_6.x;
				}
				if (this.$flyLayer.parent) {
					this.$flyLayer.y = _local_6.y;
				}
				_local_5++;
			}
		}

		public function zoon(_arg_1:Number):void
		{
			this.scaleX = (this.scaleY = (this.$bottomLayer.scaleX = (this.$bottomLayer.scaleY = _arg_1)));
			if (this.$flyLayer.parent) {
				this.$flyLayer.scaleX = (this.$flyLayer.scaleY = this.scaleX);
			}
			this.sceneMoveTo(this.mainChar.x, this.mainChar.y);
			var _local_2:Number = (1 + ((1 - _arg_1) * 2));
			this.mainChar.hp_height = (140 * _local_2);
			this.mainChar.scaleX = (this.mainChar.scaleY = _local_2);
		}

		public function slowMoveTo(_arg_1:Number, _arg_2:Number):void
		{
			var _local_3:Point;
			var _local_7:Number;
			var _local_8:int;
			var _local_9:*;
			_local_3 = this.getCameraFocusPoint(_arg_1, _arg_2);
			var _local_4:Number = _local_3.x;
			var _local_5:Number = _local_3.y;
			_local_3 = new Point();
			_local_3.x = _arg_1;
			_local_3.y = _arg_2;
			var _local_6:Number = Point.distance(_local_3, _local_3);
			if (_local_6 > 0) {
				_time = getTimer();
				_local_8 = (this.mainChar.speed * 1000);
				if (_local_8 < 600) {
					_local_8 = 500;
				}
				_local_7 = (_local_6 / _local_8);
				_local_9 = this;
				this.timeNum++;
				TweenLite.to(this.$bottomLayer, _local_7, {
					"x":_local_4,
					"y":_local_5,
					"ease":Linear.easeNone
				});
				TweenLite.to(this, _local_7, {
					"x":_local_4,
					"y":_local_5,
					"ease":Linear.easeNone
				});
			}
		}

		public function uniformSpeedMoveTo(_arg_1:Number, _arg_2:Number):void
		{
			var _local_3:Point = this.getCameraFocusPoint(_arg_1, _arg_2);
			var _local_4:Point = new Point();
			_local_4.x = _arg_1;
			_local_4.y = _arg_2;
			var _local_5:Point = _local_4;
			var _local_6:Number = Point.distance(_local_5, _local_3);
			if (_local_6 > 0) {
				this.uniformSpeedMove(_local_5, _local_3);
			}
		}

		public function getCameraFocusTo(_arg_1:Number, _arg_2:Number):Point
		{
			var _local_7:Number;
			var _local_8:Number;
			var _local_3:int = Core.stage.stageWidth;
			var _local_4:int = Core.stage.stageHeight;
			var _local_5 = 4000;
			var _local_6 = 4000;
			if (((((this.mapData) && ((this.mapData.width > 0)))) && ((this.mapData.height > 0)))) {
				_local_5 = this.mapData.width;
				_local_6 = this.mapData.height;
			}
			var _local_9:Number = (_local_3 / 2);
			var _local_10:Number = (_local_4 / 2);
			if ((((_arg_1 >= _local_9)) && ((_arg_1 <= (_local_5 - _local_9))))) {
				_local_7 = (_local_9 - _arg_1);
			} else {
				if (_arg_1 <= _local_9) {
					_local_7 = 0;
				} else {
					_local_7 = (_local_3 - _local_5);
				}
			}
			if ((((_arg_2 >= _local_10)) && ((_arg_2 <= (_local_6 - _local_10))))) {
				_local_8 = (_local_10 - _arg_2);
			} else {
				if (_arg_2 <= _local_10) {
					_local_8 = 0;
				} else {
					_local_8 = (_local_4 - _local_6);
				}
			}
			return (new Point(_local_7, _local_8));
		}

		public function getCameraFocusPoint(_arg_1:Number, _arg_2:Number):Point
		{
			var _local_7:Number;
			var _local_8:Number;
			var _local_3:int = Core.stage.stageWidth;
			var _local_4:int = Core.stage.stageHeight;
			var _local_5 = 4000;
			var _local_6 = 4000;
			if (((((this.mapData) && ((this.mapData.width > 0)))) && ((this.mapData.height > 0)))) {
				_local_5 = this.mapData.pixel_width;
				_local_6 = this.mapData.pixel_height;
			}
			var _local_9:int = 70;
			var _local_10:Point = new Point();
			_local_10.x = _arg_1;
			_local_10.y = _arg_2;
			var _local_11:Point = this.localToGlobal(_local_10);
			var _local_12:Number = (_local_3 / 2);
			var _local_13:Number = (_local_4 / 2);
			var _local_14:Point = this.localToGlobal(_local_10);
			_local_10 = new Point();
			_local_10.x = _local_12;
			_local_10.y = _local_13;
			var _local_15:int = Point.distance(_local_10, _local_14);
			var _local_16:int = _local_9;
			var _local_17:Number = scaleX;
			var _local_18:Number = (_local_14.x - _local_12);
			var _local_19:Number = (_local_14.y - _local_13);
			var _local_20:Number = Number(Math.atan2(_local_19, _local_18).toFixed(2));
			_local_14.x = Number((_local_12 + ((Math.cos(_local_20) * _local_9) * _local_17)).toFixed(2));
			_local_14.y = Number((_local_13 + ((Math.sin(_local_20) * _local_9) * _local_17)).toFixed(2));
			var _local_21:Point = this.globalToLocal(_local_14);
			var _local_22:Number = (_local_3 - _local_5);
			var _local_23:Number = (_local_4 - _local_6);
			if ((((_arg_1 >= (_local_12 + _local_9))) && ((_arg_1 <= ((_local_5 - _local_12) - _local_9))))) {
				if (_local_15 >= (_local_16 * _local_17)) {
					_local_7 = (_local_14.x - _arg_1);
					if (_local_7 > 0) {
						_local_7 = 0;
					}
					if (_local_7 < _local_22) {
						_local_7 = _local_22;
					}
				}
			} else {
				if (_arg_1 <= (_local_12 + _local_9)) {
					_local_7 = (_local_14.x - _arg_1);
					if (_local_7 > 0) {
						_local_7 = 0;
					}
				} else {
					_local_7 = (_local_14.x - _arg_1);
					if (_local_7 < _local_22) {
						_local_7 = _local_22;
					}
				}
			}
			if ((((_arg_2 >= (_local_13 + _local_9))) && ((_arg_2 <= ((_local_6 - _local_13) - _local_9))))) {
				if (_local_15 >= (_local_16 * _local_17)) {
					_local_8 = (_local_14.y - _arg_2);
					if (_local_8 > 0) {
						_local_8 = 0;
					}
					if (_local_8 < _local_23) {
						_local_8 = _local_23;
					}
				}
			} else {
				if (_arg_2 <= (_local_13 + _local_9)) {
					_local_8 = (_local_14.y - _arg_2);
					if (_local_8 > 0) {
						_local_8 = 0;
					}
				} else {
					_local_8 = (_local_14.y - _arg_2);
					if (_local_8 < _local_23) {
						_local_8 = _local_23;
					}
				}
			}
			return (new Point(_local_7, _local_8));
		}

		protected function mouseUpFunc(_arg_1:MouseEvent):void
		{
			this.isMouseDown = false;
			this.autoWalk = false;
			if (Core.sceneClickAbled == false) {
				return;
			}
		}

		protected function zuobi():Boolean
		{
			var _local_1:Date = new Date();
			var _local_2:Number = _local_1.time;
			var _local_3:Number = getTimer();
			if (Math.abs(((_local_3 - this.time_2) - (_local_2 - this.time_1))) > 30) {
				this.timeCounter++;
				if (this.timeCounter > 5) {
					return (true);
				}
				this.timeBool = true;
			} else {
				this.timeBool = false;
			}
			if (!this.timeBool) {
				this.timeCounter = 0;
			}
			this.time_2 = getTimer();
			this.time_1 = _local_2;
			return (false);
		}

		protected function fill(_arg_1:int, _arg_2:int, _arg_3:int=500, _arg_4:int=300):void
		{
			var _local_5:String = GradientType.RADIAL;
			var _local_6:Array = [0, 0, 0];
			var _local_7:Array = [1, 0.8, 0];
			var _local_8:Array = [0, 85, 0xFF];
			var _local_9:Matrix = RecoverUtils.matrix;
			_local_9.createGradientBox(_arg_3, _arg_4, 0, (_arg_1 - (_arg_3 / 2)), ((_arg_2 - (_arg_4 / 2)) - 20));
			var _local_10:String = SpreadMethod.PAD;
			this.shadowShape.graphics.beginGradientFill(_local_5, _local_6, _local_7, _local_8, _local_9, _local_10);
			this.shadowShape.graphics.drawEllipse((_arg_1 - (_arg_3 / 2)), ((_arg_2 - (_arg_4 / 2)) - 20), _arg_3, _arg_4);
		}

		protected function enterFrameFunc(_arg_1:Event):void
		{
			var _local_4:IAvatar;
			var _local_6:int;
			var _local_7:int;
			var _local_8:int;
			var _local_9:ShoawdBitmap;
			if (!this.mainChar) {
				return;
			}
			if (((((this.$flyLayer.parent) && (_sceneFlyMode))) && (!(this.$cloudLayer.parent)))) {
				this.container.addChild(this.$cloudLayer);
				this.container.addChild(this.$flyLayer);
			} else {
				if (((((!(_sceneFlyMode)) && (this.$cloudLayer.parent))) && (!(this.flying)))) {
					this.$cloudLayer.parent.removeChild(this.$cloudLayer);
				}
			}
			if (((((_sceneFlyMode) && (stage))) && (!(this.$flyLayer.parent)))) {
				this.container.addChild(this.$flyLayer);
			}
			if (((((((this.isMouseDown) && (Core.sceneClickAbled))) && (((getTimer() - this.mouseDownTime) > 1000)))) && (!(_shiftKey)))) {
				this.autoWalk = true;
			} else {
				this.autoWalk = false;
			}
			var _local_2:Rectangle = new Rectangle((this.mouseX - 200), (this.mouseY - 280), 400, 560);
			var _local_3:Array = this.fine(_local_2, false, 150);
			var _local_5:DisplayObject = (HitTest.getChildUnderPoint(this, new Point(mouseX, mouseY), _local_3) as DisplayObject);
			_local_4 = (_local_5 as IAvatar);
			if ((_local_5 as HeadShape)) {
				if (HeadShape(_local_5).owner) {
					_local_4 = (HeadShape(_local_5).owner as IAvatar);
				}
			}
			if (_local_4 != this.overAvatar) {
				if (((this.overAvatar) && (Object(this.overAvatar).filters))) {
					Object(this.overAvatar).filters = [];
				}
				this.overAvatar = _local_4;
				if (((this.overAvatar) && (!((this.overAvatar == this.mainChar))))) {
					if ((((Object(this.overAvatar).filters == null)) || ((Object(this.overAvatar).filters.length == 0)))) {
						Object(this.overAvatar).filters = [new ColorMatrixFilter(Object(this.overAvatar).liangdu(50)), new GlowFilter(0xCACACA, 0.5)];
					}
				}
			}
			if ((Core.fps < 12)) {
				_local_6 = 2000;
			} else {
				_local_6 = 600;
			}
			if (((this.mainChar.runing) || (this.mainChar.jumping))) {
				_local_6 = 1200;
			}
			if ((getTimer() - this.depthTime) > _local_6) {
				this.depthTime = getTimer();
				this.sortDepth();
				this.checkOut();
			}
			if (Core.screenShaking == false) {
				try {
					TweenLite.killTweensOf(this.$bottomLayer);
					TweenLite.killTweensOf(this);
				} catch(e:Error) {
				}
			}
			this.charMove();
			this.playNumShape();
			if ((getTimer() - this.cleanTime) > 150) {
				this.$bottomLayer.loadImage(x, y);
				this.cleanTime = getTimer();
			}
			if (((this.shoawdBitmapArray) && (this.shoawdBitmapArray.length))) {
				_local_7 = this.shoawdBitmapArray.length;
				_local_8 = 0;
				while (_local_8 < _local_7) {
					_local_9 = this.shoawdBitmapArray[_local_8];
					if (_local_9) {
						_local_9.reander();
					}
					_local_8++;
				}
			}
		}

		public function clean():void
		{
			var _local_1:Vector.<AvatartParts>;
			var _local_2:Dictionary;
			var _local_3:IAvatar;
			if (this.changing == false) {
				_local_1 = new Vector.<AvatartParts>();
				_local_2 = this.avatarHash.hash;
				for each (_local_3 in _local_2) {
					if ((_local_3 as Avatar)) {
						if (AvatarAssetManager.getInstance().checkCleanAbled(Object(_local_3).avatarParts)) {
							_local_1.push(Object(_local_3).avatarParts);
						}
					}
				}
				AvatarAssetManager.getInstance().cleanItems(_local_1);
			}
		}

		public function charMove():void
		{
			var _local_1:Dictionary;
			var _local_2:IItem;
			if (((!(this.stop)) && (this.mainChar))) {
				this.mainChar.moving();
				_local_1 = this.avatarHash.hash;
				for each (_local_2 in _local_1) {
					if ((_local_2 is Char)) {
						Char(_local_2).moving();
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

		protected function setCharHeadVisible(_arg_1:Boolean):void
		{
			var _local_4:Avatar;
			var _local_2:Array = this.avatarHash.coder::values();
			var _local_3:int = (_local_2.length - 1);
			while (_local_3 >= 0) {
				_local_4 = (_local_2[_local_3] as Avatar);
				if (((((((_local_4) && (!((_local_4 == this.mainChar))))) && (!((_local_4 == this.mainPet))))) && ((((_local_4.type == SceneConstant.CHAR)) || ((_local_4.type == SceneConstant.PET)))))) {
					_local_4.headVisible = _arg_1;
				}
				_local_3--;
			}
		}

		protected function setCharBodyVisible(_arg_1:Boolean):void
		{
			var _local_4:Avatar;
			var _local_2:Array = this.avatarHash.coder::values();
			var _local_3:int = (_local_2.length - 1);
			while (_local_3 >= 0) {
				_local_4 = (_local_2[_local_3] as Avatar);
				if (((((((_local_4) && (!((_local_4 == this.mainChar))))) && (!((_local_4 == this.mainPet))))) && ((((_local_4.type == SceneConstant.CHAR)) || ((_local_4.type == SceneConstant.PET)))))) {
					_local_4.bodyVisible = _arg_1;
				}
				_local_3--;
			}
		}

		private function checkOut():void
		{
			var _local_2:IAvatar;
			var _local_3:HeadShape;
			var _local_1:Dictionary = this.avatarHash.hash;
			for each (_local_2 in _local_1) {
				if (_local_2.type != SceneConstant.ICON_EFFECT) {
					if (!_local_2.stageIntersects) {
						if (!_local_2.stop) {
							_local_2.stop = true;
						}
						if (DisplayObject(_local_2).parent) {
							DisplayObject(_local_2).parent.removeChild((_local_2 as DisplayObject));
							if ((_local_2 as Avatar)) {
								_local_3 = (Avatar(_local_2).headShape as HeadShape);
								if (((_local_3) && (_local_3.parent))) {
									_local_3.parent.removeChild(_local_3);
								}
							}
						}
						if ((_local_2 as Char)) {
							if (((Char(_local_2).shadowShape) && (Char(_local_2).shadowShape.parent))) {
								Char(_local_2).shadowShape.parent.removeChild(Char(_local_2).shadowShape);
							}
							if (((Char(_local_2).headShape) && (Char(_local_2).headShape.parent))) {
								Char(_local_2).headShape.parent.removeChild(Char(_local_2).headShape);
							}
						}
					} else {
						if (_local_2.stop) {
							_local_2.stop = false;
						}
						if (Object(_local_2).parent == null) {
							if (_local_2.isDisposed == false) {
								this.addItem(_local_2, _local_2.layer);
								if ((_local_2 as Char)) {
									Char(_local_2).openShadow = true;
								}
								if ((_local_2 as Avatar)) {
									Avatar(_local_2).headShape.reander();
								}
							} else {
								(coder::removeRepeatObjectInAvatarHash(_local_2));
							}
						}
					}
				}
			}
		}

		private function sortDepth():void
		{
			var _local_3:Object;
			var _local_5:int;
			var _local_6:int;
			var _local_1:Array = [];
			var _local_2:int = this.$middleLayer.numChildren;
			var _local_4:int;
			while (_local_4 < _local_2) {
				_local_3 = this.$middleLayer.getChildAt(_local_4);
				if ((((_local_3 as Avatar)) || ((_local_3 as SceneItem)))) {
					if (_local_3) {
						_local_1.push(_local_3);
					}
				}
				_local_4++;
			}
			_local_2 = _local_1.length;
			_local_1.sortOn(["y", "x"], [Array.NUMERIC, Array.NUMERIC]);
			while (_local_2--) {
				_local_3 = _local_1[_local_2];
				if ((((((_local_2 <= (this.$middleLayer.numChildren - 1))) && (_local_3.stageIntersects))) && (!((this.$middleLayer.getChildAt(_local_2) == _local_3))))) {
					_local_5 = DisplayObject(_local_3).parent.getChildIndex((_local_3 as DisplayObject));
					if (_local_5 != _local_2) {
						this.$middleLayer.addChildAt((_local_3 as DisplayObject), _local_2);
					}
				}
			}
			_local_1 = [];
			_local_2 = this.$flyLayer.numChildren;
			_local_4 = 0;
			while (_local_4 < _local_2) {
				_local_3 = this.$flyLayer.getChildAt(_local_4);
				if ((_local_3 as Char)) {
					if (_local_3) {
						_local_1.push(_local_3);
					}
				}
				_local_4++;
			}
			_local_2 = _local_1.length;
			_local_1.sortOn(["y", "x"], [Array.NUMERIC, Array.NUMERIC]);
			while (_local_2--) {
				_local_3 = _local_1[_local_2];
				if ((((((_local_2 <= (this.$flyLayer.numChildren - 1))) && (_local_3.stageIntersects))) && (!((this.$flyLayer.getChildAt(_local_2) == _local_3))))) {
					_local_6 = DisplayObject(_local_3).parent.getChildIndex((_local_3 as DisplayObject));
					if (_local_6 != _local_2) {
						this.$flyLayer.addChildAt((_local_3 as DisplayObject), _local_2);
					}
				}
			}
		}

		public function get outsideRect():Rectangle
		{
			return (_outsideRect);
		}

		protected function updateOutsideRect():void
		{
			var _local_1:int = (1750 / 2);
			var _local_2:int = (1750 / 2);
			_outsideRect = new Rectangle(0, 0, _local_1, _local_2);
			var _local_3:Number = this.mainChar.x;
			var _local_4:Number = this.mainChar.y;
			var _local_5:int = Core.stage.stageWidth;
			var _local_6:int = Core.stage.stageHeight;
			var _local_7 = 4000;
			var _local_8 = 4000;
			if (((((this.mapData) && ((this.mapData.width > 0)))) && ((this.mapData.height > 0)))) {
				_local_7 = this.mapData.width;
				_local_8 = this.mapData.height;
			}
			this.$middleLayer.graphics.clear();
			this.$middleLayer.graphics.lineStyle(1, 0xFF0000);
			var _local_9:Number = (_local_5 / 2);
			var _local_10:Number = (_local_6 / 2);
			if ((((_local_3 >= _local_9)) && ((_local_3 <= (_local_7 - _local_9))))) {
				_outsideRect.x = (_local_3 - (_local_1 / 2));
			} else {
				if (_local_3 <= _local_9) {
					_outsideRect.x = 0;
				} else {
					_outsideRect.x = (_local_7 - _local_1);
				}
			}
			if ((((_local_4 >= _local_10)) && ((_local_4 <= (_local_8 - _local_10))))) {
				_outsideRect.y = (_local_4 - (_local_2 / 2));
			} else {
				if (_local_4 <= _local_10) {
					_outsideRect.y = 0;
				} else {
					_outsideRect.y = (_local_8 - _local_2);
				}
			}
			this.$middleLayer.graphics.drawRect(_outsideRect.x, _outsideRect.y, _outsideRect.width, _outsideRect.height);
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
			Core.char_shadow = bmd;
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
			Core.char_big_shadow = bmd;
			pen.graphics.clear();
		}
		
	}
}
