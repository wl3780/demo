// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.model.ModuleMonitor

package com.engine.core.controls.model
{
    import com.engine.core.controls.service.Body;
    import com.engine.core.controls.service.IMessage;
    import com.engine.core.controls.service.Message;
    import com.engine.core.controls.service.MessagePort;
    import com.engine.core.model.Proto;
    import com.engine.namespaces.coder;
    import com.engine.utils.Hash;
    
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;

    public class ModuleMonitor extends Proto 
    {

        private static var _instance:ModuleMonitor;

        private var _hash:Hash;

        public function ModuleMonitor()
        {
            this._hash = new Hash();
        }

        coder static function getInstance():ModuleMonitor
        {
            if (_instance == null){
                _instance = new (ModuleMonitor)();
            };
            return (_instance);
        }


        coder function get hash():Hash
        {
            return (this._hash);
        }

        public function setUp(_arg_1:Class):void
        {
            var _local_6:String;
            var _local_7:Class;
            var _local_8:IModule;
            var _local_2:ServierProtModule = new ServierProtModule();
            _local_2.register(ServierProtModule.NAME);
            var _local_3:XML = describeType(_arg_1);
            var _local_4:XMLList = _local_3.child("constant");
            var _local_5:int;
            while (_local_5 < _local_4.length()) {
                _local_6 = _arg_1[_local_4[_local_5].@name];
                _local_7 = (getDefinitionByName(_local_6) as Class);
                if (_local_7){
                    _local_8 = (new (_local_7)() as IModule);
                    if (_local_8){
                        _local_8.register(_local_6);
                    };
                };
                _local_5++;
            };
        }

        public function sendToTotalModule(_arg_1:String, _arg_2:String, _arg_3:Object=null):void
        {
            var _local_5:IModule;
            var _local_6:Message;
            var _local_4:Vector.<String> = new Vector.<String>();
            for each (_local_5 in this._hash.hash) {
                _local_4.push(_local_5.id);
            };
            _local_6 = new Message();
            if ((_arg_3 as Body)){
                _local_6.setUp(_arg_2, _local_4, (_arg_3 as Body));
            } else {
                _local_6.setUp(_arg_2, _local_4);
                _local_6.proto = _arg_3;
            };
            _local_6.actionType = _arg_1;
            _local_6.send();
        }

        public function addModule(_arg_1:IModule):void
        {
            if (this._hash.has(_arg_1.id) == false){
                this._hash.put(_arg_1.id, _arg_1);
            };
        }

        public function removeModule(_arg_1:String):void
        {
            this._hash.remove(_arg_1);
        }

        public function takeModule(_arg_1:String):IModule
        {
            return ((this._hash.take(_arg_1) as IModule));
        }

        public function send(_arg_1:IMessage):void
        {
            MessagePort.coder::getInstance().send(_arg_1);
        }

        public function subHandler(_arg_1:IMessage):void
        {
        }

        public function createMessage(_arg_1:String, _arg_2:Vector.<String>, _arg_3:Body=null, _arg_4:String="module_to_module"):IMessage
        {
            var _local_5:Message = new Message();
            _local_5.setUp(_arg_1, _arg_2, _arg_3, _arg_4);
            return (_local_5);
        }


    }
}//package com.engine.core.controls.model

