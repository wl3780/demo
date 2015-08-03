package com.engine.core.controls.elisor
{
	import com.engine.core.Engine;
	import com.engine.core.controls.Order;
	import com.engine.core.view.DisplayObjectPort;
	
	import flash.events.IEventDispatcher;
	import flash.net.registerClassAlias;

	public class EventOrder extends Order 
	{
		private static var _orderQueue:Vector.<EventOrder> = new Vector.<EventOrder>();

		protected var _listenerType_:String;
		protected var _listener_:Function;

		public function EventOrder()
		{
			super();
			registerClassAlias("engine.save.EventOrder", EventOrder);
			_orderMode_ = OrderMode.EVENT_ORDER;
		}
		
		public static function createEventOrder():EventOrder
		{
			var order:EventOrder = _orderQueue.length ? _orderQueue.pop() : new EventOrder();
			return order;
		}

		public function register(oid:String, type:String, listener:Function):void
		{
			_oid_ = oid;
			_id_ = _oid_ + Engine.SIGN + type;
			_listenerType_ = type;
			_listener_ = listener;
		}

		override public function dispose():void
		{
			this.unactivate();
			_orderQueue.push(this);
		}

		public function activate():void
		{
			var pispatcher:IEventDispatcher = DisplayObjectPort.task(this.oid);
			if (pispatcher) {
				pispatcher.addEventListener(_listenerType_, _listener_);
			}
		}

		public function unactivate():void
		{
			var pispatcher:IEventDispatcher = DisplayObjectPort.task(this.oid);
			if (pispatcher) {
				pispatcher.removeEventListener(_listenerType_, _listener_);
			}
		}

	}
}
