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

		protected var $id:String;
		protected var $oid:String;
		protected var $proto:Object;

		public function Proto()
		{
			registerClassAlias("saiman.save.ProtoVo", Proto);
			$id = Core.SIGN + Core.coder::nextInstanceIndex().toString(16);
		}

		public function get oid():String
		{
			return $oid;
		}
		coder function set oid(val:String):void
		{
			if ($oid != val) {
				$oid = val;
			}
		}

		public function get id():String
		{
			return $id;
		}
		coder function set id(val:String):void
		{
			if ($id != val) {
				$id = val;
			}
		}

		public function get proto():Object
		{
			return $proto;
		}
		public function set proto(val:Object):void
		{
			$proto = val;
		}

		public function clone():IProto
		{
			return ObjectUtils.copy(this) as IProto;
		}

		public function dispose():void
		{
			$id = null;
			$oid = null;
			$proto = null;
		}

		public function toString():String
		{
			var kName:String = getQualifiedClassName(this);
			return "[" + kName.substr(kName.indexOf("::") + 2) + " " + this.id + "]";
		}

	}
}
