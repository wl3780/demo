// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//gs.TweenLite

package gs
{
    import flash.utils.Dictionary;
    import flash.display.Sprite;
    import flash.utils.Timer;
    import gs.plugins.TweenPlugin;
    import gs.plugins.TintPlugin;
    import gs.plugins.RemoveTintPlugin;
    import gs.plugins.FramePlugin;
    import gs.plugins.AutoAlphaPlugin;
    import gs.plugins.VisiblePlugin;
    import gs.plugins.VolumePlugin;
    import gs.plugins.EndArrayPlugin;
    import flash.utils.getTimer;
    import flash.events.Event;
    import flash.display.DisplayObject;
    import flash.events.TimerEvent;
    import gs.utils.tween.TweenInfo;
    import flash.events.*;
    import flash.display.*;
    import flash.utils.*;
    import gs.plugins.*;
    import gs.utils.tween.*;

    public class TweenLite 
    {

        public static const version:Number = 10.092;
        public static var plugins:Object = {};
        public static var killDelayedCallsTo:Function = TweenLite.killTweensOf;
        public static var defaultEase:Function = TweenLite.easeOut;
        public static var overwriteManager:Object;
        public static var currentTime:uint;
        public static var masterList:Dictionary = new Dictionary(false);
        public static var timingSprite:Sprite = new Sprite();
        private static var _tlInitted:Boolean;
        private static var _timer:Timer = new Timer(2000);
        protected static var _reservedProps:Object = {
            "ease":1,
            "delay":1,
            "overwrite":1,
            "onComplete":1,
            "onCompleteParams":1,
            "runBackwards":1,
            "startAt":1,
            "onUpdate":1,
            "onUpdateParams":1,
            "roundProps":1,
            "onStart":1,
            "onStartParams":1,
            "persist":1,
            "renderOnStart":1,
            "proxiedEase":1,
            "easeParams":1,
            "yoyo":1,
            "loop":1,
            "onCompleteListener":1,
            "onUpdateListener":1,
            "onStartListener":1,
            "orientToBezier":1,
            "timeScale":1
        };

        public var duration:Number;
        public var vars:Object;
        public var delay:Number;
        public var startTime:Number;
        public var initTime:Number;
        public var tweens:Array;
        public var target:Object;
        public var active:Boolean;
        public var ease:Function;
        public var initted:Boolean;
        public var combinedTimeScale:Number;
        public var gc:Boolean;
        public var started:Boolean;
        public var exposedVars:Object;
        protected var _hasPlugins:Boolean;
        protected var _hasUpdate:Boolean;

        public function TweenLite(_arg_1:Object, _arg_2:Number, _arg_3:Object)
        {
            if (_arg_1 == null){
                return;
            };
            if (!_tlInitted){
                TweenPlugin.activate([TintPlugin, RemoveTintPlugin, FramePlugin, AutoAlphaPlugin, VisiblePlugin, VolumePlugin, EndArrayPlugin]);
                currentTime = getTimer();
                timingSprite.addEventListener(Event.ENTER_FRAME, updateAll, false, 0, true);
                if (overwriteManager == null){
                    overwriteManager = {
                        "mode":1,
                        "enabled":false
                    };
                };
                _timer.addEventListener("timer", killGarbage, false, 0, true);
                _timer.start();
                _tlInitted = true;
            };
            this.vars = _arg_3;
            this.duration = ((_arg_2) || (0.001));
            this.delay = ((_arg_3.delay) || (0));
            this.combinedTimeScale = ((_arg_3.timeScale) || (1));
            this.active = Boolean((((_arg_2 == 0)) && ((this.delay == 0))));
            this.target = _arg_1;
            if (typeof(this.vars.ease) != "function"){
                this.vars.ease = defaultEase;
            };
            if (this.vars.easeParams != null){
                this.vars.proxiedEase = this.vars.ease;
                this.vars.ease = this.easeProxy;
            };
            this.ease = this.vars.ease;
            this.exposedVars = (((this.vars.isTV)==true) ? this.vars.exposedVars : this.vars);
            this.tweens = [];
            this.initTime = currentTime;
            this.startTime = (this.initTime + (this.delay * 1000));
            var _local_4:int = (((((_arg_3.overwrite == undefined)) || (((!(overwriteManager.enabled)) && ((_arg_3.overwrite > 1)))))) ? overwriteManager.mode : int(_arg_3.overwrite));
            if (((!((_arg_1 in masterList))) || ((_local_4 == 1)))){
                masterList[_arg_1] = [this];
            } else {
                masterList[_arg_1].push(this);
            };
            if ((((((this.vars.runBackwards == true)) && (!((this.vars.renderOnStart == true))))) || (this.active))){
                this.initTweenVals();
                if (this.active){
                    this.render((this.startTime + 1));
                } else {
                    this.render(this.startTime);
                };
                if (((((!((this.exposedVars.visible == null))) && ((this.vars.runBackwards == true)))) && ((this.target is DisplayObject)))){
                    this.target.visible = this.exposedVars.visible;
                };
            };
        }

        public static function to(_arg_1:Object, _arg_2:Number, _arg_3:Object):TweenLite
        {
            return (new (TweenLite)(_arg_1, _arg_2, _arg_3));
        }

        public static function from(_arg_1:Object, _arg_2:Number, _arg_3:Object):TweenLite
        {
            _arg_3.runBackwards = true;
            return (new (TweenLite)(_arg_1, _arg_2, _arg_3));
        }

        public static function delayedCall(_arg_1:Number, _arg_2:Function, _arg_3:Array=null):TweenLite
        {
            return (new (TweenLite)(_arg_2, 0, {
                "delay":_arg_1,
                "onComplete":_arg_2,
                "onCompleteParams":_arg_3,
                "overwrite":0
            }));
        }

        public static function updateAll(_arg_1:Event=null):void
        {
            var _local_4:Array;
            var _local_5:int;
            var _local_6:TweenLite;
            var _local_2:uint = (currentTime = getTimer());
            var _local_3:Dictionary = masterList;
            for each (_local_4 in _local_3) {
                _local_5 = (_local_4.length - 1);
                while (_local_5 > -1) {
                    _local_6 = _local_4[_local_5];
                    if (_local_6.active){
                        _local_6.render(_local_2);
                    } else {
                        if (_local_6.gc){
                            _local_4.splice(_local_5, 1);
                        } else {
                            if (_local_2 >= _local_6.startTime){
                                _local_6.activate();
                                _local_6.render(_local_2);
                            };
                        };
                    };
                    _local_5--;
                };
            };
        }

        public static function removeTween(_arg_1:TweenLite, _arg_2:Boolean=true):void
        {
            if (_arg_1 != null){
                if (_arg_2){
                    _arg_1.clear();
                };
                _arg_1.enabled = false;
            };
        }

        public static function killTweensOf(_arg_1:Object=null, _arg_2:Boolean=false):void
        {
            var _local_3:Array;
            var _local_4:int;
            var _local_5:TweenLite;
            if (((!((_arg_1 == null))) && ((_arg_1 in masterList)))){
                _local_3 = masterList[_arg_1];
                _local_4 = (_local_3.length - 1);
                while (_local_4 > -1) {
                    _local_5 = _local_3[_local_4];
                    if (((_arg_2) && (!(_local_5.gc)))){
                        _local_5.complete(false);
                    };
                    _local_5.clear();
                    _local_4--;
                };
                delete masterList[_arg_1];
            };
        }

        protected static function killGarbage(_arg_1:TimerEvent):void
        {
            var _local_3:Object;
            var _local_2:Dictionary = masterList;
            for (_local_3 in _local_2) {
                if (_local_2[_local_3].length == 0){
                    delete _local_2[_local_3];
                };
            };
        }

        public static function easeOut(_arg_1:Number, _arg_2:Number, _arg_3:Number, _arg_4:Number):Number
        {
            _arg_1 = (_arg_1 / _arg_4);
            return ((((-(_arg_3) * _arg_1) * (_arg_1 - 2)) + _arg_2));
        }


        public function initTweenVals():void
        {
            var _local_1:String;
            var _local_2:int;
            var _local_3:*;
            var _local_4:TweenInfo;
            if (((!((this.exposedVars.timeScale == undefined))) && (this.target.hasOwnProperty("timeScale")))){
                this.tweens[this.tweens.length] = new TweenInfo(this.target, "timeScale", this.target.timeScale, (this.exposedVars.timeScale - this.target.timeScale), "timeScale", false);
            };
            for (_local_1 in this.exposedVars) {
                if (!(_local_1 in _reservedProps)){
                    if ((_local_1 in plugins)){
                        _local_3 = new (plugins[_local_1])();
                        if (_local_3.onInitTween(this.target, this.exposedVars[_local_1], this) == false){
                            this.tweens[this.tweens.length] = new TweenInfo(this.target, _local_1, this.target[_local_1], (((typeof(this.exposedVars[_local_1]))=="number") ? (this.exposedVars[_local_1] - this.target[_local_1]) : Number(this.exposedVars[_local_1])), _local_1, false);
                        } else {
                            this.tweens[this.tweens.length] = new TweenInfo(_local_3, "changeFactor", 0, 1, (((_local_3.overwriteProps.length)==1) ? _local_3.overwriteProps[0] : "_MULTIPLE_"), true);
                            this._hasPlugins = true;
                        };
                    } else {
                        this.tweens[this.tweens.length] = new TweenInfo(this.target, _local_1, this.target[_local_1], (((typeof(this.exposedVars[_local_1]))=="number") ? (this.exposedVars[_local_1] - this.target[_local_1]) : Number(this.exposedVars[_local_1])), _local_1, false);
                    };
                };
            };
            if (this.vars.runBackwards == true){
                _local_2 = (this.tweens.length - 1);
                while (_local_2 > -1) {
                    _local_4 = this.tweens[_local_2];
                    _local_4.start = (_local_4.start + _local_4.change);
                    _local_4.change = -(_local_4.change);
                    _local_2--;
                };
            };
            if (this.vars.onUpdate != null){
                this._hasUpdate = true;
            };
            if (((TweenLite.overwriteManager.enabled) && ((this.target in masterList)))){
                overwriteManager.manageOverwrites(this, masterList[this.target]);
            };
            this.initted = true;
        }

        public function activate():void
        {
            this.started = (this.active = true);
            if (!this.initted){
                this.initTweenVals();
            };
            if (this.vars.onStart != null){
                this.vars.onStart.apply(null, this.vars.onStartParams);
            };
            if (this.duration == 0.001){
                this.startTime--;
            };
        }

        public function render(_arg_1:uint):void
        {
            var _local_3:Number;
            var _local_4:TweenInfo;
            var _local_5:int;
            var _local_2:Number = ((_arg_1 - this.startTime) * 0.001);
            if (_local_2 >= this.duration){
                _local_2 = this.duration;
                _local_3 = (((((this.ease == this.vars.ease)) || ((this.duration == 0.001)))) ? 1 : 0);
            } else {
                _local_3 = this.ease(_local_2, 0, 1, this.duration);
            };
            _local_5 = (this.tweens.length - 1);
            while (_local_5 > -1) {
                _local_4 = this.tweens[_local_5];
                _local_4.target[_local_4.property] = (_local_4.start + (_local_3 * _local_4.change));
                _local_5--;
            };
            if (this._hasUpdate){
                this.vars.onUpdate.apply(null, this.vars.onUpdateParams);
            };
            if (_local_2 == this.duration){
                this.complete(true);
            };
        }

        public function complete(_arg_1:Boolean=false):void
        {
            var _local_2:int;
            if (!_arg_1){
                if (!this.initted){
                    this.initTweenVals();
                };
                this.startTime = (currentTime - ((this.duration * 1000) / this.combinedTimeScale));
                this.render(currentTime);
                return;
            };
            if (this._hasPlugins){
                _local_2 = (this.tweens.length - 1);
                while (_local_2 > -1) {
                    if (((this.tweens[_local_2].isPlugin) && (!((this.tweens[_local_2].target.onComplete == null))))){
                        this.tweens[_local_2].target.onComplete();
                    };
                    _local_2--;
                };
            };
            if (this.vars.persist != true){
                this.enabled = false;
            };
            if (this.vars.onComplete != null){
                this.vars.onComplete.apply(null, this.vars.onCompleteParams);
            };
        }

        public function clear():void
        {
            this.tweens = [];
            this.vars = (this.exposedVars = {"ease":this.vars.ease});
            this._hasUpdate = false;
        }

        public function killVars(_arg_1:Object):void
        {
            if (overwriteManager.enabled){
                overwriteManager.killVars(_arg_1, this.exposedVars, this.tweens);
            };
        }

        protected function easeProxy(_arg_1:Number, _arg_2:Number, _arg_3:Number, _arg_4:Number):Number
        {
            return (this.vars.proxiedEase.apply(null, arguments.concat(this.vars.easeParams)));
        }

        public function get enabled():Boolean
        {
            return (((this.gc) ? false : true));
        }

        public function set enabled(_arg_1:Boolean):void
        {
            var _local_2:Array;
            var _local_3:Boolean;
            var _local_4:int;
            if (_arg_1){
                if (!(this.target in masterList)){
                    masterList[this.target] = [this];
                } else {
                    _local_2 = masterList[this.target];
                    _local_4 = (_local_2.length - 1);
                    while (_local_4 > -1) {
                        if (_local_2[_local_4] == this){
                            _local_3 = true;
                            break;
                        };
                        _local_4--;
                    };
                    if (!_local_3){
                        _local_2[_local_2.length] = this;
                    };
                };
            };
            this.gc = ((_arg_1) ? false : true);
            if (this.gc){
                this.active = false;
            } else {
                this.active = this.started;
            };
        }


    }
}//package gs

