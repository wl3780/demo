package com.engine.core.view.scenes
{
	import com.engine.core.tile.Cell;
	import com.engine.core.tile.TileGroup;
	import com.engine.core.tile.square.SquarePt;
	import com.engine.core.view.items.NoderItem;
	import com.engine.core.view.avatar.AvatartParts;
	import com.engine.core.view.avatar.IAvatar;
	import com.engine.core.view.avatar.ItemAvatar;
	import com.engine.utils.gome.SquareUitls;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;

	public class SceneItem extends NoderItem implements IAvatar 
	{

		private var _pt:SquarePt;
		private var _point:Point;
		private var nameText:TextField;
		private var shape:Bitmap;
		private var _name:String;
		private var view:Bitmap;
		private var _icon:DisplayObject;
		private var _effect:ItemAvatar;
		private var _isDisposed:Boolean;
		private var _type:String;
		private var _stop:Boolean = false;
		private var _isDeath:Boolean = false;

		public function SceneItem()
		{
			this.view = new Bitmap();
			this.addChild(this.view);
			_point = new Point();
		}

		public function get avatarParts():AvatartParts
		{
			return (null);
		}

		public function get isDeath():Boolean
		{
			return (_isDeath);
		}

		public function set isDeath(_arg_1:Boolean):void
		{
			_isDeath = _arg_1;
		}

		public function set stop(_arg_1:Boolean):void
		{
			_stop = _arg_1;
		}

		public function get stop():Boolean
		{
			return (_stop);
		}

		public function hitIcon():Boolean
		{
			return (false);
		}

		override public function set x(_arg_1:Number):void
		{
			super.x = _arg_1;
			if (_point) {
				_point.x = _arg_1;
				_pt = SquareUitls.pixelsToSquare(_point);
				this.setAlpha();
			}
		}

		override public function set y(_arg_1:Number):void
		{
			super.y = _arg_1;
			if (_point) {
				_point.y = _arg_1;
				_pt = SquareUitls.pixelsToSquare(_point);
				this.setAlpha();
			}
		}

		public function setAlpha():void
		{
			var _local_1:Cell = TileGroup.getInstance().take(this.pt.key);
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

		public function nameColor(_arg_1:uint):void
		{
			if (this.nameText == null) {
				this.nameText = new TextField();
				this.nameText.textColor = 0xFFFFFF;
				this.nameText.filters = [new GlowFilter(0, 1, 4, 4, 3)];
				this.nameText.mouseEnabled = false;
				this.nameText.mouseWheelEnabled = false;
				this.nameText.selectable = false;
				this.nameText.cacheAsBitmap = true;
			}
			if (this.nameText.textColor != _arg_1) {
				this.nameText.textColor = _arg_1;
			}
		}

		override public function set name(_arg_1:String):void
		{
			if (this.nameText == null) {
				this.nameText = new TextField();
				this.nameText.textColor = 0xFFFFFF;
				this.nameText.filters = [new GlowFilter(0, 1, 4, 4, 3)];
				this.nameText.mouseEnabled = false;
				this.nameText.mouseWheelEnabled = false;
				this.nameText.selectable = false;
				this.nameText.cacheAsBitmap = true;
			}
			if (_name != _arg_1) {
				_name = _arg_1;
				if (this.contains(this.nameText) == false) {
					if (this.contains(this.nameText) == false) {
						this.addChild(this.nameText);
					}
				}
				this.nameText.htmlText = _arg_1;
				this.nameText.width = (this.nameText.textWidth + 10);
				this.nameText.y = -45;
				this.nameText.x = (-(this.nameText.textWidth) / 2);
			}
		}

		override public function get name():String
		{
			return (_name);
		}

		public function set nikeNameVisible(_arg_1:Boolean):void
		{
			if (_arg_1) {
				if (this.nameText == null) {
					this.nameText = new TextField();
					this.nameText.textColor = 0xFFFFFF;
					this.nameText.filters = [new GlowFilter(0, 1, 4, 4, 3)];
					this.nameText.mouseEnabled = false;
					this.nameText.mouseWheelEnabled = false;
					this.nameText.selectable = false;
					this.nameText.cacheAsBitmap = true;
				}
				if (!this.contains(this.nameText)) {
					this.addChild(this.nameText);
				}
			} else {
				if (this.contains(this.nameText)) {
					this.removeChild(this.nameText);
				}
			}
		}

		public function onRender():void
		{
			this.nameText.x;
		}

		public function set pt(_arg_1:SquarePt):void
		{
			_pt = _arg_1;
			_point = SquareUitls.squareTopixels(_arg_1);
			super.x = _point.x;
			super.y = _point.y;
			if (_point) {
				_pt = SquareUitls.pixelsToSquare(_point);
				this.setAlpha();
			}
		}

		public function get pt():SquarePt
		{
			return (_pt);
		}

		public function set point(_arg_1:Point):void
		{
			_point = _arg_1;
			_pt = SquareUitls.pixelsToSquare(_arg_1);
			super.x = _arg_1.x;
			super.y = _arg_1.y;
			if (_point) {
				_pt = SquareUitls.pixelsToSquare(_point);
				this.setAlpha();
			}
		}

		public function get point():Point
		{
			return (_point);
		}

		public function set icon(_arg_1:DisplayObject):void
		{
			_icon = _arg_1;
			this.addChild(_arg_1);
		}

		public function set bitmapData(_arg_1:BitmapData):void
		{
			this.view.bitmapData = _arg_1;
			this.view.y = (this.view.y - (_arg_1.height / 2));
			this.view.x = (-(_arg_1.width) / 2);
			this.nameText.x = (-(this.nameText.textWidth) / 2);
			this.nameText.y = -45;
		}

		public function liangdu(_arg_1:Number):Array
		{
			return ([1, 0, 0, 0, _arg_1, 0, 1, 0, 0, _arg_1, 0, 0, 1, 0, _arg_1, 0, 0, 0, 1, 0]);
		}

		public function get isDisposed():Boolean
		{
			return (_isDisposed);
		}

		public function loadAvatarPart(avatarType:String, avatarNum:String):String
		{
			if (_effect) {
				_effect.dispose();
				_effect = null;
				if (this.contains(_effect)) {
					this.removeChild(_effect);
				}
			}
			_effect = new ItemAvatar();
			_effect.loadAvatarPart(avatarType, avatarNum);
			this.addChild(_effect);
			return (null);
		}

		public function get stageIntersects():Boolean
		{
			return (true);
		}

		override public function dispose():void
		{
			if (_effect) {
				_effect.dispose();
				if (this.contains(_effect)) {
					this.removeChild(_effect);
				}
				_effect = null;
			}
			if (_icon) {
				if (_icon.parent) {
					_icon.parent.removeChild(_icon);
				}
				_icon = null;
			}
			if (this.view) {
				(this.view.bitmapData == null);
				if (this.contains(this.view)) {
					this.removeChild(this.view);
				}
			}
			this.view = null;
			if (this.nameText) {
				this.nameText.text = "";
				this.nameText.filters = null;
				this.nameText = null;
			}
			if (this.shape) {
				this.shape.bitmapData = null;
				if (this.shape.parent) {
					this.removeChild(this.shape);
				}
			}
			this.shape = null;
			if (_pt) {
				_pt = null;
			}
			if (_point) {
				_point = null;
			}
			var _local_1:int = (this.numChildren - 1);
			while (_local_1) {
				this.removeChildAt(_local_1);
				_local_1--;
			}
			super.dispose();
		}

	}
}
