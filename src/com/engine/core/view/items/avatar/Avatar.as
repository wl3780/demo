package com.engine.core.view.items.avatar
{
	import com.engine.core.AvatarTypes;
	import com.engine.core.Engine;
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

		public static var stageRect:Rectangle = new Rectangle();
		
		private static var intersectsRect:Rectangle = new Rectangle(0, 0, 1, 1);
		private static var op:Point = new Point();

		public var playEndFunc:Function;
		public var playEeffectFunc:Function;
		public var shadowMode:Boolean = false;
		public var sit_speed:int = 1;
		public var isGroupSongModel:Boolean = false;
		public var curr_rect:Rectangle;
		
		public var hiedBody:Boolean = false;
		public var hiedWeapon:Boolean = false;
		public var hiedMount:Boolean = false;
		
		protected var bitmapdata_mid:Bitmap;
		protected var bitmapdata_wid:Bitmap;
		protected var bitmapdata_midm:Bitmap;
		protected var bitmapdata_fid:Bitmap;
		protected var bitmapdata_wgid:Bitmap;
		
		protected var eid_avatarBitmaps:Dictionary;
		protected var _ap:AvatartParts;
		protected var $isDisposed:Boolean = false;
		protected var _pt:SquarePt;
		protected var _point:Point;
		protected var shape:ShoadwShape;
		protected var _name:String;
		protected var onMonutHeight:int;
		protected var _headShape:HeadShape;
		protected var _isDeath:Boolean = false;
		protected var height_old:int = 110;
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
		private var effectPlayEndDic:Dictionary;
		private var deayState:String;
		private var deayRestrict:AvatarRestrict;
		private var fly_vx:Number;
		private var fly_vy:Number;
		private var sit_a:int = -1;	// 坐下加速度
		private var sit_vy:int = 1;	// 坐下速度

		public function Avatar()
		{
			super();
			_point = new Point();
			this.setup();
		}

		public function get isFlyMode():Boolean
		{
			return _isFlyMode;
		}
		public function set isFlyMode(val:Boolean):void
		{
			_isFlyMode = val;
			if (this.avatarParts) {
				this.avatarParts.isFlyMode = val;
			}
		}

		public function get monutHeight():int
		{
			return this.onMonutHeight;
		}
		public function set monutHeight(val:int):void
		{
			_monutHeight = -Math.abs(val);
		}

		coder function get bodyBitmap():Bitmap
		{
			return this.bitmapdata_mid;
		}

		public function set hp_height(val:Number):void
		{
			this.hpHeight = val;
			this.height_old = val;
		}
		public function get hp_height():Number
		{
			return this.height_old;
		}

		public function get flying():Boolean
		{
			if (this.onMonutHeight == 0) {
				_flying = false;
			} else {
				_flying = true;
			}
			return _flying;
		}

		public function get jumping():Boolean
		{
			return _jumping;
		}
		public function set jumping(val:Boolean):void
		{
			_jumping = val;
			if (this.avatarParts) {
				this.avatarParts.jumping = val;
			}
		}

		public function get runing():Boolean
		{
			if (this.avatarParts && this.avatarParts.state != CharAction.WALK) {
				_runing = false;
			}
			return _runing;
		}
		public function set runing(val:Boolean):void
		{
			_runing = val;
			if (this.avatarParts) {
				this.avatarParts.runing = val;
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
			_isAutoDispose = _arg_1;
			if (_ap) {
				_ap.isAutoDispose = _arg_1;
			}
		}

		public function get headShape():HeadShape
		{
			if (!this.isDisposed) {
				if (_headShape == null) {
					_headShape = new HeadShape();
					_headShape.owner = this;
				}
				if (_headShape.parent == null && (this.parent || _headVisible)) {
					if (Scene.scene.getSceneFlyMode()) {
						Scene.scene.$flyLayer.addChild(_headShape);
					} else {
						Scene.scene.$topLayer.addChild(_headShape);
					}
				}
				return _headShape;
			}
			return null;
		}

		override public function set scaleX(val:Number):void
		{
			super.scaleX = val;
			if (_headShape) {
				_headShape.scaleX = val;
			}
		}

		override public function set scaleY(val:Number):void
		{
			super.scaleY = val;
			if (_headShape) {
				_headShape.scaleY = val;
			}
		}

		public function get shadowShape():Sprite
		{
			return this.shape;
		}

		public function set openShadow(val:Boolean):void
		{
			if (val) {
				if (this.shape == null) {
					this.shape = new ShoadwShape();
					this.shape.moveFunc = coder::flyerMove;
				}
				this.shape.owner = this;
				this.shape.graphics.clear();
				Scene.scene.$itemLayer.addChild(this.shape);
				var mtx:Matrix = RecoverUtils.matrix;
				mtx.tx = (-(Engine.char_shadow.width) / 2);
				mtx.ty = (-(Engine.char_shadow.height) / 2);
				this.shape.graphics.beginBitmapFill(Engine.char_shadow, mtx);
				this.shape.graphics.drawRect((-(Engine.char_shadow.width) / 2), (-(Engine.char_shadow.height) / 2), Engine.char_shadow.width, Engine.char_shadow.height);
				this.shape.cacheAsBitmap = true;
				if (this.shape.parent == null) {
					Scene.scene.$itemLayer.addChild(this.shape);
				}
			} else {
				if (this.shape) {
					this.shape.dispose();
					this.shape = null;
				}
			}
		}

		public function onMountShoadw(_arg_1:Boolean):void
		{
			var _local_2:Matrix;
			if (this.shape) {
				if (!_arg_1) {
					this.shape.graphics.clear();
					_local_2 = RecoverUtils.matrix;
					_local_2.tx = (-(Engine.char_big_shadow.width) / 2);
					_local_2.ty = ((-(Engine.char_big_shadow.height) / 2) + 10);
					this.shape.graphics.beginBitmapFill(Engine.char_big_shadow, _local_2);
					this.shape.graphics.drawRect(_local_2.tx, _local_2.ty, Engine.char_big_shadow.width, Engine.char_big_shadow.height);
					this.shape.cacheAsBitmap = true;
				} else {
					this.shape.graphics.clear();
					_local_2 = RecoverUtils.matrix;
					_local_2.tx = (-(Engine.char_shadow.width) / 2);
					_local_2.ty = (-(Engine.char_shadow.height) / 2);
					this.shape.graphics.beginBitmapFill(Engine.char_shadow, _local_2);
					this.shape.graphics.drawRect((-(Engine.char_shadow.width) / 2), (-(Engine.char_shadow.height) / 2), Engine.char_shadow.width, Engine.char_shadow.height);
					this.shape.cacheAsBitmap = true;
				}
			}
		}

		override public function set type(val:String):void
		{
			super.type = val;
			if (this.type == SceneConstant.CHAR 
				|| this.type == SceneConstant.MONSTER 
				|| this.type == SceneConstant.NPC 
				|| this.type == SceneConstant.SPECIAL_NPC) {
				this.isShowbodyShoadw = true;
			} else {
				this.isShowbodyShoadw = false;
			}
			this.deayTime = getTimer();
			if (_ap) {
				_ap.type = val;
			}
		}

		public function get isOnMonut():Boolean
		{
			return _isOnMonut;
		}
		public function set isOnMonut(val:Boolean):void
		{
			_isOnMonut = val;
			if (this.avatarParts) {
				this.avatarParts.isOnMonut = val;
			}
		}

		public function setIcon(bmp:Bitmap):void
		{
			if (_iconSprite) {
				this.removeChild(_iconSprite);
			}
			_iconSprite = bmp;
			if (bmp) {
				this.addChild(_iconSprite);
				this.updateUiPos();
			}
		}

		public function hitIcon():Boolean
		{
			if (_iconSprite && this.contains(_iconSprite)) {
				var p:Point = new Point();
				p.x = mouseX;
				p.y = mouseY;
				if (HitTest.getChildUnderPoint(this, p, [_iconSprite])) {
					return true;
				}
			}
			return false;
		}

		public function showFlag(dis:DisplayObject):void
		{
			if (this.headShape) {
				this.headShape.showFlag(dis);
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

		public function set headIconVisible(val:Boolean):void
		{
			_headIconVisible = val;
		}
		public function get headIconVisible():Boolean
		{
			return _headIconVisible;
		}

		public function get specialMode():int
		{
			return this.avatarParts.specialMode;
		}
		public function set specialMode(val:int):void
		{
			if (this.avatarParts) {
				this.avatarParts.specialMode = val;
			}
		}

		public function setStartTime(_arg_1:String, _arg_2:int):void
		{
		}

		public function get isDeath():Boolean
		{
			return _isDeath;
		}
		public function set isDeath(val:Boolean):void
		{
			_isDeath = val;
		}

		override public function set blendMode(val:String):void
		{
			if (this.bitmapdata_mid) {
				this.bitmapdata_mid.blendMode = val;
			}
			if (this.bitmapdata_fid) {
				this.bitmapdata_fid.blendMode = val;
			}
			if (this.bitmapdata_midm) {
				this.bitmapdata_midm.blendMode = val;
			}
			if (this.bitmapdata_wid) {
				this.bitmapdata_wid.blendMode = val;
			}
			if (this.bitmapdata_wgid) {
				this.bitmapdata_wgid.blendMode = val;
			}
		}

		public function nameColor(val:uint):void
		{
			this.headShape.nameColor = val;
		}

		public function set professionName(val:String):void
		{
			this.headShape.professionName = val;
			this.updateUiPos();
		}

		override public function get name():String
		{
			return _name;
		}
		override public function set name(val:String):void
		{
			if (val != _name) {
				_name = val;
				if (this.headShape) {
					this.headShape.name = val;
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

		public function setBlood(curr:int, max:int):void
		{
			if (this.headShape) {
				this.headShape.setBoold(curr, max);
			}
			this.updateUiPos();
		}

		public function set headVisible(val:Boolean):void
		{
			_headVisible = val;
			if (_headShape) {
				this.headShape.visible = val;
				this.updateUiPos();
			}
		}

		public function set stop(val:Boolean):void
		{
			if (this.avatarParts) {
				this.avatarParts.stop = val;
			}
		}
		public function get stop():Boolean
		{
			if (this.avatarParts) {
				return this.avatarParts.stop;
			}
			return false;
		}

		public function get isDisposed():Boolean
		{
			return this.$isDisposed
		}
		public function set isDisposed(val:Boolean):void
		{
			this.$isDisposed = val;
		}

		override public function get visible():Boolean
		{
			return _visible;
		}

		override public function get filters():Array
		{
			if (this.bitmapdata_mid) {
				return this.bitmapdata_mid.filters;
			}
			return [];
		}
		override public function set filters(val:Array):void
		{
			if (this.bitmapdata_mid && this.bitmapdata_mid.stage) {
				this.bitmapdata_mid.filters = val;
			}
			if (this.bitmapdata_fid && this.bitmapdata_fid.stage) {
				this.bitmapdata_fid.filters = val;
			}
			if (this.headShape && this.headShape.stage) {
				this.headShape.filters = val;
			}
		}

		public function set pt(val:SquarePt):void
		{
			_pt = val;
			var ppt:Point = SquareUitls.squareTopixels(val);
			super.x = ppt.x;
			super.y = ppt.y;
			_point = ppt;
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
			return _pt;
		}

		public function set bodyVisible(val:Boolean):void
		{
			this.stop = !(val);
			_bodyVisible = val;
			super.visible = val;
		}
		public function get bodyVisible():Boolean
		{
			return (_bodyVisible);
		}

		override public function set visible(val:Boolean):void
		{
			_visible = val;
			super.visible = val;
			if (this.shape) {
				this.shape.visible = val;
			}
			this.headVisible = val;
		}

		public function set point(val:Point):void
		{
			if (val) {
				super.x = Number(val.x.toFixed(2));
				super.y = Number(val.y.toFixed(2));
				if (_point == null) {
					_point = val;
				}
				_point.x = super.x;
				_point.y = super.y;
				_pt = SquareUitls.pixelsToSquare(val);
			}
			if (this.shape && this.jumping == false) {
				this.shape.x = this.x;
				this.shape.y = this.y;
			}
			if (this.headShape) {
				var headY:int = this.onMonutHeight - this.height_old + this.y;
				if (headY != this.headShape.y) {
					this.headShape.y = headY;
				}
				this.headShape.x = x;
			}
			this.setAlpha();
		}
		public function get point():Point
		{
			return _point;
		}

		override public function set x(val:Number):void
		{
			if (_point) {
				super.x = val;
				_point.x = super.x;
				_pt = SquareUitls.pixelsToSquare(_point);
			}
			if (this.shape && this.jumping == false) {
				this.shape.x = this.x;
			}
			if (this.headShape) {
				this.headShape.x = val;
			}
			this.setAlpha();
		}

		override public function set y(val:Number):void
		{
			if (_point) {
				super.y = val;
				_point.y = super.y;
				_pt = SquareUitls.pixelsToSquare(_point);
			}
			if (this.headShape) {
				var headY:int = this.onMonutHeight - this.height_old + this.y;
				if (headY != this.headShape.y) {
					this.headShape.y = headY;
				}
			}
			if (this.shape && this.jumping == false) {
				this.shape.y = val;
			}
			this.setAlpha();
		}

		public function reset():void
		{
			if (_ap) {
				_ap.dispose();
			}
			_ap = new AvatartParts();
			_ap.type = SceneConstant.AVATAR;
			_ap.onRender = this.onRender;
			_ap.onRendStart = coder::onRendStart;
			_ap.playEndFunc = coder::playEndFunc;
			_ap.playEffectFunc = coder::playEffectFunc;
			_ap.setupReady = coder::setupReady;
			_ap.disposeEffectsFunc = this.disposeEffects;
			this.bodyVisible = true;
			_isAutoDispose = true;
			_ap.coder::oid = this.id;
			this.$playEndFunc = null;
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
			if (((_headShape) && (_headShape.parent))) {
				_headShape.parent.removeChild(_headShape);
			}
			if (_headShape) {
				_headShape.dispose();
			}
			_headShape = null;
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
			return _ap;
		}
		public function set avatarParts(val:AvatartParts):void
		{
			_ap = val;
		}

		public function setup():void
		{
			this.avatarParts = new AvatartParts();
			this.avatarParts.type = SceneConstant.AVATAR;
			this.avatarParts.setupReady = coder::setupReady;
			this.avatarParts.onRender = this.onRender;
			this.avatarParts.onRendStart = coder::onRendStart;
			this.avatarParts.playEndFunc = coder::playEndFunc;
			this.avatarParts.playEffectFunc = coder::playEffectFunc;
			this.avatarParts.disposeEffectsFunc = this.disposeEffects;
			this.avatarParts.coder::oid = this.id;
			this.showBodyShoadw(false);
			
			var idx:int = this.numChildren - 1;
			while (idx >= 0) {
				var child:DisplayObject = this.getChildAt(idx);
				if (child != this.bitmapdata_wgid 
					&& child != this.bitmapdata_fid 
					&& child != this.bitmapdata_wid 
					&& child != this.bitmapdata_mid 
					&& child != this.bitmapdata_midm 
					&& child != _headShape) {
					this.removeChildAt(idx);
				}
				idx--;
			}
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
			if (_arg_1.avatarType == AvatarTypes.BODY_TYPE) {
				if (((((this.$playEndFunc) && (this.$playState))) && ((_arg_1.action == this.$playState)))) {
					this.$playEndFunc();
				}
			}
		}

		public function set fuzzyMode(_arg_1:Boolean):void
		{
			_fuzzyMode = _arg_1;
			super.filters = [new BlurFilter(20, 2)];
		}
		public function get fuzzyMode():Boolean
		{
			return (_fuzzyMode);
		}

		coder function playEndFunc(_arg_1:Object):void
		{
			var _local_2:Object;
			if (_arg_1.type == AvatarTypes.BODY_TYPE) {
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
				if (_arg_1.type == AvatarTypes.EFFECT_TYPE) {
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

		public function showBodyShoadw(val:Boolean):void
		{
			this.graphics.clear();
			if (val && Engine.shadow_bitmapData) {
				var mtx:Matrix = RecoverUtils.matrix;
				mtx.tx = -(Engine.shadow_bitmapData.width/2);
				mtx.ty = -(Engine.shadow_bitmapData.height);
				this.graphics.beginBitmapFill(Engine.shadow_bitmapData, mtx);
				this.graphics.drawRect(-(Engine.shadow_bitmapData.width/2), -(Engine.shadow_bitmapData.height), Engine.shadow_bitmapData.width, Engine.shadow_bitmapData.height);
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
			var state:String = this.avatarParts.state;
			this.loadCharActionAssets(state);
			this.setupReady();
		}

		public function setupReady():void
		{
		}

		public function loadCharActionAssets(action:String):void
		{
			if (this.isDisposed || !action) {
				return;
			}
			var dict:Dictionary;
			var paramItem:AvatarParam;
			if (this.avatarParts.avatarParts != null) {
				dict = this.avatarParts.avatarParts[action];
				for each (paramItem in dict) {
					AvatarAssetManager.getInstance().loadAvatarAssets(paramItem.oid, action, this.avatarParts.id);
				}
			}
			if (this.avatarParts.effectsParts != null) {
				dict = this.avatarParts.effectsParts[action];
				for each (paramItem in dict) {
					AvatarAssetManager.getInstance().loadAvatarAssets(paramItem.oid, action, this.avatarParts.id);
				}
			}
		}

		public function loadAvatarPart(avatarType:String, avatarNum:String):String
		{
			if (this.isDisposed || this.avatarParts == null) {
				return null;
			}
			if (avatarType == AvatarTypes.MOUNT_TYPE) {
				if (avatarNum) {
					this.isOnMonut = true;
					this.onMonutHeight = _monutHeight;
				} else {
					this.isOnMonut = false;
					this.onMonutHeight = 0;
				}
			}
			if (avatarNum) {
				AvatarManager.coder::getInstance().put(this.avatarParts);
				var avatarId:String = AvatarAssetManager.getInstance().loadAvatar(avatarType, avatarNum, this.avatarParts.id);
				return avatarId;
			} else {
				this.avatarParts.removeAvatarPartByType(avatarType);
				switch (avatarType) {
					case AvatarTypes.BODY_TYPE:
						if (this.bitmapdata_mid) {
							this.bitmapdata_mid.bitmapData = null;
						}
						break;
					case AvatarTypes.WEAPON_TYPE:
						if (this.bitmapdata_wid) {
							this.bitmapdata_wid.bitmapData = null;
						}
						break;
					case AvatarTypes.WING_TYPE:
						if (this.bitmapdata_wgid) {
							this.bitmapdata_wgid.bitmapData = null;
						}
						break;
					case AvatarTypes.MOUNT_TYPE:
						if (this.bitmapdata_midm) {
							this.bitmapdata_midm.bitmapData = null;
						}
						break;
					case AvatarTypes.FLY_TYPE:
						if (this.bitmapdata_fid) {
							this.bitmapdata_fid.bitmapData = null;
						}
						break;
				}
			}
			return null;
		}

		public function removeEffect(_arg_1:int):void
		{
			if (this.avatarParts) {
				var _local_2:String = ("eid_" + _arg_1);
				var _local_3:String = this.avatarParts.removeEffect(_local_2);
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

		public function set dir(val:int):void
		{
			if (this.isDisposed || !this.avatarParts) {
				return;
			}
			if (this.avatarParts.dir != val) {
				this.avatarParts.dir = val;
			}
		}
		public function get dir():int
		{
			if (!this.avatarParts) {
				return 0;
			}
			return this.avatarParts.dir;
		}

		public function jumpPoint(_arg_1:Point):void
		{
		}

		public function jumpPt(_arg_1:SquarePt):void
		{
		}

		public function clear():void
		{
		}

		public function disposeEffects(_arg_1:String):void
		{
			if (this.isDisposed) {
				return;
			}
			var _local_2:Bitmap;
			if (this.eid_avatarBitmaps) {
				_local_2 = this.eid_avatarBitmaps[_arg_1];
			}
			if (_local_2) {
				_local_2.bitmapData = null;
				this.removeChild(_local_2);
				delete this.eid_avatarBitmaps[_arg_1];
			}
		}

		public function setAlpha():void
		{
			if (this.pt) {
				_pt = SquareUitls.pixelsToSquare(_point);
				var sq:Square = SquareGroup.getInstance().take(this.pt.key);
				if (sq) {
					if (sq.isAlpha) {
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
			if (!_isFlyMode) {
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

		public function onRender(parts_id:String, _arg_2:int, _arg_3:BitmapData, _arg_4:Rectangle, _arg_5:String, _arg_6:String=null, _arg_7:int=0, _arg_8:int=0, _arg_9:BitmapData=null):void
		{
			var _local_10:Bitmap;
			var _local_11:int;
			var _local_12:int;
			var _local_13:int;
			var _local_14:int;
			var _local_15:Boolean;
			if (this.avatarParts.id != parts_id) {
				return;
			}
			if (this.isDisposed || !this.stage || !this.parent) {
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
			if (((!((this.avatarParts.state == CharAction.STAND))) && (!((this.avatarParts.state == CharAction.WALK))))) {
				this.loadCharActionAssets(this.avatarParts.state);
			}
			if (((!(this.isDisposed)) && (this.stage))) {
				if (_bodyVisible == false) {
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
				if (_arg_5 == AvatarTypes.BODY_TYPE) {
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
					if (_arg_5 == AvatarTypes.FLY_TYPE) {
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
						if (_arg_5 == AvatarTypes.WEAPON_TYPE) {
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
							if (_arg_5 == AvatarTypes.WING_TYPE) {
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
								if (_arg_5 == AvatarTypes.MOUNT_TYPE) {
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
									if (_arg_5 == AvatarTypes.EFFECT_TYPE) {
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
							if ((((((_local_10 == this.bitmapdata_midm)) && (this.bitmapdata_midm.parent))) && (_isFlyMode))) {
								this.fly_vx = _local_12;
								this.fly_vy = _local_13;
								if (this.jumping) {
									_local_15 = false;
								}
							}
							if ((((((_arg_3 == Engine.shadow_bitmapData)) && (_local_15))) && (_local_10.stage))) {
								if (_local_10.x != _local_12) {
									_local_10.x = (-(Engine.shadow_bitmapData.width) / 2);
								}
								if (_local_10.y != _local_13) {
									_local_10.y = (-(Engine.shadow_bitmapData.height) + this.onMonutHeight);
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
			if (this.headShape) {
				var _local_1:int = this.onMonutHeight - this.height_old + y;
				if (_local_1 != this.headShape.y) {
					this.headShape.y = _local_1;
				}
				if (this.headShape.x != this.x) {
					this.headShape.x = this.x;
				}
			}
		}

		public function get stageIntersects():Boolean
		{
			if (_visible == false) {
				return false;
			}
			var ret:Boolean = true;
			if (Scene.scene && this.isSceneItem) {
				var pt_local:Point = Scene.scene.globalToLocal(op);
				var _local_3:Number = 1 + (1 - Scene.scene.scaleX) * 2;
				var _local_4:Number = 1 + (1 - Scene.scene.scaleY) * 2;
				stageRect.x = pt_local.x;
				stageRect.y = pt_local.y;
				stageRect.width = Engine.stage.stageWidth * _local_3;
				stageRect.height = Engine.stage.stageHeight * _local_4;
				if (this.curr_rect != null) {
					intersectsRect.x = this.x + this.curr_rect.topLeft.x;
					intersectsRect.y = this.y + this.curr_rect.topLeft.y;
					intersectsRect.width = this.curr_rect.width;
					intersectsRect.height = this.curr_rect.height;
				} else {
					intersectsRect.x = this.x;
					intersectsRect.y = this.y;
				}
				ret = stageRect.intersects(intersectsRect);
			}
			return ret;
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
				case AvatarTypes.EFFECT_TYPE:
					return;
				case AvatarTypes.BODY_TYPE:
					return;
				case AvatarTypes.WEAPON_TYPE:
					return;
				case AvatarTypes.MOUNT_TYPE:
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
			if (((_headShape) && (_headShape.parent))) {
				_headShape.parent.removeChild(_headShape);
			}
			if (_headShape) {
				_headShape.dispose();
			}
			_headShape = null;
			this.shape = null;
			_bodyVisible = true;
			this.effectPlayEndDic = null;
			InstancePool.coder::getInstance().remove(this);
			this.shoadw = null;
			if (_iconSprite) {
				this.removeChild(_iconSprite);
				_iconSprite = null;
			}
			this.headIconUrl = null;
			_isOnMonut = false;
			this.onMonutHeight = 0;
			_point = null;
			_pt = null;
			if (_ap) {
				_ap.dispose();
			}
			_ap = null;
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
			_monutHeight = -80;
			InstancePool.coder::getInstance().recover(this);
		}

		override public function dispose():void
		{
			var _local_1:Bitmap;
			this.showBodyShoadw(false);
			this.effectPlayEndDic = null;
			if (_headShape) {
				_headShape.dispose();
			}
			_headShape = null;
			this.shoadw = null;
			if (_iconSprite) {
				this.removeChild(_iconSprite);
				_iconSprite = null;
			}
			_isAutoDispose = false;
			this.headIconUrl = null;
			_isOnMonut = false;
			this.onMonutHeight = 0;
			_monutHeight = -80;
			_point = null;
			_pt = null;
			_name = "";
			if (_ap) {
				_ap.dispose();
			}
			_ap = null;
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

		public function set headClickEnabled(val:Boolean):void
		{
			if (this.headShape) {
				this.headShape.clickEnabled = val;
			}
		}

	}
}
