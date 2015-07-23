package com.engine.core.view.avatar
{
	import com.engine.core.Engine;
	import com.engine.core.view.role.MainChar;
	import com.engine.core.view.scenes.Scene;
	import com.engine.core.view.scenes.SceneConstant;
	import com.engine.namespaces.coder;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class AvatarManager extends EventDispatcher 
	{

		private static var _instance:AvatarManager;

		public var effectHash:Dictionary;
		public var avatarHash:Dictionary;
		public var hashArray:Array;
		
		private var _avatarParams_:Array;
		private var lex:int;
		private var avatars_lengh:int;
		private var effects_length:int;
		private var onceTime:Number;
		private var lastHandleTimer:int = 0;
		private var tmpIndex:int = 0;

		public function AvatarManager()
		{
			this.effectHash = new Dictionary();
			this.hashArray = [];
			this.avatarHash = new Dictionary();
			_avatarParams_ = [];
			this.onceTime = Math.ceil(1000 / 30);
			super();
			Engine.stage.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}

		coder static function getInstance():AvatarManager
		{
			if (_instance == null) {
				_instance = new AvatarManager();
			}
			return _instance;
		}

		private function onEnterFrame(evt:Event):void
		{
			Engine.totalAvatarAssetsIndex = this.avatars_lengh;
			Engine.totalEffectAssetsIndex = this.effects_length;
			var passTime:int = getTimer() - this.lastHandleTimer;
			Engine.handleCount = Math.ceil(passTime / this.onceTime);
			var handleCount:int;
			if (Engine.fps > 10) {
				handleCount = Engine.handleCount;
			} else {
				handleCount = 1;
			}
			if (Engine.fps <= 3) {
				handleCount = Engine.handleCount;
			}
			while (handleCount > 0) {
				this.onRenderFunc(evt);
				handleCount--;
			}
			handleCount = Engine.handleCount;
			while (handleCount > 0) {
				this.onRenderFunc2(evt);
				handleCount--;
			}
			this.lastHandleTimer = getTimer();
		}

		public function clean():void
		{
			var _local_1:MainChar;
			var _local_2:AvatartParts;
			var _local_3:AvatartParts;
			var _local_4:int;
			var _local_5:String;
			var _local_6:String;
			if (Scene.scene.mainChar) {
				_local_1 = Scene.scene.mainChar;
				_local_2 = _local_1.avatarParts;
				_local_4 = 0;
				while (_local_4 < this.hashArray.length) {
					_local_3 = this.hashArray[_local_4];
					if (((!((_local_3 == _local_2))) && (_local_3.isAutoDispose))) {
						this.hashArray.splice(_local_4, 1);
						_local_4--;
					}
					_local_4++;
				}
				for (_local_5 in this.effectHash) {
					_local_3 = this.effectHash[_local_5];
					if (((!((_local_3 == _local_2))) && (_local_3.isAutoDispose))) {
						delete this.effectHash[_local_5];
					}
				}
				for (_local_6 in this.avatarHash) {
					_local_3 = this.avatarHash[_local_6];
					if (((!((_local_3 == _local_2))) && (_local_3.isAutoDispose))) {
						_local_3.dispose();
						delete this.avatarHash[_local_6];
					}
				}
				_avatarParams_ = [];
			}
		}

		private function onRenderFunc(... args):void
		{
			Engine.delayTime = getTimer();
			var num:int = 2;
			if (Scene.scene && Scene.scene.mainChar) {
				if (Scene.scene.mainChar.runing == false) {
					num = 2;
				} else {
					num = 7;
				}
			} else {
				num = 2;
			}
			
			var numIndex:int = this.lex % num;	// 分批渲染？？
			if (this.hashArray.length) {
				var renderNum:int;
				this.avatars_lengh = this.hashArray.length;
				if (this.hashArray.length < 30) {
					renderNum = 30;
				} else {
					renderNum = int(this.hashArray.length * 0.8);
				}
				var idx:int = 0;
				var parats:AvatartParts;
				while (idx < renderNum) {
					if (this.tmpIndex >= this.hashArray.length) {
						this.tmpIndex = 0;
					}
					parats = this.hashArray[this.tmpIndex];
					if (parats.type == SceneConstant.CHAR) {
						parats.bodyRender();
						parats.effectRender();
					} else {
						if (numIndex == 0) {
							parats.bodyRender();
							parats.effectRender();
						}
					}
					this.tmpIndex++;
					idx++;
				}
			}
			this.lex++;
		}

		private function onRenderFunc2(... args):void
		{
			this.effects_length = 0;
			for each (var parts:AvatartParts in this.avatarHash) {
				parts.effectRender();
				parts.bodyRender();
				this.effects_length++;
			}
		}

		public function put(parts:AvatartParts):void
		{
			if (parts) {
				if (parts.type == SceneConstant.EFFECT) {
					if (this.effectHash[parts.id] == null) {
						this.effectHash[parts.id] = parts;
					}
				} else {
					if (this.hashArray.indexOf(parts) == -1) {
						this.hashArray.push(parts);
					}
				}
				if (this.avatarHash[parts.id] == null) {
					this.avatarHash[parts.id] = parts;
				}
			}
		}

		public function remove(id:String):void
		{
			if (this.effectHash[id]) {
				delete this.effectHash[id];
			} else {
				var idx:int = this.hashArray.indexOf(this.avatarHash[id]);
				if (idx != -1) {
					this.hashArray.splice(idx, 1);
				}
			}
			if (this.avatarHash[id]) {
				delete this.avatarHash[id];
			}
		}

		public function take(id:String):AvatartParts
		{
			return this.avatarHash[id];
		}

		private function _loadedAvatar_():void
		{
			if (_avatarParams_.length) {
				var next:Object = _avatarParams_.shift();
				var key:String = next.key;
				var parts_id:String = next.avatarParts_id;
				var params:Dictionary = next.avatarParams;
				var parts:AvatartParts = this.avatarHash[parts_id] as AvatartParts;
				if (parts) {
					parts.coder::setupStart(key);
					var tmpParam:AvatarParam;
					for each (var paramItem:AvatarParam in params) {
						tmpParam = paramItem.clone() as AvatarParam;	// clone必须的
						tmpParam.coder::assets_id = next.assets_id;
						tmpParam.startPlayTime = next.startTime;
						parts.coder::addAvatarPart(tmpParam);
					}
					parts.coder::_setupReady_(key);
				}
			}
		}

		public function updataAvatar(_arg_1:String, _arg_2:String, _arg_3:Dictionary):void
		{
		}

		public function loadedAvatarError(id:String):void
		{
			var parts:AvatartParts = this.avatarHash[id] as AvatartParts;
			if (parts) {
				parts.coder::loadedError();
			}
		}

		public function loadedAvatar(assets_id:String, key:String, parts_id:String, startTime:int, params:Dictionary):void
		{
			_avatarParams_.push({
				"assets_id":assets_id,
				"key":key,
				"avatarParts_id":parts_id,
				"startTime":startTime,
				"avatarParams":params
			});
			_loadedAvatar_();
		}

	}
}
