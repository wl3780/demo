package com.engine.core.view.avatar
{
	import com.engine.core.model.Proto;

	public class AvatarRestrict extends Proto 
	{

		public var timeout:int;
		public var replay:int = -1;
		public var stopInLastFrame:Boolean = true;
		public var type:String;
		public var state:String;
		public var isDely:Boolean = false;
		public var stopFrame:int;
		public var gotoAndPlay:Boolean = false;
		public var gotoAndPlayLastFrame:Boolean = false;

	}
}
