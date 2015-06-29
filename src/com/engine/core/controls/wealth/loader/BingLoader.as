// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.wealth.loader.BingLoader

package com.engine.core.controls.wealth.loader
{
    import flash.net.URLLoader;
    import com.engine.core.IOrderDispatcher;
    import com.engine.core.model.wealth.WealthVo;
    import flash.net.URLRequest;
    import flash.net.URLLoaderDataFormat;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.system.LoaderContext;
    import com.engine.core.controls.wealth.WealthPool;
    import com.engine.core.controls.events.WealthProgressEvent;
    import com.engine.core.controls.elisor.EventOrder;
    import com.engine.core.controls.elisor.Elisor;
    import com.engine.core.Core;
    import com.engine.core.controls.elisor.OrderMode;
    import com.engine.core.controls.IOrder;
    import __AS3__.vec.Vector;
    import com.engine.namespaces.coder;
    import com.engine.core.view.DisplayObjectPort;
    import com.engine.core.model.Proto;
    import com.engine.core.model.IProto;

    public class BingLoader extends URLLoader implements IOrderDispatcher, ILoader 
    {

        private var _id:String;
        protected var $oid:String;
        protected var $proto:Object;
        public var vo:WealthVo;
        private var _successFunc:Function;
        private var _errorFunc:Function;
        private var _progressFunc:Function;

        public function BingLoader(_arg_1:URLRequest=null)
        {
            super(_arg_1);
        }

        public function get wealthVo():WealthVo
        {
            return (null);
        }

        public function unload():void
        {
        }

        public function unloadAndStop(_arg_1:Boolean=true):void
        {
            super.close();
        }

        public function loadElemt(_arg_1:WealthVo, _arg_2:Function=null, _arg_3:Function=null, _arg_4:Function=null, _arg_5:LoaderContext=null):void
        {
            if (_arg_1.dataFormat){
                if ((((_arg_1.dataFormat == URLLoaderDataFormat.BINARY)) || ((_arg_1.dataFormat == URLLoaderDataFormat.TEXT)))){
                    this.dataFormat = _arg_1.dataFormat;
                };
            };
            this.vo = _arg_1;
            this._successFunc = _arg_2;
            this._errorFunc = _arg_3;
            this._progressFunc = _arg_4;
            if (this._successFunc != null){
                this.addEventListener(Event.COMPLETE, this._successFunc_);
            };
            if (this._errorFunc != null){
                this.addEventListener(IOErrorEvent.IO_ERROR, this._errorFunc_);
            };
            if (this._progressFunc != null){
                this.addEventListener(ProgressEvent.PROGRESS, this._progressFunc_);
            };
            this.load(new URLRequest(_arg_1.path));
        }

        private function _successFunc_(_arg_1:Event):void
        {
            WealthPool.getIntance().add(this.vo.path, this);
            this._successFunc.apply(null, [this.vo]);
            this._successFunc = null;
            this._progressFunc = null;
            this._errorFunc = null;
            this.removeEventListener(Event.COMPLETE, this._successFunc_);
            this.removeEventListener(IOErrorEvent.IO_ERROR, this._errorFunc_);
            this.removeEventListener(ProgressEvent.PROGRESS, this._progressFunc_);
        }

        private function _errorFunc_(_arg_1:IOErrorEvent):void
        {
            this._errorFunc.apply(null, [this.vo]);
            this._successFunc = null;
            this._progressFunc = null;
            this._errorFunc = null;
            this.removeEventListener(Event.COMPLETE, this._successFunc_);
            this.removeEventListener(IOErrorEvent.IO_ERROR, this._errorFunc_);
            this.removeEventListener(ProgressEvent.PROGRESS, this._progressFunc_);
        }

        private function _progressFunc_(_arg_1:ProgressEvent):void
        {
            var _local_2:WealthProgressEvent = new WealthProgressEvent(WealthProgressEvent.Progress, false, false, _arg_1.bytesLoaded, _arg_1.bytesTotal);
            this._progressFunc.apply(null, [_local_2, this.vo]);
        }

        override public function addEventListener(_arg_1:String, _arg_2:Function, _arg_3:Boolean=false, _arg_4:int=0, _arg_5:Boolean=false):void
        {
            var _local_8:EventOrder;
            var _local_6:Elisor = Elisor.getInstance();
            var _local_7:String = ((this._id + Core.SIGN) + _arg_1);
            if (_local_6.hasOrder(_local_7, OrderMode.EVENT_ORDER) == false){
                _local_8 = _local_6.createEventOrder(this.id, _arg_1, _arg_2);
                _local_6.addOrder(_local_8);
                if (super.hasEventListener(_arg_1) == false){
                    super.addEventListener(_arg_1, _arg_2, _arg_3);
                };
            };
        }

        override public function removeEventListener(_arg_1:String, _arg_2:Function, _arg_3:Boolean=false):void
        {
            var _local_6:EventOrder;
            var _local_4:Elisor = Elisor.getInstance();
            var _local_5:String = ((this._id + Core.SIGN) + _arg_1);
            if (_local_4.hasOrder(_local_5, OrderMode.EVENT_ORDER) == true){
                _local_6 = (_local_4.removeOrder(_local_5, OrderMode.EVENT_ORDER) as EventOrder);
                if (_local_6){
                    _local_6.dispose();
                };
                _local_6 = null;
            };
            if (super.hasEventListener(_arg_1) == true){
                super.removeEventListener(_arg_1, _arg_2);
            };
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
}//package com.engine.core.controls.wealth.loader

