// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.items.avatar.AvatarAssetManager

package com.engine.core.view.items.avatar
{
    import flash.display.BitmapData;
    import com.engine.core.controls.wealth.WealthQuene;
    import flash.utils.Dictionary;
    import com.engine.core.Core;
    import flash.system.LoaderContext;
    import flash.system.ApplicationDomain;
    import flash.system.SecurityDomain;
    import com.engine.core.controls.events.WealthEvent;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import com.engine.namespaces.coder;
    import com.engine.core.model.wealth.WealthGroupVo;
    import com.engine.core.controls.wealth.WealthConstant;
    import com.engine.core.controls.wealth.loader.DisplayLoader;
    import com.engine.core.controls.wealth.WealthPool;
    import __AS3__.vec.Vector;
    import com.engine.core.view.role.MainChar;
    import com.engine.core.view.scenes.Scene;
    import flash.utils.ByteArray;
    import com.engine.core.controls.wealth.loader.BingLoader;
    import flash.geom.Matrix;
    import flash.display.LoaderInfo;
    import com.engine.core.ItemConst;

    public class AvatarAssetManager 
    {

        private static var _instance:AvatarAssetManager;
        public static var shadow:BitmapData;

        private var _quene:WealthQuene;
        public var avatarParams:Dictionary;
        public var bitmapdatas:Dictionary;
        public var elements:Dictionary;
        private var assetsQuene:Array;
        public var assetHash:Array;
        private var oldFrameRate:int;
        private var time:int = 0;
        private var loaderQuene:Array;
        private var bmdQuene:Array;

        public function AvatarAssetManager()
        {
            this.loaderQuene = [];
            this.bmdQuene = [];
            super();
            this.init();
        }

        public static function getInstance():AvatarAssetManager
        {
            if (_instance == null){
                _instance = new (AvatarAssetManager)();
            };
            return (_instance);
        }


        private function init():void
        {
            this.assetsQuene = [];
            this.assetHash = [];
            this.elements = new Dictionary();
            this.avatarParams = new Dictionary();
            this.bitmapdatas = new Dictionary();
            this._quene = new WealthQuene();
            if (false){
                this._quene.loaderContext = new LoaderContext(false);
            } else {
                this._quene.loaderContext = new LoaderContext(false, ApplicationDomain.currentDomain, SecurityDomain.currentDomain);
            };
            this._quene.delay = 10;
            this._quene.addEventListener(WealthEvent.WEALTH_LOADED, this.wealthLoadedFunc);
            this._quene.addEventListener(WealthEvent.WEALTH_ERROR, this.wealthErrorFunc);
            var _local_1:Timer = new Timer(0);
            _local_1.addEventListener(TimerEvent.TIMER, this.enterFrameFunc);
            _local_1.start();
        }

        private function enterFrameFunc(_arg_1:TimerEvent):void
        {
            var _local_2:int;
            var _local_3:Object;
            var _local_4:int;
            var _local_5:int;
            var _local_6:Object;
            var _local_7:String;
            var _local_8:String;
            var _local_9:int;
            var _local_10:Array;
            var _local_11:String;
            var _local_12:Dictionary;
            if ((Core.fps >= 12)){
                _local_2 = 5;
            } else {
                this.time = 20;
            };
            if (((this.loaderQuene.length) && (((Core.delayTime - this.time) > _local_2)))){
                this.time = Core.delayTime;
                _local_3 = this.loaderQuene.shift();
                this.analyze(_local_3.avatarParam, _local_3.loader);
            };
            this.draw();
            if (this.assetsQuene.length > 0){
                _local_4 = this.assetsQuene.length;
                if (Core.fps < 10){
                    if ((this.assetsQuene.length > 20)){
                        _local_4 = (this.assetsQuene.length / 10);
                    } else {
                        _local_4 = 1;
                    };
                } else {
                    if ((_local_4 > 30)){
                        _local_4 = 30;
                    };
                };
                _local_5 = 0;
                while (_local_5 < _local_4) {
                    if (this.assetsQuene.length){
                        _local_6 = this.assetsQuene.shift();
                        _local_7 = _local_6.url;
                        _local_8 = _local_6.owner;
                        _local_9 = _local_6.startTime;
                        _local_10 = _local_7.split("/");
                        _local_11 = _local_10[(_local_10.length - 1)];
                        _local_11 = _local_11.split(".")[0];
                        _local_12 = this.elements[_local_11];
                        if (_local_6.type == 0){
                            AvatarManager.coder::getInstance().loadedAvatar(_local_6.key, _local_11, _local_8, _local_9, _local_12);
                        };
                    };
                    _local_5++;
                };
            };
        }

        private function wealthErrorFunc(_arg_1:WealthEvent):void
        {
            log("saiman", "[ERROR]:", _arg_1.vo.path);
            AvatarManager.coder::getInstance().loadedAvatarError((_arg_1.vo.data.owner as String));
        }

        public function loadAvatarAssets(_arg_1:String, _arg_2:String, _arg_3:String):void
        {
            var _local_4:WealthGroupVo;
            if ((((this.checkLoadedFunc(_arg_1) == false)) && (!((_arg_1 == null))))){
                _local_4 = new WealthGroupVo();
                _local_4.level = WealthConstant.BUBBLE_LEVEL;
                _local_4.addWealth(_arg_1, {"action":_arg_2});
                this._quene.addGroup(_local_4);
                if (this.assetHash.indexOf(_arg_1) == -1){
                    this.assetHash.push(_arg_1);
                };
            } else {
                this.assetsQuene.push({
                    "type":1,
                    "url":_arg_1,
                    "owner":_arg_3,
                    "action":_arg_2
                });
            };
        }

        public function loadAvatar(_arg_1:String, _arg_2:String, _arg_3:String=null):String
        {
            var _local_4:String = Core.coder::nextInstanceIndex().toString();
            log("saiman", "加载动作资源：", _arg_1);
            var _local_5:WealthGroupVo = new WealthGroupVo();
            if (_arg_1.indexOf(".sm") == -1){
                _local_5.level = WealthConstant.BUBBLE_LEVEL;
            };
            var _local_6:Array = _arg_1.split("/");
            var _local_7:String = _local_6[(_local_6.length - 1)];
            _local_6 = _local_7.split(".sm")[0].split("_");
            _local_5.addWealth(_arg_1, {
                "owner":_arg_2,
                "startTime":Core.delayTime,
                "key":_local_4,
                "assetsPath":_arg_3
            });
            this._quene.addGroup(_local_5);
            if (this.assetHash.indexOf(_arg_1) == -1){
                this.assetHash.push(_arg_1);
            };
            return (_local_4);
        }

        public function checkCleanAbled(_arg_1:AvatartParts):Boolean
        {
            var _local_3:String;
            var _local_4:DisplayLoader;
            var _local_5:String;
            var _local_6:Array;
            var _local_7:AvatarParam;
            var _local_2:int;
            while (_local_2 < this.assetHash.length) {
                _local_4 = (WealthPool.getIntance().take(this.assetHash[_local_2]) as DisplayLoader);
                _local_5 = this.assetHash[_local_2];
                _local_6 = _local_5.split("/");
                _local_5 = _local_6[(_local_6.length - 1)];
                _local_5 = _local_5.split(".")[0];
                if (_arg_1.hasAssets(_local_5)){
                    return (false);
                };
                _local_2++;
            };
            for (_local_3 in this.avatarParams) {
                _local_7 = this.avatarParams[_local_3];
                if (_arg_1.hasAssets(_local_7.oid)){
                    return (false);
                };
            };
            return (true);
        }

        public function cleanItems(_arg_1:Vector.<AvatartParts>):void
        {
            var _local_2:AvatartParts;
            var _local_3:Boolean;
            var _local_4:int;
            var _local_6:int;
            var _local_7:String;
            var _local_8:String;
            var _local_9:String;
            var _local_10:DisplayLoader;
            var _local_11:String;
            var _local_12:Array;
            var _local_13:AvatarParam;
            var _local_14:String;
            var _local_15:Array;
            var _local_16:int;
            var _local_17:BitmapData;
            var _local_5:int;
            while (_local_5 < _arg_1.length) {
                _local_2 = _arg_1[_local_5];
                _local_6 = 0;
                while (_local_6 < this.assetHash.length) {
                    _local_10 = (WealthPool.getIntance().take(this.assetHash[_local_6]) as DisplayLoader);
                    _local_11 = this.assetHash[_local_6];
                    _local_12 = _local_11.split("/");
                    _local_11 = _local_12[(_local_12.length - 1)];
                    _local_11 = _local_11.split(".")[0];
                    _local_3 = _local_2.hasAssets(_local_11);
                    if (_local_3){
                        if (_local_10){
                            _local_10.dispose();
                        };
                        _local_10 = null;
                        WealthPool.getIntance().remove(this.assetHash[_local_6]);
                        this.assetHash.splice(_local_6, 1);
                        _local_6--;
                    };
                    _local_6++;
                };
                for (_local_7 in this.avatarParams) {
                    _local_13 = this.avatarParams[_local_7];
                    _local_3 = _local_2.hasAssets(_local_13.oid);
                    if (_local_3){
                        _local_13.dispose();
                        delete this.avatarParams[_local_7];
                    };
                };
                for (_local_8 in this.bitmapdatas) {
                    _local_14 = _local_8.split(Core.SIGN)[0];
                    _local_3 = _local_2.hasAssets(_local_14);
                    if (_local_3){
                        _local_15 = this.bitmapdatas[_local_8];
                        _local_16 = 0;
                        while (_local_16 < _local_15.length) {
                            _local_17 = _local_15[_local_16];
                            if (((_local_17) && (!((_local_17 == Core.shadow_bitmapData))))){
                                _local_17.dispose();
                            };
                            _local_16++;
                        };
                        delete this.bitmapdatas[_local_8];
                    };
                };
                for (_local_9 in this.elements) {
                    _local_3 = _local_2.hasAssets(_local_9);
                    if (_local_3){
                        delete this.elements[_local_9];
                    };
                };
                _local_5++;
            };
        }

        public function clean():void
        {
            var _local_1:MainChar;
            var _local_2:AvatartParts;
            var _local_3:Dictionary;
            var _local_4:Boolean;
            var _local_5:int;
            var _local_6:String;
            var _local_7:String;
            var _local_8:String;
            var _local_9:DisplayLoader;
            var _local_10:String;
            var _local_11:Array;
            var _local_12:AvatartParts;
            var _local_13:AvatarParam;
            var _local_14:String;
            var _local_15:Array;
            var _local_16:int;
            var _local_17:BitmapData;
            if (Scene.scene.mainChar){
                _local_1 = Scene.scene.mainChar;
                _local_3 = AvatarManager.coder::getInstance().avatarHash;
                _local_2 = _local_1.avatarParts;
                _local_5 = 0;
                while (_local_5 < this.assetHash.length) {
                    _local_9 = (WealthPool.getIntance().take(this.assetHash[_local_5]) as DisplayLoader);
                    _local_10 = this.assetHash[_local_5];
                    _local_11 = _local_10.split("/");
                    _local_10 = _local_11[(_local_11.length - 1)];
                    _local_10 = _local_10.split(".")[0];
                    for each (_local_12 in _local_3) {
                        _local_4 = _local_12.hasAssets(_local_10);
                        if (_local_4) break;
                    };
                    if (!_local_4){
                        _local_4 = _local_2.hasAssets(_local_10);
                    };
                    if (!_local_4){
                        if (_local_9){
                            _local_9.dispose();
                        };
                        _local_9 = null;
                        WealthPool.getIntance().remove(this.assetHash[_local_5]);
                        this.assetHash.splice(_local_5, 1);
                        _local_5--;
                    };
                    _local_5++;
                };
                for (_local_6 in this.avatarParams) {
                    _local_13 = this.avatarParams[_local_6];
                    for each (_local_12 in _local_3) {
                        _local_4 = _local_12.hasAssets(_local_13.oid);
                        if (_local_4) break;
                    };
                    if (!_local_4){
                        _local_4 = _local_2.hasAssets(_local_13.oid);
                    };
                    if (!_local_4){
                        _local_13.dispose();
                        delete this.avatarParams[_local_6];
                    };
                };
                for (_local_7 in this.bitmapdatas) {
                    _local_14 = _local_7.split(Core.SIGN)[0];
                    for each (_local_12 in _local_3) {
                        _local_4 = _local_12.hasAssets(_local_14);
                        if (_local_4) break;
                    };
                    if (!_local_4){
                        _local_4 = _local_2.hasAssets(_local_14);
                    };
                    if (!_local_4){
                        _local_15 = this.bitmapdatas[_local_7];
                        _local_16 = 0;
                        while (_local_16 < _local_15.length) {
                            _local_17 = _local_15[_local_16];
                            if (((_local_17) && (!((_local_17 == Core.shadow_bitmapData))))){
                                _local_17.dispose();
                            };
                            _local_16++;
                        };
                        delete this.bitmapdatas[_local_7];
                    };
                };
                for (_local_8 in this.elements) {
                    _local_4 = _local_2.hasAssets(_local_8);
                    for each (_local_12 in _local_3) {
                        _local_4 = _local_12.hasAssets(_local_8);
                        if (_local_4) break;
                    };
                    if (!_local_4){
                        _local_4 = _local_2.hasAssets(_local_8);
                    };
                    if (!_local_4){
                        delete this.elements[_local_8];
                    };
                };
                this.assetsQuene = [];
            };
        }

        public function checkLoadedFunc(_arg_1:String):Boolean
        {
            return (WealthPool.getIntance().has(_arg_1));
        }

        private function wealthLoadedFunc(_arg_1:WealthEvent):void
        {
            var _local_4:Dictionary;
            var _local_6:Dictionary;
            var _local_7:Array;
            var _local_8:String;
            var _local_9:AvatarParam;
            var _local_10:ByteArray;
            var _local_11:int;
            var _local_12:String;
            var _local_13:XML;
            var _local_14:String;
            var _local_2:Array = _arg_1.vo.path.split("/");
            var _local_3:String = _local_2[(_local_2.length - 1)];
            _local_3 = _local_3.split(".")[0];
            var _local_5:Object = WealthPool.getIntance().take(_arg_1.vo.path);
            if ((_local_5 as DisplayLoader)){
                _local_7 = _local_3.split("_");
                _local_8 = _local_7.pop();
                _local_3 = _local_7.join("_");
                if (this.elements[_local_3]){
                    _local_9 = this.elements[_local_3][_local_8];
                    this.loaderQuene.push({
                        "avatarParam":_local_9,
                        "loader":DisplayLoader(_local_5).contentLoaderInfo
                    });
                };
            } else {
                if ((_local_5 as BingLoader)){
                    if (this.elements[_local_3] == null){
                        _local_10 = (BingLoader(_local_5).data as ByteArray);
                        _local_10.position = 0;
                        try {
                            _local_10.uncompress();
                        } catch(e:Error) {
                        };
                        _local_11 = _local_10.readInt();
                        _local_12 = _local_10.readMultiByte(_local_11, "cn-gb");
                        _local_13 = new XML(_local_12);
                        _local_14 = _arg_1.vo.data.assetsPath;
                        _local_4 = this.analyzeData(_local_3, _local_13, _local_14);
                        this.elements[_local_3] = _local_4;
                        _local_14 = _local_14.split(Core.TMP_FILE).join((("_" + CharAction.STAND) + Core.TMP_FILE));
                        this.loadAvatarAssets(_local_14, CharAction.STAND, _arg_1.vo.data.owner);
                        this.loadAvatarAssets(_local_14, CharAction.WALK, _arg_1.vo.data.owner);
                    } else {
                        _local_4 = this.elements[_local_3];
                    };
                    AvatarManager.coder::getInstance().loadedAvatar(_arg_1.vo.data.key, _local_3, (_arg_1.vo.data.owner as String), _arg_1.vo.data.startTime, _local_4);
                };
            };
        }

        private function analyze(avatarParam:AvatarParam, contentLoaderInfo:LoaderInfo):void
        {
            var c:Class;
            var bmd:BitmapData;
            var link:String;
            var frames:int;
            var j:int;
            var id:String;
            var l:int;
            var type:String;
            var num:int;
            var i:int;
            var class_:String;
            var index:int;
            var indexLink:String;
            var bmd_:BitmapData;
            var mat:Matrix;
            try {
                if (((!(avatarParam)) || ((avatarParam.isDisposed == true)))){
                    return;
                };
                frames = avatarParam.frames;
                id = avatarParam.oid;
                l = avatarParam.heights.length;
                type = avatarParam.type;
                num = 8;
                if ((l >= 5)){
                    num = 8;
                } else {
                    num = 1;
                };
                i = 0;
                while (i < num) {
                    link = ((avatarParam.id + Core.SIGN) + avatarParam.bitmapdatas[i]);
                    if (i < 5){
                        j = 0;
                        while (j < frames) {
                            class_ = ((avatarParam.bitmapdatas[i] + ".") + j);
                            c = (contentLoaderInfo.applicationDomain.getDefinition(class_) as Class);
                            bmd = (new (c)() as BitmapData);
                            this.bitmapdatas[link][j] = bmd;
                            j = (j + 1);
                        };
                    } else {
                        index = (8 - i);
                        indexLink = ((((((avatarParam.id + Core.SIGN) + id) + ".") + avatarParam.link) + ".") + index);
                        j = 0;
                        while (j < frames) {
                            bmd_ = this.bitmapdatas[indexLink][j];
                            mat = new Matrix();
                            mat.scale(-1, 1);
                            mat.tx = bmd_.width;
                            bmd = new BitmapData(bmd_.width, bmd_.height, true, 0);
                            this.bitmapdatas[link][j] = bmd;
                            this.bmdQuene.push({
                                "bmd_":bmd_,
                                "bmd":bmd,
                                "mat":mat
                            });
                            j = (j + 1);
                        };
                    };
                    i = (i + 1);
                };
            } catch(e:Error) {
                log("saiman", e.message);
            };
        }

        private function draw():void
        {
            var _local_2:Object;
            var _local_3:BitmapData;
            var _local_4:BitmapData;
            var _local_5:Matrix;
            var _local_1:int = this.bmdQuene.length;
            while (_local_1) {
                if (this.bmdQuene.length){
                    _local_2 = this.bmdQuene.shift();
                    _local_3 = _local_2.bmd;
                    _local_4 = _local_2.bmd_;
                    _local_5 = _local_2.mat;
                    _local_3.draw(_local_4, _local_5, null, null, _local_4.rect);
                };
                _local_1--;
            };
        }

        private function analyzeData(_arg_1:String, _arg_2:XML, _arg_3:String):Dictionary
        {
            var _local_8:AvatarParam;
            var _local_10:XML;
            var _local_11:String;
            var _local_12:XMLList;
            var _local_13:int;
            var _local_14:int;
            var _local_15:String;
            var _local_16:String;
            var _local_17:Class;
            var _local_18:int;
            var _local_19:int;
            var _local_20:Boolean;
            var _local_21:int;
            var _local_22:XML;
            var _local_23:XMLList;
            var _local_24:int;
            var _local_25:int;
            var _local_26:int;
            var _local_27:int;
            var _local_28:int;
            var _local_29:int;
            var _local_30:String;
            var _local_31:int;
            var _local_4:String = _arg_1.split("_")[0];
            var _local_5:Dictionary = new Dictionary();
            var _local_6:XMLList = _arg_2.children();
            var _local_7:int = _local_6.length();
            var _local_9:int;
            while (_local_9 < _local_7) {
                _local_10 = _local_6[_local_9];
                _local_11 = _arg_2.@id;
                _local_8 = new AvatarParam();
                _local_8.assetsPath = _arg_3;
                _local_8.type = _local_4;
                _local_8.link = _local_10.@id;
                _local_8.frames = _local_10.@frames;
                if (_local_4 != ItemConst.EFFECT_TYPE){
                    _local_8.speed = int((int(_local_10.@speed) / Core._Lessen_Frame_));
                } else {
                    _local_8.speed = int(_local_10.@speed);
                };
                _local_8.offset_x = _local_10.@offset_x;
                _local_8.offset_y = _local_10.@offset_y;
                _local_8.replay = int(_local_10.@replay);
                if ((_local_8.replay == 0)){
                    _local_8.replay = -1;
                };
                _local_8.coder::oid = _arg_1;
                _local_8.coder::id = ((_arg_1 + Core.SIGN) + _local_8.link);
                _local_12 = _local_10.children();
                _local_13 = _local_12.length();
                _local_14 = 0;
                _local_19 = 8;
                if ((((_local_4 == ItemConst.EFFECT_TYPE)) || ((_local_4 == ItemConst.MOUNT_TYPE)))){
                    if ((_local_13 >= 5)){
                        _local_19 = 8;
                    } else {
                        _local_19 = 1;
                    };
                };
                _local_20 = false;
                if (((!((_local_4 == ItemConst.EFFECT_TYPE))) && ((_local_13 == 1)))){
                    _local_20 = true;
                };
                _local_14 = 0;
                while (_local_14 < _local_19) {
                    if (_local_14 < 5){
                        if (_local_20){
                            _local_22 = _local_12[0];
                            _local_21 = _local_14;
                        } else {
                            _local_22 = _local_12[_local_14];
                            _local_21 = _local_14;
                        };
                        _local_8.txs[_local_21] = [];
                        _local_8.tys[_local_21] = [];
                        _local_8.widths[_local_21] = [];
                        _local_8.heights[_local_21] = [];
                        if (!_local_20){
                            _local_8.bitmapdatas[_local_21] = ((((_local_11 + ".") + _local_8.link) + ".") + _local_21);
                            _local_15 = ((((((_local_8.id + Core.SIGN) + _local_11) + ".") + _local_8.link) + ".") + _local_21);
                        } else {
                            _local_8.bitmapdatas[_local_21] = ((((_local_11 + ".") + _local_8.link) + ".") + 0);
                            _local_15 = ((((((_local_8.id + Core.SIGN) + _local_11) + ".") + _local_8.link) + ".") + 0);
                        };
                        if (this.bitmapdatas.hasOwnProperty(_local_15) == false){
                            _local_23 = _local_22.children();
                            if (_local_23.length() == 0){
                                log("saiman", "资源配置文件格式不符合要求");
                                return (new Dictionary());
                            };
                            if (this.bitmapdatas[_local_15] == null){
                                this.bitmapdatas[_local_15] = [];
                            };
                            _local_24 = _local_23.length();
                            if (_local_24 > _local_8.frames){
                                _local_8.frames = _local_24;
                            };
                            _local_18 = 0;
                            while (_local_18 < _local_8.frames) {
                                if (_local_18 < _local_24){
                                    _local_16 = ((((((_local_11 + ".") + _local_8.link) + ".") + _local_21) + ".") + _local_18);
                                    _local_8.txs[_local_21].push(int(_local_23[_local_18].@tx[0]));
                                    _local_8.tys[_local_21].push(int(_local_23[_local_18].@ty[0]));
                                    _local_25 = int(_local_23[_local_18].@width[0]);
                                    if (_local_25 == 0){
                                        _local_25 = int(_local_23[_local_18].@w[0]);
                                    };
                                    _local_26 = int(_local_23[_local_18].@height[0]);
                                    if (_local_26 == 0){
                                        _local_26 = int(_local_23[_local_18].@h[0]);
                                    };
                                    _local_8.widths[_local_21].push(_local_25);
                                    _local_8.heights[_local_21].push(_local_26);
                                };
                                _local_18++;
                            };
                        };
                    } else {
                        _local_21 = _local_14;
                        _local_27 = (8 - _local_21);
                        _local_8.txs[_local_21] = [];
                        _local_28 = 0;
                        while (_local_28 < _local_8.widths[_local_27].length) {
                            _local_29 = (_local_8.widths[_local_27][_local_28] - _local_8.txs[_local_27][_local_28]);
                            _local_8.txs[_local_21].push(_local_29);
                            _local_28++;
                        };
                        _local_8.tys[_local_21] = _local_8.tys[_local_27];
                        _local_8.widths[_local_21] = _local_8.widths[_local_27];
                        _local_8.heights[_local_21] = _local_8.heights[_local_27];
                        if (!_local_20){
                            _local_8.bitmapdatas[_local_21] = ((((_local_11 + ".") + _local_8.link) + ".") + _local_21);
                            _local_15 = ((((((_local_8.id + Core.SIGN) + _local_11) + ".") + _local_8.link) + ".") + _local_21);
                        } else {
                            _local_8.bitmapdatas[_local_21] = ((((_local_11 + ".") + _local_8.link) + ".") + 0);
                            _local_15 = ((((((_local_8.id + Core.SIGN) + _local_11) + ".") + _local_8.link) + ".") + 0);
                        };
                        if (this.bitmapdatas.hasOwnProperty(_local_15) == false){
                            _local_30 = ((((((_local_8.id + Core.SIGN) + _local_11) + ".") + _local_8.link) + ".") + _local_27);
                            if (this.bitmapdatas[_local_15] == null){
                                this.bitmapdatas[_local_15] = [];
                            };
                            _local_31 = 0;
                            while (_local_31 < this.bitmapdatas[_local_30].length) {
                                if ((_local_4 == ItemConst.BODY_TYPE)){
                                    this.bitmapdatas[_local_15].push(Core.shadow_bitmapData);
                                } else {
                                    this.bitmapdatas[_local_15].push(null);
                                };
                                _local_31++;
                            };
                        };
                    };
                    _local_14++;
                };
                if (this.avatarParams.hasOwnProperty(_local_8.id) == false){
                    this.avatarParams[_local_8.id] = _local_8;
                    _local_5[_local_8.link] = _local_8;
                };
                _local_9++;
            };
            return (_local_5);
        }


    }
}//package com.engine.core.view.items.avatar

