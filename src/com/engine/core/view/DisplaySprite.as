﻿package com.engine.core.view
{
	import com.engine.core.Engine;
	import com.engine.core.controls.elisor.Elisor;
	import com.engine.core.view.scenes.Scene;
	import com.engine.interfaces.display.IDisplay;
	import com.engine.interfaces.system.IOrderDispatcher;
	import com.engine.utils.DisplayObjectUtil;
	import com.engine.utils.ObjectUtils;
	
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	
	public class DisplaySprite extends Sprite implements IDisplay, IOrderDispatcher
	{
		private static var _elisor_:Elisor = Elisor.getInstance();
		
		protected var _id_:String;
		protected var _oid_:String;
		protected var _type_:String;
		protected var _proto_:Object;
		protected var _enabled_:Boolean = true;
		protected var _className_:String;
		protected var _isDisposed_:Boolean = false;
		
		public function DisplaySprite()
		{
			super();
			_className_ = getQualifiedClassName(this);
			this.init();
		}
		
		protected function init():void
		{
			_id_ = Engine.getSoleId();
			DisplayObjectPort.put(this);
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if (!_elisor_.hasEventOrder(this.id, type)) {
				_elisor_.addEventOrder(this, type, listener);
				super.addEventListener(type, listener, useCapture);
			}
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			super.removeEventListener(type, listener, useCapture);
			_elisor_.removeEventOrder(this.id, type);
		}
		
		public function addFrameOrder(heartBeatHandler:Function, deay:int=0, isOnStageHandler:Boolean=false):void
		{
			_elisor_.addFrameOrder(this, heartBeatHandler, deay, isOnStageHandler);
		}
		
		public function removeFrameOrder(heartBeatHandler:Function):void
		{
			_elisor_.removeFrameOrder(heartBeatHandler);
		}
		
		public function hasFrameOrder(heartBeatHandler:Function):Boolean
		{
			return _elisor_.hasFrameOrder(heartBeatHandler);
		}
		
		public function setTimeOut(closureHandler:Function, delay:int, ... args):String
		{
			var params:Array = [this, closureHandler, delay].concat(args);
			return _elisor_.setTimeOut.apply(null, params);
		}
		
		public function setInterval(heartBeatHandler:Function, delay:int, ... args):void
		{
			var params:Array = [this, heartBeatHandler, delay].concat(args);
			_elisor_.setInterval.apply(null, params);
		}
		
		public function removeTotalFrameOrder():void
		{
			_elisor_.removeTotalFrameOrder(this);
		}
		
		public function removeTotalEventOrder():void
		{
			_elisor_.removeTotalEventOrder(this);
		}
		
		public function removeTotalOrders():void
		{
			this.removeTotalFrameOrder();
			this.removeTotalEventOrder();
		}
		
		public function set enabled(value:Boolean):void
		{
			_enabled_ = value;
		}
		public function get enabled():Boolean
		{
			return _enabled_;
		}
		
		public function get type():String
		{
			return _type_;
		}
		public function set type(value:String):void
		{
			_type_ = value;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed_;
		}
		
		public function onRender():void
		{
		}
		
		public function get id():String
		{
			return _id_;
		}
		public function set id(value:String):void
		{
			_id_ = value;
		}
		
		public function get oid():String
		{
			return _oid_;
		}
		public function set oid(value:String):void
		{
			_oid_ = value;
		}
		
		public function get proto():Object
		{
			return _proto_;
		}
		public function set proto(value:Object):void
		{
			_proto_ = value;
		}
		
		public function clone():Object
		{
			return ObjectUtils.copy(this);
		}
		
		public function resetForDisposed():void
		{
			_isDisposed_ = false;
			_enabled_ = true;
			this.init();
		}
		
		public function dispose():void
		{
			Scene.isDepthChange = true;
			if (this.parent) {
				this.parent.removeChild(this);
			}
			this.removeTotalOrders();
			DisplayObjectPort.remove(this.id);
			_id_ = null;
			_oid_ = null;
			_type_ = null;
			_proto_ = null;
			_isDisposed_ = true;
			this.graphics.clear();
			DisplayObjectUtil.clearDisplayObject(this);
		}
		
		override public function toString():String
		{
			return "[" + this.className + Engine.SIGN + this.id + "]";
		}
		
		public function get className():String
		{
			return _className_;
		}
		
	}
}
