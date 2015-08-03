package com.engine.core.model.wealth
{
	import com.engine.core.Engine;
	import com.engine.core.controls.wealth.WealthConst;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	import com.engine.utils.Hash;
	
	import flash.net.URLLoaderDataFormat;
	import flash.net.registerClassAlias;
	import flash.utils.getTimer;

	public class WealthVo extends Proto 
	{
		private static var instanceHash:Hash = new Hash();
		
		public var retryCount:int = 0;
		public var dataFormat:String;
		public var prio:int = 5;
		public var time:int;

		private var _wid:String;
		private var _url:String;
		private var _data:Object;
		private var _loaded:Boolean;
		private var _pended:Boolean;
		private var _type:String;
		private var _suffix:String;

		public function WealthVo()
		{
			super();
			registerClassAlias("engine.save.WealthVo", WealthVo);
			WealthVo.instanceHash.put(this.id, this);
		}
		
		public static function getWealthVo(id:String):WealthVo
		{
			return WealthVo.instanceHash.take(id) as WealthVo;
		}
		
		public static function removeWealthVo(id:String):WealthVo
		{
			return WealthVo.instanceHash.remove(id) as WealthVo;
		}

		public function setup(url:String, data:Object=null, dataFormat:String=null, otherArgs:Object=null, prio:int=-1):void
		{
			_url = url;
			try {
				_suffix = url.split(".").pop();
				_suffix = _suffix.split("?").shift();
				if (Engine.SWF_Files.indexOf(_suffix) != -1) {
					_type = WealthConst.SWF_WEALTH;
				} else if (Engine.IMG_Files.indexOf(_suffix) != -1) {
					_type = WealthConst.IMG_WEALTH;
				} else {
					_type = WealthConst.BING_WEALTH;
				}
			} catch(e:Error) {
				log(this, "请检查资源地址格式是否正确：" + url);
			}
			
			_data = data;
			this.proto = otherArgs;
			
			if (prio == -1) {
				this.prio = 0;
			}
			if (url.indexOf(Engine.SM_FILE) != -1) {
				this.prio = 0;
			}
			if (dataFormat) {
				this.dataFormat = dataFormat;
			} else if (_type == WealthConst.BING_WEALTH) {
				if (Engine.TEXT_Files.indexOf(_suffix) != -1) {
					this.dataFormat = URLLoaderDataFormat.TEXT;
				} else {
					this.dataFormat = URLLoaderDataFormat.BINARY;
				}
			}
			
			this.time = getTimer();
		}

		public function get url():String
		{
			return _url;
		}

		public function get data():Object
		{
			return _data;
		}
		
		public function get wid():String
		{
			return _wid;
		}
		coder function set wid(val:String):void
		{
			_wid = val;
		}

		/**
		 * 正在加载中？？？
		 * @return 
		 */		
		public function get isPended():Boolean
		{
			return _pended;
		}
		coder function set isPended(val:Boolean):void
		{
			_pended = val;
		}

		public function get isLoaded():Boolean
		{
			return _loaded;
		}
		coder function set isLoaded(val:Boolean):void
		{
			_loaded = val;
		}

		public function get suffix():String
		{
			return _suffix;
		}

		public function get type():String
		{
			return _type;
		}
		
	}
}
