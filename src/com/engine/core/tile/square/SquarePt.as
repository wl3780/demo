// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.tile.square.SquarePt

package com.engine.core.tile.square
{
    import com.engine.core.tile.TileConstant;
    import flash.net.registerClassAlias;
    import flash.geom.Point;

    public class SquarePt 
    {

        private static var size:Number = (TileConstant.TILE_SIZE / 2);

        private var _x:int;
        private var _y:int;

        public function SquarePt(_arg_1:int=0, _arg_2:int=0)
        {
            registerClassAlias("sai.save.core.tile.SquarePt", SquarePt);
            this.x = _arg_1;
            this.y = _arg_2;
        }

        public static function pixelsDistance(_arg_1:SquarePt, _arg_2:SquarePt):Number
        {
            var _local_3:Number = ((_arg_1.x * TileConstant.TILE_SIZE) + size);
            var _local_4:Number = ((_arg_2.x * TileConstant.TILE_SIZE) + size);
            var _local_5:Number = ((_arg_1.y * TileConstant.TILE_SIZE) + size);
            var _local_6:Number = ((_arg_2.y * TileConstant.TILE_SIZE) + size);
            return (Point.distance(new Point(_local_3, _local_5), new Point(_local_4, _local_6)));
        }


        public function get y():int
        {
            return (this._y);
        }

        public function set y(_arg_1:int):void
        {
            this._y = _arg_1;
        }

        public function get x():int
        {
            return (this._x);
        }

        public function set x(_arg_1:int):void
        {
            this._x = _arg_1;
        }

        public function get key():String
        {
            return (((this.x + "|") + this.y));
        }

        public function get pixelsPoint():Point
        {
            var _local_1:Number = Number(Number(((this.x * TileConstant.TILE_SIZE) + size)).toFixed(1));
            var _local_2:Number = Number(Number(((this.y * TileConstant.TILE_SIZE) + size)).toFixed(1));
            return (new Point(_local_1, _local_2));
        }

        public function toString():String
        {
            return ((((("[SquarePt(" + this.x) + ",") + this.y) + ")]"));
        }


    }
}//package com.engine.core.tile.square

