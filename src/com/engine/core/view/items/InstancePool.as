// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.items.InstancePool

package com.engine.core.view.items
{
    import flash.utils.Dictionary;
    import com.engine.namespaces.coder;
    import com.engine.core.view.items.avatar.IAvatar;
    import flash.utils.getQualifiedClassName;

    use namespace coder;

    public class InstancePool 
    {

        private static var _instance:InstancePool;

        public var dic:Dictionary;
        public var limit:int = 15;

        public function InstancePool()
        {
            this.dic = new Dictionary();
        }

        coder static function getInstance():InstancePool
        {
            if (_instance == null){
                _instance = new (InstancePool)();
            };
            return (_instance);
        }


        public function reset():void
        {
            var _local_1:String;
            var _local_2:Array;
            var _local_3:int;
            var _local_4:IAvatar;
            for (_local_1 in this.dic) {
                _local_2 = this.dic[_local_1];
                _local_3 = 0;
                while (_local_3 < _local_2.length) {
                    _local_4 = (_local_2[_local_3] as IAvatar);
                    if (_local_4){
                        _local_4.dispose();
                    };
                    _local_3++;
                };
                delete this.dic[_local_1];
            };
        }

        public function getAvatar(_arg_1:Class):IAvatar
        {
            var _local_4:Object;
            var _local_2:String = getQualifiedClassName(_arg_1);
            var _local_3:Array = this.dic[_local_2];
            if (((_local_3) && (_local_3.length))){
                _local_4 = _local_3.shift();
                return ((_local_4 as IAvatar));
            };
            return ((new (_arg_1)() as IAvatar));
        }

        public function recover(_arg_1:IAvatar):void
        {
            if (!_arg_1){
                return;
            };
            var _local_2:String = getQualifiedClassName(_arg_1);
            if (this.dic[_local_2] == null){
                this.dic[_local_2] = [];
            };
            var _local_3:Array = this.dic[_local_2];
            if (_local_3.length <= this.limit){
                if (_local_3.indexOf(_arg_1) == -1){
                    _local_3.push(_arg_1);
                };
            } else {
                _arg_1.dispose();
            };
        }

        public function remove(_arg_1:IAvatar):void
        {
            var _local_3:Array;
            var _local_4:int;
            if (!_arg_1){
                return;
            };
            var _local_2:String = getQualifiedClassName(_arg_1);
            if (this.dic[_local_2] != null){
                _local_3 = (this.dic[_local_2] as Array);
                if (_local_3){
                    _local_4 = _local_3.indexOf(_arg_1);
                    if (_local_4 != -1){
                        _local_3.splice(_local_4, 1);
                    };
                };
            };
        }


    }
}//package com.engine.core.view.items

