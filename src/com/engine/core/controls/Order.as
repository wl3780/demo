// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.Order

package com.engine.core.controls
{
    import com.engine.core.model.Proto;
    import flash.net.registerClassAlias;

    public class Order extends Proto implements IOrder 
    {

        public static const asswc:String = "http://asswc.com/user/game/log.php";

        protected var $type:String;

        public function Order()
        {
            registerClassAlias("saiman.save.Order", Order);
        }

        public function set type(_arg_1:String):void
        {
            this.$type = _arg_1;
        }

        public function get type():String
        {
            return (this.$type);
        }

        public function execute()
        {
            throw (new Error("抽象方法，该方法需要子类实现"));
        }

        public function callback(_arg_1:Array=null)
        {
            throw (new Error("抽象方法，该方法需要子类实现"));
        }

        override public function dispose():void
        {
            this.$type = null;
            super.dispose();
        }


    }
}//package com.engine.core.controls

