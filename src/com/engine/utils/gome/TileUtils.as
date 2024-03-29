﻿package com.engine.utils.gome
{
	import com.engine.core.tile.Pt;
	import com.engine.core.tile.TileConst;
	
	import flash.geom.Point;

	public class TileUtils 
	{

		public static const CORRECT_VALUE:Number = (Math.cos((-(Math.PI) / 6)) * Math.SQRT2);

		public static function isoToFlat(_arg_1:Pt):Point
		{
			var _local_2:Number = (_arg_1.x - _arg_1.z);
			var _local_3:Number = ((_arg_1.y * CORRECT_VALUE) + ((_arg_1.x + _arg_1.z) * 0.5));
			return (new Point(_local_2, _local_3));
		}

		public static function flatToIso(_arg_1:Point, _arg_2:Number=0):Pt
		{
			var _local_3:Number = (_arg_1.y + (_arg_1.x * 0.5));
			var _local_4:Number = _arg_2;
			var _local_5:Number = (_arg_1.y - (_arg_1.x * 0.5));
			return (new Pt(_local_3, _local_4, _local_5));
		}

		public static function indexToFlat(_arg_1:Pt, _arg_2:Number=-1):Point
		{
			if (_arg_2 == -1) {
				_arg_2 = TileConst.TILE_SIZE;
			}
			var _local_3:Number = (_arg_1.x - _arg_1.z);
			var _local_4:Number = ((_arg_1.y * CORRECT_VALUE) + ((_arg_1.x + _arg_1.z) * 0.5));
			return (new Point((_local_3 * _arg_2), (_local_4 * _arg_2)));
		}

		public static function getIndex(_arg_1:Point, _arg_2:Number=-1, _arg_3:Number=0):Pt
		{
			if (_arg_2 == -1) {
				_arg_2 = TileConst.TILE_SIZE;
			}
			var _local_4:Pt = flatToIso(_arg_1, _arg_3);
			_local_4.x = Math.floor((_local_4.x / _arg_2));
			_local_4.y = Math.floor((_local_4.y / _arg_2));
			_local_4.z = Math.floor((_local_4.z / _arg_2));
			return (_local_4);
		}

		public static function isoToIndex(_arg_1:Pt, _arg_2:int=-1):Pt
		{
			if (_arg_2 == -1) {
				_arg_2 = TileConst.TILE_SIZE;
			}
			return (new Pt(Math.floor((_arg_1.x / _arg_2)), Math.floor((_arg_1.y / _arg_2)), Math.floor((_arg_1.z / _arg_2))));
		}

		private static function whirlPrivate(_arg_1:Pt, _arg_2:Pt, _arg_3:int=-1):Pt
		{
			var _local_4:Number = (_arg_2.x - _arg_1.x);
			var _local_5:Number = (_arg_2.z - _arg_1.z);
			var _local_6:Number = Math.sqrt(((_local_4 * _local_4) + (_local_5 * _local_5)));
			var _local_7:Number = Math.atan2(_local_4, _local_5);
			var _local_8:Number = Math.round((_arg_1.x + (Math.sin((((_arg_3 * Math.PI) * 0.5) + _local_7)) * _local_6)));
			var _local_9:Number = Math.round((_arg_1.y + (Math.cos((((_arg_3 * Math.PI) * 0.5) + _local_7)) * _local_6)));
			var _local_10:Pt = new Pt(_local_8, 0, _local_9);
			return (_local_10);
		}

		public static function whirl(_arg_1:Pt, _arg_2:Pt, _arg_3:int=1, _arg_4:int=-1):Pt
		{
			var _local_5:Pt = _arg_2;
			var _local_6:int;
			while (_local_6 < _arg_3) {
				_local_5 = whirlPrivate(_arg_1, _local_5, _arg_4);
				_local_6++;
			}
			return (_local_5);
		}

		public static function getIsoIndexMidVertex(_arg_1:Pt):Point
		{
			var _local_2:Point = indexToFlat(_arg_1);
			return new Point(_local_2.x, (_local_2.y + TileConst.HH));
		}

		public static function getMidPoint(_arg_1:Point):Point
		{
			var _local_2:Pt = getIndex(_arg_1);
			return getIsoIndexMidVertex(_local_2);
		}

	}
}
