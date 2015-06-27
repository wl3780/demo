// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.tile.square.Square

package com.engine.core.tile.square
{
    import flash.net.registerClassAlias;
    import com.engine.core.tile.TileConstant;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.display.Graphics;
    import __AS3__.vec.Vector;
    import flash.display.GraphicsPathCommand;
    import flash.display.GraphicsPathWinding;
    import __AS3__.vec.*;

    public class Square 
    {

        private static var squareHash:Array = [];

        public var type:int;
        public var isSell:Boolean;
        public var isSafe:Boolean;
        public var isAlpha:Boolean;
        private var _index:SquarePt;

        public function Square()
        {
            registerClassAlias("sai.save.tile.Square", Square);
        }

        public static function createSquare():Square
        {
            var _local_1:Square;
            if (squareHash.length){
                _local_1 = squareHash.pop();
            } else {
                return (new (Square)());
            };
            return (_local_1);
        }


        public function setIndex(_arg_1:SquarePt):void
        {
            this._index = _arg_1;
        }

        public function setXY(_arg_1:int, _arg_2:int):void
        {
            if (this._index == null){
                this._index = new SquarePt();
            };
            if (_arg_1 != this._index.x){
                this._index.x = _arg_1;
            };
            if (_arg_2 != this._index.y){
                this._index.y = _arg_2;
            };
        }

        public function get index():SquarePt
        {
            return (this._index);
        }

        public function get y():int
        {
            if (this._index == null){
                this._index = new SquarePt();
            };
            return (this._index.y);
        }

        public function set y(_arg_1:int):void
        {
            if (this._index == null){
                this._index = new SquarePt();
            };
            if (this._index.y != _arg_1){
                if ((this._index == null)){
                    this._index = new SquarePt();
                };
                this._index.y = _arg_1;
            };
        }

        public function get x():int
        {
            if (this._index == null){
                this._index = new SquarePt();
            };
            return (this._index.x);
        }

        public function set x(_arg_1:int):void
        {
            if (this._index == null){
                this._index = new SquarePt();
            };
            if (this._index.x != _arg_1){
                if ((this._index == null)){
                    this._index = new SquarePt();
                };
                this._index.x = _arg_1;
            };
        }

        public function get key():String
        {
            return (((this.x + "|") + this.y));
        }

        public function toString():String
        {
            return ((("[Square:" + this.key) + "]"));
        }

        public function get top_left():Point
        {
            var _local_1:Number = (TileConstant.TILE_SIZE * this.x);
            var _local_2:Number = (TileConstant.TILE_SIZE * this.y);
            return (new Point(_local_1, _local_2));
        }

        public function get top_right():Point
        {
            var _local_1:Number = (TileConstant.TILE_SIZE * (this.x + 1));
            var _local_2:Number = (TileConstant.TILE_SIZE * this.y);
            return (new Point(_local_1, _local_2));
        }

        public function get bottom_left():Point
        {
            var _local_1:Number = (TileConstant.TILE_SIZE * this.x);
            var _local_2:Number = (TileConstant.TILE_SIZE * (this.y + 1));
            return (new Point(_local_1, _local_2));
        }

        public function get bottom_right():Point
        {
            var _local_1:Number = (TileConstant.TILE_SIZE * (this.x + 1));
            var _local_2:Number = (TileConstant.TILE_SIZE * (this.y + 1));
            return (new Point(_local_1, _local_2));
        }

        public function get midVertex():Point
        {
            var _local_1:Number = ((TileConstant.TILE_SIZE * this.x) - (TileConstant.TILE_SIZE / 2));
            var _local_2:Number = ((TileConstant.TILE_SIZE * this.y) - (TileConstant.TILE_SIZE / 2));
            return (new Point());
        }

        public function getBounds():Rectangle
        {
            var _local_1:Number = (this.x * TileConstant.TILE_SIZE);
            var _local_2:Number = (this.y * TileConstant.TILE_SIZE);
            var _local_3:Number = TileConstant.TILE_SIZE;
            var _local_4:Number = TileConstant.TILE_SIZE;
            return (new Rectangle(_local_1, _local_2, _local_3, _local_4));
        }

        public function drawCenterPoint(_arg_1:Graphics, _arg_2:uint, _arg_3:int=3, _arg_4:Number=0.5):void
        {
            _arg_1.beginFill(_arg_2, _arg_4);
            _arg_1.drawCircle(this.midVertex.x, this.midVertex.y, _arg_3);
        }

        public function draw2(_arg_1:Graphics):void
        {
            var _local_2:Number = 0.5;
            _arg_1.moveTo((this.top_left.x + _local_2), (this.top_left.y + _local_2));
            _arg_1.lineTo((this.top_right.x - _local_2), (this.top_right.y + _local_2));
            _arg_1.lineTo((this.bottom_right.x - _local_2), (this.bottom_right.y - _local_2));
            _arg_1.lineTo((this.bottom_left.x + _local_2), (this.bottom_left.y - _local_2));
            _arg_1.lineTo((this.top_left.x + _local_2), (this.top_left.y + _local_2));
        }

        public function draw(_arg_1:Graphics, _arg_2:uint, _arg_3:Boolean=false, _arg_4:uint=0, _arg_5:Number=0.5):void
        {
            var _local_6:Vector.<int> = new Vector.<int>();
            _local_6.push(GraphicsPathCommand.MOVE_TO);
            _local_6.push(GraphicsPathCommand.LINE_TO);
            _local_6.push(GraphicsPathCommand.LINE_TO);
            _local_6.push(GraphicsPathCommand.LINE_TO);
            _local_6.push(GraphicsPathCommand.LINE_TO);
            _arg_1.lineStyle(1, _arg_2);
            if (_arg_3){
                _arg_1.beginFill(_arg_4, _arg_5);
            };
            var _local_7:Vector.<Number> = new Vector.<Number>();
            _local_7.push(this.top_left.x, this.top_left.y);
            _local_7.push(this.top_right.x, this.top_right.y);
            _local_7.push(this.bottom_right.x, this.bottom_right.y);
            _local_7.push(this.bottom_left.x, this.bottom_left.y);
            _local_7.push(this.top_left.x, this.top_left.y);
            _arg_1.drawPath(_local_6, _local_7, GraphicsPathWinding.NON_ZERO);
        }

        public function dispose():void
        {
            this.type = 0;
            this.isAlpha = false;
            this.isSafe = false;
            this._index = null;
            this.x = 0;
            this.y = 0;
            if (squareHash.length < 10000){
                squareHash.push(this);
            };
        }


    }
}//package com.engine.core.tile.square

