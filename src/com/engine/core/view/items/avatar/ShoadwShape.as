// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.items.avatar.ShoadwShape

package com.engine.core.view.items.avatar
{
    import flash.display.Sprite;
    import flash.geom.Point;
    import com.engine.core.Core;
    import flash.geom.Rectangle;
    import com.engine.core.view.scenes.Scene;

    public class ShoadwShape extends Sprite 
    {

        private static var recovery_point:Point = new Point();

        public var owner:Avatar;
        public var moveFunc:Function;

        public function ShoadwShape()
        {
            this.mouseChildren = (this.mouseEnabled = false);
        }

        override public function set x(_arg_1:Number):void
        {
            super.x = _arg_1;
            if (_arg_1 != 0){
                if (this.moveFunc != null){
                    this.moveFunc();
                };
                if (!this.owner){
                    this.dispose();
                };
            };
            this.stageIntersects();
        }

        override public function set y(_arg_1:Number):void
        {
            super.y = _arg_1;
            if (_arg_1 != 0){
                if (this.moveFunc != null){
                    this.moveFunc();
                };
                if (!this.owner){
                    this.dispose();
                };
            };
            this.stageIntersects();
        }

        public function stageIntersects():void
        {
            if (((((!(Core.CORE_RECT)) || ((this.visible == false)))) || (!(this.owner)))){
                return;
            };
            var _local_1:int = Core.char_shadow.width;
            var _local_2:int = Core.char_shadow.height;
            var _local_3:Rectangle = getBounds(this);
            var _local_4:Point = recovery_point;
            _local_4.x = _local_3.x;
            _local_4.y = _local_3.y;
            _local_4 = this.localToGlobal(_local_4);
            _local_3.x = _local_4.x;
            _local_3.y = _local_4.y;
            if (((((!(_local_3.isEmpty())) && (Avatar.stageRect))) && (!(Avatar.stageRect.intersects(_local_3))))){
                if (this.parent){
                    this.parent.removeChild(this);
                };
            } else {
                if (!this.parent){
                    Scene.scene.$itemLayer.addChild(this);
                };
            };
        }

        public function dispose():void
        {
            if (this.parent){
                this.parent.removeChild(this);
            };
            this.graphics.clear();
            this.moveFunc = null;
            this.owner = null;
        }


    }
}//package com.engine.core.view.items.avatar

