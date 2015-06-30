package com.engine.core.controls.wealth
{
    import com.engine.core.Core;
    import com.engine.core.controls.events.WealthEvent;
    import com.engine.core.controls.events.WealthProgressEvent;
    import com.engine.core.controls.wealth.loader.BingLoader;
    import com.engine.core.controls.wealth.loader.DisplayLoader;
    import com.engine.core.controls.wealth.loader.ILoader;
    import com.engine.core.model.IProto;
    import com.engine.core.model.Proto;
    import com.engine.core.model.wealth.WealthGroupVo;
    import com.engine.core.model.wealth.WealthVo;
    import com.engine.namespaces.coder;
    
    import flash.events.EventDispatcher;
    import flash.events.ProgressEvent;
    import flash.events.TimerEvent;
    import flash.system.LoaderContext;
    import flash.utils.Dictionary;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    public class WealthQuene extends EventDispatcher implements IProto 
    {

        public static var speed:int;
		
        private static var time:int = 0;
        private static var bytesSpeed:int = 0;

        public var loaderContext:LoaderContext;
        public var limitIndex:int = 2;
		
        private var _proto:Object;
        private var _id:String;
        private var _oid:String;
        private var _groupHash:Dictionary;
        private var _priorityHash:Vector.<WealthGroupVo>;
        private var _bubbleHash:Vector.<WealthGroupVo>;
        private var _loaders:Dictionary;
        private var _isDispose:Boolean;
        private var timer:Timer;
        private var deayTime:int;
        private var priorityLevel:int;
        private var durtime:int;

        public function WealthQuene()
        {
            this.setUp();
        }
		
        public static function getSpeedStr():String
        {
            var _local_1 = "";
            if (speed > 0){
                _local_1 = (speed + " KB/s");
                if (speed > 0x0400){
                    _local_1 = (int((speed / 0x0400)) + " M/s");
                };
                return (_local_1);
            };
            return ("0 Kb/s");
        }


        public function setUp():void
        {
            this._isDispose = false;
            this._id = (Core.SIGN + Core.coder::nextInstanceIndex().toString(16));
            WealthManager.getIntance().addQuene(this);
            this._priorityHash = new Vector.<WealthGroupVo>(0);
            this._bubbleHash = new Vector.<WealthGroupVo>(0);
            this._loaders = new Dictionary();
            this._groupHash = new Dictionary();
            this.timer = new Timer(0);
            this.timer.addEventListener(TimerEvent.TIMER, this.enterFrameFunc);
            this.timer.start();
        }

        public function set delay(_arg_1:uint):void
        {
            this.timer.delay = _arg_1;
        }

        private function enterFrameFunc(... _args):void
        {
            var _local_2:int;
            if (Core.fps < 3){
                _local_2 = 100;
            };
            if ((getTimer() - this.deayTime) > _local_2){
                this.deayTime = getTimer();
                this.load();
            };
        }

        public function addGroup(_arg_1:WealthGroupVo):void
        {
            if ((((_arg_1.id == null)) || ((_arg_1 == null)))){
                return;
            };
            _arg_1.coder::oid = this.id;
            if ((this._groupHash[_arg_1.id] == null)){
                this._groupHash[_arg_1.id] = _arg_1;
            };
            if (_arg_1.level == WealthConstant.PRIORITY_LEVEL){
                this._priorityHash.push(_arg_1);
                this.priorityLevel = 0;
                this.priorityLoad();
            } else {
                this._bubbleHash.push(_arg_1);
                this.bubbleLoad();
            };
        }

        public function takeGroup(_arg_1:String):WealthGroupVo
        {
            return ((this._groupHash[_arg_1] as WealthGroupVo));
        }

        public function removeGroup(_arg_1:String):void
        {
            var _local_2:WealthGroupVo;
            var _local_3:int;
            var _local_4:int;
            if (this._isDispose){
                return;
            };
            if (this._groupHash[_arg_1]){
                _local_2 = this._groupHash[_arg_1];
                delete this._groupHash[_arg_1];
                _local_3 = 0;
                if (_local_2.level == WealthConstant.BUBBLE_LEVEL){
                    _local_4 = this._bubbleHash.length;
                    _local_3 = 0;
                    while (_local_3 < _local_4) {
                        if (this._bubbleHash[_local_3] == _local_2){
                            var _local_5 = WealthManager.getIntance();
                            (_local_5.coder::removeGroupRequest(_local_2));
                            this._bubbleHash.splice(_local_3, 1);
                            break;
                        };
                        _local_3++;
                    };
                } else {
                    _local_4 = this._priorityHash.length;
                    _local_3 = 0;
                    while (_local_3 < _local_4) {
                        if (this._priorityHash[_local_3] == _local_2){
                            _local_5 = WealthManager.getIntance();
                            (_local_5.coder::removeGroupRequest(_local_2));
                            this._priorityHash.splice(_local_3, 1);
                            return;
                        };
                        _local_3++;
                    };
                };
            };
        }

        private function load():void
        {
            if (this._isDispose){
                return;
            };
            if (this._bubbleHash.length > 0){
                this.bubbleLoad();
            };
            if (this._priorityHash.length > 0){
                this.priorityLevel = 0;
                this.priorityLoad();
            };
        }

        public function priorityLoad():void
        {
            var _local_1:int;
            var _local_2:WealthVo;
            var _local_3:WealthGroupVo;
            if (this._isDispose){
                return;
            };
            if (this._priorityHash.length > 0){
                _local_1 = 0;
                while (_local_1 < this.limitIndex) {
                    _local_2 = this.getNextWealth(this._priorityHash);
                    if (_local_2){
                        _local_3 = this._groupHash[_local_2.oid];
                        if (this.hasCatch(_local_2.path)){
                            _local_2.coder::loaded = true;
                            this.dispatchWealthEvent(WealthEvent.WEALTH_LOADED, _local_2);
                            this.limitIndex = (this.limitIndex + 1);
                            _local_3.checkFinish();
                            if (((_local_3.loaded) && ((_local_3.lock == false)))){
                                this.removeGroup(_local_2.oid);
                                this.dispatchWealthEvent(WealthEvent.WEALTH_GROUP_LOADED, _local_2);
                                if (this.priorityLevel < 100){
                                    this.priorityLoad();
                                    this.priorityLevel++;
                                };
                            };
                        } else {
                            this.loadElemt(_local_2, this.priorityLoadedFunc, this.priorityErrorFunc, this.priorityProFunc);
                        };
                        if ((limitIndex > 0)){
                            limitIndex--;
                        };
                        _local_1--;
                    };
                    _local_1++;
                };
            };
        }

        public function removeLoader(_arg_1:String):ILoader
        {
            if (this._isDispose){
                return (null);
            };
            var _local_2:ILoader = this._loaders[_arg_1];
            delete this._loaders[_arg_1];
            return (_local_2);
        }

        public function takeLoader(_arg_1:String):ILoader
        {
            return (this._loaders[_arg_1]);
        }

        private function priorityLoadedFunc(_arg_1:WealthVo):void
        {
            this.removeLoader(_arg_1.path);
            var _local_2 = WealthManager.getIntance();
            (_local_2.coder::callSuccess(_arg_1.path, false));
        }

        private function priorityErrorFunc(_arg_1:WealthVo):void
        {
            log("saiman", "加载失败：", _arg_1);
            this.removeLoader(_arg_1.path);
            var _local_2 = WealthManager.getIntance();
            (_local_2.coder::callError(_arg_1.path, false));
        }

        private function priorityProFunc(_arg_1:ProgressEvent, _arg_2:WealthVo):void
        {
            var _local_3 = WealthManager.getIntance();
            (_local_3.coder::proFunc(_arg_2.path, _arg_1));
        }

        public function bubbleLoad():void
        {
            var _local_2:WealthGroupVo;
            if (this._isDispose){
                return;
            };
            var _local_1:WealthVo = this.getNextWealth(this._bubbleHash);
            if (_local_1){
                _local_2 = this._groupHash[_local_1.oid];
                if (this.hasCatch(_local_1.path)){
                    _local_1.coder::loaded = true;
                    this.dispatchWealthEvent(WealthEvent.WEALTH_LOADED, _local_1);
                    _local_2.checkFinish();
                    if (((_local_2.loaded) && ((_local_2.lock == false)))){
                        this.removeGroup(_local_1.oid);
                        this.dispatchWealthEvent(WealthEvent.WEALTH_GROUP_LOADED, _local_1);
                        this.bubbleLoad();
                    };
                } else {
                    this.loadElemt(_local_1, this.bubbleLoadedFunc, this.bubbleErrorFunc, this.bubbleProFunc);
                };
            };
        }

        private function bubbleLoadedFunc(_arg_1:WealthVo):void
        {
            this.removeLoader(_arg_1.path);
            var _local_2 = WealthManager.getIntance();
            (_local_2.coder::callSuccess(_arg_1.path, true));
        }

        private function bubbleErrorFunc(_arg_1:WealthVo):void
        {
            if (((!(_arg_1)) || (!(_arg_1.path)))){
                this.bubbleLoad();
                return;
            };
            if (_arg_1.path){
                this.removeLoader(_arg_1.path);
                var _local_3 = WealthManager.getIntance();
                (_local_3.coder::callError(_arg_1.path, true));
            };
            var _local_2:WealthGroupVo = this._groupHash[_arg_1.oid];
            if (_local_2){
                _local_2.checkFinish();
                if (((_local_2.loaded) && ((_local_2.lock == false)))){
                    this.removeGroup(_arg_1.oid);
                    this.dispatchWealthEvent(WealthEvent.WEALTH_GROUP_LOADED, _arg_1);
                    this.bubbleLoad();
                };
            };
        }

        private function bubbleProFunc(_arg_1:ProgressEvent, _arg_2:WealthVo):void
        {
            this.dispatchWealthProgressEvent(WealthProgressEvent.Progress, _arg_1, _arg_2);
        }

        private function hasCatch(_arg_1:String):Boolean
        {
            if (WealthPool.getIntance().has(_arg_1)){
                return (true);
            };
            return (false);
        }

        private function loadElemt(_arg_1:WealthVo, _arg_2:Function, _arg_3:Function, _arg_4:Function):void
        {
            var _local_6:DisplayLoader;
            var _local_7:DisplayLoader;
            var _local_8:BingLoader;
            if (this._isDispose){
                return;
            };
            if ((((_arg_1.path == null)) || ((_arg_1 == null)))){
                return;
            };
            _arg_1.coder::lock = true;
            var _local_5:String = _arg_1.type;
            if (_local_5 == null){
                throw (new Error("资源地址不能为空"));
            };
            if (WealthManager.getIntance().hasRequest(_arg_1.path) == false){
                bytesSpeed = 0;
                time = 0;
                if (_local_5 == WealthConstant.SWF_WEALTH){
                    _local_6 = new DisplayLoader();
                    _local_6.loadElemt(_arg_1, _arg_2, _arg_3, _arg_4, this.loaderContext);
                    this._loaders[_arg_1.path] = _local_6;
                } else {
                    if (_local_5 == WealthConstant.IMG_WEALTH){
                        _local_7 = new DisplayLoader();
                        _local_7.loadElemt(_arg_1, _arg_2, _arg_3, _arg_4, this.loaderContext);
                        this._loaders[_arg_1.path] = _local_7;
                    } else {
                        if (_local_5 == WealthConstant.BING_WEALTH){
                            _local_8 = new BingLoader();
                            _local_8.loadElemt(_arg_1, _arg_2, _arg_3, _arg_4, this.loaderContext);
                            this._loaders[_arg_1.path] = _local_8;
                        };
                    };
                };
            };
            WealthManager.getIntance().addRequest(_arg_1.path, _arg_1.id, this.id);
        }

        public function cancleGroup(gid:String):void
        {
            var group:WealthGroupVo;
            var values:Vector.<WealthVo>;
            var i:int;
            var vo:WealthVo;
            var loader:ILoader;
            try {
                if (this._isDispose){
                    return;
                };
                group = this._groupHash[gid];
                if (group){
                    values = group.coder::values();
                    i = 0;
                    while (i < values.length) {
                        vo = values[i];
                        if (WealthManager.getIntance().takeRequestLength(vo.path) == 1){
                            loader = this.removeLoader(vo.path);
                            if (loader){
                                if (WealthPool.getIntance().has(vo.path) == false){
                                    loader.unloadAndStop();
                                };
                                this.limitIndex = 3;
                            };
                        };
                        i = (i + 1);
                    };
                    if (group.lock == false){
                        this.removeGroup(group.id);
                        group.dispose();
                    };
                    group.coder::$lock = true;
                    group.coder::loaded = true;
                };
            } catch(e:Error) {
                throw (e);
            };
        }

        private function getNextWealth(_arg_1:Vector.<WealthGroupVo>):WealthVo
        {
            var _local_2:WealthGroupVo;
            var _local_3:WealthVo;
            var _local_4:int = _arg_1.length;
            var _local_5:int;
            while (_local_5 < _local_4) {
                _local_2 = _arg_1[_local_5];
                if (_local_2){
                    if (_local_2.loaded == false){
                        _local_3 = _local_2.getNextWealth();
                        if (((_local_3) && (_local_3.path))){
                            return (_local_3);
                        };
                    };
                };
                _local_5++;
            };
            return (null);
        }

        public function dispatchWealthEvent(_arg_1:String, _arg_2:WealthVo):void
        {
            var _local_3:WealthEvent = new WealthEvent(_arg_1);
            _local_3.vo = new WealthVo();
            _local_3.vo.setUp(_arg_2.path, _arg_2.data, _arg_2.oid);
            _local_3.vo.coder::id = _arg_2.id;
            _local_3.vo.coder::loaded = _arg_2.loaded;
            _local_3.vo.coder::$index = _arg_2.index;
            _local_3.vo.proto = _arg_2.proto;
            _local_3.vo.coder::lock = _arg_2.lock;
            var _local_4:WealthGroupVo = this.takeGroup(_arg_2.oid);
            if (_local_4){
                _local_3.loadedIndex = _local_4.loadedIndex;
                _local_3.total_loadeIndex = _local_4.length;
                _local_3.group_name = _local_4.name;
            };
            this.dispatchEvent(_local_3);
        }

        public function dispatchWealthProgressEvent(_arg_1:String, _arg_2:ProgressEvent, _arg_3:WealthVo):void
        {
            if (time == 0){
                time = getTimer();
            };
            var _local_4:Number = (getTimer() - time);
            if ((_local_4 == 0)){
                _local_4 = 1;
            };
            bytesSpeed = (_arg_2.bytesLoaded - bytesSpeed);
            speed = ((bytesSpeed / 0x0400) / (_local_4 / 1000));
            time = getTimer();
            bytesSpeed = _arg_2.bytesLoaded;
            var _local_5:WealthProgressEvent = new WealthProgressEvent(_arg_1, false, false, _arg_2.bytesLoaded, _arg_2.bytesTotal);
            _local_5.path = _arg_3.path;
            _local_5.wealth_gid = _arg_3.oid;
            _local_5.wealth_id = _arg_3.id;
            _local_5.loadedIndex = _arg_3.loadIndex;
            _local_5.totlaIndex = _arg_3.index;
            var _local_6:WealthGroupVo = this.takeGroup(_arg_3.oid);
            _local_5.vo = _arg_3;
            _local_5.loadedIndex = _local_6.loadedIndex;
            _local_5.totlaIndex = _local_6.length;
            _local_5.group_name = _local_6.name;
            this.dispatchEvent(_local_5);
        }

        public function get id():String
        {
            return (this._id);
        }

        public function set proto(_arg_1:Object):void
        {
            this._proto = _arg_1;
        }

        public function get proto():Object
        {
            return (this._proto);
        }

        public function get oid():String
        {
            return (this._oid);
        }

        public function clone():IProto
        {
            if (this._isDispose){
                return (null);
            };
            var _local_1:Proto = new Proto();
            _local_1.coder::id = this.id;
            _local_1.coder::oid = this.oid;
            _local_1.proto = this.proto;
            return (_local_1);
        }

        public function dispose():void
        {
            var _local_1:WealthGroupVo;
            for each (_local_1 in this._groupHash) {
                this.cancleGroup(_local_1.id);
            };
            WealthManager.getIntance().removeQuene(this.id);
            this._id = null;
            this._oid = null;
            this.proto = null;
            this._groupHash = null;
            this._loaders = null;
            this._priorityHash = null;
            this._bubbleHash = null;
            if (this.timer){
                this.timer.stop();
            };
            this._isDispose = true;
        }


    }
}//package com.engine.core.controls.wealth

