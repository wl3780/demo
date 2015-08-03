package com.engine.interfaces
{
	public interface IProto
	{
		function get id():String;

		function get oid():String;

		function get proto():Object;

		function set proto(value:Object):void;

		function get className():String;

		function dispose():void;

		function clone():Object;

		function toString():String;
	}
}