// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.quadTree.Node

package com.engine.core.view.quadTree
{
    import com.engine.core.model.Proto;
    import com.engine.namespaces.coder;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    import com.engine.core.Core;
    import com.engine.utils.Hash;
    import flash.display.Graphics;

    use namespace coder;

    public class Node extends Proto 
    {

        coder var _tid_:String;
        coder var _depth_:int;
        coder var _rect:Rectangle;
        private var _nodeA:Node;
        private var _nodeB:Node;
        private var _nodeC:Node;
        private var _nodeD:Node;
        private var _nodes:Dictionary;
        private var _length:int;
        private var _tree:NodeTree;

        public function Node()
        {
            this._nodes = new Dictionary();
        }

        public function get rect():Rectangle
        {
            return (this.coder::_rect);
        }

        public function setUp(_arg_1:String, _arg_2:String, _arg_3:Rectangle, _arg_4:int):void
        {
            var _local_5:Rectangle;
            var _local_6:int;
            this.coder::_depth_ = _arg_4;
            this.coder::_tid_ = _arg_1;
            this.coder::_rect = _arg_3;
            _local_6 = (_arg_4 - 1);
            var _local_7:int = _arg_3.x;
            var _local_8:int = _arg_3.y;
            var _local_9:Number = _arg_3.width;
            var _local_10:Number = _arg_3.height;
            var _local_11:int = (_local_9 / 2);
            var _local_12:int = (_local_10 / 2);
            this.$id = (((_local_7 + _local_11) + Core.SIGN) + (_local_8 + _local_12));
            this.$oid = _arg_2;
            this._tree = (NodeTreePool.getInstance().take(_arg_1) as NodeTree);
            this._tree.addNode(this.$id, this);
            if (_local_6 > 0){
                if (this._nodeA == null){
                    this._nodeA = new Node();
                    _local_5 = new Rectangle(_local_7, _local_8, _local_11, _local_12);
                    this._nodeA.setUp(_arg_1, this.$id, _local_5, _local_6);
                };
                if (this._nodeB == null){
                    this._nodeB = new Node();
                    _local_5 = new Rectangle(_local_7, (_local_8 + _local_12), _local_11, _local_12);
                    this._nodeB.setUp(_arg_1, this.$id, _local_5, _local_6);
                };
                if (this._nodeC == null){
                    this._nodeC = new Node();
                    _local_5 = new Rectangle((_local_7 + _local_11), _local_8, _local_11, _local_12);
                    this._nodeC.setUp(_arg_1, this.$id, _local_5, _local_6);
                };
                if (this._nodeD == null){
                    this._nodeD = new Node();
                    _local_5 = new Rectangle((_local_7 + _local_11), (_local_8 + _local_12), _local_11, _local_12);
                    this._nodeD.setUp(_arg_1, this.$id, _local_5, _local_6);
                };
                this.project();
            };
        }

        private function project():void
        {
            var _local_1:INoder;
            if (this.coder::_depth_ > 0){
                for each (_local_1 in this._nodes) {
                    if (this._nodeA.coder::_rect.contains(_local_1.x, _local_1.y)){
                        this._nodeA.addChild(_local_1.id, _local_1);
                    } else {
                        if (this._nodeB.coder::_rect.contains(_local_1.x, _local_1.y)){
                            this._nodeB.addChild(_local_1.id, _local_1);
                        } else {
                            if (this._nodeC.coder::_rect.contains(_local_1.x, _local_1.y)){
                                this._nodeC.addChild(_local_1.id, _local_1);
                            } else {
                                if (this._nodeD.coder::_rect.contains(_local_1.x, _local_1.y)){
                                    this._nodeD.addChild(_local_1.id, _local_1);
                                };
                            };
                        };
                    };
                };
            };
        }

        public function reFree():void
        {
            if (this.coder::_depth_ >= 1){
                this._nodes = null;
                this._nodes = new Dictionary();
                if (this._nodeA){
                    this._nodeA.reFree();
                };
                if (this._nodeB){
                    this._nodeB.reFree();
                };
                if (this._nodeC){
                    this._nodeC.reFree();
                };
                if (this._nodeD){
                    this._nodeD.reFree();
                };
            };
        }

        override public function dispose():void
        {
            this._nodes = null;
            this._tree = null;
            super.dispose();
        }

        public function treeNodes():Hash
        {
            return (this._tree.nodes);
        }

        public function get parent():Node
        {
            if (this.oid == null){
                return (null);
            };
            return ((this._tree.nodes.take(this.oid) as Node));
        }

        public function addChild(_arg_1:String, _arg_2:INoder):void
        {
            if (this._nodes[_arg_1] == null){
                this._nodes[_arg_1] = _arg_2;
                this._length++;
            };
        }

        public function get nodeA():Node
        {
            return (this._nodeA);
        }

        public function get nodeB():Node
        {
            return (this._nodeB);
        }

        public function get nodeC():Node
        {
            return (this._nodeC);
        }

        public function get nodeD():Node
        {
            return (this._nodeD);
        }

        public function get length():int
        {
            return (this._length);
        }

        public function get dic():Dictionary
        {
            return (this._nodes);
        }

        public function removeChild(_arg_1:String):void
        {
            if (this._nodes[_arg_1]){
                delete this._nodes[_arg_1];
                this._length--;
            };
        }

        public function drawBound(_arg_1:Graphics, _arg_2:Rectangle, _arg_3:uint, _arg_4:Boolean=false):void
        {
            if (((_arg_2) && (_arg_1))){
                _arg_1.lineStyle(1, _arg_3);
                if (_arg_4){
                    _arg_1.beginFill(0, 0.2);
                };
                _arg_1.drawRect(_arg_2.topLeft.x, _arg_2.topLeft.y, _arg_2.width, _arg_2.height);
            };
        }


    }
}//package com.engine.core.view.quadTree

