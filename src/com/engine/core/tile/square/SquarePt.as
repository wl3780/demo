package com.engine.core.tile.square
{
	import com.engine.core.tile.TileConst;
	
	import flash.geom.Point;
	import flash.net.registerClassAlias;

	public class SquarePt 
	{

		private var _x:int;
		private var _y:int;

		public function SquarePt(px:int=0, py:int=0)
		{
			registerClassAlias("sai.save.core.tile.SquarePt", SquarePt);
			this.x = px;
			this.y = py;
		}

		public static function pixelsDistance(ptA:SquarePt, ptB:SquarePt):Number
		{
			var ax:Number = ptA.x * TileConst.TILE_WIDTH + TileConst.WH;
			var bx:Number = ptB.x * TileConst.TILE_WIDTH + TileConst.WH;
			var ay:Number = ptA.y * TileConst.TILE_WIDTH + TileConst.HH;
			var by:Number = ptB.y * TileConst.TILE_WIDTH + TileConst.HH;
			return Point.distance(new Point(ax, ay), new Point(bx, by));
		}


		public function get y():int
		{
			return _y;
		}

		public function set y(val:int):void
		{
			_y = val;
		}

		public function get x():int
		{
			return _x;
		}

		public function set x(val:int):void
		{
			_x = val;
		}

		public function get key():String
		{
			return this.x + "|" + this.y;
		}

		public function get pixelsPoint():Point
		{
			var px:Number = (this.x * TileConst.TILE_WIDTH + TileConst.WH) >> 0;
			var py:Number = (this.y * TileConst.TILE_HEIGHT + TileConst.HH) >> 0;
			return new Point(px, py);
		}

		public function toString():String
		{
			return "[SquarePt(" + this.x + "," + this.y + ")]";
		}

	}
}
