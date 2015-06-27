// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.model.IModule

package com.engine.core.controls.model
{
    import com.engine.core.model.IProto;
    import com.engine.core.view.IBaseSprite;
    import com.engine.core.controls.service.IMessage;

    public interface IModule extends IProto 
    {

        function get lock():Boolean;
        function get valve():Boolean;
        function set valve(_arg_1:Boolean):void;
        function get proxy():ModuleProxy;
        function get view():IBaseSprite;
        function set view(_arg_1:IBaseSprite):void;
        function register(_arg_1:String):void;
        function send(_arg_1:IMessage):void;
        function subHandler(_arg_1:IMessage):void;
        function initialize():void;
        function registerSub(... _args):void;

    }
}//package com.engine.core.controls.model

