// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.events.WealthEvent

package com.engine.core.controls.events
{
    import flash.events.Event;
    import com.engine.core.model.wealth.WealthVo;

    public class WealthEvent extends Event 
    {

        public static const WEALTH_LOADED:String = "WEALTH_LOADED";
        public static const WEALTH_GROUP_LOADED:String = "WEalth_GROUP_LOADED";
        public static const WEALTH_ERROR:String = "WEALTH_ERROR";

        public var vo:WealthVo;
        public var loadedIndex:int;
        public var total_loadeIndex:int;
        public var group_name:String;

        public function WealthEvent(_arg_1:String, _arg_2:Boolean=false, _arg_3:Boolean=false)
        {
            super(_arg_1, _arg_2, _arg_3);
        }

    }
}//package com.engine.core.controls.events

