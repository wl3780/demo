// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.quadTree.NodeTree

package com.engine.core.view.quadTree
{
    import com.engine.core.model.Proto;
    import flash.geom.Rectangle;
    import com.engine.utils.Hash;
    import com.engine.namespaces.coder;
    import com.engine.core.Core;
    import __AS3__.vec.Vector;
    import flash.utils.Dictionary;

    public class NodeTree extends Proto 
    {

        public static var minWidth:int;
        public static var minHeight:int;
        public static var minSize:int;
        public static var doubleMinWidth:int;
        public static var doubleMinHeight:int;

        private var _scopeRect:Rectangle;
        private var _depth:int;
        private var _rulerValue:int;
        private var _topNode:Node;
        private var _hash:Hash;
        public var initialized:Boolean;

        public function NodeTree(_arg_1:String)
        {
            this.coder::id = _arg_1;
        }

        public static function takeDepth(_arg_1:Number, _arg_2:int):Number
        {
            var _local_3:Number;
            var _local_4:int = 1;
            while (true) {
                _local_3 = Math.round((_arg_1 / Math.pow(2, _local_4)));
                if (_local_3 <= _arg_2){
                    return (_local_4);
                };
                _local_4++;
            };
            return (-1); //dead code
        }


        public function reset():void
        {
            this._topNode.dispose();
            this._topNode = null;
        }

        public function get nodes():Hash
        {
            return (this._hash);
        }

        public function build(_arg_1:Rectangle, _arg_2:int=50, _arg_3:Vector.<INoder>=null):void
        {
            var _local_6:int;
            var _local_7:int;
            NodeTreePool.getInstance().put(this);
            this._scopeRect = _arg_1;
            this._hash = new Hash();
            if (((_arg_1.width - _arg_1.height) > 0)){
                this._rulerValue = _arg_1.width;
            } else {
                this._rulerValue = _arg_1.height;
            };
            this._depth = takeDepth(this._rulerValue, _arg_2);
            var _local_4:int = Math.round(Math.pow(2, this._depth));
            _arg_1.width = (Math.round((_arg_1.width / _local_4)) * _local_4);
            _arg_1.height = (Math.round((_arg_1.height / _local_4)) * _local_4);
            NodeTree.minSize = (this._rulerValue / _local_4);
            minWidth = (_arg_1.width / _local_4);
            minHeight = (_arg_1.height / _local_4);
            doubleMinWidth = (minWidth * 2);
            doubleMinHeight = (minHeight * 2);
            this._topNode = new Node();
            if (_arg_3){
                _local_6 = _arg_3.length;
                _local_7 = 0;
                while (_local_7 < _local_6) {
                    _arg_3[_local_7].coder::_tid = this.id;
                    this._topNode.addChild(_arg_3[_local_7].node.id, _arg_3[_local_7]);
                    _local_7++;
                };
            };
            var _local_5:Number = Core.delayTime;
            this._topNode.setUp(this.id, null, _arg_1, this._depth);
            this._topNode.coder::id = ((int((_arg_1.x + (_arg_1.width / 2))) + Core.SIGN) + int((_arg_1.y + (_arg_1.height / 2))));
            this.initialized = true;
        }

        public function find(_arg_1:Rectangle, _arg_2:Boolean=false, _arg_3:Number=20):Array
        {
            var _local_4:Dictionary;
            var _local_5:Array;
            var _local_6:int;
            if (this.initialized){
                _local_4 = new Dictionary();
                _local_5 = [];
                if ((_arg_3 <= minSize)){
                    _arg_3 = minSize;
                };
                _local_6 = NodeTree.takeDepth(this._rulerValue, _arg_3);
                this.cycleFind(_local_5, _local_4, this._topNode, _arg_1, ((this._depth - _local_6) + 1), _arg_2);
                return (_local_5);
            };
            return (null);
        }

        private function cycleFind(_arg_1:Array, _arg_2:Dictionary, _arg_3:Node, _arg_4:Rectangle, _arg_5:int, _arg_6:Boolean):void
        {
            var _local_7:Dictionary;
            var _local_8:INoder;
            if (_arg_3){
                if (((_arg_4.intersects(_arg_3.rect)) && ((_arg_3.length > 0)))){
                    if (_arg_3.coder::_depth_ == _arg_5){
                        _local_7 = _arg_3.dic;
                        for each (_local_8 in _local_7) {
                            if (_local_8.visible){
                                if (_arg_6){
                                    if (_arg_4.intersects(_local_8.getBounds(Object(_local_8).parent))){
                                        if (_arg_2[_local_8.id] == null){
                                            _arg_2[_local_8.id] = _local_8;
                                            _arg_1.push(_local_8);
                                        };
                                    };
                                } else {
                                    if (_arg_2[_local_8.id] == null){
                                        _arg_2[_local_8.id] = _local_8;
                                        _arg_1.push(_local_8);
                                    };
                                };
                            };
                        };
                    } else {
                        if (_arg_3.nodeA){
                            this.cycleFind(_arg_1, _arg_2, _arg_3.nodeA, _arg_4, _arg_5, _arg_6);
                        };
                        if (_arg_3.nodeB){
                            this.cycleFind(_arg_1, _arg_2, _arg_3.nodeB, _arg_4, _arg_5, _arg_6);
                        };
                        if (_arg_3.nodeC){
                            this.cycleFind(_arg_1, _arg_2, _arg_3.nodeC, _arg_4, _arg_5, _arg_6);
                        };
                        if (_arg_3.nodeD){
                            this.cycleFind(_arg_1, _arg_2, _arg_3.nodeD, _arg_4, _arg_5, _arg_6);
                        };
                    };
                };
            };
        }

        private function project():void
        {
        }

        public function addNode(_arg_1:String, _arg_2:Node):void
        {
            this._hash.put(_arg_1, _arg_2);
        }

        public function removeNode(_arg_1:String):void
        {
            this._hash.remove(_arg_1);
        }

        public function takeNode(_arg_1:String):Node
        {
            return ((this._hash.take(_arg_1) as Node));
        }


    }
}//package com.engine.core.view.quadTree

