﻿package com.engine.core.view.role
{
	import com.engine.core.Core;
	import com.engine.core.tile.Pt;
	import com.engine.core.tile.TileConstant;
	import com.engine.core.tile.square.SquarePt;
	import com.engine.core.view.BitmapScale9Grid;
	import com.engine.core.view.items.HeadShowShape;
	import com.engine.core.view.items.InstancePool;
	import com.engine.core.view.items.Item;
	import com.engine.core.view.items.avatar.Avatar;
	import com.engine.core.view.items.avatar.AvatarRestrict;
	import com.engine.core.view.items.avatar.CharAction;
	import com.engine.core.view.items.avatar.ItemAvatar;
	import com.engine.core.view.items.avatar.ShoawdBitmap;
	import com.engine.core.view.scenes.Scene;
	import com.engine.core.view.scenes.SceneConstant;
	import com.engine.core.view.scenes.SceneEvent;
	import com.engine.core.view.scenes.SceneEventDispatcher;
	import com.engine.namespaces.coder;
	import com.engine.utils.gome.TileUitls;
	
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
	
	import gs.TweenLite;
	import gs.easing.Linear;

	public class Char extends Avatar 
	{

		public static const _radian_:Number = 180 / Math.PI;
		public static const _angle_:Number = Math.PI / 180;
		
		private static var bitmapScale9Grid:BitmapScale9Grid;
		private static var matrix:Matrix = new Matrix();
		
		public var popsinger:int;
		public var degree:Number;
		public var skill_tar_point:Point;
		public var suitURL:String;
		public var haloURL:String;
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
		protected var _sp:Number;
		protected var _sceneFlyMode:Boolean;
		protected var _speed_:int;
		
		private var buffSprite:Item;
		private var _walkEndFunc:Function;
		private var totlaNeedTime:int;
		private var _song_effect2:ItemAvatar;
		private var _song_effect:ItemAvatar;
		private var _halo_effect:ItemAvatar;
		private var _suit_effect:ItemAvatar;
		private var _wing_effect_1:ItemAvatar;
		private var _wing_effect_2:ItemAvatar;
		private var _dropShape:Shape;
		private var _suitVisible:Boolean = true;
		private var effectDic:Dictionary;
		private var timex:int = 0;
		private var overPoint:Point;
		private var jumpTimeNum:int;
		private var jumpTimerIndex:int;
		private var headArray:Dictionary;
		private var showList:Array;
		private var showTime:int = 0;
		private var actionPlaySpeed:int;
		private var jumpStartTime:int;
		private var tmp:int;

		public function Char()
		{
			this.jumpQuene = [];
			this.overPoint = new Point();
			super();
			this.type = SceneConstant.CHAR;
		}

		public static function createChar():Char
		{
			var _local_1:Char = (InstancePool.coder::getInstance().getAvatar(Char) as Char);
			_local_1.reset();
			return (_local_1);
		}


		public function get sceneFlyMode():Boolean
		{
			return (this._sceneFlyMode);
		}

		public function set sceneFlyMode(_arg_1:Boolean):void
		{
			this._sceneFlyMode = _arg_1;
		}

		public function get pathArr():Array
		{
			return (this._pathArr);
		}

		public function set pathArr(_arg_1:Array):void
		{
			this._pathArr = _arg_1;
		}

		public function get walkEndFunc():Function
		{
			return (this._walkEndFunc);
		}

		public function set walkEndFunc(_arg_1:Function):void
		{
			this._walkEndFunc = _arg_1;
		}

		public function get speed():Number
		{
			return (this._speed);
		}

		public function set speed(_arg_1:Number):void
		{
			this._speed = _arg_1;
			this._sp = _arg_1;
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
					bitmapScale9Grid = new BitmapScale9Grid(Core.chat_bitmapData, new Rectangle(1, 1, 100, 35));
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
			if (((this._dropShape) && (this._dropShape.parent))) {
				this._dropShape.parent.removeChild(this._dropShape);
			}
			this._dropShape = _arg_1;
			this.addChild(this._dropShape);
		}

		public function showWing(_arg_1:String, _arg_2:String):void
		{
			if (this._wing_effect_1) {
				this._wing_effect_1.dispose();
				if (this._wing_effect_1.parent) {
					this._wing_effect_1.parent.removeChild(this._wing_effect_1);
				}
			}
			this._wing_effect_1 = new ItemAvatar();
			if (this.isMainChar) {
				this._wing_effect_1.isAutoDispose = false;
			}
			this._wing_effect_1.avatarParts.isTimeoutDelete = false;
			this._wing_effect_1.avatarParts.lockEffectState = false;
			this._wing_effect_1.isSceneItem = false;
			this._wing_effect_1.loadAvatarPart(_arg_1);
			this._wing_effect_1.avatarParts.lockEffectPlaySpeed(true, this.effectSpeed);
			this.addChildAt(this._wing_effect_1, 0);
			this._wing_effect_1.visible = this.bodyVisible;
			this._wing_effect_1.play(CharAction.STAND);
			if (this._wing_effect_2) {
				this._wing_effect_2.dispose();
				if (this._wing_effect_2.parent) {
					this._wing_effect_2.parent.removeChild(this._wing_effect_2);
				}
			}
			this._wing_effect_2 = new ItemAvatar();
			if (this.isMainChar) {
				this._wing_effect_2.isAutoDispose = false;
			}
			this._wing_effect_2.avatarParts.lockEffectPlaySpeed(true, this.effectSpeed);
			this._wing_effect_2.avatarParts.isTimeoutDelete = false;
			this._wing_effect_2.avatarParts.lockEffectState = false;
			this._wing_effect_2.isSceneItem = false;
			this._wing_effect_2.loadAvatarPart(_arg_2);
			this.addChildAt(this._wing_effect_2, 0);
			this._wing_effect_2.visible = this.bodyVisible;
			this._wing_effect_2.play(CharAction.STAND);
		}

		public function removeWing():void
		{
			if (this._wing_effect_1) {
				if (this._wing_effect_1.parent) {
					removeChild(this._wing_effect_1);
				}
				this._wing_effect_1.dispose();
			}
			if (this._wing_effect_2) {
				if (this._wing_effect_2.parent) {
					removeChild(this._wing_effect_2);
				}
				this._wing_effect_2.dispose();
			}
			this._wing_effect_1 = null;
			this._wing_effect_2 = null;
		}

		override public function get transform():Transform
		{
			return (this.bitmapdata_mid.transform);
		}

		override public function set transform(_arg_1:Transform):void
		{
			this.bitmapdata_mid.transform = _arg_1;
		}

		public function setSuitVisible(_arg_1:Boolean):void
		{
			this._suitVisible = _arg_1;
			if (this._suit_effect) {
				this._suit_effect.visible = _arg_1;
			}
		}

		public function showSuit(_arg_1:String):void
		{
			this.suitURL = _arg_1;
			if (this._suit_effect) {
				this._suit_effect.dispose();
				if (this._suit_effect.parent) {
					this._suit_effect.parent.removeChild(this._suit_effect);
				}
			}
			this._suit_effect = new ItemAvatar();
			if (this.isMainChar) {
				this._suit_effect.isAutoDispose = false;
			}
			this._suit_effect.isSceneItem = false;
			this._suit_effect.avatarParts.lockEffectPlaySpeed(true, this.effectSpeed);
			this._suit_effect.loadAvatarPart(_arg_1);
			this.addChild(this._suit_effect);
			this._suit_effect.visible = this.bodyVisible;
		}

		public function removeSuit():void
		{
			this.suitURL = null;
			if (this._suit_effect) {
				if (this._suit_effect.parent) {
					removeChild(this._suit_effect);
				}
				this._suit_effect.dispose();
			}
			this._suit_effect = null;
		}

		public function showHaloBuffEffect(_arg_1:String, _arg_2:String=null):void
		{
			var _local_3:ItemAvatar;
			if (this.effectDic == null) {
				this.effectDic = new Dictionary();
			}
			if (((_arg_1) && ((this.effectDic[_arg_1] == null)))) {
				_local_3 = new ItemAvatar();
				if (this.isMainChar) {
					_local_3.isAutoDispose = false;
				}
				_local_3.isSceneItem = false;
				_local_3.avatarParts.lockEffectPlaySpeed(true, this.effectSpeed);
				_local_3.loadAvatarPart(_arg_1);
				if (_arg_2 == null) {
					this.addChild(_local_3);
					_local_3.visible = this.bodyVisible;
				} else {
					if (_arg_2 == SceneConstant.ITEM_LAYER) {
						this.addChildAt(_local_3, 0);
						_local_3.visible = this.bodyVisible;
					}
				}
				this.effectDic[_arg_1] = _local_3;
			}
		}

		public function removeHaloBuffEffect(_arg_1:String):void
		{
			var _local_2:ItemAvatar;
			if (((this.effectDic) && (this.effectDic[_arg_1]))) {
				_local_2 = this.effectDic[_arg_1];
				_local_2.dispose();
				if (_local_2.parent) {
					_local_2.parent.removeChild(_local_2);
				}
				delete this.effectDic[_arg_1];
			}
		}

		override public function loadAvatarPart(_arg_1:String, _arg_2:AvatarRestrict=null):String
		{
			var _local_3:String = super.loadAvatarPart(_arg_1, _arg_2);
			if (this._halo_effect) {
				if (isOnMonut) {
					this._halo_effect.y = 20;
				} else {
					this._halo_effect.y = 0;
				}
			}
			return (_local_3);
		}

		public function showHalo(_arg_1:String):void
		{
			this.haloURL = _arg_1;
			if (this._halo_effect) {
				this._halo_effect.dispose();
				if (this._halo_effect.parent) {
					this._halo_effect.parent.removeChild(this._halo_effect);
				}
			}
			this._halo_effect = new ItemAvatar();
			if (this.isMainChar) {
				this._halo_effect.isAutoDispose = false;
			}
			this._halo_effect.avatarParts.lockEffectPlaySpeed(true, this.effectSpeed);
			this._halo_effect.isSceneItem = false;
			this._halo_effect.loadAvatarPart(_arg_1);
			this._halo_effect.visible = this.bodyVisible;
			shape.addChild(this._halo_effect);
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

		public function removeHalo():void
		{
			this.haloURL = null;
			if (this._halo_effect) {
				if (this._halo_effect.parent) {
					this._halo_effect.parent.removeChild(this._halo_effect);
				}
				this._halo_effect.dispose();
			}
			this._halo_effect = null;
		}

		public function removeSongEffect():void
		{
			if (this._song_effect) {
				if (this._song_effect.parent) {
					this._song_effect.parent.removeChild(this._song_effect);
				}
				this._song_effect.dispose();
			}
			if (this._song_effect2) {
				this._song_effect2.dispose();
				if (this._song_effect2.parent) {
					this._song_effect2.parent.removeChild(this._song_effect2);
				}
			}
			this._song_effect2 = null;
			this._song_effect = null;
		}

		public function showSongEffect(_arg_1:String, _arg_2:String):void
		{
			if (this._song_effect) {
				this._song_effect.dispose();
				if (this._song_effect.parent) {
					this.removeChild(this._song_effect);
				}
			}
			if (this._song_effect2) {
				this._song_effect2.dispose();
				if (this._song_effect2.parent) {
					this._song_effect2.parent.removeChild(this._song_effect2);
				}
			}
			if (((_arg_1) && (!((_arg_1 == ""))))) {
				this._song_effect = new ItemAvatar();
				if (this.isMainChar) {
					this._song_effect.isAutoDispose = false;
				}
				this._song_effect.avatarParts.lockEffectPlaySpeed(true, this.effectSpeed);
				this._song_effect.isSceneItem = false;
				this._song_effect.loadAvatarPart(_arg_1);
				this._song_effect.dir = this.dir;
				this._song_effect.y = this.onMonutHeight;
				this.addChildAt(this._song_effect, 0);
				this._song_effect.visible = this.bodyVisible;
			}
			if (((_arg_2) && (!((_arg_2 == ""))))) {
				this._song_effect2 = new ItemAvatar();
				if (this.isMainChar) {
					this._song_effect2.isAutoDispose = false;
				}
				this._song_effect2.avatarParts.lockEffectPlaySpeed(true, this.effectSpeed);
				this._song_effect2.isSceneItem = false;
				this._song_effect2.loadAvatarPart(_arg_2);
				this._song_effect2.dir = this.dir;
				this._song_effect2.y = this.onMonutHeight;
				this.addChild(this._song_effect2);
				this._song_effect2.visible = this.bodyVisible;
			}
		}

		override public function set bodyVisible(_arg_1:Boolean):void
		{
			var _local_2:ItemAvatar;
			super.bodyVisible = _arg_1;
			if (this._song_effect) {
				this._song_effect.visible = _arg_1;
			}
			if (this._song_effect2) {
				this._song_effect2.visible = _arg_1;
			}
			if (this._halo_effect) {
				this._halo_effect.visible = _arg_1;
			}
			if (this._suit_effect) {
				this._suit_effect.visible = _arg_1;
			}
			if (this._wing_effect_1) {
				this._wing_effect_1.visible = _arg_1;
			}
			if (this._wing_effect_2) {
				this._wing_effect_2.visible = _arg_1;
			}
			if (this.buffSprite) {
				this.buffSprite.visible = _arg_1;
			}
			if (this.wordShape) {
				this.wordShape.visible = _arg_1;
			}
			if (this.effectDic) {
				for each (_local_2 in this.effectDic) {
					if (_local_2.parent) {
						_local_2.parent.removeChild(_local_2);
					}
					_local_2.visible = _arg_1;
				}
			}
			this.stop = !(_arg_1);
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
			if (((((avatarParts) && (!((avatarParts.state == CharAction.STAND))))) && ((((((((this.type == SceneConstant.CAR)) || ((this.type == SceneConstant.MONSTER)))) || ((this.type == SceneConstant.PET)))) || ((this.type == SceneConstant.SUMMON_MONSTER)))))) {
				avatarParts.acce = (this._speed / 120);
				if (avatarParts.acce < 1) {
					avatarParts.acce = 1;
				}
			}
			super.onRender(_arg_1, _arg_2, _arg_3, _arg_4, _arg_5, _arg_6, _arg_7, _arg_8, _arg_9);
			this.updateWord();
			if (this._suit_effect) {
				if (this._suit_effect.parent) {
					this.addChild(this._suit_effect);
				}
				if (this._suit_effect.y != this.onMonutHeight) {
					this._suit_effect.y = this.onMonutHeight;
				}
			}
			if (this._song_effect2) {
				if (this._song_effect2.y != this.onMonutHeight) {
					this._song_effect2.y = this.onMonutHeight;
				}
			}
			if (this._song_effect) {
				if (this._song_effect.y != this.onMonutHeight) {
					this._song_effect.y = this.onMonutHeight;
				}
			}
			if (this._wing_effect_1) {
				if (this._wing_effect_1.dir != this.dir) {
					this._wing_effect_1.dir = this.dir;
				}
				if (this._wing_effect_1.y != this.onMonutHeight) {
					this._wing_effect_1.y = this.onMonutHeight;
				}
			}
			if (this._wing_effect_2) {
				if (this._wing_effect_2.dir != this.dir) {
					this._wing_effect_2.dir = this.dir;
				}
				if (this._wing_effect_2.y != this.onMonutHeight) {
					this._wing_effect_2.y = this.onMonutHeight;
				}
			}
			this.wingDepth();
			if (this.buffSprite) {
				if (this.buffSprite.y != (-50 + this.onMonutHeight)) {
					this.buffSprite.y = (-50 + this.onMonutHeight);
				}
			}
			if (this.effectDic) {
				for each (_local_12 in this.effectDic) {
					if (_local_12.parent) {
						if (this.bitmapdata_midm) {
							_local_10 = this.getChildIndex(_local_12);
							_local_11 = this.getChildIndex(bitmapdata_midm);
							if (_local_10 < _local_11) {
								this.swapChildren(_local_12, bitmapdata_midm);
							}
						}
						_local_12.y = this.onMonutHeight;
					}
				}
			}
		}

		private function wingDepth():void
		{
			if (this._wing_effect_1) {
				if (((((((this.bitmapdata_midm) && (this.bitmapdata_midm.parent))) && (this.bitmapdata_fid))) && (bitmapdata_fid.parent))) {
					if ((((((dir == 0)) || ((dir == 1)))) || ((dir == 7)))) {
						if (((this._wing_effect_1) && (this._wing_effect_1.stage))) {
							this.addChild(this._wing_effect_1);
						}
						if (((this._wing_effect_2) && (this._wing_effect_2.stage))) {
							this.addChild(this._wing_effect_2);
						}
					} else {
						if (dir == 2) {
							if (((bitmapdata_midm) && (bitmapdata_midm.stage))) {
								this.addChild(this.bitmapdata_midm);
							}
							if (((bitmapdata_mid) && (bitmapdata_mid.stage))) {
								this.addChild(bitmapdata_mid);
							}
							if (((this._wing_effect_1) && (this._wing_effect_1.stage))) {
								this.addChild(this._wing_effect_1);
							}
							if (((this._wing_effect_2) && (this._wing_effect_2.stage))) {
								this.addChild(this._wing_effect_2);
							}
							if (((bitmapdata_fid) && (bitmapdata_fid.stage))) {
								this.addChild(this.bitmapdata_fid);
							}
						} else {
							if (dir == 3) {
								if (((this._wing_effect_1) && (this._wing_effect_1.stage))) {
									this.addChild(this._wing_effect_1);
								}
								if (((bitmapdata_mid) && (bitmapdata_mid.stage))) {
									this.addChild(bitmapdata_mid);
								}
								if (((bitmapdata_midm) && (bitmapdata_midm.stage))) {
									this.addChild(this.bitmapdata_midm);
								}
								if (((this._wing_effect_2) && (this._wing_effect_2.stage))) {
									this.addChild(this._wing_effect_2);
								}
								if (((bitmapdata_fid) && (bitmapdata_fid.stage))) {
									this.addChild(this.bitmapdata_fid);
								}
							} else {
								if (dir == 4) {
									if (((bitmapdata_midm) && (bitmapdata_midm.stage))) {
										this.addChild(this.bitmapdata_midm);
									}
									if (((this._wing_effect_1) && (this._wing_effect_1.stage))) {
										this.addChild(this._wing_effect_1);
									}
									if (((this._wing_effect_2) && (this._wing_effect_2.stage))) {
										this.addChild(this._wing_effect_2);
									}
									if (((bitmapdata_mid) && (bitmapdata_mid.stage))) {
										this.addChild(bitmapdata_mid);
									}
									if (((bitmapdata_fid) && (bitmapdata_fid.stage))) {
										this.addChild(this.bitmapdata_fid);
									}
								} else {
									if ((((dir == 5)) || ((dir == 6)))) {
										if (((this._wing_effect_1) && (this._wing_effect_1.stage))) {
											this.addChild(this._wing_effect_1);
										}
										if (((bitmapdata_mid) && (bitmapdata_mid.stage))) {
											this.addChild(this.bitmapdata_mid);
										}
										if (((bitmapdata_midm) && (bitmapdata_midm.stage))) {
											this.addChild(this.bitmapdata_midm);
										}
										if (((bitmapdata_fid) && (bitmapdata_fid.stage))) {
											this.addChild(this.bitmapdata_fid);
										}
										if (((this._wing_effect_2) && (this._wing_effect_2.stage))) {
											this.addChild(this._wing_effect_2);
										}
									}
								}
							}
						}
					}
				}
			}
		}

		override public function play(_arg_1:String, _arg_2:AvatarRestrict=null, _arg_3:Boolean=false, _arg_4:Function=null, _arg_5:Boolean=true):void
		{
			if (this.isBackMoving == false) {
				clearTimeout(this.jumpTimerIndex);
				super.play(_arg_1, _arg_2, _arg_3, _arg_4, _arg_5);
				if (this._wing_effect_1) {
					this._wing_effect_1.play(_arg_1);
					this._wing_effect_2.play(_arg_1);
				}
			}
		}

		override public function set alpha(_arg_1:Number):void
		{
			super.alpha = _arg_1;
			if (this.headShape) {
				this.headShape.alpha = _arg_1;
			}
			if (this.shadowShape) {
				this.shadowShape.alpha = _arg_1;
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

		override public function addChild(_arg_1:DisplayObject):DisplayObject
		{
			if (((this.isMainChar) && ((_arg_1 as ItemAvatar)))) {
				ItemAvatar(_arg_1).isAutoDispose = false;
			}
			return (super.addChild(_arg_1));
		}

		override public function addChildAt(_arg_1:DisplayObject, _arg_2:int):DisplayObject
		{
			if (((this.isMainChar) && ((_arg_1 as ItemAvatar)))) {
				ItemAvatar(_arg_1).isAutoDispose = false;
			}
			return (super.addChildAt(_arg_1, _arg_2));
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

		override public function set isDeath(_arg_1:Boolean):void
		{
			_isDeath = _arg_1;
			if (this.walkEndFunc != null) {
				this.walkEndFunc = null;
			}
			if (_arg_1) {
				this.setSuitVisible(false);
			} else {
				this.setSuitVisible(true);
			}
			this.stopMove();
		}

		override public function set pt(_arg_1:SquarePt):void
		{
			super.pt = _arg_1;
		}

		override public function set point(_arg_1:Point):void
		{
			super.point = _arg_1;
		}

		override public function set x(_arg_1:Number):void
		{
			super.x = _arg_1;
			this.setAlpha();
			this.name = this.name;
		}

		override public function set y(_arg_1:Number):void
		{
			super.y = _arg_1;
			this.setAlpha();
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
			if (Core.stopMove) {
				this.jumping = false;
				this.runing = false;
				this.pathArr = [];
				if (this.meditation) {
					this.doMeditation(true);
				} else {
					if (((!(this.jumping)) && ((avatarParts.state == CharAction.WALK)))) {
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

		public function faceTo(_arg_1:Avatar):void
		{
			if (this.jumping == false) {
				if (_arg_1) {
					this.dir = this.getDretion(_arg_1.x, _arg_1.y);
				}
			}
		}

		public function setRotation(_arg_1:Number, _arg_2:Number):void
		{
			var _local_3:Number = (this.x - _arg_1);
			var _local_4:Number = (this.y - _arg_2);
			var _local_5:Number = ((Math.atan2(_local_4, _local_3) * 180) / Math.PI);
			this.rotation = _local_5;
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
			this.overPoint = new Point();
			this.meditation = false;
			this.speed = 0;
			this.tar_point = null;
			this._point = new Point();
			this.openShadow = false;
			this.x = 0;
			this.y = 0;
			if (this._halo_effect) {
				if (this._halo_effect.parent) {
					this._halo_effect.parent.removeChild(this._halo_effect);
				}
				this._halo_effect.dispose();
			}
			if (this._wing_effect_1) {
				if (this._wing_effect_1.parent) {
					this._wing_effect_1.parent.removeChild(this._wing_effect_1);
				}
				this._wing_effect_1.dispose();
			}
			if (this._wing_effect_2) {
				if (this._wing_effect_2.parent) {
					this._wing_effect_2.parent.removeChild(this._wing_effect_2);
				}
				this._wing_effect_2.dispose();
			}
			this._song_effect = null;
			this._halo_effect = null;
			this._suit_effect = null;
			this._wing_effect_1 = null;
			this._wing_effect_2 = null;
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
			this._suitVisible = true;
			this.char_id = null;
			this.jump_deafult_speed = 335;
			this.jumpQuene = [];
			super.reset();
			if (this.isMainChar) {
				_ap.isAutoDispose = false;
			}
		}

		private function onCompleteFunc():void
		{
			this.avatarParts.vs = 0;
		}

		public function moving():void
		{
			var _local_1:int;
			if (!Core.sandBoxEnabled) {
				return;
			}
			if (this.avatarParts == null) {
				this.pathArr = [];
				this.runing = false;
				return;
			}
			if (((((((((this.pathArr) && ((this.pathArr.length >= 0)))) && (((jumping) || (runing))))) && (!(this.isDeath)))) && ((((avatarParts.state == CharAction.WALK)) || ((avatarParts.state == CharAction.SKILL2)))))) {
				_local_1 = getTimer();
				if (this == Scene.scene.mainChar) {
					Core.moveTime = ((_local_1 - this.time) / 100);
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
				this._speed_ = this.jump_deafult_speed;
			} else {
				this._speed_ = this.speed;
			}
			if (jumping) {
				if (this.pathArr.length <= (this.jumpIndex / 2)) {
					this._speed_ = (this._speed_ + (((this.jumpIndex / 2) - this.pathArr.length) * 2));
				} else {
					this._speed_ = (this._speed_ - ((this.pathArr.length - (this.jumpIndex / 2)) * 2));
				}
				if (this.pathArr.length > 1) {
					this.createShoawBitmap();
				}
			}
			var _local_2:Number = Point.distance(this.point, this.tar_point);
			var _local_3:Number = ((_local_2 / this._speed_) * 1000);
			if (this.totalTime >= _local_3) {
				this.totalTime = (this.totalTime - _local_3);
			} else {
				_local_3 = this.totalTime;
				this.totalTime = 0;
			}
			var _local_4:Number = ((this._speed_ * _local_3) / 1000);
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
				if ((Core.delayTime - this.jumpTimeNum) > 120) {
					_local_1 = new Rectangle();
					if (((bitmapdata_mid) && (bitmapdata_mid.bitmapData))) {
						_local_1 = _local_1.union(bitmapdata_mid.bitmapData.rect);
					}
					if (_local_1.isEmpty() == false) {
						_local_2 = new BitmapData(_local_1.width, _local_1.height, true, 0);
						_local_2.copyPixels(bitmapdata_mid.bitmapData, bitmapdata_mid.bitmapData.rect, new Point());
						_local_3 = new ShoawdBitmap(_local_2);
						_local_3.alpha = 0.9;
						_local_3.x = (this.x - (_local_2.width / 2));
						_local_3.y = ((this.y - _local_2.height) + this.onMonutHeight);
						Scene.scene.$itemLayer.addChild(_local_3);
					}
					this.jumpTimeNum = Core.delayTime;
				}
			}
		}

		public function doMeditation(_arg_1:Boolean, _arg_2:Boolean=false):void
		{
			this.meditation = _arg_1;
			this.isGroupSongModel = _arg_2;
			if (_arg_1) {
				this.play(CharAction.MEDITATION);
			} else {
				if (((!(this.runing)) && (!(this.jumping)))) {
					if (this.avatarParts.state == CharAction.MEDITATION) {
						this.play(CharAction.STAND);
					}
				}
			}
		}

		protected function walkEnd():void
		{
			var t:int;
			var ee:SceneEvent = new SceneEvent(SceneEvent.WALK_END);
			ee.proto = this;
			this.shadowMode = false;
			this.totalTime = 0;
			this.runing = false;
			if (((!(this.walkendStandOutSide)) && (this.runing))) {
				this.play("stand");
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
				t = (getTimer() - this.jumpStartTime);
				if (t < 500) {
					this.jumpTimerIndex = setTimeout(function ():void
					{
						play("stand");
					}, (500 - t));
				} else {
					this.play("stand");
				}
			}
			if (this.meditation) {
				this.doMeditation(true);
			}
			if (this.tar_point) {
				this.point = this.tar_point;
			}
			this.tar_point = null;
			if (this.walkEndFunc != null) {
				this.walkEndFunc();
			}
			SceneEventDispatcher.getInstance().dispatchEvent(ee);
		}

		public function reLoadHaloBuffEffect():void
		{
			var _local_1:String;
			if (this.effectDic) {
				for (_local_1 in this.effectDic) {
					this.removeHaloBuffEffect(_local_1);
					this.showHaloBuffEffect(_local_1, SceneConstant.ITEM_LAYER);
				}
			}
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
					_local_6 = TileUitls.getIsoIndexMidVertex(_local_5);
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
			if (Core.stage) {
				if (Core.stage.frameRate < 5) {
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
				this.showTime = Core.delayTime;
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
			if (this._dropShape) {
				this._dropShape.parent.removeChild(this._dropShape);
			}
			this._dropShape = null;
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
			if (this._song_effect) {
				if (this._song_effect.parent) {
					this.removeChild(this._song_effect);
				}
				this._song_effect.dispose();
			}
			this._song_effect = null;
			if (this._song_effect2) {
				this._song_effect2.dispose();
				if (this._song_effect2.parent) {
					this._song_effect2.parent.removeChild(this._song_effect2);
				}
			}
			this._song_effect2 = null;
			if (this._halo_effect) {
				if (this._halo_effect.parent) {
					this._halo_effect.parent.removeChild(this._halo_effect);
				}
				this._halo_effect.dispose();
			}
			this._halo_effect = null;
			if (this._wing_effect_1) {
				if (this._wing_effect_1.parent) {
					this._wing_effect_1.parent.removeChild(this._wing_effect_1);
				}
				this._wing_effect_1.dispose();
			}
			this._wing_effect_1 = null;
			if (this._wing_effect_2) {
				if (this._wing_effect_2.parent) {
					this._wing_effect_2.parent.removeChild(this._wing_effect_2);
				}
				this._wing_effect_2.dispose();
			}
			this._wing_effect_2 = null;
			if (this._suit_effect) {
				if (this._suit_effect.parent) {
					removeChild(this._suit_effect);
				}
				this._suit_effect.dispose();
			}
			this._suit_effect = null;
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
			this.haloURL = null;
			this.suitURL = null;
			this.headVisible = true;
			this.pathArr = [];
			this._point = new Point();
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
			this.suitURL = null;
			this.haloURL = null;
			this.isTeleporting = false;
			this.showList = null;
			if (this.headArray) {
				for each (_local_1 in this.headArray) {
					_local_1.dispose();
				}
			}
			this.headArray = null;
			if (this._dropShape) {
				this._dropShape.parent.removeChild(this._dropShape);
			}
			this._dropShape = null;
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
			if (this._song_effect) {
				this.removeChild(this._song_effect);
				this._song_effect.dispose();
			}
			this._song_effect = null;
			if (this._song_effect2) {
				this._song_effect2.dispose();
				if (this._song_effect2.parent) {
					this._song_effect2.parent.removeChild(this._song_effect2);
				}
			}
			this._song_effect2 = null;
			if (this._halo_effect) {
				if (this._halo_effect.parent) {
					this.removeChild(this._halo_effect);
				}
				this._halo_effect.dispose();
			}
			this._halo_effect = null;
			if (this._wing_effect_1) {
				if (this._wing_effect_1.parent) {
					this.removeChild(this._wing_effect_1);
				}
				this._wing_effect_1.dispose();
			}
			this._wing_effect_1 = null;
			if (this._wing_effect_2) {
				if (this._wing_effect_2.parent) {
					this.removeChild(this._wing_effect_2);
				}
				this._wing_effect_2.dispose();
			}
			this._wing_effect_2 = null;
			if (this._suit_effect) {
				if (this._suit_effect.parent) {
					removeChild(this._suit_effect);
				}
				this._suit_effect.dispose();
			}
			this._suit_effect = null;
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
			this.overPoint = null;
			this.tar_point = null;
			this.cur_point = null;
			this._pt = null;
			this._point = null;
			this.jumpQuene = [];
			this.hp_height = 110;
		}

		public function shadowMove(_arg_1:Array):void
		{
		}

		public function jump(_arg_1:Array, _arg_2:Boolean=true, _arg_3:int=0):void
		{
			var _local_6:Point;
			var _local_7:AvatarRestrict;
			var _local_8:int;
			var _local_9:Number;
			var _local_10:Number;
			if (((this.jumping) || (!(avatarParts)))) {
				return;
			}
			if (((!(_arg_1)) || ((_arg_1.length == 0)))) {
				return;
			}
			this.actionPlaySpeed = this.avatarParts.attackSpeed;
			this.meditation = false;
			this.isGroupSongModel = false;
			this.jumpIndex = _arg_1.length;
			var _local_4:int = Point.distance(_arg_1[0], _arg_1[(_arg_1.length - 1)]);
			var _local_5:int = this.speed;
			this.jump_deafult_speed = ((this.speed * 2) + ((this.speed / 2) * (1 - (_local_4 / 400))));
			this.avatarParts.attackSpeed = ((this.actionPlaySpeed * _local_4) / 400);
			if (this.isOnMonut == false) {
				this.shadowMode = false;
			}
			this.pathArr = _arg_1.slice();
			if (this.pathArr.length > 0) {
				_local_6 = this.pathArr[(this.pathArr.length - 1)];
				dir = this.getDretion(_local_6.x, _local_6.y);
				_local_7 = new AvatarRestrict();
				this.jumpStartTime = getTimer();
				clearTimeout(this.jumpTimerIndex);
				this.avatarParts.currentFrame;
				this.play(CharAction.SKILL2, null, true);
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
				_local_8 = this.needTime(_arg_1, (this.jump_deafult_speed * 0.96));
				_local_9 = _arg_1[(_arg_1.length - 1)].x;
				_local_10 = _arg_1[(_arg_1.length - 1)].y;
				TweenLite.to(shape, (_local_8 / 1000), {
					"x":_local_9,
					"y":_local_10,
					"ease":Linear.easeNone
				});
			} else {
				if (avatarParts.state == CharAction.SKILL2) {
					this.play("stand");
				}
			}
		}

		public function set state(_arg_1:String):void
		{
			this.avatarParts.state = _arg_1;
			this.loadCharActionAssets(_arg_1);
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

		public function walk(_arg_1:Array):void
		{
			var _local_2:int;
			var _local_3:int;
			var _local_4:int;
			var _local_5:int;
			if (_arg_1.length == 1) {
				_local_2 = (_arg_1[0].x / TileConstant.TILE_SIZE);
				_local_3 = (_arg_1[0].y / TileConstant.TILE_SIZE);
				_local_4 = (this.x / TileConstant.TILE_SIZE);
				_local_5 = (this.y / TileConstant.TILE_SIZE);
				if ((((_local_2 == _local_4)) && ((_local_3 == _local_5)))) {
					return;
				}
			}
			this.tmp = getTimer();
			if (!avatarParts) {
				return;
			}
			this.isGroupSongModel = false;
			this.meditation = false;
			this.removeSongEffect();
			if (!this.jumping) {
				clearTimeout(this.jumpTimerIndex);
				if (((!((this.avatarParts.state == CharAction.WALK))) && (!((this.avatarParts.state == CharAction.STAND))))) {
					this.play("stand");
				}
				this.pathArr = _arg_1.slice();
				if (this.pathArr.length > 0) {
					if (this.needTime(_arg_1) > 10000) {
					}
					if (avatarParts) {
						this.state = CharAction.WALK;
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
					if (this.avatarParts.state == CharAction.WALK) {
						this.play("stand");
					}
				}
			} else {
				if (this.avatarParts.state == CharAction.WALK) {
					this.play("stand");
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

		public function getDretion(_arg_1:Number, _arg_2:Number):int
		{
			var _local_3:int;
			var _local_4:Number = (this.x - _arg_1);
			var _local_5:Number = (this.y - _arg_2);
			var _local_6:Number = ((Math.atan2(_local_5, _local_4) * 180) / Math.PI);
			if ((((_local_6 >= -15)) && ((_local_6 < 15)))) {
				_local_3 = 6;
			} else {
				if ((((_local_6 >= 15)) && ((_local_6 < 75)))) {
					_local_3 = 7;
				} else {
					if ((((_local_6 >= 75)) && ((_local_6 < 105)))) {
						_local_3 = 0;
					} else {
						if ((((_local_6 >= 105)) && ((_local_6 < 170)))) {
							_local_3 = 1;
						} else {
							if ((((_local_6 >= 170)) || ((_local_6 < -170)))) {
								_local_3 = 2;
							} else {
								if ((((_local_6 >= -75)) && ((_local_6 < -15)))) {
									_local_3 = 5;
								} else {
									if ((((_local_6 >= -105)) && ((_local_6 < -75)))) {
										_local_3 = 4;
									} else {
										if ((((_local_6 >= -170)) && ((_local_6 < -105)))) {
											_local_3 = 3;
										}
									}
								}
							}
						}
					}
				}
			}
			return (_local_3);
		}

	}
}
