package com.engine.interfaces.display
{
    public interface IScene
	{
		function addItem(value:ISceneItem, layer:String):void;
		
		function removeItem(value:ISceneItem):void;
		
		function takeItem(char_id:String):ISceneItem;
		
		function sceneMoveTo(px:Number, py:Number):void;
		
		function changeScene(scene_id:int):void;
		
		function dispose():void;
    }
}
