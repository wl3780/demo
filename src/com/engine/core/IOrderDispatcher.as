// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.IOrderDispatcher

package com.engine.core
{
    import flash.events.IEventDispatcher;
    import com.engine.core.model.IProto;
    import com.engine.core.controls.IOrder;
    import __AS3__.vec.Vector;

    public interface IOrderDispatcher extends IEventDispatcher, IProto 
    {

        function takeOrder(_arg_1:String, _arg_2:String):IOrder;
        function hasOrder(_arg_1:String, _arg_2:String):Boolean;
        function removeOrder(_arg_1:String, _arg_2:String):IOrder;
        function addOrder(_arg_1:IOrder):Boolean;
        function takeGroupOrders(_arg_1:String):Vector.<IOrder>;
        function disposeGroupOrders(_arg_1:String):Vector.<IOrder>;

    }
}//package com.engine.core

