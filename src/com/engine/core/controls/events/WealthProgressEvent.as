package com.engine.core.controls.events
{
	import com.engine.core.model.wealth.WealthVo;
	
	import flash.events.ProgressEvent;

	public class WealthProgressEvent extends ProgressEvent 
	{

		public static const Progress:String = "WealthProgress";

		public var path:String;
		public var wealth_id:String;
		public var wealth_gid:String;
		public var vo:WealthVo;
		public var totlaIndex:int;
		public var loadedIndex:int;
		public var group_name:String;

		public function WealthProgressEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, bytesLoaded:uint=0, bytesTotal:uint=0)
		{
			super(type, bubbles, cancelable, bytesLoaded, bytesTotal);
		}

	}
}
