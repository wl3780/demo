package com.engine.core.view.avatar.data
{
	import com.engine.core.Engine;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	import com.engine.utils.Hash;
	

	public class AvatarActionFormatGroup extends Proto
	{
		private static var _instanceHash_:Hash = new Hash();
		private static var _recoverQueue_:Vector.<AvatarActionFormatGroup> = new Vector.<AvatarActionFormatGroup>();
		private static var _recoverIndex_:int = 50;

		public var idName:String;
		public var owner:String;
		public var type:String;
		public var isLoaded:Boolean;
		public var isPended:Boolean;
		public var isDisposed:Boolean = false;
		public var quoteQueue:Vector.<String>;
		public var wealth_path:String;
		public var wealth_id:String;
		public var isCreateWarn:Boolean = true;
		
		private var _actionGroup:Hash;

		public function AvatarActionFormatGroup()
		{
			super();
			_actionGroup = new Hash();
			this.quoteQueue = new Vector.<String>();
			AvatarActionFormatGroup._instanceHash_.put(this.id, this);
		}
		
		public static function createAvatarActionFormatGroup():AvatarActionFormatGroup
		{
			var result:AvatarActionFormatGroup = null;
			if (_recoverQueue_.length) {
				result = _recoverQueue_.pop();
				result.coder::id = Engine.getSoleId();
				AvatarActionFormatGroup._instanceHash_.put(result.id, result);
			} else {
				result = new AvatarActionFormatGroup();
			}
			return result;
		}
		
		public static function takeAvatarActionFormatGroup(id:String):AvatarActionFormatGroup
		{
			return AvatarActionFormatGroup._instanceHash_.take(id) as AvatarActionFormatGroup;
		}
		
		public static function removeAvatarActionFormatGroup(id:String):void
		{
			AvatarActionFormatGroup._instanceHash_.remove(id);
		}
		
		public function addAction(action:String, format:AvatarActionFormat):void
		{
			_actionGroup.put(action, format);
		}

		public function takeAction(action:String):AvatarActionFormat
		{
			return _actionGroup.take(action) as AvatarActionFormat;
		}
		
		public function removeAction(action:String):AvatarActionFormat
		{
			return _actionGroup.remove(action) as AvatarActionFormat;
		}
		
		public function hasAction(action:String):Boolean
		{
			return _actionGroup.has(action);
		}
		
		public function noticeAvatarActionData():void
		{
			if (this.isLoaded) {
				var data:AvatarActionData = null;
				var index:int = 0;
				while (index < this.quoteQueue.length) {
					data = AvatarActionData.takeAvatarData(this.quoteQueue[index]);
					if (data) {
						data.onSetupReady();
					}
					index++;
				}
				this.quoteQueue.length = 0;
			}
		}
		
		public function recover():void
		{
			if (this.isDisposed) {
				return;
			}
			if (_recoverQueue_.length < _recoverIndex_) {
				_actionGroup.reset();
				this.quoteQueue.length = 0;
				AvatarActionFormatGroup._recoverQueue_.push(this);
				AvatarActionFormatGroup._instanceHash_.remove(this.id);
			} else {
				this.dispose();
			}
		}
		
		override public function dispose():void
		{
			AvatarActionFormatGroup._instanceHash_.remove(this.id);
			super.dispose();
			this.isDisposed = true;
		}

	}
} 
