// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.service.MessagePort

package com.engine.core.controls.service
{
    import com.engine.core.controls.model.IModule;
    import com.engine.core.controls.model.MessageConstant;
    import com.engine.core.controls.model.ModuleMonitor;
    import com.engine.core.controls.model.ServierProtModule;
    import com.engine.namespaces.coder;

    public class MessagePort 
    {

        private static var _instance:MessagePort;

        public var moduleMonitor:ModuleMonitor;

        public function MessagePort()
        {
            this.moduleMonitor = ModuleMonitor.coder::getInstance();
        }

        coder static function getInstance():MessagePort
        {
            if (_instance == null){
                _instance = new (MessagePort)();
            };
            return (_instance);
        }


        public function send(_arg_1:IMessage):void
        {
            if (_arg_1.messageType == MessageConstant.MODULE_TO_SERVICE){
                this.moduleToSevrice(_arg_1);
            } else {
                this.moduleToModule(_arg_1);
            };
        }

        public function moduleToModule(_arg_1:IMessage):void
        {
            var _local_3:Vector.<String>;
            var _local_4:int;
            var _local_5:IModule;
            var _local_2:IModule = this.moduleMonitor.takeModule(_arg_1.sender);
            if (_local_2){
                _local_3 = _arg_1.geters;
                _local_4 = 0;
                while (_local_4 < _local_3.length) {
                    if (_local_3[_local_4]){
                        _local_5 = this.moduleMonitor.takeModule(_local_3[_local_4]);
                        if (Message(_arg_1).copy){
                            _arg_1 = (_arg_1.clone() as Message);
                        };
                        if (_local_5){
                            var _local_6 = _local_5.proxy;
                            (_local_6.coder::subHandler(_arg_1));
                        };
                    };
                    _local_4++;
                };
            };
        }

        public function moduleToSevrice(_arg_1:IMessage):void
        {
            var _local_2:IModule = this.moduleMonitor.takeModule(ServierProtModule.NAME);
            var _local_3 = _local_2.proxy;
            (_local_3.coder::subHandler(_arg_1));
        }


    }
}//package com.engine.core.controls.service

