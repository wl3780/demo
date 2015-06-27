package 
{
	import com.engine.core.Core;
	import com.engine.core.view.items.avatar.Avatar;
	import com.engine.core.view.role.Char;
	import com.engine.core.view.scenes.SceneConstant;
	
	import core.HeartbeatFactory;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.getTimer;

	public class demo extends Sprite 
	{

		private static var time_dur:int;
		private static var robot_quene:Array = [];
		private static var action_index:int;
		private static var robot_index:int = 0;

		private var scene:GameScene;
		private var text:TextField;
		private var openShadow:Boolean = true;
		private var headVisible:Boolean = false;
		private var bodyVisible:Boolean = true;
		private var robotReady:Boolean;

		public function demo()
		{
			this.scene = new GameScene();
			this.text = new TextField();
			super();
			this.init();
		}

		private function init():void
		{
			if (this.stage) {
				this.setup(null);
			} else {
				this.addEventListener(Event.ADDED_TO_STAGE, this.setup);
			}
		}

		public function setup(evt:Event):void
		{
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			Core.setup(this, "/", "zh_CN", "v1");
			this.scene.buildTree(new Rectangle(0, 0, 10000, 10000));
			this.scene.setup(Core.stage, this);
			this.scene.updataMainChar(100000002, 0, 0);
			this.scene.changeScene(5);
			this.scene.$bottomLayer.init(("scene_" + 4));
			this.scene.mainChar.speed = 270;
			this.scene.mainChar.char_id = "saiman";
			this.scene.mainChar.openShadow = true;
			this.scene.mainChar.name = "HERO";
			this.scene.mainChar.nameColor(0xFF0000);
			this.scene.mainChar.point = new Point(3700, 1200);
			this.scene.onSceneReadyFunc = this.setupReady;
			this.addChild(this.scene);
			
			this.text.selectable = false;
			this.text.mouseEnabled = false;
			this.text.height = 200;
			this.text.width = 280;
			this.text.textColor = 0xFFFFFF;
			this.text.filters = [new GlowFilter(0, 1, 10, 10, 20)];
			this.addChild(this.text);
			
			this.createButton(this.clickFunc, "（隐藏/显示）身体", 200, 0);
			this.createButton(this.clickFunc2, "（隐藏/显示）名字", 400, 0);
			this.createButton(this.clickFunc4, "10机器人", 200, 35);
			this.createButton(this.clickFunc5, "50机器人", 400, 35);
			this.createButton(this.clickFunc6, "100机器人", 600, 35);
			this.createButton(this.clickFunc7, "300机器人", 200, 70);
			this.createButton(this.clickFunc8, "500机器人", 400, 70);
			this.createButton(this.clickFunc9, "1000机器人", 600, 70);
			
			HeartbeatFactory.getInstance().addFrameOrder(this.enterFrameFunc);
		}

		private function resetNum(_arg_1:int):void
		{
			var _local_2:Char;
			var _local_3:int;
			var _local_4:int;
			if (robot_quene.length > _arg_1) {
				while (robot_quene.length > _arg_1) {
					_local_2 = (robot_quene.pop() as Char);
					this.scene.remove(_local_2);
					_local_2.recover();
				}
			} else {
				_local_3 = (_arg_1 - robot_quene.length);
				_local_4 = 0;
				while (_local_4 < _local_3) {
					this.createRobot();
					_local_4++;
				}
			}
		}

		public function createButton(handler:Function, msg:String, px:int, py:int=0):void
		{
			var btn:Sprite = new Sprite();
			btn.graphics.beginFill(0, 0.5);
			btn.graphics.drawRect(0, 0, 120, 30);
			btn.cacheAsBitmap = true;
			btn.buttonMode = true;
			btn.addEventListener(MouseEvent.CLICK, handler);
			this.addChild(btn);
			btn.x = px;
			btn.y = py;
			var label:TextField = new TextField();
			label.selectable = false;
			label.x = px;
			label.y = py;
			label.mouseEnabled = false;
			label.textColor = 0xFFFFFF;
			label.text = msg;
			this.addChild(label);
		}

		protected function clickFunc(btn:MouseEvent):void
		{
			this.bodyVisible = !this.bodyVisible;
			this.setCharBodyVisible();
		}

		protected function clickFunc2(btn:MouseEvent):void
		{
			this.headVisible = !this.headVisible;
			var char:Avatar;
			var idx:int = robot_quene.length - 1;
			while (idx >= 0) {
				char = robot_quene[idx] as Avatar;
				char.headVisible = this.headVisible;
				idx--;
			}
		}

		protected function clickFunc3(evt:MouseEvent):void
		{
			this.openShadow = !this.openShadow;
			var char:Avatar;
			var idx:int = robot_quene.length - 1;
			while (idx >= 0) {
				char = robot_quene[idx] as Avatar;
				char.openShadow = this.openShadow;
				idx--;
			}
		}

		private function clickFunc4(evt:MouseEvent):void
		{
			var _local_2:Char;
			while (robot_quene.length > 10) {
				_local_2 = (robot_quene.pop() as Char);
				this.scene.remove(_local_2);
				_local_2.recover();
			}
		}

		private function clickFunc5(_arg_1:MouseEvent):void
		{
			this.resetNum(50);
		}

		private function clickFunc6(_arg_1:MouseEvent):void
		{
			this.resetNum(100);
		}

		private function clickFunc7(_arg_1:MouseEvent):void
		{
			this.resetNum(300);
		}

		private function clickFunc8(_arg_1:MouseEvent):void
		{
			this.resetNum(500);
		}

		private function clickFunc9(_arg_1:MouseEvent):void
		{
			this.resetNum(1000);
		}

		protected function setCharBodyVisible():void
		{
			var char:Avatar;
			var idx:int = (robot_quene.length - 1);
			while (idx >= 0) {
				char = robot_quene[idx] as Avatar;
				char.bodyVisible = this.bodyVisible;
				idx--;
			}
		}

		private function setupReady():void
		{
			var idx:int;
			while (idx < 10) {
				this.createRobot();
				idx++;
			}
			this.robotReady = true;
		}

		private function enterFrameFunc():void
		{
			if (this.robotReady) {
				this.robotMove();
			}
			var msg:String = "\n数字1：换装\n";
			msg += "数字2：线性技能\n";
			msg += "数字3：扇形连射\n";
			msg += "Shift+左键：跳跃\n";
			this.text.text = "fps:" + Core.fps + "\n机器人数：" + robot_quene.length + msg;
		}

		private function robotMove():void
		{
			var _local_1:Char;
			var _local_2:Array;
			var _local_3:Point;
			if ((getTimer() - time_dur) > 80) {
				time_dur = getTimer();
				if (action_index >= robot_quene.length) {
					action_index = 0;
				}
				_local_1 = robot_quene[action_index];
				if (((!(_local_1.runing)) && (!(_local_1.jumping)))) {
					_local_2 = [1, -1];
					_local_3 = new Point(this.scene.mainChar.x, this.scene.mainChar.y);
					_local_3.x = (_local_3.x + (((Math.random() * ((stage.stageWidth / 2) - 100)) >> 0) * _local_2[((Math.random() * _local_2.length) >> 0)]));
					_local_3.y = (_local_3.y + (((Math.random() * ((stage.stageHeight / 2) - 20)) >> 0) * _local_2[((Math.random() * _local_2.length) >> 0)]));
					_local_1.walk([_local_3]);
					action_index++;
				} else {
					action_index++;
				}
			}
		}

		private function createRobot():Char
		{
			var _local_1:Char = Char.createChar();
			_local_1.openShadow = true;
			_local_1.proto = null;
			_local_1.name = ("robot" + robot_index);
			_local_1.stopMove();
			_local_1.char_id = String((robot_index + 10000));
			var _local_2:Array = [1, -1];
			var _local_3:Point = new Point(this.scene.mainChar.x, this.scene.mainChar.y);
			_local_3.x = (_local_3.x + (((Math.random() * ((stage.stageWidth / 2) - 100)) >> 0) * _local_2[((Math.random() * _local_2.length) >> 0)]));
			_local_3.y = (_local_3.y + (((Math.random() * ((stage.stageHeight / 2) - 20)) >> 0) * _local_2[((Math.random() * _local_2.length) >> 0)]));
			_local_1.x = _local_3.x;
			_local_1.y = _local_3.y;
			var _local_4:Array = [100000001, 100000002, 100000003, 100000004];
			this.scene.updataCharAvatarPart(_local_1, _local_4[((Math.random() * _local_4.length) >> 0)], 0, 0);
			_local_1.speed = 250;
			_local_1.headVisible = this.headVisible;
			_local_1.bodyVisible = this.bodyVisible;
			robot_quene.push(_local_1);
			this.scene.addItem(_local_1, SceneConstant.MIDDLE_LAYER);
			robot_index++;
			return (_local_1);
		}

		private function getCamera():Point
		{
			var p:Point = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
			return new Point(3700, 1200);
		}

		public function sceneReadyFunc():void
		{
		}


	}
}
