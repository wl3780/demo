// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.items.avatar.ShoadwAvatar

package com.engine.core.view.avatar
{
    import flash.display.Shape;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.filters.ColorMatrixFilter;
    import com.engine.core.view.scenes.Scene;
    import flash.display.BitmapData;
    import com.engine.core.RecoverUtils;
    import flash.geom.Matrix;

    public class ShoadwAvatar extends Shape 
    {

        private static var timer:Timer;
        private static var queneArray:Array = [];
        private static var hash:Array = [];
        private static var a:Number = 0.01;

        private var speed:Number = 0.1;

        public function ShoadwAvatar()
        {
            if (timer == null){
                timer = new Timer(50);
                timer.addEventListener(TimerEvent.TIMER, timerFunc);
                timer.start();
            };
        }

        private static function fillGray():Array
        {
            var _local_1:Array = [];
            _local_1 = _local_1.concat([0.3086, 0.6094, 0.082, 0, 0]);
            _local_1 = _local_1.concat([0.3086, 0.6094, 0.082, 0, 0]);
            _local_1 = _local_1.concat([0.3086, 0.6094, 0.082, 0, 0]);
            _local_1 = _local_1.concat([0, 0, 0, 1, 0]);
            var _local_2:ColorMatrixFilter = new ColorMatrixFilter(_local_1);
            return ([_local_2]);
        }

        private static function timerFunc(_arg_1:TimerEvent):void
        {
            var _local_3:ShoadwAvatar;
            var _local_2:int;
            while (_local_2 < queneArray.length) {
                _local_3 = queneArray[_local_2];
                _local_3.alpha = (_local_3.alpha - _local_3.speed);
                _local_3.speed = (_local_3.speed + a);
                if (_local_3.alpha <= 0){
                    if (_local_3.parent){
                        _local_3.parent.removeChild(_local_3);
                    };
                    queneArray.splice(_local_2, 1);
                    _local_3.graphics.clear();
                    if (hash.length < 30){
                        hash.push(_local_3);
                    } else {
                        _local_3 = null;
                    };
                    _local_2++;
                };
                _local_2++;
            };
        }

        public static function create(_arg_1:BitmapData, _arg_2:Number, _arg_3:Number, _arg_4:Number, _arg_5:Number):void
        {
            var _local_6:ShoadwAvatar;
            if (hash.length){
                _local_6 = hash.pop();
            } else {
                _local_6 = new (ShoadwAvatar)();
            };
            _local_6.alpha = 1;
            _local_6.speed = 0.1;
            _local_6.graphics.clear();
            _local_6.draw(_arg_1, _arg_2, _arg_3);
            _local_6.x = _arg_4;
            _local_6.y = _arg_5;
            Scene.scene.$itemLayer.addChild(_local_6);
            queneArray.push(_local_6);
        }


        public function draw(_arg_1:BitmapData, _arg_2:Number, _arg_3:Number):void
        {
            var _local_4:Matrix = RecoverUtils.matrix;
            _local_4.tx = _arg_2;
            _local_4.ty = _arg_3;
            this.graphics.beginBitmapFill(_arg_1, _local_4);
            this.graphics.drawRect(_arg_2, _arg_3, _arg_1.width, _arg_1.height);
        }

        public function liangdu(_arg_1:Number):Array
        {
            return ([1, 0, 0, 0, _arg_1, 0, 1, 0, 0, _arg_1, 0, 0, 1, 0, _arg_1, 0, 0, 0, 1, 0]);
        }


    }
}//package com.engine.core.view.items.avatar

