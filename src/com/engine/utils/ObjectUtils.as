// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.utils.ObjectUtils

package com.engine.utils
{
    import flash.utils.ByteArray;

    public class ObjectUtils 
    {


        public static function copy(_arg_1:Object):Object
        {
            var _local_2:ByteArray = new ByteArray();
            _local_2.writeObject(_arg_1);
            _local_2.position = 0;
            return (_local_2.readObject());
        }


    }
}//package com.engine.utils

