package com.engine.core.tile.square
{
	import com.engine.utils.Hash;
	
	import flash.utils.Dictionary;

	public class SquareGroup 
	{

		private static var _instance:SquareGroup;

		private var _hash:Hash;

		public function SquareGroup()
		{
			if (_instance == null) {
				_instance = this;
				_hash = new Hash();
			}
		}

		public static function getInstance():SquareGroup
		{
			if (_instance == null) {
				_instance = new SquareGroup();
			}
			return _instance;
		}


		public function get hash():Hash
		{
			return _hash;
		}

		public function dispose():void
		{
			_hash.dispose();
			_hash = null;
			_instance = null;
		}

		public function unload():void
		{
			if (this.hash == null) {
				return;
			}
			
			var square:Square;
			for (var key:String in this.hash) {
				square = this.hash.remove(key) as Square;
				square.dispose();
			}
		}

		public function reset(source:Dictionary):void
		{
			var tmpHash:Hash = _hash;
			_hash = new Hash();
			if (source) {
				for each (var item:Square in source) {
					this.put(item);
				}
			}
			tmpHash.dispose();
		}

		public function put(square:Square):void
		{
			this.hash.put(square.key, square);
		}

		public function remove(key:String):Square
		{
			if (this.hash.has(key)) {
				return _hash.remove(key) as Square;
			}
			return null;
		}

		public function has(key:String):Boolean
		{
			if (key == null) {
				return false;
			}
			return this.hash.has(key);
		}

		public function take(key:String):Square
		{
			return _hash.take(key) as Square;
		}

		public function passAbled(sqIndex:SquarePt):Boolean
		{
			if (sqIndex) {
				var sq:Square = _hash.take(sqIndex.key) as Square;
				if (sq) {
					if (sq.type == 3 || sq.type == 4) {	// 3/4是什么？
						if (sq.type > 0) {
							return true;
						}
					}
				}
			}
			return false;
		}

	}
}
