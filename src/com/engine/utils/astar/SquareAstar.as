// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.utils.astar.SquareAstar

package com.engine.utils.astar
{
    import flash.display.Graphics;
    import flash.utils.Dictionary;
    import com.engine.core.tile.square.SquarePt;
    import com.engine.core.tile.square.Square;
    import flash.utils.getTimer;
    import flash.geom.Point;

    public class SquareAstar 
    {

        private static const COST_STRAIGHT:int = 10;
        private static const COST_DIAGONAL:int = 14;
        private static const DIR_TC:String = "tc";
        private static const DIR_CT:String = "ct";
        private static const DIR_CR:String = "cr";
        private static const DIR_BC:String = "bc";

        public var g:Graphics;
        private var nonce:SquareAstarData;
        private var isFinish:Boolean;
        private var G:int;
        private var source:Dictionary;
        private var startPoint:SquarePt;
        private var endPoint:SquarePt;
        private var colsePath:Dictionary;
        private var colseArray:Array;
        private var openPath:Dictionary;
        private var openArray:Array;
        private var pathArray:Array;
        private var canTL:Boolean;
        private var canTR:Boolean;
        private var canBL:Boolean;
        private var canBR:Boolean;
        private var canTC:Boolean;
        private var canCT:Boolean;
        private var canCR:Boolean;
        private var canBC:Boolean;
        private var closeLength:int;
        public var mode:int = 1;


        public function getPath(_arg_1:Dictionary, _arg_2:SquarePt, _arg_3:SquarePt, _arg_4:Boolean=true, _arg_5:int=10000):Array
        {
            var _local_8:Square;
            var _local_9:Square;
            if (_arg_1[_arg_2.key]){
                _local_8 = (_arg_1[_arg_2.key] as Square);
                _local_9 = (_arg_1[_arg_3.key] as Square);
                if (((_local_8) && (_local_9))){
                    if ((((_local_8.type == 2)) && ((_local_9.type == 2)))){
                        this.mode = 2;
                    } else {
                        this.mode = 1;
                    };
                } else {
                    this.mode = 1;
                };
            };
            if (((!(_arg_1[_arg_2.key])) || ((((((this.mode == 1)) && (_arg_1[_arg_2.key]))) && ((_arg_1[_arg_2.key].type == 2)))))){
                return ([]);
            };
            var _local_6:Number = getTimer();
            this.reSet();
            this.startPoint = this.cycleCheck(_arg_1, _arg_2, 0);
            this.endPoint = this.cycleCheck(_arg_1, _arg_3, 0);
            this.source = _arg_1;
            this.nonce = new SquareAstarData(0, 0, this.startPoint);
            this.nonce.parent = this.nonce;
            this.colsePath[this.nonce.key] = this.nonce;
            while (this.isFinish) {
                this.getScale9Grid(_arg_1, this.nonce, this.endPoint, _arg_5);
            };
            var _local_7:Array = this.cleanArray();
            log("saiman", "*****************寻路时间", (getTimer() - _local_6), "路径长: ", _local_7.length, "*******************", "\n\n");
            return (_local_7);
        }

        public function stop():void
        {
            this.isFinish = false;
        }

        private function cycleCheck(_arg_1:Dictionary, _arg_2:SquarePt, _arg_3:int):SquarePt
        {
            var _local_4:int;
            var _local_5:int;
            var _local_6:int;
            var _local_7:Square;
            var _local_8:Array;
            var _local_9:String;
            var _local_10:Square;
            var _local_11:int;
            var _local_12:int;
            if ((this.mode == 1)){
                _local_4 = 2;
            } else {
                _local_4 = 1;
            };
            if ((((((_arg_1[_arg_2.key] == null)) || ((_arg_1[_arg_2.key].type == 0)))) || ((_arg_1[_arg_2.key].type == _local_4)))){
                _local_5 = _arg_2.x;
                _local_6 = _arg_2.y;
                _local_7 = new Square();
                _local_7.setIndex(_arg_2);
                _local_11 = (_local_5 - (_arg_3 + 1));
                while (_local_11 <= (_local_5 + (_arg_3 + 1))) {
                    _local_8 = [];
                    _local_12 = (_local_6 - (_arg_3 + 1));
                    while (_local_12 <= (_local_6 + (_arg_3 + 1))) {
                        _local_9 = ((_local_11 + "|") + _local_12);
                        if (_local_9 != _arg_2.key){
                            _local_10 = _arg_1[_local_9];
                            if (((((!((_local_10 == null))) && (!((_local_10.type == 0))))) && (!((_local_10.type == _local_4))))){
                                _local_8.push({
                                    "square":_local_10,
                                    "dis":Point.distance(_local_10.midVertex, _local_7.midVertex)
                                });
                                return (_local_10.index);
                            };
                        };
                        _local_12++;
                    };
                    if (_local_8.length > 0){
                        _local_8.sortOn("dis", Array.NUMERIC);
                        return (_local_8[0].square.index);
                    };
                    _local_11++;
                };
                if (_arg_3 > 8){
                    this.isFinish = false;
                    return (_arg_2);
                };
                return (this.cycleCheck(_arg_1, _arg_2, (_arg_3 + 1)));
            };
            return (_arg_2);
        }

        private function getDis(_arg_1:SquarePt, _arg_2:SquarePt):int
        {
            var _local_3:int = (_arg_2.x - _arg_1.x);
            if ((_local_3 < 0)){
                _local_3 = -(_local_3);
            };
            var _local_4:int = (_arg_2.y - _arg_1.y);
            if ((_local_4 < 0)){
                _local_4 = -(_local_4);
            };
            return ((_local_3 + _local_4));
        }

        private function pass(_arg_1:Square):Boolean
        {
            var _local_3:int;
            var _local_2:int = _arg_1.type;
            if (_local_2 == 0){
                return (false);
            };
            if ((this.mode == 1)){
                _local_3 = 1;
            } else {
                _local_3 = 2;
            };
            if (_local_2 == _local_3){
                return (true);
            };
            return (false);
        }

        private function stratght(_arg_1:Square, _arg_2:SquarePt, _arg_3:String):void
        {
            var _local_4:String;
            var _local_5:SquarePt;
            var _local_6:int;
            var _local_7:int;
            var _local_8:int;
            var _local_9:int;
            var _local_10:int;
            var _local_11:int;
            var _local_12:int;
            var _local_13:SquareAstarData;
            var _local_14:SquareAstarData;
            var _local_15:SquareAstarData;
            if (_arg_1 != null){
                if (this.pass(_arg_1)){
                    _local_4 = _arg_1.key;
                    _local_5 = _arg_1.index;
                    _local_6 = _local_5.x;
                    _local_7 = _local_5.y;
                    _local_8 = (_arg_2.x - _local_6);
                    if ((_local_8 < 0)){
                        _local_8 = -(_local_8);
                    };
                    _local_9 = (_arg_2.y - _local_7);
                    if ((_local_9 < 0)){
                        _local_9 = -(_local_9);
                    };
                    _local_10 = ((_local_8 + _local_9) * 10);
                    _local_11 = (COST_STRAIGHT + this.G);
                    _local_12 = (_local_11 + _local_10);
                    _local_13 = new SquareAstarData(_local_11, _local_12, _local_5);
                    if ((_local_13.parent == null)){
                        _local_13.parent = this.nonce;
                    };
                    _local_14 = this.openPath[_local_4];
                    _local_15 = this.colsePath[_local_4];
                    if ((((_local_14 == null)) && ((_local_15 == null)))){
                        this.openPath[_local_4] = _local_13;
                        this.openArray.push(_local_13);
                    } else {
                        if (_local_14 != null){
                            if ((_local_13.F < _local_14.F)){
                                this.openPath[_local_4] = _local_13;
                            };
                        };
                    };
                } else {
                    if (_arg_3 == DIR_TC){
                        this.canTC = false;
                        this.canTL = false;
                        this.canTR = false;
                    } else {
                        if (_arg_3 == DIR_CT){
                            this.canCT = false;
                            this.canBL = false;
                            this.canTL = false;
                        } else {
                            if (_arg_3 == DIR_CR){
                                this.canCR = false;
                                this.canTR = false;
                                this.canBR = false;
                            } else {
                                if (_arg_3 == DIR_BC){
                                    this.canBC = false;
                                    this.canBR = false;
                                    this.canBL = false;
                                };
                            };
                        };
                    };
                };
            } else {
                if (_arg_3 == DIR_TC){
                    this.canTC = false;
                    this.canTL = false;
                    this.canTR = false;
                } else {
                    if (_arg_3 == DIR_CT){
                        this.canCT = false;
                    } else {
                        if (_arg_3 == DIR_CR){
                            this.canCR = false;
                        } else {
                            if (_arg_3 == DIR_BC){
                                this.canBC = false;
                            };
                        };
                    };
                };
            };
        }

        private function diagonal(_arg_1:Square, _arg_2:SquarePt, _arg_3:Boolean):void
        {
            var _local_4:String;
            var _local_5:SquarePt;
            var _local_6:int;
            var _local_7:int;
            var _local_8:int;
            var _local_9:int;
            var _local_10:SquareAstarData;
            var _local_11:SquareAstarData;
            var _local_12:SquareAstarData;
            if (((_arg_3) && (!((_arg_1 == null))))){
                if (this.pass(_arg_1)){
                    _local_4 = _arg_1.key;
                    _local_5 = _arg_1.index;
                    _local_6 = (_arg_2.x - _local_5.x);
                    if ((_local_6 < 0)){
                        _local_6 = -(_local_6);
                    };
                    _local_7 = (this.endPoint.y - _local_5.y);
                    if ((_local_7 < 0)){
                        _local_7 = -(_local_7);
                    };
                    _local_8 = ((_local_6 + _local_7) * 10);
                    _local_9 = (COST_DIAGONAL + this.G);
                    _local_10 = new SquareAstarData(_local_9, (_local_9 + _local_8), _local_5);
                    if ((_local_10.parent == null)){
                        _local_10.parent = this.nonce;
                    };
                    _local_11 = this.openPath[_local_4];
                    _local_12 = this.colsePath[_local_4];
                    if ((((_local_11 == null)) && ((_local_12 == null)))){
                        this.openPath[_local_4] = _local_10;
                        this.openArray.push(_local_10);
                    } else {
                        if (_local_11 != null){
                            if ((_local_10.F < _local_11.F)){
                                this.openPath[_local_4] = _local_10;
                            };
                        };
                    };
                };
            };
        }

        private function getScale9Grid(_arg_1:Dictionary, _arg_2:SquareAstarData, _arg_3:SquarePt, _arg_4:int):void
        {
            this.canBL = true;
            this.canBR = true;
            this.canTL = true;
            this.canTR = true;
            this.canCT = true;
            this.canCR = true;
            this.canCT = true;
            this.canBC = true;
            var _local_5:SquarePt = _arg_2.pt;
            var _local_6:int = _local_5.x;
            var _local_7:int = _local_5.y;
            var _local_8:int = (_local_6 + 1);
            var _local_9:int = (_local_7 + 1);
            var _local_10:int = (_local_6 - 1);
            var _local_11:int = (_local_7 - 1);
            var _local_12:Square = _arg_1[((_local_10 + "|") + _local_11)];
            var _local_13:Square = _arg_1[((_local_8 + "|") + _local_11)];
            var _local_14:Square = _arg_1[((_local_10 + "|") + _local_9)];
            var _local_15:Square = _arg_1[((_local_8 + "|") + _local_9)];
            var _local_16:Square = _arg_1[((_local_6 + "|") + _local_11)];
            var _local_17:Square = _arg_1[((_local_10 + "|") + _local_7)];
            var _local_18:Square = _arg_1[((_local_8 + "|") + _local_7)];
            var _local_19:Square = _arg_1[((_local_6 + "|") + _local_9)];
            if (_local_16){
                this.stratght(_local_16, _arg_3, DIR_TC);
            };
            if (_local_17){
                this.stratght(_local_17, _arg_3, DIR_CT);
            };
            if (_local_18){
                this.stratght(_local_18, _arg_3, DIR_CR);
            };
            if (_local_19){
                this.stratght(_local_19, _arg_3, DIR_BC);
            };
            if (_local_12){
                this.diagonal(_local_12, _arg_3, this.canTL);
            };
            if (_local_13){
                this.diagonal(_local_13, _arg_3, this.canTR);
            };
            if (_local_14){
                this.diagonal(_local_14, _arg_3, this.canBL);
            };
            if (_local_15){
                this.diagonal(_local_15, _arg_3, this.canBR);
            };
            var _local_20:int = this.openArray.length;
            if ((((_local_20 == 0)) || ((((((((((((((((_local_16 == null)) && ((_local_17 == null)))) && ((_local_18 == null)))) && ((_local_19 == null)))) && ((_local_12 == null)))) && ((_local_13 == null)))) && ((_local_14 == null)))) && ((_local_15 == null)))))){
                this.isFinish = false;
                return;
            };
            var _local_21:int;
            var _local_22:int;
            while (_local_22 < _local_20) {
                if (_local_22 == 0){
                    _arg_2 = this.openArray[_local_22];
                } else {
                    if (this.openArray[_local_22].F < _arg_2.F){
                        _arg_2 = this.openArray[_local_22];
                        _local_21 = _local_22;
                    };
                };
                _local_22++;
            };
            this.nonce = _arg_2;
            this.openArray.splice(_local_21, 1);
            var _local_23:String = this.nonce.key;
            if (this.colsePath[_local_23] == null){
                this.colsePath[_local_23] = this.nonce;
                this.closeLength++;
                if (this.closeLength > _arg_4){
                    this.isFinish = false;
                };
            };
            if (this.nonce.key == _arg_3.key){
                this.isFinish = false;
            };
            this.G = this.nonce.G;
        }

        private function cleanArray():Array
        {
            var _local_3:Number;
            var _local_4:SquarePt;
            var _local_5:int;
            var _local_6:int;
            var _local_7:int;
            var _local_8:SquareAstarData;
            var _local_9:Boolean;
            var _local_10:int;
            this.pathArray = new Array();
            var _local_1:String = this.endPoint.key;
            if (this.colsePath[_local_1] == null){
                _local_3 = -1;
                for each (_local_8 in this.colsePath) {
                    _local_4 = _local_8.pt;
                    _local_5 = (this.endPoint.x - _local_4.x);
                    if ((_local_5 < 0)){
                        _local_5 = -(_local_5);
                    };
                    _local_6 = (this.endPoint.y - _local_4.y);
                    if ((_local_6 < 0)){
                        _local_6 = -(_local_6);
                    };
                    _local_7 = (_local_5 + _local_6);
                    if (_local_3 == -1){
                        _local_3 = _local_7;
                        _local_1 = _local_4.key;
                    } else {
                        if (_local_7 < _local_3){
                            _local_3 = _local_7;
                            _local_1 = _local_4.key;
                        };
                    };
                };
            };
            var _local_2:SquareAstarData = this.colsePath[_local_1];
            if (_local_2 != null){
                this.pathArray.unshift(_local_2.pt.pixelsPoint);
                this.pathArray.unshift(_local_2.parent.pt.pixelsPoint);
                _local_9 = true;
                _local_10 = 0;
                while (_local_9) {
                    _local_1 = this.colsePath[_local_1].parent.key;
                    if ((((_local_1 == this.startPoint.key)) || ((_local_10 > 10000)))){
                        _local_9 = false;
                        break;
                    };
                    this.pathArray.unshift(this.colsePath[_local_1].parent.pt.pixelsPoint);
                    _local_10++;
                };
            };
            return (this.pathArray);
        }

        private function reSet():void
        {
            this.pathArray = [];
            this.source = new Dictionary();
            this.colsePath = new Dictionary();
            this.colseArray = [];
            this.openPath = new Dictionary();
            this.openArray = [];
            this.G = 0;
            this.nonce = null;
            this.canTL = true;
            this.canTR = true;
            this.canBL = true;
            this.canBR = true;
            this.isFinish = true;
            this.closeLength = 0;
        }


    }
}//package com.engine.utils.astar

