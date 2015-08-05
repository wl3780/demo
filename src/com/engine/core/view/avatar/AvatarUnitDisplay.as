package com.engine.core.view.avatar
{
	import com.engine.core.Engine;
	import com.engine.core.view.DisplayObjectPort;
	import com.engine.core.view.quadTree.NoderSprite;
	import com.engine.core.view.scenes.SceneConst;
	import com.engine.interfaces.display.IAvatar;
	import com.engine.utils.Hash;
	import com.engine.utils.gome.LinearUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	public class AvatarUnitDisplay extends NoderSprite implements IAvatar
	{
		internal static var _instanceHash_:Hash = new Hash();
		internal static var depthBaseHash:Array = [["wgid", "mid", "wid"], ["wgid", "wid", "mid"], ["wid", "wgid", "mid"], ["wid", "mid", "wgid"], ["wid", "mid", "wgid"], ["mid", "wgid", "wid"], ["wgid", "mid", "wid"], ["wgid", "mid", "wid"]];
		internal static var depthAttackHash:Array = [["wgid", "mid", "wid"], ["wgid", "wid", "mid"], ["wid", "mid", "wgid"], ["wid", "mid", "wgid"], ["wid", "mid", "wgid"], ["mid", "wgid", "wid"], ["wgid", "mid", "wid"], ["wgid", "mid", "wid"]];
		internal static var depthDeathHash:Array = ["wid", "mid", "wgid"];
		internal static var charIntersectsRect:Rectangle = new Rectangle();

		private static var _recoverQueue_:Vector.<AvatarUnitDisplay> = new Vector.<AvatarUnitDisplay>();
		private static var _recoverIndex_:int = 5;

		public var mid:String;
		public var wid:String;
		public var midm:String;
		public var wgid:String;
		public var isLoopMove:Boolean;
		public var playEndFunc:Function;
		public var _ActionPlayEndFunc_:Function;
		
		protected var _effectsUnitHash_:Hash;
		protected var _isMainChar_:Boolean;
		protected var _stop_:Boolean;
		protected var _unit_:AvatarUnit;
		
		protected var bmd_mid:Bitmap;
		protected var bmd_wid:Bitmap;
		protected var bmd_wgid:Bitmap;
		protected var bmd_eid:Bitmap;
		protected var bmd_midm:Bitmap;
		protected var bmd_eid_top:Bitmap;
		protected var bmd_eid_bottom:Bitmap;
		
		protected var _hide_body_:Boolean = false;
		protected var _hide_wgid_:Boolean = false;
		protected var _hide_title_:Boolean = false;

		public function AvatarUnitDisplay()
		{
			super();
			_effectsUnitHash_ = new Hash();
			this.setup();
		}
		
		public static function get instanceHash():Hash
		{
			return _instanceHash_;
		}
		
		public static function takeUnitDisplay(unitDisplay_id:String):IAvatar
		{
			return _instanceHash_.take(unitDisplay_id) as IAvatar;
		}

		public function set priorLoadQueue(value:Vector.<String>):void
		{
			unit.priorLoadQueue = value;
		}
		public function get priorLoadQueue():Vector.<String>
		{
			return unit.priorLoadQueue;
		}
		
		public function hideBody(value:Boolean):void
		{
			_hide_body_ = value;
		}
		
		public function hideWing(value:Boolean):void
		{
			_hide_wgid_ = value;
		}
		
		public function hideTitle(value:Boolean):void
		{
			_hide_title_ = value;
		}
		
		override public function set type(value:String):void
		{
			super.type = value;
			if (this.unit) {
				unit.charType = value;
			}
		}
		
		public function setup():void
		{
			DisplayObjectPort.remove(this);
			_id_ = Engine.getSoleId();
			DisplayObjectPort.put(this);
			this.registerNodeTree(SceneConst.SCENE_ITEM_NODER);
			AvatarUnitDisplay._instanceHash_.put(this.id, this, true);
			this.reset();
		}
		
		public function get isMainChar():Boolean
		{
			return _isMainChar_;
		}
		
		public function stop():void
		{
			_stop_ = true;
			unit.stopPlay = true;
		}
		
		public function start():void
		{
			if (_stop_) {
				_stop_ = false;
				unit.stopPlay = false;
			}
		}
		
		public function play(action:String, renderType:int=0, playEndFunc:Function=null, stopFrame:int=-1):void
		{
			var list:Array = ["attack", "skill", "attack_warm", "skill_warm", "hit"];
			if ((list.indexOf(action) != -1) && (FPSUtils.fps <= 4)) {
				unit.loadActSWF();
				if (playEndFunc != null) {
					playEndFunc();
				}
				return;
			}
			if (playEndFunc != _ActionPlayEndFunc_) {
				_ActionPlayEndFunc_ = playEndFunc;
			}
			if (isLoopMove && action == ActionConst.Stand) {
				return;
			}
			if (action == ActionConst.Death) {
				renderType = AvatarUnit.PLAY_NEXT_RENDER;
			}
			this.unit.play(action, renderType, playEndFunc, stopFrame);
			updateBitmapDepth();
		}
		
		public function hasEffect(key:String):Boolean
		{
			return unit.effectHash.has(key);
		}
		
		public function effectPlay(key:String, act:String, frame:int=-1):void
		{
			unit.effectPlay(key, act, frame);
		}
		
		public function loadAvatarPart(type:String, idName:String, random:int=0):void
		{
			if (type == "mid") {
				mid = idName;
			}
			if (type == "wid") {
				wid = idName;
			}
			if (type == "wgid") {
				wgid = idName;
			}
			if (type == "midm") {
				midm = idName;
			}
			updateBitmapDepth();
			unit.charType = this.type;
			unit.loadAvatarParts(type, idName, 0, 0, random);
		}
		
		public function loadEffect(idName:String, layer:String=SceneConst.TOP_LAYER, passKey:String=null, remove:Boolean=false, dir:int=0, offsetX:int=0, offsetY:int=0, replay:int=-2, random:int=0, act:String="stand", type:String="eid"):String
		{
			if (!unit) {
				return null;
			}
			return unit.loadEffect(idName, layer, passKey, remove, offsetX, offsetY, replay, random, act, type);
		}
		
		public function death(value:Boolean):void
		{
		}
		
		public function set isAutoDispose(value:Boolean):void
		{
		}
		
		public function getDretion(curr_x:int, curr_y:int, tar_x:Number, tar_y:Number):int
		{
			return LinearUtils.getDirection(curr_x, curr_y, tar_x, tar_y);
		}
		
		public function get currFrame():int
		{
			return _unit_.mainActionData.currFrame;
		}
		
		public function getTotalFames(idName:String, action:String):int
		{
			return 0;
		}
		
		public function get isPlaying():Boolean
		{
			return false;
		}
		
		public function get dir():int
		{
			return _unit_.dir;
		}
		public function set dir(value:int):void
		{
			_unit_.dir = value;
			updateBitmapDepth();
		}
		
		public function updateBitmapDepth():void{
			var depthInfos:Array = depthBaseHash[this.dir];
			if (this.act == "attack" || this.act == "attack_warm" || this.act == "skill" || this.act == "skill_warm") {
				depthInfos = depthAttackHash[this.dir];
			} else (this.act == "death") {
				depthInfos = depthDeathHash;
			}
			
			var actKey:String = null;
			var actBitmap:Bitmap = null;
			for each (var actType:String in depthInfos) {
				actKey = "bmd_" + actType;
				actBitmap = this[actKey];
				if (!_hide_body_) {
					if (_hide_wgid_ && actKey == "bmd_wgid") {
						if (actBitmap && actBitmap.parent) {
							actBitmap.parent.removeChild(actBitmap);
						}
					} else {
						if (actBitmap) {
							this.addChildAt(actBitmap, 0);
						}
					}
				} else {
					if (actBitmap && actBitmap.parent) {
						actBitmap.parent.removeChild(actBitmap);
					}
				}
			}
		}
		
		public function get act():String
		{
			return _unit_.act;
		}
		
		public function get unit():AvatarUnit
		{
			return _unit_;
		}
		
		public function onEffectRender(oid:String, renderType:String, bitmapData:BitmapData, tx:int, ty:int):void
		{
			var bitmap:Bitmap = null;
			if (bitmapData && _effectsUnitHash_.has(oid) == false) {
				if (AvatarEffect.bitmapHash.length) {
					bitmap = AvatarEffect.bitmapHash.pop();
				} else {
					bitmap = new Bitmap();
				}
				bitmap.name = oid;
				_effectsUnitHash_.put(oid, bitmap);
			} else {
				bitmap = _effectsUnitHash_.take(oid) as Bitmap;
			}
			if (renderType == "BOTTOM_LAYER" || renderType == "body_bottom_effect" || renderType == "body_top_effect") {
				if (bitmapData && bitmap.name.indexOf(renderType) == -1) {
					bitmap.name = renderType;
				}
			} else {
				if (bitmapData) {
					addChild(bitmap);
				}
			}
			if (bitmapData == null) {
				_effectsUnitHash_.remove(oid);
				if (bitmap) {
					bitmap.bitmapData = null;
					if (bitmap.parent) {
						bitmap.parent.removeChild(bitmap);
					}
					bitmap = null;
				}
				return;
			}
			setBitmapValue(bitmap, bitmapData, -tx, -ty);
		}
		
		public function onBodyRender(renderType:String, bitmapType:String, bitmapData:BitmapData, tx:int, ty:int, shadow:BitmapData=null):void
		{
			var bitmap:Bitmap = null;
			if (bitmapData) {
				if (!_hide_body_) {
					if (renderType == "body_type") {
						switch (bitmapType) {
							case "mid":
								if (!bmd_mid) {
									bmd_mid = new Bitmap();
								}
								bitmap = bmd_mid;
								break;
							case "wid":
								if (!bmd_wid) {
									bmd_wid = new Bitmap();
								}
								bitmap = bmd_wid;
								break;
							case "wgid":
								if (!bmd_wgid) {
									bmd_wgid = new Bitmap();
								}
								bitmap = bmd_wgid;
								break;
							case "midm":
								if (!bmd_midm) {
									bmd_midm = new Bitmap();
								}
								bitmap = bmd_midm;
								break;
						}
					} else if (renderType == "body_effect") {
						if (!bmd_eid) {
							bmd_eid = new Bitmap();
							addChild(bmd_eid);
						}
						bitmap = bmd_eid;
					} else if (renderType == "body_top_effect") {
						if (!bmd_eid_bottom) {
							bmd_eid_bottom = new Bitmap();
						}
						bitmap = bmd_eid_bottom;
					} else if (renderType == "body_bottom_effect") {
						if (!bmd_eid_top) {
							bmd_eid_top = new Bitmap();
						}
						bitmap = bmd_eid_top;
					} else if (renderType == "effect") {
						if (!_effectsUnitHash_) {
							_effectsUnitHash_ = new Hash();
						}
					}
				}
				
				if (_hide_body_) {
					if (this.bmd_mid && bmd_mid.bitmapData) {
						bmd_mid.bitmapData = null;
					}
					if (this.bmd_wid && bmd_wid.bitmapData) {
						bmd_wid.bitmapData = null;
					}
					if (this.bmd_wgid && bmd_wgid.bitmapData) {
						bmd_wgid.bitmapData = null;
					}
				} else {
					if (_hide_wgid_) {
						if (this.bmd_wgid && bmd_wgid.bitmapData) {
							bmd_wgid.bitmapData = null;
						}
					}
					if (!bitmap.parent && bitmapData) {
						updateBitmapDepth();
					}
					setBitmapValue(bitmap, bitmapData, -tx, -ty);
				}
			} else {
				if (renderType == "body_type") {
					switch (bitmapType) {
						case "mid":
							if (bmd_mid && bmd_mid.bitmapData) {
								bmd_mid.bitmapData = null;
							}
							break;
						case "wid":
							if (bmd_wid && bmd_wid.bitmapData) {
								bmd_wid.bitmapData = null;
							}
							break;
						case "wgid":
							if (bmd_wgid && bmd_wgid.bitmapData) {
								bmd_wgid.bitmapData = null;
							}
							break;
						case "midm":
							if (bmd_midm && bmd_midm.bitmapData) {
								bmd_midm.bitmapData = null;
							}
							break;
					}
				} else if (renderType == "body_effect") {
					if (bmd_eid && bmd_eid.bitmapData) {
						bmd_eid.bitmapData = null;
					}
				} else if (renderType == "body_top_effect") {
					if (bmd_eid_bottom && bmd_eid_bottom.bitmapData) {
						bmd_eid_bottom.bitmapData = null;
					}
				} else if (renderType == "body_bottom_effect") {
					if (bmd_eid_top && bmd_eid_top.bitmapData) {
						bmd_eid_top.bitmapData = null;
					}
				} else if (renderType == "effect") {
					if (bmd_eid && bmd_eid.bitmapData) {
						bmd_eid.bitmapData = null;
					}
				}
			}
		}
		
		public function updateEffectXY():void
		{
			var arr:Array = null;
			var rType:String = null;
			for each (var bitmap:Bitmap in _effectsUnitHash_) {
				if (bitmap.name.indexOf("body_bottom_effect") != -1 || bitmap.name.indexOf("body_top_effect") != -1 || bitmap.name.indexOf("BOTTOM_LAYER") != -1) {
					arr = bitmap.name.split("#");
					bitmap.x = this.x + arr[4];
					bitmap.y = this.y + arr[5];
					rType = "";
					if (bitmap.name.indexOf("BOTTOM_LAYER") != -1) {
						rType = "BOTTOM_LAYER";
					}
					if (bitmap.name.indexOf("body_bottom_effect") != -1) {
						rType = "body_bottom_effect";
					}
					if (bitmap.name.indexOf("body_top_effect") != -1) {
						rType = "body_top_effect";
					}
					bitmap.name = id + "#" + rType + "#" + x + "#" + y + "#" + arr[4] + "#" + arr[5];
					if (!bitmap.parent && rType == "BOTTOM_LAYER") {
						Scene.scene.bottomLayer.addChild(bitmap);
					}
				}
			}
		}
		
		override public function set x(value:Number):void
		{
			super.x = value;
			this.updateEffectXY();
		}
		
		override public function set y(value:Number):void
		{
			super.y = value;
			this.updateEffectXY();
		}
		
		public function setBitmapValue(bitmap:Bitmap, bitmapData:BitmapData, vx:int, vy:int):void{
			if (!bitmap) {
				return;
			}
			if (bitmapData == null) {
				if (bitmap.parent) {
					bitmap.parent.removeChild(bitmap);
				}
				return;
			}
			if (_hide_body_ && bitmap && (bitmap == bmd_mid || bitmap == bmd_wid || bitmap == bmd_wgid)) {
				return;
			}
			if (stageIntersects) {
				var avatar:IAvatar = AvatarUnitDisplay.takeUnitDisplay(id);
				if (bitmap.bitmapData != bitmapData) {
					bitmap.bitmapData = bitmapData;
				}
				var bName:String = bitmap.name;
				if (bName.indexOf("body_bottom_effect") != -1) {
					if (bName.indexOf("#") != -1) {
						var arr:Array = bName.split("#");
						bitmap.x = arr[2] + vx;
						bitmap.y = arr[3] + vy;
						bitmap.name = id + "#" + "body_bottom_effect" + "#" + x + "#" + y + "#" + vx + "#" + vy;
					} else {
						bitmap.x = this.x + vx;
						bitmap.y = this.y + vy;
						bitmap.name = id + "#" + "body_bottom_effect" + "#" + x + "#" + y + "#" + vx + "#" + vy;
						if (bitmap.bitmapData != bitmapData || !bitmap.parent) {
							Scene.scene.bottomLayer.addChild(bitmap);
						}
					}
				} else {
					if (bName.indexOf("body_top_effect") != -1) {
						if (bName.indexOf("#") != -1) {
							arr = bName.split("#");
							if (int(arr[2] + vx) != bitmap.x) {
								bitmap.x = arr[2] + vx;
							}
							if (bitmap.y != int(arr[3] + vy)) {
								bitmap.y = arr[3] + vy;
							}
							bitmap.name = id + "#" + "body_bottom_effect" + "#" + x + "#" + y + "#" + vx + "#" + vy;
						} else {
							bitmap.x = this.x + vx;
							bitmap.y = this.y + vy;
							bitmap.name = id + "#" + "body_bottom_effect" + "#" + x + "#" + y + "#" + vx + "#" + vy;
							if (bitmap.bitmapData != bitmapData || !bitmap.parent) {
								Scene.scene.topLayer.addChild(bitmap);
							}
						}
					} else {
						if (bName.indexOf("BOTTOM_LAYER") != -1) {
							bitmap.x = x + vx;
							bitmap.y = y + vy;
							bitmap.name = id + "#" + "BOTTOM_LAYER" + "#" + x + "#" + y + "#" + vx + "#" + vy;
							updateEffectXY();
						} else {
							bitmap.x = vx;
							bitmap.y = vy;
						}
					}
				}
			}
		}
		
		public function get stageIntersects():Boolean
		{
			if (Scene.stageRect && (this as Char)) {
				var rect:Rectangle = charIntersectsRect;
				rect.x = x - 100;
				rect.y = y - 150;
				rect.width = 200;
				rect.height = 300;
				if (rect.width == 0) {
					rect.width = 1;
				}
				if (rect.height == 0) {
					rect.height = 1;
				}
				return Scene.stageRect.intersects(rect) ? true : false;
			}
			return true;
		}
		
		public function reset():void
		{
			DisplayObjectPort.removeTarget(this);
			_id_ = Asswc.getSoleId();
			this.registerNodeTree(SceneConst.SCENE_ITEM_NODER);
			DisplayObjectPort.addTarget(this);
			_instanceHash_.put(this.id, this, true);
			this.name = "char";
			_isDisposed_ = false;
			if (_unit_) {
				_unit_.dispose();
			}
			_unit_ = AvatarUnit.createAvatarUnit();
			_unit_.isMain = _isMainChar_;
			_unit_.oid = this.id;
			_unit_.init();
			unit = _unit_;
			priorLoadQueue = new <String>["stand"];
			if (bmd_mid && bmd_mid.bitmapData) {
				bmd_mid.bitmapData = null;
			}
			if (bmd_wid && bmd_wid.bitmapData) {
				bmd_wid.bitmapData = null;
			}
			if (bmd_midm && bmd_midm.bitmapData) {
				bmd_midm.bitmapData = null;
			}
			if (bmd_wgid && bmd_wgid.bitmapData) {
				bmd_wgid.bitmapData = null;
			}
			if (bmd_eid && bmd_eid.bitmapData) {
				bmd_eid.bitmapData = null;
			}
			if (bmd_eid_top && bmd_eid_top.bitmapData) {
				bmd_eid_top.bitmapData = null;
			}
			if (bmd_eid_bottom && bmd_eid_bottom.bitmapData) {
				bmd_eid_bottom.bitmapData = null;
			}
		}
		
		override public function resetForDisposed():void
		{
			super.resetForDisposed();
			_effectsUnitHash_ = new Hash();
			_isMainChar_ = false;
			_stop_ = false;
			isLoopMove = false;
			_hide_body_ = false;
			_hide_wgid_ = false;
			_hide_title_ = false;
			setup();
		}
		
		public function onEffectPlayEnd(oid:String):void
		{
			if (playEndFunc != null) {
				playEndFunc();
			}
		}
		
		public function playEnd(act:String):void
		{
			if (_ActionPlayEndFunc_ != null) {
				_ActionPlayEndFunc_(act);
				_ActionPlayEndFunc_ = null;
			}
		}
		
		public function recover():void
		{
			if (_isDisposed_) {
				return;
			}
			_isDisposed_ = true;
			playEndFunc = null;
			this.unactivate();
			for each (var bitmap:Bitmap in _effectsUnitHash_) {
				if (bitmap.parent) {
					bitmap.parent.removeChild(bitmap);
				}
			}
			_effectsUnitHash_.reset();
			if (unit) {
				AvatarRenderElisor.getInstance().removeUnit(unit.id);
			}
			unit.dispose();
			priorLoadQueue = new <String>["stand"];
			if (_recoverQueue_.length <= _recoverIndex_) {
				_recoverQueue_.push(this);
			}
		}
		
		override public function dispose():void
		{
			AvatarUnitDisplay._instanceHash_.remove(this.id);
			var index:int = _recoverQueue_.indexOf(this);
			if (index != -1) {
				_recoverQueue_.splice(index, 1);
			}
			priorLoadQueue = null;
			this.clearPartBitmap(bmd_mid);
			this.clearPartBitmap(bmd_wid);
			this.clearPartBitmap(bmd_wgid);
			this.clearPartBitmap(bmd_eid);
			this.clearPartBitmap(bmd_midm);
			this.clearPartBitmap(bmd_eid_top);
			this.clearPartBitmap(bmd_eid_bottom);
			bmd_mid = null;
			bmd_wid = null;
			bmd_wgid = null;
			bmd_eid = null;
			bmd_midm = null;
			bmd_eid_top = null;
			bmd_eid_bottom = null;
			mid = null;
			wid = null;
			midm = null;
			wgid = null;
			
			super.dispose();
			if (_unit_) {
				_unit_.dispose();
				_unit_ = null;
			}
			this.unactivate();
			for each (var bitmap:Bitmap in _effectsUnitHash_) {
				this.clearPartBitmap(bitmap);
			}
			_effectsUnitHash_ = null;
			this.alpha = 1;
			isLoopMove = false;
			_ActionPlayEndFunc_ = null;
			_isMainChar_ = false;
			_stop_ = false;
		}

		private function clearPartBitmap(bmd:Bitmap):void
		{
			if (bmd) {
				if (bmd.parent) {
					bmd.parent.removeChild(bmd);
				}
				bmd.bitmapData = null;
			}
		}
		
	}
} 
