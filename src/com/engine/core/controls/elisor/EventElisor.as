package com.engine.core.controls.elisor
{
	import com.engine.core.Core;
	import com.engine.core.controls.IOrder;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	
	import flash.utils.Dictionary;

	use namespace coder;

	public class EventElisor extends Proto 
	{

		private static var _instance:EventElisor;

		private var _hash:Dictionary;
		private var _len:int;

		coder static function getInstance():EventElisor
		{
			if (_instance == null) {
				_instance = new EventElisor();
				_instance.initialize();
			}
			return _instance;
		}

		public function initialize():void
		{
			_hash = new Dictionary();
		}

		public function get len():int
		{
			return _len;
		}

		public function addOrder(order:EventOrder, replace:Boolean=false):Boolean
		{
			if (order == null) {
				return false;
			}
			if (order.type == null || order.oid == null) {
				return false;
			}
			if (_hash[order.oid] == null) {
				_hash[order.oid] = new Dictionary();
			}
			if (_hash[order.oid][order.type] == null) {
				_hash[order.oid][order.type] = order;
				_len++;
			} else {
				if (replace && _hash[order.oid][order.type]) {
					delete _hash[order.oid][order.type];
					_hash[order.oid][order.type] = order;
				}
			}
			return true;
		}

		public function removeOrder(id:String):EventOrder
		{
			var arr:Array = id.split(Core.SIGN);
			if (arr.length != 2) {
				return null;
			}
			var oid:String = arr[0];
			var type:String = arr[1];
			if (_hash[oid] == null) {
				return null;
			}
			var ret:EventOrder = _hash[oid][type] as EventOrder;
			delete _hash[oid][type];
			return ret;
		}

		public function hasOrder(id:String):Boolean
		{
			var arr:Array = id.split(Core.SIGN);
			if (arr.length != 2) {
				return false;
			}
			var oid:String = arr[0];
			var type:String = arr[1];
			if (_hash[oid] == null) {
				return false;
			}
			return _hash[oid][type] != null;
		}

		public function takeOrder(id:String):EventOrder
		{
			var arr:Array = id.split(Core.SIGN);
			if (arr.length != 2) {
				return null;
			}
			var oid:String = arr[0];
			var type:String = arr[1];
			if (_hash[oid] == null) {
				return null;
			}
			return _hash[oid][type] as EventOrder;
		}

		public function hasGroup(oid:String):Boolean
		{
			if (_hash[oid] != null) {
				return true;
			}
			return false;
		}

		public function takeGroupOrder(oid:String):Vector.<IOrder>
		{
			var list:Vector.<IOrder> = new Vector.<IOrder>();
			if (_hash[oid] == null) {
				return list;
			}
			
			var dict:Dictionary = _hash[oid];
			for each (var item:EventOrder in dict) {
				list.push(item);
			}
			return list;
		}

		public function disposeGroupOrders(oid:String):Vector.<IOrder>
		{
			var list:Vector.<IOrder> = new Vector.<IOrder>();
			if (_hash[oid] == null) {
				return list;
			}
			var dict:Dictionary = _hash[oid];
			delete _hash[oid];
			for each (var item:EventOrder in dict) {
				list.push(item);
			}
			return list;
		}

		override public function dispose():void
		{
			if (_hash) {
				for (var key:String in _hash) {
					delete _hash[key];
				}
				_hash = null;
			}
			_instance = null;
			super.dispose();
		}

	}
}
