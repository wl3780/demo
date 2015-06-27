// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.demonsters.debugger.MonsterDebuggerUtils

package com.demonsters.debugger
{
    import flash.utils.Dictionary;
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.display.Stage;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.utils.getQualifiedClassName;
    import flash.system.System;
    import flash.geom.Point;
    import com.demonsters.debugger.*;

    class MonsterDebuggerUtils 
    {

        private static var _references:Dictionary = new Dictionary(true);
        private static var _reference:int = 0;


        public static function snapshot(object:DisplayObject, rectangle:Rectangle=null):BitmapData
        {
            var bitmapData:BitmapData;
            var m:Matrix;
            var scaled:Rectangle;
            var s:Number;
            var b:BitmapData;
            if (object == null){
                return (null);
            };
            var visible:Boolean = object.visible;
            var alpha:Number = object.alpha;
            var rotation:Number = object.rotation;
            var scaleX:Number = object.scaleX;
            var scaleY:Number = object.scaleY;
            try {
                object.visible = true;
                object.alpha = 1;
                object.rotation = 0;
                object.scaleX = 1;
                object.scaleY = 1;
            } catch(e1:Error) {
            };
            var bounds:Rectangle = object.getBounds(object);
            bounds.x = int((bounds.x + 0.5));
            bounds.y = int((bounds.y + 0.5));
            bounds.width = int((bounds.width + 0.5));
            bounds.height = int((bounds.height + 0.5));
            if ((object is Stage)){
                bounds.x = 0;
                bounds.y = 0;
                bounds.width = Stage(object).stageWidth;
                bounds.height = Stage(object).stageHeight;
            };
            bitmapData = null;
            if ((((bounds.width <= 0)) || ((bounds.height <= 0)))){
                return (null);
            };
            try {
                bitmapData = new BitmapData(bounds.width, bounds.height, false, 0xFFFFFF);
                m = new Matrix();
                m.tx = -(bounds.x);
                m.ty = -(bounds.y);
                bitmapData.draw(object, m, null, null, null, false);
            } catch(e2:Error) {
                bitmapData = null;
            };
            try {
                object.visible = visible;
                object.alpha = alpha;
                object.rotation = rotation;
                object.scaleX = scaleX;
                object.scaleY = scaleY;
            } catch(e3:Error) {
            };
            if (bitmapData == null){
                return (null);
            };
            if (rectangle != null){
                if ((((bounds.width <= rectangle.width)) && ((bounds.height <= rectangle.height)))){
                    return (bitmapData);
                };
                scaled = bounds.clone();
                scaled.width = rectangle.width;
                scaled.height = (rectangle.width * (bounds.height / bounds.width));
                if (scaled.height > rectangle.height){
                    scaled = bounds.clone();
                    scaled.width = (rectangle.height * (bounds.width / bounds.height));
                    scaled.height = rectangle.height;
                };
                s = (scaled.width / bounds.width);
                try {
                    b = new BitmapData(scaled.width, scaled.height, false, 0);
                    m = new Matrix();
                    m.scale(s, s);
                    b.draw(bitmapData, m, null, null, null, true);
                    bitmapData.dispose();
                    bitmapData = b;
                } catch(e4:Error) {
                    bitmapData.dispose();
                    bitmapData = null;
                };
            };
            return (bitmapData);
        }

        private static function parseClass(object:*, target:String, description:XML, currentDepth:int=1, maxDepth:int=5, includeDisplayObjects:Boolean=true):XML
        {
            var key:String;
            var itemsArrayLength:int;
            var item:* = undefined;
            var itemXML:XML;
            var itemAccess:String;
            var itemPermission:String;
            var itemIcon:String;
            var itemType:String;
            var itemName:String;
            var itemTarget:String;
            var i:int;
            var prop:* = undefined;
            var displayObject:DisplayObjectContainer;
            var displayObjects:Array;
            var child:DisplayObject;
            var rootXML:XML = new XML("<root/>");
            var nodeXML:XML = new XML("<node/>");
            var variables:XMLList = description..variable;
            var accessors:XMLList = description..accessor;
            var constants:XMLList = description..constant;
            var isDynamic:Boolean = Boolean(description.@isDynamic);
            var variablesLength:int = variables.length();
            var accessorsLength:int = accessors.length();
            var constantsLength:int = constants.length();
            var childLength:int;
            var keys:Object = {};
            var itemsArray:Array = [];
            if (isDynamic){
                for (prop in object) {
                    key = String(prop);
                    if (!keys.hasOwnProperty(key)){
                        keys[key] = key;
                        itemName = key;
                        itemType = parseType(getQualifiedClassName(object[key]));
                        itemTarget = ((target + ".") + key);
                        itemAccess = MonsterDebuggerConstants.ACCESS_VARIABLE;
                        itemPermission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                        itemIcon = MonsterDebuggerConstants.ICON_VARIABLE;
                        itemsArray[itemsArray.length] = {
                            "name":itemName,
                            "type":itemType,
                            "target":itemTarget,
                            "access":itemAccess,
                            "permission":itemPermission,
                            "icon":itemIcon
                        };
                    };
                };
            };
            i = 0;
            while (i < variablesLength) {
                key = variables[i].@name;
                if (!keys.hasOwnProperty(key)){
                    keys[key] = key;
                    itemName = key;
                    itemType = parseType(variables[i].@type);
                    itemTarget = ((target + ".") + key);
                    itemAccess = MonsterDebuggerConstants.ACCESS_VARIABLE;
                    itemPermission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                    itemIcon = MonsterDebuggerConstants.ICON_VARIABLE;
                    itemsArray[itemsArray.length] = {
                        "name":itemName,
                        "type":itemType,
                        "target":itemTarget,
                        "access":itemAccess,
                        "permission":itemPermission,
                        "icon":itemIcon
                    };
                };
                i = (i + 1);
            };
            i = 0;
            while (i < accessorsLength) {
                key = accessors[i].@name;
                if (!keys.hasOwnProperty(key)){
                    keys[key] = key;
                    itemName = key;
                    itemType = parseType(accessors[i].@type);
                    itemTarget = ((target + ".") + key);
                    itemAccess = MonsterDebuggerConstants.ACCESS_ACCESSOR;
                    itemPermission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                    itemIcon = MonsterDebuggerConstants.ICON_VARIABLE;
                    if (accessors[i].@access == MonsterDebuggerConstants.PERMISSION_READONLY){
                        itemPermission = MonsterDebuggerConstants.PERMISSION_READONLY;
                        itemIcon = MonsterDebuggerConstants.ICON_VARIABLE_READONLY;
                    };
                    if (accessors[i].@access == MonsterDebuggerConstants.PERMISSION_WRITEONLY){
                        itemPermission = MonsterDebuggerConstants.PERMISSION_WRITEONLY;
                        itemIcon = MonsterDebuggerConstants.ICON_VARIABLE_WRITEONLY;
                    };
                    itemsArray[itemsArray.length] = {
                        "name":itemName,
                        "type":itemType,
                        "target":itemTarget,
                        "access":itemAccess,
                        "permission":itemPermission,
                        "icon":itemIcon
                    };
                };
                i = (i + 1);
            };
            i = 0;
            while (i < constantsLength) {
                key = constants[i].@name;
                if (!keys.hasOwnProperty(key)){
                    keys[key] = key;
                    itemName = key;
                    itemType = parseType(constants[i].@type);
                    itemTarget = ((target + ".") + key);
                    itemAccess = MonsterDebuggerConstants.ACCESS_CONSTANT;
                    itemPermission = MonsterDebuggerConstants.PERMISSION_READONLY;
                    itemIcon = MonsterDebuggerConstants.ICON_VARIABLE_READONLY;
                    itemsArray[itemsArray.length] = {
                        "name":itemName,
                        "type":itemType,
                        "target":itemTarget,
                        "access":itemAccess,
                        "permission":itemPermission,
                        "icon":itemIcon
                    };
                };
                i = (i + 1);
            };
            itemsArray.sortOn("name", Array.CASEINSENSITIVE);
            if (((includeDisplayObjects) && ((object is DisplayObjectContainer)))){
                displayObject = DisplayObjectContainer(object);
                displayObjects = [];
                childLength = displayObject.numChildren;
                i = 0;
                while (i < childLength) {
                    child = null;
                    try {
                        child = displayObject.getChildAt(i);
                    } catch(e1:Error) {
                    };
                    if (child != null){
                        itemXML = MonsterDebuggerDescribeType.get(child);
                        itemType = parseType(itemXML.@name);
                        itemName = "DisplayObject";
                        if (child.name != null){
                            itemName = (itemName + (" - " + child.name));
                        };
                        itemTarget = ((((target + ".") + "getChildAt(") + i) + ")");
                        itemAccess = MonsterDebuggerConstants.ACCESS_DISPLAY_OBJECT;
                        itemPermission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                        itemIcon = (((child is DisplayObjectContainer)) ? MonsterDebuggerConstants.ICON_ROOT : MonsterDebuggerConstants.ICON_DISPLAY_OBJECT);
                        displayObjects[displayObjects.length] = {
                            "name":itemName,
                            "type":itemType,
                            "target":itemTarget,
                            "access":itemAccess,
                            "permission":itemPermission,
                            "icon":itemIcon,
                            "index":i
                        };
                    };
                    i = (i + 1);
                };
                displayObjects.sortOn("name", Array.CASEINSENSITIVE);
                itemsArray = displayObjects.concat(itemsArray);
            };
            itemsArrayLength = itemsArray.length;
            i = 0;
            while (i < itemsArrayLength) {
                itemType = itemsArray[i].type;
                itemName = itemsArray[i].name;
                itemTarget = itemsArray[i].target;
                itemPermission = itemsArray[i].permission;
                itemAccess = itemsArray[i].access;
                itemIcon = itemsArray[i].icon;
                if (itemPermission != MonsterDebuggerConstants.PERMISSION_WRITEONLY){
                    try {
                        if (itemAccess == MonsterDebuggerConstants.ACCESS_DISPLAY_OBJECT){
                            item = DisplayObjectContainer(object).getChildAt(itemsArray[i].index);
                        } else {
                            item = object[itemName];
                        };
                    } catch(e2:Error) {
                        item = null;
                    };
                    if ((((((((((((itemType == MonsterDebuggerConstants.TYPE_STRING)) || ((itemType == MonsterDebuggerConstants.TYPE_BOOLEAN)))) || ((itemType == MonsterDebuggerConstants.TYPE_NUMBER)))) || ((itemType == MonsterDebuggerConstants.TYPE_INT)))) || ((itemType == MonsterDebuggerConstants.TYPE_UINT)))) || ((itemType == MonsterDebuggerConstants.TYPE_FUNCTION)))){
                        nodeXML = new XML("<node/>");
                        nodeXML.@icon = itemIcon;
                        nodeXML.@label = ((((itemName + " (") + itemType) + ") = ") + printValue(item, itemType, true));
                        nodeXML.@name = itemName;
                        nodeXML.@type = itemType;
                        nodeXML.@value = printValue(item, itemType);
                        nodeXML.@target = itemTarget;
                        nodeXML.@access = itemAccess;
                        nodeXML.@permission = itemPermission;
                        rootXML.appendChild(nodeXML);
                    } else {
                        nodeXML = new XML("<node/>");
                        nodeXML.@icon = itemIcon;
                        nodeXML.@label = (((itemName + " (") + itemType) + ")");
                        nodeXML.@name = itemName;
                        nodeXML.@type = itemType;
                        nodeXML.@target = itemTarget;
                        nodeXML.@access = itemAccess;
                        nodeXML.@permission = itemPermission;
                        if (item == null){
                            nodeXML.@icon = MonsterDebuggerConstants.ICON_WARNING;
                            nodeXML.@label = (nodeXML.@label + " = null");
                        };
                        nodeXML.appendChild(parse(item, itemTarget, (currentDepth + 1), maxDepth, includeDisplayObjects).children());
                        rootXML.appendChild(nodeXML);
                    };
                };
                i = (i + 1);
            };
            return (rootXML);
        }

        private static function parseArray(_arg_1:*, _arg_2:String, _arg_3:int=1, _arg_4:int=5, _arg_5:Boolean=true):XML
        {
            var _local_7:XML;
            var _local_13:*;
            var _local_6:XML = new XML("<root/>");
            var _local_8 = "";
            var _local_9 = "";
            var _local_10:int;
            var _local_11:Array = [];
            var _local_12:Boolean = true;
            for (_local_13 in _arg_1) {
                if (!(_local_13 is int)){
                    _local_12 = false;
                };
                _local_11.push(_local_13);
            };
            if (_local_12){
                _local_11.sort(Array.NUMERIC);
            } else {
                _local_11.sort(Array.CASEINSENSITIVE);
            };
            _local_10 = 0;
            while (_local_10 < _local_11.length) {
                _local_8 = parseType(MonsterDebuggerDescribeType.get(_arg_1[_local_11[_local_10]]).@name);
                _local_9 = ((_arg_2 + ".") + String(_local_11[_local_10]));
                if ((((((((((((_local_8 == MonsterDebuggerConstants.TYPE_STRING)) || ((_local_8 == MonsterDebuggerConstants.TYPE_BOOLEAN)))) || ((_local_8 == MonsterDebuggerConstants.TYPE_NUMBER)))) || ((_local_8 == MonsterDebuggerConstants.TYPE_INT)))) || ((_local_8 == MonsterDebuggerConstants.TYPE_UINT)))) || ((_local_8 == MonsterDebuggerConstants.TYPE_FUNCTION)))){
                    _local_7 = new XML("<node/>");
                    _local_7.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
                    _local_7.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                    _local_7.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                    _local_7.@label = ((((("[" + _local_11[_local_10]) + "] (") + _local_8) + ") = ") + printValue(_arg_1[_local_11[_local_10]], _local_8, true));
                    _local_7.@name = (("[" + _local_11[_local_10]) + "]");
                    _local_7.@type = _local_8;
                    _local_7.@value = printValue(_arg_1[_local_11[_local_10]], _local_8);
                    _local_7.@target = _local_9;
                    _local_6.appendChild(_local_7);
                } else {
                    _local_7 = new XML("<node/>");
                    _local_7.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
                    _local_7.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                    _local_7.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                    _local_7.@label = (((("[" + _local_11[_local_10]) + "] (") + _local_8) + ")");
                    _local_7.@name = (("[" + _local_11[_local_10]) + "]");
                    _local_7.@type = _local_8;
                    _local_7.@value = "";
                    _local_7.@target = _local_9;
                    if (_arg_1[_local_11[_local_10]] == null){
                        _local_7.@icon = MonsterDebuggerConstants.ICON_WARNING;
                        _local_7.@label = (_local_7.@label + " = null");
                    };
                    _local_7.appendChild(parse(_arg_1[_local_11[_local_10]], _local_9, (_arg_3 + 1), _arg_4, _arg_5).children());
                    _local_6.appendChild(_local_7);
                };
                _local_10++;
            };
            return (_local_6);
        }

        public static function parseFunctions(object:*, target:String=""):XML
        {
            var itemXML:XML;
            var key:String;
            var returnType:String;
            var parameters:XMLList;
            var parametersLength:int;
            var args:Array;
            var argsString:String;
            var methodXML:XML;
            var parameterXML:XML;
            var rootXML:XML = new XML("<root/>");
            var description:XML = MonsterDebuggerDescribeType.get(object);
            var type:String = parseType(description.@name);
            var itemType:String = "";
            var itemName:String = "";
            var itemTarget:String = "";
            var keys:Object = {};
            var methods:XMLList = description..method;
            var methodsArr:Array = [];
            var methodsLength:int = methods.length();
            var optional:Boolean;
            var i:int;
            var n:int;
            itemXML = new XML("<node/>");
            itemXML.@icon = MonsterDebuggerConstants.ICON_DEFAULT;
            itemXML.@label = (("(" + type) + ")");
            itemXML.@target = target;
            i = 0;
            while (i < methodsLength) {
                key = methods[i].@name;
                try {
                    if (!keys.hasOwnProperty(key)){
                        keys[key] = key;
                        methodsArr[methodsArr.length] = {
                            "name":key,
                            "xml":methods[i],
                            "access":MonsterDebuggerConstants.ACCESS_METHOD
                        };
                    };
                } catch(e:Error) {
                };
                i = (i + 1);
            };
            methodsArr.sortOn("name", Array.CASEINSENSITIVE);
            methodsLength = methodsArr.length;
            i = 0;
            while (i < methodsLength) {
                itemType = MonsterDebuggerConstants.TYPE_FUNCTION;
                itemName = methodsArr[i].xml.@name;
                itemTarget = ((target + MonsterDebuggerConstants.DELIMITER) + itemName);
                returnType = parseType(methodsArr[i].xml.@returnType);
                parameters = methodsArr[i].xml..parameter;
                parametersLength = parameters.length();
                args = [];
                argsString = "";
                optional = false;
                n = 0;
                while (n < parametersLength) {
                    if ((((parameters[n].@optional == "true")) && (!(optional)))){
                        optional = true;
                        args[args.length] = "[";
                    };
                    args[args.length] = parseType(parameters[n].@type);
                    n = (n + 1);
                };
                if (optional){
                    args[args.length] = "]";
                };
                argsString = args.join(", ");
                argsString = argsString.replace("[, ", "[");
                argsString = argsString.replace(", ]", "]");
                methodXML = new XML("<node/>");
                methodXML.@icon = MonsterDebuggerConstants.ICON_FUNCTION;
                methodXML.@type = MonsterDebuggerConstants.TYPE_FUNCTION;
                methodXML.@access = MonsterDebuggerConstants.ACCESS_METHOD;
                methodXML.@label = ((((itemName + "(") + argsString) + "):") + returnType);
                methodXML.@name = itemName;
                methodXML.@target = itemTarget;
                methodXML.@args = argsString;
                methodXML.@returnType = returnType;
                n = 0;
                while (n < parametersLength) {
                    parameterXML = new XML("<node/>");
                    parameterXML.@type = parseType(parameters[n].@type);
                    parameterXML.@index = parameters[n].@index;
                    parameterXML.@optional = parameters[n].@optional;
                    methodXML.appendChild(parameterXML);
                    n = (n + 1);
                };
                itemXML.appendChild(methodXML);
                i = (i + 1);
            };
            rootXML.appendChild(itemXML);
            return (rootXML);
        }

        public static function parseXMLList(_arg_1:*, _arg_2:String="", _arg_3:int=1, _arg_4:int=-1):XML
        {
            var _local_5:XML = new XML("<root/>");
            if (((!((_arg_4 == -1))) && ((_arg_3 > _arg_4)))){
                return (_local_5);
            };
            var _local_6:int;
            while (_local_6 < _arg_1.length()) {
                _local_5.appendChild(parseXML(_arg_1[_local_6], (((_arg_2 + ".") + String(_local_6)) + ".children()"), _arg_3, _arg_4).children());
                _local_6++;
            };
            return (_local_5);
        }

        public static function parseXML(_arg_1:*, _arg_2:String="", _arg_3:int=1, _arg_4:int=-1):XML
        {
            var _local_6:XML;
            var _local_7:XML;
            var _local_9:String;
            var _local_5:XML = new XML("<root/>");
            var _local_8:int;
            if (((!((_arg_4 == -1))) && ((_arg_3 > _arg_4)))){
                return (_local_5);
            };
            if (_arg_2.indexOf("@") != -1){
                _local_6 = new XML("<node/>");
                _local_6.@icon = MonsterDebuggerConstants.ICON_XMLATTRIBUTE;
                _local_6.@type = MonsterDebuggerConstants.TYPE_XMLATTRIBUTE;
                _local_6.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                _local_6.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                _local_6.@label = _arg_1;
                _local_6.@name = "";
                _local_6.@value = _arg_1;
                _local_6.@target = _arg_2;
                _local_5.appendChild(_local_6);
            } else {
                if (((("name" in _arg_1)) && ((_arg_1.name() == null)))){
                    _local_6 = new XML("<node/>");
                    _local_6.@icon = MonsterDebuggerConstants.ICON_XMLVALUE;
                    _local_6.@type = MonsterDebuggerConstants.TYPE_XMLVALUE;
                    _local_6.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                    _local_6.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                    _local_6.@label = ((("(" + MonsterDebuggerConstants.TYPE_XMLVALUE) + ") = ") + printValue(_arg_1, MonsterDebuggerConstants.TYPE_XMLVALUE, true));
                    _local_6.@name = "";
                    _local_6.@value = printValue(_arg_1, MonsterDebuggerConstants.TYPE_XMLVALUE);
                    _local_6.@target = _arg_2;
                    _local_5.appendChild(_local_6);
                } else {
                    if (((("hasSimpleContent" in _arg_1)) && (_arg_1.hasSimpleContent()))){
                        _local_6 = new XML("<node/>");
                        _local_6.@icon = MonsterDebuggerConstants.ICON_XMLNODE;
                        _local_6.@type = MonsterDebuggerConstants.TYPE_XMLNODE;
                        _local_6.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                        _local_6.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                        _local_6.@label = (((_arg_1.name() + " (") + MonsterDebuggerConstants.TYPE_XMLNODE) + ")");
                        _local_6.@name = _arg_1.name();
                        _local_6.@value = "";
                        _local_6.@target = _arg_2;
                        if (_arg_1 != ""){
                            _local_7 = new XML("<node/>");
                            _local_7.@icon = MonsterDebuggerConstants.ICON_XMLVALUE;
                            _local_7.@type = MonsterDebuggerConstants.TYPE_XMLVALUE;
                            _local_7.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                            _local_7.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                            _local_7.@label = ((("(" + MonsterDebuggerConstants.TYPE_XMLVALUE) + ") = ") + printValue(_arg_1, MonsterDebuggerConstants.TYPE_XMLVALUE));
                            _local_7.@name = "";
                            _local_7.@value = printValue(_arg_1, MonsterDebuggerConstants.TYPE_XMLVALUE);
                            _local_7.@target = _arg_2;
                            _local_6.appendChild(_local_7);
                        };
                        _local_8 = 0;
                        while (_local_8 < _arg_1.attributes().length()) {
                            _local_7 = new XML("<node/>");
                            _local_7.@icon = MonsterDebuggerConstants.ICON_XMLATTRIBUTE;
                            _local_7.@type = MonsterDebuggerConstants.TYPE_XMLATTRIBUTE;
                            _local_7.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                            _local_7.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                            _local_7.@label = ((((("@" + _arg_1.attributes()[_local_8].name()) + " (") + MonsterDebuggerConstants.TYPE_XMLATTRIBUTE) + ") = ") + _arg_1.attributes()[_local_8]);
                            _local_7.@name = "";
                            _local_7.@value = _arg_1.attributes()[_local_8];
                            _local_7.@target = (((_arg_2 + ".") + "@") + _arg_1.attributes()[_local_8].name());
                            _local_6.appendChild(_local_7);
                            _local_8++;
                        };
                        _local_5.appendChild(_local_6);
                    } else {
                        _local_6 = new XML("<node/>");
                        _local_6.@icon = MonsterDebuggerConstants.ICON_XMLNODE;
                        _local_6.@type = MonsterDebuggerConstants.TYPE_XMLNODE;
                        _local_6.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                        _local_6.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                        _local_6.@label = (((_arg_1.name() + " (") + MonsterDebuggerConstants.TYPE_XMLNODE) + ")");
                        _local_6.@name = _arg_1.name();
                        _local_6.@value = "";
                        _local_6.@target = _arg_2;
                        _local_8 = 0;
                        while (_local_8 < _arg_1.attributes().length()) {
                            _local_7 = new XML("<node/>");
                            _local_7.@icon = MonsterDebuggerConstants.ICON_XMLATTRIBUTE;
                            _local_7.@type = MonsterDebuggerConstants.TYPE_XMLATTRIBUTE;
                            _local_7.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                            _local_7.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                            _local_7.@label = ((((("@" + _arg_1.attributes()[_local_8].name()) + " (") + MonsterDebuggerConstants.TYPE_XMLATTRIBUTE) + ") = ") + _arg_1.attributes()[_local_8]);
                            _local_7.@name = "";
                            _local_7.@value = _arg_1.attributes()[_local_8];
                            _local_7.@target = (((_arg_2 + ".") + "@") + _arg_1.attributes()[_local_8].name());
                            _local_6.appendChild(_local_7);
                            _local_8++;
                        };
                        _local_8 = 0;
                        while (_local_8 < _arg_1.children().length()) {
                            _local_9 = ((((_arg_2 + ".") + "children()") + ".") + _local_8);
                            _local_6.appendChild(parseXML(_arg_1.children()[_local_8], _local_9, (_arg_3 + 1), _arg_4).children());
                            _local_8++;
                        };
                        _local_5.appendChild(_local_6);
                    };
                };
            };
            return (_local_5);
        }

        public static function resume():Boolean
        {
            try {
                System.resume();
                return (true);
            } catch(e:Error) {
            };
            return (false);
        }

        public static function getObjectUnderPoint(_arg_1:DisplayObjectContainer, _arg_2:Point):DisplayObject
        {
            var _local_3:Array;
            var _local_4:DisplayObject;
            var _local_6:DisplayObject;
            if (_arg_1.areInaccessibleObjectsUnderPoint(_arg_2)){
                return (_arg_1);
            };
            _local_3 = _arg_1.getObjectsUnderPoint(_arg_2);
            _local_3.reverse();
            if ((((_local_3 == null)) || ((_local_3.length == 0)))){
                return (_arg_1);
            };
            _local_4 = _local_3[0];
            _local_3.length = 0;
            while (true) {
                _local_3[_local_3.length] = _local_4;
                if (_local_4.parent == null) break;
                _local_4 = _local_4.parent;
            };
            _local_3.reverse();
            var _local_5:int;
            while (_local_5 < _local_3.length) {
                _local_6 = _local_3[_local_5];
                if ((_local_6 is DisplayObjectContainer)){
                    _local_4 = _local_6;
                    if (!DisplayObjectContainer(_local_6).mouseChildren) break;
                } else {
                    break;
                };
                _local_5++;
            };
            return (_local_4);
        }

        public static function getReferenceID(_arg_1:*):String
        {
            if ((_arg_1 in _references)){
                return (_references[_arg_1]);
            };
            var _local_2:String = ("#" + String(_reference));
            _references[_arg_1] = _local_2;
            _reference++;
            return (_local_2);
        }

        public static function printValue(_arg_1:*, _arg_2:String, _arg_3:Boolean=false):String
        {
            if (_arg_2 == MonsterDebuggerConstants.TYPE_BYTEARRAY){
                return ((_arg_1["length"] + " bytes"));
            };
            if (_arg_1 == null){
                return ("null");
            };
            var _local_4:String = String(_arg_1);
            if (((_arg_3) && ((_local_4.length > 140)))){
                _local_4 = (_local_4.substr(0, 140) + "...");
            };
            return (_local_4);
        }

        private static function parseObject(_arg_1:*, _arg_2:String, _arg_3:int=1, _arg_4:int=5, _arg_5:Boolean=true):XML
        {
            var _local_8:XML;
            var _local_14:*;
            var _local_6:XML = new XML("<root/>");
            var _local_7:XML = new XML("<node/>");
            var _local_9 = "";
            var _local_10 = "";
            var _local_11:int;
            var _local_12:Array = [];
            var _local_13:Boolean = true;
            for (_local_14 in _arg_1) {
                if (!(_local_14 is int)){
                    _local_13 = false;
                };
                _local_12.push(_local_14);
            };
            if (_local_13){
                _local_12.sort(Array.NUMERIC);
            } else {
                _local_12.sort(Array.CASEINSENSITIVE);
            };
            _local_11 = 0;
            while (_local_11 < _local_12.length) {
                _local_9 = parseType(MonsterDebuggerDescribeType.get(_arg_1[_local_12[_local_11]]).@name);
                _local_10 = ((_arg_2 + ".") + _local_12[_local_11]);
                if ((((((((((((_local_9 == MonsterDebuggerConstants.TYPE_STRING)) || ((_local_9 == MonsterDebuggerConstants.TYPE_BOOLEAN)))) || ((_local_9 == MonsterDebuggerConstants.TYPE_NUMBER)))) || ((_local_9 == MonsterDebuggerConstants.TYPE_INT)))) || ((_local_9 == MonsterDebuggerConstants.TYPE_UINT)))) || ((_local_9 == MonsterDebuggerConstants.TYPE_FUNCTION)))){
                    _local_8 = new XML("<node/>");
                    _local_8.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
                    _local_8.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                    _local_8.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                    _local_8.@label = ((((_local_12[_local_11] + " (") + _local_9) + ") = ") + printValue(_arg_1[_local_12[_local_11]], _local_9, true));
                    _local_8.@name = _local_12[_local_11];
                    _local_8.@type = _local_9;
                    _local_8.@value = printValue(_arg_1[_local_12[_local_11]], _local_9);
                    _local_8.@target = _local_10;
                    _local_7.appendChild(_local_8);
                } else {
                    _local_8 = new XML("<node/>");
                    _local_8.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
                    _local_8.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                    _local_8.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                    _local_8.@label = (((_local_12[_local_11] + " (") + _local_9) + ")");
                    _local_8.@name = _local_12[_local_11];
                    _local_8.@type = _local_9;
                    _local_8.@value = "";
                    _local_8.@target = _local_10;
                    if (_arg_1[_local_12[_local_11]] == null){
                        _local_8.@icon = MonsterDebuggerConstants.ICON_WARNING;
                        _local_8.@label = (_local_8.@label + " = null");
                    };
                    _local_8.appendChild(parse(_arg_1[_local_12[_local_11]], _local_10, (_arg_3 + 1), _arg_4, _arg_5).children());
                    _local_7.appendChild(_local_8);
                };
                _local_11++;
            };
            _local_6.appendChild(_local_7.children());
            return (_local_6);
        }

        public static function parse(_arg_1:*, _arg_2:String="", _arg_3:int=1, _arg_4:int=5, _arg_5:Boolean=true):XML
        {
            var _local_14:XML;
            var _local_6:XML = new XML("<root/>");
            var _local_7:XML = new XML("<node/>");
            var _local_8:XML = new XML();
            var _local_9 = "";
            var _local_10 = "";
            var _local_11:Boolean;
            var _local_12:String;
            var _local_13:String = MonsterDebuggerConstants.ICON_ROOT;
            if (((!((_arg_4 == -1))) && ((_arg_3 > _arg_4)))){
                return (_local_6);
            };
            if (_arg_1 == null){
                _local_9 = "null";
                _local_12 = "null";
                _local_13 = MonsterDebuggerConstants.ICON_WARNING;
            } else {
                _local_8 = MonsterDebuggerDescribeType.get(_arg_1);
                _local_9 = parseType(_local_8.@name);
                _local_10 = parseType(_local_8.@base);
                _local_11 = Boolean(_local_8.@isDynamic);
                if ((_arg_1 is Class)){
                    _local_12 = ("Class = " + _local_9);
                    _local_9 = "Class";
                    _local_7.appendChild(parseClass(_arg_1, _arg_2, _local_8, _arg_3, _arg_4, _arg_5).children());
                } else {
                    if (_local_9 == MonsterDebuggerConstants.TYPE_XML){
                        _local_7.appendChild(parseXML(_arg_1, (_arg_2 + ".children()"), _arg_3, _arg_4).children());
                    } else {
                        if (_local_9 == MonsterDebuggerConstants.TYPE_XMLLIST){
                            _local_12 = (((_local_9 + " [") + String(_arg_1.length())) + "]");
                            _local_7.appendChild(parseXMLList(_arg_1, _arg_2, _arg_3, _arg_4).children());
                        } else {
                            if ((((_local_9 == MonsterDebuggerConstants.TYPE_ARRAY)) || ((_local_9.indexOf(MonsterDebuggerConstants.TYPE_VECTOR) == 0)))){
                                _local_12 = (((_local_9 + " [") + String(_arg_1["length"])) + "]");
                                _local_7.appendChild(parseArray(_arg_1, _arg_2, _arg_3, _arg_4).children());
                            } else {
                                if ((((((((((_local_9 == MonsterDebuggerConstants.TYPE_STRING)) || ((_local_9 == MonsterDebuggerConstants.TYPE_BOOLEAN)))) || ((_local_9 == MonsterDebuggerConstants.TYPE_NUMBER)))) || ((_local_9 == MonsterDebuggerConstants.TYPE_INT)))) || ((_local_9 == MonsterDebuggerConstants.TYPE_UINT)))){
                                    _local_7.appendChild(parseBasics(_arg_1, _arg_2, _local_9).children());
                                } else {
                                    if (_local_9 == MonsterDebuggerConstants.TYPE_OBJECT){
                                        _local_7.appendChild(parseObject(_arg_1, _arg_2, _arg_3, _arg_4, _arg_5).children());
                                    } else {
                                        _local_7.appendChild(parseClass(_arg_1, _arg_2, _local_8, _arg_3, _arg_4, _arg_5).children());
                                    };
                                };
                            };
                        };
                    };
                };
            };
            if (_arg_3 == 1){
                _local_14 = new XML("<node/>");
                _local_14.@icon = _local_13;
                _local_14.@label = _local_9;
                _local_14.@type = _local_9;
                _local_14.@target = _arg_2;
                if (_local_12 != null){
                    _local_14.@label = _local_12;
                };
                _local_14.appendChild(_local_7.children());
                _local_6.appendChild(_local_14);
            } else {
                _local_6.appendChild(_local_7.children());
            };
            return (_local_6);
        }

        public static function parseType(_arg_1:String):String
        {
            var _local_2:String;
            var _local_3:String;
            if (_arg_1.indexOf("::") != -1){
                _arg_1 = _arg_1.substring((_arg_1.indexOf("::") + 2), _arg_1.length);
            };
            if (_arg_1.indexOf("::") != -1){
                _local_2 = _arg_1.substring(0, (_arg_1.indexOf("<") + 1));
                _local_3 = _arg_1.substring((_arg_1.indexOf("::") + 2), _arg_1.length);
                _arg_1 = (_local_2 + _local_3);
            };
            _arg_1 = _arg_1.replace("()", "");
            return (_arg_1.replace(MonsterDebuggerConstants.TYPE_METHOD, MonsterDebuggerConstants.TYPE_FUNCTION));
        }

        public static function getReference(_arg_1:String)
        {
            var _local_2:*;
            var _local_3:String;
            if (_arg_1.charAt(0) != "#"){
                return (null);
            };
            for (_local_2 in _references) {
                _local_3 = _references[_local_2];
                if (_local_3 == _arg_1){
                    return (_local_2);
                };
            };
            return (null);
        }

        public static function pause():Boolean
        {
            try {
                System.pause();
                return (true);
            } catch(e:Error) {
            };
            return (false);
        }

        public static function getMemory():uint
        {
            return (System.totalMemory);
        }

        public static function getObject(base:*, target:String="", parent:int=0)
        {
            var index:Number;
            if ((((target == null)) || ((target == "")))){
                return (base);
            };
            if (target.charAt(0) == "#"){
                return (getReference(target));
            };
            var object:* = base;
            var splitted:Array = target.split(MonsterDebuggerConstants.DELIMITER);
            var i:int;
            while (i < (splitted.length - parent)) {
                if (splitted[i] != ""){
                    try {
                        if (splitted[i] == "children()"){
                            object = object.children();
                        } else {
                            if ((((object is DisplayObjectContainer)) && ((splitted[i].indexOf("getChildAt(") == 0)))){
                                index = splitted[i].substring(11, splitted[i].indexOf(")", 11));
                                object = DisplayObjectContainer(object).getChildAt(index);
                            } else {
                                object = object[splitted[i]];
                            };
                        };
                    } catch(e:Error) {
                        break;
                    };
                };
                i = (i + 1);
            };
            return (object);
        }

        public static function stackTrace():XML
        {
            var childXML:XML;
            var stack:String;
            var lines:Array;
            var i:int;
            var s:String;
            var bracketIndex:int;
            var methodIndex:int;
            var classname:String;
            var method:String;
            var file:String;
            var line:String;
            var functionXML:XML;
            var rootXML:XML = new XML("<root/>");
            childXML = new XML("<node/>");
            try {
                throw (new Error());
            } catch(e:Error) {
                stack = e.getStackTrace();
                if ((((stack == null)) || ((stack == "")))){
                    return (new XML("<root><error>Stack unavailable</error></root>"));
                };
                stack = stack.split("\t").join("");
                lines = stack.split("\n");
                if (lines.length <= 4){
                    return (new XML("<root><error>Stack to short</error></root>"));
                };
                lines.shift();
                lines.shift();
                lines.shift();
                lines.shift();
                i = 0;
                while (i < lines.length) {
                    s = lines[i];
                    s = s.substring(3, s.length);
                    bracketIndex = s.indexOf("[");
                    methodIndex = s.indexOf("/");
                    if (bracketIndex == -1){
                        bracketIndex = s.length;
                    };
                    if (methodIndex == -1){
                        methodIndex = bracketIndex;
                    };
                    classname = MonsterDebuggerUtils.parseType(s.substring(0, methodIndex));
                    method = "";
                    file = "";
                    line = "";
                    if (((!((methodIndex == s.length))) && (!((methodIndex == bracketIndex))))){
                        method = s.substring((methodIndex + 1), bracketIndex);
                    };
                    if (bracketIndex != s.length){
                        file = s.substring((bracketIndex + 1), s.lastIndexOf(":"));
                        line = s.substring((s.lastIndexOf(":") + 1), (s.length - 1));
                    };
                    functionXML = new XML("<node/>");
                    functionXML.@classname = classname;
                    functionXML.@method = method;
                    functionXML.@file = file;
                    functionXML.@line = line;
                    childXML.appendChild(functionXML);
                    i = (i + 1);
                };
            };
            rootXML.appendChild(childXML.children());
            return (rootXML);
        }

        public static function isDisplayObject(_arg_1:*):Boolean
        {
            return ((((_arg_1 is DisplayObject)) || ((_arg_1 is DisplayObjectContainer))));
        }

        private static function parseBasics(_arg_1:*, _arg_2:String, _arg_3:String):XML
        {
            var _local_4:XML = new XML("<root/>");
            var _local_5:XML = new XML("<node/>");
            _local_5.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
            _local_5.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
            _local_5.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
            _local_5.@label = ((_arg_3 + " = ") + printValue(_arg_1, _arg_3, true));
            _local_5.@name = "";
            _local_5.@type = _arg_3;
            _local_5.@value = printValue(_arg_1, _arg_3);
            _local_5.@target = _arg_2;
            _local_4.appendChild(_local_5);
            return (_local_4);
        }


    }
}//package com.demonsters.debugger

