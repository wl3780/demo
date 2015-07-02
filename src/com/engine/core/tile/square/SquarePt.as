package com.engine.core.tile.square
{
	import com.engine.core.tile.TileConstant;
	
	import flash.geom.Point;
	import flash.net.registerClassAlias;

	public class SquarePt 
	{

		private static var size:Number = TileConstant.TILE_SIZE / 2;

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
			var ax:Number = ptA.x * TileConstant.TILE_SIZE + size;
			var bx:Number = ptB.x * TileConstant.TILE_SIZE + size;
			var ay:Number = ptA.y * TileConstant.TILE_SIZE + size;
			var by:Number = ptB.y * TileConstant.TILE_SIZE + size;
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
			var px:Number = Number(Number(this.x * TileConstant.TILE_SIZE + size).toFixed(1));
			var py:Number = Number(Number(this.y * TileConstant.TILE_SIZE + size).toFixed(1));
			return new Point(px, py);
		}

		public function toString():String
		{
			return "[SquarePt(" + this.x + "," + this.y + ")]";
		}

	}
}
