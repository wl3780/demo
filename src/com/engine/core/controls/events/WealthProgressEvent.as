package com.engine.core.controls.events
{
	import flash.events.ProgressEvent;

	public class WealthProgressEvent extends ProgressEvent 
	{

		public static const PROGRESS:String = "PROGRESS";

		public var path:String;
		public var wealth_id:String;
		public var wealthGroup_id:String;
		
		public var totlaIndex:int;
		public var loadedIndex:int;

		public function WealthProgressEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, bytesLoaded:uint=0, bytesTotal:uint=0)
		{
			super(type, bubbles, cancelable, bytesLoaded, bytesTotal);
		}

	}
}
