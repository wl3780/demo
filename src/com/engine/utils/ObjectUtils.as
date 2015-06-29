package com.engine.utils
{
	import flash.utils.ByteArray;

	public class ObjectUtils 
	{

		public static function copy(target:Object):Object
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(target);
			bytes.position = 0;
			return bytes.readObject();
		}

	}
}
