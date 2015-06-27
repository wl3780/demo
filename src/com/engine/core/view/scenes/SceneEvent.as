// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.scenes.SceneEvent

package com.engine.core.view.scenes
{
    import flash.events.Event;

    public class SceneEvent extends Event 
    {

        public static const WALK_END:String = "WALK_END";
        public static const REMOVE_CHAR:String = "REMOVE_CHAR";
        public static const MOUSE_DOWN:String = "MOUSE_DOWN";
        public static const MOUSE_UP:String = "MOUSE_UP";
        public static const KEY_UP:String = "KEY_UP";
        public static const KEY_DOWN:String = "KEY_DOWN";
        public static const CHAGE_SCENE:String = "CHAGE_SCENE";

        public var proto:Object;
        public var walkEndType:int = 1;

        public function SceneEvent(_arg_1:String, _arg_2:Boolean=false, _arg_3:Boolean=false)
        {
            super(_arg_1, _arg_2, _arg_3);
        }

    }
}//package com.engine.core.view.scenes

