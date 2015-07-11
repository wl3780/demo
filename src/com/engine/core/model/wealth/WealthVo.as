package com.engine.core.model.wealth
{
	import com.engine.core.Core;
	import com.engine.core.controls.wealth.WealthConstant;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	
	import flash.net.registerClassAlias;

	public class WealthVo extends Proto 
	{
		
		public var loadIndex:int = 0;
		public var group_totalNum:int;
		public var group_loadedIndex:int;
		public var dataFormat:String;

		coder var $index:int;
		
		private var _path:String;
		private var _data:Object;
		private var _loaded:Boolean;
		private var _lock:Boolean;

		public function WealthVo()
		{
			super();
			registerClassAlias("saiman.save.WealthVo", WealthVo);
		}

		public function get path():String
		{
			return _path;
		}

		public function get data():Object
		{
			return _data;
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

		public function setUp(path:String, data:Object=null, owner:String=null):void
		{
			_path = path;
			_data = data;
			this.$oid = owner;
			this.$id = path + Core.SIGN + owner;
		}

		public function get index():int
		{
			return this.coder::$index;
		}

		public function get type():String
		{
			if (_path) {
				if (_path.indexOf(".swf") != -1 || _path.indexOf(".tmp") != -1) {
					return WealthConstant.SWF_WEALTH;
				}
				if (_path.indexOf(".png") != -1 
					|| _path.indexOf(".jpg") != -1 
					|| _path.indexOf(".jxr") != -1 
					|| _path.indexOf(".gif") != -1 
					|| _path.indexOf(".jpeg") != -1) {
					return WealthConstant.IMG_WEALTH;
				}
				return WealthConstant.BING_WEALTH;
			}
			return null;
		}
		
	}
}
