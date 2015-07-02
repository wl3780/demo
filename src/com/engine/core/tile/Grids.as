package com.engine.core.tile
{
	import flash.display.Graphics;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsPathWinding;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class Grids 
	{

		private var _rowStart:int;
		private var _rowEnd:int;
		private var _conductStart:int;
		private var _conductEnd:int;
		private var _top:Cell;
		private var _left:Cell;
		private var _right:Cell;
		private var _botton:Cell;
		private var _x:int;
		private var _y:int;

		public function Grids()
		{
			this.init();
		}

		public function init():void
		{
			_rowStart = -99999;
			_top = new Cell();
			_left = new Cell();
			_right = new Cell();
			_botton = new Cell();
		}

		public function unload():void
		{
			_top = null;
			_left = null;
			_right = null;
			_botton = null;
		}

		public function put(_arg_1:Cell, _arg_2:Boolean=true):void
		{
			if (_rowStart == -99999) {
				_rowStart = (_rowEnd = _arg_1.x);
				_conductStart = (_conductEnd = _arg_1.z);
			} else {
				if (_arg_1.x < _rowStart) {
					_rowStart = _arg_1.x;
				}
				if (_arg_1.x > _rowEnd) {
					_rowEnd = _arg_1.x;
				}
				if (_arg_1.z < _conductStart) {
					_conductStart = _arg_1.z;
				}
				if (_arg_1.z > _conductEnd) {
					_conductEnd = _arg_1.z;
				}
			}
			if (_arg_2) {
				this.setfourCell();
			}
		}

		public function prase(_arg_1:Dictionary):void
		{
			var _local_2:Cell;
			_rowStart = -99999;
			for each (_local_2 in _arg_1) {
				this.put(_local_2, false);
			}
			this.setfourCell();
		}

		private function setfourCell():void
		{
			_top.index = new Pt((_y + _rowStart), 0, (_x + _conductStart));
			_right.index = new Pt((_x + _rowEnd), 0, (_y + _conductStart));
			_left.index = new Pt((_x + _rowStart), 0, (_y + _conductEnd));
			_botton.index = new Pt((_x + _rowEnd), 0, (_y + _conductEnd));
		}

		private function cleanIt(_arg_1:Dictionary, _arg_2:Cell, _arg_3:Cell):void
		{
			var _local_4:int;
			var _local_5:int;
			var _local_6:int;
			var _local_7:int;
			var _local_8:Cell;
			if (_arg_2.x < _arg_3.x) {
				_local_6 = _arg_2.x;
			} else {
				_local_6 = _arg_3.x;
			}
			if (_arg_2.z < _arg_3.z) {
				_local_7 = _arg_2.z;
			} else {
				_local_7 = _arg_3.z;
			}
			if ((_local_6 < 0)) {
				_local_4 = -(_local_6);
			} else {
				_local_4 = 0;
			}
			if ((_local_7 < 0)) {
				_local_5 = -(_local_7);
			} else {
				_local_4 = 0;
			}
			_rowStart = -99999;
			for each (_local_8 in _arg_1) {
				_local_8.index = new Pt((_local_8.x + _local_4), _local_8.y, (_local_8.z + _local_5));
				this.put(_local_8, false);
			}
			this.setfourCell();
		}

		public function clean(_arg_1:Dictionary):Point
		{
			var _local_2:Point = new Point(this.top.leftVertex.x, this.top.leftVertex.y);
			this.cleanIt(_arg_1, this.left, this.top);
			_local_2.x = (this.top.leftVertex.x - _local_2.x);
			_local_2.y = (this.top.leftVertex.y - _local_2.y);
			return (_local_2);
		}

		public function getBounds():Rectangle
		{
			return (new Rectangle(_left.leftVertex.x, _top.topVertex.y, Math.abs((_right.rightVertex.x - _left.leftVertex.x)), Math.abs((_botton.bottonVertex.y - _top.topVertex.y))));
		}

		public function drawFaltRect(_arg_1:Graphics, _arg_2:uint=0):void
		{
			var _local_3:Vector.<int> = new Vector.<int>();
			_local_3.push(GraphicsPathCommand.MOVE_TO);
			_local_3.push(GraphicsPathCommand.LINE_TO);
			_local_3.push(GraphicsPathCommand.LINE_TO);
			_local_3.push(GraphicsPathCommand.LINE_TO);
			_local_3.push(GraphicsPathCommand.LINE_TO);
			var _local_4:Rectangle = this.getBounds();
			var _local_5:Vector.<Number> = new Vector.<Number>();
			_local_5.push(_local_4.x, _local_4.y);
			_local_5.push((_local_4.x + _local_4.width), _local_4.y);
			_local_5.push((_local_4.x + _local_4.width), (_local_4.y + _local_4.height));
			_local_5.push(_local_4.x, (_local_4.y + _local_4.height));
			_local_5.push(_local_4.x, _local_4.y);
			_arg_1.lineStyle(1, _arg_2);
			_arg_1.drawPath(_local_3, _local_5, GraphicsPathWinding.NON_ZERO);
		}

		public function drawTile(_arg_1:Graphics, _arg_2:uint=0, _arg_3:Boolean=false, _arg_4:uint=0, _arg_5:Number=0.5):void
		{
			var _local_6:Vector.<int> = new Vector.<int>();
			_local_6.push(GraphicsPathCommand.MOVE_TO);
			_local_6.push(GraphicsPathCommand.LINE_TO);
			_local_6.push(GraphicsPathCommand.LINE_TO);
			_local_6.push(GraphicsPathCommand.LINE_TO);
			_local_6.push(GraphicsPathCommand.LINE_TO);
			_arg_1.lineStyle(1, _arg_2);
			if (_arg_3) {
				_arg_1.beginFill(_arg_4, _arg_5);
			}
			_arg_1.drawPath(_local_6, this.getTileBounds(), GraphicsPathWinding.NON_ZERO);
			if (_arg_3) {
				_arg_1.endFill();
			}
		}

		public function getTileBounds():Vector.<Number>
		{
			var _local_1:Vector.<Number> = new Vector.<Number>();
			_local_1.push(_left.leftVertex.x, _left.leftVertex.y);
			_local_1.push(_top.topVertex.x, _top.topVertex.y);
			_local_1.push(_right.rightVertex.x, _right.rightVertex.y);
			_local_1.push(_botton.bottonVertex.x, _botton.bottonVertex.y);
			_local_1.push(_left.leftVertex.x, _left.leftVertex.y);
			return (_local_1);
		}

		public function get botton():Cell
		{
			return (_botton);
		}

		public function get right():Cell
		{
			return (_right);
		}

		public function get left():Cell
		{
			return (_left);
		}

		public function get top():Cell
		{
			return (_top);
		}

	}
}
