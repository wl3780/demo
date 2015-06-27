﻿package com.engine.core
{
	import com.engine.core.controls.IOrder;
	import com.engine.core.model.IProto;
	
	import flash.events.IEventDispatcher;

	public interface IOrderDispatcher extends IEventDispatcher, IProto 
	{

		function takeOrder(_arg_1:String, _arg_2:String):IOrder;
		function hasOrder(_arg_1:String, _arg_2:String):Boolean;
		function removeOrder(_arg_1:String, _arg_2:String):IOrder;
		function addOrder(_arg_1:IOrder):Boolean;
		function takeGroupOrders(_arg_1:String):Vector.<IOrder>;
		function disposeGroupOrders(_arg_1:String):Vector.<IOrder>;

	}
}