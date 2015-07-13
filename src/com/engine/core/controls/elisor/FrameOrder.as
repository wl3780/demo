package com.engine.core.controls.elisor
{
	import com.engine.core.Engine;
	import com.engine.core.controls.Order;
	import com.engine.namespaces.coder;
	
	import flash.net.registerClassAlias;

	public class FrameOrder extends Order 
	{

		private var _applyFunc:Function;
		private var _arguments:Array;
		private var _callbackFunc:Function;
		private var _timeOutFunc:Function;
		private var _timeOutargs:Array;
		private var _stop:Boolean;
		private var _startTime:Number;
		private var _between:int;
		private var _delay:int;

		public function FrameOrder()
		{
			registerClassAlias("saiman.save.FrameOrder", FrameOrder);
			this.$type = OrderMode.FRAME_ORDER;
			this.$id = Engine.coder::nextInstanceIndex().toString(16);
			_stop = true;
		}

		public function get delay():int
		{
			return _delay;
		}

		coder function set delay(val:int):void
		{
			_delay = val;
		}

		public function set delay(val:int):void
		{
			if (_delay != val) {
				if (FrameElisor.coder::getInstance().chageDeay(this.$id, val) == false) {
					_delay = val;
				}
			}
		}

		public function setUp(oid:String, delay:int, between:int=-1):void
		{
			if (oid == null){
				this.$oid = Engine.coder::nextInstanceIndex().toString(16);
			} else {
				this.$oid = oid;
			}
			_delay = delay;
			_between = between;
		}

		public function setTimeOut(func:Function, args:Array):void
		{
			_timeOutFunc = func;
			_timeOutargs = args;
		}

		public function register(applyFunc:Function, args:Array, callbackFunc:Function=null):void
		{
			if (applyFunc != null) {
				_applyFunc = applyFunc;
			}
			if (args == null) {
				args = [];
			}
			_arguments = args;
			if (callbackFunc != null) {
				_callbackFunc = callbackFunc;
			}
		}

		public function start():void
		{
			_startTime = Engine.delayTime;
			_stop = false;
		}

		public function set stop(val:Boolean):void
		{
			if (_stop != val) {
				_stop = val;
				var quene:DeayQuene = FrameElisor.coder::getInstance().takeQuene(_delay+"");
				if (val) {
					quene.stopOrder(this.$id);
				} else {
					quene.startOrder(this.$id);
				}
			}
		}

		public function get stop():Boolean
		{
			return _stop;
		}

		override public function execute():void
		{
			if (_stop == false) {
				if (_applyFunc != null) {
					var applyRet:* = _applyFunc.apply(null, _arguments);
					this.callback([applyRet]);
				}
				if (_between != -1) {
					var delayTime:int = Engine.delayTime;
					if ((delayTime - (_startTime + _between)) >= 0) {
						_stop = true;
						if (_timeOutargs == null) {
							_timeOutargs = [];
						}
						if (_timeOutFunc != null) {
							_timeOutFunc.apply(null, _timeOutargs);
						}
						this.dispose();
						return;
					}
				}
			}
		}

		override public function callback(args:Array=null):void
		{
			try {
				if (_callbackFunc == null) {
					return;
				}
				_callbackFunc.apply(null, args);
			} catch(e:Error) {
				this.dispose();
				throw new Error("【异常】：" + e.message);
			}
		}

		override public function dispose():void
		{
			if (FrameElisor.coder::getInstance().hasOrder(this.id)) {
				FrameElisor.coder::getInstance().removeOrder(this.id);
			}
			_stop = false;
			_applyFunc = null;
			_callbackFunc = null;
			_arguments = null;
			_timeOutFunc = null;
			_timeOutargs = null;
			_startTime = 0;
			_delay = 0;
			_startTime = 0;
			_between = 0;
			super.dispose();
		}

	}
}
