// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.tile.Cell

package com.engine.core.tile
{
    import flash.net.registerClassAlias;
    import com.engine.utils.gome.TileUitls;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.display.Graphics;
    import __AS3__.vec.Vector;
    import flash.display.GraphicsPathCommand;
    import flash.display.GraphicsPathWinding;
    import __AS3__.vec.*;

    public class Cell 
    {

        private static var cells:Array = [];

        public var type:int;
        public var isSell:Boolean;
        public var isSafe:Boolean;
        public var isAlpha:Boolean;
        private var _index:Pt;

        public function Cell()
        {
            registerClassAlias("sai.save.tile.Cell", Cell);
        }

        public function set index(_arg_1:Pt):void
        {
            this._index = _arg_1;
        }

        public function get index():Pt
        {
            return (this._index);
        }

        public function get x():Number
        {
            return (this.index.x);
        }

        public function get y():Number
        {
            return (this.index.y);
        }

        public function get z():Number
        {
            return (this.index.z);
        }

        public function get indexKey():String
        {
            return (((((this.x + "|") + this.y) + "|") + this.z));
        }

        public function get leftVertex():Point
        {
            if (!this.index){
                return (null);
            };
            return (TileUitls.indexToFlat(new Pt(this.index.x, this.index.y, (this.index.z + 1))));
        }

        public function get rightVertex():Point
        {
            if (!this.index){
                return (null);
            };
            return (TileUitls.indexToFlat(new Pt((this.index.x + 1), this.index.y, this.index.z)));
        }

        public function get topVertex():Point
        {
            if (!this.index){
                return (null);
            };
            return (TileUitls.indexToFlat(new Pt(this.index.x, this.index.y, this.index.z)));
        }

        public function get bottonVertex():Point
        {
            if (!this.index){
                return (null);
            };
            return (TileUitls.indexToFlat(new Pt((this.index.x + 1), this.index.y, (this.index.z + 1))));
        }

        public function get midVertex():Point
        {
            if (!this.index){
                return (null);
            };
            return (TileUitls.getIsoIndexMidVertex(this.index));
        }

        public function getBounds():Rectangle
        {
            var _local_1:Number = this.leftVertex.x;
            var _local_2:Number = this.topVertex.y;
            var _local_3:Number = (TileConstant.TILE_SIZE * 2);
            var _local_4:Number = TileConstant.TILE_SIZE;
            return (new Rectangle(_local_1, _local_2, _local_3, _local_4));
        }

        public function drawPoint(_arg_1:Graphics, _arg_2:uint=0, _arg_3:int=5):void
        {
            _arg_1.lineStyle(1, _arg_2);
            _arg_1.beginFill(_arg_2, 0.5);
            _arg_1.drawCircle(this.midVertex.x, this.midVertex.y, _arg_3);
            _arg_1.endFill();
        }

        public function draw2(_arg_1:Graphics):void
        {
            var _local_2:Vector.<int> = new Vector.<int>();
            _local_2.push(GraphicsPathCommand.MOVE_TO);
            _local_2.push(GraphicsPathCommand.LINE_TO);
            _local_2.push(GraphicsPathCommand.LINE_TO);
            _local_2.push(GraphicsPathCommand.LINE_TO);
            _local_2.push(GraphicsPathCommand.LINE_TO);
            var _local_3:Vector.<Number> = new Vector.<Number>();
            _local_3.push(this.leftVertex.x, this.leftVertex.y);
            _local_3.push(this.topVertex.x, this.topVertex.y);
            _local_3.push(this.rightVertex.x, this.rightVertex.y);
            _local_3.push(this.bottonVertex.x, this.bottonVertex.y);
            _local_3.push(this.leftVertex.x, this.leftVertex.y);
            _arg_1.drawPath(_local_2, _local_3, GraphicsPathWinding.NON_ZERO);
        }

        public function draw(_arg_1:Graphics, _arg_2:uint=0, _arg_3:Boolean=false, _arg_4:uint=0, _arg_5:Number=0.5):void
        {
            var _local_6:Vector.<int> = new Vector.<int>();
            _local_6.push(GraphicsPathCommand.MOVE_TO);
            _local_6.push(GraphicsPathCommand.LINE_TO);
            _local_6.push(GraphicsPathCommand.LINE_TO);
            _local_6.push(GraphicsPathCommand.LINE_TO);
            _local_6.push(GraphicsPathCommand.LINE_TO);
            var _local_7:Vector.<Number> = new Vector.<Number>();
            _arg_1.lineStyle(1, _arg_2);
            if (_arg_3){
                _arg_1.beginFill(_arg_4, _arg_5);
            };
            _local_7.push(this.leftVertex.x, this.leftVertex.y);
            _local_7.push(this.topVertex.x, this.topVertex.y);
            _local_7.push(this.rightVertex.x, this.rightVertex.y);
            _local_7.push(this.bottonVertex.x, this.bottonVertex.y);
            _local_7.push(this.leftVertex.x, this.leftVertex.y);
            _arg_1.drawPath(_local_6, _local_7, GraphicsPathWinding.NON_ZERO);
            if (_arg_3){
                _arg_1.endFill();
            };
        }

        public function toString():String
        {
            return ((("[Cell:" + this.indexKey) + "]"));
        }


    }
}//package com.engine.core.tile

