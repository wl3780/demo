package com.engine.core.view.items.avatar
{
	import com.engine.core.Engine;
	import com.engine.core.AvatarTypes;
	import com.engine.core.RecoverUtils;
	import com.engine.core.view.items.BloodBar;
	import com.engine.core.view.quadTree.NoderSprite;
	import com.engine.core.view.scenes.Scene;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextField;

	public class HeadShape extends NoderSprite 
	{

		private static var renderQuene:Array = [];
		private static var _professionNameText:TextField;
		private static var _nameText:TextField;
		private static var _bloodBar:BloodBar = new BloodBar();
		private static var recovery_point:Point = new Point();

		public var moveFunc:Function;
		public var owner:Avatar;
		
		private var _headIconLeft:DisplayObject;
		private var _headIconRight:DisplayObject;
		private var _flag:DisplayObject;
		private var _headIconCenter:DisplayObject;
		private var _bmd:BitmapData;
		private var _headBitmapData:BitmapData;
		private var _curr:Number;
		private var _max:Number;
		private var _name:String;
		private var _professionName:String;
		private var _nameColor:uint = 0xFFFFFF;
		private var _professionNameColor:uint = 0xFF00;
		private var _nameVisible:Boolean = true;
		private var _professionNameVisible:Boolean = true;
		private var _bloodBarVisible:Boolean = false;
		private var _shape:Sprite;
		private var _tiles:Array;
		private var _headIconSize:int = 30;
		private var _clickEnabled:Boolean;

		public function HeadShape()
		{
			super();
			_shape = new Sprite();
			_shape.mouseChildren = _shape.mouseEnabled = false;
			this.addChild(_shape);
			this.cacheAsBitmap = true;
			_bloodBarVisible = false;
			this.unactivate();
		}

		public static function setBloodBitmapData(_arg_1:BitmapData):void
		{
			_bloodBar.bitmapData = _arg_1;
		}


		public function get clickEnabled():Boolean
		{
			return (_clickEnabled);
		}
		public function set clickEnabled(_arg_1:Boolean):void
		{
			_clickEnabled = _arg_1;
			if (_arg_1) {
				this.registerNodeTree(Engine.SCENE_ITEM_NODER);
				activate();
			} else {
				unactivate();
			}
		}

		override public function get graphics():Graphics
		{
			return (_shape.graphics);
		}

		public function setBoold(_arg_1:Number, _arg_2:Number):void
		{
			_curr = _arg_1;
			_max = _arg_2;
			this.draw();
		}

		public function showTitles(_arg_1:Array):void
		{
			var _local_2:int;
			var _local_3:Object;
			var _local_4:int;
			var _local_5:Object;
			if (_tiles) {
				_local_2 = 0;
				_local_2 = 0;
				while (_local_2 < _tiles.length) {
					_local_3 = _tiles[_local_2];
					if ((_local_3 as ItemAvatar)) {
						_local_3.dispose();
					} else {
						if ((_local_3 as Bitmap)) {
							Bitmap(_local_3).bitmapData = null;
							if (_local_3.parent) {
								_local_3.parent.removeChild(_local_3);
							}
						} else {
							if ((_local_3 as Loader)) {
								Loader(_local_3).unloadAndStop();
								if (_local_3.parent) {
									_local_3.parent.removeChild(_local_3);
								}
							} else {
								if ((_local_3 as DisplayObject)) {
									if (_local_3.parent) {
										_local_3.parent.removeChild(_local_3);
									}
								}
							}
						}
					}
					_local_2++;
				}
			}
			_tiles = [];
			if (_arg_1) {
				_local_4 = 0;
				_local_2 = 0;
				while (_local_2 < _arg_1.length) {
					_local_5 = _arg_1[_local_2];
					if (_local_5) {
						if ((_local_5 as DisplayObject)) {
							_local_3 = _local_5;
							_local_3.x = (-(_local_3.width) / 2);
						} else {
							if ((_local_5 as BitmapData)) {
								_local_3 = new Bitmap();
								Bitmap(_local_3).bitmapData = (_local_5 as BitmapData);
								_local_3.x = (-(_local_3.width) / 2);
							} else {
								if ((_local_5 as String)) {
									if (String(_local_5).indexOf("eid_") != -1) {
										_local_3 = new ItemAvatar();
										_local_3.loadAvatarPart(_arg_1[_local_2]);
									} else {
										_local_3 = new Loader();
										_local_3.load(new URLRequest((_local_5 as String)));
										_local_3.x = (-(_local_3.width) / 2);
									}
								}
							}
						}
						_tiles.push(_local_3);
						_local_4++;
					}
					_local_2++;
				}
			}
			this.reander();
		}

		override public function set name(_arg_1:String):void
		{
			if (_nameText == null) {
				_nameText = new TextField();
				_nameText.filters = [new GlowFilter(0, 1, 2, 2)];
				_nameText.selectable = false;
			}
			_name = _arg_1;
			this.draw();
		}

		public function get professionNameColor():uint
		{
			return (_professionNameColor);
		}

		public function set professionNameColor(_arg_1:uint):void
		{
			_professionNameColor = _arg_1;
			_professionNameVisible = true;
			this.draw();
		}

		public function get nameColor():uint
		{
			return (_nameColor);
		}

		public function set nameColor(_arg_1:uint):void
		{
			_nameColor = _arg_1;
			this.draw();
		}

		public function get bloodBarVisible():Boolean
		{
			return (_bloodBarVisible);
		}

		public function set bloodBarVisible(_arg_1:Boolean):void
		{
			if (_bloodBarVisible != _arg_1) {
				_bloodBarVisible = _arg_1;
				this.draw();
			}
		}

		public function get professionNameVisible():Boolean
		{
			return (_professionNameVisible);
		}

		public function set professionNameVisible(_arg_1:Boolean):void
		{
			if (_professionNameVisible != _arg_1) {
				_professionNameVisible = _arg_1;
				this.draw();
			}
		}

		public function get nameVisible():Boolean
		{
			return (_nameVisible);
		}

		public function set nameVisible(_arg_1:Boolean):void
		{
			if (_nameVisible != _arg_1) {
				_nameVisible = _arg_1;
				this.draw();
			}
		}

		public function disposeFlag():void
		{
			if (_flag) {
				if ((_flag is ItemAvatar)) {
					ItemAvatar(_flag).dispose();
				} else {
					if (_flag.parent) {
						_flag.parent.removeChild(_flag);
					}
					if ((_flag as Loader)) {
						Loader(_flag).unloadAndStop();
					}
					if ((_flag as Bitmap)) {
						Object(_flag).bitmapData = null;
					}
				}
				_flag = null;
			}
		}

		public function disposeHeadIcon(_arg_1:String="all"):void
		{
			if (((_headIconLeft) && ((((_arg_1 == "all")) || ((_arg_1 == "left")))))) {
				if ((_headIconLeft is ItemAvatar)) {
					ItemAvatar(_headIconLeft).dispose();
				} else {
					if (_headIconLeft.parent) {
						_headIconLeft.parent.removeChild(_headIconLeft);
					}
					if ((_headIconLeft as Loader)) {
						Loader(_headIconLeft).unloadAndStop();
					}
					if ((_headIconLeft as Bitmap)) {
						Bitmap(_headIconLeft).bitmapData = null;
					}
				}
				_headIconLeft = null;
			}
			if (((_headIconRight) && ((((_arg_1 == "all")) || ((_arg_1 == "right")))))) {
				if ((_headIconRight is ItemAvatar)) {
					ItemAvatar(_headIconRight).dispose();
				} else {
					if (_headIconRight.parent) {
						_headIconRight.parent.removeChild(_headIconRight);
					}
					if ((_headIconRight as Loader)) {
						Loader(_headIconRight).unloadAndStop();
					}
					if ((_headIconRight as Bitmap)) {
						Bitmap(_headIconRight).bitmapData = null;
					}
				}
				_headIconRight = null;
			}
			if (((_headIconCenter) && ((((_arg_1 == "all")) || ((_arg_1 == "center")))))) {
				if ((_headIconCenter is ItemAvatar)) {
					ItemAvatar(_headIconCenter).dispose();
				} else {
					if (_headIconCenter.parent) {
						_headIconCenter.parent.removeChild(_headIconCenter);
					}
					if ((_headIconCenter as Loader)) {
						Loader(_headIconCenter).unloadAndStop();
					}
					if ((_headIconCenter as Bitmap)) {
						Bitmap(_headIconCenter).bitmapData = null;
					}
				}
				_headIconCenter = null;
			}
		}

		public function showFlag(_arg_1:DisplayObject):void
		{
			if (((_flag) && (_flag.parent))) {
				_flag.parent.removeChild(_flag);
			}
			_flag = _arg_1;
			this.draw();
		}

		public function setHeadIcon(_arg_1:Object, _arg_2:String="center"):void
		{
			var _local_3:DisplayObject;
			if ((((_arg_1 == "")) || (!(_arg_1)))) {
				this.disposeHeadIcon("");
			}
			this.disposeHeadIcon(_arg_2);
			if (_arg_1) {
				if ((_arg_1 as String)) {
					_local_3 = new ItemAvatar();
					ItemAvatar(_local_3).loadAvatarPart(AvatarTypes.EFFECT_TYPE, (_arg_1 as String));	// 有问题
				} else {
					if ((_arg_1 as BitmapData)) {
						_local_3 = new Bitmap();
						Bitmap(_local_3).bitmapData = (_arg_1 as BitmapData);
					} else {
						if ((_arg_1 as DisplayObject)) {
							_local_3 = (_arg_1 as DisplayObject);
						}
					}
				}
				if (_arg_2 == "left") {
					_headIconLeft = _local_3;
				}
				if (_arg_2 == "right") {
					_headIconRight = _local_3;
				}
				if (_arg_2 == "center") {
					_headIconCenter = _local_3;
				}
				if (_local_3) {
					this.addChild(_local_3);
				}
				this.draw();
			}
		}

		public function showHeadBtmapData(_arg_1:BitmapData):void
		{
			_headBitmapData = _arg_1;
			this.draw();
		}

		public function draw():void
		{
			if (this.hasEventListener(Event.ENTER_FRAME) == false) {
				this.addEventListener(Event.ENTER_FRAME, this.enterFrameFunc);
			}
		}

		private function enterFrameFunc(_arg_1:Event):void
		{
			this.removeEventListener(Event.ENTER_FRAME, this.enterFrameFunc);
			this.reander();
		}

		public function stageIntersects():void
		{
			if (((((!(Engine.CORE_RECT)) || ((this.visible == false)))) || (!(this.owner)))) {
				if (this.parent) {
					this.parent.removeChild(this);
				}
				return;
			}
			var _local_1:Rectangle = this.getBounds(this);
			var _local_2:Point = recovery_point;
			_local_2.x = _local_1.x;
			_local_2.y = _local_1.y;
			_local_2 = this.localToGlobal(_local_2);
			_local_1.x = _local_2.x;
			_local_1.y = _local_2.y;
			if (((((((!(_local_1.isEmpty())) && (Avatar.stageRect))) && (!(Avatar.stageRect.intersects(_local_1))))) || (!(this.owner.parent)))) {
				if (this.parent) {
					this.parent.removeChild(this);
				}
			} else {
				if (!this.parent) {
					if (Scene.scene.getSceneFlyMode()) {
						Scene.scene.$flyLayer.addChild(this);
					} else {
						Scene.scene.$topLayer.addChild(this);
					}
				}
			}
		}

		public function reander():void
		{
			var _local_4:int;
			var _local_5:DisplayObject;
			var _local_6:int;
			var _local_7:DisplayObject;
			this.cacheAsBitmap = false;
			var _local_1:Sprite = _shape;
			if (_nameText) {
				_nameText.htmlText = "";
			}
			if (_professionNameText) {
				_professionNameText.htmlText = "";
			}
			if (_bmd) {
				_bmd.dispose();
			}
			this.graphics.clear();
			while (_local_1.numChildren) {
				_local_1.removeChildAt(0);
			}
			if (((_flag) && (_flag.parent))) {
				_flag.parent.removeChild(_flag);
			}
			if (((_headIconLeft) && (_headIconLeft.parent))) {
				_headIconLeft.parent.removeChild(_headIconLeft);
			}
			if (((_headIconRight) && (_headIconRight.parent))) {
				_headIconRight.parent.removeChild(_headIconRight);
			}
			if (((_headIconCenter) && (_headIconCenter.parent))) {
				_headIconCenter.parent.removeChild(_headIconCenter);
			}
			if (_tiles) {
				_local_4 = 0;
				while (_local_4 < _tiles.length) {
					_local_5 = _tiles[_local_4];
					if (_local_5.parent) {
						_local_5.parent.removeChild(_local_5);
					}
					_local_4++;
				}
			}
			if (((_bloodBar) && (_bloodBarVisible))) {
				_local_1.addChild(_bloodBar);
			}
			if (((((((_name) && (!((_name == ""))))) && (_nameText))) && (_nameVisible))) {
				_local_1.addChild(_nameText);
			}
			if (((((((_professionName) && (!((_professionName == ""))))) && (_professionNameText))) && (_professionNameVisible))) {
				_local_1.addChild(_professionNameText);
			}
			if (((((_professionNameText) && (_professionName))) && (_professionNameVisible))) {
				_professionNameText.textColor = this.professionNameColor;
				_professionNameText.width = 200;
				_professionNameText.htmlText = _professionName;
				_professionNameText.width = (_professionNameText.textWidth + 4);
				_professionNameText.x = (-(_professionNameText.width) / 2);
				_professionNameText.height = (_professionNameText.textHeight + 4);
				_professionNameText.y = 0;
			}
			if (((((_nameText) && (_name))) && (_nameVisible))) {
				_nameText.textColor = this.nameColor;
				_nameText.width = 200;
				_nameText.htmlText = _name;
				_nameText.width = (_nameText.textWidth + 4);
				_nameText.x = (-(_nameText.width) / 2);
				_nameText.height = (_nameText.textHeight + 4);
				if (((_professionName) && (_nameVisible))) {
					_nameText.y = (_professionNameText.textHeight + 2);
				} else {
					_nameText.y = 0;
				}
			}
			if (_bloodBar) {
				_bloodBar.width = 60;
				_bloodBar.height = 5;
				_bloodBar.setValue(_curr, _max);
				_bloodBar.x = -30;
				if (_nameText) {
					_bloodBar.y = ((_nameText.y + _nameText.textHeight) + 2);
				} else {
					if (_professionNameText) {
						_bloodBar.y = ((_professionNameText.y + _professionNameText.textHeight) + 2);
					}
				}
			}
			var _local_2:Rectangle = _shape.getBounds(null);
			if (_local_2.isEmpty()) {
				return;
			}
			var _local_3:Matrix = RecoverUtils.matrix;
			_local_3.tx = -(_local_2.x);
			_local_3.ty = (_local_3.ty - 2);
			_bmd = new BitmapData((_shape.width + 2), (_shape.height + 2), true, 0);
			_bmd.draw(_local_1, _local_3);
			if (((_nameText) && (_nameText.parent))) {
				_nameText.parent.removeChild(_nameText);
			}
			if (((_professionNameText) && (_professionNameText.parent))) {
				_professionNameText.parent.removeChild(_professionNameText);
			}
			if (((_bloodBar) && (_bloodBar.parent))) {
				_bloodBar.parent.removeChild(_bloodBar);
			}
			_local_3 = RecoverUtils.matrix;
			_local_3.tx = _local_2.x;
			_local_3.ty = -(_local_2.height);
			this.graphics.beginBitmapFill(_bmd, _local_3, false);
			this.graphics.drawRect(_local_3.tx, _local_3.ty, _bmd.width, _bmd.height);
			if (_headBitmapData) {
				_local_3 = RecoverUtils.matrix;
				_local_3.tx = (-(_headBitmapData.width) / 2);
				_local_3.ty = ((-(_headBitmapData.height) - _local_2.height) - 2);
				this.graphics.beginBitmapFill(_headBitmapData, _local_3, false);
				this.graphics.drawRect(_local_3.tx, _local_3.ty, _headBitmapData.width, _headBitmapData.height);
			}
			this.cacheAsBitmap = true;
			if (_tiles) {
				_local_6 = 0;
				while (_local_6 < _tiles.length) {
					_local_7 = _tiles[_local_6];
					_local_7.y = (-((_shape.height + 3)) - ((_local_6 + 1) * _local_7.height));
					this.addChild(_local_7);
					_local_6++;
				}
			}
			if (_headIconLeft) {
				_headIconLeft.y = (-(_headIconSize) / 2);
				_headIconLeft.x = ((_local_3.tx - _headIconSize) - 5);
				if (_headIconLeft.width > 0) {
					_headIconLeft.x = ((_local_3.tx - _headIconLeft.width) - 1);
				}
				this.addChild(_headIconLeft);
			}
			if (_flag) {
				if (_headIconLeft) {
					_flag.x = ((_headIconLeft.x - _headIconSize) - 5);
					if (_flag.width > 0) {
						_flag.x = ((_headIconLeft.x - _flag.width) - 1);
					}
				} else {
					_flag.x = ((_local_3.tx - _headIconSize) - 5);
					if (_flag.width > 0) {
						_flag.x = ((_local_3.tx - _flag.width) - 1);
					}
				}
				_flag.y = (-(_headIconSize) / 2);
				this.addChild(_flag);
			}
			if (_headIconRight) {
				_headIconRight.y = (-(_headIconSize) / 2);
				_headIconRight.x = ((_bmd.width - _headIconSize) + 5);
				if (_headIconRight.width > 0) {
					(_bmd.width - _headIconRight.width);
				}
				this.addChild(_headIconRight);
			}
			if (_headIconCenter) {
				if ((_headIconCenter as ItemAvatar)) {
					_headIconCenter.y = (-(_shape.height) - _headIconSize);
				} else {
					_headIconCenter.y = (-(_shape.height) - _headIconCenter.height);
					_headIconCenter.x = (-(_headIconCenter.width) / 2);
				}
				this.addChild(_headIconCenter);
			}
		}

		override public function get height():Number
		{
			return (_shape.height);
		}

		public function reset():void
		{
			var _local_1:int;
			var _local_2:DisplayObject;
			this.moveFunc = null;
			this.owner = null;
			_headBitmapData = null;
			_name = null;
			_professionName = null;
			_curr = 100;
			_max = 100;
			_nameColor = 0xFFFFFF;
			_professionNameColor = 0xFF00;
			this.disposeHeadIcon();
			if (_bmd) {
				_bmd.dispose();
			}
			if (_tiles) {
				_local_1 = 0;
				_local_1 = 0;
				while (_local_1 < _tiles.length) {
					_local_2 = _tiles[_local_1];
					if ((_local_2 as ItemAvatar)) {
						ItemAvatar(_local_2).dispose();
					} else {
						if ((_local_2 as Bitmap)) {
							Bitmap(_local_2).bitmapData = null;
							if (_local_2.parent) {
								_local_2.parent.removeChild(_local_2);
							}
						} else {
							if ((_local_2 as DisplayObject)) {
								_local_2.parent.removeChild(_local_2);
							}
						}
					}
					_local_1++;
				}
				this.disposeHeadIcon();
				this.disposeFlag();
			}
			this.graphics.clear();
		}

		override public function dispose():void
		{
			this.reset();
			super.dispose();
		}

		override public function get name():String
		{
			return (_name);
		}

		public function set professionName(_arg_1:String):void
		{
			if (_professionName != _arg_1) {
				_professionName = _arg_1;
				if (_professionNameText == null) {
					_professionNameText = new TextField();
					_professionNameText.filters = [new GlowFilter(0, 1, 2, 2)];
					_professionNameText.selectable = false;
				}
				this.draw();
			}
		}

		public function get professionName():String
		{
			return (_professionName);
		}

		public function setup(_arg_1:Function):void
		{
			this.moveFunc = _arg_1;
		}

		override public function set x(_arg_1:Number):void
		{
			super.x = _arg_1;
			if (this.moveFunc != null) {
				this.moveFunc();
			}
			if (((((((!(this.owner)) && ((x == 0)))) && ((y == 0)))) && (this.stage))) {
				this.parent.removeChild(this);
			}
		}

		override public function set y(_arg_1:Number):void
		{
			super.y = _arg_1;
			if (this.moveFunc != null) {
				this.moveFunc();
			}
			if (((((((!(this.owner)) && ((x == 0)))) && ((y == 0)))) && (this.stage))) {
				this.parent.removeChild(this);
			}
		}

	}
}
