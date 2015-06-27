// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.DisplayObjectPort

package com.engine.core.view
{
    import com.engine.core.model.Proto;
    import com.engine.utils.Hash;
    import com.engine.namespaces.coder;
    import com.engine.core.IOrderDispatcher;

    use namespace coder;

    public class DisplayObjectPort extends Proto 
    {

        private static var _instance:DisplayObjectPort;

        private var hash:Hash;


        coder static function getInstance():DisplayObjectPort
        {
            if (_instance == null){
                _instance = new (DisplayObjectPort)();
                _instance.hash = new Hash();
            };
            return (_instance);
        }


        public function put(_arg_1:IOrderDispatcher):void
        {
            this.hash.put(_arg_1.id, _arg_1);
        }

        public function remove(_arg_1:String):IOrderDispatcher
        {
            return ((this.hash.remove(_arg_1) as IOrderDispatcher));
        }

        public function has(_arg_1:String):Boolean
        {
            return (this.hash.has(_arg_1));
        }

        public function task(_arg_1:String):IOrderDispatcher
        {
            return ((this.hash.take(_arg_1) as IOrderDispatcher));
        }

        public function get length():int
        {
            return (this.hash.length);
        }

        override public function dispose():void
        {
            var _local_1:IOrderDispatcher;
            for each (_local_1 in this.hash) {
                _local_1.dispose();
            };
            this.hash = null;
            _instance = null;
        }


    }
}//package com.engine.core.view

