package com.engine.core.controls.wealth.loader
{
	import com.engine.core.Engine;
	import com.engine.core.IOrderDispatcher;
	import com.engine.core.controls.IOrder;
	import com.engine.core.controls.elisor.Elisor;
	import com.engine.core.controls.elisor.EventOrder;
	import com.engine.core.controls.elisor.OrderMode;
	import com.engine.core.controls.events.WealthProgressEvent;
	import com.engine.core.controls.wealth.WealthPool;
	import com.engine.core.model.IProto;
	import com.engine.core.model.Proto;
	import com.engine.core.model.wealth.WealthVo;
	import com.engine.core.view.DisplayObjectPort;
	import com.engine.namespaces.coder;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	public class BingLoader extends URLLoader implements IOrderDispatcher, ILoader 
	{

		public var vo:WealthVo;
		
		private var _id:String;
		private var _oid:String;
		private var _proto:Object;
		
		private var _successFunc:Function;
		private var _errorFunc:Function;
		private var _progressFunc:Function;

		public function BingLoader(request:URLRequest=null)
		{
			super(request);
		}

		public function unloadAndStop(gc:Boolean=true):void
		{
			this.close();
		}

		public function loadElemt(wealthVo:WealthVo, successFunc:Function=null, errorFunc:Function=null, progressFunc:Function=null, _arg_5:LoaderContext=null):void
		{
			if (wealthVo.dataFormat) {
				if (wealthVo.dataFormat == URLLoaderDataFormat.BINARY || wealthVo.dataFormat == URLLoaderDataFormat.TEXT) {
					this.dataFormat = wealthVo.dataFormat;
				}
			}
			this.vo = wealthVo;
			_successFunc = successFunc;
			_errorFunc = errorFunc;
			_progressFunc = progressFunc;
			if (_successFunc != null) {
				this.addEventListener(Event.COMPLETE, _successFunc_);
			}
			if (_errorFunc != null) {
				this.addEventListener(IOErrorEvent.IO_ERROR, _errorFunc_);
			}
			if (_progressFunc != null) {
				this.addEventListener(ProgressEvent.PROGRESS, _progressFunc_);
			}
			this.load(new URLRequest(wealthVo.path));
		}

		private function _successFunc_(evt:Event):void
		{
			WealthPool.getIntance().add(this.vo.path, this);
			_successFunc.apply(null, [this.vo]);
			_successFunc = null;
			_progressFunc = null;
			_errorFunc = null;
			this.removeEventListener(Event.COMPLETE, _successFunc_);
			this.removeEventListener(IOErrorEvent.IO_ERROR, _errorFunc_);
			this.removeEventListener(ProgressEvent.PROGRESS, _progressFunc_);
		}

		private function _errorFunc_(evt:IOErrorEvent):void
		{
			_errorFunc.apply(null, [this.vo]);
			_successFunc = null;
			_progressFunc = null;
			_errorFunc = null;
			this.removeEventListener(Event.COMPLETE, _successFunc_);
			this.removeEventListener(IOErrorEvent.IO_ERROR, _errorFunc_);
			this.removeEventListener(ProgressEvent.PROGRESS, _progressFunc_);
		}

		private function _progressFunc_(evt:ProgressEvent):void
		{
			var event:WealthProgressEvent = new WealthProgressEvent(WealthProgressEvent.Progress, false, false, evt.bytesLoaded, evt.bytesTotal);
			_progressFunc.apply(null, [event, this.vo]);
		}

		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			var elisor:Elisor = Elisor.getInstance();
			var orderKey:String = _id + Engine.SIGN + type;
			if (elisor.hasOrder(orderKey, OrderMode.EVENT_ORDER) == false) {
				var order:EventOrder = elisor.createEventOrder(this.id, type, listener);
				elisor.addOrder(order);
				if (super.hasEventListener(type) == false) {
					super.addEventListener(type, listener, useCapture);
				}
			}
		}

		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			var elisor:Elisor = Elisor.getInstance();
			var orderKey:String = _id + Engine.SIGN + type;
			if (elisor.hasOrder(orderKey, OrderMode.EVENT_ORDER) == true) {
				var order:EventOrder = elisor.removeOrder(orderKey, OrderMode.EVENT_ORDER) as EventOrder;
				if (order) {
					order.dispose();
				}
			}
			if (super.hasEventListener(type) == true) {
				super.removeEventListener(type, listener);
			}
		}

		public function takeOrder(orderId:String, _arg_2:String):IOrder
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.takeOrder(orderId, _arg_2);
		}

		public function hasOrder(orderId:String, _arg_2:String):Boolean
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.hasOrder(orderId, _arg_2);
		}

		public function removeOrder(orderId:String, _arg_2:String):IOrder
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.removeOrder(orderId, _arg_2);
		}

		public function addOrder(order:IOrder):Boolean
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.addOrder(order);
		}

		public function takeGroupOrders(orderMode:String):Vector.<IOrder>
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.takeGroupOrders(_id, orderMode);
		}

		public function disposeGroupOrders(orderMode:String):Vector.<IOrder>
		{
			var elisor:Elisor = Elisor.getInstance();
			return elisor.disposeGroupOrders(_id, orderMode);
		}

		coder function set id(val:String):void
		{
			DisplayObjectPort.coder::getInstance().remove(_id);
			var list:Vector.<IOrder> = Elisor.getInstance().disposeGroupOrders(_id);
			_id = val;
			DisplayObjectPort.coder::getInstance().put(this);
			for each (var item:IOrder in list) {
				if (item) {
					Elisor.getInstance().addOrder(item);
				}
			}
		}
		public function get id():String
		{
			return _id;
		}

		public function set proto(val:Object):void
		{
			_proto = val;
		}
		public function get proto():Object
		{
			return _proto;
		}

		public function set oid(val:String):void
		{
			_oid = val;
		}
		public function get oid():String
		{
			return _oid;
		}

		public function clone():IProto
		{
			var p:Proto = new Proto();
			p.coder::id = _id;
			p.coder::oid = _oid;
			p.proto = _proto;
			return p;
		}

		public function dispose():void
		{
			this.removeEventListener(Event.COMPLETE, _successFunc_);
			this.removeEventListener(IOErrorEvent.IO_ERROR, _errorFunc_);
			this.removeEventListener(ProgressEvent.PROGRESS, _progressFunc_);
			_successFunc = null;
			_errorFunc = null;
			_progressFunc = null;
			
			var list:Vector.<IOrder> = this.disposeGroupOrders(OrderMode.TOTAL);
			for each (var item:IOrder in list) {
				if (item) {
					item.dispose();
				}
			}
			DisplayObjectPort.coder::getInstance().remove(_id);
			_id = null;
			_oid = null;
			_proto = null;
			this.vo = null;
		}

	}
}
