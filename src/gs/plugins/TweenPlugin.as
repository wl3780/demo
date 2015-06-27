// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//gs.plugins.TweenPlugin

package gs.plugins
{
    import gs.TweenLite;
    import gs.utils.tween.TweenInfo;
    import gs.*;
    import gs.utils.tween.*;

    public class TweenPlugin 
    {

        public static const VERSION:Number = 1.03;
        public static const API:Number = 1;

        public var propName:String;
        public var overwriteProps:Array;
        public var round:Boolean;
        public var onComplete:Function;
        protected var _tweens:Array;
        protected var _changeFactor:Number = 0;

        public function TweenPlugin()
        {
            this._tweens = [];
            super();
        }

        public static function activate(_arg_1:Array):Boolean
        {
            var _local_2:int;
            var _local_3:Object;
            _local_2 = (_arg_1.length - 1);
            while (_local_2 > -1) {
                _local_3 = new (_arg_1[_local_2])();
                TweenLite.plugins[_local_3.propName] = _arg_1[_local_2];
                _local_2--;
            };
            return (true);
        }


        public function onInitTween(_arg_1:Object, _arg_2:*, _arg_3:TweenLite):Boolean
        {
            this.addTween(_arg_1, this.propName, _arg_1[this.propName], _arg_2, this.propName);
            return (true);
        }

        protected function addTween(_arg_1:Object, _arg_2:String, _arg_3:Number, _arg_4:*, _arg_5:String=null):void
        {
            var _local_6:Number;
            if (_arg_4 != null){
                _local_6 = (((typeof(_arg_4))=="number") ? (_arg_4 - _arg_3) : Number(_arg_4));
                if (_local_6 != 0){
                    this._tweens[this._tweens.length] = new TweenInfo(_arg_1, _arg_2, _arg_3, _local_6, ((_arg_5) || (_arg_2)), false);
                };
            };
        }

        protected function updateTweens(_arg_1:Number):void
        {
            var _local_2:int;
            var _local_3:TweenInfo;
            var _local_4:Number;
            var _local_5:int;
            if (this.round){
                _local_2 = (this._tweens.length - 1);
                while (_local_2 > -1) {
                    _local_3 = this._tweens[_local_2];
                    _local_4 = (_local_3.start + (_local_3.change * _arg_1));
                    _local_5 = (((_local_4)<0) ? -1 : 1);
                    _local_3.target[_local_3.property] = (((((_local_4 % 1) * _local_5))>0.5) ? (int(_local_4) + _local_5) : int(_local_4));
                    _local_2--;
                };
            } else {
                _local_2 = (this._tweens.length - 1);
                while (_local_2 > -1) {
                    _local_3 = this._tweens[_local_2];
                    _local_3.target[_local_3.property] = (_local_3.start + (_local_3.change * _arg_1));
                    _local_2--;
                };
            };
        }

        public function set changeFactor(_arg_1:Number):void
        {
            this.updateTweens(_arg_1);
            this._changeFactor = _arg_1;
        }

        public function get changeFactor():Number
        {
            return (this._changeFactor);
        }

        public function killProps(_arg_1:Object):void
        {
            var _local_2:int;
            _local_2 = (this.overwriteProps.length - 1);
            while (_local_2 > -1) {
                if ((this.overwriteProps[_local_2] in _arg_1)){
                    this.overwriteProps.splice(_local_2, 1);
                };
                _local_2--;
            };
            _local_2 = (this._tweens.length - 1);
            while (_local_2 > -1) {
                if ((this._tweens[_local_2].name in _arg_1)){
                    this._tweens.splice(_local_2, 1);
                };
                _local_2--;
            };
        }


    }
}//package gs.plugins

