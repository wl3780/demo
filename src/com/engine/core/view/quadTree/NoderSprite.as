package com.engine.core.view.quadTree
{
    import com.engine.core.Core;
    import com.engine.core.view.BaseSprite;
    import com.engine.namespaces.coder;

    public class NoderSprite extends BaseSprite implements INoderSpite 
    {

        private var _node:Node;
        coder var _tid:String;
        private var _tree:NodeTree;
        private var _initialized:Boolean;
        private var _isActivate:Boolean;

        public function NoderSprite()
        {
            this.mouseChildren = false;
            this.mouseEnabled = false;
            this.tabChildren = (this.tabEnabled = false);
        }

        public function registerNodeTree(_arg_1:String):void
        {
            this.coder::_tid = _arg_1;
            this._tree = NodeTreePool.getInstance().take(_arg_1);
            this._initialized = true;
            this.activate();
        }

        override public function set x(_arg_1:Number):void
        {
            if (_arg_1 == super.x){
                return;
            };
            super.x = Number(_arg_1.toFixed(1));
            this.updata(_arg_1, super.y, this.nodeKey);
        }

        override public function set y(_arg_1:Number):void
        {
            if (_arg_1 == super.y){
                return;
            };
            super.y = Number(_arg_1.toFixed(1));
            this.updata(super.x, _arg_1, this.nodeKey);
        }

        public function updata(_arg_1:Number, _arg_2:Number, _arg_3:String):void
        {
            var _local_4:Node;
            var _local_5:Node;
            if (this._isActivate == false){
                return;
            };
            if (this._initialized == false){
                return;
            };
            if (this._tree.initialized){
                if (this._node == null){
                    _local_4 = (this._tree.nodes.take(_arg_3) as Node);
                    this._node = _local_4;
                };
                if (!this._node.coder::_rect.contains(_arg_1, _arg_2)){
                    _local_5 = (this._tree.nodes.take(_arg_3) as Node);
                    this.resetNode(this._node, _local_5);
                    if (_local_5 != null){
                        this._node = _local_5;
                    };
                };
            };
        }

        private function resetNode(_arg_1:Node, _arg_2:Node):void
        {
            if (((_arg_1) && (_arg_2))){
                if (_arg_1 != _arg_2){
                    _arg_1.removeChild(this.id);
                    _arg_2.addChild(this.id, this);
                    this._node = _arg_2;
                    this.resetNode(_arg_1.parent, _arg_2.parent);
                };
            };
        }

        public function get node():Node
        {
            return (this._node);
        }

        private function get nodeKey():String
        {
            var _local_1:int = ((int((this.x / NodeTree.doubleMinWidth)) * NodeTree.doubleMinWidth) + NodeTree.minWidth);
            var _local_2:int = ((int((this.y / NodeTree.doubleMinHeight)) * NodeTree.doubleMinHeight) + NodeTree.minHeight);
            return (((_local_1 + Core.SIGN) + _local_2));
        }

        public function activate():void
        {
            var _local_1:Node;
            if (this._tree.initialized){
                this._isActivate = true;
                _local_1 = (this._tree.nodes.take(this.nodeKey) as Node);
                this._node = _local_1;
                this.push(_local_1);
            };
        }

        public function unactivate():void
        {
            this._isActivate = false;
            if (this._node){
                this.remove(this._node);
                this._node = null;
            };
        }

        public function get isActivate():Boolean
        {
            return (this._isActivate);
        }

        public function get tid():String
        {
            return (this.coder::_tid);
        }

        public function push(_arg_1:Node):void
        {
            if (_arg_1 == null){
                return;
            };
            _arg_1.addChild(this.id, this);
            var _local_2:Node = _arg_1.parent;
            if (_local_2){
                this.push(_local_2);
            };
        }

        private function remove(_arg_1:Node):void
        {
            if (_arg_1 == null){
                return;
            };
            _arg_1.removeChild(this.id);
            var _local_2:Node = _arg_1.parent;
            if (_local_2){
                this.remove(_local_2);
            };
        }

        override public function dispose():void
        {
            this._isActivate = false;
            this.remove(this._node);
            this._node = null;
            this._tree = null;
            super.dispose();
        }


    }
}//package com.engine.core.view.quadTree

