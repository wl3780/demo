package com.engine.core.view.items.avatar
{
    import com.engine.core.Core;
    import com.engine.core.ItemConst;
    import com.engine.core.tile.square.SquarePt;
    import com.engine.core.view.items.Item;
    import com.engine.core.view.scenes.Scene;
    import com.engine.core.view.scenes.SceneConstant;
    import com.engine.namespaces.coder;
    import com.engine.utils.gome.SquareUitls;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.filters.GlowFilter;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.Dictionary;

    public class ItemAvatar extends Item implements IAvatar 
    {

        coder static var $itemAvataInstanceNumber:int;
        private static var recovery_point:Point = new Point();

        public var avatarParams:Dictionary;
        private var _ap:AvatartParts;
        private var bitmapdata_mid:Bitmap;
        private var bitmapdata_wid:Bitmap;
        protected var bitmapdata_midm:Bitmap;
        protected var bitmapdata_wgid:Bitmap;
        private var eid_avatarBitmaps:Dictionary;
        protected var $isDisposed:Boolean = false;
        public var isSkillEffect:Boolean = false;
        private var nameText:TextField;
        public var playEndFunc:Function;
        protected var _pt:SquarePt;
        protected var _point:Point;
        private var _name:String;
        public var effect_id:String;
        public var curr_rect:Rectangle;
        private var _nameEnabled:Boolean = true;
        private var time:int = 0;

        public function ItemAvatar()
        {
            this._point = new Point();
            super();
            this.setup();
            this.isSceneItem = false;
            coder::$itemAvataInstanceNumber = (coder::$itemAvataInstanceNumber + 1);
        }

        override public function set isAutoDispose(_arg_1:Boolean):void
        {
            this._isAutoDispose = _arg_1;
            if (this._ap){
                this._ap.isAutoDispose = _arg_1;
            };
        }

        override public function set isSceneItem(_arg_1:Boolean):void
        {
            super.isSceneItem = _arg_1;
            this.isAutoDispose = _arg_1;
        }

        public function get isDeath():Boolean
        {
            return (false);
        }

        public function set pt(_arg_1:SquarePt):void
        {
            if (!this._point){
                this._point = new Point();
            };
            this._pt = _arg_1;
            this._point = SquareUitls.squareTopixels(_arg_1);
            super.x = this._point.x;
            super.y = this._point.y;
        }

        public function get pt():SquarePt
        {
            return (this._pt);
        }

        public function set point(_arg_1:Point):void
        {
            if (!this._point){
                this._point = new Point();
            };
            this._point = _arg_1;
            this._pt = SquareUitls.pixelsToSquare(_arg_1);
            super.x = _arg_1.x;
            super.y = _arg_1.y;
        }

        public function get point():Point
        {
            return (this._point);
        }

        override public function set x(_arg_1:Number):void
        {
            if (!this._point){
                this._point = new Point();
            };
            super.x = _arg_1;
            this._point.x = _arg_1;
            this._pt = SquareUitls.pixelsToSquare(this._point);
        }

        override public function set y(_arg_1:Number):void
        {
            if (!this._point){
                this._point = new Point();
            };
            super.y = _arg_1;
            this._point.y = _arg_1;
            this._pt = SquareUitls.pixelsToSquare(this._point);
        }

        public function get isDisposed():Boolean
        {
            return (this.$isDisposed);
        }

        public function set isDisposed(_arg_1:Boolean):void
        {
            this.$isDisposed = _arg_1;
        }

        public function get avatarParts():AvatartParts
        {
            return (this._ap);
        }

        public function set avatarParts(_arg_1:AvatartParts):void
        {
            this._ap = _arg_1;
        }

        public function setup():void
        {
            this.avatarParams = new Dictionary();
            this.avatarParts = new AvatartParts();
            this.avatarParts.type = SceneConstant.EFFECT;
            this.avatarParts.onRender = this.onRender;
            this.avatarParts.clear = coder::clear;
            this.avatarParts.disposeEffectsFunc = coder::disposeEffects;
            this.avatarParts.playEndFunc = coder::playEndFunc;
            this.avatarParts.setupReady = coder::setupReady;
            this.avatarParts.loadErorFunc = coder::loadErrorFunc;
            this.avatarParts.coder::oid = this.id;
            this.char_id = this.id;
            this.isDisposed = false;
        }

        coder function loadErrorFunc():void
        {
            if ((((this.avatarParts.type == SceneConstant.EFFECT)) && (this.isSceneItem))){
                this.dispose();
            };
        }

        coder function setupReady():void
        {
            var _local_1:String;
            if (this.avatarParams){
                _local_1 = this.avatarParts.state;
                this.loadCharActionAssets(_local_1);
            };
        }

        coder function playEndFunc(_arg_1:Object):void
        {
            if (this.playEndFunc != null){
                this.playEndFunc.apply(null);
            };
        }

        public function get stageIntersects():Boolean
        {
            var _local_2:Point;
            var _local_3:Rectangle;
            var _local_4:Rectangle;
            var _local_1:Boolean = true;
            if (((Scene.scene) && (this.isSceneItem))){
                _local_2 = Scene.scene.globalToLocal(recovery_point);
                _local_3 = new Rectangle(_local_2.x, _local_2.y, Core.stage.stageWidth, (Core.stage.stageHeight + 150));
                _local_4 = new Rectangle(x, y, 1, 1);
                if (this.curr_rect != null){
                    _local_4.x = (x + this.curr_rect.topLeft.x);
                    _local_4.y = (y + this.curr_rect.topLeft.y);
                    _local_4.width = this.curr_rect.width;
                    _local_4.height = this.curr_rect.height;
                };
                _local_1 = _local_3.intersects(_local_4);
            };
            return (_local_1);
        }

        public function set nameEnabled(_arg_1:Boolean):void
        {
            this._nameEnabled = _arg_1;
            if (this.nameText){
                this.nameText.visible = this._nameEnabled;
            };
        }

        override public function set name(_arg_1:String):void
        {
            var _local_2:TextFormat;
            this._name = _arg_1;
            if (this.nameText == null){
                this.nameText = new TextField();
                _local_2 = new TextFormat();
                _local_2.size = 12;
                this.nameText.defaultTextFormat = _local_2;
                this.nameText.textColor = 0xFFFFFF;
                this.nameText.filters = [new GlowFilter(0, 1, 4, 4, 3)];
                this.nameText.mouseEnabled = false;
                this.nameText.mouseWheelEnabled = false;
                this.nameText.selectable = false;
                this.nameText.cacheAsBitmap = true;
            };
            this.nameText.visible = this._nameEnabled;
            if (this.contains(this.nameText) == false){
                this.addChild(this.nameText);
            };
            this.nameText.htmlText = _arg_1;
            this.nameText.width = (this.nameText.textWidth + 10);
            this.nameText.x = (-(this.nameText.textWidth) / 2);
            this.nameText.y = -110;
        }

        public function loadAvatarPart(_arg_1:String, _arg_2:AvatarRestrict=null):String
        {
            var _local_3:String;
            var _local_4:Array;
            var _local_5:String;
            var _local_6:String;
            var _local_7:String;
            var _local_8:Array;
            var _local_9:int;
            if (this.isDisposed){
                return (null);
            };
            if (this.avatarParams){
                _local_3 = _arg_1;
                _local_4 = _arg_1.split("/");
                _local_5 = _local_4[(_local_4.length - 1)];
                _local_6 = _local_4[(_local_4.length - 2)];
                if ((_local_6 == null)){
                    _local_6 = "";
                };
                if (_local_4.length >= 2){
                    _local_4[(_local_4.length - 2)] = "output";
                } else {
                    if (_local_4.length == 1){
                        _local_4.unshift("output");
                    };
                };
                _arg_1 = _local_4.join("/");
                _local_7 = _local_5.split("_")[0];
                _local_5 = _local_5.split(Core.TMP_FILE)[0];
                _local_7 = _local_5.split("_")[0];
                _arg_1 = _arg_1.split(Core.TMP_FILE).join(".sm");
                _local_8 = _local_5.split("_");
                _local_9 = int(_local_8[1]);
                if (_local_9 > 0){
                    if (this.avatarParams[_local_5] == null){
                        this.avatarParams[_local_5] = _local_5;
                    };
                    this.avatarParts.type = SceneConstant.EFFECT;
                    AvatarManager.coder::getInstance().put(this.avatarParts);
                    AvatarAssetManager.getInstance().loadAvatar(_arg_1, this.avatarParts.id, _local_3);
                } else {
                    if (this.avatarParts){
                        this.avatarParts.removeAvatarPartByType(_local_7);
                        switch (_local_7){
                            case ItemConst.BODY_TYPE:
                                if (this.bitmapdata_mid){
                                    this.bitmapdata_mid.bitmapData = null;
                                };
                                break;
                            case ItemConst.WEAPON_TYPE:
                                if (this.bitmapdata_wid){
                                    this.bitmapdata_wid.bitmapData = null;
                                };
                                break;
                            case ItemConst.MOUNT_TYPE:
                                if (this.bitmapdata_midm){
                                    this.bitmapdata_midm.bitmapData = null;
                                };
                                break;
                            case ItemConst.WING_TYPE:
                                if (this.bitmapdata_wgid){
                                    this.bitmapdata_wgid.bitmapData = null;
                                };
                                break;
                        };
                    };
                };
            };
            return (null);
        }

        public function loadCharActionAssets(_arg_1:String):void
        {
            var _local_3:AvatarParam;
            var _local_4:String;
            if ((((_arg_1 == null)) || ((_arg_1 == "")))){
                return;
            };
            if (this.avatarParts.avatarParts == null){
                return;
            };
            var _local_2:Dictionary = this.avatarParts.avatarParts[_arg_1];
            for each (_local_3 in _local_2) {
                _local_4 = _local_3.assetsPath;
                _local_4 = _local_4.split(Core.TMP_FILE).join((("_" + _arg_1) + Core.TMP_FILE));
                AvatarAssetManager.getInstance().loadAvatarAssets(_local_4, _arg_1, this.avatarParts.id);
            };
        }

        public function play(_arg_1:String):void
        {
            if (this.isDisposed){
                return;
            };
            this.avatarParts.state = _arg_1;
            this.loadCharActionAssets(_arg_1);
        }

        public function set dir(_arg_1:int):void
        {
            if (this.isDisposed){
                return;
            };
            if (this.avatarParts.dir != _arg_1){
                this.avatarParts.dir = _arg_1;
            };
        }

        public function set stop(_arg_1:Boolean):void
        {
            if (this.avatarParts){
                this.avatarParts.stop = _arg_1;
            };
        }

        public function get stop():Boolean
        {
            if (this.avatarParts){
                return (this.avatarParts.stop);
            };
            return (false);
        }

        public function get dir():int
        {
            return (this.avatarParts.dir);
        }

        public function faceTo(_arg_1:DisplayObject):void
        {
            this.dir = this.getDretion(_arg_1.x, _arg_1.y);
        }

        public function setRotation(_arg_1:Number, _arg_2:Number):void
        {
            _arg_1 = (_arg_1 - this.x);
            _arg_2 = (_arg_2 - this.y);
            var _local_3:Number = Math.atan2(_arg_2, _arg_1);
            this.rotation = ((_local_3 * 180) / Math.PI);
        }

        public function getDretion(_arg_1:Number, _arg_2:Number):int
        {
            var _local_3:int;
            var _local_4:Number = (this.x - _arg_1);
            var _local_5:Number = (this.y - _arg_2);
            var _local_6:Number = ((Math.atan2(_local_5, _local_4) * 180) / Math.PI);
            if ((((_local_6 >= -15)) && ((_local_6 < 15)))){
                _local_3 = 6;
            } else {
                if ((((_local_6 >= 15)) && ((_local_6 < 75)))){
                    _local_3 = 7;
                } else {
                    if ((((_local_6 >= 75)) && ((_local_6 < 105)))){
                        _local_3 = 0;
                    } else {
                        if ((((_local_6 >= 105)) && ((_local_6 < 170)))){
                            _local_3 = 1;
                        } else {
                            if ((((_local_6 >= 170)) || ((_local_6 < -170)))){
                                _local_3 = 2;
                            } else {
                                if ((((_local_6 >= -75)) && ((_local_6 < -15)))){
                                    _local_3 = 5;
                                } else {
                                    if ((((_local_6 >= -105)) && ((_local_6 < -75)))){
                                        _local_3 = 4;
                                    } else {
                                        if ((((_local_6 >= -170)) && ((_local_6 < -105)))){
                                            _local_3 = 3;
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
            return (_local_3);
        }

        coder function onRendStart():void
        {
            if (this.curr_rect){
                this.curr_rect.setEmpty();
            };
        }

        coder function clear():void
        {
        }

        public function hitIcon():Boolean
        {
            return (false);
        }

        coder function disposeEffects(_arg_1:String):void
        {
            var _local_2:Bitmap;
            try {
                _local_2 = this.eid_avatarBitmaps[_arg_1];
                if (_local_2){
                    _local_2.bitmapData = null;
                    if (_local_2.parent){
                        _local_2.parent.removeChild(_local_2);
                    };
                };
            } catch(e:Error) {
            };
            this.dispose();
        }

        public function onRender(_arg_1:String, _arg_2:int, _arg_3:BitmapData, _arg_4:Rectangle, _arg_5:String, _arg_6:String=null, _arg_7:int=0, _arg_8:int=0, _arg_9:BitmapData=null):void
        {
            var _local_10:Bitmap;
            var _local_11:int;
            var _local_12:int;
            if (this.avatarParts.id != _arg_1){
                return;
            };
            if (((((!(this.isDisposed)) && (this.stage))) && (!((this.parent == null))))){
                if (this.stageIntersects){
                    if (_arg_5 == ItemConst.BODY_TYPE){
                        if (this.bitmapdata_mid == null){
                            this.bitmapdata_mid = new Bitmap();
                            if (this.bitmapdata_midm){
                                this.addChild(this.bitmapdata_midm);
                            };
                            if (this.bitmapdata_mid){
                                this.addChild(this.bitmapdata_mid);
                            };
                            if (this.bitmapdata_wid){
                                this.addChild(this.bitmapdata_wid);
                            };
                            if (this.bitmapdata_wgid){
                                this.addChild(this.bitmapdata_wgid);
                            };
                        };
                        _local_10 = this.bitmapdata_mid;
                    } else {
                        if (_arg_5 == ItemConst.WEAPON_TYPE){
                            if (this.bitmapdata_wid == null){
                                this.bitmapdata_wid = new Bitmap();
                                if (this.bitmapdata_midm){
                                    this.addChild(this.bitmapdata_midm);
                                };
                                if (this.bitmapdata_mid){
                                    this.addChild(this.bitmapdata_mid);
                                };
                                if (this.bitmapdata_wid){
                                    this.addChild(this.bitmapdata_wid);
                                };
                                if (this.bitmapdata_wgid){
                                    this.addChild(this.bitmapdata_wgid);
                                };
                            };
                            _local_10 = this.bitmapdata_wid;
                        } else {
                            if (_arg_5 == ItemConst.MOUNT_TYPE){
                                if (this.bitmapdata_midm == null){
                                    this.bitmapdata_midm = new Bitmap();
                                    if (this.bitmapdata_midm){
                                        this.addChild(this.bitmapdata_midm);
                                    };
                                    if (this.bitmapdata_mid){
                                        this.addChild(this.bitmapdata_mid);
                                    };
                                    if (this.bitmapdata_wid){
                                        this.addChild(this.bitmapdata_wid);
                                    };
                                    if (this.bitmapdata_wgid){
                                        this.addChild(this.bitmapdata_wgid);
                                    };
                                };
                                _local_10 = this.bitmapdata_midm;
                            } else {
                                if (_arg_5 == ItemConst.WING_TYPE){
                                    if (this.bitmapdata_midm == null){
                                        this.bitmapdata_wgid = new Bitmap();
                                        if (this.bitmapdata_midm){
                                            this.addChild(this.bitmapdata_midm);
                                        };
                                        if (this.bitmapdata_mid){
                                            this.addChild(this.bitmapdata_mid);
                                        };
                                        if (this.bitmapdata_wid){
                                            this.addChild(this.bitmapdata_wid);
                                        };
                                        if (this.bitmapdata_wgid){
                                            this.addChild(this.bitmapdata_wgid);
                                        };
                                    };
                                    _local_10 = this.bitmapdata_wgid;
                                } else {
                                    if (_arg_5 == ItemConst.EFFECT_TYPE){
                                        if (this.eid_avatarBitmaps == null){
                                            this.eid_avatarBitmaps = new Dictionary();
                                        };
                                        if (this.eid_avatarBitmaps[_arg_6] == null){
                                            this.eid_avatarBitmaps[_arg_6] = new Bitmap();
                                            this.addChild(this.eid_avatarBitmaps[_arg_6]);
                                        };
                                        _local_10 = this.eid_avatarBitmaps[_arg_6];
                                    };
                                };
                            };
                        };
                    };
                    if (_local_10){
                        _local_11 = -(_arg_7);
                        _local_12 = -(_arg_8);
                        if (_local_10.bitmapData != _arg_3){
                            _local_10.bitmapData = _arg_3;
                        };
                        if ((((_arg_3 == Core.shadow_bitmapData)) && (Core.shadow_bitmapData))){
                            if (_local_10.x != _local_11){
                                _local_10.x = (-(Core.shadow_bitmapData.width) / 2);
                            };
                            if (_local_10.y != _local_12){
                                _local_10.y = -(Core.shadow_bitmapData.height);
                            };
                        } else {
                            if (_local_10.x != _local_11){
                                _local_10.x = _local_11;
                            };
                            if (_local_10.y != _local_12){
                                _local_10.y = _local_12;
                            };
                        };
                    };
                };
            };
        }

        public function removeAvatarPart(_arg_1:String):void
        {
        }

        public function removeAvatarPartByType(_arg_1:String):void
        {
            if (!this.avatarParts){
                return;
            };
            switch (_arg_1){
                case ItemConst.EFFECT_TYPE:
                    return;
                case ItemConst.BODY_TYPE:
                    return;
                case ItemConst.WEAPON_TYPE:
                    return;
                case ItemConst.MOUNT_TYPE:
                    return;
            };
        }

        override public function dispose():void
        {
            var _local_1:Bitmap;
            var _local_2:String;
            if (this.avatarParts){
                this.avatarParts.dispose();
                this.avatarParts = null;
            };
            if (this.bitmapdata_wid){
                this.bitmapdata_wid.bitmapData = null;
            };
            if (this.bitmapdata_midm){
                this.bitmapdata_midm.bitmapData = null;
            };
            if (this.bitmapdata_mid){
                this.bitmapdata_mid.bitmapData = null;
            };
            if (this.bitmapdata_wgid){
                this.bitmapdata_wgid.bitmapData = null;
            };
            if (((this.nameText) && (this.nameText.parent))){
                this.nameText.parent.removeChild(this.nameText);
            };
            this.bitmapdata_midm = null;
            this.bitmapdata_wid = null;
            this.bitmapdata_mid = null;
            this.bitmapdata_wgid = null;
            this._point = null;
            this.nameText = null;
            this._nameEnabled = true;
            for each (_local_1 in this.eid_avatarBitmaps) {
                if (this.contains(_local_1)){
                    this.removeChild(_local_1);
                };
                if (_local_1){
                    _local_1.bitmapData = null;
                };
                _local_1 = null;
            };
            this.eid_avatarBitmaps = null;
            for (_local_2 in this.avatarParams) {
                delete this.avatarParams[_local_2];
            };
            this.avatarParams = null;
            this._point = null;
            super.dispose();
            this.isDisposed = true;
            this._pt = null;
            if (Scene.scene){
                Scene.scene.remove(this);
            };
            coder::$itemAvataInstanceNumber--;
        }


    }
}//package com.engine.core.view.items.avatar

