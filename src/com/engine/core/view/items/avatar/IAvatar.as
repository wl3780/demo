package com.engine.core.view.items.avatar
{
	import com.engine.core.tile.square.SquarePt;
	import com.engine.core.view.items.IItem;

	public interface IAvatar extends IItem 
	{

		function get x():Number;
		function get y():Number;
		function get stop():Boolean;
		function set stop(_arg_1:Boolean):void;
		function get isDisposed():Boolean;
		function get stageIntersects():Boolean;
		function get isDeath():Boolean;
		function get pt():SquarePt;
		function get avatarParts():AvatartParts;
		function hitIcon():Boolean;
		function loadAvatarPart(_arg_1:String, _arg_2:AvatarRestrict=null):String;

	}
}
