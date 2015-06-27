// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.utils.astar.SquareAstarData

package com.engine.utils.astar
{
    import com.engine.core.tile.square.SquarePt;

    public class SquareAstarData 
    {

        public var key:String;
        public var pt:SquarePt;
        public var G:int = 0;
        public var F:int = 0;
        public var parent:SquareAstarData;

        public function SquareAstarData(_arg_1:int, _arg_2:int, _arg_3:SquarePt)
        {
            this.G = _arg_1;
            this.F = _arg_2;
            if (_arg_3){
                this.key = _arg_3.key;
            };
            this.pt = _arg_3;
        }

    }
}//package com.engine.utils.astar

