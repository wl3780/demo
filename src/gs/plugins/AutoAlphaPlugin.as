// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//gs.plugins.AutoAlphaPlugin

package gs.plugins
{
    import gs.TweenLite;
    import flash.display.*;
    import gs.*;

    public class AutoAlphaPlugin extends TweenPlugin 
    {

        public static const VERSION:Number = 1;
        public static const API:Number = 1;

        protected var _tweenVisible:Boolean;
        protected var _visible:Boolean;
        protected var _tween:TweenLite;
        protected var _target:Object;

        public function AutoAlphaPlugin()
        {
            this.propName = "autoAlpha";
            this.overwriteProps = ["alpha", "visible"];
            this.onComplete = this.onCompleteTween;
        }

        override public function onInitTween(_arg_1:Object, _arg_2:*, _arg_3:TweenLite):Boolean
        {
            this._target = _arg_1;
            this._tween = _arg_3;
            this._visible = Boolean(!((_arg_2 == 0)));
            this._tweenVisible = true;
            addTween(_arg_1, "alpha", _arg_1.alpha, _arg_2, "alpha");
            return (true);
        }

        override public function killProps(_arg_1:Object):void
        {
            super.killProps(_arg_1);
            this._tweenVisible = !(Boolean(("visible" in _arg_1)));
        }

        public function onCompleteTween():void
        {
            if (((((this._tweenVisible) && (!((this._tween.vars.runBackwards == true))))) && ((this._tween.ease == this._tween.vars.ease)))){
                this._target.visible = this._visible;
            };
        }

        override public function set changeFactor(_arg_1:Number):void
        {
            updateTweens(_arg_1);
            if (((!((this._target.visible == true))) && (this._tweenVisible))){
                this._target.visible = true;
            };
        }


    }
}//package gs.plugins

