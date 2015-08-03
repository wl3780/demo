package com.engine.core.controls.wealth
{
	import com.engine.core.Engine;
	import com.engine.core.controls.wealth.loader.DisplayLoader;
	import com.engine.interfaces.display.ILoader;
	import com.engine.utils.Hash;

	public class WealthPool extends Object 
	{
		private static var _loaderInstanceHash:Hash = new Hash();
		private static var _wealthLoaderHash:Hash = new Hash();
		private static var _symbolIntanceHash:Hash = new Hash();
		
		public function WealthPool()
		{
			super();
		}
		
		public static function addLoader(loader:ILoader):void
		{
			_loaderInstanceHash.put(loader.id, loader);
		}
		public static function takeLoader(id:String):ILoader
		{
			return _loaderInstanceHash.take(id) as ILoader;
		}
		public static function removeLoader(id:String):ILoader
		{
			return _loaderInstanceHash.remove(id) as ILoader;
		}

		
		public static function depositWealthLoader(path:String, loader_id:String):void
		{
			_wealthLoaderHash.put(path, loader_id);
		}
		public static function takeLoaderByWealth(path:String):ILoader
		{
			var loader_id:String = _wealthLoaderHash.take(path) as String;
			var loader:ILoader = _loaderInstanceHash.take(loader_id) as ILoader;
			return loader;
		}
		public static function removeLoaderByWealth(path:String):ILoader
		{
			var loader_id:String = _wealthLoaderHash.remove(path) as String;
			var loader:ILoader = _loaderInstanceHash.remove(loader_id) as ILoader;
			return loader;
		}
		public static function disposeLoaderByWealth(path:String):void
		{
			var loader_id:String = _wealthLoaderHash.remove(path) as String;
			var loader:ILoader = _loaderInstanceHash.remove(loader_id) as ILoader;
			if (loader) {
				loader.dispose();
			}
		}

		public static function getSymbolIntance(path:String, kName:String):Object
		{
			var linkName:String = path + Engine.LINE + kName;
			var instance:Object = _symbolIntanceHash.take(linkName);
			if (instance == null) {
				var clazz:Class = getClass(path, kName);
				if (clazz) {
					instance = new clazz();
					_symbolIntanceHash.put(linkName, instance);
				}
			}
			return instance;
		}

		public static function getClass(path:String, kName:String):Class
		{
			var loader:DisplayLoader = _loaderInstanceHash.take(path) as DisplayLoader;
			if (loader) {
				return loader.contentLoaderInfo.applicationDomain.getDefinition(kName) as Class;
			}
			return null;
		}

	}
}
