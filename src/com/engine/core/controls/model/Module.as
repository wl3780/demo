// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.model.Module

package com.engine.core.controls.model
{
    import flash.utils.getQualifiedClassName;
    import com.engine.core.controls.service.IMessage;
    import com.engine.namespaces.coder;
    import com.engine.core.controls.service.Body;
    import com.engine.core.controls.service.Message;
    import __AS3__.vec.Vector;

    public class Module extends BaseModule 
    {

        public function Module()
        {
            this.register(getQualifiedClassName(this));
        }

        override public function subHandler(_arg_1:IMessage):void
        {
            if (this.lock){
                return;
            };
            super.subHandler(_arg_1);
            switch (_arg_1.messageType){
                case MessageConstant.MODULE_TO_MODULE:
                    this.messageFromModule(_arg_1);
                    return;
                case MessageConstant.MODULE_TO_SERVICE:
                    this.messageFromService(_arg_1);
                    return;
            };
        }

        protected function messageFromModule(_arg_1:IMessage):void
        {
        }

        protected function messageFromService(_arg_1:IMessage):void
        {
        }

        public function sendToTotalModule(_arg_1:String, _arg_2:Object=null):void
        {
            ModuleMonitor.coder::getInstance().sendToTotalModule(_arg_1, this.$id, _arg_2);
        }

        public function sendToModule(_arg_1:String, _arg_2:Vector.<String>, _arg_3:Object):void
        {
            var _local_5:Body;
            var _local_4:Message = new Message();
            if ((_arg_3 as Body)){
                _arg_3.type = _arg_1;
                _local_5 = (_arg_3 as Body);
            } else {
                _local_5 = new Body();
                _local_5.type = _arg_1;
                _local_5.proto = _arg_3;
            };
            _local_4.setUp(this.$id, _arg_2, _local_5, MessageConstant.MODULE_TO_MODULE);
            _local_4.send();
        }

        public function sendToService(_arg_1:String, _arg_2:Vector.<String>, _arg_3:Object):void
        {
            var _local_4:Body;
            if ((_arg_3 as Body)){
                _arg_3.type = _arg_1;
                _local_4 = (_arg_3 as Body);
            } else {
                _local_4 = new Body();
                _local_4.type = _arg_1;
                _local_4.proto = _arg_3;
            };
            var _local_5:Message = new Message();
            _local_5.setUp(this.$id, _arg_2, _local_4, MessageConstant.MODULE_TO_SERVICE);
            _local_5.send();
        }

        public function copyMessage(_arg_1:Message):Message
        {
            return ((_arg_1.clone() as Message));
        }

        public function senToSub(_arg_1:String, _arg_2:IMessage):void
        {
            this.proxy.sendToSub(_arg_1, _arg_2);
        }

        public function senToSubs(_arg_1:Vector.<String>, _arg_2:IMessage):void
        {
            var _local_5:String;
            var _local_3:int = _arg_1.length;
            var _local_4:int;
            while (_local_4 < _local_3) {
                _local_5 = _arg_1[_local_4];
                if (_local_5){
                    this.proxy.sendToSub(_local_5, _arg_2);
                };
                _local_4++;
            };
        }

        override public function dispose():void
        {
            super.dispose();
        }


    }
}//package com.engine.core.controls.model

