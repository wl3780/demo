// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.items.SaimpleEffect

package com.engine.core.view.items
{
    import com.engine.core.Engine;
    import com.engine.core.view.base.BaseShape;
    import com.engine.core.view.scenes.Scene;
    import com.engine.utils.Hash;
    
    import core.HeartbeatFactory;
    
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;

    public class SaimpleEffect extends BaseShape 
    {

        private static var inited:Boolean;
        private static var hash:Hash = new Hash();
        private static var mat:Matrix = new Matrix();
        private static var stageRect:Rectangle = new Rectangle();

        private var bitmapData:BitmapData;
        private var _stop:Boolean;
        private var totalFrame:int;
        private var currFrame:int;
        private var _size:int = 34;
        private var w:int;
        private var h:int;
        private var _dur:int = 90;
        private var time:int;
        private var r:int;
        public var pause:Boolean = false;

        public function SaimpleEffect()
        {
            hash.put(this.id, this);
            this.r = ((Math.random() * 100) >> 0);
        }

        private static function enterFrameFunc():void
        {
            var _local_2:SaimpleEffect;
            var _local_1:Dictionary = hash;
            for each (_local_2 in _local_1) {
                if (!_local_2.stop){
                    _local_2.onReander();
                };
            };
        }

        public static function createSimpleEffect(_arg_1:BitmapData, _arg_2:Boolean=true):SaimpleEffect
        {
            var _local_3:SaimpleEffect = new (SaimpleEffect)();
            _local_3.setUp(_arg_1);
            if (_arg_2){
                _local_3.play(0);
            };
            return (_local_3);
        }


        public function get dur():int
        {
            return (this._dur);
        }

        public function set dur(_arg_1:int):void
        {
            this._dur = (_arg_1 + ((Math.random() * 50) >> 0));
        }

        public function set size(_arg_1:int):void
        {
            this._size = _arg_1;
        }

        public function get size():int
        {
            return (this._size);
        }

        public function get stop():Boolean
        {
            return (this._stop);
        }

        public function set stop(_arg_1:Boolean):void
        {
            this._stop = _arg_1;
        }

        public function play(_arg_1:int=0):void
        {
            if (!inited){
                inited = true;
                HeartbeatFactory.getInstance().addFrameOrder(enterFrameFunc);
            };
            this.currFrame = _arg_1;
            this.stop = false;
        }

        public function onReander():void
        {
            var _local_1:int;
            if (((((Scene.scene) && (Scene.scene.mainChar))) && (((Scene.scene.mainChar.runing) || (Scene.scene.mainChar.jumping))))){
                if ((Engine.fps < 5)){
                    _local_1 = 600;
                } else {
                    _local_1 = 400;
                };
            } else {
                if ((Engine.fps < 5)){
                    _local_1 = 500;
                } else {
                    _local_1 = 0;
                };
            };
            stageRect.width = Engine.stage.stageWidth;
            stageRect.height = Engine.stage.stageHeight;
            if ((Engine.delayTime - this.time) > ((this.dur + this.r) + _local_1)){
                this.time = Engine.delayTime;
                if ((((((this.totalFrame > 0)) && (!(this._stop)))) && (this.stage))){
                    if (this.currFrame >= this.totalFrame){
                        this.currFrame = 0;
                    };
                    if (((!(this.pause)) && (stage))){
                        this.graphics.clear();
                        mat.tx = 0;
                        mat.tx = (mat.tx - (this.currFrame * this.size));
                        this.graphics.beginBitmapFill(this.bitmapData, mat);
                        this.graphics.drawRect(0, 0, this.size, this.bitmapData.height);
                    };
                    this.currFrame++;
                };
            };
        }

        public function setUp(_arg_1:BitmapData):void
        {
            if (_arg_1){
                this.bitmapData = _arg_1;
                this.totalFrame = int((this.bitmapData.width / this.size));
            };
        }

        override public function dispose():void
        {
            hash.remove(this.id);
            this.bitmapData = null;
            this.totalFrame = 0;
            this.currFrame = 0;
            this._stop = true;
            super.dispose();
        }


    }
}//package com.engine.core.view.items

