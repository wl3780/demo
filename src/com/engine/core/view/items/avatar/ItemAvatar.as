package com.engine.core.view.items.avatar
{
	import com.engine.core.Engine;
	import com.engine.core.ItemConst;
	import com.engine.core.tile.square.SquarePt;
	import com.engine.core.view.items.Item;
	import com.engine.core.view.scenes.Scene;
	import com.engine.core.view.scenes.SceneConstant;
	import com.engine.namespaces.coder;
	import com.engine.utils.gome.LinearUtils;
	import com.engine.utils.gome.SquareUitls;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;

	public class ItemAvatar extends Item implements IAvatar 
	{

		coder static var $itemAvataInstanceNumber:int;
		
		private static var recovery_point:Point = new Point();

		public var avatarParams:Dictionary;
		public var playEndFunc:Function;
		public var effect_id:String;
		public var curr_rect:Rectangle;
		public var isSkillEffect:Boolean = false;
		
		protected var bitmapdata_midm:Bitmap;
		protected var bitmapdata_wgid:Bitmap;
		protected var $isDisposed:Boolean = false;
		protected var _pt:SquarePt;
		protected var _point:Point;
		
		private var _ap:AvatartParts;
		private var bitmapdata_mid:Bitmap;
		private var bitmapdata_wid:Bitmap;
		private var eid_avatarBitmaps:Dictionary;
		private var nameText:TextField;
		private var _nameEnabled:Boolean = true;
		private var time:int = 0;

		public function ItemAvatar()
		{
			super();
			_point = new Point();
			this.setup();
			this.isSceneItem = false;
			ItemAvatar.coder::$itemAvataInstanceNumber++;
		}

		override public function set isAutoDispose(val:Boolean):void
		{
			_isAutoDispose = val;
			if (_ap) {
				_ap.isAutoDispose = val;
			}
		}

		override public function set isSceneItem(val:Boolean):void
		{
			super.isSceneItem = val;
			this.isAutoDispose = val;
		}

		public function get isDeath():Boolean
		{
			return false;
		}

		public function set pt(val:SquarePt):void
		{
			if (!_point) {
				_point = new Point();
			}
			_pt = val;
			_point = SquareUitls.squareTopixels(val);
			super.x = _point.x;
			super.y = _point.y;
		}
		public function get pt():SquarePt
		{
			return _pt;
		}

		public function set point(val:Point):void
		{
			_point = val;
			_pt = SquareUitls.pixelsToSquare(val);
			super.x = val.x;
			super.y = val.y;
		}
		public function get point():Point
		{
			return _point;
		}

		override public function set x(val:Number):void
		{
			super.x = val;
			_point.x = val;
			_pt = SquareUitls.pixelsToSquare(_point);
		}

		override public function set y(val:Number):void
		{
			super.y = val;
			_point.y = val;
			_pt = SquareUitls.pixelsToSquare(_point);
		}

		public function get isDisposed():Boolean
		{
			return this.$isDisposed;
		}
		public function set isDisposed(val:Boolean):void
		{
			this.$isDisposed = val;
		}

		public function get avatarParts():AvatartParts
		{
			return _ap;
		}
		public function set avatarParts(val:AvatartParts):void
		{
			_ap = val;
		}
		
		public function get stageIntersects():Boolean
		{
			var _local_2:Point;
			var _local_3:Rectangle;
			var _local_4:Rectangle;
			var _local_1:Boolean = true;
			if (((Scene.scene) && (this.isSceneItem))) {
				_local_2 = Scene.scene.globalToLocal(recovery_point);
				_local_3 = new Rectangle(_local_2.x, _local_2.y, Engine.stage.stageWidth, (Engine.stage.stageHeight + 150));
				_local_4 = new Rectangle(x, y, 1, 1);
				if (this.curr_rect != null) {
					_local_4.x = (x + this.curr_rect.topLeft.x);
					_local_4.y = (y + this.curr_rect.topLeft.y);
					_local_4.width = this.curr_rect.width;
					_local_4.height = this.curr_rect.height;
				}
				_local_1 = _local_3.intersects(_local_4);
			}
			return (_local_1);
		}
		
		public function set nameEnabled(val:Boolean):void
		{
			_nameEnabled = val;
			if (this.nameText) {
				this.nameText.visible = _nameEnabled;
			}
		}
		
		override public function set name(val:String):void
		{
			super.name = val;
			if (this.nameText == null) {
				this.nameText = new TextField();
				var format:TextFormat = new TextFormat();
				format.size = 12;
				this.nameText.defaultTextFormat = format;
				this.nameText.textColor = 0xFFFFFF;
				this.nameText.filters = [new GlowFilter(0, 1, 4, 4, 3)];
				this.nameText.mouseEnabled = false;
				this.nameText.mouseWheelEnabled = false;
				this.nameText.selectable = false;
				this.nameText.cacheAsBitmap = true;
			}
			this.nameText.visible = _nameEnabled;
			if (this.contains(this.nameText) == false) {
				this.addChild(this.nameText);
			}
			this.nameText.htmlText = val;
			this.nameText.width = this.nameText.textWidth + 10;
			this.nameText.x = -(this.nameText.textWidth / 2);
			this.nameText.y = -110;
		}
		
		public function set dir(val:int):void
		{
			if (this.avatarParts && this.avatarParts.dir != val) {
				this.avatarParts.dir = val;
			}
		}
		public function get dir():int
		{
			if (this.avatarParts) {
				return this.avatarParts.dir;
			}
			return 0;
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

		public function setup():void
		{
			this.avatarParams = new Dictionary();
			this.avatarParts = new AvatartParts();
			this.avatarParts.type = SceneConstant.EFFECT;
			this.avatarParts.onRender = this.onRender;
			this.avatarParts.clear = coder::clear;
			this.avatarParts.disposeEffectsFunc = coder::disposeEffects;
			this.avatarParts.playEndFunc = coder::playEndFunc;
			this.avatarParts.setupReady = coder::setupReady;
			this.avatarParts.loadErorFunc = coder::loadErrorFunc;
			this.avatarParts.coder::oid = this.id;
			this.char_id = this.id;
			this.isDisposed = false;
		}

		coder function loadErrorFunc():void
		{
			if (this.avatarParts.type == SceneConstant.EFFECT && this.isSceneItem) {
				this.dispose();
			}
		}

		coder function setupReady():void
		{
			if (this.avatarParams) {
				var action:String = this.avatarParts.state;
				this.loadCharActionAssets(action);
			}
		}

		coder function playEndFunc(params:Object):void
		{
			if (this.playEndFunc != null) {
				this.playEndFunc.apply(null);
			}
		}

		public function loadAvatarPart(url:String, _arg_2:AvatarRestrict=null):String
		{
			var _local_3:String;
			var _local_4:Array;
			var _local_5:String;
			var _local_6:String;
			var _local_7:String;
			var _local_8:Array;
			var _local_9:int;
			if (this.isDisposed) {
				return null;
			}
			if (this.avatarParams) {
				_local_3 = url;
				_local_4 = url.split("/");
				_local_5 = _local_4[(_local_4.length - 1)];
				_local_6 = _local_4[(_local_4.length - 2)];
				if ((_local_6 == null)) {
					_local_6 = "";
				}
				if (_local_4.length >= 2) {
					_local_4[(_local_4.length - 2)] = "output";
				} else {
					if (_local_4.length == 1) {
						_local_4.unshift("output");
					}
				}
				url = _local_4.join("/");
				_local_7 = _local_5.split("_")[0];
				_local_5 = _local_5.split(Engine.TMP_FILE)[0];
				_local_7 = _local_5.split("_")[0];
				url = url.split(Engine.TMP_FILE).join(".sm");
				_local_8 = _local_5.split("_");
				_local_9 = int(_local_8[1]);
				if (_local_9 > 0) {
					if (this.avatarParams[_local_5] == null) {
						this.avatarParams[_local_5] = _local_5;
					}
					this.avatarParts.type = SceneConstant.EFFECT;
					AvatarManager.coder::getInstance().put(this.avatarParts);
					AvatarAssetManager.getInstance().loadAvatar(url, this.avatarParts.id, _local_3);
				} else {
					if (this.avatarParts) {
						this.avatarParts.removeAvatarPartByType(_local_7);
						switch (_local_7) {
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
							case ItemConst.MOUNT_TYPE:
								if (this.bitmapdata_midm) {
									this.bitmapdata_midm.bitmapData = null;
								}
								break;
							case ItemConst.WING_TYPE:
								if (this.bitmapdata_wgid) {
									this.bitmapdata_wgid.bitmapData = null;
								}
								break;
						}
					}
				}
			}
			return null;
		}

		public function loadCharActionAssets(action:String):void
		{
			var _local_4:String;
			if (this.isDisposed) {
				return;
			}
			if (action == null || action == "") {
				return;
			}
			if (this.avatarParts.avatarParts == null) {
				return;
			}
			var dict:Dictionary = this.avatarParts.avatarParts[action];
			for each (var _local_3:AvatarParam in dict) {
				_local_4 = _local_3.assetsPath;
				_local_4 = _local_4.split(Engine.TMP_FILE).join((("_" + action) + Engine.TMP_FILE));
				AvatarAssetManager.getInstance().loadAvatarAssets(_local_4, action, this.avatarParts.id);
			}
		}

		public function play(action:String):void
		{
			if (this.isDisposed) {
				return;
			}
			this.avatarParts.state = action;
			this.loadCharActionAssets(action);
		}

		public function faceTo(target:DisplayObject):void
		{
			this.dir = this.getDretion(target.x, target.y);
		}

		public function setRotation(_arg_1:Number, _arg_2:Number):void
		{
			_arg_1 = (_arg_1 - this.x);
			_arg_2 = (_arg_2 - this.y);
			var _local_3:Number = Math.atan2(_arg_2, _arg_1);
			this.rotation = ((_local_3 * 180) / Math.PI);
		}

		public function getDretion(px:Number, py:Number):int
		{
			var ret:int = LinearUtils.getDirection(this.x, this.y, px, py);
			return ret;
		}

		coder function onRendStart():void
		{
			if (this.curr_rect) {
				this.curr_rect.setEmpty();
			}
		}

		coder function clear():void
		{
		}

		public function hitIcon():Boolean
		{
			return (false);
		}

		coder function disposeEffects(_arg_1:String):void
		{
			var _local_2:Bitmap;
			try {
				_local_2 = this.eid_avatarBitmaps[_arg_1];
				if (_local_2) {
					_local_2.bitmapData = null;
					if (_local_2.parent) {
						_local_2.parent.removeChild(_local_2);
					}
				}
			} catch(e:Error) {
			}
			this.dispose();
		}

		public function onRender(_arg_1:String, _arg_2:int, _arg_3:BitmapData, _arg_4:Rectangle, _arg_5:String, _arg_6:String=null, _arg_7:int=0, _arg_8:int=0, _arg_9:BitmapData=null):void
		{
			var _local_10:Bitmap;
			var _local_11:int;
			var _local_12:int;
			if (this.avatarParts.id != _arg_1) {
				return;
			}
			if (((((!(this.isDisposed)) && (this.stage))) && (!((this.parent == null))))) {
				if (this.stageIntersects) {
					if (_arg_5 == ItemConst.BODY_TYPE) {
						if (this.bitmapdata_mid == null) {
							this.bitmapdata_mid = new Bitmap();
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
					} else {
						if (_arg_5 == ItemConst.WEAPON_TYPE) {
							if (this.bitmapdata_wid == null) {
								this.bitmapdata_wid = new Bitmap();
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
							if (_arg_5 == ItemConst.MOUNT_TYPE) {
								if (this.bitmapdata_midm == null) {
									this.bitmapdata_midm = new Bitmap();
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
								_local_10 = this.bitmapdata_midm;
							} else {
								if (_arg_5 == ItemConst.WING_TYPE) {
									if (this.bitmapdata_midm == null) {
										this.bitmapdata_wgid = new Bitmap();
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
									if (_arg_5 == ItemConst.EFFECT_TYPE) {
										if (this.eid_avatarBitmaps == null) {
											this.eid_avatarBitmaps = new Dictionary();
										}
										if (this.eid_avatarBitmaps[_arg_6] == null) {
											this.eid_avatarBitmaps[_arg_6] = new Bitmap();
											this.addChild(this.eid_avatarBitmaps[_arg_6]);
										}
										_local_10 = this.eid_avatarBitmaps[_arg_6];
									}
								}
							}
						}
					}
					if (_local_10) {
						_local_11 = -(_arg_7);
						_local_12 = -(_arg_8);
						if (_local_10.bitmapData != _arg_3) {
							_local_10.bitmapData = _arg_3;
						}
						if ((((_arg_3 == Engine.shadow_bitmapData)) && (Engine.shadow_bitmapData))) {
							if (_local_10.x != _local_11) {
								_local_10.x = (-(Engine.shadow_bitmapData.width) / 2);
							}
							if (_local_10.y != _local_12) {
								_local_10.y = -(Engine.shadow_bitmapData.height);
							}
						} else {
							if (_local_10.x != _local_11) {
								_local_10.x = _local_11;
							}
							if (_local_10.y != _local_12) {
								_local_10.y = _local_12;
							}
						}
					}
				}
			}
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

		override public function dispose():void
		{
			var _local_1:Bitmap;
			var _local_2:String;
			if (this.avatarParts) {
				this.avatarParts.dispose();
				this.avatarParts = null;
			}
			if (this.bitmapdata_wid) {
				this.bitmapdata_wid.bitmapData = null;
			}
			if (this.bitmapdata_midm) {
				this.bitmapdata_midm.bitmapData = null;
			}
			if (this.bitmapdata_mid) {
				this.bitmapdata_mid.bitmapData = null;
			}
			if (this.bitmapdata_wgid) {
				this.bitmapdata_wgid.bitmapData = null;
			}
			if (((this.nameText) && (this.nameText.parent))) {
				this.nameText.parent.removeChild(this.nameText);
			}
			this.bitmapdata_midm = null;
			this.bitmapdata_wid = null;
			this.bitmapdata_mid = null;
			this.bitmapdata_wgid = null;
			_point = null;
			this.nameText = null;
			_nameEnabled = true;
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
			for (_local_2 in this.avatarParams) {
				delete this.avatarParams[_local_2];
			}
			this.avatarParams = null;
			_point = null;
			super.dispose();
			this.isDisposed = true;
			_pt = null;
			if (Scene.scene) {
				Scene.scene.remove(this);
			}
			ItemAvatar.coder::$itemAvataInstanceNumber--;
		}

	}
}
