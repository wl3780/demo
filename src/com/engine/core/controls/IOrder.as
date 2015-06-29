// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.IOrder

package com.engine.core.controls
{
    import com.engine.core.model.IProto;

    public interface IOrder extends IProto 
    {

        function get type():String;
        function execute():void;
        function callback(_arg_1:Array=null):void;

    }
}//package com.engine.core.controls

