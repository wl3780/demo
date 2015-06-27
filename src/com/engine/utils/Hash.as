package com.engine.utils
{
	import com.engine.namespaces.coder;
	
	import flash.utils.Dictionary;

	use namespace coder;

	public class Hash 
	{

		private var _length:int;
		private var _hash:Dictionary;

		public function Hash()
		{
			_length = 0;
			_hash = new Dictionary();
		}

		public function put(key:String, val:Object):void
		{
			if (this.has(key) == false) {
				_hash[key] = val;
				_length++;
			} else {
				this.remove(key);
				_hash[key] = val;
				_length++;
			}
		}

		public function remove(key:String):Object
		{
			if (this.has(key)) {
				var ret:Object = _hash[key];
				delete _hash[key];
				_length--;
				return ret;
			}
			return null;
		}

		public function has(key:String):Boolean
		{
			if (_hash[key] != null) {
				return true;
			}
			return false;
		}

		public function take(key:String):Object
		{
			return _hash[key];
		}

		public function get length():int
		{
			return _length;
		}

		public function get hash():Dictionary
		{
			return _hash;
		}

		public function dispose():void
		{
			_hash = null;
			_length = 0;
		}

		coder function dispose():void
		{
			for (var key:String in _hash) {
				delete _hash[key];
			}
			_hash = null;
			_length = 0;
		}

		coder function values():Array
		{
			var ret:Array = [];
			for each (var val:Object in _hash) {
				ret.push(val);
			}
			return ret;
		}

		coder function keys():Array
		{
			var ret:Array = [];
			for each (var key:Object in _hash) {
				ret.push(key);
			}
			return null;
		}

	}
}
