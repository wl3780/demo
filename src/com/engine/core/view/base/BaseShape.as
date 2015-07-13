package com.engine.core.view.base
{
	import com.engine.core.Engine;
	import com.engine.core.controls.IOrder;
	import com.engine.core.controls.elisor.Elisor;
	import com.engine.core.controls.elisor.EventOrder;
	import com.engine.core.controls.elisor.FrameOrder;
	import com.engine.core.controls.elisor.OrderMode;
	import com.engine.core.model.IProto;
	import com.engine.core.model.Proto;
	import com.engine.core.view.DisplayObjectPort;
	import com.engine.core.view.IBaseSprite;
	import com.engine.namespaces.coder;
	
	import flash.display.Shape;

	public class BaseShape extends Shape implements IBaseSprite 
	{

		protected var $oid:String;
		protected var $proto:Object;

		private var _id:String;
		
		public function BaseShape()
		{
			_id = Engine.coder::nextInstanceIndex().toString(16);
			DisplayObjectPort.coder::getInstance().put(this);
		}

		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			var elisor:Elisor = Elisor.getInstance();
			var orderType:String = _id + Engine.SIGN + type;
			if (elisor.hasOrder(orderType, OrderMode.EVENT_ORDER) == false) {
				var order:EventOrder = elisor.createEventOrder(this.id, type, listener);
				elisor.addOrder(order);
				if (super.hasEventListener(type) == false) {
					super.addEventListener(type, listener, useCapture);
				}
			}
		}

		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			var elisor:Elisor = Elisor.getInstance();
			var orderType:String = _id + Engine.SIGN + type;
			if (elisor.hasOrder(orderType, OrderMode.EVENT_ORDER) == true) {
				var order:EventOrder = elisor.removeOrder(orderType, OrderMode.EVENT_ORDER) as EventOrder;
				if (order) {
					order.dispose();
				}
			}
			if (super.hasEventListener(type) == true) {
				super.removeEventListener(type, listener);
			}
		}

		public function _setTimeOut_(delay:int, closure:Function, parameters:Array):void
		{
			var elisor:Elisor = Elisor.getInstance();
			var order:FrameOrder = elisor.setTimeOut(this.id, delay, closure, parameters);
			elisor.addOrder(order);
			order.start();
		}

		public function onTimer(delay:int, action:Function, parameters:Array, callback:Function=null):FrameOrder
		{
			var elisor:Elisor = Elisor.getInstance();
			var order:FrameOrder = elisor.createFrameOrder(this.id, delay, action, parameters, callback, -1);
			elisor.addOrder(order);
			order.start();
			return order;
		}

		public function initialize():void
		{
		}

		public function takeOrder(id:String, _arg_2:String):IOrder
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.takeOrder(id, _arg_2);
		}

		public function hasOrder(id:String, _arg_2:String):Boolean
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.hasOrder(id, _arg_2);
		}

		public function removeOrder(id:String, _arg_2:String):IOrder
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.removeOrder(id, _arg_2);
		}

		public function addOrder(order:IOrder):Boolean
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.addOrder(order);
		}

		public function takeGroupOrders(orderMode:String):Vector.<IOrder>
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.takeGroupOrders(_id, orderMode);
		}

		public function disposeGroupOrders(orderMode:String):Vector.<IOrder>
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.disposeGroupOrders(_id, orderMode);
		}

		coder function set id(val:String):void
		{
			DisplayObjectPort.coder::getInstance().remove(_id);
			var list:Vector.<IOrder> = Elisor.getInstance().disposeGroupOrders(_id);
			
			_id = val;
			DisplayObjectPort.coder::getInstance().put(this);
			var idx:int;
			while (idx < list.length) {
				if (list[idx]) {
					Elisor.getInstance().addOrder(list[idx]);
				}
				idx++;
			}
		}

		public function get id():String
		{
			return _id;
		}

		public function set proto(val:Object):void
		{
			this.$proto = val;
		}

		public function get proto():Object
		{
			return this.$proto;
		}

		public function set oid(val:String):void
		{
			this.$oid = val;
		}

		public function get oid():String
		{
			return this.$oid;
		}

		public function clone():IProto
		{
			var p:Proto = new Proto();
			p.coder::id = this.id;
			p.coder::oid = this.oid;
			p.proto = this.proto;
			return p;
		}

		public function dispose():void
		{
			try {
				this.graphics.clear();
				if (this.parent) {
					this.parent.removeChild(this);
				}
				var array:Vector.<IOrder> = this.disposeGroupOrders(OrderMode.TOTAL);
				if (array) {
					var order:IOrder;
					var i:int = 0;
					while (i < array.length) {
						order = array[i];
						if (order) {
							order.dispose();
						}
						i++;
					}
				}
				DisplayObjectPort.coder::getInstance().remove(_id);
				_id = null;
				this.$oid = null;
				this.$proto = null;
			} catch(e:Error) {
				throw (e);
			}
		}

	}
}
