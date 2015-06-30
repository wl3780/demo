package com.engine.core.view
{
    import com.engine.namespaces.coder;
    
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;

    public class BitmapScale9Grid 
    {

        public static var _defaultBitmapData_:BitmapData = new BitmapData(10, 10, false, 0xFFFFFF);

        private var _bitmapdata:BitmapData;
        private var _width:int;
        private var _height:int;
        private var _scale9Grid:Rectangle;
        private var _cutRect:Rectangle;
        private var _scale9GridRect:Array;
        private var _x:int = 0;
        private var _y:int = 0;

        public function BitmapScale9Grid(_arg_1:BitmapData=null, _arg_2:Rectangle=null)
        {
            this._bitmapdata = _arg_1;
            if (this._bitmapdata == null){
                this._bitmapdata = _defaultBitmapData_;
            };
            this._scale9Grid = _arg_2;
            if (this._scale9Grid == null){
                this._scale9Grid = new Rectangle(80, 30, 121, 340);
            };
            this.updataCutRectangle();
        }

        public function set x(_arg_1:int):void
        {
            this._x = _arg_1;
            this.updataCutRectangle();
        }

        public function set y(_arg_1:int):void
        {
            this._y = _arg_1;
            this.updataCutRectangle();
        }

        public function setPos(_arg_1:int, _arg_2:int):void
        {
            this._x = _arg_1;
            this._y = _arg_2;
            this.updataCutRectangle();
        }

        public function get curRect():Rectangle
        {
            return (this._cutRect);
        }

        coder function reander():void
        {
            this.updataCutRectangle();
        }

        private function updataCutRectangle():void
        {
            var _local_13:int;
            var _local_14:Matrix;
            var _local_15:Number;
            var _local_16:Number;
            if ((((this._bitmapdata == null)) || ((((this._bitmapdata.width == 0)) && ((this._bitmapdata.height == 0)))))){
                return;
            };
            var _local_1:Rectangle = this._bitmapdata.rect;
            var _local_2:int = ((this._width - this._scale9Grid.x) - (_local_1.right - this._scale9Grid.right));
            var _local_3:int = ((this._height - this._scale9Grid.y) - (_local_1.bottom - this._scale9Grid.bottom));
            if ((_local_2 < 0)){
                _local_2 = 0;
            };
            if ((_local_3 < 0)){
                _local_3 = 0;
            };
            this._cutRect = new Rectangle(this._scale9Grid.x, this._scale9Grid.y, _local_2, _local_3);
            var _local_4:Vector.<int> = new <int>[0, this._scale9Grid.x, this._scale9Grid.right];
            var _local_5:Vector.<int> = new <int>[0, this._scale9Grid.y, this._scale9Grid.bottom];
            var _local_6:Vector.<int> = new <int>[this._scale9Grid.x, this._scale9Grid.width, (_local_1.right - this._scale9Grid.right)];
            var _local_7:Vector.<int> = new <int>[this._scale9Grid.y, this._scale9Grid.height, (_local_1.bottom - this._scale9Grid.bottom)];
            var _local_8:Vector.<int> = new <int>[0, this._cutRect.x, this._cutRect.right];
            var _local_9:Vector.<int> = new <int>[0, this._cutRect.y, this._cutRect.bottom];
            var _local_10:Vector.<int> = new <int>[this._cutRect.x, this._cutRect.width, (_local_1.right - this._scale9Grid.right)];
            var _local_11:Vector.<int> = new <int>[this._cutRect.y, this._cutRect.height, (_local_1.bottom - this._scale9Grid.bottom)];
            this._scale9GridRect = new Array();
            var _local_12:int;
            while (_local_12 < 3) {
                _local_13 = 0;
                while (_local_13 < 3) {
                    _local_14 = new Matrix();
                    _local_15 = (_local_10[_local_12] / _local_6[_local_12]);
                    _local_16 = (_local_11[_local_13] / _local_7[_local_13]);
                    _local_14.scale(_local_15, _local_16);
                    _local_14.ty = ((_local_9[_local_13] - _local_5[_local_13]) + this._y);
                    _local_14.tx = ((_local_8[_local_12] - _local_4[_local_12]) + this._x);
                    if (_local_12 == 1){
                        _local_14.tx = (((1 - _local_15) * _local_8[1]) + this._x);
                    };
                    if (_local_13 == 1){
                        _local_14.ty = (((1 - _local_16) * _local_9[1]) + this._y);
                    };
                    this._scale9GridRect.push({
                        "rect":new Rectangle(_local_8[_local_12], _local_9[_local_13], _local_10[_local_12], _local_11[_local_13]),
                        "matrix":_local_14
                    });
                    _local_13++;
                };
                _local_12++;
            };
        }

        public function set width(_arg_1:Number):void
        {
            this._width = _arg_1;
            this.updataCutRectangle();
        }

        public function set height(_arg_1:Number):void
        {
            this._height = _arg_1;
            this.updataCutRectangle();
        }

        public function setup(_arg_1:BitmapData, _arg_2:Rectangle):void
        {
            this.bitmapData = _arg_1;
            this.scale9Grid = _arg_2;
        }

        public function set scale9Grid(_arg_1:Rectangle):void
        {
            this._scale9Grid = _arg_1;
            this.updataCutRectangle();
        }

        public function get scale9Grid():Rectangle
        {
            return (this._scale9Grid);
        }

        public function set rect(_arg_1:Rectangle):void
        {
            this._x = _arg_1.x;
            this._y = _arg_1.y;
            this._width = _arg_1.width;
            this._height = _arg_1.height;
            this.updataCutRectangle();
        }

        public function set bitmapData(_arg_1:BitmapData):void
        {
            this._bitmapdata = _arg_1;
            this.updataCutRectangle();
        }

        public function draw(_arg_1:Graphics, _arg_2:Boolean=true, _arg_3:Boolean=true):void
        {
            var _local_5:Rectangle;
            var _local_6:Matrix;
            if (_arg_2){
                _arg_1.clear();
            };
            var _local_4:int;
            while (_local_4 < 9) {
                _local_5 = this._scale9GridRect[_local_4].rect;
                _local_6 = this._scale9GridRect[_local_4].matrix;
                _arg_1.beginBitmapFill(this._bitmapdata, _local_6, false, true);
                if (!((!(_arg_3)) && ((_local_4 == 4)))){
                    _arg_1.drawRect((_local_5.x + this._x), (_local_5.y + this._y), _local_5.width, _local_5.height);
                };
                _local_4++;
            };
        }

        public function setSize(_arg_1:int, _arg_2:int):void
        {
            this._width = _arg_1;
            this._height = _arg_2;
            this.updataCutRectangle();
        }


    }
}//package com.engine.core.view

