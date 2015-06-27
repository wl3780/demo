package com.engine.core.model
{
	import com.engine.core.Core;
	import com.engine.namespaces.coder;
	import com.engine.utils.ObjectUtils;
	
	import flash.net.registerClassAlias;
	import flash.utils.getQualifiedClassName;

	use namespace coder;

	public class Proto implements IProto 
	{

		protected var _id:String;
		protected var _oid:String;
		protected var _proto:Object;

		public function Proto()
		{
			registerClassAlias("saiman.save.ProtoVo", Proto);
			_id = Core.SIGN + Core.coder::nextInstanceIndex().toString(16);
		}

		public function get oid():String
		{
			return _oid;
		}
		coder function set oid(val:String):void
		{
			if (_oid != val) {
				_oid = val;
			}
		}

		public function get id():String
		{
			return _id;
		}
		coder function set id(val:String):void
		{
			if (_id != val) {
				_id = val;
			}
		}

		public function get proto():Object
		{
			return _proto;
		}
		public function set proto(val:Object):void
		{
			_proto = val;
		}

		public function clone():IProto
		{
			return ObjectUtils.copy(this) as IProto;
		}

		public function dispose():void
		{
			_id = null;
			_oid = null;
			_proto = null;
		}

		public function toString():String
		{
			var kName:String = getQualifiedClassName(this);
			return "[" + kName.substr(kName.indexOf("::") + 2) + " " + this.id + "]";
		}

	}
}
