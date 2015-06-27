package com.engine.core.view
{
	import com.engine.core.IOrderDispatcher;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	import com.engine.utils.Hash;

	use namespace coder;

	public class DisplayObjectPort extends Proto 
	{

		private static var _instance:DisplayObjectPort;

		private var hash:Hash;

		coder static function getInstance():DisplayObjectPort
		{
			if (_instance == null) {
				_instance = new DisplayObjectPort();
				_instance.hash = new Hash();
			}
			return _instance;
		}


		public function put(order:IOrderDispatcher):void
		{
			this.hash.put(order.id, order);
		}

		public function remove(id:String):IOrderDispatcher
		{
			return this.hash.remove(id) as IOrderDispatcher;
		}

		public function has(id:String):Boolean
		{
			return this.hash.has(id);
		}

		public function task(id:String):IOrderDispatcher
		{
			return this.hash.take(id) as IOrderDispatcher;
		}

		public function get length():int
		{
			return this.hash.length;
		}

		override public function dispose():void
		{
			for each (var order:IOrderDispatcher in this.hash) {
				order.dispose();
			}
			this.hash.dispose();
			this.hash = null;
			_instance = null;
		}

	}
}
