package com.engine.core.view
{
	import com.engine.core.IOrderDispatcher;
	import com.engine.namespaces.coder;
	import com.engine.utils.Hash;

	public class DisplayObjectPort extends Object 
	{

		private static var _instance:DisplayObjectPort;

		private var _hash:Hash;
		
		public function DisplayObjectPort()
		{
			super();
			_hash = new Hash();
		}

		coder static function getInstance():DisplayObjectPort
		{
			if (_instance == null) {
				_instance = new DisplayObjectPort();
			}
			return _instance;
		}


		public function put(order:IOrderDispatcher):void
		{
			_hash.put(order.id, order);
		}

		public function remove(id:String):IOrderDispatcher
		{
			return _hash.remove(id) as IOrderDispatcher;
		}

		public function has(id:String):Boolean
		{
			return _hash.has(id);
		}

		public function task(id:String):IOrderDispatcher
		{
			return _hash.take(id) as IOrderDispatcher;
		}

		public function get length():int
		{
			return _hash.length;
		}

		public function dispose():void
		{
			for each (var order:IOrderDispatcher in _hash) {
				order.dispose();
			}
			_hash.dispose();
			_hash = null;
			_instance = null;
		}

	}
}
