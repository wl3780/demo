// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.items.avatar.HeadShape

package com.engine.core.view.items.avatar
{
    import com.engine.core.view.quadTree.NoderSprite;
    import flash.text.TextField;
    import com.engine.core.view.items.BloodBar;
    import flash.geom.Point;
    import flash.display.DisplayObject;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import com.engine.core.Core;
    import flash.display.Graphics;
    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.net.URLRequest;
    import flash.filters.GlowFilter;
    import flash.events.Event;
    import flash.geom.Rectangle;
    import com.engine.core.view.scenes.Scene;
    import com.engine.core.RecoverUtils;
    import flash.geom.Matrix;

    public class HeadShape extends NoderSprite 
    {

        private static var renderQuene:Array = [];
        private static var _professionNameText:TextField;
        private static var _nameText:TextField;
        private static var _bloodBar:BloodBar = new BloodBar();
        private static var recovery_point:Point = new Point();

        public var moveFunc:Function;
        private var _headIconLeft:DisplayObject;
        private var _headIconRight:DisplayObject;
        private var _flag:DisplayObject;
        private var _headIconCenter:DisplayObject;
        private var _bmd:BitmapData;
        private var _headBitmapData:BitmapData;
        private var _curr:Number;
        private var _max:Number;
        private var _name:String;
        private var _professionName:String;
        private var _nameColor:uint = 0xFFFFFF;
        private var _professionNameColor:uint = 0xFF00;
        private var _nameVisible:Boolean = true;
        private var _professionNameVisible:Boolean = true;
        private var _bloodBarVisible:Boolean = false;
        private var _shape:Sprite;
        private var _tiles:Array;
        private var _headIconSize:int = 30;
        private var _clickEnabled:Boolean;
        public var owner:Avatar;

        public function HeadShape()
        {
            this._shape = new Sprite();
            this._shape.mouseChildren = (this._shape.mouseEnabled = false);
            this.addChild(this._shape);
            this.cacheAsBitmap = true;
            this._bloodBarVisible = false;
            this.mouseChildren = (this.mouseEnabled = (this.tabChildren = (this.tabEnabled = false)));
            unactivate();
        }

        public static function setBloodBitmapData(_arg_1:BitmapData):void
        {
            _bloodBar.bitmapData = _arg_1;
        }


        public function get clickEnabled():Boolean
        {
            return (this._clickEnabled);
        }

        public function set clickEnabled(_arg_1:Boolean):void
        {
            this._clickEnabled = _arg_1;
            if (_arg_1){
                this.registerNodeTree(Core.SCENE_ITEM_NODER);
                activate();
            } else {
                unactivate();
            };
        }

        override public function get graphics():Graphics
        {
            return (this._shape.graphics);
        }

        public function setBoold(_arg_1:Number, _arg_2:Number):void
        {
            this._curr = _arg_1;
            this._max = _arg_2;
            this.draw();
        }

        public function showTitles(_arg_1:Array):void
        {
            var _local_2:int;
            var _local_3:Object;
            var _local_4:int;
            var _local_5:Object;
            if (this._tiles){
                _local_2 = 0;
                _local_2 = 0;
                while (_local_2 < this._tiles.length) {
                    _local_3 = this._tiles[_local_2];
                    if ((_local_3 as ItemAvatar)){
                        _local_3.dispose();
                    } else {
                        if ((_local_3 as Bitmap)){
                            Bitmap(_local_3).bitmapData = null;
                            if (_local_3.parent){
                                _local_3.parent.removeChild(_local_3);
                            };
                        } else {
                            if ((_local_3 as Loader)){
                                Loader(_local_3).unloadAndStop();
                                if (_local_3.parent){
                                    _local_3.parent.removeChild(_local_3);
                                };
                            } else {
                                if ((_local_3 as DisplayObject)){
                                    if (_local_3.parent){
                                        _local_3.parent.removeChild(_local_3);
                                    };
                                };
                            };
                        };
                    };
                    _local_2++;
                };
            };
            this._tiles = [];
            if (_arg_1){
                _local_4 = 0;
                _local_2 = 0;
                while (_local_2 < _arg_1.length) {
                    _local_5 = _arg_1[_local_2];
                    if (_local_5){
                        if ((_local_5 as DisplayObject)){
                            _local_3 = _local_5;
                            _local_3.x = (-(_local_3.width) / 2);
                        } else {
                            if ((_local_5 as BitmapData)){
                                _local_3 = new Bitmap();
                                Bitmap(_local_3).bitmapData = (_local_5 as BitmapData);
                                _local_3.x = (-(_local_3.width) / 2);
                            } else {
                                if ((_local_5 as String)){
                                    if (String(_local_5).indexOf("eid_") != -1){
                                        _local_3 = new ItemAvatar();
                                        _local_3.loadAvatarPart(_arg_1[_local_2]);
                                    } else {
                                        _local_3 = new Loader();
                                        _local_3.load(new URLRequest((_local_5 as String)));
                                        _local_3.x = (-(_local_3.width) / 2);
                                    };
                                };
                            };
                        };
                        this._tiles.push(_local_3);
                        _local_4++;
                    };
                    _local_2++;
                };
            };
            this.reander();
        }

        override public function set name(_arg_1:String):void
        {
            if (_nameText == null){
                _nameText = new TextField();
                _nameText.filters = [new GlowFilter(0, 1, 2, 2)];
                _nameText.selectable = false;
            };
            this._name = _arg_1;
            this.draw();
        }

        public function get professionNameColor():uint
        {
            return (this._professionNameColor);
        }

        public function set professionNameColor(_arg_1:uint):void
        {
            this._professionNameColor = _arg_1;
            this._professionNameVisible = true;
            this.draw();
        }

        public function get nameColor():uint
        {
            return (this._nameColor);
        }

        public function set nameColor(_arg_1:uint):void
        {
            this._nameColor = _arg_1;
            this.draw();
        }

        public function get bloodBarVisible():Boolean
        {
            return (this._bloodBarVisible);
        }

        public function set bloodBarVisible(_arg_1:Boolean):void
        {
            if (this._bloodBarVisible != _arg_1){
                this._bloodBarVisible = _arg_1;
                this.draw();
            };
        }

        public function get professionNameVisible():Boolean
        {
            return (this._professionNameVisible);
        }

        public function set professionNameVisible(_arg_1:Boolean):void
        {
            if (this._professionNameVisible != _arg_1){
                this._professionNameVisible = _arg_1;
                this.draw();
            };
        }

        public function get nameVisible():Boolean
        {
            return (this._nameVisible);
        }

        public function set nameVisible(_arg_1:Boolean):void
        {
            if (this._nameVisible != _arg_1){
                this._nameVisible = _arg_1;
                this.draw();
            };
        }

        public function disposeFlag():void
        {
            if (this._flag){
                if ((this._flag is ItemAvatar)){
                    ItemAvatar(this._flag).dispose();
                } else {
                    if (this._flag.parent){
                        this._flag.parent.removeChild(this._flag);
                    };
                    if ((this._flag as Loader)){
                        Loader(this._flag).unloadAndStop();
                    };
                    if ((this._flag as Bitmap)){
                        Object(this._flag).bitmapData = null;
                    };
                };
                this._flag = null;
            };
        }

        public function disposeHeadIcon(_arg_1:String="all"):void
        {
            if (((this._headIconLeft) && ((((_arg_1 == "all")) || ((_arg_1 == "left")))))){
                if ((this._headIconLeft is ItemAvatar)){
                    ItemAvatar(this._headIconLeft).dispose();
                } else {
                    if (this._headIconLeft.parent){
                        this._headIconLeft.parent.removeChild(this._headIconLeft);
                    };
                    if ((this._headIconLeft as Loader)){
                        Loader(this._headIconLeft).unloadAndStop();
                    };
                    if ((this._headIconLeft as Bitmap)){
                        Bitmap(this._headIconLeft).bitmapData = null;
                    };
                };
                this._headIconLeft = null;
            };
            if (((this._headIconRight) && ((((_arg_1 == "all")) || ((_arg_1 == "right")))))){
                if ((this._headIconRight is ItemAvatar)){
                    ItemAvatar(this._headIconRight).dispose();
                } else {
                    if (this._headIconRight.parent){
                        this._headIconRight.parent.removeChild(this._headIconRight);
                    };
                    if ((this._headIconRight as Loader)){
                        Loader(this._headIconRight).unloadAndStop();
                    };
                    if ((this._headIconRight as Bitmap)){
                        Bitmap(this._headIconRight).bitmapData = null;
                    };
                };
                this._headIconRight = null;
            };
            if (((this._headIconCenter) && ((((_arg_1 == "all")) || ((_arg_1 == "center")))))){
                if ((this._headIconCenter is ItemAvatar)){
                    ItemAvatar(this._headIconCenter).dispose();
                } else {
                    if (this._headIconCenter.parent){
                        this._headIconCenter.parent.removeChild(this._headIconCenter);
                    };
                    if ((this._headIconCenter as Loader)){
                        Loader(this._headIconCenter).unloadAndStop();
                    };
                    if ((this._headIconCenter as Bitmap)){
                        Bitmap(this._headIconCenter).bitmapData = null;
                    };
                };
                this._headIconCenter = null;
            };
        }

        public function showFlag(_arg_1:DisplayObject):void
        {
            if (((this._flag) && (this._flag.parent))){
                this._flag.parent.removeChild(this._flag);
            };
            this._flag = _arg_1;
            this.draw();
        }

        public function setHeadIcon(_arg_1:Object, _arg_2:String="center"):void
        {
            var _local_3:DisplayObject;
            if ((((_arg_1 == "")) || (!(_arg_1)))){
                this.disposeHeadIcon("");
            };
            this.disposeHeadIcon(_arg_2);
            if (_arg_1){
                if ((_arg_1 as String)){
                    _local_3 = new ItemAvatar();
                    ItemAvatar(_local_3).loadAvatarPart((_arg_1 as String));
                } else {
                    if ((_arg_1 as BitmapData)){
                        _local_3 = new Bitmap();
                        Bitmap(_local_3).bitmapData = (_arg_1 as BitmapData);
                    } else {
                        if ((_arg_1 as DisplayObject)){
                            _local_3 = (_arg_1 as DisplayObject);
                        };
                    };
                };
                if (_arg_2 == "left"){
                    this._headIconLeft = _local_3;
                };
                if (_arg_2 == "right"){
                    this._headIconRight = _local_3;
                };
                if (_arg_2 == "center"){
                    this._headIconCenter = _local_3;
                };
                if (_local_3){
                    this.addChild(_local_3);
                };
                this.draw();
            };
        }

        public function showHeadBtmapData(_arg_1:BitmapData):void
        {
            this._headBitmapData = _arg_1;
            this.draw();
        }

        public function draw():void
        {
            if (this.hasEventListener(Event.ENTER_FRAME) == false){
                this.addEventListener(Event.ENTER_FRAME, this.enterFrameFunc);
            };
        }

        private function enterFrameFunc(_arg_1:Event):void
        {
            this.removeEventListener(Event.ENTER_FRAME, this.enterFrameFunc);
            this.reander();
        }

        public function stageIntersects():void
        {
            if (((((!(Core.CORE_RECT)) || ((this.visible == false)))) || (!(this.owner)))){
                if (this.parent){
                    this.parent.removeChild(this);
                };
                return;
            };
            var _local_1:Rectangle = this.getBounds(this);
            var _local_2:Point = recovery_point;
            _local_2.x = _local_1.x;
            _local_2.y = _local_1.y;
            _local_2 = this.localToGlobal(_local_2);
            _local_1.x = _local_2.x;
            _local_1.y = _local_2.y;
            if (((((((!(_local_1.isEmpty())) && (Avatar.stageRect))) && (!(Avatar.stageRect.intersects(_local_1))))) || (!(this.owner.parent)))){
                if (this.parent){
                    this.parent.removeChild(this);
                };
            } else {
                if (!this.parent){
                    if (Scene.scene.getSceneFlyMode()){
                        Scene.scene.$flyLayer.addChild(this);
                    } else {
                        Scene.scene.$topLayer.addChild(this);
                    };
                };
            };
        }

        public function reander():void
        {
            var _local_4:int;
            var _local_5:DisplayObject;
            var _local_6:int;
            var _local_7:DisplayObject;
            this.cacheAsBitmap = false;
            var _local_1:Sprite = this._shape;
            if (_nameText){
                _nameText.htmlText = "";
            };
            if (_professionNameText){
                _professionNameText.htmlText = "";
            };
            if (this._bmd){
                this._bmd.dispose();
            };
            this.graphics.clear();
            while (_local_1.numChildren) {
                _local_1.removeChildAt(0);
            };
            if (((this._flag) && (this._flag.parent))){
                this._flag.parent.removeChild(this._flag);
            };
            if (((this._headIconLeft) && (this._headIconLeft.parent))){
                this._headIconLeft.parent.removeChild(this._headIconLeft);
            };
            if (((this._headIconRight) && (this._headIconRight.parent))){
                this._headIconRight.parent.removeChild(this._headIconRight);
            };
            if (((this._headIconCenter) && (this._headIconCenter.parent))){
                this._headIconCenter.parent.removeChild(this._headIconCenter);
            };
            if (this._tiles){
                _local_4 = 0;
                while (_local_4 < this._tiles.length) {
                    _local_5 = this._tiles[_local_4];
                    if (_local_5.parent){
                        _local_5.parent.removeChild(_local_5);
                    };
                    _local_4++;
                };
            };
            if (((_bloodBar) && (this._bloodBarVisible))){
                _local_1.addChild(_bloodBar);
            };
            if (((((((this._name) && (!((this._name == ""))))) && (_nameText))) && (this._nameVisible))){
                _local_1.addChild(_nameText);
            };
            if (((((((this._professionName) && (!((this._professionName == ""))))) && (_professionNameText))) && (this._professionNameVisible))){
                _local_1.addChild(_professionNameText);
            };
            if (((((_professionNameText) && (this._professionName))) && (this._professionNameVisible))){
                _professionNameText.textColor = this.professionNameColor;
                _professionNameText.width = 200;
                _professionNameText.htmlText = this._professionName;
                _professionNameText.width = (_professionNameText.textWidth + 4);
                _professionNameText.x = (-(_professionNameText.width) / 2);
                _professionNameText.height = (_professionNameText.textHeight + 4);
                _professionNameText.y = 0;
            };
            if (((((_nameText) && (this._name))) && (this._nameVisible))){
                _nameText.textColor = this.nameColor;
                _nameText.width = 200;
                _nameText.htmlText = this._name;
                _nameText.width = (_nameText.textWidth + 4);
                _nameText.x = (-(_nameText.width) / 2);
                _nameText.height = (_nameText.textHeight + 4);
                if (((this._professionName) && (this._nameVisible))){
                    _nameText.y = (_professionNameText.textHeight + 2);
                } else {
                    _nameText.y = 0;
                };
            };
            if (_bloodBar){
                _bloodBar.width = 60;
                _bloodBar.height = 5;
                _bloodBar.setValue(this._curr, this._max);
                _bloodBar.x = -30;
                if (_nameText){
                    _bloodBar.y = ((_nameText.y + _nameText.textHeight) + 2);
                } else {
                    if (_professionNameText){
                        _bloodBar.y = ((_professionNameText.y + _professionNameText.textHeight) + 2);
                    };
                };
            };
            var _local_2:Rectangle = this._shape.getBounds(null);
            if (_local_2.isEmpty()){
                return;
            };
            var _local_3:Matrix = RecoverUtils.matrix;
            _local_3.tx = -(_local_2.x);
            _local_3.ty = (_local_3.ty - 2);
            this._bmd = new BitmapData((this._shape.width + 2), (this._shape.height + 2), true, 0);
            this._bmd.draw(_local_1, _local_3);
            if (((_nameText) && (_nameText.parent))){
                _nameText.parent.removeChild(_nameText);
            };
            if (((_professionNameText) && (_professionNameText.parent))){
                _professionNameText.parent.removeChild(_professionNameText);
            };
            if (((_bloodBar) && (_bloodBar.parent))){
                _bloodBar.parent.removeChild(_bloodBar);
            };
            _local_3 = RecoverUtils.matrix;
            _local_3.tx = _local_2.x;
            _local_3.ty = -(_local_2.height);
            this.graphics.beginBitmapFill(this._bmd, _local_3, false);
            this.graphics.drawRect(_local_3.tx, _local_3.ty, this._bmd.width, this._bmd.height);
            if (this._headBitmapData){
                _local_3 = RecoverUtils.matrix;
                _local_3.tx = (-(this._headBitmapData.width) / 2);
                _local_3.ty = ((-(this._headBitmapData.height) - _local_2.height) - 2);
                this.graphics.beginBitmapFill(this._headBitmapData, _local_3, false);
                this.graphics.drawRect(_local_3.tx, _local_3.ty, this._headBitmapData.width, this._headBitmapData.height);
            };
            this.cacheAsBitmap = true;
            if (this._tiles){
                _local_6 = 0;
                while (_local_6 < this._tiles.length) {
                    _local_7 = this._tiles[_local_6];
                    _local_7.y = (-((this._shape.height + 3)) - ((_local_6 + 1) * _local_7.height));
                    this.addChild(_local_7);
                    _local_6++;
                };
            };
            if (this._headIconLeft){
                this._headIconLeft.y = (-(this._headIconSize) / 2);
                this._headIconLeft.x = ((_local_3.tx - this._headIconSize) - 5);
                if (this._headIconLeft.width > 0){
                    this._headIconLeft.x = ((_local_3.tx - this._headIconLeft.width) - 1);
                };
                this.addChild(this._headIconLeft);
            };
            if (this._flag){
                if (this._headIconLeft){
                    this._flag.x = ((this._headIconLeft.x - this._headIconSize) - 5);
                    if (this._flag.width > 0){
                        this._flag.x = ((this._headIconLeft.x - this._flag.width) - 1);
                    };
                } else {
                    this._flag.x = ((_local_3.tx - this._headIconSize) - 5);
                    if (this._flag.width > 0){
                        this._flag.x = ((_local_3.tx - this._flag.width) - 1);
                    };
                };
                this._flag.y = (-(this._headIconSize) / 2);
                this.addChild(this._flag);
            };
            if (this._headIconRight){
                this._headIconRight.y = (-(this._headIconSize) / 2);
                this._headIconRight.x = ((this._bmd.width - this._headIconSize) + 5);
                if (this._headIconRight.width > 0){
                    (this._bmd.width - this._headIconRight.width);
                };
                this.addChild(this._headIconRight);
            };
            if (this._headIconCenter){
                if ((this._headIconCenter as ItemAvatar)){
                    this._headIconCenter.y = (-(this._shape.height) - this._headIconSize);
                } else {
                    this._headIconCenter.y = (-(this._shape.height) - this._headIconCenter.height);
                    this._headIconCenter.x = (-(this._headIconCenter.width) / 2);
                };
                this.addChild(this._headIconCenter);
            };
        }

        override public function get height():Number
        {
            return (this._shape.height);
        }

        public function reset():void
        {
            var _local_1:int;
            var _local_2:DisplayObject;
            this.moveFunc = null;
            this.owner = null;
            this._headBitmapData = null;
            this._name = null;
            this._professionName = null;
            this._curr = 100;
            this._max = 100;
            this._nameColor = 0xFFFFFF;
            this._professionNameColor = 0xFF00;
            this.disposeHeadIcon();
            if (this._bmd){
                this._bmd.dispose();
            };
            if (this._tiles){
                _local_1 = 0;
                _local_1 = 0;
                while (_local_1 < this._tiles.length) {
                    _local_2 = this._tiles[_local_1];
                    if ((_local_2 as ItemAvatar)){
                        ItemAvatar(_local_2).dispose();
                    } else {
                        if ((_local_2 as Bitmap)){
                            Bitmap(_local_2).bitmapData = null;
                            if (_local_2.parent){
                                _local_2.parent.removeChild(_local_2);
                            };
                        } else {
                            if ((_local_2 as DisplayObject)){
                                _local_2.parent.removeChild(_local_2);
                            };
                        };
                    };
                    _local_1++;
                };
                this.disposeHeadIcon();
                this.disposeFlag();
            };
            this.graphics.clear();
        }

        override public function dispose():void
        {
            this.reset();
            super.dispose();
        }

        override public function get name():String
        {
            return (this._name);
        }

        public function set professionName(_arg_1:String):void
        {
            if (this._professionName != _arg_1){
                this._professionName = _arg_1;
                if (_professionNameText == null){
                    _professionNameText = new TextField();
                    _professionNameText.filters = [new GlowFilter(0, 1, 2, 2)];
                    _professionNameText.selectable = false;
                };
                this.draw();
            };
        }

        public function get professionName():String
        {
            return (this._professionName);
        }

        public function setup(_arg_1:Function):void
        {
            this.moveFunc = _arg_1;
        }

        override public function set x(_arg_1:Number):void
        {
            super.x = _arg_1;
            if (this.moveFunc != null){
                this.moveFunc();
            };
            if (((((((!(this.owner)) && ((x == 0)))) && ((y == 0)))) && (this.stage))){
                this.parent.removeChild(this);
            };
        }

        override public function set y(_arg_1:Number):void
        {
            super.y = _arg_1;
            if (this.moveFunc != null){
                this.moveFunc();
            };
            if (((((((!(this.owner)) && ((x == 0)))) && ((y == 0)))) && (this.stage))){
                this.parent.removeChild(this);
            };
        }


    }
}//package com.engine.core.view.items.avatar

