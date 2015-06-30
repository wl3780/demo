// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.wealth.WealthPool

package com.engine.core.controls.wealth
{
    import com.engine.core.Core;
    import com.engine.core.controls.wealth.loader.DisplayLoader;
    import com.engine.core.controls.wealth.loader.ILoader;
    import com.engine.core.model.Proto;
    import com.engine.namespaces.coder;
    import com.engine.utils.Hash;
    
    import flash.utils.Dictionary;

    public class WealthPool extends Proto 
    {

        private static var _intance:WealthPool;

        coder var hash:Dictionary;
        private var bitmapdatas:Hash;

        public function WealthPool()
        {
            coder::hash = new Dictionary();
            this.bitmapdatas = new Hash();
        }

        public static function getIntance():WealthPool
        {
            if (_intance == null){
                _intance = new (WealthPool)();
            };
            return (_intance);
        }


        public function take(_arg_1:String):ILoader
        {
            return ((coder::hash[_arg_1] as ILoader));
        }

        public function has(_arg_1:String):Boolean
        {
            if (coder::hash[_arg_1]){
                return (true);
            };
            return (false);
        }

        public function remove(_arg_1:String):void
        {
            delete coder::hash[_arg_1];
        }

        public function add(_arg_1:String, _arg_2:ILoader):void
        {
            if (coder::hash[_arg_1] == null){
                coder::hash[_arg_1] = _arg_2;
            };
        }

        public function getSymbolIntance(_arg_1:String, _arg_2:String=null):Object
        {
            var _local_3:String;
            var _local_4:Object;
            var _local_5:Class;
            if (_arg_2){
                _local_3 = ((_arg_1 + Core.LINE) + _arg_2);
                _local_4 = this.bitmapdatas.take(_local_3);
                if (_local_4 == null){
                    _local_5 = this.getClass(_arg_1, _arg_2);
                    if (_local_5){
                        _local_4 = new (_local_5)();
                        this.bitmapdatas.put(_local_3, _local_4);
                        return (_local_4);
                    };
                    return (null);
                };
                return (_local_4);
            };
            _local_3 = _arg_1;
            _local_4 = this.bitmapdatas.take(_local_3);
            if (_local_4 == null){
                _local_5 = this.getClass(_arg_1, _arg_2);
                if (_local_5){
                    _local_4 = new (_local_5)();
                    this.bitmapdatas.put(_local_3, _local_4);
                    return (_local_4);
                };
                return (null);
            };
            return (_local_4);
        }

        public function getClass(_arg_1:String, _arg_2:String):Class
        {
            var _local_3:DisplayLoader = (WealthPool.getIntance().take(_arg_1) as DisplayLoader);
            if (_local_3){
                return ((_local_3.contentLoaderInfo.applicationDomain.getDefinition(_arg_2) as Class));
            };
            return (null);
        }


    }
}//package com.engine.core.controls.wealth

