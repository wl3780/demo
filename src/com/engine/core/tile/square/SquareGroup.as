// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.tile.square.SquareGroup

package com.engine.core.tile.square
{
    import com.engine.utils.Hash;
    import flash.utils.Dictionary;

    public class SquareGroup 
    {

        private static var instance:SquareGroup;

        private var $hash:Hash;

        public function SquareGroup()
        {
            if (instance == null){
                instance = this;
                this.initialize();
                if (this.$hash){
                    this.$hash.dispose();
                    this.$hash = new Hash();
                };
            };
        }

        public static function getInstance():SquareGroup
        {
            if (instance == null){
                instance = new (SquareGroup)();
            };
            return (instance);
        }


        public function get hash():Hash
        {
            return (this.$hash);
        }

        public function dispose():void
        {
            this.$hash.dispose();
            this.$hash = null;
        }

        public function initialize():void
        {
            this.$hash = new Hash();
        }

        public function unload():void
        {
            var _local_1:String;
            var _local_2:Square;
            if (this.hash == null){
                return;
            };
            try {
                for (_local_1 in this.hash.hash) {
                    _local_2 = this.hash.hash[_local_1];
                    _local_2.dispose();
                    delete this.hash.hash[_local_1];
                };
                this.$hash = null;
            } catch(e:Error) {
            };
            instance = null;
        }

        public function reset(_arg_1:Dictionary):void
        {
            var _local_3:Square;
            var _local_2:Hash = this.$hash;
            this.$hash = null;
            this.$hash = new Hash();
            for each (_local_3 in _arg_1) {
                this.put(_local_3);
            };
            _local_2.dispose();
        }

        public function put(_arg_1:Square):void
        {
            this.hash.put(_arg_1.key, _arg_1);
        }

        public function remove(_arg_1:String):Square
        {
            var _local_2:Square;
            if (this.hash.has(_arg_1)){
                return ((this.$hash.remove(_arg_1) as Square));
            };
            return (null);
        }

        public function has(_arg_1:String):Boolean
        {
            if (_arg_1 == null){
                return (false);
            };
            return (this.hash.has(_arg_1));
        }

        public function take(_arg_1:String):Square
        {
            return ((this.$hash.take(_arg_1) as Square));
        }

        public function passAbled(_arg_1:SquarePt):Boolean
        {
            var _local_2:Square;
            if (_arg_1){
                _local_2 = (this.$hash.take(_arg_1.key) as Square);
                if (_local_2){
                    if ((((_local_2.type == 3)) || ((_local_2.type == 4)))){
                        if (_local_2.type > 0){
                            return (true);
                        };
                    };
                };
            };
            return (false);
        }


    }
}//package com.engine.core.tile.square

