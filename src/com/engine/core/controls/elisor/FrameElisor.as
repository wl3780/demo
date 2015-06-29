package com.engine.core.controls.elisor
{
	import com.engine.core.controls.IOrder;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	
	import flash.utils.Dictionary;

	use namespace coder;

	public class FrameElisor extends Proto 
	{

		private static var _instance:FrameElisor;

		private var _owners:Dictionary;
		private var _quenes:Dictionary;
		private var _orders:Dictionary;
		private var _len:int;

		coder static function getInstance():FrameElisor
		{
			if (_instance == null) {
				_instance = new FrameElisor();
				_instance.initialize();
			}
			return _instance;
		}

		public function initialize():void
		{
			_owners = new Dictionary();
			_quenes = new Dictionary();
			_orders = new Dictionary();
		}

		public function addOrder(order:FrameOrder, _arg_2:Boolean=false):Boolean
		{
			if (order == null) {
				return false;
			}
			var oid:String = order.oid;
			var id:String = order.id;
			var delay:String = order.delay.toString();
			if (oid && id && delay) {
				var delayItem:DeayQuene;
				if (_owners[oid] == null) {
					_owners[oid] = new Dictionary();
				}
				if (_quenes[delay] == null) {
					delayItem = new DeayQuene(order.delay);
					_quenes[delay] = delayItem;
				} else {
					delayItem = _quenes[delay];
				}
				delayItem.addOrder(order);
				_owners[oid][id] = _orders[id] = order;
				_len++;
				return true;
			}
			return false;
		}

		public function stopOrder(id:String):void
		{
			var order:FrameOrder = _orders[id] as FrameOrder;
			if (order) {
				order.stop = false;
			}
		}

		public function startOrder(id:String):void
		{
			var order:FrameOrder = _orders[id] as FrameOrder;
			if (order) {
				order.stop = true;
			}
		}

		public function removeOrder(id:String):FrameOrder
		{
			var order:FrameOrder = _orders[id] as FrameOrder;
			if (order) {
				order.stop = true;
				delete _orders[id];
				if (_owners[order.oid]) {
					delete _owners[order.oid][id];
				}
				
				var dict:Dictionary = _owners[order.oid];
				var delayItem:DeayQuene = _quenes[order.delay+""] as DeayQuene;
				if (delayItem) {
					delayItem.removeOrder(id);
				}
				_len--;
				for each (var orderItem:FrameOrder in dict) {
					order.dispose();
					return order;
				}
				delete _owners[order.oid];
				order.dispose();
				return order;
			}
			return null;
		}

		public function hasOrder(id:String):Boolean
		{
			if (_orders[id]) {
				return true;
			}
			return false;
		}

		public function removeQuene(delayID:String):void
		{
			delete _quenes[delayID];
		}

		public function hasQuene(delayID:String):Boolean
		{
			if (_quenes[delayID]) {
				return true;
			}
			return false;
		}

		public function takeQuene(delayID:String):DeayQuene
		{
			return _quenes[delayID];
		}

		public function takeOrder(id:String):FrameOrder
		{
			return _orders[id] as FrameOrder;
		}

		public function hasGroup(oid:String):Boolean
		{
			if (_owners[oid]) {
				return true;
			}
			return false;
		}

		public function takeGroupOrder(oid:String):Vector.<IOrder>
		{
			var list:Vector.<IOrder> = new Vector.<IOrder>();
			if (_owners[oid]) {
				for each (var item:IOrder in _owners[oid]) {
					list.push(item);
				}
			}
			return list;
		}

		public function disposeGroupOrders(oid:String):Vector.<IOrder>
		{
			var list:Vector.<IOrder> = new Vector.<IOrder>();
			if (_owners[oid]) {
				var item:FrameOrder;
				for (var key:String in _owners[oid]) {
					item = _owners[oid][key];
					item.stop;
					item.dispose();
					list.push(item);
					_len++;
				}
				delete _owners[oid];
			}
			return list;
		}

		public function chageDeay(id:String, delay:int):Boolean
		{
			var order:FrameOrder = _orders[id] as FrameOrder;
			if (order) {
				var delayNew:DeayQuene;
				var delayItem:DeayQuene = _quenes[order.delay+""] as DeayQuene;
				if (delayItem) {
					if (delayItem.delay == order.delay) {
						delayItem.removeOrder(id);
					}
					order.coder::delay = delay;
					if (_quenes[delay+""]) {
						DeayQuene(_quenes[delay+""]).addOrder(order);
					} else {
						delayNew = new DeayQuene(delay);
						_quenes[delay+""] = delayItem;
						delayNew.addOrder(order);
					}
				} else {
					order.coder::delay = delay;
					delayNew = new DeayQuene(delay);
					_quenes[delay+""] = delayItem;
					delayNew.addOrder(order);
				}
				return true;
			}
			return false;
		}

		override public function dispose():void
		{
			var delayItem:DeayQuene;
			for (var key:String in _quenes) {
				delayItem = _quenes[key];
				delayItem.dispose();
				delete _quenes[key];
			}
			_quenes = null;
			for each (var item:FrameOrder in _orders) {
				item.dispose();
			}
			_orders = null;
			_owners = null;
			_len = 0;
			_instance = null;
			super.dispose();
		}

	}
}
