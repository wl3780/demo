package com.engine.interfaces.dock
{
	import com.engine.interfaces.IProto;

	public interface IProxy extends IProto
	{
		function send(message:IMessage):void;
		
		function subHandle(message:IMessage):void;
		
		function checkFromat():Boolean;
	}
}