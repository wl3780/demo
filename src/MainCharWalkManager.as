package 
{
	import com.engine.core.tile.square.Square;
	import com.engine.core.tile.square.SquareGroup;
	import com.engine.core.tile.square.SquarePt;
	import com.engine.core.view.role.MainChar;
	import com.engine.core.view.scenes.SceneEvent;
	import com.engine.core.view.scenes.SceneEventDispatcher;
	import com.engine.namespaces.coder;
	import com.engine.utils.astar.SquareAstar;
	import com.engine.utils.gome.SquareUitls;
	
	import flash.geom.Point;

	public class MainCharWalkManager 
	{

		private static var instance:MainCharWalkManager;

		public var walkEndFunc:Function;
		public var tar_point:Point;
		
		private var astar:SquareAstar;
		private var walkPathFragments:Array;
		private var end_point_key:String;
		private var moveType:int;
		
		coder var paths:Array;

		public function MainCharWalkManager()
		{
			super();
			this.coder::paths = [];
			this.astar = new SquareAstar();
		}

		public static function getInstance():MainCharWalkManager
		{
			return instance ||= new MainCharWalkManager();
		}

		public function mainCharWalk(pt_target:Point, callback:Function, breakStep:int=1500, moveType:int=1, _arg_5:Boolean=true):void
		{
			if (!pt_target) {
				return;
			}
			var mainChar:MainChar = GameScene.scene.mainChar;
			if (mainChar.lockMove || mainChar.isBackMoving) {
				return;
			}
			
			var pt_from:Point = mainChar.point;
			var tp_start:SquarePt = SquareUitls.pixelsToSquare(pt_from);
			var tp_end:SquarePt = SquareUitls.pixelsToSquare(pt_target);
			this.walkPathFragments = [];
			this.moveType = moveType;
			this.walkEndFunc = callback;
			this.tar_point = pt_target;
			
			if (tp_start.key == tp_end.key && Point.distance(pt_from, pt_target) > 1) {
				this.pathCutter([pt_from, pt_target]);
				coder::paths = [pt_from, pt_target];
				if (this.walkPathFragments.length) {
					GameScene.scene.mainChar.walkendStandOutSide = true;
					if (this.walkPathFragments.length == 1) {
						GameScene.scene.mainChar.walkendStandOutSide = false;
					}
					this.walkNextPart();
				} else {
					this.totalWalkEnd();
				}
			} else {
				var array:Array = this.getPath(pt_from, pt_target, breakStep);
				this.pathCutter(array);
				coder::paths = array;
				if (this.walkPathFragments.length > 0) {
					GameScene.scene.mainChar.walkendStandOutSide = true;
					if (this.walkPathFragments.length == 1) {
						GameScene.scene.mainChar.walkendStandOutSide = false;
					}
					this.walkNextPart();
				} else {
					this.totalWalkEnd();
				}
			}
		}

		private function pathCutter(array:Array, size:int=140, _arg_3:int=350):void
		{
			var len:int = array.length;
			if (len < 2) {
				return;
			}
			var new_paths:Array = [];
			var i:int = 0;
			var j:int = 0;
			while (i < len-1) {
				var pt_start:Point = array[i];
				var pt_end:Point = array[i+1];
				var dis:int = Point.distance(pt_start, pt_end);
				var length:int = Math.ceil(dis / size);
				var num:Number = dis ? size / dis : 0;
				j = 0;
				while (j <= length) {
					var pr:Number = num * j;
					var pt_now:Point = Point.interpolate(pt_end, pt_start, pr);
					pt_now.x = Math.round(pt_now.x);
					pt_now.y = Math.round(pt_now.y);
					if ((new_paths.length == 0) || (pt_now.toString() != new_paths[new_paths.length-1].toString())) {
						new_paths.push(pt_now);
					}
					if (num*(j+1) > 1) {
						new_paths.push(pt_end);
						break;
					}
					j++;
				}
				i++;
			}
			
			if (new_paths.length > 1) {
				len = new_paths.length;
				var sum:Number = 0;
				var p_start:int = 0;
				var n_start:int = 1;
				while (n_start < len) {
					sum += Point.distance(new_paths[n_start-1], new_paths[n_start]);
					if ((Math.ceil(sum) >= _arg_3) || (n_start == len-1)) {
						var pts:Array = new_paths.slice(p_start, (n_start+1));
						this.walkPathFragments.push(pts);
						sum = 0;
						p_start = n_start;
					}
					n_start++;
				}
			}
		}

		public function cleanPath(p_paths:Array):Array
		{
			var pt0:Point;
			var pt1:Point;
			var pt2:Point;
			var ratio0:Number;
			var ratio1:Number;
			if (p_paths.length > 2) {
				var idx:int = 1;
				while (idx < (p_paths.length-1)) {
					pt0 = p_paths[idx-1];
					pt1 = p_paths[idx];
					pt2 = p_paths[idx+1];
					// 斜率
					ratio0 = (pt0.y - pt1.y) / (pt0.x - pt1.x);
					ratio1 = (pt1.y - pt2.y) / (pt1.x - pt2.x);
					if (ratio0 == ratio1) {
						p_paths.splice(idx, 1);
						idx--;
					}
					idx++;
				}
			}
			return p_paths;
		}

		private function getPath(pt_start:Point, pt_end:Point, size:int=1000):Array
		{
			var tp_start:SquarePt = SquareUitls.pixelsToSquare(pt_start);
			var tp_end:SquarePt = SquareUitls.pixelsToSquare(pt_end);
			if (tp_start.key == tp_end.key) {
				return [pt_start, pt_end];
			}
			
			var ret:Array;
			if (this.checkPointType(pt_start, pt_end)) {
				ret = [pt_start, pt_end];
			} else {
				ret = this.astar.getPath(SquareGroup.getInstance().hash, tp_start, tp_end, true, size);
				if (ret.length) {
					var pt_first:Point = ret[ret.length-1];
					if (SquareUitls.pixelsToSquare(pt_first).key == tp_end.key) {
						ret[ret.length-1] = pt_end;
					}
					var pt_last:Point = ret[0];
					if (SquareUitls.pixelsToSquare(pt_last).key == tp_start.key) {
						if (tp_start.toString() != pt_start.toString()) {
							ret[0] = pt_start;
						}
					}
				}
				ret = this.cleanPath(ret);
			}
			return ret;
		}

		private function checkPointType(pt_start:Point, pt_end:Point, px:int=10):Boolean
		{
			var dis:Number = Point.distance(pt_start, pt_end);
			var index:int = Math.ceil(dis / px);
			var pass:Boolean = true;
			var idx:int;
			while (idx < index) {
				var pt_inter:Point = Point.interpolate(pt_start, pt_end, (idx/index));
				var tp_inter:SquarePt = SquareUitls.pixelsToSquare(pt_inter);
				var sq:Square = SquareGroup.getInstance().take(tp_inter.key);
				if (!sq || (sq.type < 1 && sq.type != this.astar.mode)) {
					pass = false;
					break;
				}
				idx++;
			}
			return pass;
		}

		private function totalWalkEnd():void
		{
			GameScene.scene.mainChar.walkendStandOutSide = false;
			SceneEventDispatcher.getInstance().dispatchEvent(new SceneEvent(SceneEvent.WALK_END));
			GameScene.scene.mainChar.stopMove();
			if (this.walkEndFunc != null) {
				var tmpFunc:Function = this.walkEndFunc;
				this.walkEndFunc = null;
				tmpFunc();
			}
		}

		private function walkNextPart():void
		{
			var list:Array = this.walkPathFragments.shift();
			this.end_point_key = SquareUitls.pixelsToSquare(list[list.length-1]).key;
			GameScene.scene.mainChar.walkEndFunc = this.charPartWalkEndFunc;
			GameScene.scene.mainChar.walk(list.slice());
			this.sendWalkData(list);
		}

		private function charPartWalkEndFunc():void
		{
			if (this.walkPathFragments.length == 0) {
				this.totalWalkEnd();
			} else {
				if (this.walkPathFragments.length == 1) {
					GameScene.scene.mainChar.walkendStandOutSide = false;
				}
				this.walkNextPart();
			}
		}

		private function sendWalkData(list:Array):void
		{
		}

	}
}
