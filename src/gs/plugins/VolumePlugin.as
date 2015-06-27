// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//gs.plugins.VolumePlugin

package gs.plugins
{
    import flash.media.SoundTransform;
    import gs.TweenLite;
    import flash.display.*;
    import gs.*;

    public class VolumePlugin extends TweenPlugin 
    {

        public static const VERSION:Number = 1.01;
        public static const API:Number = 1;

        protected var _target:Object;
        protected var _st:SoundTransform;

        public function VolumePlugin()
        {
            this.propName = "volume";
            this.overwriteProps = ["volume"];
        }

        override public function onInitTween(_arg_1:Object, _arg_2:*, _arg_3:TweenLite):Boolean
        {
            if (((isNaN(_arg_2)) || (!(_arg_1.hasOwnProperty("soundTransform"))))){
                return (false);
            };
            this._target = _arg_1;
            this._st = this._target.soundTransform;
            addTween(this._st, "volume", this._st.volume, _arg_2, "volume");
            return (true);
        }

        override public function set changeFactor(_arg_1:Number):void
        {
            updateTweens(_arg_1);
            this._target.soundTransform = this._st;
        }


    }
}//package gs.plugins

