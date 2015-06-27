// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.model.IProxy

package com.engine.core.controls.model
{
    import com.engine.core.model.IProto;
    import com.engine.core.controls.service.IMessage;
    import __AS3__.vec.Vector;
    import com.engine.core.controls.service.Body;

    public interface IProxy extends IProto 
    {

        function send(_arg_1:IMessage):void;
        function createMessage(_arg_1:String, _arg_2:Vector.<String>, _arg_3:Body=null, _arg_4:String="module_to_module"):IMessage;
        function setUp(_arg_1:String, _arg_2:String, _arg_3:Function):void;

    }
}//package com.engine.core.controls.model

