package com.engine.core
{
	import com.engine.core.view.avatar.data.AvatarActionFormat;
	import com.engine.core.view.avatar.data.AvatarActionFormatGroup;
	

	public class EngineGlobal
	{
		public static const MFPS:int = 5;
		
		public static const WEALTH_QUEUE_ALONE_SIGN:String = "【WQA】";
		public static const WEALTH_QUEUE_GROUP_SIGN:String = "【WQG】";
		
		public static const IMAGE_WIDTH:int = 320;
		public static const IMAGE_HEIGHT:int = 180;
		
		public static const AVATAR_IMAGE_WIDTH:int = 400;
		public static const AVATAR_IMAGE_HEIGHT:int = 300;
		
		public static const TYPE_REFLEX:Object = {
			mid:"clothes",
			eid:"effects",
			midm:"mounts",
			wid:"weapons",
			wgid:"wings"
		};
		public static const eid:String = "eid";
		public static const mid:String = "mid";
		public static const wid:String = "wid";
		public static const wgid:String = "wgid";
		public static const midm:String = "midm";
		
		public static var SHADOW_ID:String = "npc054";
		public static var MALE_SHADOW:String = "ym1001";
		public static var FAMALE_SHADOW:String = "yw1001";
		
		public static var shadowAvatarGroupMale:AvatarActionFormatGroup;
		public static var shadowAvatarGroupFamale:AvatarActionFormatGroup;
		public static var shadowAvatarGroupBaseMale:AvatarActionFormatGroup;
		public static var shadowAvatarGroupBaseFamale:AvatarActionFormatGroup;
		public static var shadowAvatarGroup:AvatarActionFormatGroup;
		
		public static var avatarData:AvatarActionFormat;
		public static var avatarDataMale:AvatarActionFormat;
		public static var avatarDataFamale:AvatarActionFormat;
		public static var avatarDataBaseMale:AvatarActionFormat;
		public static var avatarDataBaseFamale:AvatarActionFormat;
		
		public static const DELIMITER:String = "&";
		public static const SM_EXTENSION:String = ".sm";
		public static const TMP_EXTENSION:String = ".tmp";

		public static var assetsHost:String;
		public static var language:String = "zh_CN";
		public static var version:String = "1.0";
		
		private static var SCENE_ASSETS_DIR_:String;
		private static var AVATAR_ASSETS_DIR_:String;

		public static function get SCENE_IMAGE_DIR():String
		{
			if (SCENE_ASSETS_DIR_ == null) {
				SCENE_ASSETS_DIR_ = assetsHost + "assets/" + language + "/maps/";
			}
			return SCENE_ASSETS_DIR_;
		}
		
		public static function get AVATAR_ASSETS_DIR():String
		{
			if (AVATAR_ASSETS_DIR_ == null) {
				AVATAR_ASSETS_DIR_ = assetsHost + "assets/" + language + "/avatars/";
			}
			return AVATAR_ASSETS_DIR_;
		}
		
		public static function getAvatarAssetsConfigPath(idName:String):String
		{
			return AVATAR_ASSETS_DIR + "output/" + idName + SM_EXTENSION;
		}
		public static function getAvatarAssetsPath(idName:String, action:String, dir:int):String
		{
			var idType:String = idName.split(Engine.LINE)[0];
			return AVATAR_ASSETS_DIR + TYPE_REFLEX[idType] + "/" + idName + Engine.LINE + action + Engine.LINE + dir + TMP_EXTENSION;
		}
		
		public static function getMapConfigPath(map_id:String):String
		{
			return EngineGlobal.SCENE_IMAGE_DIR + "map_data/scene_" + map_id + ".data?ver=" + EngineGlobal.version
		}
		public static function getMapMiniPath(map_id:String):String
		{
			return EngineGlobal.SCENE_IMAGE_DIR + "map_mini/scene_" + map_id + ".jpg?ver=" + EngineGlobal.version
		}
		public static function getMapImagePath(map_id:String, x:int, y:int):String
		{
			return EngineGlobal.SCENE_IMAGE_DIR + "map_image/scene_" + map_id + "/" + x + Engine.LINE + y + ".jpg?ver=" + EngineGlobal.version;
		}
	}
}
