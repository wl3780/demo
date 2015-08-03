package com.engine.core.model.wealth
{
	import com.engine.core.controls.wealth.WealthConst;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	import com.engine.utils.Hash;
	
	import flash.utils.Dictionary;

	public class WealthGroupVo extends Proto 
	{
		public static var instanceHash:Hash = new Hash();
		
		internal static var _recoverQueue_:Vector.<WealthGroupVo> = new Vector.<WealthGroupVo>();
		internal static var _recoverIndex_:int = 20;

		public var name:String = "";
		public var wealthLoaded:int;
		public var type:int;
		
		private var _wealthList:Array;
		private var _wealthHash:Dictionary;
		private var _loaded:Boolean;

		public function WealthGroupVo()
		{
			super();
			_wealthList = [];
			_wealthHash = new Dictionary();
			this.type = WealthConst.PRIORITY_LEVEL;
			WealthGroupVo.instanceHash.put(this.id, this);
		}
		
		public static function createWealthGroup():WealthGroupVo
		{
			var group:WealthGroupVo = null;
			if (_recoverQueue_.length) {
				group = _recoverQueue_.pop();
				WealthGroupVo.instanceHash.put(group.id, group);
			} else {
				group = new WealthGroupVo();
			}
			return group;
		}

		public function addWealth(url:String, data:Object=null, dataFormat:String=null, otherArgs:Object=null, prio:int=-1):String
		{
			var wealthVo:WealthVo = new WealthVo();
			wealthVo.setup(url, data, dataFormat, otherArgs);
			wealthVo.coder::oid = this.id;
			wealthVo.coder::wid = this.oid;
			
			_wealthList.push(wealthVo);
			_wealthHash[wealthVo.id] = wealthVo;
			return wealthVo.id;
		}

		public function takeWealth(id:String):WealthVo
		{
			return _wealthHash[id] as WealthVo;
		}

		public function removeWealth(id:String):WealthVo
		{
			var wealthVo:WealthVo = _wealthHash[id];
			delete _wealthHash[id];
			var idx:int = _wealthList.indexOf(wealthVo);
			if (idx != -1) {
				_wealthList.slice(idx, 1);
			}
			return wealthVo;
		}

		public function wealths():Array
		{
			return _wealthList;
		}
		
		public function get wealthTotal():int
		{
			if (_wealthList) {
				return _wealthList.length;
			}
			return 0;
		}
		
		public function get isLoaded():Boolean
		{
			return _loaded;
		}

		public function checkTotalFinish():void
		{
			this.wealthLoaded = 0;
			for each (var wealthVo:WealthVo in _wealthList) {
				if (wealthVo.isLoaded == true) {
					this.wealthLoaded++;
				}
			}
			if (this.wealthLoaded >= this.wealthTotal) {
				_loaded = true;
			}
		}

		public function getNextWealth():WealthVo
		{
			for each (var item:WealthVo in _wealthList) {
				if (this.type == WealthConst.BUBBLE_LEVEL) {	// 单线程体现
					if (item.isLoaded == false) {
						if (item.isPended == false) {
							return item;
						} else {
							return null;
						}
					}
				} else {
					if (item.isLoaded == false && item.isPended == false) {
						return item;
					}
				}
			}
			return null;
		}

		public function sortOn(names:Array, options:Array):void
		{
			_wealthList.sortOn(names, options);
		}

		override public function dispose():void
		{
			for each (var wealthVo:WealthVo in _wealthList) {
				wealthVo.dispose();
			}
			WealthGroupVo.instanceHash.remove(this.id);
			_wealthHash = new Dictionary();
			_wealthList.length = 0;
			_loaded = false;
			this.type = WealthConst.PRIORITY_LEVEL;
		}
		
	}
}
