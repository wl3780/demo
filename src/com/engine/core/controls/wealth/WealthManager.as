package com.engine.core.controls.wealth
{
	import com.engine.core.Core;
	import com.engine.core.controls.events.WealthEvent;
	import com.engine.core.controls.events.WealthProgressEvent;
	import com.engine.core.model.wealth.WealthGroupVo;
	import com.engine.core.model.wealth.WealthVo;
	import com.engine.namespaces.coder;
	import com.engine.utils.Hash;
	
	import flash.events.ProgressEvent;
	import flash.utils.Dictionary;

	public class WealthManager 
	{

		private static var _intance:WealthManager;

		private var _queneHash:Hash;
		private var _requestHash:Dictionary;

		public function WealthManager()
		{
			_queneHash = new Hash();
			_requestHash = new Dictionary();
		}

		public static function getIntance():WealthManager
		{
			if (_intance == null) {
				_intance = new WealthManager();
			}
			return _intance;
		}

		public function addQuene(quene:WealthQuene):void
		{
			_queneHash.put(quene.id, quene);
		}

		public function takeQuene(id:String):WealthQuene
		{
			return _queneHash.take(id) as WealthQuene;
		}

		public function removeQuene(id:String):void
		{
			_queneHash.remove(id);
		}

		public function addRequest(path:String, oid:String, qid:String):void
		{
			if (path == null) {
				return;
			}
			if (_requestHash[path] == null) {
				_requestHash[path] = new Dictionary();
			}
			_requestHash[path][oid] = {
				"oid":oid,
				"qid":qid,
				"path":path
			}
		}

		public function hasRequest(path:String):Boolean
		{
			if (_requestHash[path] == null) {
				return false;
			}
			for (var key:String in _requestHash[path]) {
				return true;
			}
			return false;
		}

		public function takeRequestLength(path:String):int
		{
			var num:int;
			for (var key:String in _requestHash[path]) {
				num++;
			}
			return num;
		}

		public function removeRequest(path:String, oid:String):void
		{
			if (_requestHash[path] == null || _requestHash[path][oid] == null) {
				return;
			}
			delete _requestHash[path][oid];
			for (var key:String in _requestHash[path]) {
				return;
			}
			delete _requestHash[path];
		}

		coder function callSuccess(path:String):void
		{
			var dict:Dictionary = _requestHash[path];
			for each (var item:Object in dict) {
				var quene:WealthQuene = _queneHash.take(item.qid) as WealthQuene;
				var groupId:String = item.oid.split(path+Core.SIGN)[1];
				var groupVo:WealthGroupVo = quene.takeGroup(groupId);
				if (groupVo.lock) {
					quene.removeGroup(groupVo.id);
					groupVo.dispose();
					continue;
				}
				
				var wealthVo:WealthVo = groupVo.take(item.oid);
				wealthVo.coder::loaded = true;
				quene.dispatchWealthEvent(WealthEvent.WEALTH_LOADED, wealthVo);
				
				groupVo.checkFinish();
				if (groupVo.loaded) {
					quene.removeGroup(wealthVo.oid);
					quene.dispatchWealthEvent(WealthEvent.WEALTH_GROUP_LOADED, wealthVo);
				}
			}
			delete _requestHash[wealthVo.path];
		}

		coder function callError(path:String):void
		{
			var dict:Dictionary = _requestHash[path];
			for each (var item:Object in dict) {
				var quene:WealthQuene = _queneHash.take(item.qid) as WealthQuene;
				var groupId:String = item.oid.split(path+Core.SIGN)[1];
				var groupVo:WealthGroupVo = quene.takeGroup(groupId);
				if (groupVo.lock) {
					quene.removeGroup(groupVo.id);
					groupVo.dispose();
					continue;
				}
				
				var wealthVo:WealthVo = groupVo.take(item.oid);
				if (wealthVo.retryCount > 0) {
					wealthVo.retryCount--;
					wealthVo.coder::lock = false;
				} else {
					wealthVo.coder::loaded = true;
					quene.dispatchWealthEvent(WealthEvent.WEALTH_ERROR, wealthVo);
					
					groupVo.checkFinish();
					if (groupVo.loaded) {
						quene.removeGroup(wealthVo.oid);
						quene.dispatchWealthEvent(WealthEvent.WEALTH_GROUP_LOADED, wealthVo);
					}
				}
			}
			delete _requestHash[path];
		}

		coder function proFunc(path:String, evt:ProgressEvent):void
		{
			for each (var item:Object in _requestHash[path]) {
				var quene:WealthQuene = _queneHash.take(item.qid) as WealthQuene;
				if (quene == null) {
					break;
				}
				var groupId:String = item.oid.split(path+Core.SIGN)[1];
				var groupVo:WealthGroupVo = quene.takeGroup(groupId);
				if (groupVo == null) {
					break;
				}
				var wealthVo:WealthVo = groupVo.take(item.oid);
				if (wealthVo == null) {
					break;
				}
				quene.dispatchWealthProgressEvent(WealthProgressEvent.Progress, evt, wealthVo);
			}
		}

		coder function removeGroupRequest(groupVo:WealthGroupVo):void
		{
			var values:Vector.<WealthVo> = groupVo.coder::values();
			for each (var wealthVo:WealthVo in values) {
				if (_requestHash[wealthVo.path]) {
					delete _requestHash[wealthVo.path][wealthVo.id];
					for each (var item:Object in _requestHash[wealthVo.path]) {
						var quene:WealthQuene = _queneHash.take(item.qid) as WealthQuene;
						if (quene == null) {
							break;
						}
						var groupId:String = item.oid.split(item.path+Core.SIGN)[1];
						groupVo = quene.takeGroup(groupId);
						if (groupVo == null) {
							break;
						}
						wealthVo = groupVo.take(item.oid);
						if (wealthVo) {
							wealthVo.coder::lock = false;
						}
					}
				}
			}
		}

	}
}
