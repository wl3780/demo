package com.engine.utils
{
	import com.engine.core.Core;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;

	public class FPSUtils 
	{

		private static const maxMemory:uint = 41943000;
		private static const tfDelayMax:int = 10;
		
		public static var fps:int;
		
		private static var _stage:Stage;
		private static var tfDelay:int = 0;
		private static var tfTimer:int;
		
		public static function setup(stage:Stage):void
		{
			if (_stage == null) {
				_stage = stage;
				_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		private static function onEnterFrame(evt:Event):void
		{
			tfDelay ++;
			if (tfDelay >= tfDelayMax) {
				tfDelay = 0;
				fps = (1000 * tfDelayMax) / (getTimer() - tfTimer);
				tfTimer = getTimer();
				Core.fps = fps;
			}
		}

	}
}
