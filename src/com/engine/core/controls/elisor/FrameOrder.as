package com.engine.core.controls.elisor
{
	import com.engine.core.Engine;
	import com.engine.core.controls.Order;
	
	import flash.display.DisplayObject;
	import flash.net.registerClassAlias;
	
	public final class FrameOrder extends Order
	{
		private static var _orderQueue:Vector.<FrameOrder> = new Vector.<FrameOrder>();
		
		public var stop:Boolean;
		public var value:int;
		public var display:DisplayObject;
		
		protected var _applyHandler_:Function;
		
		public function FrameOrder()
		{
			super();
			registerClassAlias("engine.save.FrameOrder", FrameOrder);
		}
		
		public static function createFrameOrder():FrameOrder
		{
			var order:FrameOrder = _orderQueue.length ? _orderQueue.pop() : new FrameOrder();
			return order;
		}
		
		public function get isOnStageHandler():Boolean
		{
			if (this.display) {
				return true;
			}
			return false;
		}
		
		public function setup(orderMode:String, oid:String, applyHandler:Function):void
		{
			_orderMode_ = orderMode;
			_oid_ = oid;
			_id_ = oid + Engine.SIGN + orderMode;
			_applyHandler_ = applyHandler;
		}
		
		public function get applyHandler():Function
		{
			return _applyHandler_;
		}
		
		override public function dispose():void
		{
			this.display = null;
			this.value = 0;
			this.stop = false;
			_orderQueue.push(this);
		}
		
	}
}
