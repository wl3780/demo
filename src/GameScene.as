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
		
		private var _avatarArray:Array = [100000001, 100000002, 100000004, 100000003];
		private var _avatarIndex:int = 0;

		public function GameScene()
		{
			super();
			GameScene.scene = this;
		}

		override protected function mouseDownFunc(evt:MouseEvent):void
		{
			_shiftKey = evt.shiftKey;
			isMouseDown = true;
			mouseDownTime = getTimer();
			this.mouseDownPoint = new Point(this.mouseX, this.mouseY);
			if (_shiftKey) {
				var path:Array = SceneUtil.getJumpPath(this.mainChar.point, mouseDownPoint);
				this.mainChar.jump(path);
			} else {
				var area:Rectangle = new Rectangle(this.mouseX - 100, this.mouseY - 100, 200, 200);
				var arr:Array = this.fine(area, false, 100);
				selectAvatar = HitTest.getChildUnderPoint(this, mouseDownPoint, arr) as Avatar;
				if (selectAvatar) {
					var keys:Array = [Keyboard.B, Keyboard.C, Keyboard.N];
					var keyEvent:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
					keyEvent.keyCode = keys[(Math.random() * keys.length) >> 0];
					this.keyDownFunc(keyEvent);
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

		override protected function enterFrameFunc(evt:Event):void
		{
			super.enterFrameFunc(evt);
			shadowShape.graphics.clear();
			this.fill(this.mainChar.x, this.mainChar.y, 400, 300);
			var idx:int = 0;
			var len:int = $itemLayer.numChildren;
			var dis:DisplayObject;
			while (idx < len) {
				dis = $itemLayer.getChildAt(idx) as DisplayObject;
				this.fill(dis.x, dis.y, 200, 300);
				idx++;
			}
		}

		override public function setupReady():void
		{
			super.setupReady();
			if (this.setupReadyFunc != null) {
				this.setupReadyFunc();
			}
		}

		override protected function keyDownFunc(evt:KeyboardEvent):void
		{
			var passEffect:int;
			if (this.selectAvatar == null || this.selectAvatar.parent == null) {
				var arr:Array = avatarHash.coder::values();
				this.selectAvatar = arr[arr.length - 2];
			}
			switch (evt.keyCode) {
				case Keyboard.NUMBER_1:
					_avatarIndex++;
					if (_avatarIndex >= _avatarArray.length) {
						_avatarIndex = 0;
					}
					GameScene.scene.updateCharAvatarPart(mainChar, _avatarArray[this._avatarIndex]);
					break;
				case Keyboard.NUMBER_2:
					if (this.mainChar && this.selectAvatar) {
						passEffect = 201000002;
						mainChar.stopMove();
						mainChar.faceTo(selectAvatar);
						mainChar.play(CharAction.ATTACK, null, false, function ():void
						{
							if (selectAvatar) {
								FightUtils.lineAttack(300000009, new Point(mainChar.x, mainChar.y), new Point(selectAvatar.x, selectAvatar.y), 150, 60);
							}
						});
					}
					break;
				case Keyboard.NUMBER_3:
					if (this.mainChar && this.selectAvatar) {
						passEffect = 201000002;
						mainChar.stopMove();
						mainChar.faceTo(selectAvatar);
						mainChar.play(CharAction.ATTACK, null, false, function ():void
						{
							if (selectAvatar) {
								var p1:Point = new Point(mainChar.x, mainChar.y);
								var p2:Point = new Point(selectAvatar.x, selectAvatar.y);
								FightUtils.fanAttack(passEffect, p1, p2, 90, 5, 1);
							}
						});
					}
					break;
				default:
					break;
			}
		}

	}
}
