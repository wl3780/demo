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

		public var loaderContext:LoaderContext;
		public var limitIndex:int = 2;
		
		private var _id:String;
		private var _oid:String;
		private var _proto:Object;
		
		private var _bubbleList:Vector.<WealthGroupVo>;
		private var _priorityList:Vector.<WealthGroupVo>;
		private var _groupHash:Dictionary;
		private var _loaderHash:Dictionary;
		
		private var _isDispose:Boolean;
		private var _timer:Timer;
		private var _deayTime:int;
		private var _manager:WealthManager = WealthManager.getIntance();

		public function WealthQuene()
		{
			super(null);
			this.setUp();
		}

		public function setUp():void
		{
			_isDispose = false;
			_id = Core.SIGN + Core.coder::nextInstanceIndex().toString(16);
			WealthManager.getIntance().addQuene(this);
			_priorityList = new Vector.<WealthGroupVo>();
			_bubbleList = new Vector.<WealthGroupVo>();
			_groupHash = new Dictionary();
			_loaderHash = new Dictionary();
			
			_timer = new Timer(0);
			_timer.addEventListener(TimerEvent.TIMER, this.enterFrameFunc);
			_timer.start();
		}

		public function set delay(val:uint):void
		{
			_timer.delay = val;
		}

		private function enterFrameFunc(evt:TimerEvent):void
		{
			var interval:int;
			if (Core.fps < 3) {
				interval = 100;
			}
			if ((getTimer() - _deayTime) > interval) {
				_deayTime = getTimer();
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
				} else {
					idx = _priorityList.indexOf(groupVo);
					_priorityList.splice(idx, 1);
				}
				_manager.coder::removeGroupRequest(groupVo);
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
				this.priorityLoad();
			}
		}

		public function priorityLoad():void
		{
			if (_isDispose || _priorityList.length <= 0) {
				return;
			}
			
			var idx:int = 0;
			while (idx < this.limitIndex) {
				var wealthVo:WealthVo = this.getNextWealth(_priorityList);
				if (wealthVo) {
					if (this.hasCatch(wealthVo.path)) {	// 已加载过
						wealthVo.coder::loaded = true;
						this.dispatchWealthEvent(WealthEvent.WEALTH_LOADED, wealthVo);
						this.limitIndex++;
						
						var groupVo:WealthGroupVo = _groupHash[wealthVo.oid];
						groupVo.checkFinish();
						if (groupVo.loaded && groupVo.lock == false) {
							this.removeGroup(wealthVo.oid);
							this.dispatchWealthEvent(WealthEvent.WEALTH_GROUP_LOADED, wealthVo);
						}
					} else {
						this.loadElemt(wealthVo, this.priorityLoadedFunc, this.priorityErrorFunc, this.priorityProFunc);
					}
					this.limitIndex--;
					idx--;
				} else {
					break;
				}
				idx++;
			}
		}

		private function priorityLoadedFunc(wealthVo:WealthVo):void
		{
			log("saiman", "priority加载成功：", wealthVo);
			this.limitIndex++;
			this.removeLoader(wealthVo.path);
			_manager.coder::callSuccess(wealthVo.path);
		}

		private function priorityErrorFunc(wealthVo:WealthVo):void
		{
			log("saiman", "priority加载失败：", wealthVo);
			this.limitIndex++;
			this.removeLoader(wealthVo.path);
			_manager.coder::callError(wealthVo.path);
		}

		private function priorityProFunc(evt:ProgressEvent, wealthVo:WealthVo):void
		{
			_manager.coder::proFunc(wealthVo.path, evt);
		}

		public function bubbleLoad():void
		{
			if (_isDispose || _bubbleList.length <= 0) {
				return;
			}
			
			var wealthVo:WealthVo = this.getNextWealth(_bubbleList);
			if (wealthVo) {
				if (this.hasCatch(wealthVo.path)) {	// 已加载过
					wealthVo.coder::loaded = true;
					this.dispatchWealthEvent(WealthEvent.WEALTH_LOADED, wealthVo);
					
					var groupVo:WealthGroupVo = _groupHash[wealthVo.oid];
					groupVo.checkFinish();
					if (groupVo.loaded && groupVo.lock == false) {
						this.removeGroup(wealthVo.oid);
						this.dispatchWealthEvent(WealthEvent.WEALTH_GROUP_LOADED, wealthVo);
					}
				} else {
					this.loadElemt(wealthVo, this.bubbleLoadedFunc, this.bubbleErrorFunc, this.bubbleProFunc);
				}
			}
		}

		private function bubbleLoadedFunc(wealthVo:WealthVo):void
		{
			log("saiman", "bubble加载成功：", wealthVo);
			this.removeLoader(wealthVo.path);
			_manager.coder::callSuccess(wealthVo.path);
		}

		private function bubbleErrorFunc(wealthVo:WealthVo):void
		{
			log("saiman", "bubble加载失败：", wealthVo);
			this.removeLoader(wealthVo.path);
			_manager.coder::callError(wealthVo.path);
		}

		private function bubbleProFunc(evt:ProgressEvent, wealthVo:WealthVo):void
		{
			_manager.coder::proFunc(wealthVo.path, evt);
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
				if (type == WealthConstant.SWF_WEALTH || type == WealthConstant.IMG_WEALTH) {
					var disLoader:DisplayLoader = new DisplayLoader();
					disLoader.loadElemt(wealthVo, successFunc, errorFunc, progressFunc, this.loaderContext);
					_loaderHash[wealthVo.path] = disLoader;
				} else if (type == WealthConstant.BING_WEALTH) {
					var binLoader:BingLoader = new BingLoader();
					binLoader.loadElemt(wealthVo, successFunc, errorFunc, progressFunc, this.loaderContext);
					_loaderHash[wealthVo.path] = binLoader;
				}
			}
			WealthManager.getIntance().addRequest(wealthVo.path, wealthVo.id, this.id);
		}

		public function cancleGroup(gid:String):void
		{
			try {
				if (_isDispose) {
					return;
				}
				var group:WealthGroupVo = _groupHash[gid];
				if (!group) {
					return;
				}
				
				var loader:ILoader;
				var values:Vector.<WealthVo> = group.coder::values();
				for each (var vo:WealthVo in values) {
					if (WealthManager.getIntance().takeRequestLength(vo.path) == 1) {
						loader = this.removeLoader(vo.path);
						if (loader) {
							if (WealthPool.getIntance().has(vo.path) == false) {
								loader.unloadAndStop();
								loader.dispose();
							}
							this.limitIndex = 3;
						}
					}
				}
				if (group.lock == false) {
					this.removeGroup(group.id);
					group.dispose();
				}
				group.coder::lock = true;
				group.coder::loaded = true;
			} catch(e:Error) {
				throw (e);
			}
		}

		public function dispatchWealthEvent(type:String, wealthVo:WealthVo):void
		{
			var event:WealthEvent = new WealthEvent(type);
			event.vo = new WealthVo();
			event.vo.setUp(wealthVo.path, wealthVo.data, wealthVo.oid);
			event.vo.coder::loaded = wealthVo.loaded;
			event.vo.coder::index = wealthVo.index;
			event.vo.coder::lock = wealthVo.lock;
			event.vo.proto = wealthVo.proto;
			event.vo.dataFormat = wealthVo.dataFormat;
			
			var groupVo:WealthGroupVo = this.takeGroup(wealthVo.oid);
			if (groupVo) {
				event.loadedIndex = groupVo.loadedIndex;
				event.total_loadeIndex = groupVo.length;
				event.group_name = groupVo.name;
			}
			this.dispatchEvent(event);
		}

		public function dispatchWealthProgressEvent(type:String, evt:ProgressEvent, wealthVo:WealthVo):void
		{
			var event:WealthProgressEvent = new WealthProgressEvent(type, false, false, evt.bytesLoaded, evt.bytesTotal);
			event.path = wealthVo.path;
			event.wealth_gid = wealthVo.oid;
			event.wealth_id = wealthVo.id;
			var groupVo:WealthGroupVo = this.takeGroup(wealthVo.oid);
			event.vo = wealthVo;
			event.loadedIndex = groupVo.loadedIndex;
			event.totlaIndex = groupVo.length;
			event.group_name = groupVo.name;
			this.dispatchEvent(event);
		}
		

		private function getNextWealth(list:Vector.<WealthGroupVo>):WealthVo
		{
			for each (var item:WealthGroupVo in list) {
				if (item && item.loaded == false) {
					var vo:WealthVo = item.getNextWealth();
					if (vo) {
						return vo;
					}
				}
			}
			return null;
		}
		
		private function removeLoader(path:String):ILoader
		{
			if (_isDispose) {
				return null;
			}
			var loader:ILoader = _loaderHash[path];
			delete _loaderHash[path];
			return loader;
		}

		public function get id():String
		{
			return _id;
		}

		public function set proto(val:Object):void
		{
			_proto = val;
		}
		public function get proto():Object
		{
			return _proto;
		}

		public function get oid():String
		{
			return _oid;
		}

		public function clone():IProto
		{
			if (_isDispose) {
				return null;
			}
			var p:Proto = new Proto();
			p.coder::id = this.id;
			p.coder::oid = this.oid;
			p.proto = this.proto;
			return p;
		}

		public function dispose():void
		{
			for each (var groupVo:WealthGroupVo in _groupHash) {
				this.cancleGroup(groupVo.id);
			}
			WealthManager.getIntance().removeQuene(this.id);
			_id = null;
			_oid = null;
			_proto = null;
			_groupHash = null;
			_loaderHash = null;
			_priorityList = null;
			_bubbleList = null;
			if (_timer) {
				_timer.removeEventListener(TimerEvent.TIMER, this.enterFrameFunc);
				_timer.stop();
				_timer = null;
			}
			_isDispose = true;
		}

	}
}
