package com.engine.core
{
	import com.engine.core.controls.IOrder;
	import com.engine.core.model.IProto;
	
	import flash.events.IEventDispatcher;

	public interface IOrderDispatcher extends IEventDispatcher, IProto 
	{

		function takeOrder(orderId:String, _arg_2:String):IOrder;
		function hasOrder(orderId:String, _arg_2:String):Boolean;
		function removeOrder(orderId:String, _arg_2:String):IOrder;
		function addOrder(order:IOrder):Boolean;
		
		function takeGroupOrders(orderMode:String):Vector.<IOrder>;
		function disposeGroupOrders(orderMode:String):Vector.<IOrder>;

	}
}
