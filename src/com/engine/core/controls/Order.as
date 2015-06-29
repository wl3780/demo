package com.engine.core.controls
{
	import com.engine.core.model.Proto;
	
	import flash.net.registerClassAlias;

	public class Order extends Proto implements IOrder 
	{

		protected var $type:String;

		public function Order()
		{
			registerClassAlias("saiman.save.Order", Order);
		}

		public function set type(val:String):void
		{
			this.$type = val;
		}
		public function get type():String
		{
			return this.$type;
		}

		public function execute()
		{
			throw new Error("抽象方法，该方法需要子类实现");
		}

		public function callback(args:Array=null)
		{
			throw new Error("抽象方法，该方法需要子类实现");
		}

		override public function dispose():void
		{
			this.$type = null;
			super.dispose();
		}

	}
}
