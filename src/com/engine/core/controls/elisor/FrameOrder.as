// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.elisor.FrameOrder

package com.engine.core.controls.elisor
{
    import com.engine.core.controls.Order;
    import flash.net.registerClassAlias;
    import com.engine.namespaces.coder;
    import com.engine.core.Core;

    use namespace coder;

    public class FrameOrder extends Order 
    {

        private var _applyFunc:Function;
        private var _arguments:Array;
        private var _callbackFunc:Function;
        private var _timeOutFunc:Function;
        private var _timeOutargs:Array;
        private var _stop:Boolean;
        private var _startTime:Number;
        private var _between:int;
        private var _delay:int;

        public function FrameOrder()
        {
            registerClassAlias("saiman.save.FrameOrder", FrameOrder);
            this.$type = OrderMode.FRAME_ORDER;
            this.$id = Core.coder::nextInstanceIndex().toString(16);
            this._stop = true;
        }

        public function get delay():int
        {
            return (this._delay);
        }

        coder function set delay(_arg_1:int):void
        {
            this._delay = _arg_1;
        }

        public function set delay(_arg_1:int):void
        {
            if (this._delay != _arg_1){
                if (FrameElisor.coder::getInstance().chageDeay(this.$id, _arg_1) == false){
                    this._delay = _arg_1;
                };
            };
        }

        public function setUp(_arg_1:String, _arg_2:int, _arg_3:int=-1):void
        {
            if ((_arg_1 == null)){
                this.$oid = Core.coder::nextInstanceIndex().toString(16);
            } else {
                this.$oid = _arg_1;
            };
            this.$oid = _arg_1;
            this._delay = _arg_2;
            this._between = _arg_3;
        }

        public function setTimeOut(_arg_1:Function, _arg_2:Array):void
        {
            this._timeOutFunc = _arg_1;
            this._timeOutargs = _arg_2;
        }

        public function register(_arg_1:Function, _arg_2:Array, _arg_3:Function=null):void
        {
            if (_arg_1 != null){
                this._applyFunc = _arg_1;
            };
            if ((_arg_2 == null)){
                _arg_2 = [];
            };
            this._arguments = _arg_2;
            if (_arg_3 != null){
                this._callbackFunc = _arg_3;
            };
        }

        public function start():void
        {
            this._startTime = Core.delayTime;
            this._stop = false;
        }

        public function set stop(_arg_1:Boolean):void
        {
            var _local_2:DeayQuene;
            if (this._stop != _arg_1){
                this._stop = _arg_1;
                _local_2 = FrameElisor.coder::getInstance().takeQuene(this._delay.toString());
                if (_arg_1){
                    _local_2.stopOrder(this.$id);
                } else {
                    _local_2.startOrder(this.$id);
                };
            };
        }

        public function get stop():Boolean
        {
            return (this._stop);
        }

        override public function execute()
        {
            var _local_1:*;
            var _local_2:int;
            if (this._stop == false){
                if (this._applyFunc != null){
                    _local_1 = this._applyFunc.apply(null, this._arguments);
                    this.callback([_local_1]);
                };
                if (this._between != -1){
                    _local_2 = Core.delayTime;
                    if ((_local_2 - (this._startTime + this._between)) >= 0){
                        this._stop = true;
                        if (this._timeOutargs == null){
                            this._timeOutargs = [];
                        };
                        if (this._timeOutFunc != null){
                            this._timeOutFunc.apply(null, this._timeOutargs);
                        };
                        this.dispose();
                        return;
                    };
                };
            };
        }

        override public function callback(args:Array=null)
        {
            try {
                if (this._callbackFunc == null){
                    return;
                };
                this._callbackFunc.apply(null, args);
            } catch(e:Error) {
                this.dispose();
                throw (new Error(("【异常】：" + e.message)));
            };
        }

        override public function dispose():void
        {
            if (FrameElisor.coder::getInstance().hasOrder(this.id)){
                FrameElisor.coder::getInstance().removeOrder(this.id);
            };
            this._stop = false;
            this._applyFunc = null;
            this._callbackFunc = null;
            this._arguments = null;
            this._timeOutFunc = null;
            this._timeOutargs = null;
            this._startTime = 0;
            this._delay = 0;
            this._startTime = 0;
            this._between = 0;
            super.dispose();
        }


    }
}//package com.engine.core.controls.elisor

