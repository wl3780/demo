package com.engine.core
{
	import com.engine.namespaces.coder;
	import com.engine.utils.FPSUtils;
	import com.engine.utils.SuperKey;
	
	import core.HeartbeatFactory;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.geom.Rectangle;

	public class Engine 
	{

		public static const TMP_FILE:String = ".tmp";
		public static const SM_FILE:String = ".sm";
		public static const SIGN:String = "@";
		public static const LINE:String = "_";
		public static const WEALTH_ALONE_SIGN:String = "【WQA】";
		public static const WEALTH_GROUP_SIGN:String = "【WQG】";
		
		public static const SWF_Files:Vector.<String> = new <String>["swf","tmp"];
		public static const IMG_Files:Vector.<String> = new <String>["png","jpg","jpeg","gif","jxr",""];
		public static const TEXT_Files:Vector.<String> = new <String>["text","css","as","xml","html"];
		
		public static var totalAvatarAssetsIndex:int;
		public static var totalEffectAssetsIndex:int;
		public static var handleCount:int = 0;
		public static var delayTime:int = 0;
		public static var moveTime:Number = 0.2;
		public static var EYE_SHOT_RECT:Rectangle = new Rectangle(0, 0, 0x0400, 0x0300);
		
		public static var stage:Stage;
		/** 四叉树id */
		public static var SCENE_ITEM_NODER:String = "SCENE_ITEM_NODER";
		public static var CORE_RECT:Rectangle;
		public static var _Lessen_Frame_:int = 1;
		public static var stopMove:Boolean = true;
		
		public static var mini_bitmapData:BitmapData;
		public static var char_shadow:BitmapData;
		public static var char_shadow_arr:Vector.<BitmapData> = new Vector.<BitmapData>();
		
		public static var isCheat:Boolean = false;
		public static var sceneClickAbled:Boolean = true;
		public static var sceneIntersects:Boolean = false;
		public static var mouseStateLock:Boolean = false;
		public static var screenShaking:Boolean = true;
		
		public static var fps:int;
		public static var mainCharId:String = "haha";
		public static var enabled:Boolean = true;
		
		private static var coreTarget:DisplayObjectContainer;
		private static var INSTANCE_INDEX:int = 0;

		coder static function nextInstanceIndex():int
		{
			if (INSTANCE_INDEX > 2147483646) {
				INSTANCE_INDEX = 0;
			}
			INSTANCE_INDEX++;
			return INSTANCE_INDEX;
		}
		
		public static function getSoleId():String
		{
			return Engine.coder::nextInstanceIndex().toString(16);
		}

		public static function setup(target:DisplayObjectContainer, path:String, lang:String="zh_CN", ver:String="v1.0"):void
		{
			var pStage:Stage = target.stage;
			Engine.coreTarget = target;
			Engine.stage = pStage;
			EngineGlobal.assetsHost = path;
			EngineGlobal.language = lang;
			EngineGlobal.version = ver;
			
			FPSUtils.setup(pStage);
			SuperKey.getInstance().setUp(pStage);
			HeartbeatFactory.getInstance().setup(pStage);
		}

	}
}
