﻿package 
{
	import com.engine.core.AvatarUnitTypes;
	import com.engine.core.tile.square.Square;
	import com.engine.core.tile.square.SquareGroup;
	import com.engine.core.tile.square.SquarePt;
	import com.engine.core.view.avatar.Avatar;
	import com.engine.core.view.role.Char;
	import com.engine.utils.Bezier;
	import com.engine.utils.gome.SquareUitls;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;

	public class SceneUtil 
	{

		public static function updataCharParts(_arg_1:Avatar, _arg_2:String=null, _arg_3:String=null, _arg_4:String=null):void
		{
			if (((!(_arg_1)) || (!(_arg_1.avatarParts)))) {
				return;
			}
			_arg_1.loadAvatarPart(AvatarUnitTypes.BODY_TYPE, _arg_2);
			_arg_1.loadAvatarPart(AvatarUnitTypes.WEAPON_TYPE, _arg_3);
			_arg_1.loadAvatarPart(AvatarUnitTypes.MOUNT_TYPE, _arg_4);
			_arg_1.avatarParts.bodyRender(true);
		}

		public static function getJumpPath(pt_from:Point, pt_to:Point, time:int=5, _arg_4:int=300):Array
		{
			var range:int = 400;
			GameScene.scene.$topLayer.graphics.clear();
			var distance:Number = Point.distance(pt_from, pt_to);
			var speed:int = Math.ceil(distance / time);
			var sp:int = speed;
			if (sp > (range / time)) {
				sp = (range / time);
			}
			var pt_start:Point = pt_from;
			var pt_end:Point = pt_to;
			var tp_end:SquarePt = SquareUitls.pixelsToSquare(pt_end);
			var sq:Square = SquareGroup.getInstance().take(tp_end.key);
			if (sq == null || sq.type < 1) {
				pt_start = pt_from;
			}
			
			var p:Point;
			var pt:SquarePt;
			var _local_23:Square;
			var _local_14:int;
			var _local_15:int;
			var tmp:int = sp;
			while (tmp > 0) {
				p = Point.interpolate(pt_to, pt_from, (tmp / speed));
				pt = SquareUitls.pixelsToSquare(p);
				_local_23 = SquareGroup.getInstance().take(pt.key);
				_local_14++;
				if (((_local_23) && ((int(_local_23.type) > 0)))) {
					pt_end = p;
					if (++_local_15 > 1)
						break;
				}
				tmp--;
			}
			if (_local_14 >= sp) {
				return ([]);
			}
			distance = Point.distance(pt_start, pt_end);
			var _local_17:Point = Point.interpolate(pt_start, pt_end, 0.5);
			var _local_18:int = Math.abs((pt_start.x - pt_end.x));
			var _local_19:int = Math.abs((pt_start.y - pt_end.y));
			var _local_20:int = (pt_start.y - pt_end.y);
			if ((_local_20 > 0)) {
				_local_20 = 1;
			} else {
				_local_20 = -1;
			}
			if ((_local_20 > 0)) {
				_local_17.y = pt_end.y;
			} else {
				_local_17.y = pt_end.y;
			}
			_local_17.y = (_local_17.y - _arg_4);
			var _local_21:Array = Bezier.drawBezier(pt_start, pt_end, _local_17, 50);
			if (_local_21[(_local_21.length - 1)].toString() != pt_end.toString()) {
				_local_21.push(pt_end);
			}
			return _local_21;
		}

		public static function getTeleportPath(_arg_1:Point, _arg_2:Point, _arg_3:int=5):Point
		{
			var _local_8:Point;
			var _local_13:SquarePt;
			var _local_14:Square;
			var _local_4:int = 400;
			var _local_5:Number = Point.distance(_arg_1, _arg_2);
			var _local_6:int = Math.ceil((_local_5 / _arg_3));
			var _local_7:int = _local_6;
			if (_local_7 > (_local_4 / _arg_3)) {
				_local_7 = (_local_4 / _arg_3);
			}
			var _local_9:Point = _arg_1;
			var _local_10:Point = _arg_2;
			var _local_11:int;
			var _local_12:int = _local_7;
			while (_local_12 > 0) {
				_local_8 = Point.interpolate(_arg_2, _arg_1, (_local_12 / _local_6));
				_local_13 = SquareUitls.pixelsToSquare(_local_8);
				_local_14 = SquareGroup.getInstance().take(_local_13.key);
				if (((_local_14) && ((_local_14.type > 0)))) {
					_local_10 = _local_8;
					break;
				}
				_local_12--;
			}
			return (_local_10);
		}

		public static function getFlyPath(_arg_1:Point, _arg_2:Point, _arg_3:int=30):Array
		{
			var _local_9:Point;
			var _local_16:SquarePt;
			var _local_17:Square;
			var _local_20:SquarePt;
			var _local_21:Square;
			var _local_4:int = 400;
			var _local_5:Array = [];
			var _local_6:Number = Point.distance(_arg_1, _arg_2);
			var _local_7:int = Math.ceil((_local_6 / _arg_3));
			var _local_8:int = _local_7;
			if (_local_8 > (_local_4 / _arg_3)) {
				_local_8 = (_local_4 / _arg_3);
			}
			var _local_10:Point = _arg_1;
			var _local_11:Point = _arg_1;
			var _local_12:int;
			var _local_13:int = _local_8;
			while (_local_13 > 0) {
				_local_9 = Point.interpolate(_arg_2, _arg_1, (_local_13 / _local_7));
				_local_20 = SquareUitls.pixelsToSquare(_local_9);
				_local_21 = SquareGroup.getInstance().take(_local_20.key);
				_local_12++;
				if (((_local_21) && ((_local_21.type > 0)))) {
					_local_11 = _local_9;
					break;
				}
				_local_13--;
			}
			if ((((_local_12 >= _local_8)) || ((_local_10.toString() == _local_11.toString())))) {
				return ([]);
			}
			var _local_14:int = Point.distance(_arg_1, _local_11);
			var _local_15:int = Math.ceil((_local_14 / _arg_3));
			var _local_18:Dictionary = new Dictionary();
			var _local_19:int;
			while (_local_19 < _local_15) {
				_local_9 = Point.interpolate(_local_11, _arg_1, (_local_19 / _local_15));
				if (((!((_local_19 == 0))) && (!((_local_19 == (_local_15 - 1)))))) {
					_local_9.y = (_local_9.y - 20);
				}
				_local_5.push(_local_9);
				_local_19++;
			}
			_local_5.push(_local_11);
			return (_local_5);
		}

		public static function getDretion(_arg_1:SquarePt, _arg_2:SquarePt):int
		{
			var _local_3:int;
			var _local_4:Number = (_arg_1.x - _arg_2.x);
			var _local_5:Number = (_arg_1.y - _arg_2.y);
			var _local_6:Number = ((Math.atan2(_local_5, _local_4) * 180) / Math.PI);
			if ((((_local_6 >= -15)) && ((_local_6 < 15)))) {
				_local_3 = 2;
			} else {
				if ((((_local_6 >= 15)) && ((_local_6 < 75)))) {
					_local_3 = 3;
				} else {
					if ((((_local_6 >= 75)) && ((_local_6 < 105)))) {
						_local_3 = 4;
					} else {
						if ((((_local_6 >= 105)) && ((_local_6 < 170)))) {
							_local_3 = 5;
						} else {
							if ((((_local_6 >= 170)) || ((_local_6 < -170)))) {
								_local_3 = 6;
							} else {
								if ((((_local_6 >= -75)) && ((_local_6 < -15)))) {
									_local_3 = 1;
								} else {
									if ((((_local_6 >= -105)) && ((_local_6 < -75)))) {
										_local_3 = 0;
									} else {
										if ((((_local_6 >= -170)) && ((_local_6 < -105)))) {
											_local_3 = 7;
										}
									}
								}
							}
						}
					}
				}
			}
			return (_local_3);
		}

		public static function setCharAttackSpeed(_arg_1:Char, _arg_2:Number):Number
		{
			var _local_3:Number = 0;
			if (_arg_1) {
				if (_arg_2 > 3000) {
					_arg_2 = 3000;
				}
				if ((((_arg_2 >= 701)) && ((_arg_2 <= 3000)))) {
					_local_3 = (1 + ((700 - _arg_2) / 4600));
					_arg_1.avatarParts.attackSpeed = _local_3;
				} else {
					if (_arg_2 < 701) {
						_local_3 = 1;
						_arg_1.avatarParts.attackSpeed = _local_3;
					}
				}
			}
			return (_local_3);
		}

		public static function getNextPassCell(_arg_1:Point):SquarePt
		{
			var _local_2:Square;
			var _local_3:Square;
			var _local_4:Square;
			var _local_5:Square;
			var _local_6:Square;
			var _local_7:Square;
			var _local_8:Square;
			var _local_9:Square;
			var _local_10:Square;
			var _local_16:int;
			var _local_17:int;
			var _local_18:Square;
			var _local_19:Point;
			var _local_20:int;
			var _local_11:Array = [];
			var _local_12:SquarePt = SquareUitls.pixelsToSquare(_arg_1);
			var _local_13:Dictionary = SquareGroup.getInstance().hash;
			if (_local_13) {
				_local_16 = _local_12.x;
				_local_17 = _local_12.y;
				_local_10 = _local_13[((_local_16 + "|") + _local_17)];
				_local_2 = _local_13[((_local_16 + "|") + (_local_17 - 1))];
				_local_3 = _local_13[(((_local_16 - 1) + "|") + _local_17)];
				_local_4 = _local_13[(((_local_16 + 1) + "|") + _local_17)];
				_local_5 = _local_13[((_local_16 + "|") + (_local_17 + 1))];
				_local_6 = _local_13[(((_local_16 - 1) + "|") + (_local_17 - 1))];
				_local_7 = _local_13[(((_local_16 + 1) + "|") + (_local_17 - 1))];
				_local_8 = _local_13[(((_local_16 - 1) + "|") + (_local_17 + 1))];
				_local_9 = _local_13[(((_local_16 + 1) + "|") + (_local_17 + 1))];
				if (_local_2) {
					_local_11.push(_local_2);
				}
				if (_local_6) {
					_local_11.push(_local_6);
				}
				if (_local_7) {
					_local_11.push(_local_7);
				}
				if (_local_4) {
					_local_11.push(_local_4);
				}
				if (_local_3) {
					_local_11.push(_local_3);
				}
				if (_local_5) {
					_local_11.push(_local_5);
				}
				if (_local_8) {
					_local_11.push(_local_8);
				}
				if (_local_9) {
					_local_11.push(_local_9);
				}
			}
			var _local_14:Array = [];
			var _local_15:int;
			while (_local_15 < _local_11.length) {
				_local_18 = _local_11[_local_15];
				_local_19 = SquareUitls.squareTopixels(_local_18.index);
				_local_20 = Point.distance(_local_19, _arg_1);
				_local_14.push({
					"dis":_local_20,
					"sq":new SquarePt(_local_18.x, _local_18.y)
				});
				_local_15++;
			}
			if (_local_14.length) {
				_local_14.sortOn("dis", Array.DESCENDING);
				return (_local_14[0].sq);
			}
			return (_local_12);
		}

	}
}
