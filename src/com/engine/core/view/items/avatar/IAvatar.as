// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.items.avatar.IAvatar

package com.engine.core.view.items.avatar
{
    import com.engine.core.view.items.IItem;
    import com.engine.core.tile.square.SquarePt;

    public interface IAvatar extends IItem 
    {

        function get isDisposed():Boolean;
        function loadAvatarPart(_arg_1:String, _arg_2:AvatarRestrict=null):String;
        function get stageIntersects():Boolean;
        function get pt():SquarePt;
        function get x():Number;
        function get y():Number;
        function hitIcon():Boolean;
        function get isDeath():Boolean;
        function get stop():Boolean;
        function set stop(_arg_1:Boolean):void;
        function get avatarParts():AvatartParts;

    }
}//package com.engine.core.view.items.avatar

