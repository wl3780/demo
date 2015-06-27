// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.demonsters.debugger.MonsterDebuggerDescribeType

package com.demonsters.debugger
{
    import flash.utils.getQualifiedClassName;
    import flash.utils.describeType;
    import com.demonsters.debugger.*;

    class MonsterDebuggerDescribeType 
    {

        private static var cache:Object = {};


        static function get(_arg_1:*):XML
        {
            var _local_2:String = getQualifiedClassName(_arg_1);
            if ((_local_2 in cache)){
                return (cache[_local_2]);
            };
            var _local_3:XML = describeType(_arg_1);
            cache[_local_2] = _local_3;
            return (_local_3);
        }


    }
}//package com.demonsters.debugger

