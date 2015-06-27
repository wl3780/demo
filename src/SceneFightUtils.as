// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//SceneFightUtils

package 
{
    import flash.geom.Point;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import com.engine.core.view.scenes.SceneConstant;
    import com.engine.core.view.items.avatar.ItemAvatar;
    import com.engine.utils.gome.LinearAndFan;
    import gs.TweenLite;
    import flash.utils.getTimer;
    import gs.easing.Linear;
    import com.engine.core.view.role.Char;
    import com.engine.core.Core;

    public class SceneFightUtils 
    {


        public static function areaAttack(effect_id:int, point:Point, area:int=100, num:int=4, delay:int=150, points:Array=null):void
        {
            var num_:int;
            var dir:Array;
            var p:Point;
            var timer:Timer;
            var timeFunc:Function;
            timeFunc = function ():void
            {
                var _local_1:Point;
                if (num_ <= 0){
                    timer.stop();
                    timer.removeEventListener(TimerEvent.TIMER, timeFunc);
                    return;
                };
                if (points){
                    _local_1 = points.shift();
                    p = _local_1;
                } else {
                    p = new Point(_local_1.x, _local_1.y);
                    p.x = (p.x + (((Math.random() * (area / 2)) >> 0) * dir[((Math.random() * 2) >> 0)]));
                    p.y = (p.y + (((Math.random() * (area / 2)) >> 0) * dir[((Math.random() * 2) >> 0)]));
                };
                getEffect(effect_id, p, null, SceneConstant.MIDDLE_LAYER);
                num_--;
            };
            var array:Array = [];
            num_ = num;
            if (points){
                num_ = points.length;
            };
            dir = [1, -1];
            timer = new Timer(delay);
            timer.addEventListener(TimerEvent.TIMER, timeFunc);
            timer.start();
        }

        public static function getPoints(_arg_1:Number, _arg_2:Number, _arg_3:int):Array
        {
            var _local_4:int = 50;
            var _local_5:Array = [];
            var _local_6:Point = new Point((_arg_1 - _arg_3), _arg_2);
            _local_5.push(_local_6);
            _local_6 = new Point((_arg_1 + _local_4), (_arg_2 - (_arg_3 / 2)));
            _local_5.push(_local_6);
            _local_6 = new Point((_arg_1 - _local_4), (_arg_2 - (_arg_3 / 2)));
            _local_5.push(_local_6);
            _local_6 = new Point((_arg_1 + _arg_3), _arg_2);
            _local_5.push(_local_6);
            _local_6 = new Point((_arg_1 + _local_4), (_arg_2 + (_arg_3 / 2)));
            _local_5.push(_local_6);
            _local_6 = new Point((_arg_1 - _local_4), (_arg_2 + (_arg_3 / 2)));
            _local_5.push(_local_6);
            return (_local_5);
        }

        public static function lineAttack(effect_id:int, startPoint:Point, endPoint:Point, delay:int=100, interval:int=45, playEndFunc:Function=null):void
        {
            var array:Array;
            var arr:Array;
            var timer:Timer;
            var timeFunc:Function;
            timeFunc = function ():void
            {
                if (array.length <= 0){
                    timer.stop();
                    timer.removeEventListener(TimerEvent.TIMER, timeFunc);
                    if (playEndFunc != null){
                        playEndFunc();
                    };
                    return;
                };
                var _local_1:Point = array.shift();
                _local_1.x = (_local_1.x + (((Math.random() * 1) >> 0) * arr[((Math.random() * 2) >> 0)]));
                _local_1.y = (_local_1.y + (((Math.random() * 1) >> 0) * arr[((Math.random() * 2) >> 0)]));
                var _local_2:ItemAvatar = getEffect(effect_id, _local_1, null, SceneConstant.BOTTOM_LAYER);
            };
            array = LinearAndFan.lineAttck(startPoint, endPoint, interval);
            arr = [1, -1];
            timer = new Timer(delay);
            timer.start();
            timer.addEventListener(TimerEvent.TIMER, timeFunc);
        }

        public static function attackToPoint(speed:Number, pass_effect:int, startPoint:Point, endPoint:Point, playEndFunc:Function=null):void
        {
            var _playEndFunc:Function;
            var effect:ItemAvatar;
            var alpha_time:int;
            var onCompleteFunc:Function;
            onCompleteFunc = function ():void
            {
                TweenLite.killTweensOf(effect);
                if (effect.parent){
                    effect.parent.removeChild(effect);
                };
                effect.dispose();
                if (_playEndFunc != null){
                    _playEndFunc();
                };
            };
            _playEndFunc = playEndFunc;
            var p:Point = LinearAndFan.pointBetweenPoint(endPoint, startPoint, -100);
            p.y = (p.y - 60);
            effect = getEffect(pass_effect, p, startPoint, SceneConstant.TOP_LAYER);
            var _x:int = endPoint.x;
            var _y:int = endPoint.y;
            var start_time:Number = getTimer();
            var dis:int = Point.distance(effect.point, endPoint);
            var time:Number = ((dis / speed) - 0.1);
            TweenLite.to(effect, time, {
                "x":_x,
                "y":_y,
                "ease":Linear.easeNone,
                "onComplete":onCompleteFunc
            });
        }

        public static function attackToTarget(speed:Number, pass_effect:int, startPoint:Point, attatched:Char, playEndFunc:Function=null):void
        {
            var _playEndFunc:Function;
            var effect:ItemAvatar;
            var _x:int;
            var _y:int;
            var time:Number;
            var alpha_time:int;
            var onUpdateFunc:Function;
            var onCompleteFunc:Function;
            onUpdateFunc = function (_arg_1:Char):void
            {
                var _local_2:Point;
                var _local_3:int;
                if (((_arg_1) && (_arg_1.point))){
                    if (((!((_x == _arg_1.x))) || (!((_y == _arg_1.y))))){
                        _local_2 = new Point(_arg_1.x, (_arg_1.y - 60));
                        _local_3 = Point.distance(effect.point, _local_2);
                        if ((((_local_3 < 5)) || ((_local_3 > 700)))){
                            TweenLite.killTweensOf(effect);
                            if (effect.parent){
                                effect.parent.removeChild(effect);
                            };
                            effect.dispose();
                            if (_playEndFunc != null){
                                _playEndFunc();
                            };
                        } else {
                            _x = _arg_1.x;
                            _y = (_arg_1.y - 60);
                            start_time = getTimer();
                            time = (_local_3 / speed);
                            TweenLite.killTweensOf(effect);
                            TweenLite.to(effect, time, {
                                "x":_x,
                                "y":_y,
                                "ease":Linear.easeNone,
                                "onUpdate":onUpdateFunc,
                                "onUpdateParams":[_arg_1],
                                "onComplete":onCompleteFunc
                            });
                        };
                    };
                } else {
                    TweenLite.killTweensOf(effect);
                    if (effect.parent){
                        effect.parent.removeChild(effect);
                    };
                    effect.dispose();
                    if (_playEndFunc != null){
                        _playEndFunc();
                    };
                };
                effect.setRotation(_x, _y);
            };
            onCompleteFunc = function ():void
            {
                TweenLite.killTweensOf(effect);
                if (effect.parent){
                    effect.parent.removeChild(effect);
                };
                effect.dispose();
                if (_playEndFunc != null){
                    _playEndFunc();
                };
            };
            if (!attatched){
                return;
            };
            if (((attatched) && (attatched.isDeath))){
                return;
            };
            _playEndFunc = playEndFunc;
            var p:Point = LinearAndFan.pointBetweenPoint(new Point(attatched.x, attatched.y), startPoint, -60);
            p.y = (p.y - 60);
            effect = getEffect(pass_effect, p, startPoint, SceneConstant.TOP_LAYER);
            _x = attatched.x;
            _y = (attatched.y - 60);
            var start_time:Number = getTimer();
            var dis:int = Point.distance(effect.point, new Point(attatched.x, attatched.y));
            time = (dis / speed);
            if (dis < 700){
                TweenLite.to(effect, time, {
                    "x":_x,
                    "y":_y,
                    "ease":Linear.easeNone,
                    "onUpdate":onUpdateFunc,
                    "onUpdateParams":[attatched],
                    "onComplete":onCompleteFunc
                });
            } else {
                TweenLite.killTweensOf(effect);
                if (effect.parent){
                    effect.parent.removeChild(effect);
                };
                effect.dispose();
                if (_playEndFunc != null){
                    (_playEndFunc());
                };
            };
        }

        public static function fanAttack(pass_effect:int, startPoint:Point, endPoint:Point, size:int=90, num:int=3, delay:int=100, minRadius:int=-1):void
        {
            var time:Number;
            var effect:ItemAvatar;
            var _x:int;
            var _y:int;
            var arr:Array;
            var timer:Timer;
            var dis:int = Point.distance(startPoint, endPoint);
            time = (dis / 600);
            if (num == 1){
                effect = getEffect(pass_effect, startPoint, new Point(startPoint.x, (startPoint.y - 60)), SceneConstant.TOP_LAYER);
                _x = endPoint.x;
                _y = (endPoint.y - 60);
                TweenLite.to(effect, time, {
                    "x":_x,
                    "y":_y,
                    "ease":Linear.easeNone,
                    "onUpdate":function ():void
                    {
                        effect.setRotation(_x, _y);
                    },
                    "onComplete":function (_arg_1:ItemAvatar):void
                    {
                        if (_arg_1.parent){
                            _arg_1.parent.removeChild(_arg_1);
                        };
                        _arg_1.dispose();
                    },
                    "onCompleteParams":[effect]
                });
            } else {
                var timeFunction:Function = function (e:TimerEvent):void
                {
                    if (arr.length <= 0){
                        timer.stop();
                        return;
                    };
                    var p:Point = arr.shift();
                    var _x:int = p.x;
                    var _y:int = p.y;
                    effect = getEffect(pass_effect, startPoint, p, SceneConstant.TOP_LAYER);
                    TweenLite.to(effect, time, {
                        "x":_x,
                        "y":_y,
                        "ease":Linear.easeNone,
                        "onComplete":function (_arg_1:ItemAvatar):void
                        {
                            if (_arg_1.parent){
                                _arg_1.parent.removeChild(_arg_1);
                            };
                            _arg_1.dispose();
                        },
                        "onCompleteParams":[effect]
                    });
                };
                if ((time < 0.5)){
                    time = 0.5;
                };
                startPoint.y = (startPoint.y - 50);
                endPoint.y = (endPoint.y - 50);
                arr = LinearAndFan.sectorAttack(startPoint, endPoint, size, num, minRadius);
                timer = new Timer(delay);
                timer.addEventListener(TimerEvent.TIMER, timeFunction);
                timer.start();
            };
        }

        public static function getEffect(_arg_1:int, _arg_2:Point, _arg_3:Point=null, _arg_4:String=null):ItemAvatar
        {
            var _local_5:ItemAvatar = new ItemAvatar();
            _local_5.isSkillEffect = true;
            _local_5.isSceneItem = true;
            var _local_6:String = (((Core.hostPath + "assets/avatars/effects/eid_") + _arg_1) + Core.TMP_FILE);
            _local_5.loadAvatarPart(_local_6);
            _local_5.x = _arg_2.x;
            _local_5.y = _arg_2.y;
            if (_arg_3){
                _local_5.setRotation(_arg_3.x, _arg_3.y);
            };
            if (_arg_4 != null){
                GameScene.scene.addItem(_local_5, _arg_4);
            };
            return (_local_5);
        }


    }
}//package 

