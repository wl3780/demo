package com.engine.utils.gome
{
	import com.engine.core.tile.TileConst;
	import com.engine.core.tile.square.SquarePt;
	
	import flash.geom.Point;

	public class SquareUitls 
	{

		public static function xyToSquare(x:Number, y:Number):SquarePt
		{
			return new SquarePt(int(x / TileConst.TILE_WIDTH), int(y / TileConst.TILE_HEIGHT));
		}

		public static function pixelsToSquare(p:Point):SquarePt
		{
			return new SquarePt(int(p.x / TileConst.TILE_WIDTH), int(p.y / TileConst.TILE_HEIGHT));
		}

		public static function squareTopixels(pt:SquarePt):Point
		{
			return pt.pixelsPoint;
		}

	}
}
