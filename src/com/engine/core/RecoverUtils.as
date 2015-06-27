package com.engine.core
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class RecoverUtils 
	{

		private static var _mat_:Matrix = new Matrix();
		private static var _point_:Point = new Point();
		private static var _rect_:Rectangle = new Rectangle();

		public static function get matrix():Matrix
		{
			_mat_.identity();
			return _mat_;
		}

		public static function get point():Point
		{
			_point_.x = 0;
			_point_.y = 0;
			return _point_;
		}

		public static function get rect():Rectangle
		{
			_rect_.setEmpty();
			return _rect_;
		}

	}
}
