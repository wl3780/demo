// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.tile.Grids

package com.engine.core.tile
{
    import flash.utils.Dictionary;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import __AS3__.vec.Vector;
    import flash.display.GraphicsPathCommand;
    import flash.display.GraphicsPathWinding;
    import flash.display.Graphics;
    import __AS3__.vec.*;

    public class Grids 
    {

        private var _rowStart:int;
        private var _rowEnd:int;
        private var _conductStart:int;
        private var _conductEnd:int;
        private var _top:Cell;
        private var _left:Cell;
        private var _right:Cell;
        private var _botton:Cell;
        private var _x:int;
        private var _y:int;

        public function Grids()
        {
            this.init();
        }

        public function init():void
        {
            this._rowStart = -99999;
            this._top = new Cell();
            this._left = new Cell();
            this._right = new Cell();
            this._botton = new Cell();
        }

        public function unload():void
        {
            this._top = null;
            this._left = null;
            this._right = null;
            this._botton = null;
        }

        public function put(_arg_1:Cell, _arg_2:Boolean=true):void
        {
            if (this._rowStart == -99999){
                this._rowStart = (this._rowEnd = _arg_1.x);
                this._conductStart = (this._conductEnd = _arg_1.z);
            } else {
                if (_arg_1.x < this._rowStart){
                    this._rowStart = _arg_1.x;
                };
                if (_arg_1.x > this._rowEnd){
                    this._rowEnd = _arg_1.x;
                };
                if (_arg_1.z < this._conductStart){
                    this._conductStart = _arg_1.z;
                };
                if (_arg_1.z > this._conductEnd){
                    this._conductEnd = _arg_1.z;
                };
            };
            if (_arg_2){
                this.setfourCell();
            };
        }

        public function prase(_arg_1:Dictionary):void
        {
            var _local_2:Cell;
            this._rowStart = -99999;
            for each (_local_2 in _arg_1) {
                this.put(_local_2, false);
            };
            this.setfourCell();
        }

        private function setfourCell():void
        {
            this._top.index = new Pt((this._y + this._rowStart), 0, (this._x + this._conductStart));
            this._right.index = new Pt((this._x + this._rowEnd), 0, (this._y + this._conductStart));
            this._left.index = new Pt((this._x + this._rowStart), 0, (this._y + this._conductEnd));
            this._botton.index = new Pt((this._x + this._rowEnd), 0, (this._y + this._conductEnd));
        }

        private function cleanIt(_arg_1:Dictionary, _arg_2:Cell, _arg_3:Cell):void
        {
            var _local_4:int;
            var _local_5:int;
            var _local_6:int;
            var _local_7:int;
            var _local_8:Cell;
            if (_arg_2.x < _arg_3.x){
                _local_6 = _arg_2.x;
            } else {
                _local_6 = _arg_3.x;
            };
            if (_arg_2.z < _arg_3.z){
                _local_7 = _arg_2.z;
            } else {
                _local_7 = _arg_3.z;
            };
            if ((_local_6 < 0)){
                _local_4 = -(_local_6);
            } else {
                _local_4 = 0;
            };
            if ((_local_7 < 0)){
                _local_5 = -(_local_7);
            } else {
                _local_4 = 0;
            };
            this._rowStart = -99999;
            for each (_local_8 in _arg_1) {
                _local_8.index = new Pt((_local_8.x + _local_4), _local_8.y, (_local_8.z + _local_5));
                this.put(_local_8, false);
            };
            this.setfourCell();
        }

        public function clean(_arg_1:Dictionary):Point
        {
            var _local_2:Point = new Point(this.top.leftVertex.x, this.top.leftVertex.y);
            this.cleanIt(_arg_1, this.left, this.top);
            _local_2.x = (this.top.leftVertex.x - _local_2.x);
            _local_2.y = (this.top.leftVertex.y - _local_2.y);
            return (_local_2);
        }

        public function getBounds():Rectangle
        {
            return (new Rectangle(this._left.leftVertex.x, this._top.topVertex.y, Math.abs((this._right.rightVertex.x - this._left.leftVertex.x)), Math.abs((this._botton.bottonVertex.y - this._top.topVertex.y))));
        }

        public function drawFaltRect(_arg_1:Graphics, _arg_2:uint=0):void
        {
            var _local_3:Vector.<int> = new Vector.<int>();
            _local_3.push(GraphicsPathCommand.MOVE_TO);
            _local_3.push(GraphicsPathCommand.LINE_TO);
            _local_3.push(GraphicsPathCommand.LINE_TO);
            _local_3.push(GraphicsPathCommand.LINE_TO);
            _local_3.push(GraphicsPathCommand.LINE_TO);
            var _local_4:Rectangle = this.getBounds();
            var _local_5:Vector.<Number> = new Vector.<Number>();
            _local_5.push(_local_4.x, _local_4.y);
            _local_5.push((_local_4.x + _local_4.width), _local_4.y);
            _local_5.push((_local_4.x + _local_4.width), (_local_4.y + _local_4.height));
            _local_5.push(_local_4.x, (_local_4.y + _local_4.height));
            _local_5.push(_local_4.x, _local_4.y);
            _arg_1.lineStyle(1, _arg_2);
            _arg_1.drawPath(_local_3, _local_5, GraphicsPathWinding.NON_ZERO);
        }

        public function drawTile(_arg_1:Graphics, _arg_2:uint=0, _arg_3:Boolean=false, _arg_4:uint=0, _arg_5:Number=0.5):void
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
            _arg_1.drawPath(_local_6, this.getTileBounds(), GraphicsPathWinding.NON_ZERO);
            if (_arg_3){
                _arg_1.endFill();
            };
        }

        public function getTileBounds():Vector.<Number>
        {
            var _local_1:Vector.<Number> = new Vector.<Number>();
            _local_1.push(this._left.leftVertex.x, this._left.leftVertex.y);
            _local_1.push(this._top.topVertex.x, this._top.topVertex.y);
            _local_1.push(this._right.rightVertex.x, this._right.rightVertex.y);
            _local_1.push(this._botton.bottonVertex.x, this._botton.bottonVertex.y);
            _local_1.push(this._left.leftVertex.x, this._left.leftVertex.y);
            return (_local_1);
        }

        public function get botton():Cell
        {
            return (this._botton);
        }

        public function get right():Cell
        {
            return (this._right);
        }

        public function get left():Cell
        {
            return (this._left);
        }

        public function get top():Cell
        {
            return (this._top);
        }


    }
}//package com.engine.core.tile

