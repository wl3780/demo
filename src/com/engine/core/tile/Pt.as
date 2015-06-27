// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.tile.Pt

package com.engine.core.tile
{
    import flash.net.registerClassAlias;

    public class Pt 
    {

        private var _x:Number;
        private var _y:Number;
        private var _z:Number;

        public function Pt(_arg_1:Number=0, _arg_2:Number=0, _arg_3:Number=0)
        {
            registerClassAlias("sai.save.core.tile.Pt", Pt);
            this.x = _arg_1;
            this.y = _arg_2;
            this.z = _arg_3;
        }

        public static function distance(_arg_1:Pt, _arg_2:Pt):Number
        {
            var _local_3:Number = Math.pow(2, (_arg_1.x - _arg_2.x));
            var _local_4:Number = Math.pow(2, (_arg_1.z - _arg_2.z));
            return (Math.sqrt((_local_3 + _local_4)));
        }


        public function get key():String
        {
            return (((((this.x + "|") + this.y) + "|") + this.z));
        }

        public function toString():String
        {
            return ((((((("[Pt(" + this.x) + ",") + this.y) + ",") + this.z) + ")]"));
        }

        public function get z():Number
        {
            return (this._z);
        }

        public function set z(_arg_1:Number):void
        {
            this._z = _arg_1;
        }

        public function get x():Number
        {
            return (this._x);
        }

        public function set x(_arg_1:Number):void
        {
            this._x = _arg_1;
        }

        public function get y():Number
        {
            return (this._y);
        }

        public function set y(_arg_1:Number):void
        {
            this._y = _arg_1;
        }


    }
}//package com.engine.core.tile

