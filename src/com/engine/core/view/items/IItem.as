package com.engine.core.view.items
{
	import com.engine.core.view.IBaseSprite;

	public interface IItem extends IBaseSprite 
	{

		function set layer(_arg_1:String):void;
		function get layer():String;
		function get type():String;
		function set type(_arg_1:String):void;
		function set isSceneItem(_arg_1:Boolean):void;
		function get char_id():String;
		function set char_id(_arg_1:String):void;

	}
}
