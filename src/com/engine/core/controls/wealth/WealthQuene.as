package com.engine.core.controls.wealth
{
	import com.engine.core.Core;
	import com.engine.core.controls.events.WealthEvent;
	import com.engine.core.controls.events.WealthProgressEvent;
	import com.engine.core.controls.wealth.loader.BingLoader;
	import com.engine.core.controls.wealth.loader.DisplayLoader;
	import com.engine.core.controls.wealth.loader.ILoader;
	import com.engine.core.model.IProto;
	import com.engine.core.model.Proto;
	import com.engine.core.model.wealth.WealthGroupVo;
	import com.engine.core.model.wealth.WealthVo;
	import com.engine.namespaces.coder;
	
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class WealthQuene extends EventDispatcher implements IProto 
	{

		public static var speed:int;
		
		private static var time:int = 0;
		private static var bytesSpeed:int = 0;

		public var loaderContext:LoaderContext;
		public var limitIndex:int = 2;
		
		private var _id:String;
		private var _oid:String;
		private var _proto:Object;
		
		private var _groupHash:Dictionary;
		private var _bubbleList:Vector.<WealthGroupVo>;
		private var _priorityList:Vector.<WealthGroupVo>;
		private var _loaders:Dictionary;
		
		private var _isDispose:Boolean;
		private var timer:Timer;
		private var deayTime:int;
		private var priorityLevel:int;
		private var manager:WealthManager = WealthManager.getIntance();

		public function WealthQuene()
		{
			super(null);
			this.setUp();
		}
		
		public static function getSpeedStr():String
		{
			if (speed > 0) {
				var str:String = speed + " KB/s";
				if (speed > 0x0400) {
					str = int(speed / 0x0400) + " M/s";
				}
				return str;
			}
			return "0 Kb/s";
		}

		public function setUp():void
		{
			_isDispose = false;
			_id = Core.SIGN + Core.coder::nextInstanceIndex().toString(16);
			WealthManager.getIntance().addQuene(this);
			_priorityList = new Vector.<WealthGroupVo>();
			_bubbleList = new Vector.<WealthGroupVo>();
			_loaders = new Dictionary();
			_groupHash = new Dictionary();
			
			this.timer = new Timer(0);
			this.timer.addEventListener(TimerEvent.TIMER, this.enterFrameFunc);
			this.timer.start();
		}

		public function set delay(val:uint):void
		{
			this.timer.delay = val;
		}

		private function enterFrameFunc(evt:TimerEvent):void
		{
			var interval:int;
			if (Core.fps < 3) {
				interval = 100;
			}
			if ((getTimer() - this.deayTime) > interval) {
				this.deayTime = getTimer();
				this.load();
			}
		}

		public function addGroup(groupVo:WealthGroupVo):void
		{
			if (groupVo == null || groupVo.id == null) {
				return;
			}
			groupVo.coder::oid = this.id;
			if (_groupHash[groupVo.id] == null) {
				_groupHash[groupVo.id] = groupVo;
			}
			if (groupVo.level == WealthConstant.PRIORITY_LEVEL) {
				_priorityList.push(groupVo);
				this.priorityLevel = 0;
				this.priorityLoad();
			} else {
				_bubbleList.push(groupVo);
				this.bubbleLoad();
			}
		}

		public function takeGroup(groupId:String):WealthGroupVo
		{
			return _groupHash[groupId] as WealthGroupVo;
		}

		public function removeGroup(groupId:String):void
		{
			if (_isDispose) {
				return;
			}
			if (_groupHash[groupId]) {
				var groupVo:WealthGroupVo = _groupHash[groupId];
				delete _groupHash[groupId];
				
				var idx:int;
				if (groupVo.level == WealthConstant.BUBBLE_LEVEL) {
					idx = _bubbleList.indexOf(groupVo);
					_bubbleList.splice(idx, 1);
					manager.coder::removeGroupRequest(groupVo);
				} else {
					idx = _priorityList.indexOf(groupVo);
					_priorityList.splice(idx, 1);
					manager.coder::removeGroupRequest(groupVo);
				}
			}
		}

		private function load():void
		{
			if (_isDispose) {
				return;
			}
			if (_bubbleList.length > 0) {
				this.bubbleLoad();
			}
			if (_priorityList.length > 0) {
				this.priorityLevel = 0;
				this.priorityLoad();
			}
		}

		public function priorityLoad():void
		{
			if (_isDispose) {
				return;
			}
			if (_priorityList.length > 0) {
				var idx:int = 0;
				while (idx < this.limitIndex) {
					var wealthVo:WealthVo = this.getNextWealth(_priorityList);
					if (wealthVo) {
						if (this.hasCatch(wealthVo.path)) {
							wealthVo.coder::loaded = true;
							this.dispatchWealthEvent(WealthEvent.WEALTH_LOADED, wealthVo);
							this.limitIndex++;
							
							var groupVo:WealthGroupVo = _groupHash[wealthVo.oid];
							groupVo.checkFinish();
							if (groupVo.loaded && groupVo.lock == false) {
								this.removeGroup(wealthVo.oid);
								this.dispatchWealthEvent(WealthEvent.WEALTH_GROUP_LOADED, wealthVo);
								if (this.priorityLevel < 100) {
									this.priorityLoad();
									this.priorityLevel++;
								}
							}
						} else {
							this.loadElemt(wealthVo, this.priorityLoadedFunc, this.priorityErrorFunc, this.priorityProFunc);
						}
						if (this.limitIndex > 0) {
							this.limitIndex--;
						}
						idx--;
					}
					idx++;
				}
			}
		}

		private function priorityLoadedFunc(wealthVo:WealthVo):void
		{
			this.removeLoader(wealthVo.path);
			manager.coder::callSuccess(wealthVo.path, false);
		}

		private function priorityErrorFunc(wealthVo:WealthVo):void
		{
			log("saiman", "加载失败：", wealthVo);
			this.removeLoader(wealthVo.path);
			manager.coder::callError(wealthVo.path, false);
		}

		private function priorityProFunc(evt:ProgressEvent, wealthVo:WealthVo):void
		{
			manager.coder::proFunc(wealthVo.path, evt);
		}

		public function bubbleLoad():void
		{
			if (_isDispose) {
				return;
			}
			var wealthVo:WealthVo = this.getNextWealth(_bubbleList);
			if (wealthVo) {
				if (this.hasCatch(wealthVo.path)) {
					wealthVo.coder::loaded = true;
					this.dispatchWealthEvent(WealthEvent.WEALTH_LOADED, wealthVo);
					
					var groupVo:WealthGroupVo = _groupHash[wealthVo.oid];
					groupVo.checkFinish();
					if (groupVo.loaded && groupVo.lock == false) {
						this.removeGroup(wealthVo.oid);
						this.dispatchWealthEvent(WealthEvent.WEALTH_GROUP_LOADED, wealthVo);
						this.bubbleLoad();
					}
				} else {
					this.loadElemt(wealthVo, this.bubbleLoadedFunc, this.bubbleErrorFunc, this.bubbleProFunc);
				}
			}
		}

		private function bubbleLoadedFunc(wealthVo:WealthVo):void
		{
			this.removeLoader(wealthVo.path);
			manager.coder::callSuccess(wealthVo.path, true);
		}

		private function bubbleErrorFunc(wealthVo:WealthVo):void
		{
			if (((!(wealthVo)) || (!(wealthVo.path)))) {
				this.bubbleLoad();
				return;
			}
			if (wealthVo.path) {
				this.removeLoader(wealthVo.path);
				manager.coder::callError(wealthVo.path, true);
			}
			var _local_2:WealthGroupVo = _groupHash[wealthVo.oid];
			if (_local_2) {
				_local_2.checkFinish();
				if (((_local_2.loaded) && ((_local_2.lock == false)))) {
					this.removeGroup(wealthVo.oid);
					this.dispatchWealthEvent(WealthEvent.WEALTH_GROUP_LOADED, wealthVo);
					this.bubbleLoad();
				}
			}
		}

		private function bubbleProFunc(evt:ProgressEvent, wealthVo:WealthVo):void
		{
			this.dispatchWealthProgressEvent(WealthProgressEvent.Progress, evt, wealthVo);
		}

		private function hasCatch(path:String):Boolean
		{
			if (WealthPool.getIntance().has(path)) {
				return true;
			}
			return false;
		}

		private function loadElemt(wealthVo:WealthVo, successFunc:Function, errorFunc:Function, progressFunc:Function):void
		{
			if (_isDispose) {
				return;
			}
			if (!wealthVo || !wealthVo.path) {
				return;
			}
			wealthVo.coder::lock = true;
			var type:String = wealthVo.type;
			if (type == null) {
				throw new Error("资源地址不能为空");
			}
			
			if (WealthManager.getIntance().hasRequest(wealthVo.path) == false) {
				bytesSpeed = 0;
				time = 0;
				if (type == WealthConstant.SWF_WEALTH || type == WealthConstant.IMG_WEALTH) {
					var disLoader:DisplayLoader = new DisplayLoader();
					disLoader.loadElemt(wealthVo, successFunc, errorFunc, progressFunc, this.loaderContext);
					_loaders[wealthVo.path] = disLoader;
				} else if (type == WealthConstant.BING_WEALTH) {
					var binLoader:BingLoader = new BingLoader();
					binLoader.loadElemt(wealthVo, successFunc, errorFunc, progressFunc, this.loaderContext);
					_loaders[wealthVo.path] = binLoader;
				}
			}
			WealthManager.getIntance().addRequest(wealthVo.path, wealthVo.id, this.id);
		}

		public function cancleGroup(gid:String):void
		{
			var group:WealthGroupVo;
			var values:Vector.<WealthVo>;
			var i:int;
			var vo:WealthVo;
			var loader:ILoader;
			try {
				if (_isDispose) {
					return;
				}
				group = _groupHash[gid];
				if (group) {
					values = group.coder::values();
					i = 0;
					while (i < values.length) {
						vo = values[i];
						if (WealthManager.getIntance().takeRequestLength(vo.path) == 1) {
							loader = this.removeLoader(vo.path);
							if (loader) {
								if (WealthPool.getIntance().has(vo.path) == false) {
									loader.unloadAndStop();
								}
								this.limitIndex = 3;
							}
						}
						i = (i + 1);
					}
					if (group.lock == false) {
						this.removeGroup(group.id);
						group.dispose();
					}
					group.coder::lock = true;
					group.coder::loaded = true;
				}
			} catch(e:Error) {
				throw (e);
			}
		}

		private function getNextWealth(list:Vector.<WealthGroupVo>):WealthVo
		{
			for each (var item:WealthGroupVo in list) {
				if (item && item.loaded == false) {
					var vo:WealthVo = item.getNextWealth();
					if (vo && vo.path) {
						return vo;
					}
				}
			}
			return null;
		}

		public function dispatchWealthEvent(_arg_1:String, _arg_2:WealthVo):void
		{
			var _local_3:WealthEvent = new WealthEvent(_arg_1);
			_local_3.vo = new WealthVo();
			_local_3.vo.setUp(_arg_2.path, _arg_2.data, _arg_2.oid);
			_local_3.vo.coder::id = _arg_2.id;
			_local_3.vo.coder::loaded = _arg_2.loaded;
			_local_3.vo.coder::$index = _arg_2.index;
			_local_3.vo.proto = _arg_2.proto;
			_local_3.vo.coder::lock = _arg_2.lock;
			var _local_4:WealthGroupVo = this.takeGroup(_arg_2.oid);
			if (_local_4) {
				_local_3.loadedIndex = _local_4.loadedIndex;
				_local_3.total_loadeIndex = _local_4.length;
				_local_3.group_name = _local_4.name;
			}
			this.dispatchEvent(_local_3);
		}

		public function dispatchWealthProgressEvent(_arg_1:String, _arg_2:ProgressEvent, _arg_3:WealthVo):void
		{
			if (time == 0) {
				time = getTimer();
			}
			var _local_4:Number = (getTimer() - time);
			if ((_local_4 == 0)) {
				_local_4 = 1;
			}
			bytesSpeed = (_arg_2.bytesLoaded - bytesSpeed);
			speed = ((bytesSpeed / 0x0400) / (_local_4 / 1000));
			time = getTimer();
			bytesSpeed = _arg_2.bytesLoaded;
			var _local_5:WealthProgressEvent = new WealthProgressEvent(_arg_1, false, false, _arg_2.bytesLoaded, _arg_2.bytesTotal);
			_local_5.path = _arg_3.path;
			_local_5.wealth_gid = _arg_3.oid;
			_local_5.wealth_id = _arg_3.id;
			_local_5.loadedIndex = _arg_3.loadIndex;
			_local_5.totlaIndex = _arg_3.index;
			var _local_6:WealthGroupVo = this.takeGroup(_arg_3.oid);
			_local_5.vo = _arg_3;
			_local_5.loadedIndex = _local_6.loadedIndex;
			_local_5.totlaIndex = _local_6.length;
			_local_5.group_name = _local_6.name;
			this.dispatchEvent(_local_5);
		}
		
		
		public function removeLoader(path:String):ILoader
		{
			if (_isDispose) {
				return null;
			}
			var loader:ILoader = _loaders[path];
			delete _loaders[path];
			return loader;
		}
		
		public function takeLoader(path:String):ILoader
		{
			return _loaders[path];
		}

		public function get id():String
		{
			return (_id);
		}

		public function set proto(_arg_1:Object):void
		{
			_proto = _arg_1;
		}

		public function get proto():Object
		{
			return (_proto);
		}

		public function get oid():String
		{
			return (_oid);
		}

		public function clone():IProto
		{
			if (_isDispose) {
				return (null);
			}
			var _local_1:Proto = new Proto();
			_local_1.coder::id = this.id;
			_local_1.coder::oid = this.oid;
			_local_1.proto = this.proto;
			return (_local_1);
		}

		public function dispose():void
		{
			for each (var _local_1:WealthGroupVo in _groupHash) {
				this.cancleGroup(_local_1.id);
			}
			WealthManager.getIntance().removeQuene(this.id);
			_id = null;
			_oid = null;
			_proto = null;
			_groupHash = null;
			_loaders = null;
			_priorityList = null;
			_bubbleList = null;
			if (this.timer) {
				this.timer.removeEventListener(TimerEvent.TIMER, this.enterFrameFunc);
				this.timer.stop();
			}
			_isDispose = true;
		}

	}
}
