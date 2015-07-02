package com.engine.core.view.world
{
	import com.engine.core.Core;
	import com.engine.core.controls.events.WealthProgressEvent;
	import com.engine.core.model.map.SquareMapData;
	import com.engine.core.tile.TileGroup;
	import com.engine.core.view.scenes.Scene;
	import com.engine.namespaces.coder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;

	public class MapLayer extends Sprite 
	{

		public var mapData:SquareMapData;
		public var inited:Boolean = true;
		
		private var maps:Dictionary;
		private var loader:Loader;
		private var firstLoad:Boolean = false;
		private var bmd:BitmapData;
		private var map_id:String;
		private var mapBitmapData:BitmapData;
		private var bg_bmd:BitmapData;
		private var loader_:URLLoader;
		private var scene_data_path:String;
		private var gid:String;
		private var _bgHash:Array;
		private var time:Number = 0;
		private var loadTime:int = 0;
		private var _limitIndex_:int = 2;
		private var wealthQuene:Array;
		private var loadHash:Dictionary;
		private var bgHash:Dictionary;
		private var mapView:Array;
		private var _time_:int = 10;
		private var images:Array;

		public function MapLayer()
		{
			this.wealthQuene = [];
			this.loadHash = new Dictionary();
			this.images = [];
			super();
			this.mouseChildren = this.mouseEnabled = false;
			this.tabChildren = this.tabEnabled = false;
		}

		private function resizeFunc(evt:Event):void
		{
			if (((((this.stage) && (Scene.scene))) && (Scene.scene.mainChar))) {
				this.loadImage(Scene.scene.mainChar.x, Scene.scene.mainChar.y);
			}
		}

		private function getMapDataPath(mapID:String):String
		{
			var path:String = Core.hostPath + Core.mapPath + "map_data/" + mapID + ".data?version=" + Core.version;
			return path.replace("$language$", Core.language);
		}

		public function init(mapID:String):void
		{
			this.maps = new Dictionary();
			this.map_id = mapID;
			if (this.bg_bmd) {
				this.bg_bmd.dispose();
				this.bg_bmd = null;
			}
			
			if (this.loader) {
				this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.miniMapLoadedFunc);
				this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.errorFunc);
			}
			if (this.loader_) {
				try {
					this.loader_.removeEventListener(Event.COMPLETE, this.loadedDataFunc);
					this.loader_.removeEventListener(IOErrorEvent.IO_ERROR, this.loadedDataErrorFunc);
					this.loader_.close();
				} catch(e:Error) {
				}
			}
			
			var mapPath:String = this.getMapDataPath(mapID);
			this.scene_data_path = mapPath;
			this.loader_ = new URLLoader();
			this.loader_.dataFormat = URLLoaderDataFormat.BINARY;
			this.loader_.addEventListener(Event.COMPLETE, this.loadedDataFunc);
			this.loader_.addEventListener(IOErrorEvent.IO_ERROR, this.loadedDataErrorFunc);
			this.loader_.load(new URLRequest(mapPath));
			Core.stage.addEventListener(Event.RESIZE, this.resizeFunc);
			log("saiman", "加载地图数据文件---------------");
		}

		private function loadedDataErrorFunc(evt:IOErrorEvent):void
		{
			if (this.scene_data_path) {
				if (this.loader_) {
					try {
						this.loader_.removeEventListener(Event.COMPLETE, this.loadedDataFunc);
						this.loader_.removeEventListener(IOErrorEvent.IO_ERROR, this.loadedDataErrorFunc);
						this.loader_.close();
					} catch(e:Error) {
					}
				}
				this.loader_ = new URLLoader();
				this.loader_.dataFormat = URLLoaderDataFormat.BINARY;
				this.loader_.addEventListener(Event.COMPLETE, this.loadedDataFunc);
				this.loader_.addEventListener(IOErrorEvent.IO_ERROR, this.loadedDataErrorFunc);
				this.loader_.load(new URLRequest(this.scene_data_path));
			}
		}
		
		private function loadedDataFunc(evt:Event):void
		{
			log("saiman", "地图数据加载完毕！！！-----------------");
			this.scene_data_path = null;
			var bytes:ByteArray = this.loader_.data as ByteArray;
			if (bytes) {
				this.mapData = this.prase(bytes);
			}
			this.loader_.close();
			
			this.graphics.clear();
			var miniPath:String = Core.hostPath + Core.mapPath + "map_mini/" + this.map_id + ".jpg?version=" + Core.version;
			var context:LoaderContext = new LoaderContext();
			context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;	// 解码策略
			this.loader = new Loader();
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.miniMapLoadedFunc);
			this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.errorFunc);
			this.loader.load(new URLRequest(miniPath), context);
			log("saiman", "加载小地图--------------------");
			
			Scene.scene.setupReady();
			this.loadImage(Scene.scene.mainChar.x, Scene.scene.mainChar.y);
		}

		private function loadedFunc(evt:Event):void
		{
			var _local_2:Loader = evt.target.loader as Loader;
			_local_2.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.loadedFunc);
			_local_2.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.errorFunc);
			setTimeout(this.render, (50 + ((Math.random() * 50) >> 0)), evt);
			var _local_3:Boolean = Scene.scene.changing;
			if (_local_3) {
				_limitIndex_++;
				return;
			}
		}

		private function render(_arg_1:Event):void
		{
			var _local_4:Matrix;
			var _local_5:int;
			var _local_6:int;
			var _local_7:int;
			var _local_8:int;
			var _local_2:Loader = (_arg_1.target.loader as Loader);
			var _local_3:Bitmap = (_local_2.content as Bitmap);
			if (_local_3) {
				log("saiman", "加载完成：", _local_2.name);
				if (((_local_3.bitmapData) && ((this.bgHash[((_local_2.x + "-") + _local_2.y)] == null)))) {
					_local_2.removeEventListener(Event.ENTER_FRAME, this.render);
					delete this.loadHash[((_local_2.x + "-") + _local_2.y)];
					_local_4 = new Matrix();
					_local_4.tx = _local_2.x;
					_local_4.ty = _local_2.y;
					this.graphics.beginBitmapFill(_local_3.bitmapData, _local_4, false);
					_local_5 = _local_2.x;
					_local_6 = _local_2.y;
					_local_7 = (_local_5 + _local_3.width);
					_local_8 = (_local_6 + _local_3.height);
					this.graphics.drawTriangles(new <Number>[_local_5, _local_6, _local_7, _local_6, _local_7, _local_8, _local_5, _local_8], new <int>[0, 1, 2, 2, 3, 0]);
					this.time = Core.delayTime;
					this.bgHash[((_local_2.x + "-") + _local_2.y)] = _local_2;
					Scene.scene.charMove();
					_limitIndex_++;
				}
				_limitIndex_ = 2;
				this.loadImageFunc();
			}
		}

		private function reRender():void
		{
			var _local_9:String;
			var _local_11:int;
			var _local_12:int;
			var _local_13:int;
			var _local_14:Loader;
			var _local_15:Bitmap;
			var _local_16:Matrix;
			var _local_17:int;
			var _local_18:int;
			var _local_19:int;
			var _local_20:int;
			var _local_1:int = Core.IMAGE_SZIE;
			var _local_2:Point = this.globalToLocal(new Point());
			var _local_3:Point = new Point();
			_local_3.x = Core.stage.stageWidth;
			_local_3.y = Core.stage.stageHeight;
			var _local_4:Point = this.globalToLocal(_local_3);
			_local_2.x = Math.floor((_local_2.x / _local_1));
			_local_2.y = Math.floor((_local_2.y / _local_1));
			_local_4.x = Math.ceil((_local_4.x / _local_1));
			_local_4.y = Math.ceil((_local_4.y / _local_1));
			var _local_5:int = _local_2.x;
			var _local_6:int = _local_2.y;
			var _local_7:int = _local_4.x;
			var _local_8:int = _local_4.y;
			var _local_10:int = _local_6;
			while (_local_10 <= _local_8) {
				_local_11 = _local_5;
				while (_local_11 <= _local_7) {
					_local_12 = (_local_11 * _local_1);
					_local_13 = (_local_10 * _local_1);
					if ((((_local_10 >= 0)) && ((_local_11 >= 0)))) {
						if (((_bgHash[_local_11]) && (_bgHash[_local_11][_local_10]))) {
							_local_14 = this.bgHash[((_local_12 + "-") + _local_13)];
							if (_local_14) {
								_local_15 = (_local_14.content as Bitmap);
								_local_16 = new Matrix();
								_local_16.tx = _local_14.x;
								_local_16.ty = _local_14.y;
								this.graphics.beginBitmapFill(_local_15.bitmapData, _local_16, false);
								_local_17 = _local_14.x;
								_local_18 = _local_14.y;
								_local_19 = (_local_17 + _local_15.width);
								_local_20 = (_local_18 + _local_15.height);
								this.graphics.drawTriangles(new <Number>[_local_17, _local_18, _local_19, _local_18, _local_19, _local_20, _local_17, _local_20], new <int>[0, 1, 2, 2, 3, 0]);
							} else {
								this.drawMini(_local_12, _local_13, _local_1, _local_1);
							}
						} else {
							this.drawMini(_local_12, _local_13, _local_1, _local_1);
						}
					}
					_local_11++;
				}
				_local_10++;
			}
		}

		public function clean(sceneID:int=-1):void
		{
			if (this.loader) {
				this.loader.unloadAndStop();
				this.loader = null;
			}
			this.graphics.clear();
			var _local_2:Dictionary = new Dictionary();
			var _local_5:Object;
			var _local_6:Loader;
			for (var _local_3:String in this.loadHash) {
				_local_5 = this.loadHash[_local_3];
				_local_6 = _local_5.loader;
				if (_local_6.name.indexOf("scene_" + sceneID) == -1) {
					_local_6.unloadAndStop();
				} else {
					_local_2[_local_3] = _local_5;
				}
			}
			this.loadHash = _local_2;
			
			var _local_4:Dictionary = new Dictionary();
			if (this.bgHash) {
				var _local_7:String;
				var _local_8:Loader;
				for (_local_7 in this.bgHash) {
					_local_8 = this.bgHash[_local_7];
					if (_local_8) {
						if (_local_8.name.indexOf("scene_" + sceneID) == -1) {
							if (_local_8.content) {
								Bitmap(_local_8.content).bitmapData.dispose();
							}
							_local_8.unloadAndStop();
						} else {
							_local_4[_local_7] = _local_8;
						}
					}
				}
			}
			this.bgHash = _local_4;
			
			this.images = [];
			_limitIndex_ = 2;
			this.wealthQuene = [];
		}

		public function unload():void
		{
			var _local_1:Loader;
			_limitIndex_ = 2;
			this.mapData = null;
			this.graphics.clear();
			this.mapView = new Array();
			if (this.loader) {
				this.loader.unloadAndStop();
			}
			if (this.bgHash) {
				for each (_local_1 in this.bgHash) {
					if (_local_1) {
						Bitmap(_local_1.content).bitmapData.dispose();
						_local_1.unloadAndStop();
					}
					_local_1 = null;
				}
			}
			this.images = [];
			this.bgHash = new Dictionary();
			TileGroup.getInstance().dispose();
			TileGroup.getInstance().initialize();
			this.firstLoad = true;
			if (_bgHash) {
				_bgHash = null;
			}
			_bgHash = new Array();
			this.maps = new Dictionary();
			this.graphics.clear();
		}

		private function errorFunc(evt:IOErrorEvent):void
		{
			_limitIndex_++;
			this.loadImageFunc();
			log("saiman", " 加载错误：", evt.target.loader.name);
		}

		private function progressFunc(_arg_1:WealthProgressEvent):void
		{
		}

		private function miniMapLoadedFunc(evt:Event):void
		{
			log("saiman", "小地图加载完毕--------------------");
			this.bg_bmd = BitmapData(evt.target.loader.content.bitmapData).clone();
			if (this.loader) {
				this.loader.unloadAndStop();
				this.loader = null;
			}
			
			this.mapData.width = this.mapData.pixel_width;
			this.mapData.height = this.mapData.pixel_height;
			if (this.bg_bmd) {
				var sx:Number = this.mapData.pixel_width / this.bg_bmd.width;
				var sy:Number = this.mapData.pixel_height / this.bg_bmd.height;
				this.graphics.clear();
				var mtx:Matrix = new Matrix();
				mtx.scale(sx, sy);
				this.graphics.beginBitmapFill(this.bg_bmd, mtx, false);
				this.graphics.drawRect(0, 0, this.mapData.pixel_width, this.mapData.pixel_height);
				if (Core.mini_bitmapData) {
					Core.mini_bitmapData.dispose();
				}
				Core.mini_bitmapData = this.bg_bmd.clone();
			}
			this.reRender();
			this.inited = true;
			Scene.scene.mapData = this.mapData;
		}

		public function loadImage(px:Number, py:Number):void
		{
			if (this.mapData == null || Scene.scene.changing || Scene.scene.isReady == false) {
				return;
			}
			
			var idx:int;
			var len:int = this.wealthQuene.length;
			var obj:Object;
			var pass:Boolean = true;
			while (idx < len) {
				obj = this.wealthQuene[idx];
				if (obj.px != px && obj.py != py) {
					pass = false;
				}
				idx++;
			}
			if (pass) {
				this.wealthQuene.push({"px":px,"py":py});
			}
			this.loadImageFunc();
		}

		private function drawMini(_arg_1:Number, _arg_2:Number, _arg_3:Number, _arg_4:Number):void
		{
			var _local_8:Matrix;
			if (((!(this.mapData)) || (!(Core.mini_bitmapData)))) {
				return;
			}
			var _local_5:BitmapData = Core.mini_bitmapData;
			var _local_6:Number = (this.mapData.pixel_width / _local_5.width);
			var _local_7:Number = (this.mapData.pixel_height / _local_5.height);
			if (_local_5) {
				_local_8 = new Matrix();
				_local_8.scale(_local_6, _local_7);
				this.graphics.beginBitmapFill(_local_5, _local_8, false);
				this.graphics.drawRect(_arg_1, _arg_2, _arg_3, _arg_4);
			}
		}

		public function loadImageFunc(_arg_1:Boolean=false):void
		{
			var _local_2:Number;
			var _local_3:Number;
			var _local_17:String;
			var _local_20:String;
			var _local_25:int;
			var _local_26:String;
			var _local_27:Loader;
			var _local_28:LoaderContext;
			if ((((this.wealthQuene.length <= 0)) || ((_limitIndex_ < 0)))) {
				return;
			}
			var _local_4:Object = this.wealthQuene.shift();
			_local_2 = _local_4.px;
			_local_3 = _local_4.py;
			var _local_5:int = Core.IMAGE_SZIE;
			var _local_6:Point = this.globalToLocal(new Point());
			var _local_7:Point = new Point();
			_local_7.x = Core.stage.stageWidth;
			_local_7.y = Core.stage.stageHeight;
			var _local_8:Point = this.globalToLocal(_local_7);
			_local_7 = new Point();
			_local_7.x = (Core.stage.stageWidth / 2);
			_local_7.y = (Core.stage.stageHeight / 2);
			var _local_9:Point = this.globalToLocal(_local_7);
			_local_6.x = Math.floor((_local_6.x / _local_5));
			_local_6.y = Math.floor((_local_6.y / _local_5));
			_local_8.x = Math.round((_local_8.x / _local_5));
			_local_8.y = Math.round((_local_8.y / _local_5));
			var _local_10:int = Math.floor((_local_9.x / _local_5));
			var _local_11:int = Math.floor((_local_9.y / _local_5));
			var _local_12:Vector.<String> = new Vector.<String>();
			if ((_bgHash == null)) {
				_bgHash = [];
			}
			var _local_13:int = _local_6.x;
			var _local_14:int = _local_6.y;
			var _local_15:int = _local_8.x;
			var _local_16:int = _local_8.y;
			if (coder::hostPath != null) {
				_local_17 = ((((coder::hostPath + Core.mapPath) + "map_image/") + this.map_id) + "/");
			} else {
				_local_17 = ((((Core.hostPath + Core.mapPath) + "map_image/") + this.map_id) + "/");
			}
			var _local_18:int;
			var _local_19:int = 1;
			var _local_21:Rectangle = new Rectangle(0, 0, _local_5, _local_5);
			var _local_22:Point = new Point();
			var _local_23:Rectangle = new Rectangle(0, 0, Core.stage.stageWidth, Core.stage.stageHeight);
			var _local_24:int = _local_14;
			while (_local_24 <= _local_16) {
				_local_25 = _local_13;
				while (_local_25 <= _local_15) {
					if ((((_local_24 >= 0)) && ((_local_25 >= 0)))) {
						_local_26 = (((((_local_17 + _local_25) + "_") + _local_24) + ".jpg?version=") + Core.version);
						if (_bgHash[_local_25] == null) {
							_bgHash[_local_25] = [];
						}
						if ((((_bgHash[_local_25][_local_24] == null)) || (_arg_1))) {
							if ((((_local_18 <= _local_19)) || (_arg_1))) {
								_local_22.x = (_local_25 * _local_5);
								_local_22.y = (_local_24 * _local_5);
								_local_22 = this.localToGlobal(_local_22);
								_local_21.x = _local_22.x;
								_local_21.y = _local_22.y;
								if (_local_23.intersects(_local_21)) {
									_local_12.push((((((_local_17 + _local_25) + "_") + _local_24) + ".jpg?version=") + Core.version));
									log("saiman", "加载切片：", _local_26);
									_bgHash[_local_25][_local_24] = _local_26;
									_local_27 = new Loader();
									_local_27.name = _local_26;
									_local_27.x = (_local_25 * _local_5);
									_local_27.y = (_local_24 * _local_5);
									_local_27.contentLoaderInfo.addEventListener(Event.COMPLETE, this.loadedFunc);
									_local_27.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.errorFunc);
									_limitIndex_--;
									_local_28 = new LoaderContext();
									_local_28.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
									_local_27.load(new URLRequest(_local_26), _local_28);
									this.loadHash[((_local_25 + "_") + _local_24)] = {
										"i":_local_24,
										"j":_local_25,
										"loader":_local_27
									}
									_local_18++;
								}
							}
						}
					}
					_local_25++;
				}
				_local_24++;
			}
		}

		private function checkOut():void
		{
			var _local_2:Loader;
			var _local_4:String;
			var _local_5:Object;
			var _local_6:Point;
			var _local_7:int;
			var _local_8:int;
			var _local_1:Rectangle = new Rectangle(0, 0, Core.stage.stageWidth, Core.stage.stageHeight);
			var _local_3:Rectangle = new Rectangle(0, 0, 300, 300);
			for (_local_4 in this.loadHash) {
				_local_5 = this.loadHash[_local_4];
				_local_2 = (_local_5.loader as Loader);
				_local_6 = new Point();
				_local_6.x = _local_2.x;
				_local_6.y = _local_2.y;
				_local_6 = this.localToGlobal(_local_6);
				_local_3.x = _local_6.x;
				_local_3.y = _local_6.y;
				if (_local_1.intersects(_local_3) == false) {
					_local_7 = _local_5.i;
					_local_8 = _local_5.j;
					_local_2.unloadAndStop();
					_bgHash[_local_8][_local_7] = null;
				}
			}
		}

		private function prase(bytes:ByteArray):SquareMapData
		{
			var sqData:SquareMapData = new SquareMapData();
			sqData.uncode(bytes);
			return sqData;
		}

	}
}
