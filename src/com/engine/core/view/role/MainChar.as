// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.view.role.MainChar

package com.engine.core.view.role
{
    import flash.geom.Point;
    import com.engine.core.tile.square.SquareGroup;
    import com.engine.core.tile.square.Square;
    import com.engine.namespaces.coder;
    import com.engine.core.view.scenes.Scene;
    import com.engine.core.tile.square.SquarePt;
    import com.engine.core.view.scenes.SceneConstant;
    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    import flash.utils.getTimer;
    import com.engine.core.Core;
    import com.engine.core.view.items.avatar.CharAction;

    public class MainChar extends Char 
    {

        private static var recovery_point:Point = new Point();

        public var ready:Boolean = false;
        public var lockMove:Boolean;
        public var lockJump:Boolean;
        public var lockAttack:Boolean;
        public var lockFly:Boolean;
        public var lockTeleport:Boolean;
        public var movePointChangeFunc:Function;
        private var _ptStr:String;
        public var stopMoveFunc:Function;
        private var time_index:int;
        private var moveTime:int = 0;
        private var time__:int;
        private var firstTime:Boolean = false;

        public function MainChar()
        {
            this.openShadow = true;
            isMainChar = true;
        }

        override public function set pt(_arg_1:SquarePt):void
        {
            super.pt = _arg_1;
            var _local_2:Square = SquareGroup.getInstance().take(pt.key);
            if (((_local_2) && ((_local_2.type > 0)))){
                (Scene.scene.coder::astar.mode == _local_2.type);
            };
        }

        override public function setup():void
        {
            super.setup();
            this._ap.isAutoDispose = false;
        }

        override public function stopMove():void
        {
            super.stopMove();
            if (this.stopMoveFunc != null){
                this.stopMoveFunc();
            };
        }

        override public function moving():void
        {
            super.moving();
        }

        override public function set pathArr(_arg_1:Array):void
        {
            _pathArr = _arg_1;
        }

        override protected function charMove(_arg_1:String=""):void
        {
            var _local_11:int;
            if (tar_point == null){
                this.walkEnd();
                return;
            };
            if (this.jumping){
                this._speed_ = jump_deafult_speed;
            } else {
                this._speed_ = speed;
            };
            if (jumping){
                if (this.pathArr.length <= (jumpIndex / 2)){
                    this._speed_ = (this._speed_ + (((jumpIndex / 2) - this.pathArr.length) * 2));
                } else {
                    this._speed_ = (this._speed_ - ((this.pathArr.length - (jumpIndex / 2)) * 2));
                };
                if (this.pathArr.length > 1){
                    createShoawBitmap();
                };
            };
            var _local_2:Number = Point.distance(this.point, tar_point);
            var _local_3:Number = ((_local_2 / this._speed_) * 1000);
            if (totalTime >= _local_3){
                this.totalTime = (this.totalTime - _local_3);
            } else {
                _local_3 = totalTime;
                this.totalTime = 0;
            };
            var _local_4:Number = ((this._speed_ * _local_3) / 1000);
            var _local_5:Number = Number((tar_point.x - point.x).toFixed(2));
            var _local_6:Number = Number((tar_point.y - point.y).toFixed(2));
            var _local_7:Number = Number(Math.atan2(_local_6, _local_5).toFixed(2));
            var _local_8:Number = Number((Math.cos(_local_7) * _local_4).toFixed(2));
            var _local_9:Number = Number((Math.sin(_local_7) * _local_4).toFixed(2));
            this.x = (this.x + _local_8);
            this.y = (this.y + _local_9);
            if (this._ptStr != this.point.toString()){
                if (this.movePointChangeFunc != null){
                    this.movePointChangeFunc(this.point, tar_point);
                };
            };
            this._ptStr = this.point.toString();
            var _local_10:Point = recovery_point;
            _local_10.x = x;
            _local_10.y = y;
            _local_2 = int(Point.distance(_local_10, tar_point));
            if ((((_local_2 <= 5)) || ((((_local_8 == 0)) && ((_local_9 == 0)))))){
                if (this.pathArr.length > 0){
                    tar_point = this.pathArr.shift();
                } else {
                    this.walkEnd();
                };
            } else {
                if (((!((this.specialMode == 1))) && ((this.jumping == false)))){
                    _local_11 = this.getDretion(tar_point.x, tar_point.y);
                    if (_local_11 != dir){
                        this.dir = _local_11;
                    };
                };
            };
            if (totalTime > 0){
                this.charMove();
            };
        }

        override public function set char_id(_arg_1:String):void
        {
            super.char_id = _arg_1;
            var _local_2 = Scene.scene;
            (_local_2.coder::removeRepeatObjectInAvatarHash(this));
            Scene.scene.addItem(this, SceneConstant.MIDDLE_LAYER);
        }

        override public function set point(_arg_1:Point):void
        {
            super.point = _arg_1;
        }

        override public function set x(_arg_1:Number):void
        {
            super.x = _arg_1;
        }

        override public function set y(_arg_1:Number):void
        {
            super.y = _arg_1;
        }

        override public function onRender(_arg_1:String, _arg_2:int, _arg_3:BitmapData, _arg_4:Rectangle, _arg_5:String, _arg_6:String=null, _arg_7:int=0, _arg_8:int=0, _arg_9:BitmapData=null):void
        {
            super.onRender(_arg_1, _arg_2, _arg_3, _arg_4, _arg_5, _arg_6, _arg_7, _arg_8, _arg_9);
        }

        override protected function walkEnd():void
        {
            super.walkEnd();
            trace("=========================主角移动完毕；", (getTimer() - this.time__), this.point, "=========================");
        }

        override public function walk(_arg_1:Array):void
        {
            this.time__ = getTimer();
            this.time_index = Core.delayTime;
            super.walk(_arg_1);
        }

        override public function setupReady():void
        {
            var _local_1:Array;
            var _local_2:int;
            if (this.firstTime == false){
                this.firstTime = true;
                _local_1 = [CharAction.WALK, CharAction.ATTACK, CharAction.HIT, CharAction.SKILL2, CharAction.QUNGONG, CharAction.SKILL1];
                _local_2 = 0;
                while (_local_2 < _local_1.length) {
                    this.loadCharActionAssets(_local_1[_local_2]);
                    _local_2++;
                };
            };
        }

        override public function get stageIntersects():Boolean
        {
            return (true);
        }

        public function cleanPath():void
        {
            this.play("stand");
            this.pathArr = [];
            this.runing = false;
        }

        override public function getDretion(_arg_1:Number, _arg_2:Number):int
        {
            return (super.getDretion(_arg_1, _arg_2));
        }


    }
}//package com.engine.core.view.role

