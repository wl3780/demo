// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.items.NoderItem

package com.engine.core.view.items
{
    import com.engine.core.view.quadTree.NoderSprite;
    import com.engine.core.Core;

    public class NoderItem extends NoderSprite implements IItem 
    {

        private var _layer:String;
        private var _type:String;
        private var _isSceneItem:Boolean = true;
        private var _char_id:String;

        public function NoderItem()
        {
            this.registerNodeTree(Core.SCENE_ITEM_NODER);
        }

        public function get char_id():String
        {
            return (this._char_id);
        }

        public function set char_id(_arg_1:String):void
        {
            this._char_id = _arg_1;
        }

        public function get layer():String
        {
            return (this._layer);
        }

        public function set layer(_arg_1:String):void
        {
            this._layer = _arg_1;
        }

        public function get isSceneItem():Boolean
        {
            return (this._isSceneItem);
        }

        public function set isSceneItem(_arg_1:Boolean):void
        {
            this._isSceneItem = _arg_1;
        }

        public function get type():String
        {
            return (this._type);
        }

        public function set type(_arg_1:String):void
        {
            this._type = _arg_1;
        }


    }
}//package com.engine.core.view.items

