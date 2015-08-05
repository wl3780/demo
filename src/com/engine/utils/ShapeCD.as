// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.utils.ShapeCD

package com.engine.utils
{
    import com.engine.core.view.DisplaySprite;
    import flash.display.Shape;
    import flash.utils.Dictionary;
    import com.engine.core.HeartbeatFactory;
    import flash.utils.getTimer;
    import flash.events.Event;
    import flash.display.Graphics;

    public class ShapeCD extends DisplaySprite 
    {

        private static var isReady:Boolean;
        private static var hash:Hash = new Hash();
        public static const CD_FINISH:String = "CD_FINISH";

        public var isRuning:Boolean;
        private var _startTime:Number;
        private var _totalTime:Number;
        private var _passTime:Number;
        private var _size:Number;
        private var _angle:Number = 360;
        private var _pos:Number;
        public var isFinish:Boolean = false;
        public var visibleEnabled:Boolean = true;
        public var dur:int;
        private var _t:int;

        public function ShapeCD(_arg_1:int=50, _arg_2:int=2, _arg_3:Boolean=false)
        {
            this._size = _arg_1;
            var _local_4:Shape = new Shape();
            _local_4.graphics.beginFill(0);
            _local_4.graphics.drawRoundRect(0, 0, ((this._size * 2) + 1), ((this._size * 2) + 1), _arg_2, _arg_2);
            this.mask = _local_4;
            this.addChild(_local_4);
            this._pos = (this._size * 1.414);
            this.isRuning = false;
            this.mouseChildren = (this.mouseEnabled = false);
            if (_arg_3){
                hash.put(this.id, this);
            };
            this.liangdu(120);
        }

        private static function timerFunc():void
        {
            var _local_2:ShapeCD;
            var _local_1:Dictionary = hash;
            for each (_local_2 in _local_1) {
                _local_2.onRender();
            };
        }


        public function liangdu(_arg_1:Number):Array
        {
            return ([1, 0, 0, 0, _arg_1, 0, 1, 0, 0, _arg_1, 0, 0, 1, 0, _arg_1, 0, 0, 0, 1, 0]);
        }

        public function play(_arg_1:int, _arg_2:int=0, _arg_3:int=60):void
        {
            this.dur = (_arg_3 + ((Math.random() * 95) >> 0));
            if (!isReady){
                isReady = true;
                HeartbeatFactory.getInstance().addFrameOrder(timerFunc);
            };
            this._startTime = (getTimer() - _arg_2);
            this._totalTime = _arg_1;
            this._angle = 360;
            this.isFinish = false;
            this.isRuning = true;
        }

        public function onRender():void
        {
            if (this.isFinish){
                return;
            };
            this._passTime = (getTimer() - this._startTime);
            if (this._passTime >= this._totalTime){
                this.graphics.clear();
                this._angle = 0;
                this.isRuning = false;
                this.dispatchEvent(new Event(CD_FINISH));
                this.isFinish = true;
            } else {
                this._angle = (360 - ((360 * this._passTime) / this._totalTime));
                if ((getTimer() - this._t) > this.dur){
                    this._t = getTimer();
                    if (((this.visibleEnabled) && (this.stage))){
                        this.drawSector(graphics, this._size, this._size, this._pos, this._angle, -((this._angle + 90)));
                    };
                };
            };
        }

        private function drawSector(_arg_1:Graphics, _arg_2:int, _arg_3:int, _arg_4:int, _arg_5:Number, _arg_6:Number=270):void
        {
            var _local_11:Number;
            var _local_12:Number;
            var _local_13:Number;
            var _local_14:Number;
            if (_arg_5 <= 0){
                return;
            };
            if (_arg_5 > 360){
                _arg_5 = 360;
            };
            var _local_7:int = 8;
            _arg_5 = ((Math.PI / 180) * _arg_5);
            var _local_8:Number = (_arg_5 / _local_7);
            var _local_9:Number = (_arg_4 / Math.cos((_local_8 / 2)));
            var _local_10:Number = ((_arg_6 * Math.PI) / 180);
            var _local_15:Number = (_arg_2 + (Math.cos(_local_10) * _arg_4));
            var _local_16:Number = (_arg_3 + (Math.sin(_local_10) * _arg_4));
            _arg_1.clear();
            _arg_1.beginFill(0x666666, 0.6);
            _arg_1.moveTo(_arg_2, _arg_3);
            _arg_1.lineTo(_local_15, _local_16);
            var _local_17:Number = 0;
            while (_local_17 < _local_7) {
                _local_10 = (_local_10 + _local_8);
                _local_11 = (_arg_2 + (Math.cos((_local_10 - (_local_8 / 2))) * _local_9));
                _local_12 = (_arg_3 + (Math.sin((_local_10 - (_local_8 / 2))) * _local_9));
                _local_13 = (_arg_2 + (Math.cos(_local_10) * _arg_4));
                _local_14 = (_arg_3 + (Math.sin(_local_10) * _arg_4));
                _arg_1.curveTo(_local_11, _local_12, _local_13, _local_14);
                _local_17++;
            };
            _arg_1.lineTo(_arg_2, _arg_3);
        }

        public function get size():Number
        {
            return (this._size);
        }

        public function set size(_arg_1:Number):void
        {
            this._size = _arg_1;
        }

        override public function dispose():void
        {
            hash.remove(this.id);
            super.dispose();
        }


    }
}//package com.engine.utils

