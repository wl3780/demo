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


		private function pathCutter(_arg_1:Array, _arg_2:int=140, _arg_3:int=350):void
		{
			var _local_7:Array;
			var _local_8:int;
			var _local_9:Point;
			var _local_10:Point;
			var _local_11:int;
			var _local_12:int;
			var _local_13:Number;
			var _local_14:int;
			var _local_15:Number;
			var _local_16:Point;
			var _local_17:Number;
			var _local_18:int;
			var _local_19:int;
			var _local_4:Array = [];
			var _local_5:int = _arg_1.length;
			var _local_6:Square = new Square();
			if (_local_5 >= 2) {
				_local_8 = 0;
				while (_local_8 < (_local_5 - 1)) {
					_local_9 = _arg_1[_local_8];
					_local_10 = _arg_1[(_local_8 + 1)];
					_local_11 = Point.distance(_local_9, _local_10);
					_local_12 = Math.ceil((_local_11 / _arg_2));
					_local_13 = (_arg_2 / _local_11);
					_local_14 = 0;
					while (_local_14 <= _local_12) {
						_local_15 = (_local_13 * _local_14);
						_local_16 = Point.interpolate(_local_10, _local_9, _local_15);
						_local_16.x = Math.round(_local_16.x);
						_local_16.y = Math.round(_local_16.y);
						if ((((_local_4.length == 0)) || ((((_local_4.length > 0)) && (!((_local_16.toString() == _local_4[(_local_4.length - 1)].toString()))))))) {
							_local_4.push(_local_16);
						}
						if ((_local_13 * (_local_14 + 1)) > 1) {
							_local_4.push(_local_10);
							break;
						}
						_local_14++;
					}
					_local_8++;
				}
				if (_local_4.length > 1) {
					_local_5 = _local_4.length;
					_local_17 = 0;
					_local_18 = 0;
					_local_19 = 1;
					while (_local_19 < _local_5) {
						_local_17 = (_local_17 + Point.distance(_local_4[(_local_19 - 1)], _local_4[_local_19]));
						if ((((Math.ceil(_local_17) >= _arg_3)) || ((((_local_19 == (_local_5 - 1))) && ((Math.ceil(_local_17) < _arg_3)))))) {
							_local_7 = _local_4.slice(_local_18, (_local_19 + 1));
							this.walkPathFragments.push(_local_7);
							_local_17 = 0;
							_local_18 = _local_19;
						}
						_local_19++;
					}
				}
			}
		}

		public function cleanPath(_arg_1:Array):Array
		{
			var _local_2:int;
			var _local_3:Point;
			var _local_4:Point;
			var _local_5:Point;
			var _local_6:Number;
			var _local_7:Number;
			if (_arg_1.length > 2) {
				_local_2 = 1;
				while (_local_2 < (_arg_1.length - 1)) {
					_local_3 = _arg_1[(_local_2 - 1)];
					_local_4 = _arg_1[_local_2];
					_local_5 = _arg_1[(_local_2 + 1)];
					_local_6 = ((_local_3.y - _local_4.y) / (_local_3.x - _local_4.x));
					_local_7 = ((_local_4.y - _local_5.y) / (_local_4.x - _local_5.x));
					if (_local_6 == _local_7) {
						_arg_1.splice(_local_2, 1);
						_local_2--;
					}
					_local_2++;
				}
			}
			return (_arg_1);
		}

		private function getPath(_arg_1:Point, _arg_2:Point, _arg_3:int=1000):Array
		{
			var _local_4:Array;
			var _local_7:Point;
			var _local_8:Point;
			var _local_5:SquarePt = SquareUitls.pixelsToSquare(_arg_1);
			var _local_6:SquarePt = SquareUitls.pixelsToSquare(_arg_2);
			if (_local_5.key == _local_6.key) {
				return ([_arg_1, _arg_2]);
			}
			if (this.checkPointType(_arg_1, _arg_2)) {
				_local_4 = [_arg_1, _arg_2];
			} else {
				_local_4 = this.astar.getPath(SquareGroup.getInstance().hash.hash, _local_5, _local_6, true, _arg_3);
				if (_local_4.length) {
					_local_7 = _local_4[(_local_4.length - 1)];
					if (SquareUitls.pixelsToSquare(_local_7).key == _local_6.key) {
						_local_4[(_local_4.length - 1)] = _arg_2;
					}
					_local_8 = _local_4[0];
					if (SquareUitls.pixelsToSquare(_local_8).key == _local_5.key) {
						if (_local_5.toString() != _arg_1.toString()) {
							_local_4[0] = _arg_1;
						}
					}
				}
				_local_4 = this.cleanPath(_local_4);
			}
			return (_local_4);
		}

		private function checkPointType(_arg_1:Point, _arg_2:Point, _arg_3:int=10):Boolean
		{
			var _local_8:Point;
			var _local_9:SquarePt;
			var _local_10:Square;
			var _local_4:Number = Point.distance(_arg_1, _arg_2);
			var _local_5:int = Math.ceil((_local_4 / _arg_3));
			var _local_6:Boolean = true;
			var _local_7:int;
			while (_local_7 < _local_5) {
				_local_8 = Point.interpolate(_arg_1, _arg_2, (_local_7 / _local_5));
				_local_9 = SquareUitls.pixelsToSquare(_local_8);
				_local_10 = SquareGroup.getInstance().take(_local_9.key);
				if (((!(_local_10)) || ((((_local_10.type < 1)) && (!((_local_10.type == this.astar.mode))))))) {
					_local_6 = false;
					break;
				}
				_local_7++;
			}
			return (_local_6);
		}

		public function mainCharWalk(_arg_1:Point, _arg_2:Function, _arg_3:int=1500, _arg_4:int=1, _arg_5:Boolean=true):void
		{
			var _local_11:Array;
			var _local_6:GameScene = GameScene.scene;
			var _local_7:MainChar = _local_6.mainChar;
			if (_local_7.isBackMoving) {
				return;
			}
			var _local_8:Point = new Point(_local_7.x, _local_7.y);
			if (((!(_local_8)) || (!(_arg_1)))) {
				return;
			}
			var _local_9:SquarePt = SquareUitls.pixelsToSquare(_local_8);
			var _local_10:SquarePt = SquareUitls.pixelsToSquare(_arg_1);
			if (GameScene.scene.mainChar.lockMove) {
				return;
			}
			this.walkPathFragments = [];
			this.moveType = _arg_4;
			this.walkEndFunc = _arg_2;
			this.tar_point = _arg_1;
			if ((((_local_9.key == _local_10.key)) && ((Point.distance(_local_8, _arg_1) > 1)))) {
				this.pathCutter([_local_8, _arg_1]);
				coder::paths = [_local_8, _arg_1];
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
				_local_11 = this.getPath(_local_8, _arg_1, _arg_3);
				coder::paths = _local_11.slice();
				this.pathCutter(_local_11.slice());
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

		private function totalWalkEnd():void
		{
			GameScene.scene.mainChar.walkendStandOutSide = false;
			SceneEventDispatcher.getInstance().dispatchEvent(new SceneEvent(SceneEvent.WALK_END));
			GameScene.scene.mainChar.stopMove();
			if (this.walkEndFunc != null) {
				this.walkEndFunc();
			}
			this.walkEndFunc = null;
		}

		private function walkNextPart():void
		{
			var _local_1:Array = this.walkPathFragments.shift();
			this.end_point_key = SquareUitls.pixelsToSquare(_local_1[(_local_1.length - 1)]).key;
			GameScene.scene.mainChar.walkEndFunc = this.charPartWalkEndFunc;
			GameScene.scene.mainChar.walk(_local_1.slice());
			this.sendWalkData(_local_1);
		}

		private function charPartWalkEndFunc():void
		{
			var _local_1:MainChar = GameScene.scene.mainChar;
			if (this.walkPathFragments.length == 0) {
				this.totalWalkEnd();
			} else {
				if (this.walkPathFragments.length == 1) {
					GameScene.scene.mainChar.walkendStandOutSide = false;
				}
				this.walkNextPart();
			}
		}

		private function sendWalkData(_arg_1:Array):void
		{
		}

	}
}
