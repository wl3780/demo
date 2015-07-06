package com.engine.core.controls.events
{
	import flash.events.Event;
	import com.engine.core.model.wealth.WealthVo;

	public class WealthEvent extends Event 
	{

		public static const WEALTH_LOADED:String = "WEALTH_LOADED";
		public static const WEALTH_GROUP_LOADED:String = "WEalth_GROUP_LOADED";
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
