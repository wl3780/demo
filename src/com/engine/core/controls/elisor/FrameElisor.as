﻿package com.engine.core.controls.elisor
{
	import com.engine.core.Engine;
	import com.engine.core.model.Proto;
	import com.engine.utils.FPSUtils;
	import com.engine.utils.Hash;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	public final class FrameElisor extends Proto
	{
		private static var _instance:FrameElisor;
		
		public var stop:Boolean;
		
		private var _heartbeatSize:int = 6;
		private var _hash:Hash;
		
		private var enterFrameOrder:Vector.<Function>;
		private var enterFrameHeartbeatState:Vector.<Boolean>;
		private var enterFrameHeartbeatIndex:int;
		
		private var onStageFrameOrder:Vector.<Function>;
		private var onStageDisplays:Vector.<DisplayObject>;
		private var onStageHeartbeatState:Vector.<Boolean>;
		private var onStageHeartbeatIndex:int;
		
		private var intervalFrameOrder:Vector.<Function>;
		private var intervalQueue:Vector.<int>;
		private var intervalCountQueue:Vector.<int>;
		private var intervalHeartbeatState:Vector.<Boolean>;
		private var intervalHeartbeatIndex:int;
		
		private var delayFrameOrder:Vector.<Function>;
		private var delayFrameQueue:Vector.<int>;
		private var delayHeartbeatState:Vector.<Boolean>;
		private var delayHeartbeatIndex:int;
		
		public function FrameElisor()
		{
			super();
			_hash = new Hash();
			_hash.oid = this.id;
			
			enterFrameOrder = new Vector.<Function>();
			enterFrameHeartbeatState = new Vector.<Boolean>();
			
			onStageFrameOrder = new Vector.<Function>();
			onStageDisplays = new Vector.<DisplayObject>();
			onStageHeartbeatState = new Vector.<Boolean>();
			
			intervalFrameOrder = new Vector.<Function>();
			intervalQueue = new Vector.<int>();
			intervalCountQueue = new Vector.<int>();
			intervalHeartbeatState = new Vector.<Boolean>();
			
			delayFrameOrder = new Vector.<Function>();
			delayFrameQueue = new Vector.<int>();
			delayHeartbeatState = new Vector.<Boolean>();
		}
		
		public static function getInstance():FrameElisor
		{
			return _instance ||= new FrameElisor();
		}
		
		public function setup(stage:Stage):void
		{
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function hasFrameOrder(handler:Function):Boolean
		{
			return _hash.has(handler);
		}
		
		public function takeFrameOrder(handler:Function):FrameOrder
		{
			return _hash.take(handler) as FrameOrder;
		}
		
		public function addFrameOrder(order:FrameOrder):void
		{
			var handler:Function = order.applyHandler;
			if (_hash.has(handler) == false) {
				this.stop = true;
				_hash.put(handler, order);
				if (OrderMode.ENTER_FRAME_ORDER == order.orderMode) {
					if (order.isOnStageHandler) {
						onStageFrameOrder.push(handler);
						onStageDisplays.push(order.display);
						onStageHeartbeatState.push(order.stop);
					} else {
						enterFrameOrder.push(handler);
						enterFrameHeartbeatState.push(order.stop);
					}
				} else if (OrderMode.INTERVAL_FRAME_ORDER == order.orderMode) {
					intervalFrameOrder.push(handler);
					intervalQueue.push(order.value);
					intervalCountQueue.push(getTimer());
					intervalHeartbeatState.push(order.stop);
				} else if (OrderMode.DELAY_FRAME_ORDER == order.orderMode) {
					delayFrameOrder.push(handler);
					delayFrameQueue.push(getTimer() + order.value);
					delayHeartbeatState.push(order.stop);
				}
				this.stop = false;
			}
		}
		
		public function removeFrameOrder(handler:Function):void
		{
			var order:FrameOrder = _hash.remove(handler) as FrameOrder;
			if (!order) {
				return;
			}
			
			var index:int;
			this.stop = true;
			if (OrderMode.ENTER_FRAME_ORDER == order.orderMode) {
				if (order.isOnStageHandler) {
					index = onStageFrameOrder.indexOf(handler);
					if (index != -1) {
						onStageDisplays.splice(index, 1);
						onStageFrameOrder.splice(index, 1);
						onStageHeartbeatState.splice(index, 1);
						if (index < onStageHeartbeatIndex) {
							onStageHeartbeatIndex --;
						}
					}
				} else {
					index = enterFrameOrder.indexOf(handler);
					if (index != -1) {
						enterFrameOrder.splice(index, 1);
						enterFrameHeartbeatState.splice(index, 1);
						if (index < enterFrameHeartbeatIndex) {
							enterFrameHeartbeatIndex --;
						}
					}
				}
			} else if (OrderMode.INTERVAL_FRAME_ORDER == order.orderMode) {
				index = intervalFrameOrder.indexOf(handler);
				if (index != -1) {
					intervalFrameOrder.splice(index, 1);
					intervalQueue.splice(index, 1);
					intervalCountQueue.splice(index, 1);
					intervalHeartbeatState.splice(index, 1);
					if (index < intervalHeartbeatIndex) {
						intervalHeartbeatIndex --;
					}
				}
			} else if (OrderMode.DELAY_FRAME_ORDER == order.orderMode) {
				index = delayFrameOrder.indexOf(handler);
				if (index != -1) {
					delayFrameOrder.splice(index, 1);
					delayFrameQueue.splice(index, 1);
					delayHeartbeatState.splice(index, 1);
					if (index < delayHeartbeatIndex) {
						delayHeartbeatIndex --;
					}
				}
			}
			order.dispose();
			this.stop = false;
		}
		
		public function startFrameOrder(handler:Function):void
		{
			var order:FrameOrder = _hash.take(handler) as FrameOrder;
			if (!order) {
				return;
			}
			
			var index:int;
			order.stop = false;
			if (OrderMode.ENTER_FRAME_ORDER == order.orderMode) {
				if (order.isOnStageHandler) {
					index = onStageFrameOrder.indexOf(handler);
					if (index != -1) {
						onStageHeartbeatState[index] = false;
					}
				} else {
					index = enterFrameOrder.indexOf(handler);
					if (index != -1) {
						enterFrameHeartbeatState[index] = false;
					}
				}
			} else if (OrderMode.INTERVAL_FRAME_ORDER == order.orderMode) {
				index = intervalFrameOrder.indexOf(handler);
				if (index != -1) {
					intervalHeartbeatState[index] = false;
				}
			} else if (OrderMode.DELAY_FRAME_ORDER == order.orderMode) {
				index = delayFrameOrder.indexOf(handler);
				if (index != -1) {
					delayHeartbeatState[index] = false;
				}
			}
		}
		
		public function stopFrameOrder(handler:Function):void
		{
			var order:FrameOrder = _hash.take(handler) as FrameOrder;
			if (!order) {
				return;
			}
			
			var index:int;
			order.stop = true;
			if (OrderMode.ENTER_FRAME_ORDER == order.orderMode) {
				if (order.isOnStageHandler) {
					index = onStageFrameOrder.indexOf(handler);
					if (index != -1) {
						onStageHeartbeatState[index] = true;
					}
				} else {
					index = enterFrameOrder.indexOf(handler);
					if (index != -1) {
						enterFrameHeartbeatState[index] = true;
					}
				}
			} else if (OrderMode.INTERVAL_FRAME_ORDER == order.orderMode) {
				index = intervalFrameOrder.indexOf(handler);
				if (index != -1) {
					intervalHeartbeatState[index] = true;
				}
			} else if (OrderMode.DELAY_FRAME_ORDER == order.orderMode) {
				index = delayFrameOrder.indexOf(handler);
				if (index != -1) {
					delayHeartbeatState[index] = true;
				}
			}
		}
		
		public function stopFrameGroup(group_id:String):void
		{
			if (!group_id) {
				return;
			}
			for each (var order:FrameOrder in _hash) {
				if (order.oid == group_id) {
					this.stopFrameOrder(order.applyHandler);
				}
			}
		}
		
		public function startFrameGroup(group_id:String):void
		{
			if (!group_id) {
				return;
			}
			for each (var order:FrameOrder in _hash) {
				if (order.oid == group_id) {
					this.startFrameOrder(order.applyHandler);
				}
			}
		}
		
		public function removeFrameGroup(group_id:String):void
		{
			if (!group_id) {
				return;
			}
			for each (var order:FrameOrder in _hash) {
				if (order.oid == group_id) {
					this.removeFrameOrder(order.applyHandler);
				}
			}
		}
		
		private function onEnterFrame(event:Event):void
		{
			if (this.stop || !Engine.enabled) {
				return;
			}
			
			_heartbeatSize = FPSUtils.fps < 3 ? 2 : 6;
			onEnterFrameHandler();
			onStageFrameHandler();
			onIntervalHandler();
			onDelayHandler();
		}
		
		private function onEnterFrameHandler():void
		{
			var orderNum:int = enterFrameOrder.length;
			if (orderNum <= 0) {
				return;
			}
			
			var handler:Function = null;
			var state:Boolean;
			var orderIndex:int = Math.ceil(orderNum / _heartbeatSize);
			var tmp:int = orderNum - orderIndex;
			while (tmp >= 0 && !this.stop) {
				if (enterFrameHeartbeatIndex >= enterFrameOrder.length) {
					enterFrameHeartbeatIndex = 0;
				}
				
				handler = enterFrameOrder[enterFrameHeartbeatIndex];
				state = enterFrameHeartbeatState[enterFrameHeartbeatIndex];
				if (!state && handler != null) {
					handler.apply();
				}
				enterFrameHeartbeatIndex ++;
				tmp--;
			}
		}
		
		private function onStageFrameHandler():void
		{
			var orderNum:int = onStageFrameOrder.length;
			if (orderNum <= 0) {
				return;
			}
			
			var display:DisplayObject;
			var handler:Function = null;
			var state:Boolean;
			var orderIndex:int = Math.ceil(orderNum / _heartbeatSize);
			var tmp:int = orderNum - orderIndex;
			while (tmp >= 0 && !this.stop) {
				if (onStageHeartbeatIndex >= onStageFrameOrder.length) {
					onStageHeartbeatIndex = 0;
				}
				
				display = onStageDisplays[onStageHeartbeatIndex];
				handler = onStageFrameOrder[onStageHeartbeatIndex];
				state = onStageHeartbeatState[onStageHeartbeatIndex];
				if (display && display.stage && !state && handler != null) {
					handler.apply();
				}
				onStageHeartbeatIndex ++;
				tmp--;
			}
		}
		
		private function onIntervalHandler():void
		{
			var orderNum:int = intervalFrameOrder.length;
			if (orderNum <= 0) {
				return;
			}
			
			var handler:Function = null;
			var interval:int;
			var time:int;
			var state:Boolean;
			var order:FrameOrder = null;
			var orderIndex:int = Math.ceil(orderNum / _heartbeatSize);
			var tmp:int = orderNum - orderIndex;
			while (tmp >= 0 && !this.stop) {
				if (intervalHeartbeatIndex >= intervalFrameOrder.length) {
					intervalHeartbeatIndex = 0;
				}
				handler = intervalFrameOrder[intervalHeartbeatIndex];
				time = intervalCountQueue[intervalHeartbeatIndex];
				interval = intervalQueue[intervalHeartbeatIndex];
				state = intervalHeartbeatState[intervalHeartbeatIndex];
				if (!state && handler != null && (getTimer() - time) >= interval) {
					order = _hash.take(handler) as FrameOrder;
					if (order.proto) {
						handler.apply(null, [order.proto]);
					} else {
						handler.apply();
					}
					intervalCountQueue[intervalHeartbeatIndex] = getTimer();
				}
				intervalHeartbeatIndex ++;
				tmp--;
			}
		}
		
		private function onDelayHandler():void
		{
			var orderNum:int = delayFrameOrder.length;
			if (orderNum <= 0) {
				return;
			}
			
			var handler:Function = null;
			var time:int;
			var state:Boolean;
			var order:FrameOrder = null;
			var orderIndex:int = Math.ceil(orderNum / _heartbeatSize);
			var tmp:int = orderNum - orderIndex;
			while (tmp >= 0 && !this.stop) {
				if (delayHeartbeatIndex >= delayFrameOrder.length) {
					delayHeartbeatIndex = 0;
				}
				handler = delayFrameOrder[delayHeartbeatIndex];
				time = delayFrameQueue[delayHeartbeatIndex];
				state = delayHeartbeatState[delayHeartbeatIndex];
				if (!state && handler != null && (getTimer() - time) >= 0) {
					order = _hash.remove(handler) as FrameOrder;
					if (order.proto) {
						handler.apply(null, [order.proto]);
					} else {
						handler.apply();
					}
					// 移除
					delayFrameOrder.splice(delayHeartbeatIndex, 1);
					delayFrameQueue.splice(delayHeartbeatIndex, 1);
					delayHeartbeatState.splice(delayHeartbeatIndex, 1);
					
					order.dispose();
					delayHeartbeatIndex --;
				}
				delayHeartbeatIndex ++;
				tmp --;
			}
		}
		
	}
}
