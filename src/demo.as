package 
{
	import com.engine.core.Engine;
	import com.engine.core.view.avatar.Avatar;
	import com.engine.core.view.role.Char;
	
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

	/**
	 * 入口类
	 */
	public class demo extends Sprite 
	{
		
		private static var time_dur:int;
		private static var robot_quene:Array = [];
		private static var robot_index:int = 0;
		private static var action_index:int;

		private var scene:GameScene;
		private var text:TextField;
		
		private var openShadow:Boolean = true;
		private var headVisible:Boolean = false;
		private var bodyVisible:Boolean = true;
		private var robotReady:Boolean;

		public function demo()
		{
			super();
			this.scene = new GameScene();
			this.text = new TextField();
			this.init();
		}

		private function init():void
		{
			if (this.stage) {
				this.setup(null);
			} else {
				this.addEventListener(Event.ADDED_TO_STAGE, setup);
			}
		}

		public function setup(evt:Event):void
		{
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			Engine.setup(this, "../", "zh_CN", "v1");
			this.scene.buildTree(new Rectangle(0, 0, 10000, 10000));
			this.scene.setup(Engine.stage, this);
			this.scene.changeScene(5);
			this.scene.$mapLayer.init("scene_" + 4);
			this.scene.updateMainChar("100000002", null, null);
			
			this.scene.mainChar.speed = 270;
			this.scene.mainChar.char_id = "saiman";
			this.scene.mainChar.openShadow = true;
			this.scene.mainChar.name = "HERO";
			this.scene.mainChar.nameColor(0xFF0000);
			this.scene.mainChar.point = new Point(3700, 1200);
			this.scene.onSceneReadyFunc = this.setupReady;
			this.addChild(this.scene);
			// this.scene.setSceneFlyMode(true);
			
			this.text.selectable = false;
			this.text.mouseEnabled = false;
			this.text.height = 200;
			this.text.width = 280;
			this.text.textColor = 0xFFFFFF;
			this.text.filters = [new GlowFilter(0, 1, 10, 10, 20)];
			this.addChild(this.text);
			
			this.createButton(this.clickFunc, "（隐藏/显示）身体", 200, 0);
			this.createButton(this.clickFunc2, "（隐藏/显示）名字", 400, 0);
			this.createButton(this.clickFunc3, "（隐藏/显示）影子", 600, 0);
			this.createButton(this.clickFunc4, "10机器人", 200, 35);
			this.createButton(this.clickFunc5, "50机器人", 400, 35);
			this.createButton(this.clickFunc6, "100机器人", 600, 35);
			this.createButton(this.clickFunc7, "300机器人", 200, 70);
			this.createButton(this.clickFunc8, "500机器人", 400, 70);
			this.createButton(this.clickFunc9, "1000机器人", 600, 70);
			
			HeartbeatFactory.getInstance().addFrameOrder(enterFrameFunc, null);
		}

		private function resetNum(num:int):void
		{
			if (robot_quene.length > num) {
				var char:Char = null;
				while (robot_quene.length > num) {
					char = robot_quene.pop() as Char;
					this.scene.remove(char);
					char.recover();
				}
			} else {
				var idx:int = 0;
				var len:int = num - robot_quene.length;
				while (idx < len) {
					this.createRobot();
					idx++;
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
			btn.addEventListener(MouseEvent.MOUSE_DOWN, onUIPressed);
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

		// 显示/隐藏身体
		protected function clickFunc(btn:MouseEvent):void
		{
			this.bodyVisible = !this.bodyVisible;
			var char:Avatar;
			var idx:int = robot_quene.length - 1;
			while (idx >= 0) {
				char = robot_quene[idx] as Avatar;
				char.bodyVisible = this.bodyVisible;
				idx--;
			}
		}

		// 显示/隐藏名字
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

		// 显示/隐藏影子
		protected function clickFunc3(evt:MouseEvent):void
		{
			this.openShadow = !this.openShadow;
			this.scene.mainChar.openShadow = this.openShadow;
		}

		// 10机器人
		private function clickFunc4(evt:MouseEvent):void
		{
			this.resetNum(10);
		}

		// 50机器人
		private function clickFunc5(evt:MouseEvent):void
		{
			this.resetNum(50);
		}

		// 100机器人
		private function clickFunc6(evt:MouseEvent):void
		{
			this.resetNum(100);
		}

		// 300机器人
		private function clickFunc7(evt:MouseEvent):void
		{
			this.resetNum(300);
		}

		// 500机器人
		private function clickFunc8(evt:MouseEvent):void
		{
			this.resetNum(500);
		}

		// 1000机器人
		private function clickFunc9(evt:MouseEvent):void
		{
			this.resetNum(1000);
		}

		private function setupReady():void
		{
//			this.resetNum(10);
			this.robotReady = true;
		}

		private function enterFrameFunc():void
		{
			if (this.robotReady) {
				this.robotMove();
				
				var msg:String = "\n数字1：换装\n";
				msg += "数字2：线性技能\n";
				msg += "数字3：扇形连射\n";
				msg += "Shift+左键：跳跃\n";
				this.text.text = "fps:" + Engine.fps + "\n机器人数：" + robot_quene.length + msg;
			}
		}

		private function robotMove():void
		{
			if (!robot_quene || !robot_quene.length) {
				return;
			}
			if ((getTimer() - time_dur) < 80) {
				return;
			}
			time_dur = getTimer();
			
			if (action_index >= robot_quene.length) {
				action_index = 0;
			}
			var flags:Array = [1, -1];
			var char:Char = robot_quene[action_index];
			if (!char.runing && !char.jumping) {
				var pos:Point = new Point(this.scene.mainChar.x, this.scene.mainChar.y);
				pos.x += (Math.random() * (stage.stageWidth / 2 - 100) >> 0) * flags[Math.random() * flags.length >> 0];
				pos.y += (Math.random() * (stage.stageHeight / 2 - 20) >> 0) * flags[Math.random() * flags.length >> 0];
				char.walk([pos]);
				action_index++;
			} else {
				action_index++;
			}
		}

		private function createRobot():Char
		{
			var char:Char = Char.createChar();
			char.openShadow = true;
			char.proto = null;
			char.name = "robot" + robot_index;
			char.stopMove();
			char.char_id = String(robot_index + 10000);
			
			var flags:Array = [1, -1];
			var pos:Point = new Point(this.scene.mainChar.x, this.scene.mainChar.y);
			pos.x += (Math.random() * (stage.stageWidth / 2 - 100) >> 0) * flags[Math.random() * flags.length >> 0];
			pos.y += (Math.random() * (stage.stageHeight / 2 - 20) >> 0) * flags[Math.random() * flags.length >> 0];
			char.x = pos.x;
			char.y = pos.y;
			
			var clothes:Array = ["100000001", "100000002", "100000003", "100000004"];
			this.scene.updateCharAvatarPart(char, clothes[Math.random() * clothes.length >> 0], null, null);
			char.speed = 250;
			char.headVisible = this.headVisible;
			char.bodyVisible = this.bodyVisible;
			robot_quene.push(char);
			robot_index++;
			return char;
		}

		private function onUIPressed(evt:MouseEvent):void
		{
			Engine.sceneClickAbled = false;
		}

	}
}
