// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.service.IMessage

package com.engine.core.controls.service
{
    import com.engine.core.model.IProto;
    import __AS3__.vec.Vector;

    public interface IMessage extends IProto 
    {

        function get actionType():String;
        function set actionType(_arg_1:String):void;
        function get head():Head;
        function get body():Body;
        function get geters():Vector.<String>;
        function get sender():String;
        function get messageType():String;
        function setUp(_arg_1:String, _arg_2:Vector.<String>, _arg_3:Body=null, _arg_4:String="module_to_module"):void;
        function toString():String;
        function send():void;

    }
}//package com.engine.core.controls.service

