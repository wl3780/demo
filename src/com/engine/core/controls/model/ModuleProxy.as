// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.model.ModuleProxy

package com.engine.core.controls.model
{
    import com.engine.core.controls.service.Body;
    import com.engine.core.controls.service.IMessage;
    import com.engine.core.controls.service.Message;
    import com.engine.core.controls.service.MessagePort;
    import com.engine.core.model.Proto;
    import com.engine.namespaces.coder;
    import com.engine.utils.Hash;

    public class ModuleProxy extends Proto implements IProxy 
    {

        private var _hash:Hash;
        private var _moduleName:String;
        private var _subHandler:Function;
        private var _valve:Boolean;


        public function setUp(_arg_1:String, _arg_2:String, _arg_3:Function):void
        {
            if (_arg_1 != null){
                this.$id = _arg_1;
            };
            this._moduleName = _arg_2;
            this.$oid = _arg_2;
            this._subHandler = _arg_3;
            this._hash = new Hash();
        }

        public function addSub(_arg_1:SubProxy):void
        {
            if (_arg_1 == null){
                return;
            };
            if (this._hash.has(_arg_1.id) == false){
                this._hash.put(_arg_1.id, _arg_1);
            } else {
                throw (new Error("定阅器注册的id以存在，请确保id唯一"));
            };
        }

        public function removeSub(_arg_1:String):SubProxy
        {
            return ((this._hash.remove(_arg_1) as SubProxy));
        }

        public function takeSub(_arg_1:String):SubProxy
        {
            return ((this._hash.take(_arg_1) as SubProxy));
        }

        public function hasSub(_arg_1:String):Boolean
        {
            return (this._hash.has(_arg_1));
        }

        public function send(_arg_1:IMessage):void
        {
            MessagePort.coder::getInstance().send(_arg_1);
        }

        coder function subHandler(_arg_1:IMessage):void
        {
            var _local_2:SubProxy;
            if (this._valve){
                this._subHandler.apply(null, [_arg_1]);
                for each (_local_2 in this._hash) {
                    if (!_local_2.lock){
                        var _local_5 = _local_2;
                        (_local_5.coder::subHandler(_arg_1));
                    };
                };
            };
        }

        public function sendToSub(_arg_1:String, _arg_2:IMessage):void
        {
            var _local_3:SubProxy = this.takeSub(_arg_1);
            _arg_2.head.messageType = MessageConstant.MODELE_TO_SUB;
            _arg_2.head.geters = new <String>[_arg_1];
            if (_local_3){
                var _local_4 = _local_3;
                (_local_4.coder::subHandler(_arg_2));
            };
        }

        public function createMessage(_arg_1:String, _arg_2:Vector.<String>, _arg_3:Body=null, _arg_4:String="module_to_module"):IMessage
        {
            var _local_5:Message = new Message();
            _local_5.setUp(_arg_1, _arg_2, _arg_3, _arg_4);
            return (_local_5);
        }

        override public function dispose():void
        {
            this._hash.dispose();
            this._hash = null;
            this._subHandler = null;
            super.dispose();
        }

        public function set valve(_arg_1:Boolean):void
        {
            this._valve = _arg_1;
        }


    }
}//package com.engine.core.controls.model

