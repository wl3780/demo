package com.engine.core.controls
{
	import com.engine.core.model.Proto;
	import com.engine.interfaces.system.IOrder;
	import com.engine.namespaces.coder;
	
	import flash.net.registerClassAlias;

	public class Order extends Proto implements IOrder
	{

		protected var _orderMode_:String;

		public function Order()
		{
			super();
			registerClassAlias("engine.save.Order", Order);
		}

		public function get orderMode():String
		{
			return _orderMode_;
		}
		coder function set orderMode(val:String):void
		{
			_orderMode_ = val;
		}

	}
}
