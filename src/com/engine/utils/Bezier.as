// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.utils.Bezier

package com.engine.utils
{
    import flash.geom.Point;

    public class Bezier 
    {


        public static function drawBezier3(_arg_1:Point, _arg_2:Point, _arg_3:Point, _arg_4:Point, _arg_5:int=10):Array
        {
            var _local_9:Number;
            var _local_10:Number;
            var _local_11:Number;
            var _local_6:Number = (1 / _arg_5);
            var _local_7:Array = [];
            var _local_8:Number = 0;
            while (_local_8 <= 1) {
                _local_9 = (1 - _local_8);
                _local_10 = ((((pow(_local_9, 3) * _arg_1.x) + (((3 * _arg_3.x) * _local_8) * pow(_local_9, 2))) + (((3 * _arg_4.x) * pow(_local_8, 2)) * _local_9)) + (_arg_2.x * pow(_local_8, 3)));
                _local_11 = ((((pow(_local_9, 3) * _arg_1.y) + (((3 * _arg_3.y) * _local_8) * pow(_local_9, 2))) + (((3 * _arg_4.y) * pow(_local_8, 2)) * _local_9)) + (_arg_2.y * pow(_local_8, 3)));
                _local_7.push(new Point(_local_10, _local_11));
                _local_8 = (_local_8 + _local_6);
            };
            return (_local_7);
        }

        public static function drawBezier(_arg_1:Point, _arg_2:Point, _arg_3:Point, _arg_4:int=40):Array
        {
            var _local_8:Number;
            var _local_9:Number;
            var _local_10:Number;
            var _local_5:Number = (1 / _arg_4);
            var _local_6:Array = [];
            var _local_7:Number = 0;
            while (_local_7 <= 1) {
                _local_8 = (1 - _local_7);
                _local_9 = (((Math.pow((1 - _local_7), 2) * _arg_1.x) + (((2 * _local_7) * (1 - _local_7)) * _arg_3.x)) + (Math.pow(_local_7, 2) * _arg_2.x));
                _local_10 = (((Math.pow((1 - _local_7), 2) * _arg_1.y) + (((2 * _local_7) * (1 - _local_7)) * _arg_3.y)) + (Math.pow(_local_7, 2) * _arg_2.y));
                _local_6.push(new Point(_local_9, _local_10));
                _local_7 = (_local_7 + _local_5);
            };
            return (_local_6);
        }

        public static function pow(_arg_1:Number, _arg_2:Number):Number
        {
            return (Math.pow(_arg_1, _arg_2));
        }


    }
}//package com.engine.utils

