package com.engine.utils.astar
{
	import com.engine.core.tile.square.Square;
	import com.engine.core.tile.square.SquarePt;
	
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class SquareAstar 
	{

		private static const COST_STRAIGHT:int = 10;
		private static const COST_DIAGONAL:int = 14;
		
		public var mode:int = 1;
		
		private var nonce:SquareAstarData;
		private var startPoint:SquarePt;
		private var endPoint:SquarePt;
		private var colsePath:Dictionary;
		private var colseArray:Array;
		private var openPath:Dictionary;
		private var openArray:Array;
		private var closeLength:int;
		private var G:int;
		private var isFinish:Boolean;
		
		public function getPath(maps:Dictionary, tp_start:SquarePt, tp_end:SquarePt, _arg_4:Boolean=true, size:int=10000):Array
		{
			var sq_start:Square = maps[tp_start.key] as Square;
			var sq_end:Square = maps[tp_end.key] as Square;
			if (sq_start) {
				if (sq_end) {
					if (sq_start.type == 2 && sq_end.type == 2) {
						this.mode = 2;
					} else {
						this.mode = 1;
					}
				} else {
					this.mode = 1;
				}
			}
			if (!sq_start || (this.mode==1 && sq_start.type == 2)) {
				return [];
			}
			
			var startTime:Number = getTimer();
			this.reset();
			this.startPoint = this.cycleCheck(maps, tp_start, 0);	// 递归寻找可行点
			this.endPoint = this.cycleCheck(maps, tp_end, 0);	// 递归寻找可行点
			this.nonce = new SquareAstarData(0, 0, this.startPoint);
			this.nonce.parent = this.nonce;
			this.colsePath[this.nonce.key] = this.nonce;
			while (this.isFinish) {
				this.getScale9Grid(maps, this.nonce, this.endPoint, size);
			}
			var paths:Array = this.cleanArray();
			log("saiman", "*****************寻路时间：", (getTimer() - startTime), "路径长: ", paths.length, "*******************", "\n\n");
			return paths;
		}

		public function stop():void
		{
			this.isFinish = false;
		}

		private function cycleCheck(maps:Dictionary, tp_source:SquarePt, round:int):SquarePt
		{
			var type:int = this.mode == 1 ? 2 : 1;
			if (maps[tp_source.key] == null || maps[tp_source.key].type == 0 || maps[tp_source.key].type == type) {
				var tx:int = tp_source.x;
				var ty:int = tp_source.y;
				
				var i:int = tx - (round+1);
				while (i <= tx + (round+1)) {
					var j:int = ty - (round+1);
					while (j <= ty + (round+1)) {
						var key:String = i + "|" + j;
						if (key != tp_source.key) {
							var sq_target:Square = maps[key];
							if (sq_target && sq_target.type != 0 && sq_target.type != type) {
								return sq_target.index;
							}
						}
						j++;
					}
					i++;
				}
				if (round > 8) {
					this.isFinish = false;
					return tp_source;
				}
				return this.cycleCheck(maps, tp_source, (round+1));
			}
			return tp_source;
		}

		private function getDis(pa:SquarePt, pb:SquarePt):int
		{
			var dx:int = pb.x - pa.x;
			if (dx < 0) {
				dx = -dx;
			}
			var dy:int = pb.y - pa.y;
			if (dy < 0) {
				dy = -dy;
			}
			return dx + dy;
		}

		private function pass(sq:Square):Boolean
		{
			var type:int = sq.type;
			if (type == 0) {
				return false;
			}
			var targetType:int;
			if (this.mode == 1) {
				targetType = 1;
			} else {
				targetType = 2;
			}
			if (type == targetType) {
				return true;
			}
			return false;
		}
		
		/**
		 * 直线
		 */
		private function stratght(sq_curr:Square, pt_end:SquarePt):void
		{
			if (sq_curr != null) {
				if (this.pass(sq_curr)) {
					var key:String = sq_curr.key;
					var pt_curr:SquarePt = sq_curr.index;
					var hValue:int = this.getDis(pt_curr, pt_end) * COST_STRAIGHT;
					var gValue:int = COST_STRAIGHT + this.G;
					var fValue:int = gValue + hValue;
					var sa_curr:SquareAstarData = new SquareAstarData(gValue, fValue, pt_curr);
					if (sa_curr.parent == null) {
						sa_curr.parent = this.nonce;
					}
					var sa_open:SquareAstarData = this.openPath[key];
					var sa_close:SquareAstarData = this.colsePath[key];
					if (sa_open == null && sa_close == null) {
						this.openPath[key] = sa_curr;
						this.openArray.push(sa_curr);
					} else {
						if (sa_open != null) {
							if (sa_curr.F < sa_open.F) {
								this.openPath[key] = sa_curr;
							}
						}
					}
				}
			}
		}

		/**
		 * 对角线
		 */		
		private function diagonal(sq_curr:Square, pt_end:SquarePt):void
		{
			if (sq_curr != null) {
				if (this.pass(sq_curr)) {
					var key:String = sq_curr.key;
					var pt_curr:SquarePt = sq_curr.index;
					var hValue:int = this.getDis(pt_curr, pt_end) * COST_STRAIGHT;
					var gValue:int = COST_DIAGONAL + this.G;
					var fValue:int = gValue + hValue;
					var sa_curr:SquareAstarData = new SquareAstarData(gValue, fValue, pt_curr);
					if (sa_curr.parent == null) {
						sa_curr.parent = this.nonce;
					}
					var sa_open:SquareAstarData = this.openPath[key];
					var sa_close:SquareAstarData = this.colsePath[key];
					if (sa_open == null && sa_close == null) {
						this.openPath[key] = sa_curr;
						this.openArray.push(sa_curr);
					} else {
						if (sa_open != null) {
							if (sa_curr.F < sa_open.F) {
								this.openPath[key] = sa_curr;
							}
						}
					}
				}
			}
		}

		private function getScale9Grid(maps:Dictionary, sa_curr:SquareAstarData, pt_end:SquarePt, maxSize:int):void
		{
			var pt_curr:SquarePt = sa_curr.pt;
			var ox:int = pt_curr.x;
			var oy:int = pt_curr.y;
			var rx:int = ox + 1;
			var by:int = oy + 1;
			var lx:int = ox - 1;
			var ty:int = oy - 1;
			var sq_tl:Square = maps[lx + "|" + ty];	// 左上
			var sq_tr:Square = maps[rx + "|" + ty];	// 右上
			var sq_bl:Square = maps[lx + "|" + by];	// 左下
			var sq_br:Square = maps[rx + "|" + by];	// 右下
			var sq_tt:Square = maps[ox + "|" + ty];	// 上
			var sq_ll:Square = maps[lx + "|" + oy];	// 左
			var sq_rr:Square = maps[rx + "|" + oy];	// 右
			var sq_bb:Square = maps[ox + "|" + by];	// 下
			if (sq_tt) {
				this.stratght(sq_tt, pt_end);
			}
			if (sq_ll) {
				this.stratght(sq_ll, pt_end);
			}
			if (sq_rr) {
				this.stratght(sq_rr, pt_end);
			}
			if (sq_bb) {
				this.stratght(sq_bb, pt_end);
			}
			if (sq_tl) {
				this.diagonal(sq_tl, pt_end);
			}
			if (sq_tr) {
				this.diagonal(sq_tr, pt_end);
			}
			if (sq_bl) {
				this.diagonal(sq_bl, pt_end);
			}
			if (sq_br) {
				this.diagonal(sq_br, pt_end);
			}
			var len:int = this.openArray.length;
			if (len == 0) {// || (!sq_tt && !sq_ll && !sq_rr && !sq_bb && !sq_tl && !sq_tr && !sq_bl && !sq_br)) {
				this.isFinish = false;
				return;
			}
			var tIdx:int;
			var idx:int;
			while (idx < len) {
				if (idx == 0) {
					sa_curr = this.openArray[idx];
				} else {
					if (this.openArray[idx].F < sa_curr.F) {
						sa_curr = this.openArray[idx];
						tIdx = idx;
					}
				}
				idx++;
			}
			this.nonce = sa_curr;
			this.openArray.splice(tIdx, 1);
			var key:String = this.nonce.key;
			if (this.colsePath[key] == null) {
				this.colsePath[key] = this.nonce;
				this.closeLength++;
				if (this.closeLength > maxSize) {
					this.isFinish = false;
				}
			}
			if (this.nonce.key == pt_end.key) {
				this.isFinish = false;
			}
			this.G = this.nonce.G;
		}

		private function cleanArray():Array
		{
			var pathArray:Array = [];
			var key:String = this.endPoint.key;
			if (this.colsePath[key] == null) {	// 寻找距离终点最近的点
				var pt_item:SquarePt;
				var hMin:int = int.MAX_VALUE;
				var hVal:int;
				for each (var item:SquareAstarData in this.colsePath) {
					pt_item = item.pt;
					hVal = this.getDis(pt_item, this.endPoint);
					if (hVal < hMin) {
						hMin = hVal;
						key = pt_item.key;
					}
				}
			}
			var sa_end:SquareAstarData = this.colsePath[key];
			if (sa_end != null) {
				pathArray.unshift(sa_end.pt.pixelsPoint);
				pathArray.unshift(sa_end.parent.pt.pixelsPoint);
				var idx:int = 0;
				while (true) {
					key = this.colsePath[key].parent.key;
					if (key == this.startPoint.key || idx > 10000) {
						break;
					}
					pathArray.unshift(this.colsePath[key].parent.pt.pixelsPoint);
					idx++;
				}
			}
			return pathArray;
		}

		private function reset():void
		{
			this.colsePath = new Dictionary();
			this.colseArray = [];
			this.openPath = new Dictionary();
			this.openArray = [];
			this.G = 0;
			this.nonce = null;
			this.isFinish = true;
			this.closeLength = 0;
		}

	}
}
