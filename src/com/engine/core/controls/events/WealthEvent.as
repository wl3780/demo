package com.engine.core.controls.events
{
	import com.engine.core.model.wealth.WealthVo;
	
	import flash.events.Event;

	public class WealthEvent extends Event 
	{
		/**
		 * 单个加载完毕
		 */
		public static const WEALTH_LOADED:String = "WEALTH_LOADED";
		/**
		 * 组加载完毕
		 */		
		public static const WEALTH_GROUP_LOADED:String = "WEALTH_GROUP_LOADED";
		/**
		 * 加载失败
		 */
		public static const WEALTH_ERROR:String = "WEALTH_ERROR";

		public var vo:WealthVo;
		public var loadedIndex:int;
		public var total_loadeIndex:int;
		public var group_name:String;

		public function WealthEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

	}
}
