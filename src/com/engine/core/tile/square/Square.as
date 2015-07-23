package com.engine.core.tile.square
{
	import com.engine.core.tile.TileConst;
	
	import flash.display.Graphics;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsPathWinding;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;

	public class Square 
	{

		private static var squareHash:Vector.<Square> = new Vector.<Square>();

		public var type:int;
		public var color:uint;
		public var isSell:Boolean;
		public var isSafe:Boolean;
		public var isAlpha:Boolean;
		
		private var _index:SquarePt;

		public function Square()
		{
			registerClassAlias("sai.save.tile.Square", Square);
		}

		public static function createSquare():Square
		{
			var sq:Square;
			if (squareHash.length) {
				sq = squareHash.pop();
			} else {
				sq = new Square();
			}
			return sq;
		}


		public function setIndex(val:SquarePt):void
		{
			_index = val;
		}

		public function get index():SquarePt
		{
			return _index;
		}

		public function setXY(px:int, py:int):void
		{
			if (_index == null) {
				_index = new SquarePt();
			}
			if (px != _index.x) {
				_index.x = px;
			}
			if (py != _index.y) {
				_index.y = py;
			}
		}

		public function get y():int
		{
			if (_index == null) {
				_index = new SquarePt();
			}
			return _index.y;
		}

		public function set y(val:int):void
		{
			if (_index == null) {
				_index = new SquarePt();
			}
			if (_index.y != val) {
				_index.y = val;
			}
		}

		public function get x():int
		{
			if (_index == null) {
				_index = new SquarePt();
			}
			return _index.x;
		}

		public function set x(val:int):void
		{
			if (_index == null) {
				_index = new SquarePt();
			}
			if (_index.x != val) {
				_index.x = val;
			}
		}

		public function get key():String
		{
			if (_index) {
				return _index.key;
			} else {
				return this.x + "|" + this.y;
			}
		}

		public function toString():String
		{
			return "[Square:" + this.key + "]";
		}

		public function get top_left():Point
		{
			var px:Number = TileConst.TILE_SIZE * this.x;
			var py:Number = TileConst.TILE_SIZE * this.y;
			return new Point(px, py);
		}

		public function get top_right():Point
		{
			var px:Number = TileConst.TILE_SIZE * (this.x + 1);
			var py:Number = TileConst.TILE_SIZE * this.y;
			return new Point(px, py);
		}

		public function get bottom_left():Point
		{
			var px:Number = TileConst.TILE_SIZE * this.x;
			var py:Number = TileConst.TILE_SIZE * (this.y + 1);
			return new Point(px, py);
		}

		public function get bottom_right():Point
		{
			var px:Number = TileConst.TILE_SIZE * (this.x + 1);
			var py:Number = TileConst.TILE_SIZE * (this.y + 1);
			return new Point(px, py);
		}

		public function get midVertex():Point
		{
			var midX:Number = (TileConst.TILE_SIZE * this.x) - (TileConst.TILE_SIZE / 2);
			var midY:Number = (TileConst.TILE_SIZE * this.y) - (TileConst.TILE_SIZE / 2);
			return new Point(midX, midY);
		}

		public function getBounds():Rectangle
		{
			var px:Number = this.x * TileConst.TILE_SIZE;
			var py:Number = this.y * TileConst.TILE_SIZE;
			var pw:Number = TileConst.TILE_SIZE;
			var ph:Number = TileConst.TILE_SIZE;
			return new Rectangle(px, py, pw, ph);
		}

		public function drawCenterPoint(pen:Graphics, color:uint, radius:int=3, alpha:Number=0.5):void
		{
			pen.beginFill(color, alpha);
			pen.drawCircle(this.midVertex.x, this.midVertex.y, radius);
		}

		public function draw2(pen:Graphics):void
		{
			var offset:Number = 0.5;
			pen.moveTo((this.top_left.x + offset), (this.top_left.y + offset));
			pen.lineTo((this.top_right.x - offset), (this.top_right.y + offset));
			pen.lineTo((this.bottom_right.x - offset), (this.bottom_right.y - offset));
			pen.lineTo((this.bottom_left.x + offset), (this.bottom_left.y - offset));
			pen.lineTo((this.top_left.x + offset), (this.top_left.y + offset));
		}

		public function draw(pen:Graphics, color:uint, isFill:Boolean=false, fillColor:uint=0, fillAlpha:Number=0.5):void
		{
			var cmds:Vector.<int> = new Vector.<int>();
			cmds.push(GraphicsPathCommand.MOVE_TO);
			cmds.push(GraphicsPathCommand.LINE_TO);
			cmds.push(GraphicsPathCommand.LINE_TO);
			cmds.push(GraphicsPathCommand.LINE_TO);
			cmds.push(GraphicsPathCommand.LINE_TO);
			pen.lineStyle(1, color);
			if (isFill) {
				pen.beginFill(fillColor, fillAlpha);
			}
			var datas:Vector.<Number> = new Vector.<Number>();
			datas.push(this.top_left.x, this.top_left.y);
			datas.push(this.top_right.x, this.top_right.y);
			datas.push(this.bottom_right.x, this.bottom_right.y);
			datas.push(this.bottom_left.x, this.bottom_left.y);
			datas.push(this.top_left.x, this.top_left.y);
			pen.drawPath(cmds, datas, GraphicsPathWinding.NON_ZERO);
		}

		public function dispose():void
		{
			this.type = 0;
			this.isAlpha = false;
			this.isSafe = false;
			if (_index) {
				_index = null;
			}
			if (squareHash.length < 10000) {
				squareHash.push(this);
			}
		}

	}
}
