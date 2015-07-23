// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.items.avatar.ShoawdBitmap

package com.engine.core.view.avatar
{
    import flash.display.Bitmap;
    import com.engine.core.view.scenes.Scene;
    import com.engine.core.Engine;
    import flash.display.BitmapData;

    public class ShoawdBitmap extends Bitmap 
    {

        private var time:int = 0;

        public function ShoawdBitmap(_arg_1:BitmapData=null, _arg_2:String="auto", _arg_3:Boolean=false)
        {
            super(_arg_1, _arg_2, _arg_3);
            Scene.scene.addShoawdBitmap(this);
            this.time = Engine.delayTime;
            this.visible = false;
        }

        public function reander():void
        {
            if ((Engine.delayTime - this.time) > 30){
                if (!visible){
                    visible = true;
                };
                this.alpha = (this.alpha - 0.03);
                if (this.alpha < 0){
                    Scene.scene.removeShoawdBitmap(this);
                };
            };
        }

        public function dispose():void
        {
            if (bitmapData){
                this.bitmapData.dispose();
            };
            this.bitmapData = null;
            if (this.parent){
                this.parent.removeChild(this);
            };
        }


    }
}//package com.engine.core.view.items.avatar

