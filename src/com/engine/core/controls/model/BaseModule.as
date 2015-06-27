// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.model.BaseModule

package com.engine.core.controls.model
{
    import com.engine.core.view.IBaseSprite;
    import com.engine.namespaces.coder;
    import com.engine.core.model.IProto;
    import com.engine.core.controls.service.IMessage;
    import com.engine.core.Core;
    import com.engine.core.controls.service.Message;
    import com.engine.core.controls.service.MessagePort;
    import __AS3__.vec.Vector;
    import com.engine.core.controls.service.Body;

    public class BaseModule implements IModule 
    {

        protected var $id:String;
        protected var $oid:String;
        protected var $proto:Object;
        protected var $proxy:ModuleProxy;
        protected var $view:IBaseSprite;
        protected var $valve:Boolean;
        private var _lock:Boolean;

        public function BaseModule()
        {
            this.valve = true;
        }

        public function get lock():Boolean
        {
            return (this._lock);
        }

        public function set lock(_arg_1:Boolean):void
        {
            this._lock = _arg_1;
        }

        public function get valve():Boolean
        {
            return (this.$valve);
        }

        public function set valve(_arg_1:Boolean):void
        {
            this.$valve = _arg_1;
            if (this.$proxy){
                this.$proxy.valve = _arg_1;
            };
        }

        public function get id():String
        {
            return (this.$id);
        }

        public function get oid():String
        {
            return (this.$oid);
        }

        public function set proto(_arg_1:Object):void
        {
            this.$proto = _arg_1;
        }

        public function get proto():Object
        {
            return (this.$proto);
        }

        public function get proxy():ModuleProxy
        {
            return (this.$proxy);
        }

        public function get view():IBaseSprite
        {
            return (this.$view);
        }

        public function set view(_arg_1:IBaseSprite):void
        {
            this.$view = _arg_1;
        }

        public function initialize():void
        {
        }

        public function dispose():void
        {
            ModuleMonitor.coder::getInstance().removeModule(this.id);
            this.$proxy.dispose();
            this.$proxy = null;
            this.$view = null;
            this.$proto = null;
            this.$id = null;
        }

        public function clone():IProto
        {
            return (null);
        }

        public function register(_arg_1:String):void
        {
            if (this.$proxy == null){
                this.$proxy = new ModuleProxy();
                this.$proxy.valve = this.$valve;
                this.proxy.setUp(null, _arg_1, this.subHandler);
                this.$id = _arg_1;
                ModuleMonitor.coder::getInstance().addModule(this);
            };
        }

        public function subHandler(_arg_1:IMessage):void
        {
        }

        public function send(_arg_1:IMessage):void
        {
            if (!Core.sandBoxEnabled){
                return;
            };
            Message.check(_arg_1);
            MessagePort.coder::getInstance().send(_arg_1);
        }

        public function createMessage(_arg_1:String, _arg_2:Vector.<String>, _arg_3:Body=null, _arg_4:String="module_to_module"):IMessage
        {
            var _local_5:Message = new Message();
            _local_5.setUp(_arg_1, _arg_2, _arg_3, _arg_4);
            return (_local_5);
        }

        public function registerSub(... _args):void
        {
            var _local_3:Object;
            var _local_4:SubProxy;
            var _local_2:int;
            while (_local_2 < _args.length) {
                _local_3 = _args[_local_2];
                if ((_local_3 is Class)){
                    _local_4 = (new (_local_3)() as SubProxy);
                    _local_4.coder::oid = this.id;
                    if (_local_4){
                        this.proxy.addSub(_local_4);
                    } else {
                        throw (new Error("参数对象不是SubProxy子类对象"));
                    };
                } else {
                    if ((_local_3 as SubProxy)){
                        _local_4.coder::oid = this.id;
                        this.proxy.addSub(_local_4);
                    } else {
                        throw (new Error("参数对象不是SubProxy子类对象"));
                    };
                };
                _local_2++;
            };
        }


    }
}//package com.engine.core.controls.model

