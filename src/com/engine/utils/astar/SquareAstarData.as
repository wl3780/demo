package com.engine.utils.astar
{
	import com.engine.core.tile.square.SquarePt;

	public class SquareAstarData 
	{

		public var key:String;
		public var pt:SquarePt;
		public var G:int = 0;
		public var F:int = 0;
		public var parent:SquareAstarData;

		public function SquareAstarData(g:int, f:int, pt:SquarePt)
		{
			this.G = g;
			this.F = f;
			if (pt) {
				this.key = pt.key;
			}
			this.pt = pt;
		}

	}
}
