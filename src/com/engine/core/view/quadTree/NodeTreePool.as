package com.engine.core.view.quadTree
{
	import flash.utils.Dictionary;

	public class NodeTreePool 
	{

		private static var _instance:NodeTreePool;

		private var hash:Dictionary;

		public function NodeTreePool()
		{
			this.hash = new Dictionary();
		}

		public static function getInstance():NodeTreePool
		{
			if (_instance == null) {
				_instance = new NodeTreePool();
			}
			return _instance;
		}

		public function put(tree:NodeTree):void
		{
			if (this.hash[tree.id] == null) {
				this.hash[tree.id] = tree;
			}
		}

		public function take(id:String):NodeTree
		{
			return this.hash[id] as NodeTree;
		}

		public function remove(id:String):void
		{
			delete this.hash[id];
		}

	}
}
