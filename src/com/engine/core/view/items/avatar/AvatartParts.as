package com.engine.core.view.items.avatar
{
    import com.engine.core.Core;
    import com.engine.core.ItemConst;
    import com.engine.core.model.Proto;
    import com.engine.namespaces.coder;
    
    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;

    public class AvatartParts extends Proto 
    {

        public var avatarParts:Dictionary;
        public var effectsParts:Dictionary;
        public var hiedBody:Boolean = false;
        public var hiedWeapon:Boolean = false;
        public var hiedMount:Boolean = false;
        public var eid_len:int = 0;
        public var type:String;
        public var attackSpeed:Number = 1;
        public var vs:Number = 0;
        public var acce:Number = 1;
        public var runing:Boolean;
        public var jumping:Boolean;
        public var isTimeoutDelete:Boolean = true;
        public var specialMode:int = 0;
        public var isFlyMode:Boolean = false;
        public var isAutoDispose:Boolean = true;
        public var setupReady:Function;
        public var onRender:Function;
        public var clear:Function;
        public var disposeEffectsFunc:Function;
        public var subFunc:Function;
        public var playEndFunc:Function;
        public var loadErorFunc:Function;
        public var onRendStart:Function;
        public var playEffectFunc:Function;
        public var isPalyStandDeay:Boolean = true;
        public var isOnMonut:Boolean;
        public var lockEffectState:Boolean = true;
		
        protected var _effectRestrict:Dictionary;
		
        private var assetsIndex:int;
        private var counter:int;
        private var _stop:Boolean = false;
        private var _effectRestricts:Dictionary;
        private var states:Array;
        private var _state:String = "stand";
        private var oldState:String = "stand";
        private var _currRestrict:AvatarRestrict;
        private var _currentFrame:int = 0;
        private var _fly_currentFrame:int = 0;
        private var _totalFrames:int = 4;
        private var _dir:int = 4;
        private var _speed:int = 0;
        private var wid_id:String;
        private var mid_id:String;
        private var midm_id:String;
        private var isDisposed:Boolean = false;
        private var _isLockSpeed:Boolean = false;
        private var _lockSpeedState:String = "all";
        private var _isLockEffectPlaySpeed:Boolean;
        private var _lockEffectPlaySpeed:int;
        private var lockSpeedValue:int;
        private var timerId:int = 0;

        public function AvatartParts()
        {
            this.states = ["walk", "stand", "skill1", "hit", "skill2", "skill3", "dazuo", "caiji", "fly"];
            this._currRestrict = new AvatarRestrict();
            super();
            this._effectRestrict = new Dictionary();
        }

        public function get totalFrames():int
        {
            return (this._totalFrames);
        }

        public function get stop():Boolean
        {
            return (this._stop);
        }

        public function set stop(_arg_1:Boolean):void
        {
            this._stop = _arg_1;
        }

        public function addEffectRestrict(_arg_1:String, _arg_2:AvatarRestrict):void
        {
            if (this._effectRestrict[_arg_1] == null){
                this._effectRestrict[_arg_1] = _arg_2;
            };
        }

        public function removeEffectRestrict(_arg_1:String):void
        {
            delete this._effectRestrict[_arg_1];
        }

        public function get speed():int
        {
            return (this._speed);
        }

        public function setSpeedLock(_arg_1:Boolean, _arg_2:int=0, _arg_3:String="all"):void
        {
            this._lockSpeedState = _arg_3;
            this._isLockSpeed = _arg_1;
            this.lockSpeedValue = _arg_2;
        }

        public function lockEffectPlaySpeed(_arg_1:Boolean, _arg_2:int=0):void
        {
            this._isLockEffectPlaySpeed = _arg_1;
            this._lockEffectPlaySpeed = _arg_2;
        }

        coder function set speed(_arg_1:int):void
        {
            this._speed = _arg_1;
        }

        public function get restrict():AvatarRestrict
        {
            return (this._currRestrict);
        }

        public function set restrict(_arg_1:AvatarRestrict):void
        {
            this._currRestrict = _arg_1;
        }

        public function get state():String
        {
            return (this._state);
        }

        public function set state(_arg_1:String):void
        {
            if (this._state != _arg_1){
                this._state = _arg_1;
            };
        }

        public function get currentFrame():int
        {
            return (this._currentFrame);
        }

        public function set currentFrame(_arg_1:int):void
        {
            this._currentFrame = _arg_1;
        }

        public function play(_arg_1:String=null, _arg_2:AvatarRestrict=null, _arg_3:Boolean=false):void
        {
            if (_arg_1 != this.state){
                this.currentFrame = 0;
                this.counter = 0;
                if (_arg_2){
                    _arg_2.state = _arg_1;
                    this.restrict = _arg_2;
                };
                this.state = _arg_1;
                if (_arg_3){
                    this.bodyRender();
                };
            };
        }

        public function bodyRender(_arg_1:Boolean=false):void
        {
            var _local_2:AvatarParam;
            var _local_3:BitmapData;
            var _local_4:Rectangle;
            var _local_5:BitmapData;
            var _local_6:int;
            var _local_7:String;
            var _local_8:String;
            var _local_9:String;
            var _local_10:Dictionary;
            var _local_11:Boolean;
            var _local_12:int;
            var _local_13:int;
            var _local_14:Boolean;
            var _local_15:Boolean;
            var _local_16:Object;
            var _local_17:int;
            if (((((this.isDisposed) || (this._stop))) || ((this.avatarParts == null)))){
                return;
            };
            if (this.avatarParts != null){
                _local_9 = this.state;
                if (((((((this.isFlyMode) && (this.isOnMonut))) && (!((_local_9 == CharAction.MEDITATION))))) && (!((_local_9 == CharAction.SKILL2))))){
                    _local_9 = CharAction.STAND;
                };
                if (this.specialMode == 1){
                    _local_9 = "skill2";
                };
                _local_10 = (this.avatarParts[_local_9] as Dictionary);
                if (this.oldState != this.state){
                    this.counter = 0;
                    this._currentFrame = 0;
                };
                if (_local_10){
                    if (this.clear != null){
                        this.clear();
                    };
                    _local_11 = false;
                    _local_2 = _local_10[this.mid_id];
                    if (_local_2 == null){
                        _local_2 = _local_10[this.midm_id];
                        if (!_local_2){
                            (_local_2 == _local_10[this.wid_id]);
                            if (!_local_2){
                                return;
                            };
                        };
                    };
                    this._speed = (_local_2.speed * (1 / this.acce));
                    if (((this._isLockSpeed) && ((((this._lockSpeedState == "all")) || ((this._lockSpeedState == this.state)))))){
                        this._speed = this.lockSpeedValue;
                    };
                    if ((((this.runing == false)) && ((this.state == CharAction.WALK)))){
                        this.state = "stand";
                    };
                    _local_12 = (this._speed - this.vs);
                    if ((((((((((this.state == CharAction.ATTACK)) || ((this.state == CharAction.QUNGONG)))) || ((this.state == CharAction.SKILL1)))) || ((this.state == CharAction.MEDITATION)))) || ((this.state == CharAction.MEDITATION)))){
                        _local_12 = (this.attackSpeed * this._speed);
                    };
                    _local_13 = (Core.delayTime - this.counter);
                    if ((((_local_13 >= _local_12)) || (_arg_1))){
                        this.counter = Core.delayTime;
                        this.oldState = this.state;
                        _local_14 = true;
                        _local_15 = true;
                        if (this.onRendStart != null){
                            this.onRendStart();
                        };
                        for each (_local_2 in _local_10) {
                            _local_11 = true;
                            _local_16 = {
                                "assets_id":_local_2.coder::assets_id,
                                "link":_local_2.link,
                                "type":_local_2.type,
                                "avatarParm_oid":_local_2.oid,
                                "avatarParm_id":_local_2.id
                            };
                            this._totalFrames = _local_2.frames;
                            _local_8 = _local_2.type;
                            if ((((this._currentFrame >= _local_2.frames)) && (((!(this.isFlyMode)) || (((this.isFlyMode) && (!((_local_8 == "midm"))))))))){
                                if ((((this.specialMode == 1)) && ((this._currentFrame >= _local_2.frames)))){
                                    this._currentFrame = 0;
                                } else {
                                    if (!((((this._currRestrict) && ((this._currRestrict.state == _local_9)))) && (this._currRestrict.stopInLastFrame))){
                                        this._currentFrame = 0;
                                        if (this.playEndFunc != null){
                                            this.playEndFunc(_local_16);
                                        };
                                    } else {
                                        if (((((((this._currRestrict) && (this._currRestrict.state))) && (!((_local_9 == CharAction.DEATH))))) && (!((_local_9 == CharAction.MEDITATION))))){
                                            if (this.playEndFunc != null){
                                                this.playEndFunc(_local_16);
                                            };
                                            if (this.isPalyStandDeay){
                                                this.play(CharAction.STAND);
                                            } else {
                                                this._currentFrame = (_local_2.frames - 1);
                                            };
                                        } else {
                                            this._currentFrame = (_local_2.frames - 1);
                                        };
                                    };
                                };
                            };
                            if (this._currentFrame == (_local_2.frames - 2)){
                                if (this.playEffectFunc != null){
                                    this.playEffectFunc(_local_2);
                                };
                            };
                            if ((((_local_8 == "midm")) && (this.isFlyMode))){
                                _local_17 = (_local_2.frames - 1);
                                if (this._fly_currentFrame > _local_17){
                                    this._fly_currentFrame = 0;
                                };
                                _local_3 = _local_2.getBitmapData(this.dir, this._fly_currentFrame);
                            } else {
                                _local_3 = _local_2.getBitmapData(this.dir, this._currentFrame);
                            };
                            if (((((this.isFlyMode) && ((_local_8 == "midm")))) && ((_local_17 < this._currentFrame)))){
                                _local_3 = _local_2.getBitmapData(this.dir, this._fly_currentFrame);
                            };
                            if (_local_2.maxRects[this.dir] == null){
                                _local_2.maxRects[this.dir] = new Rectangle(0, 0, 0, 110);
                            };
                            if (_local_3 == Core.shadow_bitmapData){
                            };
                            if (((((((_local_3) && (!((_local_3 == Core.shadow_bitmapData))))) && ((_local_3.width > 0)))) && ((_local_3.height > 0)))){
                                _local_2.maxRects[this.dir] = _local_3.rect.union(_local_2.maxRects[this.dir]);
                            };
                            _local_4 = _local_2.maxRects[this.dir];
                            if (_local_2.replay == 0){
                                _local_7 = _local_2.oid;
                                delete this.avatarParts[_local_7];
                                _local_2.dispose();
                                break;
                            };
                            if (_local_2.replay > 0){
                                if (!((((((this.hiedBody) && ((_local_2.type == ItemConst.BODY_TYPE)))) || (((this.hiedWeapon) && ((_local_2.type == ItemConst.WEAPON_TYPE)))))) || (((this.hiedMount) && ((_local_2.type == ItemConst.MOUNT_TYPE)))))){
                                    if (_local_2.type == ItemConst.BODY_TYPE){
                                        _local_14 = false;
                                    };
                                    if (_local_2.type == ItemConst.MOUNT_TYPE){
                                        _local_15 = false;
                                    };
                                    if (((this.isFlyMode) && ((_local_8 == "midm")))){
                                        this.onRender(this.id, this._dir, _local_3, _local_4, _local_2.type, _local_2.id, _local_2.txs[this._dir][this._fly_currentFrame], _local_2.tys[this._dir][this._fly_currentFrame], _local_5);
                                    } else {
                                        this.onRender(this.id, this._dir, _local_3, _local_4, _local_2.type, _local_2.id, _local_2.txs[this._dir][this._currentFrame], _local_2.tys[this._dir][this._currentFrame], _local_5);
                                    };
                                };
                                if (this._currentFrame >= _local_2.frames){
                                    _local_2.replay--;
                                };
                            } else {
                                if (_local_2.replay == -1){
                                    if (!((((((this.hiedBody) && ((_local_2.type == ItemConst.BODY_TYPE)))) || (((this.hiedWeapon) && ((_local_2.type == ItemConst.WEAPON_TYPE)))))) || (((this.hiedMount) && ((_local_2.type == ItemConst.MOUNT_TYPE)))))){
                                        if (_local_2.type == ItemConst.BODY_TYPE){
                                            _local_14 = false;
                                        };
                                        if (_local_2.type == ItemConst.MOUNT_TYPE){
                                            _local_15 = false;
                                        };
                                        if (((this.isFlyMode) && ((_local_8 == "midm")))){
                                            this.onRender(this.id, this._dir, _local_3, _local_4, _local_2.type, _local_2.id, _local_2.txs[this._dir][this._fly_currentFrame], _local_2.tys[this._dir][this._fly_currentFrame], _local_5);
                                        } else {
                                            this.onRender(this.id, this._dir, _local_3, _local_4, _local_2.type, _local_2.id, _local_2.txs[this._dir][this._currentFrame], _local_2.tys[this._dir][this._currentFrame], _local_5);
                                        };
                                    };
                                };
                            };
                        };
                        if (_local_14){
                            this.onRender(this.id, 0, null, _local_4, ItemConst.BODY_TYPE);
                        };
                        if (_local_15){
                            this.onRender(this.id, 0, null, _local_4, ItemConst.WEAPON_TYPE);
                        };
                        this._currentFrame = (this._currentFrame + 1);
                        this._fly_currentFrame = (this._fly_currentFrame + 1);
                    };
                };
            };
        }

        public function getEffectRestrict(_arg_1:String):AvatarRestrict
        {
            var _local_2:AvatarRestrict;
            for each (_local_2 in this._effectRestrict) {
                if (_arg_1 == _local_2.oid){
                    return (_local_2);
                };
            };
            return (null);
        }

        public function effectRender():void
        {
            var _local_1:AvatarParam;
            var _local_2:BitmapData;
            var _local_3:Rectangle;
            var _local_5:int;
            var _local_6:String;
            var _local_7:String;
            var _local_8:Function;
            var _local_9:Dictionary;
            var _local_10:int;
            var _local_11:int;
            var _local_12:Object;
            var _local_13:Boolean;
            var _local_14:AvatarRestrict;
            var _local_15:int;
            var _local_16:int;
            if (((this.isDisposed) || ((this.effectsParts == null)))){
                return;
            };
            var _local_4:int;
            if (this.effectsParts != null){
                if (this.lockEffectState){
                    _local_9 = (this.effectsParts[CharAction.STAND] as Dictionary);
                } else {
                    _local_9 = (this.effectsParts[this.state] as Dictionary);
                    if (!_local_9){
                        _local_9 = (this.effectsParts[CharAction.STAND] as Dictionary);
                    };
                };
                if (_local_9){
                    if (this.clear != null){
                        this.clear();
                    };
                    for each (_local_1 in _local_9) {
                        if (!this.lockEffectState){
                            _local_1.replay = -1;
                        };
                        _local_12 = {
                            "assets_id":_local_1.coder::assets_id,
                            "link":_local_1.link,
                            "type":_local_1.type,
                            "avatarParm_oid":_local_1.oid,
                            "avatarParm_id":_local_1.id
                        };
                        _local_13 = false;
                        _local_14 = this.getEffectRestrict(_local_12.assets_id);
                        if (((_local_14) && ((_local_14.oid == _local_12.assets_id)))){
                            if (_local_14.gotoAndPlay){
                                _local_1.currentFrame = _local_14.stopFrame;
                            };
                            if (_local_14.gotoAndPlayLastFrame){
                                _local_1.currentFrame--;
                            };
                            if (_local_14.stopInLastFrame){
                                _local_13 = true;
                            };
                        };
                        if (_local_1.heights.length == 1){
                            _local_11 = 0;
                        } else {
                            _local_11 = this.dir;
                        };
                        _local_15 = (Core.delayTime - _local_1.counter);
                        if (((((!((_local_1.replay == -1))) && (((Core.delayTime - _local_1.startPlayTime) > (((_local_1.replay * _local_1.speed) * _local_1.frames) + 3000))))) && (!(_local_13)))){
                            _local_1.replay = 0;
                        };
                        if (((((this.isTimeoutDelete) && ((ItemAvatar.coder::$itemAvataInstanceNumber > 500)))) && (int(((getTimer() / 1000) < 30))))){
                            _local_1.replay = 0;
                            _local_6 = (_local_1.id + _local_1.oid);
                            this.onRender(0, null, _local_3, _local_1.type);
                            this.disposeEffectsFunc(_local_1.id);
                            delete _local_9[_local_6];
                            _local_1.dispose();
                            this.eid_len--;
                            if (this.loadErorFunc != null){
                                this.loadErorFunc();
                            };
                            break;
                        };
                        _local_16 = _local_1.speed;
                        if (this._isLockEffectPlaySpeed){
                            _local_16 = this._lockEffectPlaySpeed;
                        };
                        if (_local_15 >= _local_16){
                            _local_1.counter = Core.delayTime;
                            _local_10 = _local_1.currentFrame;
                            _local_3 = _local_1.getRect(_local_11, _local_10);
                            _local_2 = _local_1.getBitmapData(_local_11, _local_10);
                            if (_local_2){
                                _local_1.currentFrame = (_local_1.currentFrame + Core.handleCount);
                                _local_5 = _local_3.width;
                                if (((_local_13) && ((_local_1.currentFrame >= _local_1.frames)))){
                                    _local_1.currentFrame--;
                                };
                                if (_local_1.replay == 0){
                                    _local_6 = (_local_1.id + _local_1.oid);
                                    this.onRender(this.id, 0, null, _local_3, _local_1.type);
                                    this.disposeEffectsFunc(_local_1.id);
                                    delete _local_9[_local_6];
                                    _local_1.dispose();
                                    this.eid_len--;
                                    break;
                                };
                                if (_local_1.replay > 0){
                                    this.onRender(this.id, _local_11, _local_2, _local_3, _local_1.type, _local_1.id, _local_1.txs[_local_11][_local_10], _local_1.tys[_local_11][_local_10]);
                                    if (_local_1.currentFrame >= _local_1.frames){
                                        if (!_local_13){
                                            _local_1.currentFrame = 0;
                                            _local_1.replay--;
                                        };
                                        if (this.playEndFunc != null){
                                            this.playEndFunc(_local_12);
                                        };
                                    };
                                } else {
                                    this.onRender(this.id, _local_11, _local_2, _local_3, _local_1.type, _local_1.id, _local_1.txs[_local_11][_local_10], _local_1.tys[_local_11][_local_10]);
                                    if (_local_1.currentFrame >= _local_1.frames){
                                        _local_1.currentFrame = 0;
                                        if (this.playEndFunc != null){
                                            this.playEndFunc(_local_12);
                                        };
                                    };
                                };
                            } else {
                                if (((((((!(_local_2)) && (this.isTimeoutDelete))) && ((_local_1.startPlayTime > 0)))) && (((_local_1.counter - _local_1.startPlayTime) > 15000)))){
                                    _local_6 = (_local_1.id + _local_1.oid);
                                    this.onRender(this.id, 0, null, _local_3, _local_1.type);
                                    this.disposeEffectsFunc(_local_1.id);
                                    delete _local_9[_local_6];
                                    _local_1.dispose();
                                    this.eid_len--;
                                    break;
                                };
                            };
                        };
                    };
                };
            };
        }

        public function removeAvatarPartByType(_arg_1:String):void
        {
            var _local_2:Dictionary;
            var _local_3:String;
            var _local_4:String;
            if (this.avatarParts){
                for each (_local_2 in this.avatarParts) {
                    for (_local_3 in _local_2) {
                        _local_4 = _local_3.split("_")[0];
                        if (_arg_1 == _local_4){
                            delete _local_2[_local_3];
                        };
                    };
                };
            };
        }

        public function removeEffect(_arg_1:String):String
        {
            var _local_2:String;
            var _local_3:Dictionary;
            var _local_4:String;
            var _local_5:AvatarParam;
            if (this.effectsParts){
                _local_3 = this.effectsParts[CharAction.STAND];
                for (_local_4 in _local_3) {
                    if (_local_4.indexOf(_arg_1) != -1){
                        _local_5 = _local_3[_local_4];
                        _local_2 = _local_5.id;
                        _local_5.dispose();
                        _local_5 = null;
                        delete _local_3[_local_4];
                        break;
                    };
                };
            };
            return (_local_2);
        }

        public function removeAvatarPart(_arg_1:String):void
        {
            delete this.avatarParts[_arg_1];
        }

        coder function setupStart(_arg_1:String):void
        {
            var _local_2:String;
            var _local_4:Dictionary;
            var _local_5:String;
            var _local_6:String;
            var _local_7:AvatarParam;
            var _local_3:String = _arg_1.split("_")[0];
            for each (_local_4 in this.avatarParts) {
                for (_local_5 in _local_4) {
                    _local_6 = _local_5.split("_")[0];
                    if ((((((_local_6 == _local_3)) && (!((_local_6 == ItemConst.EFFECT_TYPE))))) && (!((_arg_1 == _local_5))))){
                        _local_7 = _local_4[_local_5];
                        delete _local_4[_local_5];
                        if (_local_7){
                            _local_7.dispose();
                        };
                        _local_2 = _local_3;
                    };
                };
            };
            if (_local_2){
                if (this.onRender != null){
                    this.onRender(this.id, 0, null, new Rectangle(0, 0, 0, 110), null, _local_2, 0, 0);
                };
            };
            if (this.subFunc != null){
                this.subFunc.apply(null, ["setupStart"]);
            };
        }

        coder function loadedError():void
        {
            if (this.loadErorFunc != null){
                this.loadErorFunc();
            };
        }

        coder function _setupReady_(_arg_1:String):void
        {
            if (this.subFunc != null){
                this.subFunc.apply(null, ["setupReady"]);
            };
            if (this.setupReady != null){
                this.setupReady();
            };
            this.bodyRender(true);
        }

        coder function addEffectRestrict(_arg_1:AvatarRestrict):void
        {
            if (this._effectRestricts == null){
                this._effectRestricts = new Dictionary();
            };
            if (this._effectRestricts[_arg_1.oid] == null){
                this._effectRestricts[_arg_1.oid] = new Dictionary();
            };
            this._effectRestricts[_arg_1.oid][_arg_1.id] = _arg_1;
        }

        coder function addAvatarPart(_arg_1:AvatarParam):void
        {
            if (_arg_1 == null){
                return;
            };
            var _local_2:String = _arg_1.link;
            var _local_3:String = _arg_1.oid;
            var _local_4:String = _local_3.split("_")[0];
            if (_local_3){
                if (_arg_1.type == ItemConst.EFFECT_TYPE){
                    if (this.effectsParts == null){
                        this.effectsParts = new Dictionary();
                    };
                    if (this.effectsParts[_local_2] == null){
                        this.effectsParts[_local_2] = new Dictionary();
                    };
                    this.effectsParts[_local_2][(_arg_1.id + _local_3)] = _arg_1;
                    this.eid_len++;
                } else {
                    if (_local_4 == "mid"){
                        this.mid_id = _local_3;
                    };
                    if (_local_4 == "midm"){
                        this.midm_id = _local_3;
                    };
                    if (_local_4 == "wid"){
                        this.wid_id = _local_3;
                    };
                    if (this.avatarParts == null){
                        this.avatarParts = new Dictionary();
                    };
                    if (this.avatarParts[_local_2] == null){
                        this.avatarParts[_local_2] = new Dictionary();
                    };
                    if (this.avatarParts[_local_2][_local_3]){
                        delete this.avatarParts[_local_2][_local_3];
                    };
                    this.avatarParts[_local_2][_local_3] = _arg_1;
                };
            };
        }

        public function get dir():int
        {
            return (this._dir);
        }

        public function set dir(_arg_1:int):void
        {
            this._dir = _arg_1;
        }

        public function hasAssets(_arg_1:String):Boolean
        {
            var _local_2:Dictionary;
            var _local_3:String;
            for each (_local_2 in this.avatarParts) {
                for (_local_3 in _local_2) {
                    if (_local_3.indexOf(_arg_1) != -1){
                        return (true);
                    };
                };
            };
            for each (_local_2 in this.effectsParts) {
                for (_local_3 in _local_2) {
                    if (_local_3.indexOf(_arg_1) != -1){
                        return (true);
                    };
                };
            };
            return (false);
        }

        override public function dispose():void
        {
            var _local_1:Dictionary;
            var _local_2:AvatarParam;
            var _local_3:AvatarParam;
            this.acce = 1;
            this.assetsIndex = 0;
            this.isDisposed = true;
            this.isFlyMode = false;
            this.hiedBody = false;
            this.hiedWeapon = false;
            this.hiedMount = false;
            this.isAutoDispose = true;
            this.counter = 0;
            this.dir = 0;
            this.lockSpeedValue = 0;
            this._fly_currentFrame = 0;
            this._currentFrame = 0;
            this._isLockSpeed = false;
            this._lockSpeedState = "all";
            this.oldState = "stand";
            this._speed = 0;
            this._totalFrames = 0;
            AvatarManager.coder::getInstance().remove(this.id);
            this.disposeEffectsFunc = null;
            this.clear = null;
            this.onRender = null;
            this.subFunc = null;
            this.playEndFunc = null;
            this.onRendStart = null;
            this.setupReady = null;
            this.loadErorFunc = null;
            this.playEffectFunc = null;
            this.type = null;
            this._state = "stand";
            for each (_local_1 in this.effectsParts) {
                for each (_local_2 in _local_1) {
                    _local_2.dispose();
                    _local_2 = null;
                };
            };
            this.effectsParts = null;
            for each (_local_1 in this.avatarParts) {
                for each (_local_3 in _local_1) {
                    _local_3.dispose();
                    _local_3 = null;
                };
            };
            this._effectRestrict = null;
            this.states = null;
            this.avatarParts = null;
            if (this._currRestrict){
                this._currRestrict.dispose();
            };
            this._currRestrict = null;
            this.mid_id = null;
            this.midm_id = null;
            super.dispose();
        }


    }
}//package com.engine.core.view.items.avatar

