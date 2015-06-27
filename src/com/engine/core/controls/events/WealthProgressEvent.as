// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.events.WealthProgressEvent

package com.engine.core.controls.events
{
    import flash.events.ProgressEvent;
    import com.engine.core.model.wealth.WealthVo;

    public class WealthProgressEvent extends ProgressEvent 
    {

        public static const Progress:String = "WealthProgress";

        public var path:String;
        public var wealth_id:String;
        public var wealth_gid:String;
        public var vo:WealthVo;
        public var totlaIndex:int;
        public var loadedIndex:int;
        public var group_name:String;

        public function WealthProgressEvent(_arg_1:String, _arg_2:Boolean=false, _arg_3:Boolean=false, _arg_4:uint=0, _arg_5:uint=0)
        {
            super(_arg_1, _arg_2, _arg_3, _arg_4, _arg_5);
        }

    }
}//package com.engine.core.controls.events

