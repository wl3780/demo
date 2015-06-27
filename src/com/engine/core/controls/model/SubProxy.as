// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.model.SubProxy

package com.engine.core.controls.model
{
    import com.engine.core.model.Proto;
    import flash.utils.getQualifiedClassName;
    import com.engine.core.controls.service.IMessage;
    import com.engine.namespaces.coder;
    import flash.utils.getDefinitionByName;
    import com.engine.core.controls.service.Message;
    import __AS3__.vec.Vector;
    import com.engine.core.controls.service.Body;
    import __AS3__.vec.*;

    use namespace coder;

    public class SubProxy extends Proto implements IProxy 
    {

        private var _moduleName:String;
        private var _subHandler:Function;
        private var _lock:Boolean = false;

        public function SubProxy()
        {
            this.$id = getQualifiedClassName(this);
        }

        public function subHandler(_arg_1:IMessage):void
        {
        }

        public function get lock():Boolean
        {
            return (this._lock);
        }

        public function set lock(_arg_1:Boolean):void
        {
            this._lock = _arg_1;
        }

        public function setUp(_arg_1:String, _arg_2:String, _arg_3:Function):void
        {
            var _local_5:*;
            var _local_6:Class;
            if (_arg_1 != null){
                this.$id = _arg_1;
            };
            this._moduleName = _arg_2;
            this._subHandler = _arg_3;
            this.$oid = _arg_2;
            var _local_4:IModule = ModuleMonitor.coder::getInstance().takeModule(this.$oid);
            if (_local_4){
                try {
                    _local_6 = (getDefinitionByName(_arg_1) as Class);
                } catch(e:Error) {
                };
                if (_local_6){
                    _local_5 = new (_local_6)();
                } else {
                    _local_5 = this;
                };
                _local_4.proxy.addSub(_local_5);
            };
        }

        public function unlock():void
        {
            this._subHandler = null;
            this._moduleName = null;
            this.$oid = null;
            var _local_1:IModule = ModuleMonitor.coder::getInstance().takeModule(this.$oid);
            if (_local_1){
                _local_1.proxy.removeSub(this.$id);
            };
        }

        public function senToSub(_arg_1:String, _arg_2:IMessage):void
        {
            if (this.lock){
                return;
            };
            var _local_3:IModule = ModuleMonitor.coder::getInstance().takeModule(this.$oid);
            if (_local_3){
                _local_3.proxy.sendToSub(_arg_1, _arg_2);
            };
        }

        public function sendToSub(_arg_1:String, _arg_2:String, _arg_3:Object):void
        {
            var _local_5:Message;
            if (this.lock){
                return;
            };
            var _local_4:IModule = ModuleMonitor.coder::getInstance().takeModule(this.$oid);
            if (_local_4){
                if ((_arg_3 as Message)){
                    _local_4.proxy.sendToSub(_arg_1, (_arg_3 as Message));
                } else {
                    _local_5 = new Message();
                    _local_5.setUp(this.id, new <String>[_arg_1], null);
                    _local_5.actionType = _arg_2;
                    _local_5.proto = _arg_3;
                    _local_4.proxy.sendToSub(_arg_1, _local_5);
                };
            };
        }

        public function senToSubs(_arg_1:Vector.<String>, _arg_2:IMessage):void
        {
            var _local_4:int;
            var _local_5:int;
            var _local_6:String;
            if (this.lock){
                return;
            };
            var _local_3:IModule = ModuleMonitor.coder::getInstance().takeModule(this.$oid);
            if (_local_3){
                _local_4 = _arg_1.length;
                _local_5 = 0;
                while (_local_5 < _local_4) {
                    _local_6 = _arg_1[_local_5];
                    if (_local_6){
                        _local_3.proxy.sendToSub(_local_6, _arg_2);
                    };
                    _local_5++;
                };
            };
        }

        public function sendToSerivce(_arg_1:String, _arg_2:Object):void
        {
            if (this.lock){
                return;
            };
            var _local_3:Message = new Message();
            _local_3.setUp(this.$oid, new <String>[ServierProtModule.NAME], null, MessageConstant.MODULE_TO_SERVICE);
            _local_3.actionType = _arg_1;
            _local_3.proto = _arg_2;
            _local_3.send();
        }

        public function sendToTotalModule(_arg_1:String, _arg_2:Object=null):void
        {
            if (this.lock){
                return;
            };
            ModuleMonitor.coder::getInstance().sendToTotalModule(_arg_1, this.oid, _arg_2);
        }

        public function sendToModule(_arg_1:String, _arg_2:Vector.<String>, _arg_3:Object=null):void
        {
            var _local_5:Body;
            if (this.lock){
                return;
            };
            var _local_4:Message = new Message();
            if ((_arg_3 as Body)){
                _arg_3.type = _arg_1;
                _local_5 = (_arg_3 as Body);
            } else {
                _local_5 = new Body();
                _local_5.type = _arg_1;
                _local_5.proto = _arg_3;
            };
            _local_4.setUp(this.oid, _arg_2, _local_5, MessageConstant.MODULE_TO_MODULE);
            _local_4.send();
        }

        public function send(_arg_1:IMessage):void
        {
            if (this.lock){
                return;
            };
            var _local_2:IModule = ModuleMonitor.coder::getInstance().takeModule(this.$oid);
            if (_local_2){
                _local_2.send(_arg_1);
            } else {
                throw (new Error("该Sub还没注册"));
            };
        }

        coder function subHandler(_arg_1:IMessage):void
        {
            if (this.lock){
                return;
            };
            this.subHandler.apply(null, [_arg_1]);
        }

        public function createMessage(_arg_1:String, _arg_2:Vector.<String>, _arg_3:Body=null, _arg_4:String="module_to_module"):IMessage
        {
            var _local_5:Message = new Message();
            _local_5.setUp(this.oid, _arg_2, _arg_3, _arg_4);
            return (_local_5);
        }

        override public function dispose():void
        {
            this._subHandler = null;
            var _local_1:IModule = ModuleMonitor.coder::getInstance().takeModule(this.$oid);
            if (_local_1){
                _local_1.proxy.removeSub(this.id);
            };
            super.dispose();
        }

        public function getSubIdByClass(_arg_1:Class):String
        {
            try {
                return (getQualifiedClassName(_arg_1));
            } catch(e:Error) {
            };
            return (null);
        }


    }
}//package com.engine.core.controls.model

