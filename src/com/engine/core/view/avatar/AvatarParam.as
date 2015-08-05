package com.engine.core.view.avatar
{
	import com.engine.core.AvatarUnitTypes;
	import com.engine.core.Engine;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;

	public class AvatarParam extends Proto 
	{

		public var action:String;
		public var avatarType:String;
		
		public var replay:int = -1;
		public var holdOnLastFrame:Boolean = false;
		public var currentFrame:int;
		public var frames:int;
		public var speed:int;
		public var offset_x:int;
		public var offset_y:int;
		public var txs:Vector.<Object>;
		public var tys:Vector.<Object>;
		public var widths:Vector.<Object>;
		public var heights:Vector.<Object>;
		public var bitmapFlips:Array;
		public var startPlayTime:int = 0;
		public var counter:int;
		public var maxRects:Array;
		
		coder var assets_id:String;
		coder var singleDir:Boolean = false;
		
		private var _isDisposed:Boolean = false;

		public function AvatarParam()
		{
			super();
			registerClassAlias("saiman.save.AvatarParam", AvatarParam);
			this.init();
		}

		private function init():void
		{
			this.txs = new Vector.<Object>();
			this.tys = new Vector.<Object>();
			this.widths = new Vector.<Object>();
			this.heights = new Vector.<Object>();
			this.bitmapFlips = new Array(8);
			this.maxRects = new Array(8);
		}
		
		public function setup(avatarId:String, xml:XML):void
		{
			this.avatarType = avatarId.split("_")[0];
			this.action = xml.@id;
			this.frames = xml.@frames;
			if (avatarType != AvatarUnitTypes.EFFECT_TYPE) {
				this.speed = int(xml.@speed) / Engine._Lessen_Frame_;
			} else {
				this.speed = xml.@speed;
			}
			this.offset_x = xml.@offset_x;
			this.offset_y = xml.@offset_y;
			this.replay = xml.@replay;
			if (this.replay == 0) {
				this.replay = -1;
			}
			this.coder::oid = avatarId;
			this.coder::id = avatarId + Engine.SIGN + this.action;
			
			var dirList:XMLList = xml.children();
			var dirLen:int = dirList.length();
			var dirIdx:int = 0;
			var actXML:XML;
			if (dirLen == 1) {	// 8方向
				this.coder::singleDir = true;
				actXML = dirList[0];
				this.initFrameData(0, actXML.children());
				while (dirIdx < 8) {
					this.txs[dirIdx] = this.txs[0];
					this.tys[dirIdx] = this.tys[0];
					this.widths[dirIdx] = this.widths[0];
					this.heights[dirIdx] = this.heights[0];
					this.bitmapFlips[dirIdx] = false;
					dirIdx++;
				}
			} else {
				while (dirIdx < 8) {	// 8方向
					if (dirIdx < dirLen) {
						actXML = dirList[dirIdx];
						this.initFrameData(dirIdx, actXML.children());
						this.bitmapFlips[dirIdx] = false;
					} else {	// 反转
						this.txs[dirIdx] = [];
						var flipDirIdx:int = 8 - dirIdx;
						var flipFrameIdx:int = 0;
						while (flipFrameIdx < this.widths[flipDirIdx].length) {
							var flipFrameX:int = this.widths[flipDirIdx][flipFrameIdx] - this.txs[flipDirIdx][flipFrameIdx];
							this.txs[dirIdx].push(flipFrameX);
							flipFrameIdx++;
						}
						this.tys[dirIdx] = this.tys[flipDirIdx];
						this.widths[dirIdx] = this.widths[flipDirIdx];
						this.heights[dirIdx] = this.heights[flipDirIdx];
						this.bitmapFlips[dirIdx] = true;
					}
					dirIdx++;
				}
			}
		}
		private function initFrameData(dirIdx:int, frameList:XMLList):void
		{
			this.txs[dirIdx] = [];
			this.tys[dirIdx] = [];
			this.widths[dirIdx] = [];
			this.heights[dirIdx] = [];
			
			var frameLen:int = frameList.length();
			if (frameLen > this.frames) {
				this.frames = frameLen;
			}
			var frameIdx:int = 0;
			while (frameIdx < frameLen) {
				this.txs[dirIdx].push(int(frameList[frameIdx].@tx[0]));
				this.tys[dirIdx].push(int(frameList[frameIdx].@ty[0]));
				var frameW:int = int(frameList[frameIdx].@width[0]);
				if (frameW == 0) {
					frameW = int(frameList[frameIdx].@w[0]);
				}
				var frameH:int = int(frameList[frameIdx].@height[0]);
				if (frameH == 0) {
					frameH = int(frameList[frameIdx].@h[0]);
				}
				this.widths[dirIdx].push(frameW);
				this.heights[dirIdx].push(frameH);
				frameIdx++;
			}
		}

		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}

		override public function clone():Object
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
			ret.coder::singleDir = this.coder::singleDir;
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
			var key:String = this.oid + "." + this.action + "." + dir;
			if (this.coder::singleDir) {
				key = this.oid + "." + this.action + "." + 0;
			}
			var manager:AvatarAssetManager = AvatarAssetManager.getInstance();
			if (manager.bitmapdatas[key] != null) {
				return manager.bitmapdatas[key][frame] as BitmapData;
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
			this.bitmapFlips = null;
			this.action = null;
			this.maxRects = null;
			this.avatarType = null;
			this.startPlayTime = 0;
			this.speed = 0;
			this.frames = 0;
			super.dispose();
		}

	}
}
