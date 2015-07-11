package com.engine.core.controls.wealth
{
	import com.engine.core.Core;
	import com.engine.core.controls.wealth.loader.DisplayLoader;
	import com.engine.core.controls.wealth.loader.ILoader;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	import com.engine.utils.Hash;
	
	import flash.utils.Dictionary;

	public class WealthPool extends Proto 
	{

		private static var _intance:WealthPool;

		coder var hash:Dictionary;
		private var bitmapdatas:Hash;

		public function WealthPool()
		{
			coder::hash = new Dictionary();
			this.bitmapdatas = new Hash();
		}

		public static function getIntance():WealthPool
		{
			if (_intance == null) {
				_intance = new WealthPool();
			}
			return _intance;
		}


		public function take(path:String):ILoader
		{
			return coder::hash[path] as ILoader;
		}

		public function has(path:String):Boolean
		{
			if (coder::hash[path]) {
				return true;
			}
			return false;
		}

		public function remove(path:String):void
		{
			delete coder::hash[path];
		}

		public function add(path:String, loader:ILoader):void
		{
			if (coder::hash[path] == null) {
				coder::hash[path] = loader;
			}
		}

		public function getSymbolIntance(path:String, kName:String=null):Object
		{
			var linkName:String;
			var instance:Object;
			var clazz:Class;
			if (kName) {
				linkName = path + Core.LINE + kName;
				instance = this.bitmapdatas.take(linkName);
				if (instance == null) {
					clazz = this.getClass(path, kName);
					if (clazz) {
						instance = new clazz();
						this.bitmapdatas.put(linkName, instance);
						return instance;
					}
					return null;
				}
				return instance;
			}
			
			linkName = path;
			instance = this.bitmapdatas.take(linkName);
			if (instance == null) {
				return null;
			}
			return instance;
		}

		public function getClass(path:String, kName:String):Class
		{
			var loader:DisplayLoader = WealthPool.getIntance().take(path) as DisplayLoader;
			if (loader) {
				return loader.contentLoaderInfo.applicationDomain.getDefinition(kName) as Class;
			}
			return null;
		}

	}
}
