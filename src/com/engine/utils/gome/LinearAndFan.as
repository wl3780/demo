// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.utils.gome.LinearAndFan

package com.engine.utils.gome
{
    import flash.geom.Point;

    public class LinearAndFan 
    {


        public static function lineAttck(_arg_1:Point, _arg_2:Point, _arg_3:int=80):Array
        {
            var _local_7:Point;
            if (((!(_arg_1)) || (!(_arg_2)))){
                return ([]);
            };
            var _local_4:Number = _arg_1.x;
            var _local_5:Number = _arg_1.y;
            var _local_6:Number = Point.distance(_arg_1, _arg_2);
            var _local_8:Array = [];
            var _local_9:int = (_local_6 / _arg_3);
            var _local_10:int;
            while (_local_10 < _local_9) {
                _local_7 = Point.interpolate(_arg_1, _arg_2, (1 - (_local_10 / _local_9)));
                _local_8.push(_local_7);
                _local_10++;
            };
            return (_local_8);
        }

        public static function pointBetweenPoint(_arg_1:Point, _arg_2:Point, _arg_3:int):Point
        {
            if (((!(_arg_1)) || (!(_arg_2)))){
                return (null);
            };
            var _local_4:Number = Point.distance(_arg_1, _arg_2);
            var _local_5:Number = (_arg_2.x + ((_arg_3 / _local_4) * (_arg_2.x - _arg_1.x)));
            var _local_6:Number = (_arg_2.y + ((_arg_3 / _local_4) * (_arg_2.y - _arg_1.y)));
            return (new Point(_local_5, _local_6));
        }

        public static function lineSectorAttack(_arg_1:Point, _arg_2:Point, _arg_3:Number, _arg_4:int=3, _arg_5:int=200):Array
        {
            if (((!(_arg_1)) || (!(_arg_2)))){
                return ([]);
            };
            var _local_6:Array = sectorAttack(_arg_1, _arg_2, _arg_3, _arg_4, _arg_5);
            var _local_7:Array = [];
            var _local_8:int;
            while (_local_8 < _local_6.length) {
                _local_7[_local_8] = lineAttck(_arg_1, _local_6[_local_8]);
                _local_8++;
            };
            return (_local_7);
        }

        public static function sectorAttack(_arg_1:Point, _arg_2:Point, _arg_3:Number, _arg_4:int=3, _arg_5:int=200):Array
        {
            var _local_17:Number;
            var _local_18:Number;
            var _local_19:Number;
            var _local_20:Number;
            var _local_25:Number;
            var _local_26:Number;
            var _local_27:Point;
            var _local_6:Number = _arg_3;
            if (_local_6 <= 0){
                return ([]);
            };
            if (_local_6 > 360){
                _local_6 = 360;
            };
            _local_6 = ((Math.PI / 180) * _local_6);
            var _local_7:Number = _arg_1.x;
            var _local_8:Number = _arg_1.y;
            var _local_9:Number = Point.distance(_arg_1, _arg_2);
            var _local_10:Number = (_arg_2.x - _arg_1.x);
            var _local_11:Number = (_arg_2.y - _arg_1.y);
            var _local_12:Number = Math.atan2(_local_11, _local_10);
            var _local_13:int = ((_local_12 * 180) / Math.PI);
            _local_13 = (_local_13 - (_arg_3 / 2));
            var _local_14:Number = (_local_6 / _arg_4);
            var _local_15:Number = (_local_9 / Math.cos((_local_14 / 2)));
            var _local_16:Number = ((_local_13 * Math.PI) / 180);
            if (((!((_arg_5 == -1))) && ((_local_9 < _arg_5)))){
                _local_9 = _arg_5;
                _local_25 = (_local_7 + (Math.cos(_local_16) * _local_9));
                _local_26 = (_local_8 + (Math.sin(_local_16) * _local_9));
                _arg_2.x = _local_25;
                _arg_2.y = _local_26;
                _local_10 = (_arg_2.x - _arg_1.x);
                _local_11 = (_arg_2.y - _arg_1.y);
                _local_12 = Math.atan2(_local_11, _local_10);
                _local_13 = ((_local_12 * 180) / Math.PI);
                _local_13 = (_local_13 - (_arg_3 / 2));
                _local_14 = (_local_6 / _arg_4);
                _local_15 = (_local_9 / Math.cos((_local_14 / 2)));
                _local_16 = ((_local_13 * Math.PI) / 180);
            };
            var _local_21:Number = (_local_7 + (Math.cos(_local_16) * _local_9));
            var _local_22:Number = (_local_8 + (Math.sin(_local_16) * _local_9));
            var _local_23:Array = [];
            _local_23.push(new Point(_local_21, _local_22));
            var _local_24:Number = 0;
            while (_local_24 < _arg_4) {
                _local_16 = (_local_16 + _local_14);
                _local_17 = (_local_7 + (Math.cos((_local_16 - (_local_14 / 2))) * _local_15));
                _local_18 = (_local_8 + (Math.sin((_local_16 - (_local_14 / 2))) * _local_15));
                _local_19 = (_local_7 + (Math.cos(_local_16) * _local_9));
                _local_20 = (_local_8 + (Math.sin(_local_16) * _local_9));
                _local_27 = new Point(_local_19, _local_20);
                _local_23.push(_local_27);
                _local_24++;
            };
            return (_local_23);
        }


    }
}//package com.engine.utils.gome

