﻿package com.engine.core.view.role
{
	import com.engine.core.Engine;
	import com.engine.core.tile.Pt;
	import com.engine.core.tile.TileConst;
	import com.engine.core.tile.square.Square;
	import com.engine.core.tile.square.SquareGroup;
	import com.engine.core.view.BitmapScale9Grid;
	import com.engine.core.view.avatar.ActionConst;
	import com.engine.core.view.avatar.Avatar;
	import com.engine.core.view.avatar.AvatarRestrict;
	import com.engine.core.view.avatar.ItemAvatar;
	import com.engine.core.view.avatar.ShoawdBitmap;
	import com.engine.core.view.items.HeadShowShape;
	import com.engine.core.view.items.InstancePool;
	import com.engine.core.view.items.Item;
	import com.engine.core.view.scenes.Scene;
	import com.engine.core.view.scenes.SceneConst;
	import com.engine.core.view.scenes.SceneEvent;
	import com.engine.core.view.scenes.SceneEventDispatcher;
	import com.engine.namespaces.coder;
	import com.engine.utils.gome.LinearUtils;
	import com.engine.utils.gome.TileUtils;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	public class Char extends Avatar 
	{
		
		private static var bitmapScale9Grid:BitmapScale9Grid;
		private static var matrix:Matrix = new Matrix();
		
		public var popsinger:int;
		public var isTeleporting:Boolean = false;
		public var effectSpeed:int = 350;
		public var isBackMoving:Boolean = false;
		public var jump_deafult_speed:int = 335;
		public var jumpQuene:Array;
		public var meditation:Boolean = false;
		public var walkendStandOutSide:Boolean = false;
		public var jump_lock:Boolean = true;
		public var jumpIndex:int;

		protected var isMainChar:Boolean = false;
		protected var _pathArr:Array;
		protected var _speed:Number = 160;
		protected var showWordTime:int;
		protected var wordTxt:TextField;
		protected var wordShape:Sprite;
		protected var tar_point:Point;
		protected var cur_point:Point;
		protected var time:Number = 0;
		protected var totalTime:Number = 0;
		protected var _sceneFlyMode:Boolean;
		protected var _speed_:int;
		
		private var buffSprite:Item;
		private var _walkEndFunc:Function;
		
		private var _dropShape:Shape;
		private var effectDic:Dictionary;
		private var timex:int = 0;
		private var jumpTimeNum:int;
		private var jumpTimerIndex:int;
		private var headArray:Dictionary;
		private var showList:Array;
		private var showTime:int = 0;
		private var actionPlaySpeed:int;
		private var jumpStartTime:int;

		public function Char()
		{
			super();
			this.type = SceneConst.CHAR;
			this.jumpQuene = [];
		}

		public static function createChar():Char
		{
			var char:Char = InstancePool.coder::getInstance().getAvatar(Char) as Char;
			char.reset();
			return char;
		}


		public function get sceneFlyMode():Boolean
		{
			return _sceneFlyMode;
		}
		public function set sceneFlyMode(val:Boolean):void
		{
			_sceneFlyMode = val;
		}

		public function get pathArr():Array
		{
			return (_pathArr);
		}

		public function set pathArr(_arg_1:Array):void
		{
			_pathArr = _arg_1;
		}

		public function get walkEndFunc():Function
		{
			return (_walkEndFunc);
		}

		public function set walkEndFunc(_arg_1:Function):void
		{
			_walkEndFunc = _arg_1;
		}

		public function get speed():Number
		{
			return _speed;
		}
		public function set speed(val:Number):void
		{
			_speed = val;
		}
		
		public function loop():void
		{
		}
		
		public function loopMove():void
		{
		}

		public function sayWord(_arg_1:String):void
		{
			var _local_2:TextFormat;
			if (this.isDeath) {
				return;
			}
			if (_arg_1 != null) {
				this.showWordTime = getTimer();
				if (this.wordTxt == null) {
					this.wordTxt = new TextField();
					this.wordTxt.textColor = 16697473;
					this.wordTxt.filters = [new GlowFilter(0, 1, 2, 2)];
					this.wordTxt.cacheAsBitmap = true;
					this.wordTxt.mouseEnabled = false;
					this.wordTxt.mouseWheelEnabled = false;
					this.wordTxt.selectable = false;
					this.wordTxt.width = 150;
					this.wordTxt.wordWrap = true;
					this.wordTxt.multiline = true;
				}
				if (this.wordShape == null) {
					this.wordShape = new Sprite();
				}
				this.wordShape.y = 100;
				this.wordTxt.htmlText = _arg_1;
				this.wordTxt.width = 150;
				this.wordTxt.height = (this.wordTxt.textHeight + 4);
				this.wordTxt.width = (this.wordTxt.textWidth + 10);
				this.wordTxt.x = (this.wordTxt.y = 2);
				if (bitmapScale9Grid == null) {
					bitmapScale9Grid = new BitmapScale9Grid(Engine.chat_bitmapData, new Rectangle(1, 1, 100, 35));
				}
				bitmapScale9Grid.width = (this.wordTxt.width + 5);
				bitmapScale9Grid.height = (this.wordTxt.height + 15);
				bitmapScale9Grid.draw(this.wordShape.graphics);
				this.wordShape.visible = this.bodyVisible;
				_local_2 = new TextFormat();
				_local_2.size = 12;
				if (this.wordTxt.textWidth < 150) {
					_local_2.align = TextFormatAlign.CENTER;
				} else {
					_local_2.align = TextFormatAlign.LEFT;
				}
				this.wordTxt.defaultTextFormat = _local_2;
				if ((((_arg_1 == null)) || ((_arg_1 == "")))) {
					if (this.wordShape) {
						this.wordShape.removeChild(this.wordTxt);
					}
					if (this.wordShape.parent) {
						this.wordShape.parent.removeChild(this.wordShape);
					}
				}
				this.addChild(this.wordShape);
				this.wordShape.addChild(this.wordTxt);
			} else {
				if (((this.wordShape) && (this.wordTxt))) {
					if ((((_arg_1 == null)) || ((_arg_1 == "")))) {
						if (this.wordTxt.parent) {
							this.wordTxt.parent.removeChild(this.wordTxt);
						}
						if (this.wordShape.parent) {
							this.wordShape.parent.removeChild(this.wordShape);
						}
					}
				}
			}
			this.updateWord();
		}

		public function setDrop(_arg_1:Shape):void
		{
			if (!_arg_1) {
				return;
			}
			if (((_dropShape) && (_dropShape.parent))) {
				_dropShape.parent.removeChild(_dropShape);
			}
			_dropShape = _arg_1;
			this.addChild(_dropShape);
		}

		override public function get transform():Transform
		{
			if (this.bmp_mid) {
				return this.bmp_mid.transform;
			}
			return null;
		}
		override public function set transform(val:Transform):void
		{
			if (this.bmp_mid) {
				this.bmp_mid.transform = val;
			}
		}

		override public function loadAvatarPart(avatarType:String, avatarNum:String):String
		{
			var loadKey:String = super.loadAvatarPart(avatarType, avatarNum);
			return loadKey;
		}

		override public function set shoadw(_arg_1:BitmapData):void
		{
			if (_arg_1) {
				if (shoadwShape == null) {
					shoadwShape = new Sprite();
					matrix.identity();
					matrix.tx = (_arg_1.width / 2);
					matrix.ty = _arg_1.height;
					shoadwShape.graphics.beginBitmapFill(_arg_1, matrix);
					shoadwShape.graphics.drawRect((-(_arg_1.width) / 2), -(_arg_1.height), _arg_1.width, _arg_1.height);
					shoadwShape.cacheAsBitmap = true;
				}
				this.addChildAt(shoadwShape, 0);
			} else {
				if (((shoadwShape) && (shoadwShape.parent))) {
					shoadwShape.parent.removeChild(shoadwShape);
					shoadwShape.graphics.clear();
				}
				shoadwShape = null;
			}
		}

		override public function set bodyVisible(val:Boolean):void
		{
			super.bodyVisible = val;
			if (this.buffSprite) {
				this.buffSprite.visible = val;
			}
			if (this.wordShape) {
				this.wordShape.visible = val;
			}
			if (this.effectDic) {
				for each (var item:ItemAvatar in this.effectDic) {
					if (item.parent) {
						item.parent.removeChild(item);
					}
					item.visible = val;
				}
			}
			this.stop = !val;
		}

		public function addBuff(_arg_1:DisplayObject):void
		{
			if (this.buffSprite == null) {
				this.buffSprite = new Item();
				this.buffSprite.mouseChildren = (this.buffSprite.mouseEnabled = false);
				this.buffSprite.tabEnabled = (this.buffSprite.tabChildren = false);
				if ((numChildren == 0)) {
					this.addChildAt(this.buffSprite, (this.numChildren - 1));
				} else {
					this.addChild(this.buffSprite);
				}
				this.buffSprite.y = -50;
			}
			var _local_2:int = _arg_1.width;
			if (_local_2 == 0) {
				_local_2 = 32;
			}
			_arg_1.x = (this.buffSprite.numChildren * (_local_2 + 2));
			this.buffSprite.addChild(_arg_1);
			this.buffSprite.x = ((-(this.buffSprite.numChildren) * (_local_2 + 2)) / 2);
			this.buffSprite.visible = this.bodyVisible;
		}

		override public function onRender(_arg_1:String, _arg_2:int, _arg_3:BitmapData, _arg_4:Rectangle, _arg_5:String, _arg_6:String=null, _arg_7:int=0, _arg_8:int=0, _arg_9:BitmapData=null):void
		{
			var _local_10:int;
			var _local_11:int;
			var _local_12:ItemAvatar;
			if (_arg_1 != this.avatarParts.id) {
				return;
			}
			if (this.isDisposed) {
				return;
			}
			if (((((avatarParts) && (!((avatarParts.state == ActionConst.STAND))))) && ((((((((this.type == SceneConst.CAR)) || ((this.type == SceneConst.MONSTER)))) || ((this.type == SceneConst.PET)))) || ((this.type == SceneConst.SUMMON_MONSTER)))))) {
				avatarParts.acce = (_speed / 120);
				if (avatarParts.acce < 1) {
					avatarParts.acce = 1;
				}
			}
			super.onRender(_arg_1, _arg_2, _arg_3, _arg_4, _arg_5, _arg_6, _arg_7, _arg_8, _arg_9);
			this.updateWord();
			if (this.buffSprite) {
				if (this.buffSprite.y != (-50 + this.onMonutHeight)) {
					this.buffSprite.y = (-50 + this.onMonutHeight);
				}
			}
			if (this.effectDic) {
				for each (_local_12 in this.effectDic) {
					if (_local_12.parent) {
						if (this.bmp_midm) {
							_local_10 = this.getChildIndex(_local_12);
							_local_11 = this.getChildIndex(bmp_midm);
							if (_local_10 < _local_11) {
								this.swapChildren(_local_12, bmp_midm);
							}
						}
						_local_12.y = this.onMonutHeight;
					}
				}
			}
		}

		override public function play(action:String, _arg_2:AvatarRestrict=null, _arg_3:Boolean=false, _arg_4:Function=null, _arg_5:Boolean=true):void
		{
			if (this.isBackMoving == false) {
				clearTimeout(this.jumpTimerIndex);
				super.play(action, _arg_2, _arg_3, _arg_4, _arg_5);
			}
		}

		override public function set alpha(val:Number):void
		{
			super.alpha = val;
			if (this.headShape) {
				this.headShape.alpha = val;
			}
			if (this.shadowShape) {
				this.shadowShape.alpha = val;
			}
		}
		
		public function updateAlpha():void
		{
			var tile:Square = SquareGroup.getInstance().take(this.key) as Square;
			if (tile) {
				if (tile.isAlpha) {
					if (this.alpha != 0.5) {
						this.alpha = 0.5;
					}
				} else {
					if (this.alpha != 1) {
						this.alpha = 1;
					}
				}
			}
		}

		public function updateWord():void
		{
			if (this.wordShape) {
				if (this.wordShape.y != ((-(height_old) + this.onMonutHeight) - this.wordShape.height)) {
					this.wordShape.y = (((-(height_old) + this.onMonutHeight) - this.wordShape.height) - 35);
				}
			}
			if (this.wordShape) {
				if (this.wordShape.x != -(int((this.wordTxt.textWidth / 2)))) {
					this.wordShape.x = -(int((this.wordShape.width / 2)));
				}
			}
			if (((((this.buffSprite) && (this.buffSprite.numChildren))) && (!((this.getChildIndex(this.buffSprite) == (this.numChildren - 1)))))) {
				this.addChildAt(this.buffSprite, (this.numChildren - 1));
			}
			if (((((this.wordShape) && (this.wordShape.parent))) && ((this.showWordTime > 0)))) {
				if ((getTimer() - this.showWordTime) > 3000) {
					this.wordShape.parent.removeChild(this.wordShape);
					this.showWordTime = 0;
				}
			}
		}

		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (this.isMainChar && (child as ItemAvatar)) {
				ItemAvatar(child).isAutoDispose = false;
			}
			return super.addChild(child);
		}

		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if (this.isMainChar && (child as ItemAvatar)) {
				ItemAvatar(child).isAutoDispose = false;
			}
			return super.addChildAt(child, index);
		}

		public function removeBuff(_arg_1:int):void
		{
			var _local_2:int;
			var _local_3:DisplayObject;
			var _local_4:int;
			var _local_5:int;
			if (this.buffSprite) {
				_local_2 = this.buffSprite.numChildren;
				_local_4 = 0;
				while (_local_4 < _local_2) {
					_local_3 = (this.buffSprite.getChildAt(_local_4) as DisplayObject);
					if ((((Object(_local_3).proto == _arg_1)) && (_local_3.parent))) {
						this.buffSprite.removeChild(_local_3);
						break;
					}
					_local_4++;
				}
				_local_5 = 0;
				while (_local_5 < this.buffSprite.numChildren) {
					_local_3 = (this.buffSprite.getChildAt(_local_5) as DisplayObject);
					_local_3.x = ((_local_5 * _local_3.width) + 3);
					_local_5++;
				}
				this.buffSprite.x = (-(this.buffSprite.width) / 2);
			}
		}

		override public function set isDeath(val:Boolean):void
		{
			_isDeath = val;
			if (this.walkEndFunc != null) {
				this.walkEndFunc = null;
			}
			this.stopMove();
		}

		public function stopMove():void
		{
			if (!avatarParts) {
				return;
			}
			if (this.shape) {
				this.shape.x = this.x;
				this.shape.y = this.y;
			}
			if (Engine.stopMove) {
				this.jumping = false;
				this.runing = false;
				this.pathArr = [];
				if (this.meditation) {
					this.doMeditation(true);
				} else {
					if (((!(this.jumping)) && ((avatarParts.state == ActionConst.WALK)))) {
					}
				}
				if (this == Scene.scene.mainChar) {
					this.timex = getTimer();
				}
			}
			if (this.actionPlaySpeed != 0) {
				this.avatarParts.attackSpeed = this.actionPlaySpeed;
				this.actionPlaySpeed = 0;
			}
		}

		public function faceTo(char:Avatar):void
		{
			if (this.jumping == false) {
				if (char) {
					this.dir = this.getDretion(char.x, char.y);
				}
			}
		}

		public function setRotation(px:Number, py:Number):void
		{
			var dx:Number = this.x - px;
			var dy:Number = this.y - py;
			var r:Number = (Math.atan2(dy, dx) * 180) / Math.PI;
			this.rotation = r;
		}

		public function faceToPoint(_arg_1:Number, _arg_2:Number):void
		{
			this.dir = this.getDretion(_arg_1, _arg_2);
		}

		override public function reset():void
		{
			this.stopMove();
			this.showList = null;
			this.name = "";
			this.popsinger = -1;
			this.sceneFlyMode = false;
			this.type = null;
			this.headArray = null;
			this.meditation = false;
			this.speed = 0;
			this.tar_point = null;
			_point = new Point();
			this.openShadow = false;
			this.x = 0;
			this.y = 0;
			this.buffSprite = null;
			this.cur_point = null;
			this.curr_rect = null;
			this.effectDic = null;
			this.isBackMoving = false;
			this.isTeleporting = false;
			this.jump_lock = true;
			this.runing = false;
			this.jumping = false;
			this.pathArr = [];
			this.layer = null;
			this.char_id = null;
			this.jump_deafult_speed = 335;
			this.jumpQuene = [];
			super.reset();
			if (this.isMainChar) {
				this.avatarParts.isAutoDispose = false;
			}
		}

		private function onCompleteFunc():void
		{
			this.avatarParts.vs = 0;
		}

		public function moving():void
		{
			var _local_1:int;
			if (this.avatarParts == null) {
				this.pathArr = [];
				this.runing = false;
				return;
			}
			if (((((((((this.pathArr) && ((this.pathArr.length >= 0)))) && (((jumping) || (runing))))) && (!(this.isDeath)))) && ((((avatarParts.state == ActionConst.WALK)) || ((avatarParts.state == ActionConst.SKILL2)))))) {
				_local_1 = getTimer();
				if (this == Scene.scene.mainChar) {
					Engine.moveTime = ((_local_1 - this.time) / 100);
				}
				this.totalTime = (this.totalTime + (_local_1 - this.time));
				if ((((this.totalTime > 0)) && (this.tar_point))) {
					this.charMove();
				}
			}
			this.time = getTimer();
		}

		public function get key():String
		{
			return (((this.type + "-") + this.char_id));
		}

		protected function charMove(_arg_1:String=null):void
		{
			var _local_10:int;
			if (this.tar_point == null) {
				this.walkEnd();
				return;
			}
			if (this.speed == 0) {
				this.walkEnd();
				return;
			}
			if (this.jumping) {
				_speed_ = this.jump_deafult_speed;
			} else {
				_speed_ = this.speed;
			}
			if (jumping) {
				if (this.pathArr.length <= (this.jumpIndex / 2)) {
					_speed_ = (_speed_ + (((this.jumpIndex / 2) - this.pathArr.length) * 2));
				} else {
					_speed_ = (_speed_ - ((this.pathArr.length - (this.jumpIndex / 2)) * 2));
				}
				if (this.pathArr.length > 1) {
					this.createShoawBitmap();
				}
			}
			var _local_2:Number = Point.distance(this.point, this.tar_point);
			var _local_3:Number = ((_local_2 / _speed_) * 1000);
			if (this.totalTime >= _local_3) {
				this.totalTime = (this.totalTime - _local_3);
			} else {
				_local_3 = this.totalTime;
				this.totalTime = 0;
			}
			var _local_4:Number = ((_speed_ * _local_3) / 1000);
			var _local_5:Number = (this.tar_point.x - point.x);
			var _local_6:Number = (this.tar_point.y - point.y);
			var _local_7:Number = Number(Math.atan2(_local_6, _local_5).toFixed(2));
			var _local_8:Number = Number((Math.cos(_local_7) * _local_4).toFixed(2));
			var _local_9:Number = Number((Math.sin(_local_7) * _local_4).toFixed(2));
			this.x = (this.x + _local_8);
			this.y = (this.y + _local_9);
			_local_2 = int(Point.distance(this.point, this.tar_point));
			if ((((_local_2 <= 5)) || ((((_local_8 == 0)) && ((_local_9 == 0)))))) {
				if (this.pathArr.length > 0) {
					this.tar_point = this.pathArr.shift();
				} else {
					this.walkEnd();
				}
			} else {
				if (((!((this.specialMode == 1))) && ((this.jumping == false)))) {
					_local_10 = this.getDretion(this.tar_point.x, this.tar_point.y);
					if (_local_10 != dir) {
						this.dir = _local_10;
					}
				}
			}
			if (this.totalTime > 0) {
				this.charMove();
			}
		}

		protected function createShoawBitmap():void
		{
			var _local_1:Rectangle;
			var _local_2:BitmapData;
			var _local_3:ShoawdBitmap;
			if (this.popsinger == 4) {
				if ((Engine.delayTime - this.jumpTimeNum) > 120) {
					_local_1 = new Rectangle();
					if (((bmp_mid) && (bmp_mid.bitmapData))) {
						_local_1 = _local_1.union(bmp_mid.bitmapData.rect);
					}
					if (_local_1.isEmpty() == false) {
						_local_2 = new BitmapData(_local_1.width, _local_1.height, true, 0);
						_local_2.copyPixels(bmp_mid.bitmapData, bmp_mid.bitmapData.rect, new Point());
						_local_3 = new ShoawdBitmap(_local_2);
						_local_3.alpha = 0.9;
						_local_3.x = (this.x - (_local_2.width / 2));
						_local_3.y = ((this.y - _local_2.height) + this.onMonutHeight);
						Scene.scene.$itemLayer.addChild(_local_3);
					}
					this.jumpTimeNum = Engine.delayTime;
				}
			}
		}

		public function doMeditation(_arg_1:Boolean, _arg_2:Boolean=false):void
		{
			this.meditation = _arg_1;
			this.isGroupSongModel = _arg_2;
			if (_arg_1) {
				this.play(ActionConst.MEDITATION);
			} else {
				if (((!(this.runing)) && (!(this.jumping)))) {
					if (this.avatarParts.state == ActionConst.MEDITATION) {
						this.play(ActionConst.STAND);
					}
				}
			}
		}

		protected function walkEnd():void
		{
			var ee:SceneEvent = new SceneEvent(SceneEvent.WALK_END);
			ee.proto = this;
			this.shadowMode = false;
			this.totalTime = 0;
			this.runing = false;
			if (((!(this.walkendStandOutSide)) && (this.runing))) {
				this.play(ActionConst.STAND);
				ee.walkEndType = 1;
			}
			if (this.jumping) {
				ee.walkEndType = 2;
				if (this.shape) {
					TweenLite.killTweensOf(this.shape);
					this.shape.x = this.x;
					this.shape.y = this.y;
				}
				if (this.actionPlaySpeed != 0) {
					this.avatarParts.attackSpeed = this.actionPlaySpeed;
					this.actionPlaySpeed = 0;
				}
				this.jumping = false;
				var t:int;
				t = (getTimer() - this.jumpStartTime);
				if (t < 500) {
					this.jumpTimerIndex = setTimeout(function ():void
					{
						play(ActionConst.STAND);
					}, (500-t));
				} else {
					this.play(ActionConst.STAND);
				}
			}
			if (this.meditation) {
				this.doMeditation(true);
			}
			if (this.tar_point) {
				this.point = this.tar_point;
				this.tar_point = null;
			}
			if (this.walkEndFunc != null) {
				this.walkEndFunc();
			}
			SceneEventDispatcher.getInstance().dispatchEvent(ee);
		}

		protected function surplusDis():Number
		{
			var _local_2:Array;
			var _local_3:int;
			var _local_4:int;
			var _local_5:Pt;
			var _local_6:Point;
			var _local_7:Point;
			var _local_8:Point;
			var _local_1:Number = 0;
			if (((this.pathArr) && (this.pathArr.length))) {
				_local_2 = [this.point];
				_local_3 = 0;
				while (_local_3 < this.pathArr.length) {
					_local_5 = this.pathArr[_local_3];
					_local_6 = TileUtils.getIsoIndexMidVertex(_local_5);
					_local_2.push(_local_6);
					_local_3++;
				}
				_local_4 = 0;
				while (_local_4 < (_local_2.length - 1)) {
					_local_7 = _local_2[_local_4];
					_local_8 = _local_2[(_local_4 + 1)];
					_local_1 = (_local_1 + Point.distance(_local_7, _local_8));
					_local_4++;
				}
				_local_2 = null;
			}
			return (_local_1);
		}

		public function addHeadShow(_arg_1:HeadShowShape):void
		{
			if (Engine.stage) {
				if (Engine.stage.frameRate < 5) {
					return;
				}
			}
			if (!this.showList) {
				this.showList = [];
			}
			this.showList.push(_arg_1);
			if (this.showList.length > 10) {
				this.showList.shift();
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

		public function showHeadShow():void
		{
			var _local_1:HeadShowShape;
			var _local_2:Rectangle;
			if (((((((headShape) && (this.showList))) && (this.showList.length))) && (((getTimer() - this.showTime) > 300)))) {
				_local_1 = this.showList.shift();
				this.showTime = Engine.delayTime;
				if (_local_1) {
					_local_1.dy = 1;
					_local_1.y = -(this.height_old);
					_local_2 = _local_1.getBounds(null);
					if (_local_1.type == 0) {
						_local_1.x = (-((_local_1.width + _local_2.left)) / 2);
					}
					if (!this.headArray) {
						this.headArray = new Dictionary();
					}
					_local_1.playEndFunc = this.removeHeadShow;
					this.headArray[_local_1.id] = _local_1;
					this.headShape.addChild(_local_1);
				}
			}
			if (this.headArray == null) {
				return;
			}
			for each (_local_1 in this.headArray) {
				_local_1.monutHeight = this.onMonutHeight;
				_local_1.moving();
			}
		}

		override public function recover():void
		{
			var _local_1:HeadShowShape;
			var _local_2:ItemAvatar;
			this.popsinger = -1;
			this.showList = null;
			if (this.headArray) {
				for each (_local_1 in this.headArray) {
					_local_1.dispose();
				}
			}
			if (_dropShape) {
				_dropShape.parent.removeChild(_dropShape);
			}
			_dropShape = null;
			this.headArray = null;
			this.isGroupSongModel = false;
			this.stopMove();
			try {
				if (shape) {
					TweenLite.killTweensOf(shape);
					shape.dispose();
				}
			} catch(e:Error) {
			}
			if (this.effectDic) {
				for each (_local_2 in this.effectDic) {
					if (_local_2.parent) {
						_local_2.parent.removeChild(_local_2);
					}
					_local_2.dispose();
				}
			}
			this.effectDic = null;
			
			if (((this.wordShape) && (this.wordShape.parent))) {
				this.wordShape.graphics.clear();
				this.removeChild(this.wordShape);
			}
			this.wordShape = null;
			if (this.wordTxt) {
				if (this.wordTxt.parent) {
					this.wordTxt.parent.removeChild(this.wordTxt);
				}
				this.wordTxt.text = "";
			}
			if (this.buffSprite) {
				if (this.buffSprite.parent) {
					this.removeChild(this.buffSprite);
				}
				while (this.buffSprite.numChildren) {
					this.buffSprite.removeChildAt((this.buffSprite.numChildren - 1));
				}
			}
			this.buffSprite = null;
			this.headVisible = true;
			this.pathArr = [];
			_point = new Point();
			this.speed = 0;
			this.visible = true;
			this.isTeleporting = false;
			this.isSceneItem = false;
			this.char_id = "";
			this.layer = "";
			this.isBackMoving = false;
			this.isSceneItem = false;
			this.jump_lock = false;
			this.jumpQuene = [];
			super.recover();
		}

		override public function dispose():void
		{
			var _local_1:HeadShowShape;
			var _local_2:ItemAvatar;
			this.popsinger = -1;
			if (this.isDisposed) {
				return;
			}
			this.isGroupSongModel = false;
			this.sceneFlyMode = false;
			this.stopMove();
			if (shape) {
				TweenLite.killTweensOf(shape);
			}
			this.isTeleporting = false;
			this.showList = null;
			if (this.headArray) {
				for each (_local_1 in this.headArray) {
					_local_1.dispose();
				}
			}
			this.headArray = null;
			if (_dropShape) {
				_dropShape.parent.removeChild(_dropShape);
			}
			_dropShape = null;
			super.dispose();
			if (this.effectDic) {
				for each (_local_2 in this.effectDic) {
					if (_local_2.parent) {
						_local_2.parent.removeChild(_local_2);
					}
					_local_2.dispose();
				}
			}
			this.effectDic = null;
			
			if (((this.wordShape) && (this.wordShape.parent))) {
				this.removeChild(this.wordShape);
			}
			this.wordShape = null;
			if (this.wordTxt) {
				this.wordTxt.text = "";
			}
			this.wordTxt = null;
			if (this.buffSprite) {
				if (this.buffSprite.parent) {
					this.removeChild(this.buffSprite);
				}
				while (this.buffSprite.numChildren) {
					this.buffSprite.removeChildAt((this.buffSprite.numChildren - 1));
				}
			}
			this.buffSprite = null;
			this.pathArr = null;
			this.tar_point = null;
			this.cur_point = null;
			_pt = null;
			_point = null;
			this.jumpQuene = [];
			this.hp_height = 110;
		}

		public function shadowMove(_arg_1:Array):void
		{
		}

		public function jump(paths:Array, _arg_2:Boolean=true, _arg_3:int=0):void
		{
			var _local_6:Point;
			var _local_7:AvatarRestrict;
			var _local_8:int;
			var _local_9:Number;
			var _local_10:Number;
			if (this.jumping || !this.avatarParts) {
				return;
			}
			if (!paths || paths.length == 0) {
				return;
			}
			this.actionPlaySpeed = this.avatarParts.attackSpeed;
			this.meditation = false;
			this.isGroupSongModel = false;
			this.jumpIndex = paths.length;
			var dis:int = Point.distance(paths[0], paths[paths.length-1]);
			this.jump_deafult_speed = ((this.speed * 2) + ((this.speed / 2) * (1 - (dis / 400))));
			this.avatarParts.attackSpeed = ((this.actionPlaySpeed * dis) / 400);
			if (this.isOnMonut == false) {
				this.shadowMode = false;
			}
			this.pathArr = paths.slice();
			if (this.pathArr.length > 0) {
				_local_6 = this.pathArr[(this.pathArr.length - 1)];
				dir = this.getDretion(_local_6.x, _local_6.y);
				_local_7 = new AvatarRestrict();
				this.jumpStartTime = getTimer();
				clearTimeout(this.jumpTimerIndex);
				this.avatarParts.currentFrame;
				this.play(ActionConst.SKILL2, null, true);
				this.jump_lock = _arg_2;
				if (((_arg_2) && (avatarParts))) {
					avatarParts.isPalyStandDeay = false;
				}
				this.cur_point = null;
				runing = false;
				jumping = true;
				this.time = getTimer();
				this.totalTime = 0;
				this.tar_point = this.pathArr.shift();
				this.cur_point = point;
				_local_8 = this.needTime(paths, (this.jump_deafult_speed * 0.96));
				_local_9 = paths[(paths.length - 1)].x;
				_local_10 = paths[(paths.length - 1)].y;
				TweenLite.to(shape, (_local_8 / 1000), {
					"x":_local_9,
					"y":_local_10,
					"ease":Linear.easeNone
				});
			} else {
				if (avatarParts.state == ActionConst.SKILL2) {
					this.play("stand");
				}
			}
		}

		public function set state(val:String):void
		{
			this.avatarParts.state = val;
			this.loadCharActionAssets(val);
		}

		private function needTime(_arg_1:Array, _arg_2:int=0):int
		{
			var _local_5:Point;
			var _local_6:Point;
			var _local_7:int;
			var _local_8:int;
			var _local_9:int;
			if (_arg_2 == 0) {
				_arg_2 = this.speed;
			}
			if (_arg_1.length == 0) {
				return (0);
			}
			var _local_3:int = _arg_1.length;
			var _local_4:Number = 0;
			if (_arg_1.length < 2) {
				_local_5 = this.point;
				_local_6 = _arg_1[0];
				_local_7 = Point.distance(_local_5, _local_6);
				return (((_local_7 / _arg_2) * 1000));
			}
			_local_5 = this.point;
			_local_8 = 0;
			while (_local_8 < _local_3) {
				_local_6 = _arg_1[_local_8];
				_local_9 = Point.distance(_local_5, _local_6);
				_local_4 = (_local_4 + ((_local_9 / _arg_2) * 1000));
				_local_5 = _arg_1[_local_8];
				_local_8++;
			}
			return (_local_4);
		}

		public function walk(paths:Array):void
		{
			if (!this.avatarParts) {
				return;
			}
			if (paths.length == 1) {
				var ttx:int = paths[0].x / TileConst.TILE_WIDTH;
				var tty:int = paths[0].y / TileConst.TILE_HEIGHT;
				var ftx:int = this.x / TileConst.TILE_WIDTH;
				var fty:int = this.y / TileConst.TILE_HEIGHT;
				if (ttx == ftx && tty == fty) {
					return;
				}
			}
			this.isGroupSongModel = false;
			this.meditation = false;
			if (!this.jumping) {
				clearTimeout(this.jumpTimerIndex);
				if (this.avatarParts.state != ActionConst.WALK && this.avatarParts.state != ActionConst.STAND) {
					this.play(ActionConst.STAND);
				}
				this.pathArr = paths.slice();
				if (this.pathArr.length > 0) {
					if (this.needTime(paths) > 10000) {
					}
					if (avatarParts) {
						this.state = ActionConst.WALK;
					}
					this.cur_point = null;
					runing = true;
					jumping = false;
					this.time = getTimer();
					this.totalTime = 0;
					this.tar_point = this.pathArr.shift();
					if ((((Point.distance(this.point, this.tar_point) > 60)) && ((this.pathArr.length > 1)))) {
						this.point = this.tar_point;
						this.dir = this.getDretion(this.tar_point.x, this.tar_point.y);
					}
					this.cur_point = this.point;
				} else {
					if (this.avatarParts.state == ActionConst.WALK) {
						this.play(ActionConst.STAND);
					}
				}
			} else {
				if (this.avatarParts.state == ActionConst.WALK) {
					this.play(ActionConst.STAND);
				}
			}
		}

		public function setAttackSpeed(_arg_1:Number):void
		{
			if (avatarParts) {
				if (_arg_1 > 3000) {
					_arg_1 = 3000;
				}
				if ((((_arg_1 >= 701)) && ((_arg_1 <= 3000)))) {
					this.avatarParts.attackSpeed = (1 + ((700 - _arg_1) / 4600));
				} else {
					if (_arg_1 < 701) {
						this.avatarParts.attackSpeed = 1;
					}
				}
			}
		}

		public function stepMove(_arg_1:Point, _arg_2:Point, _arg_3:Number):Point
		{
			var _local_4:Number = (_arg_2.x - _arg_1.x);
			var _local_5:Number = (_arg_2.y - _arg_1.y);
			var _local_6:Number = Math.atan2(_local_5, _local_4);
			var _local_7:Number = (Math.cos(_local_6) * _arg_3);
			var _local_8:Number = (Math.sin(_local_6) * _arg_3);
			return (new Point(_local_7, _local_8));
		}

		public function getDretion(px:Number, py:Number):int
		{
			var ret:int = LinearUtils.getDirection(this.x, this.y, px, py);
			return ret;
		}

	}
}
