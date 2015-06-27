// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.utils.FPS

package com.engine.utils
{
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.display.BitmapData;
    import flash.text.TextField;
    import flash.events.Event;
    import flash.display.Bitmap;
    import flash.text.TextFormat;
    import flash.text.TextFieldAutoSize;
    import flash.system.System;
    import flash.utils.getTimer;

    public class FPS extends Sprite 
    {

        private static const maxMemory:uint = 41943000;
        private static const diagramWidth:uint = 60;
        private static const tfDelayMax:int = 10;
        private static var instance:FPS;
        private static const diagramHeight:uint = 40;
        private static var pt:Point = new Point(80, 90);

        private var currentY:int;
        private var diagramTimer:int;
        private var tfTimer:int;
        private var diagram:BitmapData;
        private var mem:TextField;
        private var fps:TextField;
        private var tfDelay:int = 0;

        public function FPS():void
        {
            this.addEventListener(Event.ADDED_TO_STAGE, this.run);
        }

        private function run(_arg_1:Event):void
        {
            var _local_2:Bitmap;
            if (instance == null){
                instance = this;
                this.fps = new TextField();
                this.mem = new TextField();
                this.mouseEnabled = false;
                this.mouseChildren = false;
                this.fps.defaultTextFormat = new TextFormat("Tahoma", 10, 0xCCCCCC);
                this.fps.autoSize = TextFieldAutoSize.LEFT;
                this.fps.text = ("FPS: " + Number(stage.frameRate).toFixed(2));
                this.fps.selectable = false;
                this.fps.x = (-(diagramWidth) - 2);
                addChild(this.fps);
                this.mem.defaultTextFormat = new TextFormat("Tahoma", 10, 0xCCCC00);
                this.mem.autoSize = TextFieldAutoSize.LEFT;
                this.mem.text = ("MEM: " + this.bytesToString(System.totalMemory));
                this.mem.selectable = false;
                this.mem.x = (-(diagramWidth) - 2);
                this.mem.y = 10;
                addChild(this.mem);
                this.currentY = 20;
                this.diagram = new BitmapData(diagramWidth, diagramHeight, true, 0x20FFFF00);
                _local_2 = new Bitmap(this.diagram);
                _local_2.y = (this.currentY + 4);
                _local_2.x = -(diagramWidth);
                addChildAt(_local_2, 0);
                this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
                this.stage.addEventListener(Event.RESIZE, this.onResize);
                this.onResize();
                this.diagramTimer = getTimer();
                this.tfTimer = getTimer();
            };
        }

        private function bytesToString(_arg_1:uint):String
        {
            var _local_2:String;
            if (_arg_1 < 0x0400){
                _local_2 = (String(_arg_1) + "b");
            } else {
                if (_arg_1 < 0x2800){
                    _local_2 = (Number((_arg_1 / 0x0400)).toFixed(2) + "kb");
                } else {
                    if (_arg_1 < 102400){
                        _local_2 = (Number((_arg_1 / 0x0400)).toFixed(1) + "kb");
                    } else {
                        if (_arg_1 < 0x100000){
                            _local_2 = (int((_arg_1 / 0x0400)) + "kb");
                        } else {
                            if (_arg_1 < 0xA00000){
                                _local_2 = (Number((_arg_1 / 0x100000)).toFixed(2) + "mb");
                            } else {
                                if (_arg_1 < 104857600){
                                    _local_2 = (Number((_arg_1 / 0x100000)).toFixed(1) + "mb");
                                } else {
                                    _local_2 = (int((_arg_1 / 0x100000)) + "mb");
                                };
                            };
                        };
                    };
                };
            };
            return (_local_2);
        }

        private function onEnterFrame(_arg_1:Event):void
        {
            this.tfDelay++;
            if (this.tfDelay >= tfDelayMax){
                this.tfDelay = 0;
                this.fps.text = ("FPS: " + Number(((1000 * tfDelayMax) / (getTimer() - this.tfTimer))).toFixed(2));
                this.tfTimer = getTimer();
            };
            var _local_2:* = (1000 / (getTimer() - this.diagramTimer));
            var _local_3:* = (((_local_2 > stage.frameRate)) ? 1 : (_local_2 / stage.frameRate));
            this.diagramTimer = getTimer();
            this.mem.text = ("MEM: " + this.bytesToString(System.totalMemory));
            var _local_4:Number = (System.totalMemory / maxMemory);
        }

        private function onResize(_arg_1:Event=null):void
        {
            var _local_2:Point = parent.globalToLocal(pt);
            this.x = _local_2.x;
            this.y = _local_2.y;
        }


    }
}//package com.engine.utils

