// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//gs.plugins.VisiblePlugin

package gs.plugins
{
    import gs.TweenLite;
    import flash.display.*;
    import gs.*;

    public class VisiblePlugin extends TweenPlugin 
    {

        public static const VERSION:Number = 1;
        public static const API:Number = 1;

        protected var _target:Object;
        protected var _tween:TweenLite;
        protected var _visible:Boolean;

        public function VisiblePlugin()
        {
            this.propName = "visible";
            this.overwriteProps = ["visible"];
            this.onComplete = this.onCompleteTween;
        }

        override public function onInitTween(_arg_1:Object, _arg_2:*, _arg_3:TweenLite):Boolean
        {
            this._target = _arg_1;
            this._tween = _arg_3;
            this._visible = Boolean(_arg_2);
            return (true);
        }

        public function onCompleteTween():void
        {
            if (((!((this._tween.vars.runBackwards == true))) && ((this._tween.ease == this._tween.vars.ease)))){
                this._target.visible = this._visible;
            };
        }

        override public function set changeFactor(_arg_1:Number):void
        {
            if (this._target.visible != true){
                this._target.visible = true;
            };
        }


    }
}//package gs.plugins

