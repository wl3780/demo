package com.engine.core.view.avatar.data
{
	import com.engine.core.Engine;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	import com.engine.utils.Hash;
	

	public class AvatarActionFormat extends Proto
	{
		private static var _instanceHash_:Hash = new Hash();
		private static var _recoverQueue_:Vector.<AvatarActionFormat> = new Vector.<AvatarActionFormat>();
		private static var _recoverIndex_:int = 50;

		public var idName:String;
		public var offset_x:int;
		public var offset_y:int;
		public var actionName:String;
		public var totalFrames:uint;
		public var actionSpeed:uint;
		public var replay:int = -1;
		public var skillFrame:int;
		public var hitFrame:int;
		public var totalDir:int;
		public var totalTime:int;
		public var isDisposed:Boolean = false;
		public var path:String;
		
		public var intervalTimes:Vector.<int>;
		public var txs:Vector.<Vector.<int>>;
		public var tys:Vector.<Vector.<int>>;
		public var widths:Vector.<Vector.<uint>>;
		public var heights:Vector.<Vector.<uint>>;
		public var bitmapdatas:Vector.<Vector.<String>>;
		public var max_rects:Vector.<Vector.<uint>>;
		public var dirOffsetX:Vector.<int>;
		public var dirOffsetY:Vector.<int>;
		
		private var actState:Object;

		public function AvatarActionFormat()
		{
			super();
			actState = {};
			AvatarActionFormat._instanceHash_.put(this.id, this);
		}
		
		public static function get getInstanceHash():Hash
		{
			return _instanceHash_;
		}
		
		public static function createAvatarActionFormat():AvatarActionFormat
		{
			var result:AvatarActionFormat = null;
			if (_recoverQueue_.length) {
				result = _recoverQueue_.pop();
				result.coder::id = Engine.getSoleId();
				result.init();
				AvatarActionFormat._instanceHash_.put(result.id, result);
			} else {
				result = new AvatarActionFormat();
				result.init();
			}
			return result;
		}
		
		public static function takeAvatarActionFormat(id:String):AvatarActionFormat
		{
			return AvatarActionFormat._instanceHash_.take(id) as AvatarActionFormat;
		}

		public function resetActReady():void
		{
			actState = {};
		}
		
		public function getActReady(act:String, dir:int):Boolean
		{
			var key:String = act + Engine.LINE + dir;
			return actState[key] == null ? false : actState[key];
		}
		
		public function setActReady(act:String, dir:int, value:Boolean):void
		{
			var key:String = act + Engine.LINE + dir;
			actState[key] = value;
		}
		
		public function init():void
		{
			offset_x = 0;
			offset_y = 0;
			actionName = "";
			totalFrames = 0;
			actionSpeed = 0;
			replay = -1;
			skillFrame = 0;
			hitFrame = 0;
			totalDir = 0;
			
			intervalTimes = new Vector.<int>();
			txs = new Vector.<Vector.<int>>();
			tys = new Vector.<Vector.<int>>();
			widths = new Vector.<Vector.<uint>>();
			heights = new Vector.<Vector.<uint>>();
			bitmapdatas = new Vector.<Vector.<String>>();
			max_rects = new Vector.<Vector.<uint>>();
			dirOffsetX = new <int>[0,0,0,0,0,0,0,0];
			dirOffsetY = new <int>[0,0,0,0,0,0,0,0];
		}
		
		override public function clone():Object
		{
			var result:AvatarActionFormat = AvatarActionFormat.createAvatarActionFormat();
			result.bitmapdatas = this.bitmapdatas.slice();
			return result;
		}
		
		public function recover():void
		{
			if (this.isDisposed) {
				return;
			}
			if (_recoverQueue_.length <= _recoverIndex_) {
				AvatarActionFormat._instanceHash_.remove(this.id);
				_recoverQueue_.push(this);
			} else {
				this.dispose();
			}
		}
		
		override public function dispose():void
		{
			AvatarActionFormat._instanceHash_.remove(this.id);
			super.dispose();
			this.isDisposed = true;
		}
		
		public function getLink(dir:int, frame:int):String
		{
			actionName = actionName.split("attack_warm").join("attack");
			return idName + "." + actionName + "." + dir + "." + frame;
		}
		
		public function getSwfLink():String
		{
			return idName + "." + actionName;
		}

	}
} 
