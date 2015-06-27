// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.RecoverUtils

package com.engine.core
{
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class RecoverUtils 
    {

        private static var _mat_:Matrix = new Matrix();
        private static var _point_:Point = new Point();
        private static var _rect_:Rectangle = new Rectangle();


        public static function get matrix():Matrix
        {
            _mat_.identity();
            return (_mat_);
        }

        public static function get point():Point
        {
            _point_.x = 0;
            _point_.y = 0;
            return (_point_);
        }

        public static function get rect():Rectangle
        {
            _rect_.isEmpty();
            return (_rect_);
        }


    }
}//package com.engine.core

