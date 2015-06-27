package com.engine.utils
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;

	public class SuperKey extends EventDispatcher 
	{

		public static const SUPER:String = "SAIMAN";
		public static const DEBUG:String = "DEBUG";
		public static const HELLP:String = "HELLP";
		public static const GM:String = "GM";
		
		private static var _instance:SuperKey;

		private var keyArray:Array;
		private var stage:Stage;
		private var time:int = 0;
		private var inputMode:Boolean;
		private var inputTime:int;

		public function SuperKey()
		{
			super();
			this.keyArray = [];
		}

		public static function getInstance():SuperKey
		{
			if (_instance == null) {
				_instance = new SuperKey();
			}
			return _instance;
		}


		public function setUp(pStage:Stage):void
		{
			this.stage = pStage;
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.keydownFunc);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, this.keyupFunc);
		}

		private function keydownFunc(evt:KeyboardEvent):void
		{
			if (this.inputMode) {
				if ((getTimer() - this.inputTime) > 10000) {
					this.inputMode = false;
					this.keyArray = [];
					return;
				}
				if (evt.shiftKey && evt.keyCode == Keyboard.SHIFT) {
					this.keyArray = [];
				}
				if ((getTimer() - this.time) < 200 || this.time == 0) {
					this.time = getTimer();
					this.keyArray.push(String.fromCharCode(evt.keyCode));
				} else {
					this.time = 0;
					this.keyArray = [];
					this.keyArray.push(String.fromCharCode(evt.keyCode));
				}
			}
			if (evt.shiftKey && String.fromCharCode(evt.keyCode) == "¿") {
				this.inputMode = true;
				this.inputTime = getTimer();
				this.keyArray = [];
			}
			
			var succ:Boolean = true;
			var input:String = this.keyArray.join("");
			if (input == SUPER) {
				this.dispatchEvent(new Event(SUPER));
			} else if (input == DEBUG) {
				this.dispatchEvent(new Event(DEBUG));
			} else if (input == HELLP) {
				this.dispatchEvent(new Event(HELLP));
			} else if (input == GM) {
				this.dispatchEvent(new Event(GM));
			} else {
				succ = false;
			}
			
			if (succ) {
				this.keyArray = [];
				this.inputMode = false;
				return;
			}
			this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.keydownFunc);
			this.stage.removeEventListener(KeyboardEvent.KEY_UP, this.keyupFunc);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.keydownFunc);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, this.keyupFunc);
		}

		private function keyupFunc(evt:KeyboardEvent):void
		{
			this.dispatchEvent(evt);
		}

	}
}
