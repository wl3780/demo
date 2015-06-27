// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.elisor.FrameElisor

package com.engine.core.controls.elisor
{
    import com.engine.core.model.Proto;
    import flash.utils.Dictionary;
    import com.engine.namespaces.coder;
    import com.engine.core.controls.IOrder;
    import __AS3__.vec.Vector;
    import __AS3__.vec.*;

    use namespace coder;

    public class FrameElisor extends Proto 
    {

        private static var _instance:FrameElisor;

        private var _owners:Dictionary;
        private var _quenes:Dictionary;
        private var _orders:Dictionary;
        private var _len:int;


        coder static function getInstance():FrameElisor
        {
            if (_instance == null){
                _instance = new (FrameElisor)();
                _instance.initialize();
            };
            return (_instance);
        }


        public function initialize():void
        {
            this._owners = new Dictionary();
            this._quenes = new Dictionary();
            this._orders = new Dictionary();
        }

        public function addOrder(_arg_1:FrameOrder, _arg_2:Boolean=false):Boolean
        {
            var _local_6:DeayQuene;
            if (_arg_1 == null){
                return (false);
            };
            var _local_3:String = _arg_1.oid;
            var _local_4:String = _arg_1.id;
            var _local_5:String = _arg_1.delay.toString();
            if (((((_local_3) && (_local_4))) && (_local_5))){
                if (this._owners[_local_3] == null){
                    this._owners[_local_3] = new Dictionary();
                };
                if (this._quenes[_local_5] == null){
                    _local_6 = new DeayQuene(_arg_1.delay);
                    this._quenes[_local_5] = _local_6;
                };
                _local_6 = this._quenes[_local_5];
                _local_6.addOrder(_arg_1);
                this._owners[_local_3][_local_4] = (this._orders[_local_4] = _arg_1);
                this._len++;
                return (true);
            };
            return (false);
        }

        public function stopOrder(_arg_1:String):void
        {
            var _local_2:FrameOrder = (this._orders[_arg_1] as FrameOrder);
            if (_local_2){
                _local_2.stop = false;
            };
        }

        public function startOrder(_arg_1:String):void
        {
            var _local_2:FrameOrder = (this._orders[_arg_1] as FrameOrder);
            if (_local_2){
                _local_2.stop = true;
            };
        }

        public function removeOrder(_arg_1:String):FrameOrder
        {
            var _local_2:FrameOrder;
            var _local_3:Dictionary;
            var _local_4:DeayQuene;
            var _local_5:FrameOrder;
            if (this._orders[_arg_1]){
                _local_2 = (this._orders[_arg_1] as FrameOrder);
                _local_2.stop = true;
                delete this._orders[_arg_1];
                if (this._owners[_local_2.oid]){
                    delete this._owners[_local_2.oid][_arg_1];
                };
                _local_3 = this._owners[_local_2.oid];
                _local_4 = (this._quenes[_local_2.delay.toString()] as DeayQuene);
                if (_local_4){
                    _local_4.removeOrder(_arg_1);
                };
                this._len--;
                for each (_local_5 in _local_3) {
                    _local_2.dispose();
                    return (_local_2);
                };
                delete this._owners[_local_2.oid];
                _local_2.dispose();
                return (_local_2);
            };
            return (null);
        }

        public function hasOrder(_arg_1:String):Boolean
        {
            if (this._orders[_arg_1]){
                return (true);
            };
            return (false);
        }

        public function removeQuene(_arg_1:String):void
        {
            delete this._quenes[_arg_1];
        }

        public function hasQuene(_arg_1:String):Boolean
        {
            if (this._quenes[_arg_1]){
                return (true);
            };
            return (false);
        }

        public function takeQuene(_arg_1:String):DeayQuene
        {
            return (this._quenes[_arg_1]);
        }

        public function takeOrder(_arg_1:String):FrameOrder
        {
            return ((this._orders[_arg_1] as FrameOrder));
        }

        public function hasGroup(_arg_1:String):Boolean
        {
            if (this._owners[_arg_1]){
                return (true);
            };
            return (false);
        }

        public function takeGroupOrder(_arg_1:String):Vector.<IOrder>
        {
            var _local_3:IOrder;
            var _local_2:Vector.<IOrder> = new Vector.<IOrder>();
            if (this._owners[_arg_1]){
                for each (_local_3 in this._owners[_arg_1]) {
                    _local_2.push(_local_3);
                };
            };
            return (_local_2);
        }

        public function disposeGroupOrders(_arg_1:String):Vector.<IOrder>
        {
            var _local_3:String;
            var _local_4:FrameOrder;
            var _local_2:Vector.<IOrder> = new Vector.<IOrder>();
            if (this._owners[_arg_1]){
                for (_local_3 in this._owners[_arg_1]) {
                    _local_4 = this._owners[_arg_1][_local_3];
                    _local_4.stop;
                    _local_4.dispose();
                    _local_2.push((_local_4 as IOrder));
                    this._len++;
                };
                delete this._owners[_arg_1];
            };
            return (_local_2);
        }

        public function chageDeay(_arg_1:String, _arg_2:int):Boolean
        {
            var _local_4:DeayQuene;
            var _local_5:DeayQuene;
            var _local_3:FrameOrder = (this._orders[_arg_1] as FrameOrder);
            if (_local_3){
                _local_4 = (this._quenes[_local_3.delay.toString()] as DeayQuene);
                if (_local_4){
                    if (_local_4.delay == _local_3.delay){
                        _local_4.removeOrder(_arg_1);
                    };
                    _local_3.coder::delay = _arg_2;
                    if (this._quenes[_arg_2.toString()]){
                        DeayQuene(this._quenes[_arg_2.toString()]).addOrder(_local_3);
                    } else {
                        _local_5 = new DeayQuene(_arg_2);
                        this._quenes[_arg_2] = _local_4;
                        _local_5.addOrder(_local_3);
                    };
                } else {
                    _local_3.coder::delay = _arg_2;
                    _local_5 = new DeayQuene(_arg_2);
                    this._quenes[_arg_2] = _local_4;
                    _local_5.addOrder(_local_3);
                };
                return (true);
            };
            return (false);
        }

        override public function dispose():void
        {
            var _local_1:String;
            var _local_2:FrameOrder;
            var _local_3:DeayQuene;
            _instance = null;
            for (_local_1 in this._quenes) {
                _local_3 = this._quenes[_local_1];
                _local_3.dispose();
                delete this._quenes[_local_1];
            };
            this._quenes = null;
            for each (_local_2 in this._orders) {
                _local_2.dispose();
            };
            this._orders = null;
            this._owners = null;
            this._len = 0;
            super.dispose();
        }


    }
}//package com.engine.core.controls.elisor

