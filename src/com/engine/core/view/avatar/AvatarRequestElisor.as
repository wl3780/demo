package com.engine.core.view.avatar
{
	import com.engine.core.Engine;
	import com.engine.core.EngineGlobal;
	import com.engine.core.HeartbeatFactory;
	import com.engine.core.controls.events.WealthEvent;
	import com.engine.core.controls.wealth.WealthConst;
	import com.engine.core.controls.wealth.WealthManager;
	import com.engine.core.controls.wealth.WealthPool;
	import com.engine.core.controls.wealth.WealthQueueAlone;
	import com.engine.core.controls.wealth.loader.BingLoader;
	import com.engine.core.controls.wealth.loader.DisplayLoader;
	import com.engine.core.model.wealth.WealthVo;
	import com.engine.core.view.avatar.data.AvatarActionData;
	import com.engine.core.view.avatar.data.AvatarActionFormat;
	import com.engine.core.view.avatar.data.AvatarActionFormatGroup;
	import com.engine.core.view.scenes.Scene;
	import com.engine.interfaces.display.ILoader;
	import com.engine.utils.FPSUtils;
	import com.engine.utils.Hash;
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class AvatarRequestElisor
	{
		public static var analyzeSWFQueueNow:Array = [];
		public static var AvatarLoadHash:Hash = new Hash();
		
		private static var _instance_:AvatarRequestElisor;
		private static var _bitmapdataHash_:Hash = new Hash();

		public var stop:Boolean = false;
		
		private var _wealthQueue_:WealthQueueAlone;
		private var _requestsHash_:Hash;
		private var _urlRequestsHash_:Hash;
		private var loadIndex:int = 80;
		private var analyeHash:Dictionary;

		public function AvatarRequestElisor()
		{
			_requestsHash_ = new Hash();
			_urlRequestsHash_ = new Hash();
			analyeHash = new Dictionary();
			super();
			this.setup();
		}
		
		public static function set stop(value:Boolean):void
		{
			AvatarRequestElisor.getInstance().wealthQueue.stop = value;
		}
		public static function get stop():Boolean
		{
			return AvatarRequestElisor.getInstance().wealthQueue.stop;
		}
		
		public static function getBitmapDataHash(key:String, link:String):Dictionary
		{
			return _bitmapdataHash_.take(key) as Dictionary;
		}
		
		public static function getBitmapData(key:String, link:String):BitmapData
		{
			var dic:Dictionary = _bitmapdataHash_.take(key) as Dictionary;
			if (dic) {
				return dic[link] as BitmapData;
			}
			return null;
		}
		
		public static function getInstance():AvatarRequestElisor
		{
			return _instance_ ||= new AvatarRequestElisor();
		}
		
		public function get wealthQueue():WealthQueueAlone
		{
			return _wealthQueue_;
		}
		
		public function setup():void
		{
			AvatarRenderElisor.getInstance();
			_wealthQueue_ = new WealthQueueAlone();
			_wealthQueue_.loaderContext = null;
			_wealthQueue_.delay = 18;
			_wealthQueue_.limitIndex = loadIndex;
			_wealthQueue_.name = WealthConst.AVATAR_REQUEST_WEALTH;
			_wealthQueue_.isSortOn = true;
			_wealthQueue_.addEventListener(WealthEvent.WEALTH_COMPLETE, onWealthLoadFunc);
			HeartbeatFactory.getInstance().addFrameOrder(heartBeatHandler, Engine.stage);
		}
		
		private function heartBeatHandler():void
		{
			if (this.stop) {
				return;
			}
			var queueLen:int = analyzeSWFQueueNow.length;
			if (queueLen > 36) {
				queueLen = 36;
			}
			if (analyzeSWFQueueNow.length > 200) {
				queueLen = 200;
			}
			if (FPSUtils.fps < 15) {
				queueLen = 36;
			}
			var data:Object = null;
			while (queueLen > 0 && analyzeSWFQueueNow.length) {
				data = analyzeSWFQueueNow.shift();
				this.analyzeSWF(data);
				queueLen--;
			}
		}
		
		public function loadAvatarFormat(unit_id:String, idName:String):String
		{
			if (!idName || idName == "null" || idName == "0") {
				log(this, "AvatarFormat id can not be null");
			}
			
			var path:String = EngineGlobal.getAvatarAssetsConfigPath(idName);
			var type:String = idName.split(Engine.LINE)[0];
			var actData:AvatarActionData = AvatarActionData.createAvatarActionData();
			var group:AvatarActionFormatGroup = _requestsHash_.take(path) as AvatarActionFormatGroup;
			if (!group) {
				group = AvatarActionFormatGroup.createAvatarActionFormatGroup();
				group.wealth_path = path;
				_requestsHash_.put(path, group);
			}
			group.quoteQueue.push(actData.id);
			actData.oid = unit_id;
			actData.type = type;
			actData.idName = idName;
			actData.path = path;
			actData.startTime = getTimer();
			actData.avatarDataFormatGroup_id = group.id;
			if (idName == ("mid_" + EngineGlobal.SHADOW_ID)) {
				EngineGlobal.shadowAvatarGroup = group;
				EngineGlobal.avatarData = actData;
			}
			if (idName == ("mid_" + EngineGlobal.FAMALE_SHADOW)) {
				EngineGlobal.shadowAvatarGroupFamale = group;
				EngineGlobal.avatarDataFamale = actData;
			}
			if (idName == ("mid_" + EngineGlobal.MALE_SHADOW)) {
				EngineGlobal.shadowAvatarGroupMale = group;
				EngineGlobal.avatarDataMale = actData;
			}
			if (idName == "mid_wco001") {
				EngineGlobal.shadowAvatarGroupBaseFamale = group;
				EngineGlobal.avatarDataBaseFamale = actData;
			}
			if (idName == "mid_wcx001") {
				EngineGlobal.shadowAvatarGroupBaseMale = group;
				EngineGlobal.avatarDataBaseMale = actData;
			}
			if (group.isLoaded == false) {
				if (group.isPended == false) {
					group.isPended = true;
					group.wealth_id = _wealthQueue_.addWealth(path, {
						actionDataGroup_id:group.id,
						avatarData_id:actData.id,
						avatarUnit_id:unit_id
					});
				}
			} else {
				actData.onSetupReady();
			}
			return actData.id;
		}
		
		protected function onWealthLoadFunc(evt:WealthEvent):void
		{
			var path:String = evt.path;
			var loader:ILoader = WealthPool.takeLoaderByWealth(path);
			var wealthData:WealthVo = WealthVo.takeWealthVo(evt.wealth_id);
			if (loader as BingLoader) {
				if (wealthData.data) {
					var formatGroup:AvatarActionFormatGroup = AvatarActionFormatGroup.takeAvatarActionFormatGroup(wealthData.data.actionDataGroup_id);
					this.analyeAvatarActionFormat(formatGroup, (loader as BingLoader).data as ByteArray);
					formatGroup.isLoaded = true;
					formatGroup.isPended = false;
					formatGroup.noticeAvatarActionData();
				}
				wealthData.dispose();
			} else if (loader as DisplayLoader) {
				if (wealthData.data) {
					var actInfo:Object = this.getActAndDir(path);
					analyzeSWFQueueNow.push({
						data:wealthData.data,
						path:path,
						act:actInfo.act,
						dir:actInfo.dir
					});
				}
				wealthData.dispose();
			} else {
				log(this, "加载完成【异常】loader查询失败！", path);
			}
		}
		
		public function getActAndDir(path:String):Object
		{
			var arr:Array = path.split("/");
			var fileName:String = arr[arr.length - 1].split(".")[0];
			arr = fileName.split("_");
			var act:String = arr[2];
			var dir:int = arr[arr.length - 1];
			return {
				act:act,
				dir:dir
			};
		}
		
		private function analyeAvatarActionFormat(actionGroup:AvatarActionFormatGroup, byte:ByteArray):void
		{
			try {
				byte.position = 0;
				byte.uncompress();
			} catch (e:Error) {
				log(this, "重复解压错？");
			}
			
			var idName:String = byte.readUTF();
			actionGroup.idName = idName;
			var len:int = byte.readByte();
			var index:int;
			var actionFormat:AvatarActionFormat;
			while (index < len) {
				actionFormat = AvatarActionFormat.createAvatarActionFormat();
				actionFormat.oid = actionGroup.id;
				actionFormat.idName = idName;
				var actionName:String = byte.readUTF();
				var totalFrames:int = byte.readByte();
				var actionSpeed:int = byte.readShort();
				var replay:int = byte.readInt();
				var skillFrame:int = byte.readByte();
				var hitFrame:int = byte.readByte();
				var totalDir:int = byte.readByte();
				actionFormat.actionName = actionName;
				actionFormat.totalFrames = totalFrames;
				actionFormat.actionSpeed = actionSpeed;
				actionFormat.replay = replay;
				actionFormat.skillFrame = skillFrame==0 ? totalFrames - 2 : skillFrame;
				actionFormat.hitFrame = hitFrame;
				actionFormat.totalDir = totalDir;
				if (actionFormat.replay == 0) {
					actionFormat.replay = 1;
				}
				actionFormat.totalTime = 0;
				
				var frameIndex:int = 0;
				while (frameIndex < totalFrames) {
					var interval:int = byte.readInt();
					actionFormat.intervalTimes.push(actionSpeed + interval);
					actionFormat.totalTime += actionSpeed + interval;
					frameIndex++;
				}
				
				var dirIndex:int = 0;
				while (dirIndex < totalDir) {
					actionFormat.dirOffsetX[dirIndex] = byte.readInt();
					actionFormat.dirOffsetY[dirIndex] = byte.readInt();
					dirIndex++;
				}
				
				dirIndex = 0;
				while (dirIndex < totalDir) {
					var bWidths:Vector.<uint> = new Vector.<uint>();
					var bHeights:Vector.<uint> = new Vector.<uint>();
					var bTxs:Vector.<int> = new Vector.<int>();
					var bTys:Vector.<int> = new Vector.<int>();
					var bBitmapdatas:Vector.<String> = new Vector.<String>();
					
					frameIndex = 0;
					while (frameIndex < totalFrames) {
						var w:int = byte.readShort();
						var h:int = byte.readShort();
						var tx:int = byte.readShort();
						var ty:int = byte.readShort();
						tx = tx - 400;//EngineGlobal.AVATAR_IMAGE_WIDTH;
						ty = ty - 300;//EngineGlobal.AVATAR_IMAGE_HEIGHT;
						bWidths.push(w);
						bHeights.push(h);
						bTxs.push(tx);
						bTys.push(ty);
						bBitmapdatas.push(actionFormat.getLink(dirIndex, frameIndex));
						frameIndex ++;
					}
					actionFormat.widths.push(bWidths);
					actionFormat.heights.push(bHeights);
					actionFormat.txs.push(bTxs);
					actionFormat.tys.push(bTys);
					actionFormat.bitmapdatas.push(bBitmapdatas);
					dirIndex ++;
				}
				actionGroup.addAction(actionName, actionFormat);
				index++;
			}
			if (actionGroup.isCreateWarn) {
				if (actionGroup.hasAction("attack")) {
					this.addWarmDataFormat("attack", "attack_warm", actionGroup);
				}
				if (actionGroup.hasAction("walk")) {
					this.addWarmDataFormat("walk", "walk_warm", actionGroup, 1);
				}
				if (actionGroup.hasAction("run")) {
					this.addWarmDataFormat("run", "run_warm", actionGroup, 1);
				}
			}
		}
		
		private function addWarmDataFormat(copyFrom:String, warmAction:String, actionGroup:AvatarActionFormatGroup, replay:int=-1):void
		{
			var copyFormat:AvatarActionFormat = actionGroup.takeAction(copyFrom);
			if (!copyFormat) {
				return;
			}

			var actionFormat:AvatarActionFormat = AvatarActionFormat.createAvatarActionFormat();
			actionFormat.oid = actionGroup.id;
			actionFormat.idName = actionGroup.idName;
			actionFormat.actionName = warmAction;
			actionFormat.totalFrames = 1;
			actionFormat.actionSpeed = copyFormat.actionSpeed;
			actionFormat.replay = -1;
			actionFormat.skillFrame = 0;
			actionFormat.hitFrame = 0;
			actionFormat.totalDir = copyFormat.totalDir;
			actionFormat.totalTime = 0;
			
			var frameIndex:int = 0;	// 与原版有出入
			while (frameIndex < actionFormat.totalFrames) {
				actionFormat.intervalTimes.push(actionFormat.actionSpeed + 0);
				actionFormat.totalTime += actionFormat.actionSpeed + 0;
				frameIndex++;
			}
			
			var dirIndex:int = 0;
			while (dirIndex < actionFormat.totalDir) {
				actionFormat.dirOffsetX[dirIndex] = copyFormat.dirOffsetX[dirIndex];
				actionFormat.dirOffsetY[dirIndex] = copyFormat.dirOffsetY[dirIndex];
				dirIndex++;
			}
			dirIndex = 0;
			while (dirIndex < actionFormat.totalDir) {
				var bWidths:Vector.<uint> = copyFormat.widths[dirIndex].slice(0, 1);
				var bHeights:Vector.<uint> = copyFormat.heights[dirIndex].slice(0, 1);
				var bTxs:Vector.<int> = copyFormat.txs[dirIndex].slice(0, 1);
				var bTys:Vector.<int> = copyFormat.tys[dirIndex].slice(0, 1);
				var bBitmapdatas:Vector.<int> = copyFormat.bitmapdatas[dirIndex].slice(0, 1);
				
				actionFormat.widths.push(bWidths);
				actionFormat.heights.push(bHeights);
				actionFormat.txs.push(bTxs);
				actionFormat.tys.push(bTys);
				actionFormat.bitmapdatas.push(bBitmapdatas);
				dirIndex++;
			}
			actionGroup.addAction(warmAction, actionFormat);
		}
		
		public function loadAvatarSWF(dataFormat_id:String, idName:String, act:String, dir:int=0):void
		{
			if (act.indexOf("warm") != -1) {
				return;
			}
			var idType:String = idName.split(Engine.LINE)[0];
			var path:String = EngineGlobal.getAvatarAssetsPath(idName, act ,dir);
			var loader:DisplayLoader = WealthPool.takeLoaderByWealth(path) as DisplayLoader;
			if (loader) {
				var avatarData:AvatarActionFormat = AvatarActionFormat.takeAvatarActionFormat(dataFormat_id);
				avatarData.path = path;
				var analyKey:String = avatarData.idName + "." + avatarData.actionName + "." + dir;
				var has:Boolean = false;
				if (analyeHash[avatarData.idName] != null) {
					has = analyeHash[avatarData.idName][analyKey] != null ? true : false;
				}
				if (!has) {
					this.analyzeSWF({
						data:dataFormat_id,
						path:path,
						act:act,
						dir:dir
					});
				}
			} else {
				if (_wealthQueue_._wealthGroup_.hashWealth(path) == false) {
					var reqKey:String = dataFormat_id + Engine.SIGN + path;
					_urlRequestsHash_.put(reqKey, reqKey, true);
					var prio:int = -1;
					if (path.indexOf("npc") != -1) {
						prio = 1;
					} else if (path.indexOf("ms") != -1) {
						prio = 2;
					}
					var arr:Array = [Scene.scene.mainChar.mid, Scene.scene.mainChar.wid, Scene.scene.mainChar.wgid];
					var index:int = arr.indexOf(idName);
					if (index != -1) {
						prio = -1;
					}
					_wealthQueue_.addWealth(path, dataFormat_id, null, null, prio);
				}
			}
		}
		
		public function hasRequests(idName:String, act:String):Boolean
		{
			for (var url:String in _urlRequestsHash_) {
				if (url.indexOf(idName) != -1 && url.indexOf(act) != -1) {
					return true;
				}
			}
			return false;
		}
		
		public function hasAnalyzeSWF(idName:String, act:String):Boolean
		{
			var dic:Dictionary = analyeHash[idName];
			if (dic) {
				for (var key:String in dic) {
					if (key.indexOf(idName) != -1 && key.indexOf(act) != -1) {
						return true;
					}
				}
			}
			return false;
		}
		
		private function analyzeSWF(data:Object):void
		{
			var actionFormat_id:String = data.data;
			var actionGroup:AvatarActionFormatGroup = AvatarActionFormatGroup.takeAvatarActionFormatGroup(actionFormat.oid);
			var actionFormat:AvatarActionFormat = AvatarActionFormat.takeAvatarActionFormat(actionFormat_id);
			if (actionFormat) {
				if (data.act != actionFormat.actionName) {
					return;
				}
				var totalFrams:int = actionFormat.totalFrames;
				var idName:String = actionFormat.idName;
				var act:String = data.act;
				var path:String = data.path;
				var dir:int = data.dir;
				var key:String = idName + "." + act + "." + dir;
				if (act.indexOf("warm") != -1) {
					path = path.replace("attack_warm", "attack");
				}
				var loader:DisplayLoader = WealthPool.takeLoaderByWealth(path) as DisplayLoader;
				if (!loader) {
					return;
				}
				var isOk:Boolean = true;
				actionFormat.setActReady(data.act, data.dir, true);
				
				var dic:Dictionary = null;
				if (analyeHash[idName] == null) {
					dic = new Dictionary();
					analyeHash[idName] = dic;
				} else {
					dic = analyeHash[idName];
				}
				if (dic[key] == null) {
					dic[key] = key;
					var bitmapdataDic:Dictionary = _bitmapdataHash_.take(idName + "_" + act) as Dictionary;
					if (!bitmapdataDic) {
						bitmapdataDic = new Dictionary();
					}
					
					var link:String = null;
					var cls:Class = null;
					var bmd:BitmapData = null;
					var frameIndex:int = 0;
					while (frameIndex < totalFrams) {
						link = actionFormat.getLink(dir, frameIndex);
						if (bitmapdataDic[link] == null) {
							try {
								cls = loader.contentLoaderInfo.applicationDomain.getDefinition(link) as Class;
								bmd = new cls();
							} catch(e:Error) {
								if (bmd) {
									bmd.dispose();
								}
								bmd = null;
								isOk = false;
								actionFormat.setActReady(act, dir, false);
							}
							bitmapdataDic[link] = bmd;
						}
						frameIndex++;
					}
					if (isOk) {
						var warmAct:String = ActionConst.warmHash[act];
						if (actionGroup.isCreateWarn && warmAct != null) {
							var id2:String = actionGroup.takeAction(warmAct).id;
							_bitmapdataHash_.put(idName + "_" + warmAct, bitmapdataDic);
						}
						_bitmapdataHash_.put(idName + "_" + act, bitmapdataDic);
					}
				}
			}
		}
		
		public function clear():void
		{
			var arr:Array = null;
			var swf_id:String = null;
			var dataFormat:AvatarActionFormat = null;
			var hash:Dictionary = null;
			var bmd:BitmapData = null;
			var id_:String = null;
			var actData:Object = null;
			var dataFormat_id:String = null;
			
			var reg:RegExp = /.*[wco|wcx|dcx|dco|fcx|fco].*/;
			analyzeSWFQueueNow.length = 0;
			_wealthQueue_.limitIndex = loadIndex;
			_wealthQueue_._wealthGroup_.resetWealths();
			_wealthQueue_.stop = true;
			log("=-=-=-=-=-clear");
			
			var cacheMemory:Boolean = true;
			if (Engine.currMemory >= 700) {
				cacheMemory = false;
			}
			var assetsHash:Hash = new Hash();
			var assetsHash2:Hash = new Hash();
			var isOk:Boolean;
			for (var key:String in _bitmapdataHash_) {
				if (reg.test(key)) {
					if (cacheMemory) {
						isOk = false;
					}
				}
				if (isOk) {
					hash = _bitmapdataHash_[key];
					for (var tmp_id:String in hash) {
						arr = tmp_id.split(".");
						swf_id = arr[0] + "_" + arr[1] + ".tmp";
						assetsHash.put(swf_id, swf_id);
						swf_id = arr[0] + "." + arr[1];
						assetsHash2.put(swf_id, swf_id);
						WealthPool.clean(arr[0]);
						bmd = hash[tmp_id] as BitmapData;
						if (bmd) {
							bmd.dispose();
						}
					}
					delete _bitmapdataHash_[key];
				}
			}
			var loaderInstanceHash:Hash = WealthManager.loaderInstanceHash;
			trace("回收前：", loaderInstanceHash.length);
			for each (var loader:ILoader in loaderInstanceHash) {
				if ((loader as DisplayLoader)) {
					if (loader.path) {
						arr = loader.path.split("/");
						swf_id = arr[(arr.length - 1)];
						isOk = true;
						if (((reg.test(swf_id)) && (cacheMemory))) {
							isOk = false;
						}
						if (((((isOk) && ((loader as DisplayLoader)))) && (!((swf_id.indexOf(".tmp") == -1))))) {
							WealthElisor.removeSign(loader.path);
							id_ = loader.id;
							loader.dispose();
							loaderInstanceHash.remove(tmp_id);
						}
					}
				}
			}
			trace("回收后：", loaderInstanceHash.length);
			for (var link:String in _urlRequestsHash_) {
				arr = link.split("/");
				swf_id = arr[(arr.length - 1)];
				dataFormat_id = link.slice(0, link.indexOf("@", 2));
				dataFormat = AvatarActionFormat.takeAvatarActionFormat(dataFormat_id);
				isOk = true;
				if (((reg.test(dataFormat.idName)) && (cacheMemory))) {
					isOk = false;
				}
				if (isOk) {
					if (dataFormat) {
						actData = getActAndDir(link);
						dataFormat.resetActReady();
					}
					_urlRequestsHash_.remove(link);
				}
			}
			_urlRequestsHash_.reset();
			var hashx:Hash = AvatarActionFormat.getInstanceHash;
			for each (var dataFormat_:AvatarActionFormat in hashx) {
				isOk = true;
				if (((reg.test(dataFormat_.idName)) && (cacheMemory))) {
					isOk = false;
				}
				if (isOk) {
					dataFormat_.resetActReady();
				}
			}
			analyeHash = new Dictionary();
			WealthManager.clear(assetsHash);
			assetsHash.reset();
			assetsHash2.reset();
			_wealthQueue_.stop = false;
		}

	}
} 
