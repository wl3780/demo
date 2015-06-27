// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.elisor.EventOrder

package com.engine.core.controls.elisor
{
    import com.engine.core.controls.Order;
    import flash.net.registerClassAlias;
    import com.engine.core.Core;
    import com.engine.namespaces.coder;
    import com.engine.core.view.DisplayObjectPort;
    import com.engine.core.IOrderDispatcher;

    public class EventOrder extends Order 
    {

        public var _listener:Function;
        public var listenerType:String;

        public function EventOrder()
        {
            registerClassAlias("saiman.save.EventOrder", EventOrder);
            this.$type = OrderMode.EVENT_ORDER;
        }

        public function register(_arg_1:String, _arg_2:String, _arg_3:Function):void
        {
            this._listener = _arg_3;
            this.listenerType = _arg_2;
            this.$oid = _arg_1;
            this.$id = ((this.$oid + Core.SIGN) + _arg_2);
        }

        override public function dispose():void
        {
            var _local_1:IOrderDispatcher = DisplayObjectPort.coder::getInstance().task(this.oid);
            if (_local_1){
                _local_1.removeEventListener(this.listenerType, this._listener);
                _local_1 = null;
            };
            this._listener = null;
            this.listenerType = null;
            this.$id = null;
            this.$oid = null;
            super.dispose();
        }

        override public function execute()
        {
            this.activate();
        }

        public function activate():void
        {
            var _local_1:IOrderDispatcher = DisplayObjectPort.coder::getInstance().task(this.oid);
            if (_local_1){
                _local_1.addEventListener(this.$id, this._listener);
                _local_1 = null;
            };
        }

        public function unactivate():void
        {
            var _local_1:IOrderDispatcher = DisplayObjectPort.coder::getInstance().task(this.oid);
            if (_local_1){
                _local_1.removeEventListener(this.$id, this._listener);
                _local_1 = null;
            };
        }


    }
}//package com.engine.core.controls.elisor

