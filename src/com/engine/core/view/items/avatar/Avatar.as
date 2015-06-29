package com.engine.core.view.items.avatar
{
	import com.engine.core.Core;
	import com.engine.core.ItemConst;
	import com.engine.core.RecoverUtils;
	import com.engine.core.model.IProto;
	import com.engine.core.tile.square.Square;
	import com.engine.core.tile.square.SquareGroup;
	import com.engine.core.tile.square.SquarePt;
	import com.engine.core.view.items.InstancePool;
	import com.engine.core.view.items.NoderItem;
	import com.engine.core.view.scenes.Scene;
	import com.engine.core.view.scenes.SceneConstant;
	import com.engine.namespaces.coder;
	import com.engine.utils.Hash;
	import com.engine.utils.HitTest;
	import com.engine.utils.gome.SquareUitls;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	public class Avatar extends NoderItem implements IAvatar 
	{

		public static const _radian_:Number = (180 / Math.PI);
		public static const _angle_:Number = (Math.PI / 180);
		
		public static var stageRect:Rectangle = new Rectangle();
		
		private static var intersectsRect:Rectangle = new Rectangle(0, 0, 1, 1);
		private static var op:Point = new Point();

		public var playEndFunc:Function;
		public var playEeffectFunc:Function;
		public var shadowMode:Boolean = false;
		public var sit_speed:int = 1;
		public var isGroupSongModel:Boolean = false;
		public var curr_rect:Rectangle;
		
		protected var _ap:AvatartParts;
		protected var bitmapdata_mid:Bitmap;
		protected var bitmapdata_wid:Bitmap;
		protected var bitmapdata_midm:Bitmap;
		protected var bitmapdata_fid:Bitmap;
		protected var bitmapdata_wgid:Bitmap;
		protected var eid_avatarBitmaps:Dictionary;
		protected var $isDisposed:Boolean = false;
		protected var _pt:SquarePt;
		protected var _point:Point;
		protected var shape:ShoadwShape;
		protected var _name:String;
		protected var _filters:Array;
		protected var onMonutHeight:int;
		protected var _headShape:HeadShape;
		protected var _isDeath:Boolean = false;
		protected var playEndHash:Hash;
		protected var height_old:int = 110;
		protected var onMonutDir:int = 0;
		protected var $playEndHash:Dictionary;
		protected var _headIconVisible:Boolean = true;
		protected var _iconSprite:Bitmap;
		protected var shoadwShape:Sprite;
		protected var _flying:Boolean;
		protected var _visible:Boolean = true;
		protected var _isFlyMode:Boolean = false;
		protected var _fuzzyMode:Boolean;
		protected var _isAutoDispose:Boolean = true;
		protected var _bodyVisible:Boolean = true;
		protected var $playEndFunc:Function;
		protected var $playState:String;
		
		private var isShowbodyShoadw:Boolean = false;
		private var _runing:Boolean = false;
		private var _jumping:Boolean = false;
		private var _monutHeight:int = -80;
		private var _isOnMonut:Boolean = false;
		private var hpHeight:int = 110;
		private var _headVisible:Boolean;
		private var deayTime:int;
		private var headIconUrl:String;
		private var timerId:int = 0;
		private var effectPlayEndDic:Dictionary;
		private var deayState:String;
		private var deayRestrict:AvatarRestrict;
		private var fly_vx:Number;
		private var fly_vy:Number;
		private var old_dir:int;
		private var sit_a:int = -1;
		private var sit_vy:int = 1;

		public function Avatar()
		{
			this._point = new Point();
			super();
			this.playEndHash = new Hash();
			this._point = new Point();
			this.setup();
		}

		public static function createAvatar():Avatar
		{
			var _local_1:Avatar = (InstancePool.coder::getInstance().getAvatar(Avatar) as Avatar);
			_local_1.point = new Point();
			_local_1.avatarParts = new AvatartParts();
			_local_1.isSceneItem = true;
			_local_1.avatarParts.type = "Avatar";
			_local_1.avatarParts.onRender = _local_1.onRender;
			_local_1.avatarParts.playEndFunc = _local_1.playEndFunc;
			_local_1.avatarParts.playEffectFunc = _local_1.playEeffectFunc;
			_local_1.avatarParts.setupReady = coder::setupReady;
			_local_1.avatarParts.disposeEffectsFunc = _local_1.disposeEffects;
			_local_1.avatarParts.coder::oid = _local_1.id;
			_local_1.dir = 0;
			_local_1.isDisposed = false;
			return (_local_1);
		}


		public function get isFlyMode():Boolean
		{
			return (this._isFlyMode);
		}

		public function set isFlyMode(_arg_1:Boolean):void
		{
			this._isFlyMode = _arg_1;
			if (this.avatarParts) {
				this.avatarParts.isFlyMode = _arg_1;
			}
		}

		public function get monutHeight():int
		{
			return (this.onMonutHeight);
		}

		public function set monutHeight(_arg_1:int):void
		{
			this._monutHeight = -(Math.abs(_arg_1));
		}

		coder function get bodyBitmap():Bitmap
		{
			return (this.bitmapdata_mid);
		}

		public function set hp_height(_arg_1:Number):void
		{
			this.hpHeight = _arg_1;
			this.height_old = _arg_1;
		}

		public function get hp_height():Number
		{
			return (this.height_old);
		}

		public function get flying():Boolean
		{
			if ((this.onMonutHeight == 0)) {
				this._flying = false;
			} else {
				this._flying = true;
			}
			return (this._flying);
		}

		public function get jumping():Boolean
		{
			return (this._jumping);
		}

		public function set jumping(_arg_1:Boolean):void
		{
			this._jumping = _arg_1;
			if (this.avatarParts) {
				this.avatarParts.jumping = _arg_1;
			}
		}

		public function get runing():Boolean
		{
			if (((this.avatarParts) && (!((this.avatarParts.state == CharAction.WALK))))) {
				this._runing = false;
			}
			return (this._runing);
		}

		public function set runing(_arg_1:Boolean):void
		{
			this._runing = _arg_1;
			if (this.avatarParts) {
				this.avatarParts.runing = _arg_1;
			}
		}

		public function showTiles(_arg_1:Array):void
		{
			if (this.headShape) {
				this.headShape.showTitles(_arg_1);
				this.updateUiPos();
			}
		}

		public function set isAutoDispose(_arg_1:Boolean):void
		{
			this._isAutoDispose = _arg_1;
			if (this._ap) {
				this._ap.isAutoDispose = _arg_1;
			}
		}

		public function get headShape():HeadShape
		{
			if (!this.isDisposed) {
				if (this._headShape == null) {
					this._headShape = new HeadShape();
					this._headShape.owner = this;
				}
				if ((((this._headShape.parent == null)) && (((this.parent) || (this._headVisible))))) {
					if (Scene.scene.getSceneFlyMode()) {
						Scene.scene.$flyLayer.addChild(this._headShape);
					} else {
						Scene.scene.$topLayer.addChild(this._headShape);
					}
				}
				return (this._headShape);
			}
			return (null);
		}

		override public function set scaleX(_arg_1:Number):void
		{
			super.scaleX = _arg_1;
			if (this._headShape) {
				this._headShape.scaleX = _arg_1;
			}
		}

		override public function set scaleY(_arg_1:Number):void
		{
			super.scaleY = _arg_1;
			if (this._headShape) {
				this._headShape.scaleY = _arg_1;
			}
		}

		public function get shadowShape():Sprite
		{
			return (this.shape);
		}

		public function set openShadow(_arg_1:Boolean):void
		{
			var _local_2:Matrix;
			if (_arg_1) {
				if (this.shape == null) {
					this.shape = new ShoadwShape();
					this.shape.moveFunc = coder::flyerMove;
				}
				this.shape.owner = this;
				this.shape.graphics.clear();
				Scene.scene.$itemLayer.addChild(this.shape);
				_local_2 = RecoverUtils.matrix;
				_local_2.tx = (-(Core.char_shadow.width) / 2);
				_local_2.ty = (-(Core.char_shadow.height) / 2);
				this.shape.graphics.beginBitmapFill(Core.char_shadow, _local_2);
				this.shape.graphics.drawRect((-(Core.char_shadow.width) / 2), (-(Core.char_shadow.height) / 2), Core.char_shadow.width, Core.char_shadow.height);
				this.shape.cacheAsBitmap = true;
				if (this.shape.parent == null) {
					Scene.scene.$itemLayer.addChild(this.shape);
				}
			} else {
				if (this.shape) {
					this.shape.dispose();
				}
				this.shape = null;
			}
		}

		public function onMountShoadw(_arg_1:Boolean):void
		{
			var _local_2:Matrix;
			if (this.shape) {
				if (!_arg_1) {
					this.shape.graphics.clear();
					_local_2 = RecoverUtils.matrix;
					_local_2.tx = (-(Core.char_big_shadow.width) / 2);
					_local_2.ty = ((-(Core.char_big_shadow.height) / 2) + 10);
					this.shape.graphics.beginBitmapFill(Core.char_big_shadow, _local_2);
					this.shape.graphics.drawRect(_local_2.tx, _local_2.ty, Core.char_big_shadow.width, Core.char_big_shadow.height);
					this.shape.cacheAsBitmap = true;
				} else {
					this.shape.graphics.clear();
					_local_2 = RecoverUtils.matrix;
					_local_2.tx = (-(Core.char_shadow.width) / 2);
					_local_2.ty = (-(Core.char_shadow.height) / 2);
					this.shape.graphics.beginBitmapFill(Core.char_shadow, _local_2);
					this.shape.graphics.drawRect((-(Core.char_shadow.width) / 2), (-(Core.char_shadow.height) / 2), Core.char_shadow.width, Core.char_shadow.height);
					this.shape.cacheAsBitmap = true;
				}
			}
		}

		override public function set type(_arg_1:String):void
		{
			super.type = _arg_1;
			if ((((((((this.type == SceneConstant.CHAR)) || ((this.type == SceneConstant.MONSTER)))) || ((this.type == SceneConstant.NPC)))) || ((this.type == SceneConstant.SPECIAL_NPC)))) {
				this.isShowbodyShoadw = true;
			} else {
				this.isShowbodyShoadw = false;
			}
			this.deayTime = getTimer();
			if (this._ap) {
				this._ap.type = _arg_1;
			}
		}

		public function get isOnMonut():Boolean
		{
			return (this._isOnMonut);
		}

		public function set isOnMonut(_arg_1:Boolean):void
		{
			this.avatarParts.isOnMonut = _arg_1;
			this._isOnMonut = _arg_1;
		}

		public function setIcon(_arg_1:Bitmap):void
		{
			if (this._iconSprite) {
				this.removeChild(this._iconSprite);
			}
			this._iconSprite = _arg_1;
			if (_arg_1) {
				this.addChild(this._iconSprite);
				this.updateUiPos();
			}
		}

		public function hitIcon():Boolean
		{
			var _local_1:Point;
			if (((this._iconSprite) && (this.contains(this._iconSprite)))) {
				_local_1 = new Point();
				_local_1.x = mouseX;
				_local_1.y = mouseY;
				if (HitTest.getChildUnderPoint(this, _local_1, [this._iconSprite])) {
					return (true);
				}
			}
			return (false);
		}

		public function showFlag(_arg_1:DisplayObject):void
		{
			if (this.headShape) {
				this.headShape.showFlag(_arg_1);
			}
			this.updateUiPos();
		}

		public function disposeFlag():void
		{
			if (this.headShape) {
				this.headShape.disposeFlag();
			}
		}

		public function setHeadIcon(_arg_1:Object, _arg_2:String="center"):void
		{
			if (this.headShape) {
				this.headShape.setHeadIcon(_arg_1, _arg_2);
			}
			this.updateUiPos();
		}

		public function disposeHeadIcon(_arg_1:String="all"):void
		{
			if (this.headShape) {
				this.headShape.disposeHeadIcon(_arg_1);
			}
		}

		public function set headIconVisible(_arg_1:Boolean):void
		{
		}

		public function get headIconVisible():Boolean
		{
			return (this._headIconVisible);
		}

		public function get specialMode():int
		{
			return (this.avatarParts.specialMode);
		}

		public function set specialMode(_arg_1:int):void
		{
			if (this.avatarParts) {
				this.avatarParts.specialMode = _arg_1;
			}
		}

		public function setStartTime(_arg_1:String, _arg_2:int):void
		{
		}

		public function get isDeath():Boolean
		{
			return (this._isDeath);
		}

		public function set isDeath(_arg_1:Boolean):void
		{
			this._isDeath = _arg_1;
		}

		override public function set blendMode(_arg_1:String):void
		{
			if (this.bitmapdata_mid) {
				this.bitmapdata_mid.blendMode = _arg_1;
			}
			if (this.bitmapdata_fid) {
				this.bitmapdata_fid.blendMode = _arg_1;
			}
			if (this.bitmapdata_midm) {
				this.bitmapdata_midm.blendMode = _arg_1;
			}
			if (this.bitmapdata_wid) {
				this.bitmapdata_wid.blendMode = _arg_1;
			}
			if (this.bitmapdata_wgid) {
				this.bitmapdata_wgid.blendMode = _arg_1;
			}
		}

		public function nameColor(_arg_1:uint):void
		{
			this.headShape.nameColor = _arg_1;
		}

		public function set professionName(_arg_1:String):void
		{
			this.headShape.professionName = _arg_1;
			this.updateUiPos();
		}

		override public function get name():String
		{
			return (this._name);
		}

		override public function set name(_arg_1:String):void
		{
			if (_arg_1 != this._name) {
				this._name = _arg_1;
				if (this.headShape) {
					this.headShape.name = _arg_1;
				}
			}
			this.updateUiPos();
		}

		public function setBloodBarVisible(_arg_1:Boolean):void
		{
			if (this.headShape) {
				this.headShape.bloodBarVisible = _arg_1;
			}
			this.updateUiPos();
		}

		public function setBlood(_arg_1:int, _arg_2:int):void
		{
			if (this.headShape) {
				this.headShape.setBoold(_arg_1, _arg_2);
			}
			this.updateUiPos();
		}

		public function set headVisible(_arg_1:Boolean):void
		{
			this._headVisible = _arg_1;
			if (this._headShape) {
				this.headShape.visible = _arg_1;
				this.updateUiPos();
			}
		}

		public function set stop(_arg_1:Boolean):void
		{
			if (this.avatarParts) {
				this.avatarParts.stop = _arg_1;
			}
		}

		public function get stop():Boolean
		{
			if (this.avatarParts) {
				return (this.avatarParts.stop);
			}
			return (false);
		}

		public function get isDisposed():Boolean
		{
			return (this.$isDisposed);
		}

		public function set isDisposed(_arg_1:Boolean):void
		{
			this.$isDisposed = _arg_1;
		}

		override public function get visible():Boolean
		{
			return (this._visible);
		}

		override public function get filters():Array
		{
			if (this.bitmapdata_mid) {
				return (this.bitmapdata_mid.filters);
			}
			return ([]);
		}

		override public function set filters(_arg_1:Array):void
		{
			if (((this.bitmapdata_mid) && (this.bitmapdata_mid.stage))) {
				this.bitmapdata_mid.filters = _arg_1;
			}
			if (((this.bitmapdata_fid) && (this.bitmapdata_fid.stage))) {
				this.bitmapdata_fid.filters = _arg_1;
			}
			if (((this.headShape) && (this.headShape.stage))) {
				this.headShape.filters = _arg_1;
			}
		}

		public function liangdu(_arg_1:Number):Array
		{
			return ([1, 0, 0, 0, _arg_1, 0, 1, 0, 0, _arg_1, 0, 0, 1, 0, _arg_1, 0, 0, 0, 1, 0]);
		}

		public function set pt(_arg_1:SquarePt):void
		{
			this._pt = _arg_1;
			var _local_2:Point = SquareUitls.squareTopixels(_arg_1);
			super.x = _local_2.x;
			super.y = _local_2.y;
			_local_2.x = super.x;
			_local_2.y = super.y;
			this._point = _local_2;
			if (((this.shape) && ((this.jumping == false)))) {
				if (this.shape.x != this.x) {
					this.shape.x = this.x;
				}
				if (this.shape.y != this.y) {
					this.shape.y = this.y;
				}
			}
			var _local_3:int = ((this.onMonutHeight - this.height_old) + y);
			if (_local_3 != this.headShape.y) {
				this.headShape.y = _local_3;
			}
			if (this.headShape.x != x) {
				this.headShape.x = x;
			}
			this.headShape.stageIntersects();
		}

		public function get pt():SquarePt
		{
			return (this._pt);
		}

		public function set bodyVisible(_arg_1:Boolean):void
		{
			this.stop = !(_arg_1);
			this._bodyVisible = _arg_1;
			super.visible = _arg_1;
		}

		public function get bodyVisible():Boolean
		{
			return (this._bodyVisible);
		}

		override public function set visible(_arg_1:Boolean):void
		{
			this._visible = _arg_1;
			super.visible = _arg_1;
			if (this.shape) {
				this.shape.visible = _arg_1;
			}
			this.headVisible = _arg_1;
		}

		public function set point(_arg_1:Point):void
		{
			var _local_2:int;
			if (_arg_1) {
				super.x = Number(_arg_1.x.toFixed(2));
				super.y = Number(_arg_1.y.toFixed(2));
				if ((this._point == null)) {
					this._point = _arg_1;
				}
				this._point.x = super.x;
				this._point.y = super.y;
				this._pt = SquareUitls.pixelsToSquare(_arg_1);
			}
			if (((this.shape) && ((this.jumping == false)))) {
				this.shape.x = this.x;
				this.shape.y = this.y;
			}
			if (this.headShape) {
				_local_2 = ((this.onMonutHeight - this.height_old) + y);
				if (_local_2 != this.headShape.y) {
					this.headShape.y = _local_2;
				}
				this.headShape.x = x;
			}
			this.setAlpha();
		}

		public function get point():Point
		{
			return (this._point);
		}

		override public function set x(_arg_1:Number):void
		{
			if (this._point) {
				super.x = _arg_1;
				this._point.x = super.x;
				this._pt = SquareUitls.pixelsToSquare(this._point);
			}
			if (((this.shape) && ((this.jumping == false)))) {
				this.shape.x = this.x;
			}
			if (this.headShape) {
				this.headShape.x = _arg_1;
			}
			this.setAlpha();
		}

		override public function set y(_arg_1:Number):void
		{
			var _local_2:int;
			if (this._point) {
				super.y = _arg_1;
				this._point.y = super.y;
				this._pt = SquareUitls.pixelsToSquare(this._point);
			}
			if (this.headShape) {
				_local_2 = ((this.onMonutHeight - this.height_old) + y);
				if (_local_2 != this.headShape.y) {
					this.headShape.y = _local_2;
				}
			}
			if (((this.shape) && ((this.jumping == false)))) {
				this.shape.y = this.y;
			}
			this.setAlpha();
		}

		public function reset():void
		{
			if (this._ap) {
				this._ap.dispose();
			}
			this._ap = null;
			this._ap = new AvatartParts();
			this._ap.type = "Avatar";
			this._ap.onRender = this.onRender;
			this._ap.onRendStart = coder::onRendStart;
			this._ap.playEndFunc = coder::playEndFunc;
			this._ap.playEffectFunc = coder::playEffectFunc;
			this._ap.setupReady = coder::setupReady;
			this._ap.disposeEffectsFunc = this.disposeEffects;
			this.bodyVisible = true;
			this._isAutoDispose = true;
			this._ap.coder::oid = this.id;
			this.$playEndFunc = null;
			this.$playEndHash = null;
			this.playEndHash = new Hash();
			this.$playState = null;
			this.$proto = null;
			if (this.shape) {
				this.shape.dispose();
			}
			this.shape = null;
			this.deayRestrict = null;
			this.deayState = null;
			this.isDeath = false;
			this.isDisposed = false;
			if (((this._headShape) && (this._headShape.parent))) {
				this._headShape.parent.removeChild(this._headShape);
			}
			if (this._headShape) {
				this._headShape.dispose();
			}
			this._headShape = null;
			this.effectPlayEndDic = null;
			this.eid_avatarBitmaps = null;
			this.dir = 0;
			this.alpha = 1;
			if (!this.visible) {
				this.visible = true;
			}
			if (this.blendMode != BlendMode.NORMAL) {
				this.blendMode = BlendMode.NORMAL;
			}
			if (this.cacheAsBitmap) {
				this.cacheAsBitmap = false;
			}
			this.dir = 4;
			this.eid_avatarBitmaps = new Dictionary();
			this.jumping = false;
			this.runing = false;
			this.specialMode = 0;
			this.stop = false;
			this.isOnMonut = false;
			this.isSceneItem = false;
			this.old_dir = 0;
			this.sit_a = -1;
			this.sit_vy = 1;
			this.height_old = 110;
			this.hpHeight = 110;
			if (this.bitmapdata_mid) {
				this.transform.colorTransform = new ColorTransform();
			}
			if (this.bitmapdata_mid) {
				this.bitmapdata_mid.bitmapData = null;
			}
			if (this.bitmapdata_midm) {
				this.bitmapdata_midm.bitmapData = null;
			}
			if (this.bitmapdata_wid) {
				this.bitmapdata_wid.bitmapData = null;
			}
			if (this.bitmapdata_fid) {
				this.bitmapdata_fid.bitmapData = null;
			}
			if (((this.bitmapdata_wid) && (this.bitmapdata_wid.parent))) {
				this.bitmapdata_wid.parent.removeChild(this.bitmapdata_wid);
			}
			if (((this.bitmapdata_mid) && (this.bitmapdata_mid.parent))) {
				this.bitmapdata_mid.parent.removeChild(this.bitmapdata_mid);
			}
			if (((this.bitmapdata_midm) && (this.bitmapdata_midm.parent))) {
				this.bitmapdata_midm.parent.removeChild(this.bitmapdata_midm);
			}
			if (((this.bitmapdata_fid) && (this.bitmapdata_fid.parent))) {
				this.bitmapdata_fid.parent.removeChild(this.bitmapdata_fid);
			}
			if (((this.bitmapdata_wgid) && (this.bitmapdata_wgid.parent))) {
				this.bitmapdata_wgid.parent.removeChild(this.bitmapdata_wgid);
			}
			if (this.bitmapdata_mid) {
				this.bitmapdata_mid.blendMode = BlendMode.NORMAL;
			}
			if (this.bitmapdata_fid) {
				this.bitmapdata_fid.blendMode = BlendMode.NORMAL;
			}
			if (this.bitmapdata_midm) {
				this.bitmapdata_midm.blendMode = BlendMode.NORMAL;
			}
			if (this.bitmapdata_wid) {
				this.bitmapdata_wid.blendMode = BlendMode.NORMAL;
			}
			if (this.bitmapdata_wgid) {
				this.bitmapdata_wgid.blendMode = BlendMode.NORMAL;
			}
		}

		public function get avatarParts():AvatartParts
		{
			return (this._ap);
		}

		public function set avatarParts(_arg_1:AvatartParts):void
		{
			this._ap = _arg_1;
		}

		public function setup():void
		{
			var _local_3:DisplayObject;
			this.avatarParts = new AvatartParts();
			this.avatarParts.type = "Avatar";
			this.avatarParts.onRender = this.onRender;
			this.avatarParts.onRendStart = coder::onRendStart;
			this.avatarParts.playEndFunc = coder::playEndFunc;
			this.avatarParts.playEffectFunc = coder::playEffectFunc;
			this.avatarParts.setupReady = coder::setupReady;
			this.avatarParts.disposeEffectsFunc = this.disposeEffects;
			this.avatarParts.coder::oid = this.id;
			this.showBodyShoadw(false);
			var _local_1:int = this.numChildren;
			var _local_2:int;
			while (_local_2 < _local_1) {
				_local_3 = this.getChildAt(_local_2);
				if (((((((((((!((_local_3 == this.bitmapdata_wgid))) && (!((_local_3 == this.bitmapdata_fid))))) && (!((_local_3 == this.bitmapdata_wid))))) && (!((_local_3 == this.bitmapdata_mid))))) && (!((_local_3 == this.bitmapdata_midm))))) && (!((_local_3 == this._headShape))))) {
					this.removeChildAt(_local_2);
					_local_2--;
				}
				_local_2++;
			}
			this.graphics.clear();
			this.isDisposed = false;
		}

		coder function onRendStart():void
		{
			if (this.curr_rect) {
				this.curr_rect.setEmpty();
			}
		}

		coder function playEffectFunc(_arg_1:AvatarParam):void
		{
			if (_arg_1.type == ItemConst.BODY_TYPE) {
				if (((((this.$playEndFunc) && (this.$playState))) && ((_arg_1.link == this.$playState)))) {
					this.$playEndFunc();
				}
			}
		}

		public function set fuzzyMode(_arg_1:Boolean):void
		{
			this._fuzzyMode = _arg_1;
			super.filters = [new BlurFilter(20, 2)];
		}

		public function get fuzzyMode():Boolean
		{
			return (this._fuzzyMode);
		}

		coder function playEndFunc(_arg_1:Object):void
		{
			var _local_2:Object;
			if (_arg_1.type == ItemConst.BODY_TYPE) {
				if (((((!((this.deayState == null))) && (!((_arg_1.link == this.deayState))))) && (!((this.deayState == CharAction.STAND))))) {
					this.avatarParts.play(this.deayState, this.deayRestrict, true);
					this.deayState = null;
					this.avatarParts.isPalyStandDeay = true;
				} else {
					if (((this.runing) && (!((this.avatarParts.state == CharAction.WALK))))) {
						this.avatarParts.isPalyStandDeay = false;
						this.avatarParts.play(CharAction.WALK);
					}
				}
			} else {
				if (_arg_1.type == ItemConst.EFFECT_TYPE) {
					if (this.effectPlayEndDic) {
						for each (_local_2 in this.effectPlayEndDic) {
							if (_arg_1.assets_id == _local_2.key) {
								if (_local_2.parems == null) {
									_local_2.func();
								} else {
									_local_2.func(_local_2.parems);
								}
								delete this.effectPlayEndDic[_local_2.key];
							}
						}
					}
				}
			}
		}

		public function showBodyShoadw(_arg_1:Boolean):void
		{
			var _local_2:Matrix;
			this.graphics.clear();
			if (((_arg_1) && (Core.shadow_bitmapData))) {
				_local_2 = RecoverUtils.matrix;
				_local_2.tx = (-(Core.shadow_bitmapData.width) / 2);
				_local_2.ty = -(Core.shadow_bitmapData.height);
				this.graphics.beginBitmapFill(Core.shadow_bitmapData, _local_2);
				this.graphics.drawRect((-(Core.shadow_bitmapData.width) / 2), -(Core.shadow_bitmapData.height), Core.shadow_bitmapData.width, Core.shadow_bitmapData.height);
			}
		}

		public function set shoadw(_arg_1:BitmapData):void
		{
			var _local_2:Matrix;
			if (_arg_1) {
				if (this.shoadwShape == null) {
					this.shoadwShape = new Sprite();
					_local_2 = RecoverUtils.matrix;
					_local_2.tx = (_arg_1.width / 2);
					_local_2.ty = _arg_1.height;
					this.shoadwShape.graphics.beginBitmapFill(_arg_1, _local_2);
					this.shoadwShape.graphics.drawRect((-(_arg_1.width) / 2), -(_arg_1.height), _arg_1.width, _arg_1.height);
					this.shoadwShape.cacheAsBitmap = true;
				}
				this.addChildAt(this.shoadwShape, 0);
			} else {
				if (((this.shoadwShape) && (this.shoadwShape.parent))) {
					this.shoadwShape.parent.removeChild(this.shoadwShape);
					this.shoadwShape.graphics.clear();
				}
				this.shoadwShape = null;
			}
		}

		coder function setupReady():void
		{
			var _local_1:String = this.avatarParts.state;
			this.loadCharActionAssets(_local_1);
			this.setupReady();
		}

		public function setupReady():void
		{
		}

		public function loadCharActionAssets(_arg_1:String):void
		{
			var _local_3:AvatarParam;
			var _local_4:String;
			if ((((_arg_1 == null)) || ((_arg_1 == "")))) {
				return;
			}
			if (this.avatarParts.avatarParts == null) {
				return;
			}
			var _local_2:Dictionary = this.avatarParts.avatarParts[_arg_1];
			for each (_local_3 in _local_2) {
				_local_4 = _local_3.assetsPath;
				if (AvatarAssetManager.getInstance().checkLoadedFunc(_local_4) == true) {
					return;
				}
				_local_4 = _local_4.split(Core.TMP_FILE).join((("_" + _arg_1) + Core.TMP_FILE));
				AvatarAssetManager.getInstance().loadAvatarAssets(_local_4, _arg_1, this.avatarParts.id);
			}
		}

		public function loadAvatarPart(_arg_1:String, _arg_2:AvatarRestrict=null):String
		{
			if ((((this.type == SceneConstant.COLLECTION_ITEM)) && (this.bitmapdata_mid))) {
			}
			if (this.isDisposed) {
				return (null);
			}
			var _local_3:String = _arg_1;
			var _local_4:Array = _arg_1.split("/");
			var _local_5:String = _local_4[(_local_4.length - 1)];
			var _local_6:String = _local_5.split("_")[0];
			_local_5 = _local_5.split(Core.TMP_FILE)[0];
			var _local_7:String = _local_4[(_local_4.length - 2)];
			if ((_local_7 == null)) {
				_local_7 = "";
			}
			if (_local_4.length >= 2) {
				_local_4[(_local_4.length - 2)] = "output";
			} else {
				if (_local_4.length == 1) {
					_local_4.unshift("output");
				}
			}
			_arg_1 = _local_4.join("/");
			_local_6 = _local_5.split("_")[0];
			_local_5 = _local_5.split(Core.TMP_FILE)[0];
			_local_6 = _local_5.split("_")[0];
			_arg_1 = _arg_1.split(Core.TMP_FILE).join(".sm");
			var _local_8:int = int(_local_5.split("_")[1]);
			if (_local_6 == ItemConst.MOUNT_TYPE) {
				if (_local_8 == 0) {
					this.isOnMonut = false;
					this.onMonutHeight = 0;
				} else {
					this.isOnMonut = true;
					this.onMonutHeight = this._monutHeight;
				}
			}
			if (_local_8 > 0) {
				if (this.avatarParts) {
					AvatarManager.coder::getInstance().put(this.avatarParts);
					_local_5 = AvatarAssetManager.getInstance().loadAvatar(_arg_1, this.avatarParts.id, _local_3);
					if ((((_local_6 == "eid")) && (_arg_2))) {
						_arg_2.coder::oid = _local_5;
						this.avatarParts.addEffectRestrict(_local_5, _arg_2);
					}
					return (_local_5);
				}
			} else {
				if (this.avatarParts) {
					this.avatarParts.removeAvatarPartByType(_local_6);
					switch (_local_6) {
						case ItemConst.BODY_TYPE:
							if (this.bitmapdata_mid) {
								this.bitmapdata_mid.bitmapData = null;
							}
							break;
						case ItemConst.WEAPON_TYPE:
							if (this.bitmapdata_wid) {
								this.bitmapdata_wid.bitmapData = null;
							}
							break;
						case ItemConst.WING_TYPE:
							if (this.bitmapdata_wgid) {
								this.bitmapdata_wgid.bitmapData = null;
							}
							break;
						case ItemConst.MOUNT_TYPE:
							if (this.bitmapdata_midm) {
								this.bitmapdata_midm.bitmapData = null;
							}
							break;
						case ItemConst.FLY_TYPE:
							if (this.bitmapdata_fid) {
								this.bitmapdata_fid.bitmapData = null;
							}
							break;
					}
				}
			}
			return (null);
		}

		public function removeEffect(_arg_1:int):void
		{
			var _local_2:String;
			var _local_3:String;
			if (this.avatarParts) {
				_local_2 = ("eid_" + _arg_1);
				_local_3 = this.avatarParts.removeEffect(_local_2);
				if (_local_3) {
					this.disposeEffects(_local_3);
				}
			}
		}

		public function addEffectPlayEndFunc(_arg_1:String, _arg_2:Function, _arg_3:Object=null):void
		{
			if (this.effectPlayEndDic == null) {
				this.effectPlayEndDic = new Dictionary();
			}
			if (this.effectPlayEndDic[_arg_1] == null) {
				this.effectPlayEndDic[_arg_1] = {
					"key":_arg_1,
					"func":_arg_2,
					"parems":_arg_3
				}
			}
		}

		public function play(_arg_1:String, _arg_2:AvatarRestrict=null, _arg_3:Boolean=false, _arg_4:Function=null, _arg_5:Boolean=true):void
		{
			var _local_6:int;
			if (this.avatarParts == null) {
				return;
			}
			if (((this.isDeath) && (!((_arg_1 == CharAction.DEATH))))) {
				return;
			}
			if ((((((_arg_1 == CharAction.WALK)) || ((_arg_1 == CharAction.DEATH)))) || ((_arg_1 == CharAction.STAND)))) {
				_arg_3 = true;
			}
			if (_arg_1 == CharAction.DEATH) {
				this.isDeath = true;
			}
			_arg_3 = true;
			if (((((!((_arg_1 == CharAction.WALK))) && (!((_arg_1 == CharAction.STAND))))) && (!((_arg_1 == CharAction.COLLECTION))))) {
				_arg_2 = new AvatarRestrict();
				_arg_2.state = _arg_1;
			}
			if (this.isDisposed) {
				return;
			}
			this.deayState = _arg_1;
			this.deayRestrict = _arg_2;
			if (!_arg_5) {
				if (_arg_4 != null) {
					(_arg_4());
				}
			} else {
				_local_6 = (4 * 100);
				if (_arg_4 != null) {
					setTimeout(_arg_4, _local_6);
				}
			}
			this.$playState = _arg_1;
			if (this.deayState) {
				this.avatarParts.isPalyStandDeay = false;
			} else {
				this.avatarParts.isPalyStandDeay = true;
			}
			if (_arg_3) {
				this.deayState = null;
				this.avatarParts.isPalyStandDeay = true;
				if ((((_arg_1 == CharAction.MEDITATION)) || (this.specialMode))) {
					this.avatarParts.isPalyStandDeay = false;
				}
				if (this.avatarParts.state == _arg_1) {
					_arg_3 = false;
				}
				this.avatarParts.play(_arg_1, _arg_2, _arg_3);
			}
			this.loadCharActionAssets(_arg_1);
		}

		public function set dir(_arg_1:int):void
		{
			if (((this.isDisposed) || (!(this.avatarParts)))) {
				return;
			}
			if (this.avatarParts.dir != _arg_1) {
				this.avatarParts.dir = _arg_1;
			}
		}

		public function jumpPoint(_arg_1:Point):void
		{
		}

		public function jumpPt(_arg_1:SquarePt):void
		{
		}

		public function get dir():int
		{
			if (!this.avatarParts) {
				return (0);
			}
			return (this.avatarParts.dir);
		}

		public function clear():void
		{
		}

		public function disposeEffects(_arg_1:String):void
		{
			var _local_2:Bitmap;
			if (this.isDisposed) {
				return;
			}
			if (this.eid_avatarBitmaps) {
				_local_2 = this.eid_avatarBitmaps[_arg_1];
			}
			if (_local_2) {
				_local_2.bitmapData = null;
				this.removeChild(_local_2);
				delete this.eid_avatarBitmaps[_arg_1];
			}
		}

		protected function getAngle(_arg_1:Point, _arg_2:Point):Number
		{
			var _local_3:Number;
			var _local_4:int = (_arg_2.x - _arg_1.x);
			var _local_5:int = (_arg_2.y - _arg_1.y);
			return (Math.atan2(_local_5, _local_4));
		}

		protected function getDegree(_arg_1:Point, _arg_2:Point):Number
		{
			var _local_3:int;
			var _local_4:int = (_arg_2.x - _arg_1.x);
			var _local_5:int = (_arg_1.y - _arg_2.y);
			if (_local_5 == 0) {
				if ((_local_4 > 0)) {
					_local_3 = 90;
				} else {
					_local_3 = 270;
				}
			} else {
				if ((_local_5 > 0)) {
					_local_3 = (Math.atan((_local_4 / _local_5)) * _radian_);
				} else {
					_local_3 = ((Math.atan((_local_4 / _local_5)) * _radian_) + 180);
				}
			}
			return (_local_3);
		}

		public function setAlpha():void
		{
			var _local_1:Square;
			if (this.pt) {
				this._pt = SquareUitls.pixelsToSquare(this._point);
				_local_1 = SquareGroup.getInstance().take(this.pt.key);
				if (_local_1) {
					if (_local_1.isAlpha) {
						if (this.alpha != 0.6) {
							this.alpha = 0.6;
						}
					} else {
						if (this.alpha != 1) {
							this.alpha = 1;
						}
					}
				}
			}
		}

		coder function flyerMove():void
		{
			var _local_1:Point;
			if (!this._isFlyMode) {
				return;
			}
			if (((((this.jumping) && (this.bitmapdata_midm))) && (this.bitmapdata_midm.bitmapData))) {
				_local_1 = new Point(this.shape.x, this.shape.y);
				_local_1 = Scene.scene.localToGlobal(_local_1);
				_local_1 = this.globalToLocal(_local_1);
				this.bitmapdata_midm.x = (_local_1.x + this.fly_vx);
				this.bitmapdata_midm.y = (_local_1.y + this.fly_vy);
			}
		}

		public function onRender(_arg_1:String, _arg_2:int, _arg_3:BitmapData, _arg_4:Rectangle, _arg_5:String, _arg_6:String=null, _arg_7:int=0, _arg_8:int=0, _arg_9:BitmapData=null):void
		{
			var _local_10:Bitmap;
			var _local_11:int;
			var _local_12:int;
			var _local_13:int;
			var _local_14:int;
			var _local_15:Boolean;
			if (this.isDisposed) {
				return;
			}
			if (this.avatarParts.id != _arg_1) {
				return;
			}
			if (((this.isShowbodyShoadw) && (((getTimer() - this.deayTime) > 500)))) {
				if (((!(this.bitmapdata_mid)) || (!(this.bitmapdata_mid.bitmapData)))) {
					this.showBodyShoadw(true);
				} else {
					this.showBodyShoadw(false);
				}
				this.isShowbodyShoadw = false;
			}
			if ((((((_arg_6 == null)) || ((this.avatarParts == null)))) || ((this.parent == null)))) {
				return;
			}
			if (((!((this.avatarParts.state == CharAction.STAND))) && (!((this.avatarParts.state == CharAction.WALK))))) {
				this.loadCharActionAssets(this.avatarParts.state);
			}
			if (((!(this.isDisposed)) && (this.stage))) {
				if (this._bodyVisible == false) {
					if (((this.bitmapdata_fid) && (!((this.bitmapdata_fid.bitmapData == null))))) {
						this.bitmapdata_fid.bitmapData = null;
					}
					if (((this.bitmapdata_midm) && (!((this.bitmapdata_midm.bitmapData == null))))) {
						this.bitmapdata_midm.bitmapData = null;
					}
					if (((this.bitmapdata_mid) && (!((this.bitmapdata_mid.bitmapData == null))))) {
						this.bitmapdata_mid.bitmapData = null;
					}
					if (((this.bitmapdata_wid) && (!((this.bitmapdata_wid.bitmapData == null))))) {
						this.bitmapdata_wid.bitmapData = null;
					}
					if (((this.bitmapdata_wgid) && (!((this.bitmapdata_wgid.bitmapData == null))))) {
						this.bitmapdata_wgid.bitmapData = null;
					}
					return;
				}
				if (_arg_5 == ItemConst.BODY_TYPE) {
					if (this.bitmapdata_mid == null) {
						this.bitmapdata_mid = new Bitmap();
					}
					if (!this.bitmapdata_mid.parent) {
						if (this.bitmapdata_midm) {
							this.addChild(this.bitmapdata_midm);
						}
						if (this.bitmapdata_mid) {
							this.addChild(this.bitmapdata_mid);
						}
						if (this.bitmapdata_wid) {
							this.addChild(this.bitmapdata_wid);
						}
						if (this.bitmapdata_wgid) {
							this.addChild(this.bitmapdata_wgid);
						}
					}
					_local_10 = this.bitmapdata_mid;
					if ((((this.avatarParts.state == CharAction.MEDITATION)) || (((this.bitmapdata_midm) && (this.bitmapdata_midm.bitmapData))))) {
						_local_11 = 4;
						if (this.avatarParts.state == CharAction.MEDITATION) {
							_local_14 = 10;
						}
						if (this.isGroupSongModel) {
							this.sit_vy = (this.sit_vy + (this.sit_speed * this.sit_a));
						} else {
							this.sit_vy = 0;
						}
						if ((((this.sit_vy > 0)) || ((this.sit_vy < -(_local_14))))) {
							this.sit_a = -(this.sit_a);
						}
					}
				} else {
					if (_arg_5 == ItemConst.FLY_TYPE) {
						if (this.bitmapdata_fid == null) {
							this.bitmapdata_fid = new Bitmap();
						}
						if (!this.bitmapdata_fid.parent) {
							if (this.bitmapdata_midm) {
								this.addChild(this.bitmapdata_midm);
							}
							if (this.bitmapdata_fid) {
								this.addChild(this.bitmapdata_fid);
							}
							if (this.bitmapdata_mid) {
								this.addChild(this.bitmapdata_mid);
							}
							if (this.bitmapdata_wid) {
								this.addChild(this.bitmapdata_wid);
							}
							if (this.bitmapdata_wgid) {
								this.addChild(this.bitmapdata_wgid);
							}
						}
						_local_10 = this.bitmapdata_fid;
					} else {
						if (_arg_5 == ItemConst.WEAPON_TYPE) {
							if (this.bitmapdata_wid == null) {
								this.bitmapdata_wid = new Bitmap();
							}
							if (!this.bitmapdata_wid.parent) {
								if (this.bitmapdata_midm) {
									this.addChild(this.bitmapdata_midm);
								}
								if (this.bitmapdata_mid) {
									this.addChild(this.bitmapdata_mid);
								}
								if (this.bitmapdata_wid) {
									this.addChild(this.bitmapdata_wid);
								}
								if (this.bitmapdata_wgid) {
									this.addChild(this.bitmapdata_wgid);
								}
							}
							_local_10 = this.bitmapdata_wid;
						} else {
							if (_arg_5 == ItemConst.WING_TYPE) {
								if (this.bitmapdata_wgid == null) {
									this.bitmapdata_wgid = new Bitmap();
								}
								if (!this.bitmapdata_wgid.parent) {
									if (this.bitmapdata_midm) {
										this.addChild(this.bitmapdata_midm);
									}
									if (this.bitmapdata_mid) {
										this.addChild(this.bitmapdata_mid);
									}
									if (this.bitmapdata_wid) {
										this.addChild(this.bitmapdata_wid);
									}
									if (this.bitmapdata_wgid) {
										this.addChild(this.bitmapdata_wgid);
									}
								}
								_local_10 = this.bitmapdata_wgid;
							} else {
								if (_arg_5 == ItemConst.MOUNT_TYPE) {
									if (this.bitmapdata_midm == null) {
										this.bitmapdata_midm = new Bitmap();
									}
									if (!this.bitmapdata_midm.parent) {
										if (this.bitmapdata_midm) {
											this.addChild(this.bitmapdata_midm);
										}
										if (this.bitmapdata_mid) {
											this.addChild(this.bitmapdata_mid);
										}
										if (this.bitmapdata_wid) {
											this.addChild(this.bitmapdata_wid);
										}
										if (this.bitmapdata_wgid) {
											this.addChild(this.bitmapdata_wgid);
										}
									} else {
										if (((((this.bitmapdata_midm) && (this.bitmapdata_mid))) && (this.bitmapdata_mid.parent))) {
											if (this.getChildIndex(this.bitmapdata_midm) > this.getChildIndex(this.bitmapdata_mid)) {
												if (this.bitmapdata_midm) {
													this.addChild(this.bitmapdata_midm);
												}
												if (this.bitmapdata_mid) {
													this.addChild(this.bitmapdata_mid);
												}
												if (this.bitmapdata_wid) {
													this.addChild(this.bitmapdata_wid);
												}
												if (this.bitmapdata_wgid) {
													this.addChild(this.bitmapdata_wgid);
												}
											}
										}
									}
									_local_10 = this.bitmapdata_midm;
								} else {
									if (_arg_5 == ItemConst.EFFECT_TYPE) {
										if (this.eid_avatarBitmaps == null) {
											this.eid_avatarBitmaps = new Dictionary();
										}
										if (this.eid_avatarBitmaps[_arg_6] == null) {
											this.eid_avatarBitmaps[_arg_6] = new Bitmap();
											if (!this.eid_avatarBitmaps[_arg_6].parent) {
												this.addChild(this.eid_avatarBitmaps[_arg_6]);
											}
										}
										_local_10 = this.eid_avatarBitmaps[_arg_6];
									}
								}
							}
						}
					}
				}
				if (_local_10) {
					_local_12 = -(_arg_7);
					_local_13 = 0;
					if ((((this.avatarParts.state == CharAction.MEDITATION)) || (((this.bitmapdata_midm) && (this.bitmapdata_midm.bitmapData))))) {
						_local_14 = 0;
						if (this.avatarParts.state == CharAction.MEDITATION) {
							if (((((this.bitmapdata_wid) && (this.bitmapdata_wid.stage))) && (this.bitmapdata_wid.visible))) {
								this.bitmapdata_wid.visible = false;
							}
							_local_14 = 10;
						}
						_local_13 = (((-(_arg_8) + this.sit_vy) - _local_14) + this.onMonutHeight);
					} else {
						if (((this.bitmapdata_midm) && (!(this.bitmapdata_midm.bitmapData)))) {
							if (this.sit_vy != 0) {
								this.sit_vy = 0;
							}
							if (this.sit_a != -1) {
								this.sit_a = -1;
							}
						}
						_local_13 = (-(_arg_8) + this.onMonutHeight);
						if (((((this.bitmapdata_wid) && (this.bitmapdata_wid.stage))) && (!(this.bitmapdata_wid.visible)))) {
							this.bitmapdata_wid.visible = true;
						}
					}
					if (((((((this.bitmapdata_midm) && (this.bitmapdata_midm.parent))) && (this.bitmapdata_fid))) && (this.bitmapdata_fid.parent))) {
						if (this.dir == 0) {
							if (((this.bitmapdata_midm) && (this.bitmapdata_midm.parent))) {
								this.addChildAt(this.bitmapdata_midm, 0);
							}
							if (((this.bitmapdata_fid) && (this.bitmapdata_fid.parent))) {
								this.addChildAt(this.bitmapdata_fid, 1);
							}
							if (((this.bitmapdata_mid) && (this.bitmapdata_mid.parent))) {
								this.addChildAt(this.bitmapdata_mid, 2);
							}
						} else {
							if (this.dir == 4) {
								if (((this.bitmapdata_midm) && (this.bitmapdata_midm.parent))) {
									this.addChildAt(this.bitmapdata_midm, 0);
								}
								if (((this.bitmapdata_fid) && (this.bitmapdata_midm.parent))) {
									this.addChildAt(this.bitmapdata_fid, 1);
								}
								if (((this.bitmapdata_mid) && (this.bitmapdata_mid.parent))) {
									this.addChildAt(this.bitmapdata_mid, 2);
								}
							} else {
								if (((this.bitmapdata_mid) && (this.bitmapdata_mid.parent))) {
									this.addChildAt(this.bitmapdata_mid, 0);
								}
								if (((this.bitmapdata_midm) && (this.bitmapdata_midm.parent))) {
									this.addChildAt(this.bitmapdata_midm, 1);
								}
								if (((this.bitmapdata_fid) && (this.bitmapdata_fid.parent))) {
									this.addChildAt(this.bitmapdata_fid, 2);
								}
							}
						}
					}
					if (_arg_3) {
						if (this.shoadwShape) {
							this.shoadw = null;
						}
						if (this.stageIntersects) {
							if (((!((_local_10.bitmapData == _arg_3))) && (_local_10.stage))) {
								_local_10.bitmapData = _arg_3;
							}
							_local_15 = true;
							if ((((((_local_10 == this.bitmapdata_midm)) && (this.bitmapdata_midm.parent))) && (this._isFlyMode))) {
								this.fly_vx = _local_12;
								this.fly_vy = _local_13;
								if (this.jumping) {
									_local_15 = false;
								}
							}
							if ((((((_arg_3 == Core.shadow_bitmapData)) && (_local_15))) && (_local_10.stage))) {
								if (_local_10.x != _local_12) {
									_local_10.x = (-(Core.shadow_bitmapData.width) / 2);
								}
								if (_local_10.y != _local_13) {
									_local_10.y = (-(Core.shadow_bitmapData.height) + this.onMonutHeight);
								}
							} else {
								if (((!((_local_10.bitmapData == _arg_3))) && (_local_10.stage))) {
									_local_10.bitmapData = _arg_3;
								}
								if (((_local_15) && (_local_10.stage))) {
									if (_local_10.x != _local_12) {
										_local_10.x = _local_12;
									}
									if (_local_10.y != _local_13) {
										_local_10.y = _local_13;
									}
								}
							}
							if (((this.shadowMode) && (_local_10.bitmapData))) {
								ShoadwAvatar.create(_local_10.bitmapData, _local_12, _local_13, x, y);
							}
						}
						if (((((((!((this.bitmapdata_mid == null))) || (!((this.bitmapdata_wid == null))))) || (!((this.bitmapdata_midm == null))))) || (this.bitmapdata_fid))) {
							this.showBodyShoadw(false);
						}
					} else {
						if (_local_10.bitmapData) {
							_local_10.bitmapData = null;
						}
					}
				}
			}
			if (((this.avatarParts) && ((this.avatarParts.state == "stand")))) {
			}
			if (this.avatarParts.state == CharAction.DEATH) {
				this.height_old = 30;
			} else {
				if (this.avatarParts.state == CharAction.MEDITATION) {
					this.height_old = 80;
				} else {
					this.height_old = this.hpHeight;
				}
			}
			this.updateUiPos();
		}

		public function updateUiPos():void
		{
			var _local_1:int;
			if (this.headShape) {
				_local_1 = ((this.onMonutHeight - this.height_old) + y);
				if (_local_1 != this.headShape.y) {
					this.headShape.y = _local_1;
				}
				if (this.headShape.x != x) {
					this.headShape.x = x;
				}
			}
		}

		public function get stageIntersects():Boolean
		{
			var _local_2:Point;
			var _local_3:Number;
			var _local_4:Number;
			if (this._visible == false) {
				return (false);
			}
			var _local_1:Boolean = true;
			if (((Scene.scene) && (this.isSceneItem))) {
				_local_2 = Scene.scene.globalToLocal(op);
				_local_3 = (1 + ((1 - Scene.scene.scaleX) * 2));
				_local_4 = (1 + ((1 - Scene.scene.scaleY) * 2));
				stageRect.x = _local_2.x;
				stageRect.y = _local_2.y;
				stageRect.width = (Core.stage.stageWidth * _local_3);
				stageRect.height = (Core.stage.stageHeight * _local_4);
				intersectsRect.x = x;
				intersectsRect.y = y;
				if (this.curr_rect != null) {
					intersectsRect.x = (x + this.curr_rect.topLeft.x);
					intersectsRect.y = (y + this.curr_rect.topLeft.y);
					intersectsRect.width = this.curr_rect.width;
					intersectsRect.height = this.curr_rect.height;
				}
				_local_1 = stageRect.intersects(intersectsRect);
			}
			return (_local_1);
		}

		public function removeAvatarPart(_arg_1:String):void
		{
		}

		public function removeAvatarPartByType(_arg_1:String):void
		{
			if (!this.avatarParts) {
				return;
			}
			switch (_arg_1) {
				case ItemConst.EFFECT_TYPE:
					return;
				case ItemConst.BODY_TYPE:
					return;
				case ItemConst.WEAPON_TYPE:
					return;
				case ItemConst.MOUNT_TYPE:
					return;
			}
		}

		public function recover():void
		{
			var _local_1:Bitmap;
			if (this.isDisposed) {
				return;
			}
			this.isAutoDispose = true;
			if (this.parent) {
				this.parent.removeChild(this);
			}
			if (this.shape) {
				this.shape.dispose();
			}
			if (((this._headShape) && (this._headShape.parent))) {
				this._headShape.parent.removeChild(this._headShape);
			}
			if (this._headShape) {
				this._headShape.dispose();
			}
			this._headShape = null;
			this.shape = null;
			this._bodyVisible = true;
			this.effectPlayEndDic = null;
			InstancePool.coder::getInstance().remove(this);
			this.shoadw = null;
			if (this._iconSprite) {
				this.removeChild(this._iconSprite);
				this._iconSprite = null;
			}
			this.headIconUrl = null;
			this._isOnMonut = false;
			this.onMonutHeight = 0;
			this._point = null;
			this._pt = null;
			this.playEndHash = null;
			if (this._ap) {
				this._ap.dispose();
			}
			this._ap = null;
			if (this.bitmapdata_wid) {
				this.bitmapdata_wid.bitmapData = null;
			}
			if (this.bitmapdata_mid) {
				this.bitmapdata_mid.bitmapData = null;
			}
			if (this.bitmapdata_midm) {
				this.bitmapdata_midm.bitmapData = null;
			}
			if (this.bitmapdata_fid) {
				this.bitmapdata_fid.bitmapData = null;
			}
			if (this.bitmapdata_wgid) {
				this.bitmapdata_wgid.bitmapData = null;
			}
			if (((this.bitmapdata_wid) && (this.bitmapdata_wid.parent))) {
				this.bitmapdata_wid.parent.removeChild(this.bitmapdata_wid);
			}
			if (((this.bitmapdata_mid) && (this.bitmapdata_mid.parent))) {
				this.bitmapdata_mid.parent.removeChild(this.bitmapdata_mid);
			}
			if (((this.bitmapdata_midm) && (this.bitmapdata_midm.parent))) {
				this.bitmapdata_midm.parent.removeChild(this.bitmapdata_midm);
			}
			if (((this.bitmapdata_fid) && (this.bitmapdata_fid.parent))) {
				this.bitmapdata_fid.parent.removeChild(this.bitmapdata_fid);
			}
			if (((this.bitmapdata_wgid) && (this.bitmapdata_wgid.parent))) {
				this.bitmapdata_wgid.parent.removeChild(this.bitmapdata_wgid);
			}
			for each (_local_1 in this.eid_avatarBitmaps) {
				if (this.contains(_local_1)) {
					this.removeChild(_local_1);
				}
				if (_local_1) {
					_local_1.bitmapData = null;
				}
				_local_1 = null;
			}
			this.eid_avatarBitmaps = null;
			this.isDisposed = false;
			this.filters = [];
			this.$playState = CharAction.STAND;
			if (this.proto) {
				if ((this.proto as IProto)) {
					IProto(this.proto).dispose();
				}
				this.proto = null;
			}
			this.char_id = null;
			this.deayState = null;
			this.deayRestrict = null;
			this.isSceneItem = false;
			this.runing = false;
			this.jumping = false;
			this._monutHeight = -80;
			InstancePool.coder::getInstance().recover(this);
		}

		override public function dispose():void
		{
			var _local_1:Bitmap;
			this.showBodyShoadw(false);
			this.effectPlayEndDic = null;
			if (this._headShape) {
				this._headShape.dispose();
			}
			this._headShape = null;
			this.shoadw = null;
			if (this._iconSprite) {
				this.removeChild(this._iconSprite);
				this._iconSprite = null;
			}
			this._isAutoDispose = false;
			this.headIconUrl = null;
			this._isOnMonut = false;
			this.onMonutHeight = 0;
			this._monutHeight = -80;
			this._point = null;
			this._pt = null;
			this.playEndHash = null;
			this._name = "";
			if (this._ap) {
				this._ap.dispose();
			}
			this._ap = null;
			if (this.bitmapdata_wid) {
				this.bitmapdata_wid.bitmapData = null;
			}
			if (this.bitmapdata_mid) {
				this.bitmapdata_mid.bitmapData = null;
			}
			if (this.bitmapdata_midm) {
				this.bitmapdata_midm.bitmapData = null;
			}
			if (this.bitmapdata_fid) {
				this.bitmapdata_fid.bitmapData = null;
			}
			if (this.bitmapdata_wgid) {
				this.bitmapdata_wgid.bitmapData = null;
			}
			this.bitmapdata_wid = null;
			this.bitmapdata_mid = null;
			this.bitmapdata_midm = null;
			this.bitmapdata_fid = null;
			this.bitmapdata_wgid = null;
			for each (_local_1 in this.eid_avatarBitmaps) {
				if (this.contains(_local_1)) {
					this.removeChild(_local_1);
				}
				if (_local_1) {
					_local_1.bitmapData = null;
				}
				_local_1 = null;
			}
			this.eid_avatarBitmaps = null;
			if (this.shape) {
				this.shape.dispose();
			}
			this.shape = null;
			while (this.numChildren) {
				this.removeChildAt(0);
			}
			super.dispose();
			InstancePool.coder::getInstance().remove(this);
			this.isDisposed = true;
			if (Scene.scene) {
				Scene.scene.remove(this);
			}
		}

		public function set headClickEnabled(_arg_1:Boolean):void
		{
			if (this.headShape) {
				this.headShape.clickEnabled = _arg_1;
			}
		}

	}
}
