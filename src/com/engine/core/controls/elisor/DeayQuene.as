package com.engine.core.controls.elisor
{
	import com.engine.core.controls.IOrder;
	import com.engine.core.model.Proto;
	import com.engine.core.view.base.BaseTimer;
	import com.engine.namespaces.coder;
	
	import flash.display.Shape;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;

	public class DeayQuene extends Proto 
	{

		private var _openHash:Dictionary;
		private var timer:BaseTimer;
		private var _delay:int;
		private var len:int;
		private var enterFrame:Shape;
		private var _closeHash:Dictionary;
		private var _isDispose:Boolean;

		public function DeayQuene(_arg_1:int=250)
		{
			_openHash = new Dictionary();
			_closeHash = new Dictionary();
			_delay = _arg_1;
			this.len = 0;
		}

		public function get delay():int
		{
			return (_delay);
		}

		private function timerFunc(_arg_1:TimerEvent):void
		{
			var _local_2:IOrder;
			if (this.len <= 0) {
				this.len = 0;
				if (this.timer) {
					this.timer.stop();
				}
				this.dispose();
			}
			for each (_local_2 in _openHash) {
				_local_2.execute();
			}
		}

		public function stopOrder(_arg_1:String):void
		{
			var _local_2:FrameOrder = _openHash[_arg_1];
			delete _openHash[_arg_1];
			if (_local_2) {
				if (_closeHash[_arg_1] == null) {
					_closeHash[_arg_1] = _local_2;
				}
			}
		}

		public function startOrder(_arg_1:String):void
		{
			var _local_2:FrameOrder = _closeHash[_arg_1];
			delete _closeHash[_arg_1];
			if (_local_2) {
				if (_openHash[_arg_1] == null) {
					_openHash[_arg_1] = _local_2;
				}
			}
		}

		public function addOrder(_arg_1:FrameOrder):void
		{
			if (_arg_1) {
				if (_openHash[_arg_1.id] == null) {
					_openHash[_arg_1.id] = _arg_1;
					this.len++;
					if (this.len > 0) {
						this.timer = new BaseTimer(this.delay);
						this.timer.addEventListener(TimerEvent.TIMER, this.timerFunc);
						this.timer.start();
					}
				}
			}
		}

		public function removeOrder(_arg_1:String):void
		{
			var _local_2:FrameOrder = _openHash[_arg_1];
			if (_local_2) {
				delete _openHash[_arg_1];
				_local_2 = null;
				this.len--;
				if (this.len <= 0) {
					this.len = 0;
					this.timer.stop();
					this.dispose();
				}
			} else {
				_local_2 = _closeHash[_arg_1];
				if (_local_2) {
					delete _closeHash[_arg_1];
					_local_2 = null;
					this.len--;
					if (this.len <= 0) {
						this.len = 0;
						this.timer.stop();
						this.dispose();
					}
				}
			}
		}

		public function hasOrder(_arg_1:String):Boolean
		{
			if (_openHash[_arg_1]) {
				return (true);
			}
			if (_closeHash[_arg_1]) {
				return (true);
			}
			return (false);
		}

		public function takeOrder(_arg_1:String):FrameOrder
		{
			var _local_2:FrameOrder = (_openHash[_arg_1] as FrameOrder);
			if (_local_2 == null) {
				_local_2 = _closeHash[_arg_1];
			}
			return (_local_2);
		}

		override public function dispose():void
		{
			var _local_1:IOrder;
			var _local_2:IOrder;
			if (_isDispose) {
				return;
			}
			FrameElisor.coder::getInstance().removeQuene(_delay);
			for each (_local_1 in _openHash) {
				_local_1.dispose();
			}
			for each (_local_2 in _closeHash) {
				_local_2.dispose();
			}
			if (this.timer) {
				this.timer.removeEventListener(TimerEvent.TIMER, this.timerFunc);
				this.timer.dispose();
				this.timer.stop();
				this.timer = null;
			}
			_openHash = null;
			_closeHash = null;
			this.len = 0;
			super.dispose();
			_isDispose = true;
		}

	}
}
