// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.wealth.loader.DisplayLoader

package com.engine.core.controls.wealth.loader
{
    import flash.display.Loader;
    import com.engine.core.IOrderDispatcher;
    import com.engine.core.model.wealth.WealthVo;
    import flash.system.LoaderContext;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.net.URLRequest;
    import com.engine.core.Core;
    import com.engine.core.controls.wealth.WealthPool;
    import flash.events.ErrorEvent;
    import com.engine.core.controls.events.WealthProgressEvent;
    import com.engine.core.controls.elisor.EventOrder;
    import com.engine.core.controls.elisor.Elisor;
    import com.engine.core.controls.elisor.OrderMode;
    import com.engine.core.controls.IOrder;
    import __AS3__.vec.Vector;
    import com.engine.namespaces.coder;
    import com.engine.core.view.DisplayObjectPort;
    import com.engine.core.model.Proto;
    import com.engine.core.model.IProto;

    public class DisplayLoader extends Loader implements IOrderDispatcher, ILoader 
    {

        private var _id:String;
        protected var $oid:String;
        protected var $proto:Object;
        public var vo:WealthVo;
        private var _successFunc:Function;
        private var _errorFunc:Function;
        private var _progressFunc:Function;


        public function get wealthVo():WealthVo
        {
            return (null);
        }

        override public function unloadAndStop(_arg_1:Boolean=true):void
        {
            super.unloadAndStop(_arg_1);
        }

        public function loadElemt(vo:WealthVo, successFunc:Function=null, errorFunc:Function=null, progressFunc:Function=null, loaderContext:LoaderContext=null):void
        {
            var lc:LoaderContext;
            this.vo = vo;
            this._successFunc = successFunc;
            this._errorFunc = errorFunc;
            this._progressFunc = progressFunc;
            if (this._successFunc != null){
                this.contentLoaderInfo.addEventListener(Event.COMPLETE, this._successFunc_);
            };
            if (this._errorFunc != null){
                this.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this._errorFunc_);
            };
            if (this._progressFunc != null){
                this.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, this._progressFunc_);
            };
            try {
                this.load(new URLRequest(vo.path), loaderContext);
            } catch(e:Error) {
                lc = new LoaderContext(false, Core.stage.loaderInfo.applicationDomain);
                this.load(new URLRequest(vo.path), lc);
            };
        }

        private function _successFunc_(_arg_1:Event):void
        {
            WealthPool.getIntance().add(this.vo.path, this);
            this._successFunc.apply(null, [this.vo]);
            this._successFunc = null;
            this._progressFunc = null;
            this._errorFunc = null;
            this.contentLoaderInfo.removeEventListener(Event.COMPLETE, this._successFunc_);
            this.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this._errorFunc_);
            this.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, this._progressFunc_);
        }

        private function _errorFunc_(_arg_1:ErrorEvent):void
        {
            this._errorFunc.apply(null, [this.vo]);
            this._successFunc = null;
            this._progressFunc = null;
            this._errorFunc = null;
            this.contentLoaderInfo.removeEventListener(Event.COMPLETE, this._successFunc_);
            this.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this._errorFunc_);
            this.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, this._progressFunc_);
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
            this.contentLoaderInfo.removeEventListener(Event.COMPLETE, this._successFunc_);
            this.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this._errorFunc_);
            this.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, this._progressFunc_);
            this.contentLoaderInfo.addEventListener(Event.UNLOAD, this.unloadFunc);
            this._successFunc = null;
            this._progressFunc = null;
            this._errorFunc = null;
            this.vo = null;
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
            this.unloadAndStop();
        }

        private function unloadFunc(_arg_1:Event):void
        {
            this.contentLoaderInfo.removeEventListener(Event.UNLOAD, this.unloadFunc);
        }


    }
}//package com.engine.core.controls.wealth.loader

