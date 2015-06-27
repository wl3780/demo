// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.demonsters.debugger.MonsterDebuggerConnection

package com.demonsters.debugger
{
    class MonsterDebuggerConnection 
    {

        private static var connector:IMonsterDebuggerConnection;


        static function initialize():void
        {
            connector = new MonsterDebuggerConnectionDefault();
        }

        static function processQueue():void
        {
            connector.processQueue();
        }

        static function set address(_arg_1:String):void
        {
            connector.address = _arg_1;
        }

        static function get connected():Boolean
        {
            return (connector.connected);
        }

        static function connect():void
        {
            connector.connect();
        }

        static function send(_arg_1:String, _arg_2:Object, _arg_3:Boolean=false):void
        {
            connector.send(_arg_1, _arg_2, _arg_3);
        }


    }
}//package com.demonsters.debugger

