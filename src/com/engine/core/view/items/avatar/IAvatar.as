package com.engine.core.view.items.avatar
{
	import com.engine.core.tile.square.SquarePt;
	import com.engine.core.view.items.IItem;

	public interface IAvatar extends IItem 
	{

		function get x():Number;
		function get y():Number;
		
		function get stop():Boolean;
		function set stop(val:Boolean):void;
		
		function get isDisposed():Boolean;
		function get stageIntersects():Boolean;
		function get isDeath():Boolean;
		function get pt():SquarePt;
		function get avatarParts():AvatartParts;
		
		function hitIcon():Boolean;
		function loadAvatarPart(avatarType:String, avatarNum:String):String;

	}
}
