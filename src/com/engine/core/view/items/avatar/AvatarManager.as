package com.engine.core.view.items.avatar
{
    import com.engine.core.Core;
    import com.engine.core.controls.elisor.Elisor;
    import com.engine.core.view.base.BaseShape;
    import com.engine.core.view.role.MainChar;
    import com.engine.core.view.scenes.Scene;
    import com.engine.core.view.scenes.SceneConstant;
    import com.engine.namespaces.coder;
    
    import flash.events.Event;
    import flash.utils.Dictionary;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    public class AvatarManager extends BaseShape 
    {

        private static var _instance:AvatarManager;

        private var hash:Dictionary;
        public var hashArray:Array;
        public var avatarHash:Dictionary;
        private var elisor:Elisor;
        private var _avatarParams_:Array;
        private var lex:int;
        private var timer_1:Timer;
        private var avatars_lengh:int;
        private var effects_length:int;
        private var onceTime:Number;
        private var lastHandleTimer:int = 0;
        private var time:int = 0;
        private var num:int = 2;
        private var tmpIndex:int = 0;

        public function AvatarManager()
        {
            this.hash = new Dictionary();
            this.hashArray = [];
            this.avatarHash = new Dictionary();
            this.elisor = Elisor.getInstance();
            this._avatarParams_ = [];
            this.onceTime = Math.ceil((1000 / 30));
            super();
            addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
        }

        coder static function getInstance():AvatarManager
        {
            if (_instance == null){
                _instance = new (AvatarManager)();
            };
            return (_instance);
        }


        private function onEnterFrame(_arg_1:Event):void
        {
            var _local_3:int;
            Core.totalAvatarAssetsIndex = this.avatars_lengh;
            Core.totalEffectAssetsIndex = this.effects_length;
            var _local_2:int = (getTimer() - this.lastHandleTimer);
            Core.handleCount = Math.ceil((_local_2 / this.onceTime));
            if ((Core.fps > 10)){
                _local_3 = Core.handleCount;
            } else {
                _local_3 = 1;
            };
            if (Core.fps <= 3){
                _local_3 = Core.handleCount;
            };
            while (_local_3 > 0) {
                this.onRenderFunc(_arg_1);
                _local_3--;
            };
            _local_3 = Core.handleCount;
            while (_local_3 > 0) {
                this.onRenderFunc2(_arg_1);
                _local_3--;
            };
            this.lastHandleTimer = getTimer();
        }

        public function clean():void
        {
            var _local_1:MainChar;
            var _local_2:AvatartParts;
            var _local_3:AvatartParts;
            var _local_4:int;
            var _local_5:String;
            var _local_6:String;
            if (Scene.scene.mainChar){
                _local_1 = Scene.scene.mainChar;
                _local_2 = _local_1.avatarParts;
                _local_4 = 0;
                while (_local_4 < this.hashArray.length) {
                    _local_3 = this.hashArray[_local_4];
                    if (((!((_local_3 == _local_2))) && (_local_3.isAutoDispose))){
                        this.hashArray.splice(_local_4, 1);
                        _local_4--;
                    };
                    _local_4++;
                };
                for (_local_5 in this.hash) {
                    _local_3 = this.hash[_local_5];
                    if (((!((_local_3 == _local_2))) && (_local_3.isAutoDispose))){
                        delete this.hash[_local_5];
                    };
                };
                for (_local_6 in this.avatarHash) {
                    _local_3 = this.avatarHash[_local_6];
                    if (((!((_local_3 == _local_2))) && (_local_3.isAutoDispose))){
                        _local_3.dispose();
                        delete this.avatarHash[_local_6];
                    };
                };
                this._avatarParams_ = [];
            };
        }

        private function onRenderFunc(... _args):void
        {
            var _local_3:int;
            var _local_4:int;
            var _local_5:Object;
            Core.delayTime = getTimer();
            if (((Scene.scene) && (Scene.scene.mainChar))){
                if (Scene.scene.mainChar.runing == false){
                    this.num = 2;
                } else {
                    this.num = 7;
                };
            } else {
                this.num = 2;
            };
            if ((this.num > int.MAX_VALUE)){
                this.num = 0;
            };
            var _local_2:int = (this.lex % this.num);
            if (this.hashArray.length){
                this.avatars_lengh = this.hashArray.length;
                if ((this.hashArray.length < 30)){
                    _local_3 = 30;
                } else {
                    _local_3 = int((this.hashArray.length * 0.8));
                };
                _local_4 = 0;
                while (_local_4 < _local_3) {
                    if (this.tmpIndex >= this.hashArray.length){
                        this.tmpIndex = 0;
                    };
                    _local_5 = this.hashArray[this.tmpIndex];
                    if (_local_5.type == SceneConstant.CHAR){
                        _local_5.bodyRender();
                        _local_5.effectRender();
                    } else {
                        if (_local_2 == 0){
                            _local_5.bodyRender();
                            _local_5.effectRender();
                        };
                    };
                    this.tmpIndex++;
                    _local_4++;
                };
            };
            this.lex++;
        }

        private function onRenderFunc2(... _args):void
        {
            var _local_2:AvatartParts;
            this.effects_length = 0;
            for each (_local_2 in this.avatarHash) {
                _local_2.effectRender();
                _local_2.bodyRender();
                this.effects_length++;
            };
        }

        public function put(_arg_1:AvatartParts):void
        {
            if (_arg_1){
                if (_arg_1.type == SceneConstant.EFFECT){
                    if (this.hash[_arg_1.id] == null){
                        this.hash[_arg_1.id] = _arg_1;
                    };
                } else {
                    if (this.hashArray.indexOf(_arg_1) == -1){
                        this.hashArray.push(_arg_1);
                    };
                };
                if (this.avatarHash[_arg_1.id] == null){
                    this.avatarHash[_arg_1.id] = _arg_1;
                };
            };
        }

        public function remove(_arg_1:String):void
        {
            var _local_2:int;
            if (this.hash[_arg_1]){
                delete this.hash[_arg_1];
            } else {
                _local_2 = this.hashArray.indexOf(this.avatarHash[_arg_1]);
                if (_local_2 != -1){
                    this.hashArray.splice(_local_2, 1);
                };
            };
            if (this.avatarHash[_arg_1]){
                delete this.avatarHash[_arg_1];
            };
        }

        public function take(_arg_1:String):AvatartParts
        {
            return (this.avatarHash[_arg_1]);
        }

        private function _loadedAvatar_():void
        {
            var _local_1:Object;
            var _local_2:String;
            var _local_3:String;
            var _local_4:Dictionary;
            var _local_5:AvatartParts;
            var _local_6:AvatarParam;
            var _local_7:AvatarParam;
            if (this._avatarParams_.length){
                _local_1 = this._avatarParams_.shift();
                _local_2 = _local_1.key;
                _local_3 = _local_1.avatarParts_id;
                _local_4 = _local_1.avatarParams;
                _local_5 = (this.avatarHash[_local_3] as AvatartParts);
                if (_local_5){
                    var _local_8 = _local_5;
                    (_local_8.coder::setupStart(_local_2));
                    for each (_local_6 in _local_4) {
                        _local_7 = (_local_6.coder::clone() as AvatarParam);
                        _local_7.coder::assets_id = _local_1.assets_id;
                        _local_7.startPlayTime = _local_1.startTime;
                        var _local_10 = _local_5;
                        (_local_10.coder::addAvatarPart(_local_7));
                    };
                    _local_8 = _local_5;
                    (_local_8.coder::setupReady(_local_2));
                };
                _local_4 = null;
            };
        }

        public function updataAvatar(_arg_1:String, _arg_2:String, _arg_3:Dictionary):void
        {
        }

        public function loadedAvatarError(_arg_1:String):void
        {
            var _local_2:AvatartParts = (this.avatarHash[_arg_1] as AvatartParts);
            if (_local_2){
                var _local_3 = _local_2;
                (_local_3.coder::loadedError());
            };
        }

        public function loadedAvatar(_arg_1:String, _arg_2:String, _arg_3:String, _arg_4:int, _arg_5:Dictionary):void
        {
            this._avatarParams_.push({
                "assets_id":_arg_1,
                "key":_arg_2,
                "avatarParts_id":_arg_3,
                "startTime":_arg_4,
                "avatarParams":_arg_5
            });
            this._loadedAvatar_();
        }


    }
}//package com.engine.core.view.items.avatar

