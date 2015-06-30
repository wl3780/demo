package com.engine.core.model.wealth
{
    import com.engine.core.Core;
    import com.engine.core.controls.wealth.WealthConstant;
    import com.engine.core.model.Proto;
    import com.engine.namespaces.coder;
    
    import flash.net.registerClassAlias;

    public class WealthVo extends Proto 
    {
		
        public var loadIndex:int = 0;
        public var group_totalNum:int;
        public var group_loadedIndex:int;
        public var dataFormat:String;

        coder var $index:int;
		
        private var _path:String;
        private var _data:Object;
        private var _loaded:Boolean;
        private var _lock:Boolean;

        public function WealthVo()
        {
            registerClassAlias("saiman.save.WealthVo", WealthVo);
        }

        public function get path():String
        {
            return (this._path);
        }

        public function get data():Object
        {
            return (this._data);
        }

        public function get lock():Boolean
        {
            return (this._lock);
        }

        coder function set lock(_arg_1:Boolean):void
        {
            this._lock = _arg_1;
        }

        public function get loaded():Boolean
        {
            return (this._loaded);
        }

        coder function set loaded(_arg_1:Boolean):void
        {
            this._loaded = _arg_1;
        }

        public function setUp(_arg_1:String, _arg_2:Object=null, _arg_3:String=null):void
        {
            this._path = _arg_1;
            this._data = _arg_2;
            this.$oid = _arg_3;
            this.$id = ((_arg_1 + Core.SIGN) + _arg_3);
        }

        public function get index():int
        {
            return this.coder::$index;
        }

        public function get type():String
        {
            if (this._path){
                if (((!((this._path.indexOf(".swf") == -1))) || (!((this._path.indexOf(".tmp") == -1))))){
                    return (WealthConstant.SWF_WEALTH);
                };
                if (((((((((!((this._path.indexOf(".png") == -1))) || (!((this._path.indexOf(".jpg") == -1))))) || (!((this._path.indexOf(".jxr") == -1))))) || (!((this._path.indexOf(".gif") == -1))))) || (!((this._path.indexOf(".jpeg") == -1))))){
                    return (WealthConstant.IMG_WEALTH);
                };
                return (WealthConstant.BING_WEALTH);
            };
            return (null);
        }


    }
}//package com.engine.core.model.wealth

