// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.quadTree.INoder

package com.engine.core.view.quadTree
{
    import flash.display.DisplayObject;
    import flash.geom.Rectangle;

    public interface INoder 
    {

        function set x(_arg_1:Number):void;
        function get x():Number;
        function set y(_arg_1:Number):void;
        function get y():Number;
        function get node():Node;
        function activate():void;
        function unactivate():void;
        function get isActivate():Boolean;
        function getBounds(_arg_1:DisplayObject):Rectangle;
        function get id():String;
        function get tid():String;
        function get visible():Boolean;

    }
}//package com.engine.core.view.quadTree

