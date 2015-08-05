package com.engine.core.controls.wealth
{
	import com.engine.core.Engine;
	import com.engine.core.controls.events.WealthEvent;
	import com.engine.core.controls.events.WealthProgressEvent;
	import com.engine.core.model.wealth.WealthGroupVo;
	import com.engine.core.model.wealth.WealthVo;
	import com.engine.interfaces.IProto;
	import com.engine.interfaces.system.IWealthQueue;
	import com.engine.namespaces.coder;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.system.LoaderContext;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class WealthQueueAlone extends EventDispatcher implements IProto, IWealthQueue
	{
		public static var avatarRequestElisorTime:int;
		
		private static var _Manager_:WealthManager = WealthManager.getInstance();
		
		public var loaderContext:LoaderContext;
		public var _wealthGroup_:WealthGroupVo;
		public var isSortOn:Boolean;
		public var name:String;
		
		protected var _id_:String;
		protected var _oid_:String;
		protected var _proto_:Object;
		protected var _className_:String;
		protected var _isDispose_:Boolean;
		
		private var _delay:int = 15;
		private var _delayTime:int;
		private var _limitIndex:int = 2;
		private var _limitIndexMax:int = 2;
		private var _stop:Boolean = false;
		
		private var timer:Timer;

		public function WealthQueueAlone()
		{
			super();
			_id_ = Engine.WEALTH_ALONE_SIGN + Engine.getSoleId();
			WealthManager.instanceHash.put(this.id, this);

			_wealthGroup_ = WealthGroupVo.createWealthGroup();
			_wealthGroup_.coder::oid = this.id;
			
			timer = new Timer(5);
			timer.addEventListener(TimerEvent.TIMER, timerFunc);
			timer.start();
		}

		private function timerFunc(evt:TimerEvent):void
		{
			if (_stop == false) {
				this.loop();
			}
		}
		
		public function set limitIndex(value:int):void
		{
			_limitIndex = value;
			_limitIndexMax = value;
		}
		
		public function setStateLimitIndex():void
		{
			_limitIndex --;
			if (_limitIndex < 0) {
				_limitIndex = 0;
			}
		}
		
		public function get length():int
		{
			return _wealthGroup_.wealthTotal;
		}
		
		public function get stop():Boolean
		{
			return _stop;
		}
		public function set stop(value:Boolean):void
		{
			_stop = value;
		}
		
		public function set delay(value:int):void
		{
			_delay = value;
		}
		
		public function addWealth(url:String, data:Object=null, dataFormat:String=null, otherArgs:Object=null, prio:int=-1):String
		{
			if (_isDispose_) {
				return null;
			}
			
			var wealth_id:String = _wealthGroup_.addWealth(url, data, dataFormat, otherArgs, prio);
			if (isSortOn) {
				_wealthGroup_.sortOn(["prio", "time"], [Array.NUMERIC, Array.NUMERIC]);
			}
			return wealth_id;
		}
		
		private function loop():void
		{
			var pass:Boolean = false;
			if (this.name == WealthConst.AVATAR_REQUEST_WEALTH) {
				if ((getTimer()-WealthQueueAlone.avatarRequestElisorTime) > 500) {
					pass = true;
					WealthQueueAlone.avatarRequestElisorTime = getTimer();
				}
			} else {
				if ((getTimer()-_delayTime) > _delay) {
					pass = true;
					_delayTime = getTimer();
				}
			}
			if (pass) {
				this.loadWealth();
			}
		}
		
		private function loadWealth():void
		{
			if (_wealthGroup_ && _wealthGroup_.wealthTotal) {
				var wealthVo:WealthVo = null;
				var idx:int = 0;
				while (idx < _limitIndex) {
					wealthVo = _wealthGroup_.getNextWealth();
					if (wealthVo) {
						_Manager_.loadWealth(wealthVo, this.loaderContext);
					}
					idx++;
				}
			}
		}
		
		internal final function _callSuccess_(wealth_id:String):void
		{
			var wealthVo:WealthVo = WealthVo.takeWealthVo(wealth_id);
			if (wealthVo && wealthVo.isLoaded == false) {
				_limitIndex++;
				if (_limitIndex > _limitIndexMax) {
					_limitIndex = _limitIndexMax;
				}
				wealthVo.coder::isLoaded = true;
				wealthVo.coder::isPended = false;
				_wealthGroup_.removeWealth(wealth_id);
				this.dispatchWealthEvent(WealthEvent.WEALTH_COMPLETE, wealthVo.url, wealth_id, wealthVo.oid);
			}
		}
		
		internal final function _callError_(wealth_id:String):void
		{
			var wealthVo:WealthVo = WealthVo.takeWealthVo(wealth_id);
			if (wealthVo && wealthVo.isLoaded == false) {
				_limitIndex++;
				if (_limitIndex > _limitIndexMax) {
					_limitIndex = _limitIndexMax;
				}
				wealthVo.coder::isLoaded = true;
				wealthVo.coder::isPended = false;
				_wealthGroup_.removeWealth(wealth_id);
				this.dispatchWealthEvent(WealthEvent.WEALTH_ERROR, wealthVo.url, wealth_id, wealthVo.oid);
			}
		}
		
		internal final function _callProgress_(wealth_id:String, bytesLoaded:Number, bytesTotal:Number):void
		{
			var wealthVo:WealthVo = WealthVo.takeWealthVo(wealth_id);
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
		
		public function removeWealth(wealth_id:String):void
		{
			if (_isDispose_) {
				return;
			}
			_Manager_.cancelWealth(wealth_id);
			_wealthGroup_.removeWealth(wealth_id);
		}
		
		public function get id():String
		{
			return _id_;
		}
		
		public function get oid():String
		{
			return _oid_;
		}
		
		public function get proto():Object
		{
			return _proto_;
		}
		public function set proto(value:Object):void
		{
			_proto_ = value;
		}
		
		public function get className():String
		{
			return _className_;
		}
		
		public function clone():Object
		{
			throw new Error("不支持复制");
		}
		
		public function dispose():void
		{
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, timerFunc);
			timer = null;
			
			WealthManager.instanceHash.remove(this.id);
			_id_ = null;
			_oid_ = null;
			_proto_ = null;
			_isDispose_ = true;
			_wealthGroup_.dispose();
			_wealthGroup_ = null;
		}
		
		override public function toString():String
		{
			return "[" + this.className + Engine.SIGN + this.id + "]";
		}
	}
} 
