// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.demonsters.debugger.MonsterDebuggerCore

package com.demonsters.debugger
{
    import flash.utils.Timer;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.text.TextField;
    import flash.display.DisplayObject;
    import com.demonsters.debugger.MonsterDebugger;
    import flash.display.BitmapData;
    import flash.utils.ByteArray;
    import flash.geom.Rectangle;
    import flash.system.Capabilities;
    import flash.utils.getDefinitionByName;
    import flash.external.ExternalInterface;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.text.TextFormat;
    import flash.text.TextFieldAutoSize;
    import com.demonsters.debugger.MonsterDebuggerData;
    import com.demonsters.debugger.*;

    class MonsterDebuggerCore 
    {

        private static const MONITOR_UPDATE:int = 1000;
        private static const HIGHLITE_COLOR:uint = 3381759;
        private static var _monitorTimer:Timer;
        private static var _monitorSprite:Sprite;
        private static var _monitorTime:Number;
        private static var _monitorStart:Number;
        private static var _monitorFrames:int;
        private static var _base:Object = null;
        private static var _stage:Stage = null;
        private static var _highlight:Sprite;
        private static var _highlightInfo:TextField;
        private static var _highlightTarget:DisplayObject;
        private static var _highlightMouse:Boolean;
        private static var _highlightUpdate:Boolean;
        static const ID:String = "com.demonsters.debugger.core";


        private static function send(_arg_1:Object, _arg_2:Boolean=false):void
        {
            if (MonsterDebugger.enabled){
                MonsterDebuggerConnection.send(MonsterDebuggerCore.ID, _arg_1, _arg_2);
            };
        }

        static function snapshot(_arg_1:*, _arg_2:DisplayObject, _arg_3:String="", _arg_4:String=""):void
        {
            var _local_5:BitmapData;
            var _local_6:ByteArray;
            var _local_7:Object;
            if (MonsterDebugger.enabled){
                _local_5 = MonsterDebuggerUtils.snapshot(_arg_2);
                if (_local_5 != null){
                    _local_6 = _local_5.getPixels(new Rectangle(0, 0, _local_5.width, _local_5.height));
                    _local_7 = {
                        "command":MonsterDebuggerConstants.COMMAND_SNAPSHOT,
                        "memory":MonsterDebuggerUtils.getMemory(),
                        "date":new Date(),
                        "target":String(_arg_1),
                        "reference":MonsterDebuggerUtils.getReferenceID(_arg_1),
                        "bytes":_local_6,
                        "width":_local_5.width,
                        "height":_local_5.height,
                        "person":_arg_3,
                        "label":_arg_4
                    };
                    send(_local_7);
                };
            };
        }

        static function trace(_arg_1:*, _arg_2:*, _arg_3:String="", _arg_4:String="", _arg_5:uint=0, _arg_6:int=5):void
        {
            var _local_7:XML;
            var _local_8:Object;
            if (MonsterDebugger.enabled){
                _local_7 = XML(MonsterDebuggerUtils.parse(_arg_2, "", 1, _arg_6, false));
                _local_8 = {
                    "command":MonsterDebuggerConstants.COMMAND_TRACE,
                    "memory":MonsterDebuggerUtils.getMemory(),
                    "date":new Date(),
                    "target":String(_arg_1),
                    "reference":MonsterDebuggerUtils.getReferenceID(_arg_1),
                    "xml":_local_7,
                    "person":_arg_3,
                    "label":_arg_4,
                    "color":_arg_5
                };
                send(_local_8);
            };
        }

        static function sendInformation():void
        {
            var UIComponentClass:* = undefined;
            var tmpLocation:String;
            var tmpTitle:String;
            var NativeApplicationClass:* = undefined;
            var descriptor:XML;
            var ns:Namespace;
            var filename:String;
            var FileClass:* = undefined;
            var slash:int;
            var playerType:String = Capabilities.playerType;
            var playerVersion:String = Capabilities.version;
            var isDebugger:Boolean = Capabilities.isDebugger;
            var isFlex:Boolean;
            var fileTitle:String = "";
            var fileLocation:String = "";
            try {
                UIComponentClass = getDefinitionByName("mx.core::UIComponent");
                if (UIComponentClass != null){
                    isFlex = true;
                };
            } catch(e1:Error) {
            };
            if ((((_base is DisplayObject)) && (_base.hasOwnProperty("loaderInfo")))){
                if (DisplayObject(_base).loaderInfo != null){
                    fileLocation = unescape(DisplayObject(_base).loaderInfo.url);
                };
            };
            if (_base.hasOwnProperty("stage")){
                if (((!((_base["stage"] == null))) && ((_base["stage"] is Stage)))){
                    fileLocation = unescape(Stage(_base["stage"]).loaderInfo.url);
                };
            };
            if ((((playerType == "ActiveX")) || ((playerType == "PlugIn")))){
                if (ExternalInterface.available){
                    try {
                        tmpLocation = ExternalInterface.call("window.location.href.toString");
                        tmpTitle = ExternalInterface.call("window.document.title.toString");
                        if (tmpLocation != null){
                            fileLocation = tmpLocation;
                        };
                        if (tmpTitle != null){
                            fileTitle = tmpTitle;
                        };
                    } catch(e2:Error) {
                    };
                };
            };
            if (playerType == "Desktop"){
                try {
                    NativeApplicationClass = getDefinitionByName("flash.desktop::NativeApplication");
                    if (NativeApplicationClass != null){
                        descriptor = NativeApplicationClass["nativeApplication"]["applicationDescriptor"];
                        ns = descriptor.namespace();
                        filename = descriptor.ns::filename;
                        FileClass = getDefinitionByName("flash.filesystem::File");
                        if (Capabilities.os.toLowerCase().indexOf("windows") != -1){
                            filename = (filename + ".exe");
                            fileLocation = FileClass["applicationDirectory"]["resolvePath"](filename)["nativePath"];
                        } else {
                            if (Capabilities.os.toLowerCase().indexOf("mac") != -1){
                                filename = (filename + ".app");
                                fileLocation = FileClass["applicationDirectory"]["resolvePath"](filename)["nativePath"];
                            };
                        };
                    };
                } catch(e3:Error) {
                };
            };
            if ((((fileTitle == "")) && (!((fileLocation == ""))))){
                slash = Math.max(fileLocation.lastIndexOf("\\"), fileLocation.lastIndexOf("/"));
                if (slash != -1){
                    fileTitle = fileLocation.substring((slash + 1), fileLocation.lastIndexOf("."));
                } else {
                    fileTitle = fileLocation;
                };
            };
            if (fileTitle == ""){
                fileTitle = "Application";
            };
            var data:Object = {
                "command":MonsterDebuggerConstants.COMMAND_INFO,
                "debuggerVersion":MonsterDebugger.VERSION,
                "playerType":playerType,
                "playerVersion":playerVersion,
                "isDebugger":isDebugger,
                "isFlex":isFlex,
                "fileLocation":fileLocation,
                "fileTitle":fileTitle
            };
            send(data, true);
            MonsterDebuggerConnection.processQueue();
        }

        static function clear():void
        {
            if (MonsterDebugger.enabled){
                send({"command":MonsterDebuggerConstants.COMMAND_CLEAR_TRACES});
            };
        }

        static function get base()
        {
            return (_base);
        }

        private static function monitorTimerCallback(_arg_1:TimerEvent):void
        {
            var _local_2:Number;
            var _local_3:Number;
            var _local_4:uint;
            var _local_5:uint;
            var _local_6:Object;
            if (MonsterDebugger.enabled){
                _local_2 = new Date().time;
                _local_3 = (_local_2 - _monitorTime);
                _local_4 = ((_monitorFrames / _local_3) * 1000);
                _local_5 = 0;
                if (_stage == null){
                    if (((((_base.hasOwnProperty("stage")) && (!((_base["stage"] == null))))) && ((_base["stage"] is Stage)))){
                        _stage = Stage(_base["stage"]);
                    };
                };
                if (_stage != null){
                    _local_5 = _stage.frameRate;
                };
                _monitorFrames = 0;
                _monitorTime = _local_2;
                if (MonsterDebuggerConnection.connected){
                    _local_6 = {
                        "command":MonsterDebuggerConstants.COMMAND_MONITOR,
                        "memory":MonsterDebuggerUtils.getMemory(),
                        "fps":_local_4,
                        "fpsMovie":_local_5,
                        "time":_local_2
                    };
                    send(_local_6);
                };
            };
        }

        private static function highlightClicked(_arg_1:MouseEvent):void
        {
            _arg_1.preventDefault();
            _arg_1.stopImmediatePropagation();
            highlightClear();
            _highlightTarget = MonsterDebuggerUtils.getObjectUnderPoint(_stage, new Point(_stage.mouseX, _stage.mouseY));
            _highlightMouse = false;
            _highlight.removeEventListener(MouseEvent.CLICK, highlightClicked);
            _highlight.mouseEnabled = false;
            if (_highlightTarget != null){
                inspect(_highlightTarget);
                highlightDraw(false);
            };
            send({"command":MonsterDebuggerConstants.COMMAND_STOP_HIGHLIGHT});
        }

        static function initialize():void
        {
            _monitorTime = new Date().time;
            _monitorStart = new Date().time;
            _monitorFrames = 0;
            _monitorTimer = new Timer(MONITOR_UPDATE);
            _monitorTimer.addEventListener(TimerEvent.TIMER, monitorTimerCallback, false, 0, true);
            _monitorTimer.start();
            if (((((_base.hasOwnProperty("stage")) && (!((_base["stage"] == null))))) && ((_base["stage"] is Stage)))){
                _stage = (_base["stage"] as Stage);
            };
            _monitorSprite = new Sprite();
            _monitorSprite.addEventListener(Event.ENTER_FRAME, frameHandler, false, 0, true);
            var _local_1:TextFormat = new TextFormat();
            _local_1.font = "Arial";
            _local_1.color = 0xFFFFFF;
            _local_1.size = 11;
            _local_1.leftMargin = 5;
            _local_1.rightMargin = 5;
            _highlightInfo = new TextField();
            _highlightInfo.embedFonts = false;
            _highlightInfo.autoSize = TextFieldAutoSize.LEFT;
            _highlightInfo.mouseWheelEnabled = false;
            _highlightInfo.mouseEnabled = false;
            _highlightInfo.condenseWhite = false;
            _highlightInfo.embedFonts = false;
            _highlightInfo.multiline = false;
            _highlightInfo.selectable = false;
            _highlightInfo.wordWrap = false;
            _highlightInfo.defaultTextFormat = _local_1;
            _highlightInfo.text = "";
            _highlight = new Sprite();
            _highlightMouse = false;
            _highlightTarget = null;
            _highlightUpdate = false;
        }

        private static function highlightDraw(fill:Boolean):void
        {
            if (_highlightTarget == null){
                return;
            };
            var boundsOuter:Rectangle = _highlightTarget.getBounds(_stage);
            if ((_highlightTarget is Stage)){
                boundsOuter.x = 0;
                boundsOuter.y = 0;
                boundsOuter.width = _highlightTarget["stageWidth"];
                boundsOuter.height = _highlightTarget["stageHeight"];
            } else {
                boundsOuter.x = int((boundsOuter.x + 0.5));
                boundsOuter.y = int((boundsOuter.y + 0.5));
                boundsOuter.width = int((boundsOuter.width + 0.5));
                boundsOuter.height = int((boundsOuter.height + 0.5));
            };
            var boundsInner:Rectangle = boundsOuter.clone();
            boundsInner.x = (boundsInner.x + 2);
            boundsInner.y = (boundsInner.y + 2);
            boundsInner.width = (boundsInner.width - 4);
            boundsInner.height = (boundsInner.height - 4);
            if (boundsInner.width < 0){
                boundsInner.width = 0;
            };
            if (boundsInner.height < 0){
                boundsInner.height = 0;
            };
            _highlight.graphics.clear();
            _highlight.graphics.beginFill(HIGHLITE_COLOR, 1);
            _highlight.graphics.drawRect(boundsOuter.x, boundsOuter.y, boundsOuter.width, boundsOuter.height);
            _highlight.graphics.drawRect(boundsInner.x, boundsInner.y, boundsInner.width, boundsInner.height);
            if (fill){
                _highlight.graphics.beginFill(HIGHLITE_COLOR, 0.25);
                _highlight.graphics.drawRect(boundsInner.x, boundsInner.y, boundsInner.width, boundsInner.height);
            };
            if (_highlightTarget.name != null){
                _highlightInfo.text = ((String(_highlightTarget.name) + " - ") + String(MonsterDebuggerDescribeType.get(_highlightTarget).@name));
            } else {
                _highlightInfo.text = String(MonsterDebuggerDescribeType.get(_highlightTarget).@name);
            };
            var boundsText:Rectangle = new Rectangle(boundsOuter.x, (boundsOuter.y - (_highlightInfo.textHeight + 3)), (_highlightInfo.textWidth + 15), (_highlightInfo.textHeight + 5));
            if (boundsText.y < 0){
                boundsText.y = (boundsOuter.y + boundsOuter.height);
            };
            if ((boundsText.y + boundsText.height) > _stage.stageHeight){
                boundsText.y = (_stage.stageHeight - boundsText.height);
            };
            if (boundsText.x < 0){
                boundsText.x = 0;
            };
            if ((boundsText.x + boundsText.width) > _stage.stageWidth){
                boundsText.x = (_stage.stageWidth - boundsText.width);
            };
            _highlight.graphics.beginFill(HIGHLITE_COLOR, 1);
            _highlight.graphics.drawRect(boundsText.x, boundsText.y, boundsText.width, boundsText.height);
            _highlight.graphics.endFill();
            _highlightInfo.x = boundsText.x;
            _highlightInfo.y = boundsText.y;
            try {
                _stage.addChild(_highlight);
                _stage.addChild(_highlightInfo);
            } catch(e:Error) {
            };
        }

        private static function handleInternal(item:MonsterDebuggerData):void
        {
            var obj:* = undefined;
            var xml:XML;
            var method:Function;
            var displayObject:DisplayObject;
            var bitmapData:BitmapData;
            var bytes:ByteArray;
            switch (item.data["command"]){
                case MonsterDebuggerConstants.COMMAND_HELLO:
                    sendInformation();
                    return;
                case MonsterDebuggerConstants.COMMAND_BASE:
                    obj = MonsterDebuggerUtils.getObject(_base, "", 0);
                    if (obj != null){
                        xml = XML(MonsterDebuggerUtils.parse(obj, "", 1, 2, true));
                        send({
                            "command":MonsterDebuggerConstants.COMMAND_BASE,
                            "xml":xml
                        });
                    };
                    return;
                case MonsterDebuggerConstants.COMMAND_INSPECT:
                    obj = MonsterDebuggerUtils.getObject(_base, item.data["target"], 0);
                    if (obj != null){
                        _base = obj;
                        xml = XML(MonsterDebuggerUtils.parse(obj, "", 1, 2, true));
                        send({
                            "command":MonsterDebuggerConstants.COMMAND_BASE,
                            "xml":xml
                        });
                    };
                    return;
                case MonsterDebuggerConstants.COMMAND_GET_OBJECT:
                    obj = MonsterDebuggerUtils.getObject(_base, item.data["target"], 0);
                    if (obj != null){
                        xml = XML(MonsterDebuggerUtils.parse(obj, item.data["target"], 1, 2, true));
                        send({
                            "command":MonsterDebuggerConstants.COMMAND_GET_OBJECT,
                            "xml":xml
                        });
                    };
                    return;
                case MonsterDebuggerConstants.COMMAND_GET_PROPERTIES:
                    obj = MonsterDebuggerUtils.getObject(_base, item.data["target"], 0);
                    if (obj != null){
                        xml = XML(MonsterDebuggerUtils.parse(obj, item.data["target"], 1, 1, false));
                        send({
                            "command":MonsterDebuggerConstants.COMMAND_GET_PROPERTIES,
                            "xml":xml
                        });
                    };
                    return;
                case MonsterDebuggerConstants.COMMAND_GET_FUNCTIONS:
                    obj = MonsterDebuggerUtils.getObject(_base, item.data["target"], 0);
                    if (obj != null){
                        xml = XML(MonsterDebuggerUtils.parseFunctions(obj, item.data["target"]));
                        send({
                            "command":MonsterDebuggerConstants.COMMAND_GET_FUNCTIONS,
                            "xml":xml
                        });
                    };
                    return;
                case MonsterDebuggerConstants.COMMAND_SET_PROPERTY:
                    obj = MonsterDebuggerUtils.getObject(_base, item.data["target"], 1);
                    if (obj != null){
                        try {
                            obj[item.data["name"]] = item.data["value"];
                            send({
                                "command":MonsterDebuggerConstants.COMMAND_SET_PROPERTY,
                                "target":item.data["target"],
                                "value":obj[item.data["name"]]
                            });
                        } catch(e1:Error) {
                        };
                    };
                    return;
                case MonsterDebuggerConstants.COMMAND_GET_PREVIEW:
                    obj = MonsterDebuggerUtils.getObject(_base, item.data["target"], 0);
                    if (((!((obj == null))) && (MonsterDebuggerUtils.isDisplayObject(obj)))){
                        displayObject = (obj as DisplayObject);
                        bitmapData = MonsterDebuggerUtils.snapshot(displayObject, new Rectangle(0, 0, 300, 300));
                        if (bitmapData != null){
                            bytes = bitmapData.getPixels(new Rectangle(0, 0, bitmapData.width, bitmapData.height));
                            send({
                                "command":MonsterDebuggerConstants.COMMAND_GET_PREVIEW,
                                "bytes":bytes,
                                "width":bitmapData.width,
                                "height":bitmapData.height
                            });
                        };
                    };
                    return;
                case MonsterDebuggerConstants.COMMAND_CALL_METHOD:
                    method = MonsterDebuggerUtils.getObject(_base, item.data["target"], 0);
                    if (((!((method == null))) && ((method is Function)))){
                        if (item.data["returnType"] == MonsterDebuggerConstants.TYPE_VOID){
                            method.apply(null, item.data["arguments"]);
                        } else {
                            try {
                                obj = method.apply(null, item.data["arguments"]);
                                xml = XML(MonsterDebuggerUtils.parse(obj, "", 1, 5, false));
                                send({
                                    "command":MonsterDebuggerConstants.COMMAND_CALL_METHOD,
                                    "id":item.data["id"],
                                    "xml":xml
                                });
                            } catch(e2:Error) {
                            };
                        };
                    };
                    return;
                case MonsterDebuggerConstants.COMMAND_PAUSE:
                    MonsterDebuggerUtils.pause();
                    send({"command":MonsterDebuggerConstants.COMMAND_PAUSE});
                    return;
                case MonsterDebuggerConstants.COMMAND_RESUME:
                    MonsterDebuggerUtils.resume();
                    send({"command":MonsterDebuggerConstants.COMMAND_RESUME});
                    return;
                case MonsterDebuggerConstants.COMMAND_HIGHLIGHT:
                    obj = MonsterDebuggerUtils.getObject(_base, item.data["target"], 0);
                    if (((!((obj == null))) && (MonsterDebuggerUtils.isDisplayObject(obj)))){
                        if (((!((DisplayObject(obj).stage == null))) && ((DisplayObject(obj).stage is Stage)))){
                            _stage = obj["stage"];
                        };
                        if (_stage != null){
                            highlightClear();
                            send({"command":MonsterDebuggerConstants.COMMAND_STOP_HIGHLIGHT});
                            _highlight.removeEventListener(MouseEvent.CLICK, highlightClicked);
                            _highlight.mouseEnabled = false;
                            _highlightTarget = DisplayObject(obj);
                            _highlightMouse = false;
                            _highlightUpdate = true;
                        };
                    };
                    return;
                case MonsterDebuggerConstants.COMMAND_START_HIGHLIGHT:
                    highlightClear();
                    _highlight.addEventListener(MouseEvent.CLICK, highlightClicked, false, 0, true);
                    _highlight.mouseEnabled = true;
                    _highlightTarget = null;
                    _highlightMouse = true;
                    _highlightUpdate = true;
                    send({"command":MonsterDebuggerConstants.COMMAND_START_HIGHLIGHT});
                    return;
                case MonsterDebuggerConstants.COMMAND_STOP_HIGHLIGHT:
                    highlightClear();
                    _highlight.removeEventListener(MouseEvent.CLICK, highlightClicked);
                    _highlight.mouseEnabled = false;
                    _highlightTarget = null;
                    _highlightMouse = false;
                    _highlightUpdate = false;
                    send({"command":MonsterDebuggerConstants.COMMAND_STOP_HIGHLIGHT});
                    return;
            };
        }

        static function inspect(_arg_1:*):void
        {
            var _local_2:*;
            var _local_3:XML;
            if (MonsterDebugger.enabled){
                _base = _arg_1;
                _local_2 = MonsterDebuggerUtils.getObject(_base, "", 0);
                if (_local_2 != null){
                    _local_3 = XML(MonsterDebuggerUtils.parse(_local_2, "", 1, 2, true));
                    send({
                        "command":MonsterDebuggerConstants.COMMAND_BASE,
                        "xml":_local_3
                    });
                };
            };
        }

        private static function frameHandler(_arg_1:Event):void
        {
            if (MonsterDebugger.enabled){
                _monitorFrames++;
                if (_highlightUpdate){
                    highlightUpdate();
                };
            };
        }

        static function set base(_arg_1:*):void
        {
            _base = _arg_1;
        }

        private static function highlightUpdate():void
        {
            var _local_1:*;
            highlightClear();
            if (_highlightMouse){
                if (((((_base.hasOwnProperty("stage")) && (!((_base["stage"] == null))))) && ((_base["stage"] is Stage)))){
                    _stage = (_base["stage"] as Stage);
                };
                if (Capabilities.playerType == "Desktop"){
                    _local_1 = getDefinitionByName("flash.desktop::NativeApplication");
                    if (((!((_local_1 == null))) && (!((_local_1["nativeApplication"]["activeWindow"] == null))))){
                        _stage = _local_1["nativeApplication"]["activeWindow"]["stage"];
                    };
                };
                if (_stage == null){
                    _highlight.removeEventListener(MouseEvent.CLICK, highlightClicked);
                    _highlight.mouseEnabled = false;
                    _highlightTarget = null;
                    _highlightMouse = false;
                    _highlightUpdate = false;
                    return;
                };
                _highlightTarget = MonsterDebuggerUtils.getObjectUnderPoint(_stage, new Point(_stage.mouseX, _stage.mouseY));
                if (_highlightTarget != null){
                    highlightDraw(true);
                };
                return;
            };
            if (_highlightTarget != null){
                if ((((_highlightTarget.stage == null)) || ((_highlightTarget.parent == null)))){
                    _highlight.removeEventListener(MouseEvent.CLICK, highlightClicked);
                    _highlight.mouseEnabled = false;
                    _highlightTarget = null;
                    _highlightMouse = false;
                    _highlightUpdate = false;
                    return;
                };
                highlightDraw(false);
            };
        }

        static function handle(_arg_1:MonsterDebuggerData):void
        {
            if (MonsterDebugger.enabled){
                if ((((_arg_1.id == null)) || ((_arg_1.id == "")))){
                    return;
                };
                if (_arg_1.id == MonsterDebuggerCore.ID){
                    handleInternal(_arg_1);
                };
            };
        }

        static function breakpoint(_arg_1:*, _arg_2:String="breakpoint"):void
        {
            var _local_3:XML;
            var _local_4:Object;
            if (((MonsterDebugger.enabled) && (MonsterDebuggerConnection.connected))){
                _local_3 = MonsterDebuggerUtils.stackTrace();
                _local_4 = {
                    "command":MonsterDebuggerConstants.COMMAND_PAUSE,
                    "memory":MonsterDebuggerUtils.getMemory(),
                    "date":new Date(),
                    "target":String(_arg_1),
                    "reference":MonsterDebuggerUtils.getReferenceID(_arg_1),
                    "stack":_local_3,
                    "id":_arg_2
                };
                send(_local_4);
                MonsterDebuggerUtils.pause();
            };
        }

        private static function highlightClear():void
        {
            if (((!((_highlight == null))) && (!((_highlight.parent == null))))){
                _highlight.parent.removeChild(_highlight);
                _highlight.graphics.clear();
                _highlight.x = 0;
                _highlight.y = 0;
            };
            if (((!((_highlightInfo == null))) && (!((_highlightInfo.parent == null))))){
                _highlightInfo.parent.removeChild(_highlightInfo);
                _highlightInfo.x = 0;
                _highlightInfo.y = 0;
            };
        }


    }
}//package com.demonsters.debugger

