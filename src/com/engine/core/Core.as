package com.engine.core
{
	import com.engine.namespaces.coder;
	import com.engine.utils.FPSUtils;
	import com.engine.utils.SuperKey;
	
	import core.HeartbeatFactory;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.geom.Rectangle;

	public class Core 
	{

		public static const TMP_FILE:String = ".tmp";
		public static const SM_FILE:String = ".sm";
		public static const IMAGE_SZIE:int = 300;
		public static const SIGN:String = "#";
		public static const LINE:String = "-";
		
		public static var totalAvatarAssetsIndex:int;
		public static var totalEffectAssetsIndex:int;
		public static var handleCount:int = 0;
		public static var delayTime:int = 0;
		public static var moveTime:Number = 0.2;
		public static var EYE_SHOT_RECT:Rectangle = new Rectangle(0, 0, 0x0400, 0x0300);
		
		public static var stage:Stage;
		public static var SCENE_ITEM_NODER:String = "SCENE_ITEM_NODER";
		public static var CORE_RECT:Rectangle;
		public static var _Lessen_Frame_:int = 1;
		public static var stopMove:Boolean = true;
		
		public static var version:String = "v1.0";
		public static var language:String = "zh_CN";
		public static var hostPath:String = "/assets/src/";
		public static var avatarAssetsPath:String = "assets/$language$/avatars/";
		public static var mapPath:String = "assets/$language$/maps/";
		
		public static var shadowBitmap:Bitmap;
		public static var mini_bitmapData:BitmapData;
		public static var chat_bitmapData:BitmapData;
		public static var shadow_bitmapData:BitmapData;
		public static var char_shadow:BitmapData;
		public static var char_big_shadow:BitmapData;
		
		public static var isCheat:Boolean = false;
		public static var sceneClickAbled:Boolean = true;
		public static var sceneIntersects:Boolean = false;
		public static var mouseStateLock:Boolean = false;
		public static var screenShaking:Boolean = true;
		
		public static var fps:int;
		
		private static var coreTarget:DisplayObjectContainer;
		private static var INSTANCE_INDEX:int = 0;
		private static var _instance:Core;

		protected var $initialized:Boolean;

		coder static function nextInstanceIndex():int
		{
			if (INSTANCE_INDEX > 2147483646) {
				INSTANCE_INDEX = 0;
			}
			INSTANCE_INDEX++;
			return INSTANCE_INDEX;
		}

		public static function getInstance():Core
		{
			if (!_instance) {
				_instance = new Core();
			}
			return _instance;
		}

		public static function setup(target:DisplayObjectContainer, path:String, lang:String="zh_CN", ver:String="v1.0"):void
		{
			var pStage:Stage = target.stage;
			Core.coreTarget = target;
			Core.stage = pStage;
			Core.version = ver;
			Core.hostPath = path;
			Core.avatarAssetsPath = Core.avatarAssetsPath.replace("$language$", lang);
			Core.mapPath = Core.mapPath.replace("$language$", lang);
			
			FPSUtils.setup(pStage);
			SuperKey.getInstance().setUp(pStage);
			HeartbeatFactory.getInstance().setup(pStage);
		}

	}
}
