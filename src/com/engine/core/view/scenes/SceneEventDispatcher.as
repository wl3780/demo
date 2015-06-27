// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.scenes.SceneEventDispatcher

package com.engine.core.view.scenes
{
    import flash.events.EventDispatcher;

    public class SceneEventDispatcher extends EventDispatcher 
    {

        private static var _instance:SceneEventDispatcher;


        public static function getInstance():SceneEventDispatcher
        {
            if (_instance == null){
                _instance = new (SceneEventDispatcher)();
            };
            return (_instance);
        }


    }
}//package com.engine.core.view.scenes

