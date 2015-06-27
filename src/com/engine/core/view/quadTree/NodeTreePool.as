// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.quadTree.NodeTreePool

package com.engine.core.view.quadTree
{
    import flash.utils.Dictionary;

    public class NodeTreePool 
    {

        private static var _instance:NodeTreePool;

        private var hash:Dictionary;

        public function NodeTreePool()
        {
            this.hash = new Dictionary();
        }

        public static function getInstance():NodeTreePool
        {
            if (_instance == null){
                _instance = new (NodeTreePool)();
            };
            return (_instance);
        }


        public function put(_arg_1:NodeTree):void
        {
            if (this.hash[_arg_1.id] == null){
                this.hash[_arg_1.id] = _arg_1;
            };
        }

        public function take(_arg_1:String):NodeTree
        {
            return (this.hash[_arg_1]);
        }

        public function remove(_arg_1:String):void
        {
            delete this.hash[_arg_1];
        }


    }
}//package com.engine.core.view.quadTree

