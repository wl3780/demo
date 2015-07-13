package com.engine.core.view
{
	import com.engine.core.Engine;
	import com.engine.core.controls.IOrder;
	import com.engine.core.controls.elisor.Elisor;
	import com.engine.core.controls.elisor.EventOrder;
	import com.engine.core.controls.elisor.FrameOrder;
	import com.engine.core.controls.elisor.OrderMode;
	import com.engine.core.model.IProto;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	
	import flash.display.Sprite;

	public class BaseSprite extends Sprite implements IBaseSprite 
	{

		protected var $oid:String;
		protected var $proto:Object;
		
		private var _id:String;

		public function BaseSprite()
		{
			super();
			_id = Engine.coder::nextInstanceIndex().toString(16);
			DisplayObjectPort.coder::getInstance().put(this);
		}

		override public function addEventListener(type:String, handler:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			var elisor:Elisor = Elisor.getInstance();
			var key:String = _id + Engine.SIGN + type;
			if (elisor.hasOrder(key, OrderMode.EVENT_ORDER) == false) {
				var order:EventOrder = elisor.createEventOrder(this.id, type, handler);
				elisor.addOrder(order);
				super.addEventListener(type, handler, useCapture);
			}
		}

		override public function removeEventListener(type:String, handler:Function, useCapture:Boolean=false):void
		{
			var elisor:Elisor = Elisor.getInstance();
			var key:String = _id + Engine.SIGN + type;
			if (elisor.hasOrder(key, OrderMode.EVENT_ORDER) == true) {
				var order:EventOrder = elisor.removeOrder(key, OrderMode.EVENT_ORDER) as EventOrder;
				if (order) {
					order.dispose();
				}
			}
			super.removeEventListener(type, handler, useCapture);
		}

		public function _setTimeOut_(delay:int, closure:Function, parameters:Array):void
		{
			var elisor:Elisor = Elisor.getInstance();
			var order:FrameOrder = elisor.setTimeOut(this.id, delay, closure, parameters);
			elisor.addOrder(order);
			order.start();
		}

		public function onTimer(_arg_1:int, _arg_2:Function, _arg_3:Array, _arg_4:Function=null):FrameOrder
		{
			var elisor:Elisor = Elisor.getInstance();
			var order:FrameOrder = elisor.createFrameOrder(this.id, _arg_1, _arg_2, _arg_3, _arg_4, -1);
			elisor.addOrder(order);
			order.start();
			return order;
		}

		public function initialize():void
		{
		}

		public function takeOrder(_arg_1:String, _arg_2:String):IOrder
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.takeOrder(_arg_1, _arg_2);
		}

		public function hasOrder(_arg_1:String, _arg_2:String):Boolean
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.hasOrder(_arg_1, _arg_2);
		}

		public function removeOrder(_arg_1:String, _arg_2:String):IOrder
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.removeOrder(_arg_1, _arg_2);
		}

		public function addOrder(order:IOrder):Boolean
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.addOrder(order);
		}

		public function takeGroupOrders(mode:String):Vector.<IOrder>
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.takeGroupOrders(_id, mode);
		}

		public function disposeGroupOrders(mode:String):Vector.<IOrder>
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.disposeGroupOrders(_id, mode);
		}

		coder function set id(val:String):void
		{
			DisplayObjectPort.coder::getInstance().remove(_id);
			var orderList:Vector.<IOrder> = Elisor.getInstance().disposeGroupOrders(_id);
			_id = val;
			DisplayObjectPort.coder::getInstance().put(this);
			var idx:int = 0;
			var order:IOrder = null;
			while (idx < orderList.length) {
				order = orderList[idx];
				if (order) {
					Elisor.getInstance().addOrder(order);
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
			var newPro:Proto = new Proto();
			newPro.coder::id = _id;
			newPro.coder::oid = this.$oid;
			newPro.proto = this.$proto;
			return newPro;
		}

		public function dispose():void
		{
			if (this.graphics) {
				this.graphics.clear();
			}
			if (this.parent) {
				this.parent.removeChild(this);
			}
			var orderList:Vector.<IOrder> = this.disposeGroupOrders(OrderMode.TOTAL);
			if (orderList) {
				var order:IOrder;
				var idx:int = 0;
				while (idx < orderList.length) {
					order = orderList[idx];
					if (order) {
						order.dispose();
					}
					idx++;
				}
			}
			DisplayObjectPort.coder::getInstance().remove(_id);
			_id = null;
			this.$oid = null;
			this.$proto = null;
		}

	}
}
