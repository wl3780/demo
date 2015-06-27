// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.elisor.Elisor

package com.engine.core.controls.elisor
{
    import com.engine.core.model.Proto;
    import com.engine.namespaces.coder;
    import com.engine.core.controls.IOrder;
    import __AS3__.vec.Vector;
    import __AS3__.vec.*;

    public class Elisor extends Proto 
    {

        private static var _instance:Elisor;

        private var _EventElisor:EventElisor;
        private var _FrameElisor:FrameElisor;


        public static function getInstance():Elisor
        {
            if (_instance == null){
                _instance = new (Elisor)();
                _instance.initialize();
            };
            return (_instance);
        }


        public function initialize():void
        {
            this._EventElisor = EventElisor.coder::getInstance();
            this._FrameElisor = FrameElisor.coder::getInstance();
        }

        public function createEventOrder(_arg_1:String, _arg_2:String, _arg_3:Function):EventOrder
        {
            var _local_4 = new EventOrder();
            _local_4.register(_arg_1, _arg_2, _arg_3);
            return (_local_4);
        }

        public function createFrameOrder(_arg_1:String, _arg_2:int, _arg_3:Function, _arg_4:Array=null, _arg_5:Function=null, _arg_6:int=-1):FrameOrder
        {
            if (_arg_3 == null){
                throw (new Error("action 不能为 null"));
            };
            var _local_7 = new FrameOrder();
            _local_7.setUp(_arg_1, _arg_2, _arg_6);
            _local_7.register(_arg_3, _arg_4, _arg_5);
            return (_local_7);
        }

        public function setTimeOut(_arg_1:String, _arg_2:int, _arg_3:Function, _arg_4:Array):FrameOrder
        {
            var _local_5 = new FrameOrder();
            _local_5.setUp(_arg_1, 20, _arg_2);
            _local_5.setTimeOut(_arg_3, _arg_4);
            return (_local_5);
        }

        public function addOrder(_arg_1:IOrder, _arg_2:Boolean=false):Boolean
        {
            switch (_arg_1.type){
                case OrderMode.EVENT_ORDER:
                    return (this._EventElisor.addOrder((_arg_1 as EventOrder)));
                case OrderMode.FRAME_ORDER:
                    return (this._FrameElisor.addOrder((_arg_1 as FrameOrder)));
            };
            return (false);
        }

        public function removeOrder(_arg_1:String, _arg_2:String):IOrder
        {
            switch (_arg_1){
                case OrderMode.EVENT_ORDER:
                    return (this._EventElisor.removeOrder(_arg_1));
                case OrderMode.FRAME_ORDER:
                    return (this._FrameElisor.removeOrder(_arg_1));
            };
            return (null);
        }

        public function hasOrder(_arg_1:String, _arg_2:String):Boolean
        {
            switch (_arg_1){
                case OrderMode.EVENT_ORDER:
                    return (this._EventElisor.hasOrder(_arg_1));
                case OrderMode.FRAME_ORDER:
                    return (this._FrameElisor.hasOrder(_arg_1));
            };
            return (false);
        }

        public function takeOrder(_arg_1:String, _arg_2:String):IOrder
        {
            switch (_arg_1){
                case OrderMode.EVENT_ORDER:
                    return (this._EventElisor.takeOrder(_arg_1));
                case OrderMode.FRAME_ORDER:
                    return (this._FrameElisor.takeOrder(_arg_1));
            };
            return (null);
        }

        public function hasGroup(_arg_1:String, _arg_2:String="total"):Boolean
        {
            switch (_arg_2){
                case OrderMode.TOTAL:
                    return (((this._EventElisor.hasGroup(_arg_1)) || (this._FrameElisor.hasGroup(_arg_1))));
                case OrderMode.EVENT_ORDER:
                    return (this._EventElisor.hasGroup(_arg_1));
                case OrderMode.FRAME_ORDER:
                    return (this._FrameElisor.hasGroup(_arg_1));
            };
            return (false);
        }

        public function takeGroupOrders(_arg_1:String, _arg_2:String="total"):Vector.<IOrder>
        {
            var _local_3:Vector.<IOrder>;
            switch (_arg_2){
                case OrderMode.TOTAL:
                    _local_3 = new Vector.<IOrder>();
                    _local_3 = _local_3.concat(this._EventElisor.takeGroupOrder(_arg_1));
                    _local_3.concat(this._FrameElisor.takeGroupOrder(_arg_1));
                    return (_local_3);
                case OrderMode.EVENT_ORDER:
                    return (this._EventElisor.takeGroupOrder(_arg_1));
                case OrderMode.FRAME_ORDER:
                    return (this._FrameElisor.takeGroupOrder(_arg_1));
            };
            return (null);
        }

        public function disposeGroupOrders(_arg_1:String, _arg_2:String="total"):Vector.<IOrder>
        {
            var _local_3:Vector.<IOrder>;
            switch (_arg_2){
                case OrderMode.TOTAL:
                    _local_3 = new Vector.<IOrder>();
                    _local_3 = _local_3.concat(this._EventElisor.disposeGroupOrders(_arg_1));
                    return (_local_3.concat(this._FrameElisor.disposeGroupOrders(_arg_1)));
                case OrderMode.EVENT_ORDER:
                    return (this._EventElisor.disposeGroupOrders(_arg_1));
                case OrderMode.FRAME_ORDER:
                    return (this._FrameElisor.disposeGroupOrders(_arg_1));
            };
            return (null);
        }

        override public function dispose():void
        {
            this._EventElisor.dispose();
            this._FrameElisor.dispose();
            this._EventElisor = null;
            this._FrameElisor = null;
            super.dispose();
            _instance = null;
        }


    }
}//package com.engine.core.controls.elisor

