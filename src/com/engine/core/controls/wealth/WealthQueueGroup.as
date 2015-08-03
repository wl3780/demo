package com.engine.core.controls.wealth
{
	import com.engine.core.Engine;
	import com.engine.core.controls.elisor.Elisor;
	import com.engine.core.controls.events.WealthEvent;
	import com.engine.core.controls.events.WealthProgressEvent;
	import com.engine.core.model.wealth.WealthGroupVo;
	import com.engine.core.model.wealth.WealthVo;
	import com.engine.interfaces.IProto;
	import com.engine.interfaces.system.IWealthQueue;
	import com.engine.namespaces.coder;
	import com.engine.utils.Hash;
	
	import flash.events.EventDispatcher;
	import flash.system.LoaderContext;
	import flash.utils.getTimer;

	public class WealthQueueGroup extends EventDispatcher implements IProto, IWealthQueue
	{
		private static var _Manager_:WealthManager = WealthManager.getInstance();

		public var loaderContext:LoaderContext;
		
		private var _id:String;
		private var _oid:String;
		private var _proto:Object;
		private var _className:String;
		private var _isDispose:Boolean = false;
		
		private var _wealthGroupQueue:Vector.<WealthGroupVo>;
		private var _wealthGroupHash:Hash;
		
		private var _delay:uint;
		private var _deayTime:int;
		private var _limitIndex:int = 2;
		private var _limitIndexMax:int = 2;
		private var _stop:Boolean;

		public function WealthQueueGroup()
		{
			super();
			_id = Engine.WEALTH_GROUP_SIGN + Engine.getSoleId();
			WealthManager.instanceHash.put(this.id, this);
			
			_wealthGroupQueue = new Vector.<WealthGroupVo>();
			_wealthGroupHash = new Hash();
			
			Elisor.getInstance().addFrameOrder(this, loop);
		}
		
		public function set limitIndex(val:int):void
		{
			_limitIndex = val;
			_limitIndexMax = val;
		}
		
		public function setStateLimitIndex():void
		{
			_limitIndex --;
			if (_limitIndex < 0) {
				_limitIndex = 0;
			}
		}

		public function set delay(val:uint):void
		{
			_delay = val;
		}
		
		public function get stop():Boolean
		{
			return _stop;
		}
		public function set stop(val:Boolean):void
		{
			_stop = val;
		}

		private function loop():void
		{
			if (this.stop) {
				return;
			}
			var interval:int = Engine.fps < 3 ? 100 : _delay;
			if ((getTimer()-_deayTime) > interval) {
				_deayTime = getTimer();
				this.loadWealth();
			}
		}
		
		public function addWealthGroup(group:WealthGroupVo):void
		{
			if (_wealthGroupHash.has(group.id) == false) {
				_wealthGroupQueue.push(group);
				_wealthGroupHash.put(group.id, group);
				group.coder::oid = this.id;
			}
		}
		
		public function takeWealthGroup(group_id:String):WealthGroupVo
		{
			return _wealthGroupHash.take(group_id) as WealthGroupVo;
		}
		
		public function removeWealthGroup(group_id:String):void
		{
			var group:WealthGroupVo = _wealthGroupHash.take(group_id) as WealthGroupVo;
			if (group) {
				for each (var wealthVo:WealthVo in group.wealths) {
					_Manager_.cancelWealth(wealthVo.id);
				}
				var index:int = _wealthGroupQueue.indexOf(group);
				if (index != -1) {
					_wealthGroupQueue.splice(index, 1);
				}
			}
		}
		
		public function removeWealthById(wealth_id:String):void
		{
			var wealthVo:WealthVo = WealthVo.getWealthVo(wealth_id);
			if (wealthVo && wealthVo.oid) {
				var group:WealthGroupVo = _wealthGroupHash.take(wealthVo.oid) as WealthGroupVo;
				if (group) {
					group.removeWealth(wealth_id);
				}
			}
		}
		
		public function loadWealth():void
		{
			if (_wealthGroupQueue.length) {
				var groupVo:WealthGroupVo = null;
				var wealthVo:WealthVo = null;
				var index:int = 0;
				while (index < _limitIndex && _wealthGroupQueue.length) {
					groupVo = this.getNeedWealthGroup();
					if (groupVo == null) {
						var count:int = _wealthGroupQueue.length - 1;
						while (count >= 0) {
							removeWealthGroup(_wealthGroupQueue[count].id);
							count--;
						}
						_limitIndex = _limitIndexMax;
					} else {
						wealthVo = groupVo.getNextWealth();
						if (wealthVo) {
							_Manager_.loadWealth(wealthVo, this.loaderContext);
						}
					}
					index++;
				}
			}
		}
		
		private function getNeedWealthGroup():WealthGroupVo
		{
			for each (var group:WealthGroupVo in _wealthGroupQueue) {
				if (group.isLoaded == false) {
					return group;
				}
			}
			return null;
		}

		internal final function _callSuccess_(wealth_id:String):void
		{
			var wealthVo:WealthVo = WealthVo.getWealthVo(wealth_id);
			if (wealthVo) {
				_limitIndex++;
				wealthVo.coder::isLoaded = true;
				wealthVo.coder::isPended = false;
				var group:WealthGroupVo = this.updateWealthGroup(wealth_id);
				this.dispatchWealthEvent(WealthEvent.WEALTH_COMPLETE, wealthVo.url, wealth_id, group.id);
				if (group.isLoaded) {
					this.dispatchWealthEvent(WealthEvent.WEALTH_GROUP_COMPLETE, wealthVo.url, wealth_id, group.id);
					this.removeWealthGroup(group.id);
				}
			}
		}
		
		internal final function _callError_(wealth_id:String):void
		{
			var wealthVo:WealthVo = WealthVo.getWealthVo(wealth_id);
			if (wealthVo) {
				_limitIndex++;
				wealthVo.coder::isLoaded = true;
				wealthVo.coder::isPended = false;
				var group:WealthGroupVo = this.updateWealthGroup(wealth_id);
				this.dispatchWealthEvent(WealthEvent.WEALTH_ERROR, wealthVo.url, wealth_id, group.id);
				if (group.isLoaded) {
					this.dispatchWealthEvent(WealthEvent.WEALTH_GROUP_COMPLETE, wealthVo.url, wealth_id, group.id);
					this.removeWealthGroup(group.id);
				}
			}
		}
		
		internal final function _callProgress_(wealth_id:String, bytesLoaded:Number, bytesTotal:Number):void
		{
			var wealthVo:WealthVo = WealthVo.getWealthVo(wealth_id);
			if (wealthVo) {
				this.dispatchWealthProgressEvent(wealthVo.url, wealth_id, wealthVo.oid, bytesLoaded, bytesTotal);
			}
		}
		
		private function dispatchWealthEvent(eventType:String, path:String, wealth_id:String, wealthGroup_id:String):void
		{
			var event:WealthEvent = new WealthEvent(eventType);
			event.path = path;
			event.wealth_id = wealth_id;
			event.wealthGroup_id = wealthGroup_id;
			this.dispatchEvent(event);
		}
		
		private function dispatchWealthProgressEvent(path:String, wealth_id:String, wealthGroup_id:String, bytesLoaded:Number, bytesTotal:Number):void
		{
			var event:WealthProgressEvent = new WealthProgressEvent(WealthProgressEvent.PROGRESS);
			event.path = path;
			event.wealth_id = wealth_id;
			event.wealthGroup_id = wealthGroup_id;
			event.bytesLoaded = bytesLoaded;
			event.bytesTotal = bytesTotal;
			this.dispatchEvent(event);
		}
		
		private function updateWealthGroup(wealth_id:String):WealthGroupVo
		{
			var wealthVo:WealthVo = WealthVo.getWealthVo(wealth_id);
			if (wealthVo) {
				var group:WealthGroupVo = this.takeWealthGroup(wealthVo.oid);
				group.checkTotalFinish();
				return group;
			}
			return null;
		}

		public function get id():String
		{
			return _id;
		}

		public function get oid():String
		{
			return _oid;
		}

		public function set proto(val:Object):void
		{
			_proto = val;
		}
		public function get proto():Object
		{
			return _proto;
		}
		
		public function get className():String
		{
			return _className;
		}

		public function clone():Object
		{
			throw new Error("不支持复制");
		}
		
		override public function toString():String
		{
			return "[" + this.className + Engine.SIGN + this.id + "]";
		}

		public function dispose():void
		{
			Elisor.getInstance().removeTotalOrder(this);
			WealthManager.instanceHash.remove(this.id);
			_id = null;
			_oid = null;
			_proto = null;
			_isDispose = true;
			for each (var groupVo:WealthGroupVo in _wealthGroupQueue) {
				groupVo.dispose();
			}
			_wealthGroupQueue = null;
			_wealthGroupHash = null;
		}

	}
}
