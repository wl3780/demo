package com.engine.core.view.items.avatar
{
	import com.engine.core.Engine;
	import com.engine.core.EngineGlobal;
	import com.engine.core.ItemConst;
	import com.engine.core.controls.events.WealthEvent;
	import com.engine.core.controls.wealth.WealthConstant;
	import com.engine.core.controls.wealth.WealthPool;
	import com.engine.core.controls.wealth.WealthQuene;
	import com.engine.core.controls.wealth.loader.BingLoader;
	import com.engine.core.controls.wealth.loader.DisplayLoader;
	import com.engine.core.model.wealth.WealthGroupVo;
	import com.engine.core.view.role.MainChar;
	import com.engine.core.view.scenes.Scene;
	import com.engine.namespaces.coder;
	
	import flash.display.BitmapData;
	import flash.display.LoaderInfo;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	public class AvatarAssetManager 
	{

		public static var shadow:BitmapData;
		
		private static var _instance:AvatarAssetManager;

		public var avatarParams:Dictionary;
		public var bitmapdatas:Dictionary;
		public var elements:Dictionary;
		public var assetHash:Array;
		
		private var _quene:WealthQuene;
		private var _loaderQuene:Array;
		private var _assetsQuene:Array;
		private var _bmdQuene:Array;
		private var _oldFrameRate:int;
		private var _delayTime:int = 0;

		public function AvatarAssetManager()
		{
			super();
			this.init();
		}

		public static function getInstance():AvatarAssetManager
		{
			if (_instance == null) {
				_instance = new AvatarAssetManager();
			}
			return _instance;
		}

		private function init():void
		{
			this.assetHash = [];
			this.elements = new Dictionary();
			this.avatarParams = new Dictionary();
			this.bitmapdatas = new Dictionary();
			
			_loaderQuene = [];
			_assetsQuene = [];
			_bmdQuene = [];
			_quene = new WealthQuene();
			if (false) {
				_quene.loaderContext = new LoaderContext(false);
			} else {
				_quene.loaderContext = new LoaderContext(false, ApplicationDomain.currentDomain, SecurityDomain.currentDomain);
			}
			_quene.delay = 10;
			_quene.addEventListener(WealthEvent.WEALTH_LOADED, this.wealthLoadedFunc);
			_quene.addEventListener(WealthEvent.WEALTH_ERROR, this.wealthErrorFunc);
			
			var timer:Timer = new Timer(0);
			timer.addEventListener(TimerEvent.TIMER, this.enterFrameFunc);
			timer.start();
		}

		private function enterFrameFunc(evt:TimerEvent):void
		{
			var interval:int;
			if (Engine.fps >= 12) {
				interval = 5;
			} else {
				interval = 20;
			}
			if (_loaderQuene.length && (Engine.delayTime - _delayTime) > interval) {
				_delayTime = Engine.delayTime;
				var loaderItem:Object = _loaderQuene.shift();
				this.analyze(loaderItem.avatarParam, loaderItem.loader);
			}
			this.draw();
			if (_assetsQuene.length > 0) {
				var passNum:int = _assetsQuene.length;
				if (Engine.fps < 10) {
					if (_assetsQuene.length > 20) {
						passNum = _assetsQuene.length / 10;
					} else {
						passNum = 1;
					}
				} else {
					if (passNum > 30) {
						passNum = 30;
					}
				}
				var idx:int = 0;
				while (idx < passNum) {
					if (_assetsQuene.length) {
						var assetItem:Object = _assetsQuene.shift();
						if (assetItem.type == 0) {
							var url:String = assetItem.url;
							var owner:String = assetItem.owner;
							var startTime:int = assetItem.startTime;
							var arr:Array = url.split("/");
							var avatarId:String = arr[arr.length-1];
							avatarId = avatarId.split(".")[0];
							var dict:Dictionary = this.elements[avatarId];
							AvatarManager.coder::getInstance().loadedAvatar(assetItem.key, avatarId, owner, startTime, dict);
						}
					} else {
						break;
					}
					idx++;
				}
			}
		}
		
		private function wealthLoadedFunc(evt:WealthEvent):void
		{
			var array:Array = evt.vo.path.split("/");
			var fileName:String = array[array.length-1];
			fileName = fileName.split(".")[0];
			var loader:Object = WealthPool.getIntance().take(evt.vo.path);
			if (loader as DisplayLoader) {
				var arr:Array = fileName.split("_");
				var action:String = arr.pop();
				fileName = arr.join("_");
				if (this.elements[fileName]) {
					var param:AvatarParam = this.elements[fileName][action];
					_loaderQuene.push({
						"avatarParam":param,
						"loader":DisplayLoader(loader).contentLoaderInfo
					});
				}
			} else if (loader as BingLoader) {
				var dict:Dictionary;
				if (this.elements[fileName] == null) {
					var bytes:ByteArray = BingLoader(loader).data as ByteArray;
					bytes.position = 0;
					try {
						bytes.uncompress();
					} catch(e:Error) {
					}
					var size:int = bytes.readInt();
					var str:String = bytes.readUTFBytes(size);
					var xml:XML = new XML(str);
					dict = this.analyzeData(fileName, xml);
					this.elements[fileName] = dict;
					this.loadAvatarAssets(fileName, CharAction.STAND, evt.vo.data.owner);
					this.loadAvatarAssets(fileName, CharAction.WALK, evt.vo.data.owner);
				} else {
					dict = this.elements[fileName];
				}
				AvatarManager.coder::getInstance().loadedAvatar(evt.vo.data.key, fileName, evt.vo.data.owner, evt.vo.data.startTime, dict);
			}
		}

		private function wealthErrorFunc(evt:WealthEvent):void
		{
			log("saiman", "[ERROR]:", evt.vo.path);
			AvatarManager.coder::getInstance().loadedAvatarError(evt.vo.data.owner as String);
		}

		public function loadAvatar(avatarType:String, avatarNum:String, oid:String, filePath:String=null):String
		{
			var avatarId:String = avatarType + Engine.LINE + avatarNum;
			var smPath:String = EngineGlobal.getAvatarAssetsConfigPath(avatarId);
			log("saiman", "加载动作资源：", smPath);
			var key:String = Engine.coder::nextInstanceIndex().toString(16);
			var groupVo:WealthGroupVo = new WealthGroupVo();
			groupVo.level = WealthConstant.BUBBLE_LEVEL;
			groupVo.addWealth(smPath, {
				"owner":oid,
				"startTime":Engine.delayTime,
				"key":key,
				"assetsPath":filePath
			});
			_quene.addGroup(groupVo);
			if (this.assetHash.indexOf(smPath) == -1) {
				this.assetHash.push(smPath);
			}
			return key;
		}
		
		public function loadAvatarAssets(avatarId:String, action:String, parts_id:String):void
		{
			if (!avatarId || !action) {
				return;
			}
			var url:String = EngineGlobal.getAvatarAssetsPath(avatarId + Engine.LINE + action);
			if (this.checkLoadedFunc(url) == false) {
				var groupVo:WealthGroupVo = new WealthGroupVo();
				groupVo.level = WealthConstant.BUBBLE_LEVEL;
				groupVo.addWealth(url, {"action":action});
				_quene.addGroup(groupVo);
				if (this.assetHash.indexOf(url) == -1) {
					this.assetHash.push(url);
				}
			} else {
				_assetsQuene.push({
					"type":1,
					"url":url,
					"owner":parts_id,
					"action":action
				});
			}
		}

		public function checkCleanAbled(parts:AvatartParts):Boolean
		{
			var idx:int;
			while (idx < this.assetHash.length) {
				var url:String = this.assetHash[idx];
				var loader:DisplayLoader = WealthPool.getIntance().take(url) as DisplayLoader;
				var arr:Array = url.split("/");
				var avatarId:String = arr[arr.length-1];
				avatarId = avatarId.split(".")[0];
				if (parts.hasAssets(avatarId)) {
					return false;
				}
				idx++;
			}
			for each (var param:AvatarParam in this.avatarParams) {
				if (parts.hasAssets(param.oid)) {
					return false;
				}
			}
			return true;
		}

		public function cleanItems(avatarList:Vector.<AvatartParts>):void
		{
			var _local_2:AvatartParts;
			var _local_3:Boolean;
			var _local_4:int;
			var _local_6:int;
			var _local_7:String;
			var _local_8:String;
			var _local_9:String;
			var _local_10:DisplayLoader;
			var _local_11:String;
			var _local_12:Array;
			var _local_13:AvatarParam;
			var _local_14:String;
			var _local_15:Array;
			var _local_16:int;
			var _local_17:BitmapData;
			var idx:int;
			while (idx < avatarList.length) {
				_local_2 = avatarList[idx];
				_local_6 = 0;
				while (_local_6 < this.assetHash.length) {
					_local_10 = (WealthPool.getIntance().take(this.assetHash[_local_6]) as DisplayLoader);
					_local_11 = this.assetHash[_local_6];
					_local_12 = _local_11.split("/");
					_local_11 = _local_12[(_local_12.length - 1)];
					_local_11 = _local_11.split(".")[0];
					_local_3 = _local_2.hasAssets(_local_11);
					if (_local_3) {
						if (_local_10) {
							_local_10.dispose();
						}
						_local_10 = null;
						WealthPool.getIntance().remove(this.assetHash[_local_6]);
						this.assetHash.splice(_local_6, 1);
						_local_6--;
					}
					_local_6++;
				}
				for (_local_7 in this.avatarParams) {
					_local_13 = this.avatarParams[_local_7];
					_local_3 = _local_2.hasAssets(_local_13.oid);
					if (_local_3) {
						_local_13.dispose();
						delete this.avatarParams[_local_7];
					}
				}
				for (_local_8 in this.bitmapdatas) {
					_local_14 = _local_8.split(Engine.SIGN)[0];
					_local_3 = _local_2.hasAssets(_local_14);
					if (_local_3) {
						_local_15 = this.bitmapdatas[_local_8];
						_local_16 = 0;
						while (_local_16 < _local_15.length) {
							_local_17 = _local_15[_local_16];
							if (((_local_17) && (!((_local_17 == Engine.shadow_bitmapData))))) {
								_local_17.dispose();
							}
							_local_16++;
						}
						delete this.bitmapdatas[_local_8];
					}
				}
				for (_local_9 in this.elements) {
					_local_3 = _local_2.hasAssets(_local_9);
					if (_local_3) {
						delete this.elements[_local_9];
					}
				}
				idx++;
			}
		}

		public function clean():void
		{
			var _local_1:MainChar;
			var _local_2:AvatartParts;
			var _local_3:Dictionary;
			var _local_4:Boolean;
			var _local_5:int;
			var _local_6:String;
			var _local_7:String;
			var _local_8:String;
			var _local_9:DisplayLoader;
			var _local_10:String;
			var _local_11:Array;
			var _local_12:AvatartParts;
			var _local_13:AvatarParam;
			var _local_14:String;
			var _local_15:Array;
			var _local_16:int;
			var _local_17:BitmapData;
			if (Scene.scene.mainChar) {
				_local_1 = Scene.scene.mainChar;
				_local_3 = AvatarManager.coder::getInstance().avatarHash;
				_local_2 = _local_1.avatarParts;
				_local_5 = 0;
				while (_local_5 < this.assetHash.length) {
					_local_9 = (WealthPool.getIntance().take(this.assetHash[_local_5]) as DisplayLoader);
					_local_10 = this.assetHash[_local_5];
					_local_11 = _local_10.split("/");
					_local_10 = _local_11[(_local_11.length - 1)];
					_local_10 = _local_10.split(".")[0];
					for each (_local_12 in _local_3) {
						_local_4 = _local_12.hasAssets(_local_10);
						if (_local_4) break;
					}
					if (!_local_4) {
						_local_4 = _local_2.hasAssets(_local_10);
					}
					if (!_local_4) {
						if (_local_9) {
							_local_9.dispose();
						}
						_local_9 = null;
						WealthPool.getIntance().remove(this.assetHash[_local_5]);
						this.assetHash.splice(_local_5, 1);
						_local_5--;
					}
					_local_5++;
				}
				for (_local_6 in this.avatarParams) {
					_local_13 = this.avatarParams[_local_6];
					for each (_local_12 in _local_3) {
						_local_4 = _local_12.hasAssets(_local_13.oid);
						if (_local_4) break;
					}
					if (!_local_4) {
						_local_4 = _local_2.hasAssets(_local_13.oid);
					}
					if (!_local_4) {
						_local_13.dispose();
						delete this.avatarParams[_local_6];
					}
				}
				for (_local_7 in this.bitmapdatas) {
					_local_14 = _local_7.split(Engine.SIGN)[0];
					for each (_local_12 in _local_3) {
						_local_4 = _local_12.hasAssets(_local_14);
						if (_local_4) break;
					}
					if (!_local_4) {
						_local_4 = _local_2.hasAssets(_local_14);
					}
					if (!_local_4) {
						_local_15 = this.bitmapdatas[_local_7];
						_local_16 = 0;
						while (_local_16 < _local_15.length) {
							_local_17 = _local_15[_local_16];
							if (((_local_17) && (!((_local_17 == Engine.shadow_bitmapData))))) {
								_local_17.dispose();
							}
							_local_16++;
						}
						delete this.bitmapdatas[_local_7];
					}
				}
				for (_local_8 in this.elements) {
					_local_4 = _local_2.hasAssets(_local_8);
					for each (_local_12 in _local_3) {
						_local_4 = _local_12.hasAssets(_local_8);
						if (_local_4) break;
					}
					if (!_local_4) {
						_local_4 = _local_2.hasAssets(_local_8);
					}
					if (!_local_4) {
						delete this.elements[_local_8];
					}
				}
				_assetsQuene = [];
			}
		}

		public function checkLoadedFunc(url:String):Boolean
		{
			return WealthPool.getIntance().has(url);
		}

		private function analyze(avatarParam:AvatarParam, contentLoaderInfo:LoaderInfo):void
		{
			if (!avatarParam || avatarParam.isDisposed || !contentLoaderInfo) {
				return;
			}
			var frames:int = avatarParam.frames;
			var id:String = avatarParam.oid;
			var l:int = avatarParam.heights.length;
			var type:String = avatarParam.avatarType;
			var num:int = 8;
			if (l >= 5) {
				num = 8;
			} else {
				num = 1;
			}
			
			var clazz:Class;
			var bmd:BitmapData;
			var link:String;
			var kName:String;
			var index:int;
			var indexLink:String;
			var bmd_:BitmapData;
			var mat:Matrix;
			var j:int = 0;
			var i:int = 0;
			while (i < num) {
				link = avatarParam.id + Engine.SIGN + avatarParam.bitmapdatas[i];
				if (i < 5) {
					j = 0;
					while (j < frames) {
						kName = avatarParam.bitmapdatas[i] + "." + j;
						clazz = contentLoaderInfo.applicationDomain.getDefinition(kName) as Class;
						bmd = new clazz() as BitmapData;
						this.bitmapdatas[link][j] = bmd;
						j++;
					}
				} else {
					index = 8 - i;
					indexLink = avatarParam.id + Engine.SIGN + id + "." + avatarParam.action + "." + index;
					j = 0;
					while (j < frames) {
						bmd_ = this.bitmapdatas[indexLink][j];
						mat = new Matrix();
						mat.scale(-1, 1);
						mat.tx = bmd_.width;
						bmd = new BitmapData(bmd_.width, bmd_.height, true, 0);
						this.bitmapdatas[link][j] = bmd;
						_bmdQuene.push({
							"bmd_":bmd_,
							"bmd":bmd,
							"mat":mat
						});
						j++;
					}
				}
				i++;
			}
		}

		private function draw():void
		{
			while (_bmdQuene.length) {
				var info:Object = _bmdQuene.shift();
				var target:BitmapData = info.bmd;
				var source:BitmapData = info.bmd_;
				var mtx:Matrix = info.mat;
				target.draw(source, mtx, null, null, source.rect);
			}
		}

		private function analyzeData(fileName:String, xml:XML):Dictionary
		{
			var bmdKey:String;
			var frameIdx:int;
			var dirIdx:int;
			var frameLen:int;
			var frameW:int;
			var frameH:int;
			var flipIdx:int;
			var flipFrameIdx:int;
			var flipFrameX:int;
			var _local_30:String;
			var _local_31:int;
			var avatarType:String = fileName.split("_")[0];
			var dict:Dictionary = new Dictionary();
			var xmlList:XMLList = xml.children();
			var len:int = xmlList.length();
			var idx:int;
			var avatarId:String = xml.@id;
			while (idx < len) {
				var xmlItem:XML = xmlList[idx];
				var param:AvatarParam = new AvatarParam();
				param.avatarType = avatarType;
				param.action = xmlItem.@id;
				param.frames = xmlItem.@frames;
				if (avatarType != ItemConst.EFFECT_TYPE) {
					param.speed = int(int(xmlItem.@speed) / Engine._Lessen_Frame_);
				} else {
					param.speed = xmlItem.@speed;
				}
				param.offset_x = xmlItem.@offset_x;
				param.offset_y = xmlItem.@offset_y;
				param.replay = xmlItem.@replay;
				if (param.replay == 0) {
					param.replay = -1;
				}
				param.coder::oid = fileName;
				param.coder::id = fileName + Engine.SIGN + param.action;
				
				var actList:XMLList = xmlItem.children();
				var actLen:int = actList.length();
				var actIdx:int = 0;
				var dirs:int = 8;
				if (avatarType == ItemConst.EFFECT_TYPE || avatarType == ItemConst.MOUNT_TYPE) {
					if (actLen >= 5) {
						dirs = 8;
					} else {
						dirs = 1;
					}
				}
				var once:Boolean = false;
				if (avatarType != ItemConst.EFFECT_TYPE && actLen == 1) {
					once = true;
				}
				actIdx = 0;
				while (actIdx < dirs) {
					var actXML:XML;
					var frameList:XMLList;
					if (actIdx < 5) {
						if (once) {
							actXML = actList[0];
							dirIdx = actIdx;
						} else {
							actXML = actList[actIdx];
							dirIdx = actIdx;
						}
						param.txs[dirIdx] = [];
						param.tys[dirIdx] = [];
						param.widths[dirIdx] = [];
						param.heights[dirIdx] = [];
						if (!once) {
							param.bitmapdatas[dirIdx] = avatarId + "." + param.action + "." + dirIdx;
							bmdKey = param.id + Engine.SIGN + avatarId + "." + param.action + "." + dirIdx;
						} else {
							param.bitmapdatas[dirIdx] = avatarId + "." + param.action + "." + 0;
							bmdKey = param.id + Engine.SIGN + avatarId + "." + param.action + "." + 0;
						}
						if (this.bitmapdatas.hasOwnProperty(bmdKey) == false) {
							frameList = actXML.children();
							if (frameList.length() == 0) {
								log("saiman", "资源配置文件格式不符合要求");
								return new Dictionary();
							}
							if (this.bitmapdatas[bmdKey] == null) {
								this.bitmapdatas[bmdKey] = [];
							}
							frameLen = frameList.length();
							if (frameLen > param.frames) {
								param.frames = frameLen;
							}
							frameIdx = 0;
							while (frameIdx < param.frames) {
								if (frameIdx < frameLen) {
									param.txs[dirIdx].push(int(frameList[frameIdx].@tx[0]));
									param.tys[dirIdx].push(int(frameList[frameIdx].@ty[0]));
									frameW = int(frameList[frameIdx].@width[0]);
									if (frameW == 0) {
										frameW = int(frameList[frameIdx].@w[0]);
									}
									frameH = int(frameList[frameIdx].@height[0]);
									if (frameH == 0) {
										frameH = int(frameList[frameIdx].@h[0]);
									}
									param.widths[dirIdx].push(frameW);
									param.heights[dirIdx].push(frameH);
								}
								frameIdx++;
							}
						}
					} else {	// 反转
						dirIdx = actIdx;
						flipIdx = 8 - dirIdx;
						param.txs[dirIdx] = [];
						flipFrameIdx = 0;
						while (flipFrameIdx < param.widths[flipIdx].length) {
							flipFrameX = param.widths[flipIdx][flipFrameIdx] - param.txs[flipIdx][flipFrameIdx];
							param.txs[dirIdx].push(flipFrameX);
							flipFrameIdx++;
						}
						param.tys[dirIdx] = param.tys[flipIdx];
						param.widths[dirIdx] = param.widths[flipIdx];
						param.heights[dirIdx] = param.heights[flipIdx];
						if (!once) {
							param.bitmapdatas[dirIdx] = avatarId + "." + param.action + "." + dirIdx;
							bmdKey = param.id + Engine.SIGN + avatarId + "." + param.action + "." + dirIdx;
						} else {
							param.bitmapdatas[dirIdx] = avatarId + "." + param.action + "." + 0;
							bmdKey = param.id + Engine.SIGN + avatarId + "." + param.action + "." + 0;
						}
						if (this.bitmapdatas.hasOwnProperty(bmdKey) == false) {
							_local_30 = param.id + Engine.SIGN + avatarId + "." + param.action + "." + flipIdx;
							if (this.bitmapdatas[bmdKey] == null) {
								this.bitmapdatas[bmdKey] = [];
							}
							_local_31 = 0;
							while (_local_31 < this.bitmapdatas[_local_30].length) {
								if (avatarType == ItemConst.BODY_TYPE) {
									this.bitmapdatas[bmdKey].push(Engine.shadow_bitmapData);
								} else {
									this.bitmapdatas[bmdKey].push(null);
								}
								_local_31++;
							}
						}
					}
					actIdx++;
				}
				if (this.avatarParams.hasOwnProperty(param.id) == false) {
					this.avatarParams[param.id] = param;
					dict[param.action] = param;
				}
				idx++;
			}
			return dict;
		}
		
	}
}
