package com.engine.core.controls.elisor
{
	import com.engine.core.Engine;
	import com.engine.core.IOrderDispatcher;
	import com.engine.core.controls.Order;
	import com.engine.core.view.DisplayObjectPort;
	import com.engine.namespaces.coder;
	
	import flash.net.registerClassAlias;

	public class EventOrder extends Order 
	{

		public var listenerType:String;
		
		private var _listener:Function;

		public function EventOrder()
		{
			registerClassAlias("saiman.save.EventOrder", EventOrder);
			this.$type = OrderMode.EVENT_ORDER;
		}

		public function register(oid:String, type:String, listener:Function):void
		{
			_listener = listener;
			this.listenerType = type;
			this.$oid = oid;
			this.$id = this.$oid + Engine.SIGN + type;
		}

		override public function dispose():void
		{
			var order:IOrderDispatcher = DisplayObjectPort.coder::getInstance().task(this.oid);
			if (order) {
				order.removeEventListener(this.listenerType, _listener);
			}
			_listener = null;
			this.listenerType = null;
			this.$id = null;
			this.$oid = null;
			super.dispose();
		}

		override public function execute():void
		{
			this.activate();
		}

		public function activate():void
		{
			var order:IOrderDispatcher = DisplayObjectPort.coder::getInstance().task(this.oid);
			if (order) {
				order.addEventListener(this.$id, _listener);
			}
		}

		public function unactivate():void
		{
			var order:IOrderDispatcher = DisplayObjectPort.coder::getInstance().task(this.oid);
			if (order) {
				order.removeEventListener(this.$id, _listener);
			}
		}

	}
}
