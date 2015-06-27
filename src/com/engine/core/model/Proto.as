// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.model.Proto

package com.engine.core.model
{
    import flash.net.registerClassAlias;
    import com.engine.core.Core;
    import com.engine.namespaces.coder;
    import com.engine.utils.ObjectUtils;
    import flash.utils.getQualifiedClassName;

    use namespace coder;

    public class Proto implements IProto 
    {

        protected var $proto:Object;
        protected var $id:String;
        protected var $oid:String;

        public function Proto()
        {
            registerClassAlias("saiman.save.ProtoVo", Proto);
            if (this.$id == null){
                this.$id = (Core.SIGN + Core.coder::nextInstanceIndex().toString(16));
            };
        }

        public function get oid():String
        {
            return (this.$oid);
        }

        coder function set oid(_arg_1:String):void
        {
            if (this.$oid != _arg_1){
                this.$oid = _arg_1;
            };
        }

        public function get id():String
        {
            return (this.$id);
        }

        coder function set id(_arg_1:String):void
        {
            if (this.$id != _arg_1){
                this.$id = _arg_1;
            };
        }

        public function get proto():Object
        {
            return (this.$proto);
        }

        public function set proto(_arg_1:Object):void
        {
            this.$proto = _arg_1;
        }

        public function clone():IProto
        {
            return ((ObjectUtils.copy(this) as IProto));
        }

        public function dispose():void
        {
            if (!Core.sandBoxEnabled){
                return;
            };
            this.proto = null;
            this.$oid = null;
            this.$id = null;
        }

        public function toString():String
        {
            var _local_1:String = getQualifiedClassName(this);
            return ((((("[" + _local_1.substr((_local_1.indexOf("::") + 2), _local_1.length)) + " ") + this.id) + "]"));
        }


    }
}//package com.engine.core.model

