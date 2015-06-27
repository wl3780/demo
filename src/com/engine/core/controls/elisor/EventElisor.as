// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.elisor.EventElisor

package com.engine.core.controls.elisor
{
    import com.engine.core.model.Proto;
    import flash.utils.Dictionary;
    import com.engine.namespaces.coder;
    import com.engine.core.Core;
    import com.engine.core.controls.IOrder;
    import __AS3__.vec.Vector;
    import __AS3__.vec.*;

    use namespace coder;

    public class EventElisor extends Proto 
    {

        private static var _instance:EventElisor;

        private var _hash:Dictionary;
        private var _len:int;


        coder static function getInstance():EventElisor
        {
            if (_instance == null){
                _instance = new (EventElisor)();
                _instance.initialize();
            };
            return (_instance);
        }


        public function get len():int
        {
            return (this._len);
        }

        public function initialize():void
        {
            this._hash = new Dictionary();
        }

        public function addOrder(_arg_1:EventOrder, _arg_2:Boolean=false):Boolean
        {
            if (_arg_1 == null){
                return (false);
            };
            if ((((_arg_1.type == null)) || ((_arg_1.oid == null)))){
                return (false);
            };
            if (this._hash[_arg_1.oid] == null){
                this._hash[_arg_1.oid] = new Dictionary();
            };
            if (this._hash[_arg_1.oid][_arg_1.type] == null){
                this._hash[_arg_1.oid][_arg_1.type] = _arg_1;
                this._len++;
            } else {
                if (((_arg_2) && (this._hash[_arg_1.oid][_arg_1.type]))){
                    delete this._hash[_arg_1.oid][_arg_1.type];
                    this._hash[_arg_1.oid][_arg_1.type] = _arg_1;
                };
            };
            return (true);
        }

        public function removeOrder(_arg_1:String):EventOrder
        {
            if (this._hash == null){
                return (null);
            };
            var _local_2:Array = _arg_1.split(Core.SIGN);
            if (_local_2.length != 2){
                return (null);
            };
            var _local_3:String = _local_2[0];
            var _local_4:String = _local_2[1];
            if (this._hash[_local_3] == null){
                return (null);
            };
            return ((this._hash[_local_3][_local_4] as EventOrder));
        }

        public function hasOrder(_arg_1:String):Boolean
        {
            if (this._hash == null){
                return (false);
            };
            var _local_2:Array = _arg_1.split(Core.SIGN);
            if (_local_2.length != 2){
                return (false);
            };
            var _local_3:String = _local_2[0];
            var _local_4:String = _local_2[1];
            if (this._hash[_local_3] == null){
                return (false);
            };
            if (this._hash[_local_3][_local_4] == null){
                return (false);
            };
            return (true);
        }

        public function takeOrder(_arg_1:String):EventOrder
        {
            if (this._hash == null){
                return (null);
            };
            var _local_2:Array = _arg_1.split(Core.SIGN);
            if (_local_2.length != 2){
                return (null);
            };
            var _local_3:String = _local_2[0];
            var _local_4:String = _local_2[1];
            if (this._hash[_local_3] == null){
                return (null);
            };
            return ((this._hash[_local_3][_local_4] as EventOrder));
        }

        public function hasGroup(_arg_1:String):Boolean
        {
            if (this._hash == null){
                return (false);
            };
            if (this._hash[_arg_1] != null){
                return (true);
            };
            return (false);
        }

        public function takeGroupOrder(_arg_1:String):Vector.<IOrder>
        {
            var _local_4:EventOrder;
            var _local_2:Vector.<IOrder> = new Vector.<IOrder>();
            if (this._hash == null){
                return (_local_2);
            };
            if (this._hash[_arg_1] == null){
                return (_local_2);
            };
            var _local_3:Dictionary = this._hash[_arg_1];
            for each (_local_4 in _local_3) {
                _local_2.push(_local_4);
            };
            return (_local_2);
        }

        public function disposeGroupOrders(_arg_1:String):Vector.<IOrder>
        {
            var _local_4:EventOrder;
            var _local_2:Vector.<IOrder> = new Vector.<IOrder>();
            if (this._hash == null){
                return (_local_2);
            };
            if (this._hash[_arg_1] == null){
                return (_local_2);
            };
            var _local_3:Dictionary = this._hash[_arg_1];
            delete this._hash[_arg_1];
            for each (_local_4 in _local_3) {
                _local_2.push(_local_4);
            };
            return (_local_2);
        }

        override public function dispose():void
        {
            var _local_1:String;
            if (this._hash){
                for (_local_1 in this._hash) {
                    delete this._hash[_local_1];
                };
            };
            this._hash = null;
            _instance = null;
            super.dispose();
        }


    }
}//package com.engine.core.controls.elisor

