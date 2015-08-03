package 
{
	import com.engine.core.AvatarTypes;
	import com.engine.core.view.avatar.ItemAvatar;
	import com.engine.core.view.role.Char;
	import com.engine.core.view.scenes.SceneConst;
	import com.engine.utils.gome.LinearUtils;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class FightUtils 
	{

		public static function areaAttack(effect_id:String, point:Point, area:int=100, num:int=4, delay:int=150, points:Array=null):void
		{
			var num_:int;
			var dir:Array;
			var p:Point;
			var timer:Timer;
			var timeFunc:Function;
			timeFunc = function ():void
			{
				var _local_1:Point;
				if (num_ <= 0) {
					timer.stop();
					timer.removeEventListener(TimerEvent.TIMER, timeFunc);
					return;
				}
				if (points) {
					_local_1 = points.shift();
					p = _local_1;
				} else {
					p = new Point(_local_1.x, _local_1.y);
					p.x = (p.x + (((Math.random() * (area / 2)) >> 0) * dir[((Math.random() * 2) >> 0)]));
					p.y = (p.y + (((Math.random() * (area / 2)) >> 0) * dir[((Math.random() * 2) >> 0)]));
				}
				getEffect(effect_id, p, null, SceneConst.MIDDLE_LAYER);
				num_--;
			}
			var array:Array = [];
			num_ = num;
			if (points) {
				num_ = points.length;
			}
			dir = [1, -1];
			timer = new Timer(delay);
			timer.addEventListener(TimerEvent.TIMER, timeFunc);
			timer.start();
		}

		public static function lineAttack(effect_id:String, startPoint:Point, endPoint:Point, delay:int=100, interval:int=45, playEndFunc:Function=null):void
		{
			var array:Array;
			var arr:Array;
			var timer:Timer;
			var timeFunc:Function;
			timeFunc = function ():void
			{
				if (array.length <= 0) {
					timer.stop();
					timer.removeEventListener(TimerEvent.TIMER, timeFunc);
					if (playEndFunc != null) {
						playEndFunc();
					}
					return;
				}
				var _local_1:Point = array.shift();
				_local_1.x = (_local_1.x + (((Math.random() * 1) >> 0) * arr[((Math.random() * 2) >> 0)]));
				_local_1.y = (_local_1.y + (((Math.random() * 1) >> 0) * arr[((Math.random() * 2) >> 0)]));
				var _local_2:ItemAvatar = FightUtils.getEffect(effect_id, _local_1, null, SceneConst.BOTTOM_LAYER);
			}
			array = LinearUtils.lineAttck(startPoint, endPoint, interval);
			arr = [1, -1];
			timer = new Timer(delay);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, timeFunc);
		}

		public static function attackToPoint(speed:Number, pass_effect:String, startPoint:Point, endPoint:Point, playEndFunc:Function=null):void
		{
			var _playEndFunc:Function;
			var effect:ItemAvatar;
			var alpha_time:int;
			var onCompleteFunc:Function;
			onCompleteFunc = function ():void
			{
				TweenLite.killTweensOf(effect);
				if (effect.parent) {
					effect.parent.removeChild(effect);
				}
				effect.dispose();
				if (_playEndFunc != null) {
					_playEndFunc();
				}
			}
			_playEndFunc = playEndFunc;
			var p:Point = LinearUtils.pointBetweenPoint(endPoint, startPoint, -100);
			p.y = (p.y - 60);
			effect = getEffect(pass_effect, p, startPoint, SceneConst.TOP_LAYER);
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

		public static function attackToTarget(speed:Number, pass_effect:String, startPoint:Point, attatched:Char, playEndFunc:Function=null):void
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
				if (((_arg_1) && (_arg_1.point))) {
					if (((!((_x == _arg_1.x))) || (!((_y == _arg_1.y))))) {
						_local_2 = new Point(_arg_1.x, (_arg_1.y - 60));
						_local_3 = Point.distance(effect.point, _local_2);
						if ((((_local_3 < 5)) || ((_local_3 > 700)))) {
							TweenLite.killTweensOf(effect);
							if (effect.parent) {
								effect.parent.removeChild(effect);
							}
							effect.dispose();
							if (_playEndFunc != null) {
								_playEndFunc();
							}
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
						}
					}
				} else {
					TweenLite.killTweensOf(effect);
					if (effect.parent) {
						effect.parent.removeChild(effect);
					}
					effect.dispose();
					if (_playEndFunc != null) {
						_playEndFunc();
					}
				}
				effect.setRotation(_x, _y);
			}
			onCompleteFunc = function ():void
			{
				TweenLite.killTweensOf(effect);
				if (effect.parent) {
					effect.parent.removeChild(effect);
				}
				effect.dispose();
				if (_playEndFunc != null) {
					_playEndFunc();
				}
			}
			if (!attatched) {
				return;
			}
			if (((attatched) && (attatched.isDeath))) {
				return;
			}
			_playEndFunc = playEndFunc;
			var p:Point = LinearUtils.pointBetweenPoint(new Point(attatched.x, attatched.y), startPoint, -60);
			p.y = (p.y - 60);
			effect = getEffect(pass_effect, p, startPoint, SceneConst.TOP_LAYER);
			_x = attatched.x;
			_y = (attatched.y - 60);
			var start_time:Number = getTimer();
			var dis:int = Point.distance(effect.point, new Point(attatched.x, attatched.y));
			time = (dis / speed);
			if (dis < 700) {
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
				if (effect.parent) {
					effect.parent.removeChild(effect);
				}
				effect.dispose();
				if (_playEndFunc != null) {
					(_playEndFunc());
				}
			}
		}

		public static function fanAttack(pass_effect:String, startPoint:Point, endPoint:Point, size:int=90, num:int=3, delay:int=100, minRadius:int=-1):void
		{
			var time:Number;
			var effect:ItemAvatar;
			var _x:int;
			var _y:int;
			var arr:Array;
			var timer:Timer;
			var dis:int = Point.distance(startPoint, endPoint);
			time = (dis / 600);
			if (num == 1) {
				effect = getEffect(pass_effect, startPoint, new Point(startPoint.x, (startPoint.y - 60)), SceneConst.TOP_LAYER);
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
						if (_arg_1.parent) {
							_arg_1.parent.removeChild(_arg_1);
						}
						_arg_1.dispose();
					},
					"onCompleteParams":[effect]
				});
			} else {
				var timeFunction:Function = function (e:TimerEvent):void
				{
					if (arr.length <= 0) {
						timer.stop();
						return;
					}
					var p:Point = arr.shift();
					var _x:int = p.x;
					var _y:int = p.y;
					effect = getEffect(pass_effect, startPoint, p, SceneConst.TOP_LAYER);
					TweenLite.to(effect, time, {
						"x":_x,
						"y":_y,
						"ease":Linear.easeNone,
						"onComplete":function (_arg_1:ItemAvatar):void
						{
							if (_arg_1.parent) {
								_arg_1.parent.removeChild(_arg_1);
							}
							_arg_1.dispose();
						},
						"onCompleteParams":[effect]
					});
				}
				if ((time < 0.5)) {
					time = 0.5;
				}
				startPoint.y = (startPoint.y - 50);
				endPoint.y = (endPoint.y - 50);
				arr = LinearUtils.sectorAttack(startPoint, endPoint, size, num, minRadius);
				timer = new Timer(delay);
				timer.addEventListener(TimerEvent.TIMER, timeFunction);
				timer.start();
			}
		}

		public static function getEffect(effect_id:String, _arg_2:Point, _arg_3:Point=null, _arg_4:String=null):ItemAvatar
		{
			var avatar:ItemAvatar = new ItemAvatar();
			avatar.isSkillEffect = true;
			avatar.isSceneItem = true;
			avatar.loadAvatarPart(AvatarTypes.EFFECT_TYPE, effect_id);
			avatar.x = _arg_2.x;
			avatar.y = _arg_2.y;
			if (_arg_3) {
				avatar.setRotation(_arg_3.x, _arg_3.y);
			}
			if (_arg_4 != null) {
				GameScene.scene.addItem(avatar, _arg_4);
			}
			return avatar;
		}

	}
}
