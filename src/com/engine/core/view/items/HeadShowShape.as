// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.items.HeadShowShape

package com.engine.core.view.items
{
    import com.engine.core.view.base.BaseShape;
    import flash.utils.getTimer;
    import com.engine.core.Core;

    public class HeadShowShape extends BaseShape 
    {

        public var dy:Number = 2;
        public var time:int;
        private var va:Number = 0.025;
        public var stop:Boolean = false;
        public var playEndFunc:Function;
        private var startY:int;
        private var startTime:int;
        public var monutHeight:int;
        public var body_height:int;
        private var dx:int = 15;
        private var startSpeedY:int = 3;
        public var type:int = 0;


        public function setStartY(_arg_1:int, _arg_2:int, _arg_3:int=0):void
        {
            this.startTime = getTimer();
            this.startY = 0;
            this.dx = 8;
            this.monutHeight = -(Math.abs(_arg_1));
            this.y = _arg_1;
            this.cacheAsBitmap = true;
            this.startSpeedY = 3;
            this.type = _arg_3;
            if (_arg_3 == 1){
                this.scaleX = (this.scaleY = 2);
                this.y = -100;
                this.dy = 0.05;
                this.dx = 3;
            } else {
                if (_arg_3 == 2){
                    this.scaleX = (this.scaleY = 1);
                    this.dy = 0.05;
                    this.dx = 4;
                };
            };
        }

        override public function set x(_arg_1:Number):void
        {
            super.x = _arg_1;
        }

        public function moving():void
        {
            var _local_1:int;
            if (((!(this.stop)) && (((getTimer() - this.time) > 2)))){
                this.time = getTimer();
                _local_1 = (getTimer() - this.startTime);
                if (this.type == 0){
                    if (this.startSpeedY < 0){
                        this.startSpeedY = 0;
                    };
                    this.dy = ((2 * Core.handleCount) + this.startSpeedY);
                    if (this.startSpeedY > 0){
                        this.startSpeedY = (this.startSpeedY - 0.1);
                    };
                    this.startY = (this.startY - this.dy);
                    this.x = (this.x - this.dx);
                    this.dx = (this.dx - (0.15 * Core.handleCount));
                    this.y = this.startY;
                    if (_local_1 > 400){
                        this.dy = ((1.5 * Core.handleCount) + this.startSpeedY);
                        this.alpha = (this.alpha - (this.va * Core.handleCount));
                        if (_local_1 > 5000){
                            alpha = -1;
                        };
                    } else {
                        this.dy = ((2 * Core.handleCount) + this.startSpeedY);
                    };
                } else {
                    if (this.type == 1){
                        if (scaleX > 1){
                            this.scaleX = (this.scaleX - this.dy);
                            this.scaleY = (this.scaleY - this.dy);
                        };
                        if (scaleX < 1){
                            this.scaleX = (this.scaleY = 1);
                        };
                        if (_local_1 > 400){
                            this.alpha = (this.alpha - (this.va * Core.handleCount));
                            this.y = (this.y - (this.dx * Core.handleCount));
                        };
                        if (_local_1 > 5000){
                            alpha = -1;
                        };
                    } else {
                        if (this.type == 2){
                            if (_local_1 > 200){
                                this.alpha = (this.alpha - (this.va * Core.handleCount));
                                this.y = (this.y - (this.dx * Core.handleCount));
                            };
                            if (_local_1 > 5000){
                                alpha = -1;
                            };
                        };
                    };
                };
                if (this.alpha < 0){
                    if (this.playEndFunc != null){
                        this.playEndFunc(id);
                    };
                    this.playEndFunc = null;
                    if (this.parent){
                        this.parent.removeChild(this);
                    };
                    this.dispose();
                    this.stop = true;
                };
            };
        }

        override public function dispose():void
        {
            this.playEndFunc = null;
            super.dispose();
        }


    }
}//package com.engine.core.view.items

