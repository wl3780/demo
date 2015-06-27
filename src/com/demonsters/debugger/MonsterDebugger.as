// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.demonsters.debugger.MonsterDebugger

package com.demonsters.debugger
{
    import flash.display.DisplayObject;

    public class MonsterDebugger 
    {

        private static var _enabled:Boolean = true;
        private static var _initialized:Boolean = false;
        static const VERSION:Number = 3.02;
        public static var logger:Function;


        public static function get enabled():Boolean
        {
            return (_enabled);
        }

        public static function trace(_arg_1:*, _arg_2:*, _arg_3:String="", _arg_4:String="", _arg_5:uint=0, _arg_6:int=5):void
        {
            if (((_initialized) && (_enabled))){
                MonsterDebuggerCore.trace(_arg_1, _arg_2, _arg_3, _arg_4, _arg_5, _arg_6);
            };
        }

        public static function log(... args):void
        {
            var target:String;
            var stack:String;
            var lines:Array;
            var s:String;
            var bracketIndex:int;
            var methodIndex:int;
            if (((_initialized) && (_enabled))){
                if (args.length == 0){
                    return;
                };
                target = "Log";
                try {
                    throw (new Error());
                } catch(e:Error) {
                    stack = e.getStackTrace();
                    if (((!((stack == null))) && (!((stack == ""))))){
                        stack = stack.split("\t").join("");
                        lines = stack.split("\n");
                        if (lines.length > 2){
                            lines.shift();
                            lines.shift();
                            s = lines[0];
                            s = s.substring(3, s.length);
                            bracketIndex = s.indexOf("[");
                            methodIndex = s.indexOf("/");
                            if (bracketIndex == -1){
                                bracketIndex = s.length;
                            };
                            if (methodIndex == -1){
                                methodIndex = bracketIndex;
                            };
                            target = MonsterDebuggerUtils.parseType(s.substring(0, methodIndex));
                            if (target == "<anonymous>"){
                                target = "";
                            };
                            if (target == ""){
                                target = "Log";
                            };
                        };
                    };
                };
                if (args.length == 1){
                    MonsterDebuggerCore.trace(target, args[0], "", "", 0, 5);
                } else {
                    MonsterDebuggerCore.trace(target, args, "", "", 0, 5);
                };
            };
        }

        public static function clear():void
        {
            if (((_initialized) && (_enabled))){
                MonsterDebuggerCore.clear();
            };
        }

        public static function set enabled(_arg_1:Boolean):void
        {
            _enabled = _arg_1;
        }

        public static function snapshot(_arg_1:*, _arg_2:DisplayObject, _arg_3:String="", _arg_4:String=""):void
        {
            if (((_initialized) && (_enabled))){
                MonsterDebuggerCore.snapshot(_arg_1, _arg_2, _arg_3, _arg_4);
            };
        }

        public static function inspect(_arg_1:*):void
        {
            if (((_initialized) && (_enabled))){
                MonsterDebuggerCore.inspect(_arg_1);
            };
        }

        public static function breakpoint(_arg_1:*, _arg_2:String="breakpoint"):void
        {
            if (((_initialized) && (_enabled))){
                MonsterDebuggerCore.breakpoint(_arg_1, _arg_2);
            };
        }

        public static function initialize(_arg_1:Object, _arg_2:String="127.0.0.1"):void
        {
            if (!_initialized){
                _initialized = true;
                MonsterDebuggerCore.base = _arg_1;
                MonsterDebuggerCore.initialize();
                MonsterDebuggerConnection.initialize();
                MonsterDebuggerConnection.address = _arg_2;
                MonsterDebuggerConnection.connect();
            };
        }


    }
}//package com.demonsters.debugger

