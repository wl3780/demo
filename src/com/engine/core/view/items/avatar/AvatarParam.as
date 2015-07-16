package com.engine.core.view.items.avatar
{
	import com.engine.core.Engine;
	import com.engine.core.model.IProto;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;

	public class AvatarParam extends Proto 
	{

		public var replay:int = -1;
		public var holdOnLastFrame:Boolean = false;
		public var currentFrame:int;
		public var depth:int;
		public var type:String;
		public var link:String;
		public var frames:int;
		public var speed:int;
		public var offset_x:int;
		public var offset_y:int;
		public var txs:Vector.<Object>;
		public var tys:Vector.<Object>;
		public var widths:Vector.<Object>;
		public var heights:Vector.<Object>;
		public var bitmapdatas:Array;
		public var startPlayTime:int = 0;
		public var counter:int;
		public var maxRects:Array;
		
		coder var assets_id:String;
		
		private var _isDisposed:Boolean = false;

		public function AvatarParam()
		{
			super();
			registerClassAlias("saiman.save.AvatarParam", AvatarParam);
			this.init();
		}

		public function init():void
		{
			this.txs = new Vector.<Object>();
			this.tys = new Vector.<Object>();
			this.widths = new Vector.<Object>();
			this.heights = new Vector.<Object>();
			this.bitmapdatas = new Array(8);
			this.maxRects = new Array(8);
		}

		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}

		override public function clone():IProto
		{
			var ret:AvatarParam = super.clone() as AvatarParam;
			ret.coder::oid = this.oid;
			var tmp:Array;
			var idx:int = 0;
			while (idx < this.heights.length) {
				tmp = this.heights[idx].slice();
				ret.heights[idx] = tmp;
				tmp = this.widths[idx].slice();
				ret.widths[idx] = tmp;
				tmp = this.txs[idx].slice();
				ret.txs[idx] = tmp;
				tmp = this.tys[idx].slice();
				ret.tys[idx] = tmp;
				idx++;
			}
			return ret;
		}

		public function getRect(i:int, j:int):Rectangle
		{
			return new Rectangle(
				this.txs[i][j] + this.offset_x,
				this.tys[i][j] + this.offset_y,
				this.widths[i][j],
				this.heights[i][j]);
		}

		public function getBitmapData(dir:int, frame:int):BitmapData
		{
			try {
				var key:String = this.oid + Engine.SIGN + this.link + Engine.SIGN + this.bitmapdatas[dir];
				var manager:AvatarAssetManager = AvatarAssetManager.getInstance();
				return manager.bitmapdatas[key][frame] as BitmapData;
			} catch(e:Error) {
			}
			return null;
		}

		override public function dispose():void
		{
			_isDisposed = true;
			coder::assets_id = null;
			this.counter = 0;
			this.txs = null;
			this.tys = null;
			this.widths = null;
			this.heights = null;
			this.bitmapdatas = null;
			this.link = null;
			this.maxRects = null;
			this.type = null;
			this.startPlayTime = 0;
			this.speed = 0;
			this.frames = 0;
			super.dispose();
		}

	}
}
