package com.engine.core.tile
{
	import com.engine.utils.Hash;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;

	public class TileGroup 
	{

		private static var _instance:TileGroup;

		public var leftTop:Point;
		
		private var $hash:Hash;
		private var $grids:Grids;

		public function TileGroup()
		{
			if (_instance == null) {
				_instance = this;
				this.initialize();
				this.grids.init();
				if (this.$hash) {
					this.$hash.dispose();
					this.$hash = null;
					this.$hash = new Hash();
				}
			}
		}

		public static function getInstance():TileGroup
		{
			if (_instance == null) {
				_instance = new TileGroup();
			}
			return _instance;
		}


		public function get grids():Grids
		{
			return (this.$grids);
		}

		public function get hash():Hash
		{
			return (this.$hash);
		}

		public function dispose():void
		{
			this.$hash.dispose();
			this.$hash = null;
			this.$grids = null;
		}

		public function initialize():void
		{
			this.$hash = new Hash();
			this.$grids = new Grids();
		}

		public function unload():void
		{
			var _local_1:String;
			if (this.hash == null) {
				return;
			}
			try {
				this.$hash.dispose();
				this.$hash = null;
			} catch(e:Error) {
			}
			_instance = null;
		}

		public function reset(_arg_1:Dictionary):void
		{
			var _local_3:Cell;
			var _local_2:Hash = this.$hash;
			this.$hash = null;
			this.$hash = new Hash();
			this.grids.init();
			for each (_local_3 in _arg_1) {
				this.put(_local_3);
			}
			_local_2.dispose();
		}

		public function put(_arg_1:Cell):void
		{
			if (!this.hash.has(_arg_1.indexKey)) {
				this.grids.put(_arg_1);
			}
			this.hash.put(_arg_1.indexKey, _arg_1);
		}

		public function remove(_arg_1:String):Cell
		{
			var _local_2:Cell;
			if (this.hash.has(_arg_1)) {
				return ((this.$hash.remove(_arg_1) as Cell));
			}
			return (null);
		}

		public function has(_arg_1:String):Boolean
		{
			if (_arg_1 == null) {
				return (false);
			}
			return (this.hash.has(_arg_1));
		}

		public function take(_arg_1:String):Cell
		{
			return ((this.$hash.take(_arg_1) as Cell));
		}

		public function getBound():Grids
		{
			return (this.grids);
		}

		public function clean():Point
		{
			var _local_1:Point = this.grids.clean(this.hash);
			this.reset(this.hash);
			return _local_1;
		}

		public function passAbled(_arg_1:Pt):Boolean
		{
			var _local_2:Cell;
			if (_arg_1) {
				_local_2 = (this.$hash.take(_arg_1.key) as Cell);
				if (_local_2) {
					if ((((_local_2.type == 3)) || ((_local_2.type == 4)))) {
						if (_local_2.type > 0) {
							return (true);
						}
					}
				}
			}
			return (false);
		}

		public function getScale9Grid(_arg_1:Pt):ScaleGrid
		{
			var _local_2:ScaleGrid = new ScaleGrid();
			_local_2.setValue(_arg_1, this.hash);
			return (_local_2);
		}

	}
}
