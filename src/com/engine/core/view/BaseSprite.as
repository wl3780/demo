// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.BaseSprite

package com.engine.core.view
{
    import flash.display.Sprite;
    import com.engine.namespaces.coder;
    import com.engine.core.Core;
    import com.engine.core.controls.elisor.EventOrder;
    import com.engine.core.controls.elisor.Elisor;
    import com.engine.core.controls.elisor.OrderMode;
    import com.engine.core.controls.elisor.FrameOrder;
    import com.engine.core.controls.IOrder;
    import __AS3__.vec.Vector;
    import com.engine.core.model.Proto;
    import com.engine.core.model.IProto;

    use namespace coder;

    public class BaseSprite extends Sprite implements IBaseSprite 
    {

        private var _id:String;
        protected var $oid:String;
        protected var $proto:Object;

        public function BaseSprite()
        {
            this._id = Core.coder::nextInstanceIndex().toString(16);
            DisplayObjectPort.coder::getInstance().put(this);
        }

        override public function addEventListener(_arg_1:String, _arg_2:Function, _arg_3:Boolean=false, _arg_4:int=0, _arg_5:Boolean=false):void
        {
            var _local_8:EventOrder;
            if (!Core.sandBoxEnabled){
                return;
            };
            var _local_6:Elisor = Elisor.getInstance();
            var _local_7:String = ((this._id + Core.SIGN) + _arg_1);
            if (_local_6.hasOrder(_local_7, OrderMode.EVENT_ORDER) == false){
                _local_8 = _local_6.createEventOrder(this.id, _arg_1, _arg_2);
                _local_6.addOrder(_local_8);
                super.addEventListener(_arg_1, _arg_2, _arg_3);
            };
        }

        override public function removeEventListener(_arg_1:String, _arg_2:Function, _arg_3:Boolean=false):void
        {
            var _local_6:EventOrder;
            if (!Core.sandBoxEnabled){
                return;
            };
            var _local_4:Elisor = Elisor.getInstance();
            var _local_5:String = ((this._id + Core.SIGN) + _arg_1);
            if (_local_4.hasOrder(_local_5, OrderMode.EVENT_ORDER) == true){
                _local_6 = (_local_4.removeOrder(_local_5, OrderMode.EVENT_ORDER) as EventOrder);
                if (_local_6){
                    _local_6.dispose();
                };
                _local_6 = null;
            };
            super.removeEventListener(_arg_1, _arg_2);
        }

        public function _setTimeOut_(_arg_1:int, _arg_2:Function, _arg_3:Array):void
        {
            var _local_4:Elisor = Elisor.getInstance();
            var _local_5:FrameOrder = _local_4.setTimeOut(this.id, _arg_1, _arg_2, _arg_3);
            _local_4.addOrder(_local_5);
            _local_5.start();
        }

        public function onTimer(_arg_1:int, _arg_2:Function, _arg_3:Array, _arg_4:Function=null):FrameOrder
        {
            var _local_5:Elisor = Elisor.getInstance();
            var _local_6:FrameOrder = _local_5.createFrameOrder(this.id, _arg_1, _arg_2, _arg_3, _arg_4, -1);
            _local_5.addOrder(_local_6);
            _local_6.start();
            return (_local_6);
        }

        public function initialize():void
        {
        }

        public function takeOrder(_arg_1:String, _arg_2:String):IOrder
        {
            var _local_3:Elisor = Elisor.getInstance();
            return (_local_3.takeOrder(_arg_1, _arg_2));
        }

        public function hasOrder(_arg_1:String, _arg_2:String):Boolean
        {
            var _local_3:Elisor = Elisor.getInstance();
            return (_local_3.hasOrder(_arg_1, _arg_2));
        }

        public function removeOrder(_arg_1:String, _arg_2:String):IOrder
        {
            var _local_3:Elisor = Elisor.getInstance();
            return (_local_3.removeOrder(_arg_1, _arg_2));
        }

        public function addOrder(_arg_1:IOrder):Boolean
        {
            var _local_2:Elisor = Elisor.getInstance();
            return (_local_2.addOrder(_arg_1));
        }

        public function takeGroupOrders(_arg_1:String):Vector.<IOrder>
        {
            var _local_2:Elisor = Elisor.getInstance();
            return (_local_2.takeGroupOrders(this._id, _arg_1));
        }

        public function disposeGroupOrders(_arg_1:String):Vector.<IOrder>
        {
            var _local_2:Elisor = Elisor.getInstance();
            return (_local_2.disposeGroupOrders(this._id, _arg_1));
        }

        coder function set id(_arg_1:String):void
        {
            DisplayObjectPort.coder::getInstance().remove(this._id);
            var _local_2:Vector.<IOrder> = Elisor.getInstance().disposeGroupOrders(this._id);
            this._id = _arg_1;
            DisplayObjectPort.coder::getInstance().put(this);
            var _local_3:int;
            while (_local_3 < _local_2.length) {
                if (_local_2[_local_3]){
                    Elisor.getInstance().addOrder(_local_2[_local_3]);
                };
                _local_3++;
            };
        }

        public function get id():String
        {
            return (this._id);
        }

        public function set proto(_arg_1:Object):void
        {
            this.$proto = _arg_1;
        }

        public function get proto():Object
        {
            return (this.$proto);
        }

        public function set oid(_arg_1:String):void
        {
            this.$oid = _arg_1;
        }

        public function get oid():String
        {
            return (this.$oid);
        }

        public function clone():IProto
        {
            var _local_1:Proto = new Proto();
            _local_1.coder::id = this._id;
            _local_1.coder::oid = this.$oid;
            _local_1.proto = this.$proto;
            return (_local_1);
        }

        public function dispose():void
        {
            var _local_2:int;
            var _local_3:IOrder;
            if (!Core.sandBoxEnabled){
                return;
            };
            if (graphics){
                this.graphics.clear();
            };
            if (this.parent){
                this.parent.removeChild(this);
            };
            var _local_1:Vector.<IOrder> = this.disposeGroupOrders(OrderMode.TOTAL);
            if (_local_1){
                _local_2 = 0;
                while (_local_2 < _local_1.length) {
                    _local_3 = _local_1[_local_2];
                    if (_local_3){
                        _local_3.dispose();
                    };
                    _local_3 = null;
                    _local_2++;
                };
            };
            DisplayObjectPort.coder::getInstance().remove(this._id);
            _local_1 = null;
            this._id = null;
            this.$oid = null;
            this.$proto = null;
        }


    }
}//package com.engine.core.view

