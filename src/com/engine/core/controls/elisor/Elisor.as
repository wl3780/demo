package com.engine.core.controls.elisor
{
	import com.engine.core.model.Proto;
	import com.engine.interfaces.IProto;
	import com.engine.interfaces.system.IOrderDispatcher;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;

	public class Elisor extends Proto 
	{

		private static var _instance:Elisor;

		private var _EventElisor:EventElisor;
		private var _FrameElisor:FrameElisor;

		public function Elisor()
		{
			super();
			_EventElisor = EventElisor.getInstance();
			_FrameElisor = FrameElisor.getInstance();
		}

		public static function getInstance():Elisor
		{
			if (_instance == null) {
				_instance = new Elisor();
			}
			return _instance;
		}

		public function setup(stage:Stage):void
		{
			_FrameElisor.setup(stage);
		}
		
		// ---------------------------------------------
		public function addFrameOrder(target:IProto, handler:Function, delay:int=0, isOnStageHandler:Boolean=false):void
		{
			var order:FrameOrder = FrameOrder.createFrameOrder();
			order.value = delay;
			if (delay == 0) {
				order.setup(OrderMode.ENTER_FRAME_ORDER, target.id, handler);
			} else {
				if (isOnStageHandler) {
					order.display = target as DisplayObject;
				}
				order.setup(OrderMode.DELAY_FRAME_ORDER, target.id, handler);
			}
			_FrameElisor.addFrameOrder(order);
		}
		
		public function hasFrameOrder(handler:Function):Boolean
		{
			return _FrameElisor.hasFrameOrder(handler);
		}
		
		public function setInterval(target:IProto, handler:Function, delay:int, ... args):void
		{
			var order:FrameOrder = FrameOrder.createFrameOrder();
			order.value = delay;
			order.setup(OrderMode.INTERVAL_FRAME_ORDER, target.id, handler);
			order.proto = args;
			_FrameElisor.addFrameOrder(order);
		}
		
		public function setTimeOut(target:IProto, handler:Function, delay:int, ... args):String
		{
			var order:FrameOrder = FrameOrder.createFrameOrder();
			order.value = delay;
			order.setup(OrderMode.DELAY_FRAME_ORDER, target.id, handler);
			order.proto = args;
			_FrameElisor.addFrameOrder(order);
			return order.id;
		}
		
		public function removeFrameOrder(handler:Function):void
		{
			_FrameElisor.removeFrameOrder(handler);
		}
		
		public function stopFrameOrder(handler:Function):void
		{
			_FrameElisor.stopFrameOrder(handler);
		}
		
		public function stopTargetFrameOrder(target:IProto):void
		{
			_FrameElisor.stopFrameGroup(target.id);
		}
		
		public function removeTotalFrameOrder(target:IProto):void
		{
			_FrameElisor.removeFrameGroup(target.id);
		}
		
		// ---------------------------------------------
		public function hasEventOrder(oid:String, listenerType:String):Boolean
		{
			return _EventElisor.hasEventOrder(oid, listenerType);
		}
		
		public function addEventOrder(tar:IOrderDispatcher, type:String, listener:Function):void
		{
			var order:EventOrder = EventOrder.createEventOrder();
			order.register(tar.id, type, listener);
			_EventElisor.addOrder(order);
		}
		
		public function removeEventOrder(oid:String, listenerType:String):void
		{
			_EventElisor.removeEventOrder(oid, listenerType);
		}
		
		public function removeTotalEventOrder(target:IProto):void
		{
			_EventElisor.disposeGroupOrders(target.id);
		}
		
		// ---------------------------------------------
		public function removeTotalOrder(target:IProto):void
		{
			this.removeTotalEventOrder(target);
			this.removeTotalFrameOrder(target);
		}

	}
}
