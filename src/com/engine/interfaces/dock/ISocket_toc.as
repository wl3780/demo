package com.engine.interfaces.dock
{
	import flash.utils.ByteArray;
	import com.engine.interfaces.IProto;

	public interface ISocket_toc extends IProto
	{
		function get pack_id():int;

		function decode(byte:ByteArray):void;
	}
}