package com.engine.core.model.wealth
{
    import com.engine.core.Core;
    import com.engine.core.controls.wealth.WealthConstant;
    import com.engine.core.model.Proto;
    import com.engine.namespaces.coder;
    
    import flash.net.URLLoaderDataFormat;
    import flash.utils.Dictionary;

    public class WealthGroupVo extends Proto 
    {

        public var name:String = "";
        public var loadedIndex:int;
        
        coder var $index:int;
        coder var $lock:Boolean;
		
		private var _level:int;
        private var _values:Vector.<WealthVo>;
        private var _hash:Dictionary;
        private var _loaded:Boolean;

        public function WealthGroupVo()
        {
            this._level = WealthConstant.PRIORITY_LEVEL;
            this._hash = new Dictionary();
            this._values = new Vector.<WealthVo>();
        }

        public function get lock():Boolean
        {
            return ((this.coder::$lock as Boolean));
        }

        public function get level():int
        {
            return (this._level);
        }

        public function set level(_arg_1:int):void
        {
            this._level = _arg_1;
        }

        public function get loaded():Boolean
        {
            return (this._loaded);
        }

        coder function set loaded(_arg_1:Boolean):void
        {
            this._loaded = _arg_1;
        }

        public function addWealth(_arg_1:String, _arg_2:Object, _arg_3:int=0):void
        {
            var _local_5:WealthVo;
            var _local_6:Array;
            var _local_7:String;
            var _local_4:String = ((_arg_1 + Core.SIGN) + this.id);
            if (this._hash[_local_4] == null){
                _local_5 = new WealthVo();
                _local_5.setUp(_arg_1, _arg_2, this.id);
                _local_6 = _arg_1.split("/");
                _local_7 = _local_6[(_local_6.length - 1)];
                if (((((((!((_local_7.indexOf(".txt") == -1))) || (!((_local_7.indexOf(".xml") == -1))))) || (!((_local_7.indexOf(".css") == -1))))) || (!((_local_7.indexOf(".as") == -1))))){
                    _local_5.dataFormat = URLLoaderDataFormat.TEXT;
                } else {
                    _local_5.dataFormat = URLLoaderDataFormat.BINARY;
                };
                _local_5.coder::$index = this._values.length;
                _local_5.loadIndex = _arg_3;
                this._values.push(_local_5);
                this._hash[_local_4] = _local_5;
            };
        }

        public function checkFinish():void
        {
            var _local_1:int = this._values.length;
            var _local_2:int;
            var _local_3:int;
            while (_local_3 < _local_1) {
                if (this._values[_local_3].loaded == false){
                    this._loaded = false;
                } else {
                    _local_2++;
                };
                _local_3++;
            };
            this.loadedIndex = _local_2;
            if (_local_2 == _local_1){
                this._loaded = true;
            };
        }

        public function addWealths(_arg_1:Vector.<String>, _arg_2:Vector.<Object>):void
        {
            var _local_3:String;
            var _local_6:WealthVo;
            var _local_4:int = _arg_1.length;
            var _local_5:int;
            while (_local_5 < _local_4) {
                _local_3 = ((_arg_1[_local_5] + Core.SIGN) + this.id);
                if (this._hash[_local_3] == null){
                    _local_6 = new WealthVo();
                    if (_arg_2 == null){
                        _local_6.setUp(_arg_1[_local_5], null, this.id);
                    } else {
                        _local_6.setUp(_arg_1[_local_5], _arg_2[_local_5], this.id);
                    };
                    if (((!((_arg_1[_local_5].indexOf(".txt") == -1))) || (!((_arg_1[_local_5].indexOf(".xml") == -1))))){
                        _local_6.dataFormat = URLLoaderDataFormat.TEXT;
                    } else {
                        _local_6.dataFormat = URLLoaderDataFormat.BINARY;
                    };
                    _local_6.coder::$index = this._values.length;
                    this._hash[_local_3] = _local_6;
                    this._values.push(_local_6);
                };
                _local_5++;
            };
        }

        public function shift():WealthVo
        {
            var _local_1:WealthVo;
            var _local_2:int;
            if (this._values.length){
                _local_1 = this._values.shift();
                _local_2 = 0;
                while (_local_2 < this._values.length) {
                    this._values[_local_2].coder::$index = _local_2;
                    _local_2++;
                };
                delete this._hash[_local_1.id];
            };
            return (null);
        }

        coder function values():Vector.<WealthVo>
        {
            return (this._values);
        }

        public function getNextWealth():WealthVo
        {
            var _local_2:WealthVo;
            var _local_1:int;
            while (_local_1 < this._values.length) {
                _local_2 = this._values[_local_1];
                if ((((((_local_2.lock == false)) && ((_local_2.loaded == false)))) && (_local_2.path))){
                    return (_local_2);
                };
                _local_1++;
            };
            return (null);
        }

        public function remove(_arg_1:String):WealthVo
        {
            var _local_2:WealthVo = this._hash[_arg_1];
            delete this._hash[_arg_1];
            var _local_3:int;
            while (_local_3 < this._values.length) {
                if (this._values[_local_3] == _local_2){
                    this._values.splice(_local_3, 1);
                };
                _local_3++;
            };
            return (_local_2);
        }

        public function pop():WealthVo
        {
            var _local_1:WealthVo;
            if (this._values.length){
                _local_1 = this._values.pop();
                delete this._hash[_local_1.id];
                return (_local_1);
            };
            return (null);
        }

        public function take(_arg_1:String):WealthVo
        {
            return ((this._hash[_arg_1] as WealthVo));
        }

        public function sortOn(pro:String="index"):void
        {
            var value:String;
            var compareFunction:Function;
            compareFunction = function (_arg_1:WealthVo, _arg_2:WealthVo):int
            {
                if (_arg_1.hasOwnProperty(pro)){
                    return (int((_arg_1[value] - _arg_2[value])));
                };
                return (int((_arg_1.index - _arg_2.index)));
            };
            value = pro;
            this._values.sort(compareFunction);
        }

        public function get length():int
        {
            if (this._values){
                return (this._values.length);
            };
            return (0);
        }

        public function reBuild():void
        {
            this._hash = null;
            this._hash = new Dictionary();
            this._values = null;
            this._values = new Vector.<WealthVo>();
            this._level = 0;
        }

        override public function dispose():void
        {
            this._hash = null;
            this._values = null;
            this._level = 0;
            super.dispose();
        }


    }
}//package com.engine.core.model.wealth

