// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.service.Message

package com.engine.core.controls.service
{
    import com.engine.core.model.Proto;
    import flash.net.registerClassAlias;
    import com.engine.namespaces.coder;
    import com.engine.core.controls.model.ModuleMonitor;
    import __AS3__.vec.Vector;
    import com.engine.core.controls.model.Module;
    import flash.utils.getQualifiedClassName;
    import com.engine.core.controls.model.SubProxy;
    import com.engine.core.controls.model.MessageConstant;
    import com.engine.core.controls.model.IModule;
    import __AS3__.vec.*;

    public class Message extends Proto implements IMessage 
    {

        protected var $head:Head;
        protected var $body:Body;
        public var bubble:Boolean;
        public var copy:Boolean;

        public function Message()
        {
            registerClassAlias("saiman.save.Message", Message);
        }

        public static function check(_arg_1:IMessage):void
        {
            var _local_2:String;
            if (_arg_1 == null){
                throw (new Error("【message】不能为null！"));
            };
            if ((((((_arg_1.sender == null)) || ((_arg_1.geters.length <= 0)))) || ((_arg_1.geters == null)))){
                _local_2 = (("sender=" + _arg_1.sender) + "\n");
                if (_arg_1.geters){
                    _local_2 = (_local_2 + ("geters length=" + _arg_1.geters.length));
                } else {
                    _local_2 = (_local_2 + (("geters=" + _arg_1.geters) + "\n"));
                };
                throw (new Error(("【message】基本信息不完整，请检查！\n" + _local_2)));
            };
        }

        public static function sendToTotalModule(_arg_1:String, _arg_2:String, _arg_3:Object=null):void
        {
            ModuleMonitor.coder::getInstance().sendToTotalModule(_arg_1, _arg_2, _arg_3);
        }

        public static function sendToModules(_arg_1:String, _arg_2:String, _arg_3:Vector.<String>, _arg_4:Object=null):void
        {
            var _local_5:Message = new (Message)();
            if ((_arg_4 as Body)){
                _local_5.setUp(_arg_2, _arg_3, (_arg_4 as Body));
            } else {
                _local_5.setUp(_arg_2, _arg_3);
                _local_5.proto = _arg_4;
            };
            _local_5.actionType = _arg_1;
            _local_5.send();
        }

        public static function sendToSub2(_arg_1:String, _arg_2:String, _arg_3:Class, _arg_4:Object=null):void
        {
            var _local_6:Message;
            var _local_5:Module = (ModuleMonitor.coder::getInstance().takeModule(_arg_2) as Module);
            if (_local_5){
                _local_6 = new (Message)();
                _local_6.setUp(_arg_2, new <String>[getQualifiedClassName(_arg_3)]);
                _local_6.proto = _arg_4;
                _local_6.actionType = _arg_1;
                _local_5.senToSub(getQualifiedClassName(_arg_3), _local_6);
            };
        }

        public static function sendToSub(_arg_1:String, _arg_2:SubProxy, _arg_3:Class, _arg_4:Object=null):void
        {
            var _local_6:Message;
            var _local_5:Module = (ModuleMonitor.coder::getInstance().takeModule(_arg_2.oid) as Module);
            if (_local_5){
                _local_6 = new (Message)();
                _local_6.setUp(getQualifiedClassName(_arg_2), new <String>[getQualifiedClassName(_arg_3)]);
                _local_6.proto = _arg_4;
                _local_6.actionType = _arg_1;
                _local_5.senToSub(getQualifiedClassName(_arg_3), _local_6);
            };
        }

        public static function sendToService(_arg_1:String, _arg_2:String, _arg_3:Object):void
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
            var _local_5:Message = new (Message)();
            _local_5.setUp(_arg_2, new <String>[MessageConstant.MODULE_TO_SERVICE], _local_4, MessageConstant.MODULE_TO_SERVICE);
            _local_5.send();
        }


        public function get actionType():String
        {
            return (this.$body.type);
        }

        public function set actionType(_arg_1:String):void
        {
            if (this.$body == null){
                this.$body = new Body();
            };
            this.$body.type = _arg_1;
        }

        public function get head():Head
        {
            return (this.$head);
        }

        public function get messageType():String
        {
            if (this.$head == null){
                return (null);
            };
            return (this.$head.messageType);
        }

        public function get sender():String
        {
            if (this.$head == null){
                return (null);
            };
            return (this.$head.sender);
        }

        public function get geters():Vector.<String>
        {
            if (this.$head == null){
                return (null);
            };
            return (this.$head.geters);
        }

        public function get body():Body
        {
            return (this.$body);
        }

        override public function set proto(_arg_1:Object):void
        {
            if (this.body == null){
                this.$body = new Body();
            };
            this.$body.proto = _arg_1;
        }

        override public function get proto():Object
        {
            if (this.$body == null){
                return (null);
            };
            return (this.$body.proto);
        }

        public function setUp(_arg_1:String, _arg_2:Vector.<String>, _arg_3:Body=null, _arg_4:String="module_to_module"):void
        {
            var _local_5:Head = new Head();
            _local_5.geters = _arg_2;
            _local_5.messageType = _arg_4;
            _local_5.sender = _arg_1;
            this.$head = _local_5;
            this.$body = _arg_3;
            this.$oid = _arg_1;
        }

        public function setUpFunction(_arg_1:Function=null, _arg_2:Array=null, _arg_3:Function=null):void
        {
            if (this.$body){
                this.$body.setUpFunction(_arg_1, _arg_2, _arg_3);
            };
        }

        public function send():void
        {
            check(this);
            var _local_1:IModule = ModuleMonitor.coder::getInstance().takeModule(this.sender);
            if (_local_1){
                if (!_local_1.lock){
                    _local_1.send(this);
                };
            } else {
                throw (new Error("消息发送方非注册模块成员"));
            };
        }

        override public function toString():String
        {
            var _local_1:String = getQualifiedClassName(this);
            var _local_2 = "";
            _local_2 = (_local_2 + (((("[" + _local_1.substr((_local_1.indexOf("::") + 2), _local_1.length)) + " ") + id) + " "));
            _local_2 = (_local_2 + (("messageType=" + this.messageType) + " "));
            _local_2 = (_local_2 + (("sender=" + this.sender) + " "));
            return ((_local_2 + (("geters=" + this.geters) + " ]")));
        }

        override public function dispose():void
        {
            if (this.$body){
                this.$body.dispose();
            };
            if (this.head){
                this.head.dispose();
            };
            this.$body = null;
            this.$head = null;
            super.dispose();
        }


    }
}//package com.engine.core.controls.service

