package com.engine.utils.gome
{
	import com.engine.core.tile.TileConst;
	import com.engine.core.tile.square.SquarePt;
	
	import flash.geom.Point;

	public class SquareUitls 
	{

		public static function xyToSquare(_arg_1:Number, _arg_2:Number):SquarePt
		{
			return (new SquarePt(int((_arg_1 / TileConst.TILE_SIZE)), int((_arg_2 / TileConst.TILE_SIZE))));
		}

		public static function pixelsToSquare(_arg_1:Point):SquarePt
		{
			return (new SquarePt(int((_arg_1.x / TileConst.TILE_SIZE)), int((_arg_1.y / TileConst.TILE_SIZE))));
		}

		public static function squareTopixels(_arg_1:SquarePt):Point
		{
			return (_arg_1.pixelsPoint);
		}

	}
}
