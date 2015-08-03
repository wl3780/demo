package com.engine.core.controls.events
{
	import flash.events.Event;

	public class WealthEvent extends Event 
	{
		/**
		 * 单个加载完毕
		 */
		public static const WEALTH_COMPLETE:String = "WEALTH_COMPLETE";
		/**
		 * 组加载完毕
		 */		
		public static const WEALTH_GROUP_COMPLETE:String = "WEALTH_GROUP_COMPLETE";
		/**
		 * 加载失败
		 */
		public static const WEALTH_ERROR:String = "WEALTH_ERROR";

		public var path:String;
		public var wealth_id:String;
		public var wealthGroup_id:String;

		public function WealthEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

	}
}
