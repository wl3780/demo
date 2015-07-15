package com.engine.core.view.items
{
	import com.engine.core.view.BaseSprite;

	public class Item extends BaseSprite implements IItem 
	{

		private var _layer:String;
		private var _type:String;
		private var _isSceneItem:Boolean = true;
		private var _char_id:String;
		
		protected var _isAutoDispose:Boolean = true;

		public function Item()
		{
			super();
			this.mouseChildren = this.mouseEnabled = false;
			this.tabChildren = this.tabEnabled = false;
		}

		public function set isAutoDispose(val:Boolean):void
		{
			_isAutoDispose = val;
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
