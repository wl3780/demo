package core
{
	import com.engine.utils.FPSUtils;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.Dictionary;

	public class HeartbeatFactory
	{
		private static var _instance_:HeartbeatFactory;

		private var hash:Dictionary;
		private var unstageFrameOrder:Vector.<Function>;
		private var stageFrameOrder:Vector.<Function>;
		private var stageFrameOrderTarget:Vector.<DisplayObject>;
		private var heartbeatIndex:int = 0;
		private var startIndex:int;

		public function HeartbeatFactory()
		{
			super();
			hash = new Dictionary();
			unstageFrameOrder = new Vector.<Function>();
			stageFrameOrder = new Vector.<Function>();
			stageFrameOrderTarget = new Vector.<DisplayObject>();
		}
		
		public static function getInstance():HeartbeatFactory
		{
			return _instance_ ||= new HeartbeatFactory();
		}

		public function setup(stage:Stage):void
		{
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		protected function onEnterFrame(event:Event):void
		{
			var idx:int;
			var action:Function = null;
			if (unstageFrameOrder.length) {
				var heartbeatSize:int = FPSUtils.fps < 3 ? 2 : 6;
				heartbeatIndex = Math.ceil(unstageFrameOrder.length / heartbeatSize);
				idx = unstageFrameOrder.length - heartbeatIndex;
				while (idx >= 0) {
					if (startIndex >= unstageFrameOrder.length) {
						startIndex = 0;
					}
					action = unstageFrameOrder[startIndex];
					action.apply();
					startIndex++;
					idx--;
				}
			}
			
			var dis:DisplayObject = null;
			idx = 0;
			var len:int = stageFrameOrder.length
			while (idx < len) {
				dis = stageFrameOrderTarget[idx];
				if (dis.stage) {
					action = stageFrameOrder[idx];
					action.apply();
				}
				idx++;
			}
		}
		
		public function addFrameOrder(listener:Function, onStageTarget:DisplayObject=null):void
		{
			if (hash[listener] == null) {
				hash[listener] = {onStageTarget:onStageTarget}
				if (onStageTarget) {
					stageFrameOrder.push(listener);
					stageFrameOrderTarget.push(onStageTarget);
				} else {
					unstageFrameOrder.push(listener);
				}
			}
		}
		
		public function removeFrameOrder(listener:Function):void
		{
			if (hash[listener] != null) {
				var dis:DisplayObject = hash[listener].onStageTarget as DisplayObject;
				delete hash[listener];
				
				var index:int;
				if (!dis) {
					index = unstageFrameOrder.indexOf(listener);
					if (index != -1) {
						unstageFrameOrder.splice(index, 1);
					}
				} else {
					index = stageFrameOrder.indexOf(listener);
					if (index != -1) {
						stageFrameOrder.splice(index, 1);
						stageFrameOrderTarget.splice(index, 1);
					}
				}
			}
		}

	}
}
