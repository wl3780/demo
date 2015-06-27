// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.service.Body

package com.engine.core.controls.service
{
    import com.engine.core.controls.Order;

    public class Body extends Order 
    {

        private var _execFunc:Function;
        private var _args:Array;
        private var _callbackFunc:Function;


        public function setUpFunction(_arg_1:Function=null, _arg_2:Array=null, _arg_3:Function=null):void
        {
            this._args = _arg_2;
            this._execFunc = _arg_1;
            this._callbackFunc = _arg_3;
        }

        override public function execute()
        {
            if (this._execFunc != null){
                if (this._args == null){
                    this._args = [];
                };
                return (this._execFunc.apply(null, this._args));
            };
        }

        override public function callback(_arg_1:Array=null)
        {
            if (this._callbackFunc != null){
                if (_arg_1 == null){
                    _arg_1 = [];
                };
                this._callbackFunc.apply(null, _arg_1);
            };
        }

        override public function dispose():void
        {
            this.proto = null;
            this._args = null;
            this._execFunc = null;
            this._callbackFunc = null;
            super.dispose();
        }


    }
}//package com.engine.core.controls.service

