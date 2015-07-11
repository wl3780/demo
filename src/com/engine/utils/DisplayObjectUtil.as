package com.engine.utils
{
	import flash.geom.Matrix;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;

	public class DisplayObjectUtil 
	{

		public static function drawTransformBitmap(_arg_1:DisplayObject, _arg_2:Number, _arg_3:Number, _arg_4:Boolean=false):BitmapData
		{
			var _local_5:Matrix = getFitMatrix(_arg_2, _arg_3, _arg_1.width, _arg_1.height, _arg_4);
			var _local_6:BitmapData = new BitmapData(_arg_2, _arg_3, true, 0);
			_local_6.draw(_arg_1, _local_5, null, null, null, true);
			return (_local_6);
		}

		public static function getFitMatrix(_arg_1:Number, _arg_2:Number, _arg_3:Number, _arg_4:Number, _arg_5:Boolean=false):Matrix
		{
			var _local_6:Number = getScale(_arg_1, _arg_2, _arg_3, _arg_4);
			if (_arg_5) {
				_local_6 = 1;
			}
			var _local_7:Matrix = new Matrix();
			_local_7.scale(_local_6, _local_6);
			var _local_8:Number = ((_arg_1 - (_arg_3 * _local_6)) / 2);
			var _local_9:Number = ((_arg_2 - (_arg_4 * _local_6)) / 2);
			_local_7.tx = (_local_7.tx + _local_8);
			_local_7.ty = (_local_7.ty + _local_9);
			return (_local_7);
		}

		public static function getScale(_arg_1:Number, _arg_2:Number, _arg_3:Number, _arg_4:Number):Number
		{
			var _local_5:Number;
			var _local_6:Number;
			var _local_7:Number = (_arg_3 - _arg_4);
			var _local_8:Number = (_arg_1 - _arg_2);
			if ((_local_8 < 0)) {
				_local_5 = _arg_1;
			} else {
				_local_5 = _arg_2;
			}
			if ((_local_7 > 0)) {
				_local_6 = (_local_5 / _arg_3);
			} else {
				_local_6 = (_local_5 / _arg_4);
			}
			return (_local_6);
		}

		
		public static function liangdu(num:Number):Array
		{
			return [
				1, 0, 0, 0, num,
				0, 1, 0, 0, num,
				0, 0, 1, 0, num,
				0, 0, 0, 1, 0];
		}
		
	}
}
