package com.engine.core.view.items
{
	import com.engine.core.view.IBaseSprite;

	public interface IItem extends IBaseSprite 
	{

		function set layer(val:String):void;
		function get layer():String;
		
		function get type():String;
		function set type(val:String):void;
		
		function get char_id():String;
		function set char_id(val:String):void;
		
		function set isSceneItem(val:Boolean):void;

	}
}
