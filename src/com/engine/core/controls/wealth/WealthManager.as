package com.engine.core.controls.wealth
{
    import com.engine.core.Core;
    import com.engine.core.controls.events.WealthEvent;
    import com.engine.core.controls.events.WealthProgressEvent;
    import com.engine.core.model.wealth.WealthGroupVo;
    import com.engine.core.model.wealth.WealthVo;
    import com.engine.namespaces.coder;
    import com.engine.utils.Hash;
    
    import flash.events.ProgressEvent;
    import flash.utils.Dictionary;

    public class WealthManager 
    {

        private static var _intance:WealthManager;

        private var _hash:Hash;
        private var _requestHash:Dictionary;

        public function WealthManager()
        {
            this._requestHash = new Dictionary();
            this._hash = new Hash();
        }

        public static function getIntance():WealthManager
        {
            if (_intance == null){
                _intance = new (WealthManager)();
            };
            return (_intance);
        }


        public function addQuene(_arg_1:WealthQuene):void
        {
            this._hash.put(_arg_1.id, _arg_1);
        }

        public function takeQuene(_arg_1:String):WealthQuene
        {
            return ((this._hash.take(_arg_1) as WealthQuene));
        }

        public function removeQuene(_arg_1:String):void
        {
            this._hash.remove(_arg_1);
        }

        public function addRequest(_arg_1:String, _arg_2:String, _arg_3:String):void
        {
            if (_arg_1 == null){
                return;
            };
            if (this._requestHash[_arg_1] == null){
                this._requestHash[_arg_1] = new Dictionary();
            };
            this._requestHash[_arg_1][_arg_2] = {
                "oid":_arg_2,
                "qid":_arg_3,
                "path":_arg_1
            };
        }

        public function hasRequest(_arg_1:String):Boolean
        {
            var _local_2:String;
            if (this._requestHash[_arg_1] == null){
                return (false);
            };
            for each (_local_2 in this._requestHash[_arg_1]) {
                return (true);
            };
            return (false);
        }

        public function takeRequestLength(_arg_1:String):int
        {
            var _local_3:String;
            var _local_2:int;
            for each (_local_3 in this._requestHash[_arg_1]) {
                _local_2++;
            };
            return (_local_2);
        }

        public function removeRequest(_arg_1:String, _arg_2:String):void
        {
            var _local_3:String;
            if ((((this._requestHash[_arg_1][_arg_2] == null)) || ((this._requestHash[_arg_1] == null)))){
                return;
            };
            delete this._requestHash[_arg_1][_arg_2];
            for each (_local_3 in this._requestHash[_arg_1]) {
                return;
            };
            delete this._requestHash[_arg_1];
        }

        coder function callSuccess(_arg_1:String, _arg_2:Boolean):void
        {
            var _local_4:Object;
            var _local_5:WealthQuene;
            var _local_6:String;
            var _local_7:WealthGroupVo;
            var _local_8:WealthVo;
            var _local_3:Dictionary = this._requestHash[_arg_1];
            for each (_local_4 in _local_3) {
                _local_5 = (this._hash.take(_local_4.qid) as WealthQuene);
                _local_6 = _local_4.oid.split((_local_4.path + Core.SIGN))[1];
                _local_7 = _local_5.takeGroup(_local_6);
                _local_8 = _local_7.take(_local_4.oid);
                if (_local_8){
                    _local_8.coder::loaded = true;
                };
                if (_local_7.lock){
                    _local_5.removeGroup(_local_7.id);
                    _local_7.dispose();
                    _local_7 = null;
                    break;
                };
                if (_arg_2 == false){
                    _local_5.coder::limitIndex = (_local_5.coder::limitIndex + 1);
                };
                if (_local_7.lock == false){
                    _local_7.checkFinish();
                };
                _local_5.dispatchWealthEvent(WealthEvent.WEALTH_LOADED, _local_8);
                if (_local_7.loaded){
                    if (_local_7.lock == false){
                        _local_5.removeGroup(_local_8.oid);
                        _local_5.dispatchWealthEvent(WealthEvent.WEALTH_GROUP_LOADED, _local_8);
                    };
                };
            };
            delete this._requestHash[_local_8.path];
        }

        coder function callError(_arg_1:String, _arg_2:Boolean):void
        {
            var _local_4:Object;
            var _local_5:int;
            var _local_6:WealthQuene;
            var _local_7:String;
            var _local_8:WealthGroupVo;
            var _local_9:WealthVo;
            var _local_3:Array = [];
            for each (_local_4 in this._requestHash[_arg_1]) {
                _local_3.push(_local_4);
            };
            _local_5 = 0;
            while (_local_5 < _local_3.length) {
                _local_4 = _local_3[_local_5];
                _local_6 = (this._hash.take(_local_4.qid) as WealthQuene);
                _local_7 = _local_4.oid.split((_local_4.path + Core.SIGN))[1];
                if (_local_6 == null) break;
                _local_8 = _local_6.takeGroup(_local_7);
                if (_local_8 == null) break;
                _local_9 = _local_8.take(_local_4.oid);
                if (_local_9 == null) break;
                delete this._requestHash[_arg_1][_local_9.id];
                if ((_arg_2 == false)){
                    _local_6.coder::limitIndex = (_local_6.coder::limitIndex + 1);
                };
                if (_local_9.loadIndex > 0){
                    _local_9.loadIndex--;
                    _local_9.coder::lock = false;
                } else {
                    if (_local_9){
                        _local_9.coder::loaded = true;
                    };
                    if (_local_8.lock){
                        _local_6.removeGroup(_local_8.id);
                        _local_8.dispose();
                        return;
                    };
                    _local_6.dispatchWealthEvent(WealthEvent.WEALTH_ERROR, _local_9);
                    if (_local_8.lock == false){
                        _local_8.checkFinish();
                    };
                    if (_local_8.loaded){
                        if (_local_8.lock == false){
                            _local_6.removeGroup(_local_9.oid);
                            _local_6.dispatchWealthEvent(WealthEvent.WEALTH_GROUP_LOADED, _local_9);
                        };
                    };
                };
                _local_5++;
            };
        }

        coder function proFunc(_arg_1:String, _arg_2:ProgressEvent):void
        {
            var _local_3:Object;
            var _local_4:WealthQuene;
            var _local_5:String;
            var _local_6:WealthGroupVo;
            var _local_7:WealthVo;
            for each (_local_3 in this._requestHash[_arg_1]) {
                _local_4 = (this._hash.take(_local_3.qid) as WealthQuene);
                _local_5 = _local_3.oid.split((_local_3.path + Core.SIGN))[1];
                if (_local_4 == null) break;
                _local_6 = _local_4.takeGroup(_local_5);
                if (_local_6 == null) break;
                _local_7 = _local_6.take(_local_3.oid);
                if (_local_7 == null) break;
                _local_4.dispatchWealthProgressEvent(WealthProgressEvent.Progress, _arg_2, _local_7);
            };
        }

        coder function removeGroupRequest(_arg_1:WealthGroupVo):void
        {
            var _local_5:WealthVo;
            var _local_6:Object;
            var _local_7:WealthQuene;
            var _local_8:String;
            var _local_2:Vector.<WealthVo> = _arg_1.coder::values();
            var _local_3:int = _local_2.length;
            var _local_4:int;
            while (_local_4 < _local_3) {
                _local_5 = _local_2[_local_4];
                if (this._requestHash[_local_5.path]){
                    delete this._requestHash[_local_5.path][_local_5.id];
                    for each (_local_6 in this._requestHash[_local_5.path]) {
                        _local_7 = (this._hash.take(_local_6.qid) as WealthQuene);
                        _local_8 = _local_6.oid.split((_local_6.path + Core.SIGN))[1];
                        if (_local_7 == null) break;
                        _arg_1 = _local_7.takeGroup(_local_8);
                        if (_arg_1 == null) break;
                        _local_5 = _arg_1.take(_local_6.oid);
                        if (_local_5){
                            _local_5.coder::lock = false;
                        };
                    };
                };
                _local_4++;
            };
        }


    }
}//package com.engine.core.controls.wealth

