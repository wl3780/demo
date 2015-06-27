// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.model.map.SquareMapData

package com.engine.core.model.map
{
    import com.engine.core.model.Proto;
    import com.engine.core.tile.square.Square;
    import com.engine.core.tile.square.SquarePt;
    import flash.utils.ByteArray;
    import com.engine.core.tile.square.SquareGroup;
    import com.engine.utils.Hash;

    public class SquareMapData extends Proto 
    {

        public var map_id:int;
        public var pixel_width:int;
        public var pixel_height:int;
        public var len:int;
        public var items:Array;
        public var sceneData:Object;
        public var width:int;
        public var height:int;
        public var pixel_x:int;
        public var pixel_y:int;


        public function prasePro(_arg_1:int, _arg_2:int, _arg_3:int):Square
        {
            var _local_4:uint;
            var _local_5:Square = Square.createSquare();
            var _local_6:String = _arg_3.toString();
            _local_5.type = int(_local_6.slice(1, 2));
            _local_5.isSafe = Boolean(int(_local_6.slice(2, 3)));
            _local_5.isSell = Boolean(int(_local_6.slice(3, 4)));
            _local_5.isAlpha = Boolean(int(_local_6.slice(4, 5)));
            _local_5.setIndex(new SquarePt(_arg_1, _arg_2));
            if ((_local_5.type > 0)){
                _local_4 = 0xFF00;
            } else {
                _local_4 = 0xFF0000;
            };
            return (_local_5);
        }

        public function praseLayerpro(_arg_1:int, _arg_2:int, _arg_3:int, _arg_4:ByteArray):ItemData
        {
            var _local_5:ItemData = new ItemData();
            _local_5.x = _arg_2;
            _local_5.y = _arg_3;
            _local_5.item_id = _arg_1;
            _local_5.layer = _arg_4.readShort();
            _local_5.depth = _arg_4.readShort();
            return (_local_5);
        }

        public function uncode(_arg_1:ByteArray, _arg_2:Hash=null):void
        {
            var _local_3:Square;
            var _local_4:int;
            var _local_5:ItemData;
            var _local_6:int;
            var _local_7:int;
            var _local_8:int;
            var _local_9:int;
            var _local_10:int;
            if (_arg_1 == null){
                return;
            };
            this.items = [];
            _arg_1.position = 0;
            try {
                _arg_1.uncompress();
            } catch(e:Error) {
            };
            _arg_1.position = 0;
            this.map_id = _arg_1.readShort();
            this.pixel_x = _arg_1.readShort();
            this.pixel_y = _arg_1.readShort();
            this.pixel_width = _arg_1.readShort();
            this.pixel_height = _arg_1.readShort();
            var _local_11:int = _arg_1.readInt();
            var _local_12:SquareGroup = SquareGroup.getInstance();
            _local_4 = 0;
            while (_local_4 < _local_11) {
                _local_6 = _arg_1.readShort();
                _local_7 = _arg_1.readShort();
                _local_3 = this.prasePro(_local_6, _local_7, _arg_1.readShort());
                if (_arg_2){
                    _arg_2.put(_local_3.key, _local_3);
                } else {
                    _local_12.put(_local_3);
                };
                _local_4++;
            };
            _local_11 = _arg_1.readShort();
            _local_4 = 0;
            while (_local_4 < _local_11) {
                _local_8 = _arg_1.readInt();
                _local_9 = _arg_1.readInt();
                _local_10 = _arg_1.readInt();
                _local_5 = this.praseLayerpro(_local_8, _local_9, _local_10, _arg_1);
                this.items.push(_local_5);
                _local_4++;
            };
        }


    }
}//package com.engine.core.model.map

