package com.engine.core.controls.elisor
{
	import com.engine.core.model.Proto;
	import com.engine.interfaces.system.IOrder;
	import com.engine.utils.Hash;
	
	internal final class EventElisor extends Proto
	{
		private static var _instance:EventElisor;
		
		private var _orderHash:Hash;
		private var _length:int;
		
		public function EventElisor()
		{
			super();
			_orderHash = new Hash();
		}
		
		internal static function getInstance():EventElisor
		{
			return _instance ||= new EventElisor();
		}
		
		public function get length():int
		{
			return _length;
		}
		
		public function addOrder(order:EventOrder):Boolean
		{
			if (!order || !order.orderMode || !order.oid) {
				return false;
			}
			
			var subHash:Hash = _orderHash.take(order.oid) as Hash;
			if (!subHash) {
				subHash = new Hash();
				_orderHash.put(order.oid, subHash);
			}
			if (!subHash.has(order.orderMode)) {
				_length ++;
			}
			subHash.put(order.orderMode, order, true);
			return true;
		}
		
		public function removeEventOrder(oid:String, listenerType:String):void
		{
			if (!listenerType || !oid) {
				return;
			}
			
			var subHash:Hash = _orderHash.take(oid) as Hash;
			if (subHash) {
				var order:EventOrder = subHash.remove(listenerType) as EventOrder;
				if (order) {
					_length --;
					order.dispose();
				}
			}
		}
		
		public function hasEventOrder(oid:String, listenerType:String):Boolean
		{
			if (!listenerType || !oid) {
				return false;
			}
			
			var subHash:Hash = _orderHash.take(oid) as Hash;
			if (subHash) {
				return subHash.has(listenerType);
			}
			return false;
		}
		
		public function takeEventOrder(oid:String, listenerType:String):EventOrder
		{
			if (!listenerType || !oid) {
				return null;
			}
			
			var subHash:Hash = _orderHash.take(oid) as Hash;
			if (subHash) {
				return subHash.take(listenerType) as EventOrder;
			}
			return null;
		}
		
		public function hasGroup(oid:String):Boolean
		{
			var subHash:Hash = _orderHash[oid];
			if (subHash) {
				return subHash.length > 0;
			}
			return false;
		}
		
		public function takeGroupOrder(oid:String):Vector.<IOrder>
		{
			var result:Vector.<IOrder> = new Vector.<IOrder>();
			var subHash:Hash = _orderHash.take(oid) as Hash;
			if (subHash) {
				for each (var order:EventOrder in subHash) {
					result.push(order);
				}
			}
			return result;
		}
		
		public function disposeGroupOrders(oid:String):void
		{
			var suhHash:Hash = _orderHash.remove(oid) as Hash;
			if (suhHash) {
				for each (var order:EventOrder in suhHash) {
					order.dispose();
					_length --;
				}
				suhHash.dispose();
			}
		}
		
	}
}
