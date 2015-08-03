package com.engine.core.controls.wealth.loader
{
	import com.engine.core.Engine;
	import com.engine.core.controls.wealth.WealthPool;
	import com.engine.interfaces.display.ILoader;
	import com.engine.namespaces.coder;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	public class BingLoader extends URLLoader implements ILoader
	{
		private var _id:String;
		private var _oid:String;
		private var _proto:Object;
		private var _className:String;
		private var _name:String;
		private var _path:String;
		
		private var _successFunc:Function;
		private var _errorFunc:Function;
		private var _progressFunc:Function;

		public function BingLoader(request:URLRequest=null)
		{
			super(request);
			_id = Engine.getSoleId();
			WealthPool.addLoader(this);
		}

		public function unloadAndStop(gc:Boolean=true):void
		{
			this.close();
		}

		public function loadElemt(path:String, successFunc:Function=null, errorFunc:Function=null, progressFunc:Function=null, _arg_5:LoaderContext=null):void
		{
			_path = path;
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
			this.load(new URLRequest(path));
		}

		private function _successFunc_(evt:Event):void
		{
			_successFunc.apply(null, [this.path]);
			_successFunc = null;
			_progressFunc = null;
			_errorFunc = null;
			this.removeEventListener(Event.COMPLETE, _successFunc_);
			this.removeEventListener(IOErrorEvent.IO_ERROR, _errorFunc_);
			this.removeEventListener(ProgressEvent.PROGRESS, _progressFunc_);
		}

		private function _errorFunc_(evt:IOErrorEvent):void
		{
			_errorFunc.apply(null, [this.path]);
			_successFunc = null;
			_progressFunc = null;
			_errorFunc = null;
			this.removeEventListener(Event.COMPLETE, _successFunc_);
			this.removeEventListener(IOErrorEvent.IO_ERROR, _errorFunc_);
			this.removeEventListener(ProgressEvent.PROGRESS, _progressFunc_);
		}

		private function _progressFunc_(evt:ProgressEvent):void
		{
			_progressFunc.apply(null, [this.path, evt.bytesLoaded, evt.bytesTotal]);
		}

		public function get id():String
		{
			return _id;
		}

		public function get oid():String
		{
			return _oid;
		}
		coder function set oid(val:String):void
		{
			_oid = val;
		}

		public function set proto(val:Object):void
		{
			_proto = val;
		}
		public function get proto():Object
		{
			return _proto;
		}
		
		public function get className():String
		{
			return _className;
		}
		
		public function get name():String
		{
			return _name;
		}
		public function set name(value:String):void
		{
			_name = name;
		}
		
		public function get path():String
		{
			return _path;
		}

		public function clone():Object
		{
			throw new Error("不支持该方法");
		}
		
		override public function toString():String
		{
			return "[" + this.className + Engine.SIGN + this.id + "]";
		}

		public function dispose():void
		{
			this.removeEventListener(Event.COMPLETE, _successFunc_);
			this.removeEventListener(IOErrorEvent.IO_ERROR, _errorFunc_);
			this.removeEventListener(ProgressEvent.PROGRESS, _progressFunc_);
			_successFunc = null;
			_errorFunc = null;
			_progressFunc = null;
			
			WealthPool.removeLoader(this.id);
			_id = null;
			_oid = null;
			_proto = null;
		}

	}
}
