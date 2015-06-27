package 
{
	import com.engine.core.view.items.avatar.Avatar;
	import com.engine.core.view.items.avatar.CharAction;
	import com.engine.core.view.scenes.Scene;
	import com.engine.namespaces.coder;
	import com.engine.utils.HitTest;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;

	public class GameScene extends Scene 
	{

		public static var scene:GameScene;

		public var setupReadyFunc:Function;
		
		private var index:int = 0;

		public function GameScene()
		{
			scene = this;
		}

		override protected function mouseDownFunc(_arg_1:MouseEvent):void
		{
			var _local_2:Array;
			var _local_3:Rectangle;
			var _local_4:Array;
			var _local_5:Array;
			var _local_6:KeyboardEvent;
			_shiftKey = _arg_1.shiftKey;
			isMouseDown = true;
			mouseDownTime = getTimer();
			this.mouseDownPoint = new Point(this.mouseX, this.mouseY);
			if (_shiftKey) {
				_local_2 = SceneUtil.getJumpPath(this.mainChar.point, mouseDownPoint);
				this.mainChar.jump(_local_2);
			} else {
				_local_3 = new Rectangle((this.mouseX - 100), (this.mouseY - 100), 200, 200);
				_local_4 = this.fine(_local_3, false, 100);
				selectAvatar = (HitTest.getChildUnderPoint(this, mouseDownPoint, _local_4) as Avatar);
				if (selectAvatar) {
					_local_5 = [Keyboard.B, Keyboard.C, Keyboard.N];
					_local_6 = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
					_local_6.keyCode = _local_5[((Math.random() * _local_5.length) >> 0)];
					this.keyDownFunc(_local_6);
				} else {
					if ((getTimer() - time) > 500) {
						this.mainCharWalk(mouseDownPoint);
						time = getTimer();
					}
				}
			}
		}

		override public function mainCharWalk(_arg_1:Point, _arg_2:Function=null, _arg_3:int=1000, _arg_4:int=1, _arg_5:Boolean=true, _arg_6:Boolean=false):void
		{
			if (mainChar.lockMove) {
				return;
			}
			MainCharWalkManager.getInstance().mainCharWalk(_arg_1, _arg_2, _arg_3, _arg_4, _arg_5);
		}

		override protected function enterFrameFunc(_arg_1:Event):void
		{
			var _local_4:DisplayObject;
			super.enterFrameFunc(_arg_1);
			shadowShape.graphics.clear();
			this.fill(this.mainChar.x, this.mainChar.y, 400, 300);
			var _local_2:int = $itemLayer.numChildren;
			var _local_3:int;
			while (_local_3 < _local_2) {
				_local_4 = ($itemLayer.getChildAt(_local_3) as DisplayObject);
				this.fill(_local_4.x, _local_4.y, 200, 300);
				_local_3++;
			}
		}

		override public function setupReady():void
		{
			super.setupReady();
			if (this.setupReadyFunc != null) {
				this.setupReadyFunc();
			}
		}

		override protected function keyDownFunc(e:KeyboardEvent):void
		{
			var arr:Array;
			var array:Array;
			var passEffect:int;
			if ((((selectAvatar == null)) || (((selectAvatar) && (!(selectAvatar.parent)))))) {
				arr = avatarHash.coder::values();
				selectAvatar = arr[(arr.length - 2)];
			}
			switch (e.keyCode) {
				case Keyboard.NUMBER_2:
					if (((mainChar) && (selectAvatar))) {
						passEffect = 201000002;
						mainChar.stopMove();
						mainChar.faceTo(selectAvatar);
						mainChar.play(CharAction.ATTACK, null, false, function ():void
						{
							if (selectAvatar) {
								SceneFightUtils.lineAttack(300000009, new Point(mainChar.x, mainChar.y), new Point(selectAvatar.x, selectAvatar.y), 150, 60);
							}
						});
					}
					return;
				case Keyboard.NUMBER_3:
					if (((mainChar) && (selectAvatar))) {
						passEffect = 201000002;
						mainChar.stopMove();
						mainChar.faceTo(selectAvatar);
						mainChar.play(CharAction.ATTACK, null, false, function ():void
						{
							var _local_1:Point;
							var _local_2:Point;
							if (selectAvatar) {
								_local_1 = new Point(mainChar.x, mainChar.y);
								_local_2 = new Point(selectAvatar.x, selectAvatar.y);
								SceneFightUtils.fanAttack(passEffect, _local_1, _local_2, 90, 5, 1);
							}
						});
					}
					return;
				case Keyboard.NUMBER_1:
					array = [100000001, 100000002, 100000004, 100000003];
					this.index++;
					if (this.index >= array.length) {
						this.index = 0;
					}
					GameScene.scene.updataCharAvatarPart(mainChar, array[this.index]);
					return;
			}
		}

	}
}
