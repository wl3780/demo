// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.items.BloodBar

package com.engine.core.view.items
{
    import flash.display.Shape;
    import flash.display.BitmapData;

    public class BloodBar extends Shape 
    {

        private var bmd:BitmapData;
        private var currValue:Number;
        private var maxValue:Number;
        private var percent:Number = 0;
        private var _width:Number = 0;
        private var _height:Number = 0;
        private var _bitmapData:BitmapData;
        private var _overBitmapData:BitmapData;

        public function BloodBar()
        {
            this.width = 50;
            this.height = 5;
            this.cacheAsBitmap = true;
        }

        public function set overBitmapData(_arg_1:BitmapData):void
        {
            this._overBitmapData = _arg_1;
            this.onRender();
        }

        public function set bitmapData(_arg_1:BitmapData):void
        {
            this._bitmapData = _arg_1;
            this.onRender();
        }

        public function setValue(_arg_1:int, _arg_2:int):void
        {
            this.currValue = _arg_1;
            this.maxValue = _arg_2;
            this.percent = (int(((_arg_1 / _arg_2) * 100)) / 100);
            if (this.percent > 1){
                this.percent = 1;
            };
            if (this.percent < 0){
                this.percent = 0;
            };
            if (int(((_arg_1 / _arg_2) * 100)) == 0){
                this.percent = 0;
            };
            this.onRender();
        }

        public function onRender():void
        {
            this.graphics.clear();
            if (this._bitmapData){
                this.graphics.beginBitmapFill(this._bitmapData);
                this.graphics.drawRect(0, 2, (this.width * this.percent), this.height);
            } else {
                this.graphics.beginFill(0xFF0000);
                this.graphics.drawRect(0, 2, (this.width * this.percent), this.height);
            };
            this.graphics.endFill();
            if (this._overBitmapData){
                this.graphics.lineStyle(0.25, 0, 0);
                this.graphics.beginBitmapFill(this._bitmapData);
                this.graphics.drawRect(0, 2, this.width, this.height);
                this.graphics.endFill();
            } else {
                this.graphics.lineStyle(0.25, 0);
                this.graphics.drawRect(0, 2, this.width, this.height);
                this.graphics.endFill();
            };
        }

        override public function set width(_arg_1:Number):void
        {
            this._width = _arg_1;
            this.onRender();
        }

        override public function set height(_arg_1:Number):void
        {
            this._height = _arg_1;
            this.onRender();
        }

        override public function get width():Number
        {
            return (this._width);
        }

        override public function get height():Number
        {
            return (this._height);
        }


    }
}//package com.engine.core.view.items

