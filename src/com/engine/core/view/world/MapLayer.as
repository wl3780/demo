package com.engine.core.view.world
{
	import com.engine.core.Engine;
	import com.engine.core.EngineGlobal;
	import com.engine.core.model.map.SquareMapData;
	import com.engine.core.tile.TileGroup;
	import com.engine.core.view.scenes.Scene;
	
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
		
		private var loader:Loader;
		private var loader_:URLLoader;
		private var map_id:String;
		private var bg_bmd:BitmapData;
		private var scene_data_path:String;
		private var _bgHash:Array;
		private var _limitIndex_:int = 2;
		private var wealthQuene:Array;
		private var loadHash:Dictionary;
		private var bgHash:Dictionary;
		
		private var _stageMinP:Point;
		private var _stageMidP:Point;
		private var _stageMaxP:Point;

		public function MapLayer()
		{
			super();
			this.mouseChildren = this.mouseEnabled = false;
			this.tabChildren = this.tabEnabled = false;
			
			this.wealthQuene = [];
			this.loadHash = new Dictionary();
		}

		private function resizeFunc(evt:Event):void
		{
			_stageMinP.x = Engine.stage.stageWidth/2;
			_stageMinP.y = Engine.stage.stageHeight/2;
			_stageMaxP.x = Engine.stage.stageWidth;
			_stageMaxP.y = Engine.stage.stageHeight;
			if (this.stage && Scene.scene && Scene.scene.mainChar) {
				this.loadImage(Scene.scene.mainChar.x, Scene.scene.mainChar.y);
			}
		}

		private function getMapDataPath(mapId:String):String
		{
			var path:String = EngineGlobal.SCENE_IMAGE_DIR + "map_data/" + mapId + ".data?version=" + EngineGlobal.version;
			return path;
		}

		public function init(mapId:String):void
		{
			this.map_id = mapId;
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
			
			_stageMinP = new Point(0, 0);
			_stageMidP = new Point(Engine.stage.stageWidth/2, Engine.stage.stageHeight/2);
			_stageMaxP = new Point(Engine.stage.stageWidth, Engine.stage.stageHeight);
			
			var mapPath:String = this.getMapDataPath(mapId);
			this.scene_data_path = mapPath;
			this.loader_ = new URLLoader();
			this.loader_.dataFormat = URLLoaderDataFormat.BINARY;
			this.loader_.addEventListener(Event.COMPLETE, this.loadedDataFunc);
			this.loader_.addEventListener(IOErrorEvent.IO_ERROR, this.loadedDataErrorFunc);
			this.loader_.load(new URLRequest(mapPath));
			Engine.stage.addEventListener(Event.RESIZE, this.resizeFunc);
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
			var miniPath:String = EngineGlobal.SCENE_IMAGE_DIR + "map_mini/" + this.map_id + ".jpg?version=" + EngineGlobal.version;
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
			var bgLoader:Loader = evt.target.loader as Loader;
			bgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.loadedFunc);
			bgLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.errorFunc);
			setTimeout(this.render, (50 + Math.random() * 50) >> 0, evt);
			if (Scene.scene.changing) {
				_limitIndex_++;
				return;
			}
		}

		private function render(evt:Event):void
		{
			var bgLoader:Loader = evt.target.loader as Loader;
			var bgImage:Bitmap = bgLoader.content as Bitmap;
			if (bgImage) {
				log("saiman", "加载完成：", bgLoader.name);
				if (bgImage.bitmapData && this.bgHash[bgLoader.x + "-" + bgLoader.y] == null) {
					bgLoader.removeEventListener(Event.ENTER_FRAME, this.render);
					delete this.loadHash[bgLoader.x + "-" + bgLoader.y];
					var mtx:Matrix = new Matrix();
					mtx.tx = bgLoader.x;
					mtx.ty = bgLoader.y;
					this.graphics.beginBitmapFill(bgImage.bitmapData, mtx, false);
					var startX:int = bgLoader.x;
					var startY:int = bgLoader.y;
					var endX:int = startX + bgImage.width;
					var endY:int = startY + bgImage.height;
					this.graphics.drawTriangles(new <Number>[startX, startY, endX, startY, endX, endY, startX, endY], new <int>[0, 1, 2, 2, 3, 0]);
					this.bgHash[bgLoader.x + "-" + bgLoader.y] = bgLoader;
					Scene.scene.charMove();
					_limitIndex_++;
				}
				_limitIndex_ = 2;
				this.loadImageFunc();
			}
		}

		private function reRender():void
		{
			var pY:int;
			var pX:int;
			var bgLoader:Loader;
			var bgImage:Bitmap;
			var mtx:Matrix;
			var startX:int;
			var startY:int;
			var endX:int;
			var endY:int;
			
			var psize:int = Engine.IMAGE_SZIE;
			var pMin:Point = this.globalToLocal(_stageMinP);
			var pMax:Point = this.globalToLocal(_stageMaxP);
			var startCol:int = Math.floor(pMin.x / psize);
			var startRow:int = Math.floor(pMin.y / psize);
			var endCol:int = Math.ceil(pMax.x / psize);
			var endRow:int = Math.ceil(pMax.y / psize);
			
			var j:int;
			var i:int = startRow;
			while (i <= endRow) {
				j = startCol;
				while (j <= endCol) {
					pY = j * psize;
					pX = i * psize;
					if (i >= 0 && j >= 0) {
						if (_bgHash[j] && _bgHash[j][i]) {
							bgLoader = this.bgHash[pY + "-" + pX];
							if (bgLoader) {
								bgImage = bgLoader.content as Bitmap;
								mtx = new Matrix();
								mtx.tx = bgLoader.x;
								mtx.ty = bgLoader.y;
								this.graphics.beginBitmapFill(bgImage.bitmapData, mtx, false);
								startX = bgLoader.x;
								startY = bgLoader.y;
								endX = startX + bgImage.width;
								endY = startY + bgImage.height;
								this.graphics.drawTriangles(new <Number>[startX, startY, endX, startY, endX, endY, startX, endY], new <int>[0, 1, 2, 2, 3, 0]);
							} else {
								this.drawMini(pY, pX, psize, psize);
							}
						} else {
							this.drawMini(pY, pX, psize, psize);
						}
					}
					j++;
				}
				i++;
			}
		}

		public function clean(sceneId:int=-1):void
		{
			if (this.loader) {
				this.loader.unloadAndStop();
				this.loader = null;
			}
			this.graphics.clear();
			var newHash:Dictionary = new Dictionary();
			var loaderObj:Object;
			var loaderItem:Loader;
			for (var loaderKey:String in this.loadHash) {
				loaderObj = this.loadHash[loaderKey];
				loaderItem = loaderObj.loader;
				if (loaderItem.name.indexOf("scene_" + sceneId) == -1) {
					loaderItem.unloadAndStop();
				} else {
					newHash[loaderKey] = loaderObj;
				}
			}
			this.loadHash = newHash;
			
			newHash = new Dictionary();
			if (this.bgHash) {
				var bgLoader:Loader;
				for (var bgKey:String in this.bgHash) {
					bgLoader = this.bgHash[bgKey];
					if (bgLoader) {
						if (bgLoader.name.indexOf("scene_" + sceneId) == -1) {
							if (bgLoader.content) {
								Bitmap(bgLoader.content).bitmapData.dispose();
							}
							bgLoader.unloadAndStop();
						} else {
							newHash[bgKey] = bgLoader;
						}
					}
				}
			}
			this.bgHash = newHash;
			
			_limitIndex_ = 2;
			this.wealthQuene = [];
		}

		public function unload():void
		{
			_limitIndex_ = 2;
			this.mapData = null;
			this.graphics.clear();
			if (this.loader) {
				this.loader.unloadAndStop();
				this.loader = null;
			}
			if (this.bgHash) {
				for each (var loaderItem:Loader in this.bgHash) {
					if (loaderItem) {
						Bitmap(loaderItem.content).bitmapData.dispose();
						loaderItem.unloadAndStop();
					}
				}
			}
			this.bgHash = new Dictionary();
			if (_bgHash) {
				_bgHash.length = 0;
			} else {
				_bgHash = new Array();
			}
			TileGroup.getInstance().dispose();
			TileGroup.getInstance().initialize();
		}

		private function errorFunc(evt:IOErrorEvent):void
		{
			_limitIndex_++;
			this.loadImageFunc();
			log("saiman", " 加载错误：", evt.target.loader.name);
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
				if (Engine.mini_bitmapData) {
					Engine.mini_bitmapData.dispose();
				}
				Engine.mini_bitmapData = this.bg_bmd.clone();
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
				this.wealthQuene.push({
					"px":px,
					"py":py
				});
			}
			this.loadImageFunc();
		}

		private function drawMini(px:Number, py:Number, pw:Number, ph:Number):void
		{
			if (!this.mapData || !Engine.mini_bitmapData) {
				return;
			}
			
			var miniMap:BitmapData = Engine.mini_bitmapData;
			var sx:Number = this.mapData.pixel_width / miniMap.width;
			var sy:Number = this.mapData.pixel_height / miniMap.height;
			var mtx:Matrix = new Matrix();
			mtx.scale(sx, sy);
			this.graphics.beginBitmapFill(miniMap, mtx, false);
			this.graphics.drawRect(px, py, pw, ph);
		}

		public function loadImageFunc(flag:Boolean=false):void
		{
			if (this.wealthQuene.length <= 0 || _limitIndex_ < 0) {
				return;
			}
			var obj:Object = this.wealthQuene.shift();
			var px:Number = obj.px;
			var py:Number = obj.py;
			var psize:int = Engine.IMAGE_SZIE;
			
			var pMin:Point = this.globalToLocal(_stageMinP);
			var pMid:Point = this.globalToLocal(_stageMaxP);
			var pMax:Point = this.globalToLocal(_stageMidP);
			var startX:int = Math.floor(pMin.x / psize);
			var startY:int = Math.floor(pMin.y / psize);
			var midX:int = Math.round(pMid.x / psize);
			var midY:int = Math.round(pMid.y / psize);
			var endX:int = Math.floor(pMax.x / psize);
			var endY:int = Math.floor(pMax.y / psize);
			
			if (_bgHash == null) {
				_bgHash = [];
			}
			var pathPrefix:String = EngineGlobal.SCENE_IMAGE_DIR + "map_image/" + this.map_id + "/";
			var path:String;
			var bgLoader:Loader;
			var bgContext:LoaderContext;
			
			var tmpIndex:int;
			var tmpLimit:int = 1;
			var bgPt:Point = new Point();
			var bgArea:Rectangle = new Rectangle(0, 0, psize, psize);
			var stageArea:Rectangle = new Rectangle(0, 0, Engine.stage.stageWidth, Engine.stage.stageHeight);
			
			var j:int;
			var i:int = startY;
			while (i <= midY) {
				j = startX;
				while (j <= midX) {
					if (i >= 0 && j >= 0) {
						path = pathPrefix + j + "_" + i + ".jpg?version=" + EngineGlobal.version;
						if (_bgHash[j] == null) {
							_bgHash[j] = [];
						}
						if (_bgHash[j][i] == null || flag) {
							if (tmpIndex <= tmpLimit || flag) {
								bgPt.x = j * psize;
								bgPt.y = i * psize;
								bgPt = this.localToGlobal(bgPt);
								bgArea.x = bgPt.x;
								bgArea.y = bgPt.y;
								if (stageArea.intersects(bgArea)) {
									log("saiman", "加载切片：", path);
									_bgHash[j][i] = path;
									bgLoader = new Loader();
									bgLoader.name = path;
									bgLoader.x = j * psize;
									bgLoader.y = i * psize;
									bgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.loadedFunc);
									bgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.errorFunc);
									_limitIndex_--;
									bgContext = new LoaderContext();
									bgContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
									bgLoader.load(new URLRequest(path), bgContext);
									this.loadHash[j + "_" + i] = {
										"i":i,
										"j":j,
										"loader":bgLoader
									}
									tmpIndex++;
								}
							}
						}
					}
					j++;
				}
				i++;
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
			var _local_1:Rectangle = new Rectangle(0, 0, Engine.stage.stageWidth, Engine.stage.stageHeight);
			var _local_3:Rectangle = new Rectangle(0, 0, 300, 300);Engine.IMAGE_SZIE
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
