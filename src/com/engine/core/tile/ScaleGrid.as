// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.tile.ScaleGrid

package com.engine.core.tile
{
    import flash.utils.Dictionary;

    public class ScaleGrid 
    {

        private var _tc:Cell;
        private var _ct:Cell;
        private var _cr:Cell;
        private var _bc:Cell;
        private var _tl:Cell;
        private var _tr:Cell;
        private var _bl:Cell;
        private var _br:Cell;
        private var _cc:Cell;
        private var _value:Pt;


        public function get cc():Cell
        {
            return (this._cc);
        }

        public function setValue(_arg_1:Pt, _arg_2:Dictionary):void
        {
            var _local_4:int;
            var _local_5:int;
            if (!_arg_1){
                return;
            };
            this._value = _arg_1;
            var _local_3:Dictionary = _arg_2;
            if (_local_3){
                _local_4 = _arg_1.x;
                _local_5 = _arg_1.z;
                this._cc = _local_3[((_local_4 + "|0|") + _local_5)];
                this._tc = _local_3[((_local_4 + "|0|") + (_local_5 - 1))];
                this._ct = _local_3[(((_local_4 - 1) + "|0|") + _local_5)];
                this._cr = _local_3[(((_local_4 + 1) + "|0|") + _local_5)];
                this._bc = _local_3[((_local_4 + "|0|") + (_local_5 + 1))];
                this._tl = _local_3[(((_local_4 - 1) + "|0|") + (_local_5 - 1))];
                this._tr = _local_3[(((_local_4 + 1) + "|0|") + (_local_5 - 1))];
                this._bl = _local_3[(((_local_4 - 1) + "|0|") + (_local_5 + 1))];
                this._br = _local_3[(((_local_4 + 1) + "|0|") + (_local_5 + 1))];
            };
        }

        public function get value():Pt
        {
            return (this._value);
        }

        public function get br():Cell
        {
            return (this._br);
        }

        public function get bl():Cell
        {
            return (this._bl);
        }

        public function get tr():Cell
        {
            return (this._tr);
        }

        public function get tl():Cell
        {
            return (this._tl);
        }

        public function get bc():Cell
        {
            return (this._bc);
        }

        public function get cr():Cell
        {
            return (this._cr);
        }

        public function get ct():Cell
        {
            return (this._ct);
        }

        public function get tc():Cell
        {
            return (this._tc);
        }

        public function passCell():Array
        {
            var _local_1:Array = [];
            if (this.tc){
                _local_1.push(this.tc);
            };
            if (this.tl){
                _local_1.push(this.tl);
            };
            if (this.tr){
                _local_1.push(this.tr);
            };
            if (this.cr){
                _local_1.push(this.cr);
            };
            if (this.ct){
                _local_1.push(this.ct);
            };
            if (this.bc){
                _local_1.push(this.bc);
            };
            if (this.bl){
                _local_1.push(this.bl);
            };
            if (this.br){
                _local_1.push(this.br);
            };
            return (_local_1);
        }


    }
}//package com.engine.core.tile

