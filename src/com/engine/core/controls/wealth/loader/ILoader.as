// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.wealth.loader.ILoader

package com.engine.core.controls.wealth.loader
{
    import com.engine.core.model.IProto;
    import com.engine.core.model.wealth.WealthVo;
    import flash.system.LoaderContext;

    public interface ILoader extends IProto 
    {

        function get wealthVo():WealthVo;
        function unloadAndStop(_arg_1:Boolean=true):void;
        function loadElemt(_arg_1:WealthVo, _arg_2:Function=null, _arg_3:Function=null, _arg_4:Function=null, _arg_5:LoaderContext=null):void;

    }
}//package com.engine.core.controls.wealth.loader

