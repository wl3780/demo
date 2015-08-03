package com.engine.core.view
{
	import com.engine.interfaces.system.IOrderDispatcher;
	import com.engine.utils.Hash;

	public class DisplayObjectPort
	{

		private static var _hash:Hash = new Hash();
		
		public static function put(order:IOrderDispatcher):void
		{
			_hash.put(order.id, order);
		}

		public static function remove(id:String):IOrderDispatcher
		{
			return _hash.remove(id) as IOrderDispatcher;
		}

		public static function has(id:String):Boolean
		{
			return _hash.has(id);
		}

		public static function task(id:String):IOrderDispatcher
		{
			return _hash.take(id) as IOrderDispatcher;
		}

		public static function get length():int
		{
			return _hash.length;
		}

	}
}
