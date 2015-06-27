// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.utils.HitTest

package com.engine.utils
{
    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.display.DisplayObject;
    import flash.geom.Matrix;
    import flash.display.DisplayObjectContainer;
    import flash.geom.ColorTransform;
    import flash.filters.ColorMatrixFilter;

    public class HitTest 
    {

        private static var pixel:BitmapData = new BitmapData(1, 1, true, 0);
        private static var pixelRect:Rectangle = new Rectangle(0, 0, 1, 1);
        private static var recovery_point:Point = new Point();


        private static function replacColor(_arg_1:BitmapData, _arg_2:uint):BitmapData
        {
            var _local_3:BitmapData = new BitmapData(_arg_1.width, _arg_1.height);
            var _local_4:uint = 0x22000000;
            _arg_2 = 0xFFFF0000;
            _local_3.threshold(_arg_1, _arg_1.rect, recovery_point, ">=", _local_4, _arg_2, 0xFFFFFFFF, true);
            return (_local_3);
        }

        public static function getChildUnderPoint(_arg_1:DisplayObjectContainer, _arg_2:Point, _arg_3:Array=null, _arg_4:Class=null, _arg_5:int=10):DisplayObject
        {
            var _local_6:DisplayObject;
            var _local_9:*;
            var _local_10:Rectangle;
            var _local_11:BitmapData;
            var _local_12:Matrix;
            var _local_14:uint;
            if (_arg_3){
                _arg_3.sortOn("y", Array.NUMERIC);
            };
            if (_arg_4 == null){
                _arg_4 = DisplayObject;
            };
            var _local_7:Array = [];
            var _local_8:int = (_arg_3.length - 1);
            var _local_13:int = _local_8;
            while (_local_13 >= 0) {
                _local_9 = _arg_3[_local_13];
                if ((_local_9 as _arg_4)){
                    _local_10 = _arg_3[_local_13].getBounds(_arg_1);
                    if (_local_10.containsPoint(_arg_2)){
                        _local_11 = new BitmapData(1, 1, true, 0);
                        _local_12 = new Matrix();
                        _local_12.tx = -(int(_local_9.mouseX));
                        _local_12.ty = -(int(_local_9.mouseY));
                        _local_11.draw(_local_9, _local_12, null, null, pixelRect);
                        _local_14 = ((_local_11.getPixel32(0, 0) >> 24) & 0xFF);
                        if (_local_14 > _arg_5){
                            _local_6 = _local_9;
                            break;
                        };
                    };
                };
                _local_13--;
            };
            return (_local_6);
        }

        public static function getChildUnderPointWithDifferentLayer(_arg_1:DisplayObjectContainer, _arg_2:Point, _arg_3:Array=null, _arg_4:Class=null):DisplayObject
        {
            var _local_5:DisplayObject;
            var _local_10:DisplayObject;
            var _local_11:int;
            var _local_12:int;
            var _local_13:*;
            var _local_14:BitmapData;
            var _local_15:Matrix;
            var _local_16:uint;
            if (_arg_3 == null){
                return (null);
            };
            var _local_6:Array = [];
            var _local_7:int;
            while (_local_7 < _arg_3.length) {
                _local_10 = _arg_3[_local_7];
                _local_11 = (_local_10.parent.parent.getChildIndex(_local_10.parent) * 1000000);
                _local_12 = _local_10.y;
                _local_6.push({
                    "target":_local_10,
                    "depth":(_local_11 + _local_12)
                });
                _local_7++;
            };
            _local_6.sortOn("depth", (Array.NUMERIC | Array.DESCENDING));
            if (_arg_4 == null){
                _arg_4 = DisplayObject;
            };
            var _local_8:Array = [];
            var _local_9:int = (_local_6.length - 1);
            while (_local_9 >= 0) {
                _local_13 = _local_6[_local_9].target;
                if ((_local_13 as _arg_4)){
                    _local_14 = new BitmapData(1, 1, true, 0);
                    _local_15 = new Matrix();
                    _local_15.tx = -(int(_local_13.mouseX));
                    _local_15.ty = -(int(_local_13.mouseY));
                    _local_14.draw(_local_13, _local_15, null, null, new Rectangle(0, 0, 1, 1));
                    _local_16 = ((_local_14.getPixel32(0, 0) >> 24) & 0xFF);
                    if (_local_16 > 40){
                        _local_5 = _local_13;
                        break;
                    };
                };
                _local_9--;
            };
            return (_local_5);
        }

        public static function getChildAtPoint(_arg_1:DisplayObjectContainer, _arg_2:Point, _arg_3:Array=null):DisplayObject
        {
            var _local_14:DisplayObject;
            var _local_15:Rectangle;
            if (_arg_3 == null){
                _arg_3 = new Array();
                _arg_3 = _arg_1.getObjectsUnderPoint(_arg_2);
            };
            var _local_4:Array = [];
            var _local_5:int;
            while (_local_5 < _arg_3.length) {
                _local_14 = _arg_3[_local_5];
                _local_15 = _local_14.getBounds(_arg_1);
                if (_local_15.containsPoint(_arg_2)){
                    _local_4.push(_local_14);
                };
                _local_5++;
            };
            _arg_3 = _local_4;
            var _local_6:ColorTransform = new ColorTransform();
            var _local_7:Matrix = new Matrix();
            _local_7.tx = -(int(_arg_2.x));
            _local_7.ty = -(int(_arg_2.y));
            var _local_8:BitmapData = new BitmapData(1, 1);
            var _local_9:Array = new Array();
            var _local_10:Rectangle = new Rectangle(0, 0, _local_8.width, _local_8.height);
            var _local_11:int;
            while (_local_11 < _arg_3.length) {
                _local_6.color = _local_11;
                _local_9.push(_arg_3[_local_11].transform.colorTransform);
                _arg_3[_local_11].transform.colorTransform = _local_6;
                _local_11++;
            };
            _local_8.draw(_arg_1, _local_7, null, null, _local_10);
            var _local_12:int = _local_8.getPixel(0, 0);
            var _local_13:int;
            while (_local_13 < _arg_3.length) {
                _arg_3[_local_13].transform.colorTransform = _local_9[_local_13];
                _local_13++;
            };
            return (_arg_3[_local_12]);
        }

        private static function setfilter(_arg_1:int):ColorMatrixFilter
        {
            var _local_2:Array = new Array();
            _local_2 = _local_2.concat([1, 0, 0, 2, 0]);
            _local_2 = _local_2.concat([1, 0, 0, 2, 0]);
            _local_2 = _local_2.concat([1, 0, 0, 2, 0]);
            _local_2 = _local_2.concat([1, 0, 0, 1, 0]);
            return (new ColorMatrixFilter(_local_2));
        }


    }
}//package com.engine.utils

