package com.engine.core.view.items
{
	import com.engine.core.Engine;
	import com.engine.core.view.quadTree.NoderSprite;

	public class NoderItem extends NoderSprite implements IItem 
	{

		private var _type:String;
		private var _char_id:String;
		private var _layer:String;
		private var _isSceneItem:Boolean = true;

		public function NoderItem()
		{
			super();
			this.registerNodeTree(Engine.SCENE_ITEM_NODER);
		}

		public function get char_id():String
		{
			return _char_id;
		}
		public function set char_id(val:String):void
		{
			_char_id = val;
		}

		public function get layer():String
		{
			return _layer;
		}
		public function set layer(val:String):void
		{
			_layer = val;
		}

		public function get isSceneItem():Boolean
		{
			return _isSceneItem;
		}
		public function set isSceneItem(val:Boolean):void
		{
			_isSceneItem = val;
		}

		public function get type():String
		{
			return _type;
		}
		public function set type(val:String):void
		{
			_type = val;
		}

	}
}
