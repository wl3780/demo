// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.model.IProto

package com.engine.core.model
{
    public interface IProto 
    {

        function get id():String;
        function set proto(_arg_1:Object):void;
        function get proto():Object;
        function get oid():String;
        function clone():IProto;
        function dispose():void;

    }
}//package com.engine.core.model

