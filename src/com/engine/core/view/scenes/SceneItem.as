// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.scenes.SceneItem

package com.engine.core.view.scenes
{
    import com.engine.core.view.items.NoderItem;
    import com.engine.core.view.items.avatar.IAvatar;
    import com.engine.core.tile.square.SquarePt;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import com.engine.core.view.items.avatar.ItemAvatar;
    import com.engine.core.view.items.avatar.AvatartParts;
    import com.engine.utils.gome.SquareUitls;
    import com.engine.core.tile.TileGroup;
    import com.engine.core.tile.Cell;
    import flash.filters.GlowFilter;
    import flash.display.BitmapData;
    import com.engine.core.view.items.avatar.AvatarRestrict;

    public class SceneItem extends NoderItem implements IAvatar 
    {

        private var _pt:SquarePt;
        private var _point:Point;
        private var nameText:TextField;
        private var shape:Bitmap;
        private var _name:String;
        private var view:Bitmap;
        private var _icon:DisplayObject;
        private var _effect:ItemAvatar;
        private var _isDisposed:Boolean;
        private var _type:String;
        private var _stop:Boolean = false;
        private var _isDeath:Boolean = false;

        public function SceneItem()
        {
            this.view = new Bitmap();
            this.addChild(this.view);
            this._point = new Point();
        }

        public function get avatarParts():AvatartParts
        {
            return (null);
        }

        public function get isDeath():Boolean
        {
            return (this._isDeath);
        }

        public function set isDeath(_arg_1:Boolean):void
        {
            this._isDeath = _arg_1;
        }

        public function set stop(_arg_1:Boolean):void
        {
            this._stop = _arg_1;
        }

        public function get stop():Boolean
        {
            return (this._stop);
        }

        public function hitIcon():Boolean
        {
            return (false);
        }

        override public function set x(_arg_1:Number):void
        {
            super.x = _arg_1;
            if (this._point){
                this._point.x = _arg_1;
                this._pt = SquareUitls.pixelsToSquare(this._point);
                this.setAlpha();
            };
        }

        override public function set y(_arg_1:Number):void
        {
            super.y = _arg_1;
            if (this._point){
                this._point.y = _arg_1;
                this._pt = SquareUitls.pixelsToSquare(this._point);
                this.setAlpha();
            };
        }

        public function setAlpha():void
        {
            var _local_1:Cell = TileGroup.getInstance().take(this.pt.key);
            if (_local_1){
                if (_local_1.isAlpha){
                    if (this.alpha != 0.6){
                        this.alpha = 0.6;
                    };
                } else {
                    if (this.alpha != 1){
                        this.alpha = 1;
                    };
                };
            };
        }

        public function nameColor(_arg_1:uint):void
        {
            if (this.nameText == null){
                this.nameText = new TextField();
                this.nameText.textColor = 0xFFFFFF;
                this.nameText.filters = [new GlowFilter(0, 1, 4, 4, 3)];
                this.nameText.mouseEnabled = false;
                this.nameText.mouseWheelEnabled = false;
                this.nameText.selectable = false;
                this.nameText.cacheAsBitmap = true;
            };
            if (this.nameText.textColor != _arg_1){
                this.nameText.textColor = _arg_1;
            };
        }

        override public function set name(_arg_1:String):void
        {
            if (this.nameText == null){
                this.nameText = new TextField();
                this.nameText.textColor = 0xFFFFFF;
                this.nameText.filters = [new GlowFilter(0, 1, 4, 4, 3)];
                this.nameText.mouseEnabled = false;
                this.nameText.mouseWheelEnabled = false;
                this.nameText.selectable = false;
                this.nameText.cacheAsBitmap = true;
            };
            if (this._name != _arg_1){
                this._name = _arg_1;
                if (this.contains(this.nameText) == false){
                    if (this.contains(this.nameText) == false){
                        this.addChild(this.nameText);
                    };
                };
                this.nameText.htmlText = _arg_1;
                this.nameText.width = (this.nameText.textWidth + 10);
                this.nameText.y = -45;
                this.nameText.x = (-(this.nameText.textWidth) / 2);
            };
        }

        override public function get name():String
        {
            return (this._name);
        }

        public function set nikeNameVisible(_arg_1:Boolean):void
        {
            if (_arg_1){
                if (this.nameText == null){
                    this.nameText = new TextField();
                    this.nameText.textColor = 0xFFFFFF;
                    this.nameText.filters = [new GlowFilter(0, 1, 4, 4, 3)];
                    this.nameText.mouseEnabled = false;
                    this.nameText.mouseWheelEnabled = false;
                    this.nameText.selectable = false;
                    this.nameText.cacheAsBitmap = true;
                };
                if (!this.contains(this.nameText)){
                    this.addChild(this.nameText);
                };
            } else {
                if (this.contains(this.nameText)){
                    this.removeChild(this.nameText);
                };
            };
        }

        public function onRender():void
        {
            this.nameText.x;
        }

        public function set pt(_arg_1:SquarePt):void
        {
            this._pt = _arg_1;
            this._point = SquareUitls.squareTopixels(_arg_1);
            super.x = this._point.x;
            super.y = this._point.y;
            if (this._point){
                this._pt = SquareUitls.pixelsToSquare(this._point);
                this.setAlpha();
            };
        }

        public function get pt():SquarePt
        {
            return (this._pt);
        }

        public function set point(_arg_1:Point):void
        {
            this._point = _arg_1;
            this._pt = SquareUitls.pixelsToSquare(_arg_1);
            super.x = _arg_1.x;
            super.y = _arg_1.y;
            if (this._point){
                this._pt = SquareUitls.pixelsToSquare(this._point);
                this.setAlpha();
            };
        }

        public function get point():Point
        {
            return (this._point);
        }

        public function set icon(_arg_1:DisplayObject):void
        {
            this._icon = _arg_1;
            this.addChild(_arg_1);
        }

        public function set bitmapData(_arg_1:BitmapData):void
        {
            this.view.bitmapData = _arg_1;
            this.view.y = (this.view.y - (_arg_1.height / 2));
            this.view.x = (-(_arg_1.width) / 2);
            this.nameText.x = (-(this.nameText.textWidth) / 2);
            this.nameText.y = -45;
        }

        public function liangdu(_arg_1:Number):Array
        {
            return ([1, 0, 0, 0, _arg_1, 0, 1, 0, 0, _arg_1, 0, 0, 1, 0, _arg_1, 0, 0, 0, 1, 0]);
        }

        public function get isDisposed():Boolean
        {
            return (this._isDisposed);
        }

        public function loadAvatarPart(_arg_1:String, _arg_2:AvatarRestrict=null):String
        {
            if (this._effect){
                this._effect.dispose();
                this._effect = null;
                if (this.contains(this._effect)){
                    this.removeChild(this._effect);
                };
            };
            this._effect = new ItemAvatar();
            this._effect.loadAvatarPart(_arg_1);
            this.addChild(this._effect);
            return (null);
        }

        public function get stageIntersects():Boolean
        {
            return (true);
        }

        override public function dispose():void
        {
            if (this._effect){
                this._effect.dispose();
                if (this.contains(this._effect)){
                    this.removeChild(this._effect);
                };
                this._effect = null;
            };
            if (this._icon){
                if (this._icon.parent){
                    this._icon.parent.removeChild(this._icon);
                };
                this._icon = null;
            };
            if (this.view){
                (this.view.bitmapData == null);
                if (this.contains(this.view)){
                    this.removeChild(this.view);
                };
            };
            this.view = null;
            if (this.nameText){
                this.nameText.text = "";
                this.nameText.filters = null;
                this.nameText = null;
            };
            if (this.shape){
                this.shape.bitmapData = null;
                if (this.shape.parent){
                    this.removeChild(this.shape);
                };
            };
            this.shape = null;
            if (this._pt){
                this._pt = null;
            };
            if (this._point){
                this._point = null;
            };
            var _local_1:int = (this.numChildren - 1);
            while (_local_1) {
                this.removeChildAt(_local_1);
                _local_1--;
            };
            super.dispose();
        }


    }
}//package com.engine.core.view.scenes

