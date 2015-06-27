// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.utils.Hash

package com.engine.utils
{
    import flash.utils.Dictionary;
    import com.engine.namespaces.coder;

    use namespace coder;

    public class Hash 
    {

        private var _length:int;
        private var _hash:Dictionary;

        public function Hash()
        {
            this._length = 0;
            this._hash = new Dictionary();
        }

        public function put(_arg_1:String, _arg_2:Object):void
        {
            if (this.has(_arg_1) == false){
                this._hash[_arg_1] = _arg_2;
                this._length++;
            } else {
                this.remove(_arg_1);
                this._hash[_arg_1] = _arg_2;
                this._length++;
            };
        }

        public function remove(_arg_1:String):Object
        {
            var _local_2:Object;
            if (this.has(_arg_1)){
                _local_2 = this._hash[_arg_1];
                delete this._hash[_arg_1];
                this._length--;
                return (_local_2);
            };
            return (null);
        }

        public function has(_arg_1:String):Boolean
        {
            if (this._hash[_arg_1] != null){
                return (true);
            };
            return (false);
        }

        public function take(_arg_1:String):Object
        {
            return (this._hash[_arg_1]);
        }

        public function get length():int
        {
            return (this._length);
        }

        public function get hash():Dictionary
        {
            return (this._hash);
        }

        public function dispose():void
        {
            this._hash = null;
            this._length = 0;
        }

        coder function dispose():void
        {
            var _local_1:String;
            for (_local_1 in this._hash) {
                delete this._hash[_local_1];
            };
            this._hash = null;
            this._length = 0;
        }

        coder function values():Array
        {
            var _local_2:Object;
            var _local_1:Array = [];
            for each (_local_2 in this._hash) {
                _local_1.push(_local_2);
            };
            return (_local_1);
        }

        coder function takekey():String
        {
            var _local_1:Object;
            for each (_local_1 in this._hash) {
                return ((_local_1.id as String));
            };
            return (null);
        }


    }
}//package com.engine.utils

