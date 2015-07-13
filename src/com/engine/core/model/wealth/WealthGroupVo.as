package com.engine.core.model.wealth
{
	import com.engine.core.Engine;
	import com.engine.core.controls.wealth.WealthConstant;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	
	import flash.net.URLLoaderDataFormat;
	import flash.utils.Dictionary;

	public class WealthGroupVo extends Proto 
	{

		public var name:String = "";
		public var loadedIndex:int;
		public var level:int;
		
		private var _values:Vector.<WealthVo>;
		private var _hash:Dictionary;
		private var _loaded:Boolean;
		private var _lock:Boolean;

		public function WealthGroupVo()
		{
			super();
			_hash = new Dictionary();
			_values = new Vector.<WealthVo>();
			this.level = WealthConstant.PRIORITY_LEVEL;
		}

		public function addWealth(path:String, data:Object, index:int=0):void
		{
			var key:String = path + Engine.SIGN + this.id;
			if (_hash[key] == null) {
				var wealthVo:WealthVo = new WealthVo();
				wealthVo.setUp(path, data, this.id);
				if (path.indexOf(".txt") != -1 
					|| path.indexOf(".xml") != -1 
					|| path.indexOf(".css") != -1 
					|| path.indexOf(".as") != -1) {
					wealthVo.dataFormat = URLLoaderDataFormat.TEXT;
				} else {
					wealthVo.dataFormat = URLLoaderDataFormat.BINARY;
				}
				wealthVo.coder::index = _values.length;
				wealthVo.retryCount = index;
				
				_values.push(wealthVo);
				_hash[key] = wealthVo;
			}
		}

		public function checkFinish():void
		{
			var count:int;
			var len:int = _values.length;
			var idx:int;
			while (idx < len) {
				if (_values[idx].loaded == false) {
					_loaded = false;
				} else {
					count++;
				}
				idx++;
			}
			this.loadedIndex = count;
			if (count == len) {
				_loaded = true;
			}
		}

		public function addWealths(paths:Vector.<String>, datas:Vector.<Object>):void
		{
			var len:int = paths.length;
			var idx:int;
			while (idx < len) {
				this.addWealth(paths[idx], datas ? datas[idx] : null, idx);
				idx++;
			}
		}

		public function getNextWealth():WealthVo
		{
			for each (var item:WealthVo in _values) {
				if (item.lock == false && item.loaded == false && item.path) {
					return item;
				}
			}
			return null;
		}

		public function remove(id:String):WealthVo
		{
			var wealthVo:WealthVo = _hash[id];
			delete _hash[id];
			var idx:int = _values.indexOf(wealthVo);
			if (idx != -1) {
				_values.slice(idx, 1);
			}
			return wealthVo;
		}

		public function take(id:String):WealthVo
		{
			return _hash[id] as WealthVo;
		}

		public function sortOn(pro:String="index"):void
		{
			var compareFunction:Function = function (one:WealthVo, another:WealthVo):int
			{
				if (one.hasOwnProperty(pro)) {
					return int(one[pro] - another[pro]);
				}
				return one.index - another.index;
			};
			_values.sort(compareFunction);
		}

		public function reBuild():void
		{
			_hash = new Dictionary();
			_values = new Vector.<WealthVo>();
			this.level = WealthConstant.PRIORITY_LEVEL;
		}

		override public function dispose():void
		{
			_hash = null;
			_values = null;
			super.dispose();
		}

		
		coder function values():Vector.<WealthVo>
		{
			return _values;
		}
		
		public function get length():int
		{
			if (_values) {
				return _values.length;
			}
			return 0;
		}
		
		public function get lock():Boolean
		{
			return _lock;
		}
		coder function set lock(val:Boolean):void
		{
			_lock = val;
		}
		
		public function get loaded():Boolean
		{
			return _loaded;
		}
		coder function set loaded(val:Boolean):void
		{
			_loaded = val;
		}
		
	}
}
