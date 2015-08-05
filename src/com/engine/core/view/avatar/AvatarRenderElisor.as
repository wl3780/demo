package com.engine.core.view.avatar
{
	import com.engine.core.Engine;
	import com.engine.core.EngineGlobal;
	import com.engine.core.HeartbeatFactory;
	import com.engine.core.view.scenes.Scene;
	import com.engine.interfaces.display.IAvatar;
	import com.engine.utils.FPSUtils;
	
	import flash.utils.getTimer;

	public class AvatarRenderElisor
	{
		public static var readnerNum:int = 2;

		private static var _instance_:AvatarRenderElisor;
		private static var unitQueue:Vector.<AvatarUnit> = new Vector.<AvatarUnit>();

		private var intervalue:int = 0;
		private var renderIndex:int = 0;

		public function AvatarRenderElisor()
		{
			HeartbeatFactory.getInstance().addFrameOrder(heartBeatHandler, Engine.stage);
		}
		
		public static function getInstance():AvatarRenderElisor
		{
			return _instance_ ||= new AvatarRenderElisor();
		}
		
		public static function get unit_length():int
		{
			return unitQueue.length;
		}

		public function addUnit(unit:AvatarUnit):void
		{
			if (unitQueue.indexOf(unit) == -1) {
				unitQueue.push(unit);
			}
		}
		
		public function removeUnit(unit_id:String):void
		{
			var avatarUnit:AvatarUnit = AvatarUnit.takeAvatarUnit(unit_id);
			if (avatarUnit) {
				var idx:int = unitQueue.indexOf(avatarUnit);
				if (idx != -1) {
					unitQueue.splice(idx, 1);
				}
			}
		}
		
		private function heartBeatHandler():void
		{
			if (!Scene.scene) {
				return;
			}
			if (Engine.stage) {
				EngineGlobal.stageRect.width = Engine.stage.stageWidth;
				EngineGlobal.stageRect.height = Engine.stage.stageHeight;
			}
			var needTime:int = 30;
			if (FPSUtils.fps < 10) {
				needTime = 60;
			}
			if (FPSUtils.fps < 5) {
				needTime = 150;
			}
			if (getTimer()-intervalue < needTime) {
				return;
			}
			intervalue = getTimer();
			
			renderIndex = renderIndex + 1;
			if (renderIndex >= readnerNum) {
				renderIndex = 0;
			}
			var avatarUnit:AvatarUnit = null;
			var tmpAvatar:IAvatar = null;
			var queueIndex:int = 0;
			while (queueIndex < unitQueue.length) {
				avatarUnit = unitQueue[queueIndex];
				tmpAvatar = AvatarUnitDisplay.takeUnitDisplay(avatarUnit.oid);
				if ((avatarUnit.renderindex == renderIndex) || (tmpAvatar == Scene.scene.mainChar) || (tmpAvatar as AvatarEffect)) {
					if (tmpAvatar && avatarUnit && !avatarUnit.isDisposed && !tmpAvatar.isDisposed) {
						if (avatarUnit.charType != "showad") {
							if (avatarUnit.charType == "effect") {
								avatarUnit.onBodyRender();
								avatarUnit.onEffectRender();
							} else {
								if ((tmpAvatar as AvatarEffect)) {
									if (tmpAvatar.type == "STATIC_STAGE_EFFECT") {
										if (AvatarEffect(tmpAvatar).stageIntersects) {
											avatarUnit.onEffectRender();
										}
									} else {
										avatarUnit.onEffectRender();
									}
								} else {
									avatarUnit.onBodyRender();
									avatarUnit.onEffectRender();
								}
							}
						} else {
							unitQueue.splice(queueIndex, 1);
						}
					} else {
						unitQueue.splice(queueIndex, 1);
						if (!tmpAvatar) {
							avatarUnit.dispose();
						}
					}
				}
				queueIndex++;
			}
		}

	}
} 
