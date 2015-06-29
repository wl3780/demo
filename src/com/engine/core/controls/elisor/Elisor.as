package com.engine.core.controls.elisor
{
	import com.engine.core.controls.IOrder;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;

	public class Elisor extends Proto 
	{

		private static var _instance:Elisor;

		private var _EventElisor:EventElisor;
		private var _FrameElisor:FrameElisor;

		public static function getInstance():Elisor
		{
			if (_instance == null) {
				_instance = new Elisor();
				_instance.initialize();
			}
			return _instance;
		}


		public function initialize():void
		{
			_EventElisor = EventElisor.coder::getInstance();
			_FrameElisor = FrameElisor.coder::getInstance();
		}

		public function createEventOrder(oid:String, type:String, listener:Function):EventOrder
		{
			var order:EventOrder = new EventOrder();
			order.register(oid, type, listener);
			return order;
		}

		public function createFrameOrder(oid:String, delay:int, action:Function, args:Array=null, callback:Function=null, between:int=-1):FrameOrder
		{
			if (action == null) {
				throw new Error("action 不能为 null");
				return;
			}
			var order:FrameOrder = new FrameOrder();
			order.setUp(oid, delay, between);
			order.register(action, args, callback);
			return order;
		}

		public function setTimeOut(oid:String, between:int, func:Function, args:Array):FrameOrder
		{
			var order:FrameOrder = new FrameOrder();
			order.setUp(oid, 20, between);
			order.setTimeOut(func, args);
			return order;
		}

		public function addOrder(order:IOrder, _arg_2:Boolean=false):Boolean
		{
			switch (order.type) {
				case OrderMode.EVENT_ORDER:
					return _EventElisor.addOrder(order as EventOrder);
				case OrderMode.FRAME_ORDER:
					return _FrameElisor.addOrder(order as FrameOrder);
			}
			return false;
		}

		public function removeOrder(_arg_1:String, _arg_2:String):IOrder
		{
			switch (_arg_1) {
				case OrderMode.EVENT_ORDER:
					return _EventElisor.removeOrder(_arg_1);
				case OrderMode.FRAME_ORDER:
					return _FrameElisor.removeOrder(_arg_1);
			}
			return null;
		}

		public function hasOrder(_arg_1:String, _arg_2:String):Boolean
		{
			switch (_arg_1) {
				case OrderMode.EVENT_ORDER:
					return _EventElisor.hasOrder(_arg_1);
				case OrderMode.FRAME_ORDER:
					return _FrameElisor.hasOrder(_arg_1);
			}
			return false;
		}

		public function takeOrder(_arg_1:String, _arg_2:String):IOrder
		{
			switch (_arg_1) {
				case OrderMode.EVENT_ORDER:
					return _EventElisor.takeOrder(_arg_1);
				case OrderMode.FRAME_ORDER:
					return _FrameElisor.takeOrder(_arg_1);
			}
			return null;
		}

		public function hasGroup(_arg_1:String, orderMode:String=OrderMode.TOTAL):Boolean
		{
			switch (orderMode) {
				case OrderMode.TOTAL:
					return _EventElisor.hasGroup(_arg_1) || _FrameElisor.hasGroup(_arg_1);
				case OrderMode.EVENT_ORDER:
					return _EventElisor.hasGroup(_arg_1);
				case OrderMode.FRAME_ORDER:
					return _FrameElisor.hasGroup(_arg_1);
			}
			return false;
		}

		public function takeGroupOrders(_arg_1:String, orderMode:String=OrderMode.TOTAL):Vector.<IOrder>
		{
			switch (orderMode) {
				case OrderMode.TOTAL:
					var list:Vector.<IOrder> = _EventElisor.takeGroupOrder(_arg_1);
					list.concat(_FrameElisor.takeGroupOrder(_arg_1));
					return list;
				case OrderMode.EVENT_ORDER:
					return _EventElisor.takeGroupOrder(_arg_1);
				case OrderMode.FRAME_ORDER:
					return _FrameElisor.takeGroupOrder(_arg_1);
			}
			return null;
		}

		public function disposeGroupOrders(_arg_1:String, orderMode:String=OrderMode.TOTAL):Vector.<IOrder>
		{
			switch (orderMode) {
				case OrderMode.TOTAL:
					var list:Vector.<IOrder> = _EventElisor.disposeGroupOrders(_arg_1);
					return list.concat(_FrameElisor.disposeGroupOrders(_arg_1));
				case OrderMode.EVENT_ORDER:
					return _EventElisor.disposeGroupOrders(_arg_1);
				case OrderMode.FRAME_ORDER:
					return _FrameElisor.disposeGroupOrders(_arg_1);
			}
			return null;
		}

		override public function dispose():void
		{
			_EventElisor.dispose();
			_EventElisor = null;
			_FrameElisor.dispose();
			_FrameElisor = null;
			super.dispose();
			_instance = null;
		}

	}
}
