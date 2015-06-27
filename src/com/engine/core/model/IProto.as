package com.engine.core.model
{
	public interface IProto 
	{

		function get id():String;
		
		function get oid():String;
		
		function set proto(val:Object):void;
		function get proto():Object;
		
		function clone():IProto;
		
		function dispose():void;

	}
}
