package com.engine.core.view.items
{
	import com.engine.interfaces.display.IAvatar;
	import com.engine.namespaces.coder;
	
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	public class InstancePool 
	{

		private static var _instance:InstancePool;

		public var dic:Dictionary;
		public var limit:int = 15;

		public function InstancePool()
		{
			this.dic = new Dictionary();
		}

		coder static function getInstance():InstancePool
		{
			if (_instance == null) {
				_instance = new InstancePool();
			}
			return _instance;
		}

		public function reset():void
		{
			var pool:Array;
			var idx:int;
			var avatar:IAvatar;
			for (var kName:String in this.dic) {
				pool = this.dic[kName];
				idx = 0;
				while (idx < pool.length) {
					avatar = pool[idx] as IAvatar;
					if (avatar) {
						avatar.dispose();
					}
					idx++;
				}
				delete this.dic[kName];
			}
		}

		public function getAvatar(aClass:Class):IAvatar
		{
			var kName:String = getQualifiedClassName(aClass);
			var pool:Array = this.dic[kName];
			if (pool && pool.length) {
				return pool.pop() as IAvatar;
			}
			return new aClass() as IAvatar;
		}

		public function recover(avatar:IAvatar):void
		{
			if (!avatar) {
				return;
			}
			var kName:String = getQualifiedClassName(avatar);
			if (this.dic[kName] == null) {
				this.dic[kName] = [];
			}
			var pool:Array = this.dic[kName];
			if (pool.length <= this.limit) {
				if (pool.indexOf(avatar) == -1) {
					pool.push(avatar);
				}
			} else {
				avatar.dispose();
			}
		}

		public function remove(avatar:IAvatar):void
		{
			if (!avatar) {
				return;
			}
			var kName:String = getQualifiedClassName(avatar);
			if (this.dic[kName] != null) {
				var pool:Array = this.dic[kName] as Array;
				if (pool) {
					var idx:int = pool.indexOf(avatar);
					if (idx != -1) {
						pool.splice(idx, 1);
					}
				}
			}
   	 	}

	}
}
