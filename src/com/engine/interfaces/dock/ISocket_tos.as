package com.engine.interfaces.dock
{
	import flash.utils.ByteArray;
	import com.engine.interfaces.IProto;

	public interface ISocket_tos extends IProto
	{
		function get pack_id():int;

		function encode():ByteArray;
		
	}
}