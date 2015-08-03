package com.engine.core.view.world
{
	import com.engine.core.Engine;
	import com.engine.core.EngineGlobal;
	import com.engine.core.RecoverUtils;
	import com.engine.core.controls.wealth.WealthPool;
	import com.engine.core.controls.wealth.loader.BingLoader;
	import com.engine.core.controls.wealth.loader.DisplayLoader;
	import com.engine.core.controls.wealth.loader.ProtoURLLoader;
	import com.engine.core.model.map.SquareMapData;
	import com.engine.core.view.DisplaySprite;
	import com.engine.core.view.scenes.Scene;
	import com.engine.interfaces.display.ITerrain;
	import com.engine.utils.Hash;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class MapLayer extends DisplaySprite implements ITerrain 
	{

		public var mapData:SquareMapData;
		public var isReady:Boolean = true;
		public var map_id:String;
		
		private var minibytesLoader:ProtoURLLoader;
		private var mapdataLoader:ProtoURLLoader;
		private var miniimageLoader:Loader;
		private var bg_bmd:BitmapData;
		
		private var _context:LoaderContext;
		private var _mapdataHash:Hash = new Hash();
		private var _minibytesHash:Hash = new Hash();
		private var _imgreqHash:Hash = new Hash();
		private var _imgloadHash:Hash = new Hash();
		private var _imgrenderHash:Hash = new Hash();
		private var loaderQueue:Array = [];
		
		private var tar_rect:Rectangle;
		private var tar2_rect:Rectangle;
		private var stage_rect:Rectangle;
		
		private var _stageMinP:Point;
		private var _stageMidP:Point;
		private var _stageMaxP:Point;
		private var _mapMinP:Point;
		private var _mapMidP:Point;
		private var _mapMaxP:Point;
		
		private var _general_limitIndex_:int = 4;	// 最大并发数
		private var _limitIndex_:int = 15;
		
		private var changeSceneTime:int = 0;
		private var loadImageTime:int = 0;

		public function MapLayer()
		{
			super();
			this.mouseChildren = this.mouseEnabled = false;
			this.tabChildren = this.tabEnabled = false;
			
			this.mapData = new SquareMapData();
			
			tar_rect = new Rectangle(0, 0, EngineGlobal.IMAGE_WIDTH, EngineGlobal.IMAGE_HEIGHT);
			tar2_rect = new Rectangle(0, 0, EngineGlobal.IMAGE_WIDTH+200, EngineGlobal.IMAGE_HEIGHT+100);
			stage_rect = new Rectangle(0, 0, Engine.stage.stageWidth, Engine.stage.stageHeight);
			
			_context = new LoaderContext();
			_context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;	// 解码策略
			
			_stageMinP = new Point(0, 0);
			_stageMidP = new Point(Engine.stage.stageWidth/2, Engine.stage.stageHeight/2);
			_stageMaxP = new Point(Engine.stage.stageWidth, Engine.stage.stageHeight);
			
			var timer:Timer = new Timer();
			timer.addEventListener(TimerEvent.TIMER, timerFunc);
			timer.start();
		}

		public function changeScene(map_id:String):void
		{
			if (this.map_id != map_id) {
				this.map_id = map_id;
				this.clean();
				this.loadMapData();
				changeSceneTime = getTimer();
			}
		}
		
		private function loadMapData():void
		{
			this.isReady = false;
			var path:String = EngineGlobal.getMapConfigPath(this.map_id);
			var bLoader:BingLoader = WealthPool.getInstance().take(path) as BingLoader;	// 游戏预加载
			if (_mapdataHash.has(path) || bLoader) {
				this.isReady = true;
				if (bLoader) {
					this.analyzeMapData(bLoader.data as ByteArray);
				} else {
					this.analyzeMapData(_mapdataHash.take(path).data as ByteArray);
				}
				this.loadMinimapBytes();
				Scene.scene.setupReady();
			} else {
				if (mapdataLoader) {
					try {
						mapdataLoader.removeEventListener(Event.COMPLETE, onMapDataComplete);
						mapdataLoader.removeEventListener(IOErrorEvent.IO_ERROR, onMapDataError);
						mapdataLoader.close();
					} catch(e:Error) {
					}
				}
				mapdataLoader = new ProtoURLLoader();
				mapdataLoader.name = path;
				mapdataLoader.dataFormat = URLLoaderDataFormat.BINARY;
				mapdataLoader.addEventListener(Event.COMPLETE, onMapDataComplete);
				mapdataLoader.addEventListener(IOErrorEvent.IO_ERROR, onMapDataError);
				mapdataLoader.load(new URLRequest(path));
			}
		}
		private function onMapDataComplete(evt:Event):void
		{
			this.isReady = true;
			_mapdataHash.put(mapdataLoader.name, mapdataLoader);
			this.analyzeMapData(mapdataLoader.data as ByteArray);
			this.loadMinimapBytes();
			Scene.scene.setupReady();
			mapdataLoader = null;
		}
		private function onMapDataError(evt:IOErrorEvent):void
		{
			log("-----------------加载地图配置失败-----------------");
			_mapdataHash.remove(mapdataLoader.name);
			this.loadMapData();
		}
		
		private function loadMinimapBytes():void
		{
			var path:String = EngineGlobal.getMapMiniPath(this.map_id);
			var disLoader:DisplayLoader = WealthPool.getInstance().take(path) as DisplayLoader;	// 游戏预加载
			if (disLoader != null) {
				this.onMinimapImageComplete(null, disLoader);
			} else {
				if (minibytesLoader) {
					try {
						minibytesLoader.removeEventListener(Event.COMPLETE, onMinimapBytesComplete);
						minibytesLoader.removeEventListener(IOErrorEvent.IO_ERROR, onMinimapBytesError);
						minibytesLoader.close();
					} catch (e:Error) {
					}
				}
				if (_minibytesHash.has(path) == false) {
					minibytesLoader = new ProtoURLLoader();
					minibytesLoader.name = path;
					minibytesLoader.dataFormat = URLLoaderDataFormat.BINARY;
					minibytesLoader.addEventListener(Event.COMPLETE, onMinimapBytesComplete);
					minibytesLoader.addEventListener(IOErrorEvent.IO_ERROR, onMinimapBytesError);
					minibytesLoader.load(new URLRequest(path));
				} else {
					var proLoader:ProtoURLLoader = _minibytesHash.take(path) as ProtoURLLoader;
					this.loadMinimapImage(proLoader.data, path);
				}
			}
		}
		private function onMinimapBytesComplete(evt:Event):void
		{
			minibytesLoader.removeEventListener(Event.COMPLETE, onMinimapBytesComplete);
			minibytesLoader.removeEventListener(IOErrorEvent.IO_ERROR, onMinimapBytesError);
			_minibytesHash.put(minibytesLoader.name, minibytesLoader, true);
			this.loadMinimapImage(minibytesLoader.data, minibytesLoader.name);
			minibytesLoader = null;
		}
		private function onMinimapBytesError(evt:Event):void
		{
			log("-----------------加载小地图二进制失败-----------------");
			this.loadMinimapBytes();
		}
		
		private function loadMinimapImage(bytes:ByteArray, path:String):void
		{
			if (miniimageLoader) {
				miniimageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onMinimapImageComplete);
				miniimageLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onMinimapImageError);
				miniimageLoader.unloadAndStop();
			}
			miniimageLoader = new Loader();
			miniimageLoader.name = path;
			miniimageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onMinimapImageComplete);
			miniimageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onMinimapImageError);
			miniimageLoader.loadBytes(bytes);
		}
		private function onMinimapImageComplete(evt:Event, loaderx:Loader=null):void
		{
			if (bg_bmd) {
				bg_bmd.dispose();
			}
			if (loaderx) {
				bg_bmd = (loaderx.content as Bitmap).bitmapData.clone();
			} else {
				bg_bmd = (evt.target.loader.content as Bitmap).bitmapData.clone();
			}
			Scene.scene.miniMapReady(bg_bmd);	// 其它地方需要使用
			var bmd:BitmapData = new BitmapData(bg_bmd.width, bg_bmd.height, true, 0);
			bmd.applyFilter(bg_bmd, bg_bmd.rect, new Point(), new BlurFilter(10, 10, 1));
			bg_bmd = bmd;
			if (bg_bmd) {
				var sw:Number = this.mapData.pixel_width / bg_bmd.width;
				var sh:Number = this.mapData.pixel_height / bg_bmd.height;
				var mat:Matrix = new Matrix();
				mat.scale(sw, sh);
				this.graphics.clear();
				this.graphics.beginBitmapFill(bg_bmd, mat, false);
				this.graphics.drawRect(0, 0, this.mapData.pixel_width, this.mapData.pixel_height);
			}
			
			if (miniimageLoader) {
				try {
					miniimageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onMinimapImageComplete);
					miniimageLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onMinimapImageError);
					miniimageLoader.unloadAndStop();
				} catch (e:Error) {
				}
				miniimageLoader = null;
			}
		}
		private function onMinimapImageError(evt:Event, loader:Loader=null):void
		{
			log("-----------------加载小地图失败-----------------");
			this.loadMinimapBytes();
		}
		
		private function timerFunc(evt:TimerEvent):void
		{
			if (this.isReady == false) {
				return;
			}
			_stageMinP.x = Engine.stage.stageWidth/2;
			_stageMinP.y = Engine.stage.stageHeight/2;
			_stageMaxP.x = Engine.stage.stageWidth;
			_stageMaxP.y = Engine.stage.stageHeight;
			
			_mapMinP = this.globalToLocal(_stageMinP);
			_mapMidP = this.globalToLocal(_stageMidP);
			_mapMaxP = this.globalToLocal(_stageMaxP);
			
			stage_rect.setTo(_mapMinP.x, _mapMinP.y, Engine.stage.stageWidth, Engine.stage.stageHeight);
			
			this.checkNeedLoadImage();
			this.loopLoadImage();
			this.renderIntersects();
		}
		
		private function checkNeedLoadImage():void
		{
			var start_x:int = _mapMinP.x / EngineGlobal.IMAGE_WIDTH;
			var end_x:int = _mapMaxP.x / EngineGlobal.IMAGE_WIDTH;
			var start_y:int = _mapMinP.y / EngineGlobal.IMAGE_HEIGHT;
			var end_y:int = _mapMaxP.y / EngineGlobal.IMAGE_HEIGHT;
			var col:int = start_x;
			var row:int;
			while (col <= end_x) {
				row = start_y;
				while (row <= end_y) {
					this.addNeedLoadImage(col, row);
					row++;
				}
				col++;
			}
		}
		
		private function addNeedLoadImage(index_x:int, index_y:int):void
		{
			if (index_x < 0 || index_y < 0) {
				return;
			}
			var path:String = EngineGlobal.getMapImagePath(this.map_id, index_x, index_y);
			if (_imgloadHash.has(path) == true) {
				return;
			}
			tar_rect.x = index_x * EngineGlobal.IMAGE_WIDTH;
			tar_rect.y = index_y * EngineGlobal.IMAGE_HEIGHT;
			if (stage_rect.intersects(tar_rect)) {
				var key:String = index_x + Engine.LINE + index_y;
				if (_imgreqHash.has(key) == false) {
					_imgreqHash.push(key, {
						map_id:this.map_id,
						key:key,
						dis:0,
						index_x:index_x,
						index_y:index_y
					});
				}
			}
		}
		
		private function loopLoadImage():void
		{
			if (_imgreqHash.length == 0) {
				return;
			}
			var time:int = 20;
			if ((getTimer() - changeSceneTime) < 8000) {
				time = 0;
			}
			if ((getTimer() - loadImageTime) < time) {
				return;
			}
			var idx:int = 0;
			while (idx < _general_limitIndex_) {
				if (_imgreqHash.length && _limitIndex_ > 0) {
					var data:Object = this.getNear();
					tar2_rect.x = data.index_x * EngineGlobal.IMAGE_WIDTH - 150;
					tar2_rect.y = data.index_y * EngineGlobal.IMAGE_HEIGHT - 50;
					if (stage_rect.intersects(tar2_rect)) {
						_imgreqHash.remove(data.key);
						this.loadImage(data.index_x, data.index_y);
					}
				}
				idx++;
			}
		}
		
		private function getNear():Object
		{
			var keyObj:Object = null;
			var tX:int = _mapMidP.x / EngineGlobal.IMAGE_WIDTH;
			var tY:int = _mapMidP.y / EngineGlobal.IMAGE_HEIGHT;
			var arr:Array = [];
			for each (var item:Object in _imgreqHash) {
				var dX:int = item.index_x;
				var dY:int = item.index_y;
				item.dis = Math.abs(dX - tX) + Math.abs(dY - tY);
				if (keyObj == null || keyObj.dis > item.dis) {
					keyObj = item;
				}
			}
			return keyObj;
		}
		
		private function loadImage(index_x:int, index_y:int):void
		{
			var path:String = EngineGlobal.getMapImagePath(this.map_id, index_x, index_y);
			if (_imgloadHash.has(path) == false && _limitIndex_ > 0) {
				var tmpLoader:Loader = null;
				if (loaderQueue.length) {
					tmpLoader = loaderQueue.pop();
				} else {
					tmpLoader = new Loader();
				}
				tmpLoader.name = path;
				tmpLoader.x = index_x * EngineGlobal.IMAGE_WIDTH;
				tmpLoader.y = index_y * EngineGlobal.IMAGE_HEIGHT;
				tmpLoader.load(new URLRequest(path), _context);
				tmpLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadedFunc);
				tmpLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrorFunc);
				_imgloadHash.put(path, tmpLoader);
				_limitIndex_ --;
			}
		}
		
		private function onLoadedFunc(evt:Event):void
		{
			var tmpLoader:Loader = evt.target.loader as Loader;
			tmpLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadedFunc);
			tmpLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onErrorFunc);
			if (_limitIndex_ < _general_limitIndex_) {
				_limitIndex_ ++;
			}
		}
		private function onErrorFunc(evt:IOErrorEvent):void
		{
			var tmpLoader:Loader = evt.target.loader as Loader;
			tmpLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadedFunc);
			tmpLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onErrorFunc);
			_imgloadHash.remove(tmpLoader.name);
			if (_limitIndex_ < _general_limitIndex_) {
				_limitIndex_ ++;
			}
		}
		
		private function renderIntersects():void
		{
			if (_imgloadHash.length == 0) {
				return;
			}
			var start_x:int = _mapMinP.x / EngineGlobal.IMAGE_WIDTH;
			var end_x:int = _mapMaxP.x / EngineGlobal.IMAGE_WIDTH;
			var start_y:int = _mapMinP.y / EngineGlobal.IMAGE_HEIGHT;
			var end_y:int = _mapMaxP.y / EngineGlobal.IMAGE_HEIGHT;
			var col:int = start_x;
			var row:int;
			while (col <= end_x) {
				row = start_y;
				while (row <= end_y) {
					this.onRenderLoadedImage(col, row);
					row++;
				}
				col++;
			}
		}
		
		private function onRenderLoadedImage(index_x:int, index_y:int):void
		{
			var path:String = EngineGlobal.getMapImagePath(this.map_id, index_x, index_y);
			if (_imgrenderHash.has(path) == false) {
				tar_rect.x = index_x * EngineGlobal.IMAGE_WIDTH;
				tar_rect.y = index_y * EngineGlobal.IMAGE_HEIGHT;
				if (stage_rect.intersects(tar_rect)) {
					if (_imgloadHash.has(path) == true) {
						var image:Bitmap = null;
						var tmpLoader:Loader = _imgloadHash.take(path) as Loader;
						if (tmpLoader) {
							image = tmpLoader.content as Bitmap;
						}
						if (image && image.bitmapData) {
							_imgrenderHash.put(path, path);
							this.draw(tar_rect.x, tar_rect.y, image.bitmapData);
						}
					}
				}
			}
		}
		
		private function draw(x:int, y:int, bitmapData:BitmapData):void
		{
			var mat:Matrix = RecoverUtils.matrix;
			mat.tx = x;
			mat.ty = y;
			var w:int = x + bitmapData.width;
			var h:int = y + bitmapData.height;
			this.graphics.beginBitmapFill(bitmapData, mat, false);
			this.graphics.drawTriangles(new <Number>[x,y,w,y,w,h,x,h], new <int>[0,1,2,2,3,0]);
		}

		public function clean():void
		{
			this.graphics.clear();
			if (miniimageLoader) {
				miniimageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onMinimapImageComplete);
				miniimageLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onMinimapImageError);
				miniimageLoader = null;
			}
			for each (var tmpLoader:Loader in _imgloadHash) {
				tmpLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadedFunc);
				tmpLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onErrorFunc);
				tmpLoader.unloadAndStop();
				loaderQueue.push(tmpLoader);
			}
			
			var stageIndexW:int = Math.ceil(Engine.stage.stageWidth / EngineGlobal.IMAGE_WIDTH);
			var stageIndexH:int = Math.ceil(Engine.stage.stageHeight / EngineGlobal.IMAGE_HEIGHT);
			_limitIndex_ = stageIndexW * stageIndexH;
			_limitIndex_ = _limitIndex_ > 15 ? 15 : _limitIndex_;
			_limitIndex_ = _limitIndex_ < _general_limitIndex_ ? _general_limitIndex_ : _limitIndex_;
			
			var idx:int = loaderQueue.length;
			while (idx < _limitIndex_) {
				loaderQueue.push(new Loader());
			}
			
			_imgreqHash.reset();
			_imgloadHash.reset();
			_imgrenderHash.reset();
		}

		private function analyzeMapData(bytes:ByteArray):void
		{
			this.mapData.uncode(bytes);
		}

	}
}
