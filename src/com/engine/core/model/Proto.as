package com.engine.core.model
{
	import com.engine.core.Engine;
	import com.engine.interfaces.IProto;
	import com.engine.namespaces.coder;
	import com.engine.utils.ObjectUtils;
	
	import flash.net.registerClassAlias;
	import flash.utils.getQualifiedClassName;

	public class Proto implements IProto
	{
		private static var _className:String;

		protected var _id_:String;
		protected var _oid_:String;
		protected var _proto_:Object;

		public function Proto()
		{
			registerClassAlias("engine.save.Proto", Proto);
			_id_ = Engine.SIGN + Engine.getSoleId();
		}

		public function get oid():String
		{
			return _oid_;
		}
		coder function set oid(val:String):void
		{
			if (_oid_ != val) {
				_oid_ = val;
			}
		}

		public function get id():String
		{
			return _id_;
		}
		coder function set id(val:String):void
		{
			if (_id_ != val) {
				_id_ = val;
			}
		}

		public function get proto():Object
		{
			return _proto_;
		}
		public function set proto(val:Object):void
		{
			_proto_ = val;
		}
		
		public function get className():String
		{
			if (Proto._className == null) {
				Proto._className = getQualifiedClassName(this);
			}
			return Proto._className;
		}

		public function clone():Object
		{
			return ObjectUtils.copy(this);
		}

		public function dispose():void
		{
			_id_ = null;
			_oid_ = null;
			_proto_ = null;
		}

		public function toString():String
		{
			return "[" + this.className + Engine.SIGN + this.id + "]";
		}

	}
}
