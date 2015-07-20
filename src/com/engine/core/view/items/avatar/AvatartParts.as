package com.engine.core.view.items.avatar
{
	import com.engine.core.Engine;
	import com.engine.core.AvatarTypes;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class AvatartParts extends Proto 
	{

		public var avatarParts:Dictionary;
		public var effectsParts:Dictionary;
		
		public var eid_len:int = 0;
		public var type:String;
		public var attackSpeed:Number = 1;
		public var vs:Number = 0;
		public var acce:Number = 1;
		public var runing:Boolean;
		public var jumping:Boolean;
		public var isTimeoutDelete:Boolean = true;
		public var specialMode:int = 0;
		public var isFlyMode:Boolean = false;
		public var isAutoDispose:Boolean = true;
		public var isPalyStandDeay:Boolean = true;
		public var isOnMonut:Boolean;
		public var lockEffectState:Boolean = true;
		
		public var setupReady:Function;
		public var onRender:Function;
		public var clear:Function;
		public var disposeEffectsFunc:Function;
		public var playEndFunc:Function;
		public var loadErorFunc:Function;
		public var onRendStart:Function;
		public var playEffectFunc:Function;
		
		protected var _effectRestrict:Dictionary;
		
		private var assetsIndex:int;
		private var counter:int;
		private var _stop:Boolean = false;
		private var _effectRestricts:Dictionary;
		private var _state:String = CharAction.STAND;
		private var oldState:String = CharAction.STAND
		private var _currRestrict:AvatarRestrict;
		private var _currentFrame:int = 0;
		private var _fly_currentFrame:int = 0;
		private var _totalFrames:int = 4;
		private var _dir:int = 4;
		private var _speed:int = 0;
		private var wid_id:String;
		private var mid_id:String;
		private var midm_id:String;
		private var isDisposed:Boolean = false;
		private var _isLockSpeed:Boolean = false;
		private var _lockSpeedState:String = "all";
		private var _isLockEffectPlaySpeed:Boolean;
		private var _lockEffectPlaySpeed:int;
		private var lockSpeedValue:int;

		public function AvatartParts()
		{
			super();
			_currRestrict = new AvatarRestrict();
			_effectRestrict = new Dictionary();
		}

		public function get stop():Boolean
		{
			return _stop;
		}
		public function set stop(val:Boolean):void
		{
			_stop = val;
		}

		public function addEffectRestrict(effID:String, effRestrict:AvatarRestrict):void
		{
			if (_effectRestrict[effID] == null) {
				_effectRestrict[effID] = effRestrict;
			}
		}
		
		public function getEffectRestrict(effID:String):AvatarRestrict
		{
			for each (var item:AvatarRestrict in _effectRestrict) {
				if (effID == item.oid) {
					return item;
				}
			}
			return null;
		}

		public function removeEffectRestrict(effID:String):void
		{
			delete _effectRestrict[effID];
		}

		public function get speed():int
		{
			return _speed;
		}
		coder function set speed(val:int):void
		{
			_speed = val;
		}

		public function setSpeedLock(_arg_1:Boolean, _arg_2:int=0, _arg_3:String="all"):void
		{
			_lockSpeedState = _arg_3;
			_isLockSpeed = _arg_1;
			this.lockSpeedValue = _arg_2;
		}

		public function lockEffectPlaySpeed(_arg_1:Boolean, _arg_2:int=0):void
		{
			_isLockEffectPlaySpeed = _arg_1;
			_lockEffectPlaySpeed = _arg_2;
		}

		public function get restrict():AvatarRestrict
		{
			return _currRestrict;
		}
		public function set restrict(val:AvatarRestrict):void
		{
			_currRestrict = val;
		}

		public function get state():String
		{
			return _state;
		}
		public function set state(val:String):void
		{
			if (_state != val) {
				_state = val;
			}
		}

		public function get currentFrame():int
		{
			return _currentFrame;
		}
		public function set currentFrame(val:int):void
		{
			_currentFrame = val;
		}

		public function get totalFrames():int
		{
			return _totalFrames;
		}

		public function play(state:String=null, restrict:AvatarRestrict=null, playNow:Boolean=false):void
		{
			if (state != this.state) {
				this.currentFrame = 0;
				this.counter = 0;
				if (restrict) {
					restrict.state = state;
					this.restrict = restrict;
				}
				this.state = state;
				if (playNow) {
					this.bodyRender();
				}
			}
		}

		public function bodyRender(now:Boolean=false):void
		{
			if (this.isDisposed || _stop || this.avatarParts == null) {
				return;
			}
			
			var playAction:String = this.state;
			if (this.isFlyMode && this.isOnMonut && playAction != CharAction.MEDITATION && playAction != CharAction.SKILL2) {
				playAction = CharAction.STAND;
			}
			if (this.specialMode == 1) {
				playAction = CharAction.SKILL2;
			}
			var actionDict:Dictionary = this.avatarParts[playAction] as Dictionary;
			if (this.oldState != this.state) {
				this.counter = 0;
				_currentFrame = 0;
			}
			if (actionDict) {
				if (this.clear != null) {
					this.clear();
				}
				var param:AvatarParam = actionDict[this.mid_id];
				if (param == null) {
					param = actionDict[this.midm_id];
					if (param == null) {
						param == actionDict[this.wid_id];
						if (param == null) {
							return;
						}
					}
				}
				_speed = param.speed * (1 / this.acce);
				if (_isLockSpeed && (_lockSpeedState == "all" || _lockSpeedState == this.state)) {
					_speed = this.lockSpeedValue;
				}
				if (this.runing == false && this.state == CharAction.WALK) {
					this.state = CharAction.STAND;
				}
				var interval:int = _speed - this.vs;
				if (this.state == CharAction.ATTACK || this.state == CharAction.QUNGONG || this.state == CharAction.SKILL1 || this.state == CharAction.MEDITATION) {
					interval = this.attackSpeed * _speed;
				}
				
				var passTime:int = Engine.delayTime - this.counter;
				if (passTime >= interval || now) {
					this.counter = Engine.delayTime;
					this.oldState = this.state;
					if (this.onRendStart != null) {
						this.onRendStart();
					}
					for each (param in actionDict) {
						var callParam:Object = {
							"assets_id":param.coder::assets_id,
							"link":param.action,
							"type":param.avatarType,
							"avatarParm_oid":param.oid,
							"avatarParm_id":param.id
						}
						_totalFrames = param.frames;
						var playType:String = param.avatarType;
						if (_currentFrame >= param.frames && (!this.isFlyMode || playType != AvatarTypes.MOUNT_TYPE)) {
							if (this.specialMode == 1 && _currentFrame >= param.frames) {
								_currentFrame = 0;
							} else if (!(_currRestrict && _currRestrict.state == playAction) && _currRestrict.stopInLastFrame) {
								_currentFrame = 0;
								if (this.playEndFunc != null) {
									this.playEndFunc(callParam);
								}
							} else if (_currRestrict && _currRestrict.state && playAction != CharAction.DEATH && playAction != CharAction.MEDITATION) {
								if (this.playEndFunc != null) {
									this.playEndFunc(callParam);
								}
								if (this.isPalyStandDeay) {
									this.play(CharAction.STAND);
								} else {
									_currentFrame = param.frames - 1;
								}
							} else {
								_currentFrame = param.frames - 1;
							}
						}
						if (_currentFrame == (param.frames-2)) {
							if (this.playEffectFunc != null) {
								this.playEffectFunc(param);
							}
						}
						var bmd:BitmapData;
						var playFrame:int;
						if (playType == AvatarTypes.MOUNT_TYPE && this.isFlyMode) {
							playFrame = param.frames - 1;
							if (_fly_currentFrame > playFrame) {
								_fly_currentFrame = 0;
							}
							bmd = param.getBitmapData(this.dir, _fly_currentFrame);
						} else {
							bmd = param.getBitmapData(this.dir, _currentFrame);
						}
						if (this.isFlyMode && playType == AvatarTypes.MOUNT_TYPE && playFrame < _currentFrame) {
							bmd = param.getBitmapData(this.dir, _fly_currentFrame);
						}
						if (param.maxRects[this.dir] == null) {
							param.maxRects[this.dir] = new Rectangle(0, 0, 0, 110);
						}
						if (bmd && bmd != Engine.shadow_bitmapData && bmd.width > 0 && bmd.height > 0) {
							param.maxRects[this.dir] = bmd.rect.union(param.maxRects[this.dir]);
						}
						var rect:Rectangle = param.maxRects[this.dir];
						if (param.replay == 0) {
							delete this.avatarParts[param.oid];
							param.dispose();
							break;
						}
						
						if (param.replay > 0 || param.replay == -1) {
							if (this.isFlyMode && playType == AvatarTypes.MOUNT_TYPE) {
								this.onRender(this.id, _dir, bmd, rect, param.avatarType, param.id, param.txs[_dir][_fly_currentFrame], param.tys[_dir][_fly_currentFrame]);
							} else {
								this.onRender(this.id, _dir, bmd, rect, param.avatarType, param.id, param.txs[_dir][_currentFrame], param.tys[_dir][_currentFrame]);
							}
							if (param.replay > 0 && _currentFrame >= param.frames) {
								param.replay--;
							}
						}
					}
					_currentFrame++;
					_fly_currentFrame++;
				}
			}
		}

		public function effectRender():void
		{
			if (this.isDisposed || this.effectsParts == null) {
				return;
			}
		
			var actionDict:Dictionary;
			if (this.lockEffectState) {
				actionDict = this.effectsParts[CharAction.STAND] as Dictionary;
			} else {
				actionDict = this.effectsParts[this.state] as Dictionary;
				if (!actionDict) {
					actionDict = this.effectsParts[CharAction.STAND] as Dictionary;
				}
			}
			if (actionDict) {
				if (this.clear != null) {
					this.clear();
				}
				for each (var param:AvatarParam in actionDict) {
					if (!this.lockEffectState) {
						param.replay = -1;
					}
					var _local_12:Object = {
						"assets_id":param.coder::assets_id,
						"link":param.action,
						"type":param.avatarType,
						"avatarParm_oid":param.oid,
						"avatarParm_id":param.id
					};
					var _local_13:Boolean = false;
					var _local_14:AvatarRestrict = this.getEffectRestrict(_local_12.assets_id);
					if (((_local_14) && ((_local_14.oid == _local_12.assets_id)))) {
						if (_local_14.gotoAndPlay) {
							param.currentFrame = _local_14.stopFrame;
						}
						if (_local_14.gotoAndPlayLastFrame) {
							param.currentFrame--;
						}
						if (_local_14.stopInLastFrame) {
							_local_13 = true;
						}
					}
					var _local_11:int
					if (param.heights.length == 1) {
						_local_11 = 0;
					} else {
						_local_11 = this.dir;
					}
					var _local_15:int = (Engine.delayTime - param.counter);
					if (((((!((param.replay == -1))) && (((Engine.delayTime - param.startPlayTime) > (((param.replay * param.speed) * param.frames) + 3000))))) && (!(_local_13)))) {
						param.replay = 0;
					}
					var _local_2:BitmapData;
					var _local_3:Rectangle;
					var _local_6:String;
					if (((((this.isTimeoutDelete) && ((ItemAvatar.coder::$itemAvataInstanceNumber > 500)))) && (int(((getTimer() / 1000) < 30))))) {
						param.replay = 0;
						_local_6 = (param.id + param.oid);
						this.onRender(0, null, _local_3, param.avatarType);
						this.disposeEffectsFunc(param.id);
						delete actionDict[_local_6];
						param.dispose();
						this.eid_len--;
						if (this.loadErorFunc != null) {
							this.loadErorFunc();
						}
						break;
					}
					var _local_16:int = param.speed;
					if (_isLockEffectPlaySpeed) {
						_local_16 = _lockEffectPlaySpeed;
					}
					if (_local_15 >= _local_16) {
						param.counter = Engine.delayTime;
						var _local_10:int = param.currentFrame;
						_local_3 = param.getRect(_local_11, _local_10);
						_local_2 = param.getBitmapData(_local_11, _local_10);
						if (_local_2) {
							param.currentFrame = (param.currentFrame + Engine.handleCount);
							var _local_5:int = _local_3.width;
							if (((_local_13) && ((param.currentFrame >= param.frames)))) {
								param.currentFrame--;
							}
							if (param.replay == 0) {
								_local_6 = (param.id + param.oid);
								this.onRender(this.id, 0, null, _local_3, param.avatarType);
								this.disposeEffectsFunc(param.id);
								delete actionDict[_local_6];
								param.dispose();
								this.eid_len--;
								break;
							}
							if (param.replay > 0) {
								this.onRender(this.id, _local_11, _local_2, _local_3, param.avatarType, param.id, param.txs[_local_11][_local_10], param.tys[_local_11][_local_10]);
								if (param.currentFrame >= param.frames) {
									if (!_local_13) {
										param.currentFrame = 0;
										param.replay--;
									}
									if (this.playEndFunc != null) {
										this.playEndFunc(_local_12);
									}
								}
							} else {
								this.onRender(this.id, _local_11, _local_2, _local_3, param.avatarType, param.id, param.txs[_local_11][_local_10], param.tys[_local_11][_local_10]);
								if (param.currentFrame >= param.frames) {
									param.currentFrame = 0;
									if (this.playEndFunc != null) {
										this.playEndFunc(_local_12);
									}
								}
							}
						} else {
							if (((((((!(_local_2)) && (this.isTimeoutDelete))) && ((param.startPlayTime > 0)))) && (((param.counter - param.startPlayTime) > 15000)))) {
								_local_6 = (param.id + param.oid);
								this.onRender(this.id, 0, null, _local_3, param.avatarType);
								this.disposeEffectsFunc(param.id);
								delete actionDict[_local_6];
								param.dispose();
								this.eid_len--;
								break;
							}
						}
					}
				}
			}
		}

		public function removeAvatarPartByType(itemType:String):void
		{
			if (this.avatarParts) {
				var subType:String;
				for each (var dict:Dictionary in this.avatarParts) {
					for (var subKey:String in dict) {
						subType = subKey.split("_")[0];
						if (itemType == subType) {
							delete dict[subKey];
						}
					}
				}
			}
		}

		public function removeEffect(itemType:String):String
		{
			var pid:String;
			if (this.effectsParts) {
				var dict:Dictionary = this.effectsParts[CharAction.STAND];
				var param:AvatarParam;
				for (var subKey:String in dict) {
					if (subKey.indexOf(itemType) != -1) {
						param = dict[subKey];
						pid = param.id;
						param.dispose();
						delete dict[subKey];
						break;
					}
				}
			}
			return pid;
		}

		public function removeAvatarPart(linkKey:String):void
		{
			delete this.avatarParts[linkKey];
		}

		coder function setupStart(avatarId:String):void
		{
			var finded:Boolean = false;
			var avatarType:String = avatarId.split("_")[0];
			for each (var dict:Dictionary in this.avatarParts) {
				for (var subKey:String in dict) {
					var subType:String = subKey.split("_")[0];
					if (subType == avatarType && subType != AvatarTypes.EFFECT_TYPE && avatarId != subKey) {
						var param:AvatarParam = dict[subKey];
						delete dict[subKey];
						if (param) {
							param.dispose();
						}
						finded = true;
					}
				}
			}
			if (finded && this.onRender != null) {
				this.onRender(this.id, 0, null, new Rectangle(0, 0, 0, 110), null, avatarType, 0, 0);
			}
		}

		coder function loadedError():void
		{
			if (this.loadErorFunc != null) {
				this.loadErorFunc();
			}
		}

		coder function _setupReady_(key:String):void
		{
			if (this.setupReady != null) {
				this.setupReady();
			}
			this.bodyRender(true);
		}

		coder function addEffectRestrict(_arg_1:AvatarRestrict):void
		{
			if (_effectRestricts == null) {
				_effectRestricts = new Dictionary();
			}
			if (_effectRestricts[_arg_1.oid] == null) {
				_effectRestricts[_arg_1.oid] = new Dictionary();
			}
			_effectRestricts[_arg_1.oid][_arg_1.id] = _arg_1;
		}

		coder function addAvatarPart(param:AvatarParam):void
		{
			if (param == null) {
				return;
			}
			var tmpAction:String = param.action;
			var tmpOid:String = param.oid;
			if (tmpOid) {
				if (param.avatarType == AvatarTypes.EFFECT_TYPE) {
					if (this.effectsParts == null) {
						this.effectsParts = new Dictionary();
					}
					if (this.effectsParts[tmpAction] == null) {
						this.effectsParts[tmpAction] = new Dictionary();
					}
					this.effectsParts[tmpAction][param.id + tmpOid] = param;
					this.eid_len++;
				} else {
					var itemType:String = tmpOid.split("_")[0];
					if (itemType == AvatarTypes.BODY_TYPE) {
						this.mid_id = tmpOid;
					}
					if (itemType == AvatarTypes.MOUNT_TYPE) {
						this.midm_id = tmpOid;
					}
					if (itemType == AvatarTypes.WEAPON_TYPE) {
						this.wid_id = tmpOid;
					}
					if (this.avatarParts == null) {
						this.avatarParts = new Dictionary();
					}
					if (this.avatarParts[tmpAction] == null) {
						this.avatarParts[tmpAction] = new Dictionary();
					}
					this.avatarParts[tmpAction][tmpOid] = param;
				}
			}
		}

		public function get dir():int
		{
			return _dir;
		}
		public function set dir(val:int):void
		{
			_dir = val;
		}

		public function hasAssets(itemType:String):Boolean
		{
			var dict:Dictionary;
			var subKey:String;
			for each (dict in this.avatarParts) {
				for (subKey in dict) {
					if (subKey.indexOf(itemType) != -1) {
						return true;
					}
				}
			}
			for each (dict in this.effectsParts) {
				for (subKey in dict) {
					if (subKey.indexOf(itemType) != -1) {
						return true;
					}
				}
			}
			return false;
		}

		override public function dispose():void
		{
			this.acce = 1;
			this.assetsIndex = 0;
			this.isDisposed = true;
			this.isFlyMode = false;
			this.isAutoDispose = true;
			this.counter = 0;
			this.dir = 0;
			this.lockSpeedValue = 0;
			_currentFrame = 0;
			_fly_currentFrame = 0;
			_isLockSpeed = false;
			_lockSpeedState = "all";
			this.oldState = "stand";
			_speed = 0;
			_totalFrames = 0;
			AvatarManager.coder::getInstance().remove(this.id);
			this.disposeEffectsFunc = null;
			this.clear = null;
			this.onRender = null;
			this.playEndFunc = null;
			this.onRendStart = null;
			this.setupReady = null;
			this.loadErorFunc = null;
			this.playEffectFunc = null;
			this.type = null;
			_state = "stand";
			var dict:Dictionary;
			for each (dict in this.effectsParts) {
				for each (var _local_2:AvatarParam in dict) {
					_local_2.dispose();
				}
			}
			this.effectsParts = null;
			for each (dict in this.avatarParts) {
				for each (var _local_3:AvatarParam in dict) {
					_local_3.dispose();
				}
			}
			this.avatarParts = null;
			_effectRestrict = null;
			if (_currRestrict) {
				_currRestrict.dispose();
				_currRestrict = null;
			}
			this.mid_id = null;
			this.midm_id = null;
			super.dispose();
		}

	}
}
