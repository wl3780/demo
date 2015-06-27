// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.utils.Track

package com.engine.utils
{
    import com.engine.core.Core;

    public class Track 
    {


        public static function track(... _args):void
        {
            if (Core.track != null){
                Core.track.apply(null, _args);
            } else {
                trace(_args);
            };
        }


    }
}//package com.engine.utils

