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
    import flash.display.Stage;
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

    use namespace coder;

    public class MapLayer extends Sprite 
    {

        public var mapData:SquareMapData;
        public var inited:Boolean = true;
		
        coder var hostPath:String;
		
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

        private function resizeFunc(_arg_1:Event):void
        {
            if (((((this.stage) && (Scene.scene))) && (Scene.scene.mainChar))){
                this.loadImage(Scene.scene.mainChar.x, Scene.scene.mainChar.y);
            };
        }

        private function getMapPath(_arg_1:String, _arg_2:String=null):String
        {
            var _local_3:String = (((((Core.hostPath + Core.mapPath) + "map_data/") + _arg_1) + ".data?version=") + Core.version);
            if (_arg_2 != null){
                _local_3 = (((((_arg_2 + Core.mapPath) + "map_data/") + _arg_1) + ".data?version=") + Core.version);
            };
            return (_local_3.replace("$language$", Core.language));
        }

        public function init(_arg_1:String):void
        {
            var _local_2:String;
            if (this.maps != null){
                this.maps = null;
            };
            this.maps = new Dictionary();
            this.map_id = _arg_1;
            if (this.bg_bmd){
                this.bg_bmd.dispose();
            };
            this.bg_bmd = null;
            if (coder::hostPath != null){
                _local_2 = this.getMapPath(_arg_1, coder::hostPath);
            } else {
                _local_2 = this.getMapPath(_arg_1);
            };
            if (this.loader){
                this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.miniMapLoadedFunc);
                this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.errorFunc);
            };
            if (this.loader_){
                try {
                    this.loader_.removeEventListener(Event.COMPLETE, this.loadedDataFunc);
                    this.loader_.removeEventListener(IOErrorEvent.IO_ERROR, this.loadedDataErrorFunc);
                    this.loader_.close();
                } catch(e:Error) {
                };
            };
            this.loader_ = new URLLoader();
            this.loader_.dataFormat = URLLoaderDataFormat.BINARY;
            this.scene_data_path = _local_2;
            this.loader_.load(new URLRequest(_local_2));
            this.loader_.addEventListener(Event.COMPLETE, this.loadedDataFunc);
            this.loader_.addEventListener(IOErrorEvent.IO_ERROR, this.loadedDataErrorFunc);
            Core.stage.addEventListener(Event.RESIZE, this.resizeFunc);
            log("saiman", "加载地图数据文件---------------");
        }

        private function loadedDataErrorFunc(_arg_1:*):void
        {
            if (this.scene_data_path){
                if (this.loader_){
                    try {
                        this.loader_.removeEventListener(Event.COMPLETE, this.loadedDataFunc);
                        this.loader_.removeEventListener(IOErrorEvent.IO_ERROR, this.loadedDataErrorFunc);
                        this.loader_.close();
                    } catch(e:Error) {
                    };
                };
                this.loader_ = new URLLoader();
                this.loader_.dataFormat = URLLoaderDataFormat.BINARY;
                this.loader_.load(new URLRequest(this.scene_data_path));
                this.loader_.addEventListener(Event.COMPLETE, this.loadedDataFunc);
                this.loader_.addEventListener(IOErrorEvent.IO_ERROR, this.loadedDataErrorFunc);
            };
        }

        private function loadedFunc(_arg_1:Event):void
        {
            var _local_2:Loader = (_arg_1.target.loader as Loader);
            _local_2.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.loadedFunc);
            _local_2.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.errorFunc);
            setTimeout(this.render, (50 + ((Math.random() * 50) >> 0)), _arg_1);
            var _local_3:Boolean = Scene.scene.changing;
            if (_local_3){
                this._limitIndex_++;
                return;
            };
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
            if (_local_3){
                log("saiman", "加载完成：", _local_2.name);
                if (((_local_3.bitmapData) && ((this.bgHash[((_local_2.x + "-") + _local_2.y)] == null)))){
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
                    this._limitIndex_++;
                };
                this._limitIndex_ = 2;
                this.loadImageFunc();
            };
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
                    if ((((_local_10 >= 0)) && ((_local_11 >= 0)))){
                        if (((this._bgHash[_local_11]) && (this._bgHash[_local_11][_local_10]))){
                            _local_14 = this.bgHash[((_local_12 + "-") + _local_13)];
                            if (_local_14){
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
                            };
                        } else {
                            this.drawMini(_local_12, _local_13, _local_1, _local_1);
                        };
                    };
                    _local_11++;
                };
                _local_10++;
            };
        }

        public function clean(_arg_1:int=-1):void
        {
            var _local_3:String;
            var _local_4:Dictionary;
            var _local_5:Object;
            var _local_6:Loader;
            var _local_7:String;
            var _local_8:Loader;
            if (this.loader){
                this.loader.unloadAndStop();
            };
            this.graphics.clear();
            var _local_2:Dictionary = new Dictionary();
            for (_local_3 in this.loadHash) {
                _local_5 = this.loadHash[_local_3];
                _local_6 = _local_5.loader;
                if (_local_6.name.indexOf(("scene_" + _arg_1)) == -1){
                    _local_6.unloadAndStop();
                } else {
                    _local_2[_local_3] = _local_5;
                };
            };
            this.loadHash = _local_2;
            _local_4 = new Dictionary();
            if (this.bgHash){
                for (_local_7 in this.bgHash) {
                    _local_8 = this.bgHash[_local_7];
                    if (_local_8){
                        if (_local_8.name.indexOf(("scene_" + _arg_1)) == -1){
                            if (_local_8.content){
                                Bitmap(_local_8.content).bitmapData.dispose();
                            };
                            _local_8.unloadAndStop();
                        } else {
                            _local_4[_local_7] = _local_8;
                        };
                    };
                    _local_8 = null;
                };
            };
            this.images = [];
            this.bgHash = _local_4;
            this._limitIndex_ = 2;
            this.wealthQuene = [];
        }

        public function unload():void
        {
            var _local_1:Loader;
            this._limitIndex_ = 2;
            this.mapData = null;
            this.graphics.clear();
            this.mapView = new Array();
            if (this.loader){
                this.loader.unloadAndStop();
            };
            if (this.bgHash){
                for each (_local_1 in this.bgHash) {
                    if (_local_1){
                        Bitmap(_local_1.content).bitmapData.dispose();
                        _local_1.unloadAndStop();
                    };
                    _local_1 = null;
                };
            };
            this.images = [];
            this.bgHash = new Dictionary();
            TileGroup.getInstance().dispose();
            TileGroup.getInstance().initialize();
            this.firstLoad = true;
            if (this._bgHash){
                this._bgHash = null;
            };
            this._bgHash = new Array();
            this.maps = new Dictionary();
            this.graphics.clear();
        }

        private function errorFunc(_arg_1:IOErrorEvent):void
        {
            this._limitIndex_++;
            this.loadImageFunc();
            log("saiman", " 加载错误：", _arg_1.target.loader.name);
        }

        private function loadedDataFunc(_arg_1:Event):void
        {
            var _local_2:String;
            this.scene_data_path = null;
            log("saiman", "地图数据加载完毕！！！-----------------");
            if (coder::hostPath != null){
                _local_2 = (((((coder::hostPath + Core.mapPath) + "map_mini/") + this.map_id) + ".jpg?version=") + Core.version);
            } else {
                _local_2 = (((((Core.hostPath + Core.mapPath) + "map_mini/") + this.map_id) + ".jpg?version=") + Core.version);
            };
            var _local_3:ByteArray = (_arg_1.target.data as ByteArray);
            if (_local_3){
                this.mapData = this.prase(_local_3);
            };
            this.graphics.clear();
            URLLoader(_arg_1.target).close();
            this.loader = new Loader();
            var _local_4:Stage = Core.stage;
            var _local_5:LoaderContext = new LoaderContext();
            _local_5.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
            this.loader.load(new URLRequest(_local_2), _local_5);
            this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.miniMapLoadedFunc);
            this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.errorFunc);
            log("saiman", "加载小地图--------------------");
            Scene.scene.changing = false;
            Scene.scene.setupReady();
            this.loadImage(Scene.scene.mainChar.x, Scene.scene.mainChar.y);
        }

        private function progressFunc(_arg_1:WealthProgressEvent):void
        {
        }

        private function miniMapLoadedFunc(_arg_1:Event):void
        {
            var _local_2:Number;
            var _local_3:Number;
            var _local_4:Matrix;
            log("saiman", "小地图加载完毕--------------------");
            this.graphics.clear();
            this.bg_bmd = BitmapData(_arg_1.target.loader.content.bitmapData).clone();
            this.mapData.width = this.mapData.pixel_width;
            this.mapData.height = this.mapData.pixel_height;
            if (this.loader){
                this.loader.unloadAndStop();
            };
            this.loader = null;
            if (this.bg_bmd){
                _local_2 = (this.mapData.pixel_width / this.bg_bmd.width);
                _local_3 = (this.mapData.pixel_height / this.bg_bmd.height);
                this.graphics.clear();
                _local_4 = new Matrix();
                _local_4.scale(_local_2, _local_3);
                this.graphics.beginBitmapFill(this.bg_bmd, _local_4, false);
                this.graphics.drawRect(0, 0, this.mapData.pixel_width, this.mapData.pixel_height);
            };
            this.reRender();
            if (Core.mini_bitmapData){
                Core.mini_bitmapData.dispose();
            };
            if (this.bg_bmd){
                Core.mini_bitmapData = this.bg_bmd.clone();
            };
            this.inited = true;
            Scene.scene.mapData = this.mapData;
        }

        public function loadImage(_arg_1:Number, _arg_2:Number):void
        {
            var _local_5:Object;
            if ((((((this.mapData == null)) || (Scene.scene.changing))) || ((Scene.scene.isReady == false)))){
                return;
            };
            var _local_3:int;
            var _local_4:int = this.wealthQuene.length;
            var _local_6:Boolean = true;
            while (_local_3 < _local_4) {
                _local_5 = this.wealthQuene[_local_3];
                if (((!((_local_5.px == _arg_1))) && (!((_local_5.py == _arg_2))))){
                    _local_6 = false;
                };
                _local_3++;
            };
            if (_local_6){
                this.wealthQuene.push({
                    "px":_arg_1,
                    "py":_arg_2
                });
            };
            this.loadImageFunc();
        }

        private function drawMini(_arg_1:Number, _arg_2:Number, _arg_3:Number, _arg_4:Number):void
        {
            var _local_8:Matrix;
            if (((!(this.mapData)) || (!(Core.mini_bitmapData)))){
                return;
            };
            var _local_5:BitmapData = Core.mini_bitmapData;
            var _local_6:Number = (this.mapData.pixel_width / _local_5.width);
            var _local_7:Number = (this.mapData.pixel_height / _local_5.height);
            if (_local_5){
                _local_8 = new Matrix();
                _local_8.scale(_local_6, _local_7);
                this.graphics.beginBitmapFill(_local_5, _local_8, false);
                this.graphics.drawRect(_arg_1, _arg_2, _arg_3, _arg_4);
            };
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
            if ((((this.wealthQuene.length <= 0)) || ((this._limitIndex_ < 0)))){
                return;
            };
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
            if ((this._bgHash == null)){
                this._bgHash = [];
            };
            var _local_13:int = _local_6.x;
            var _local_14:int = _local_6.y;
            var _local_15:int = _local_8.x;
            var _local_16:int = _local_8.y;
            if (coder::hostPath != null){
                _local_17 = ((((coder::hostPath + Core.mapPath) + "map_image/") + this.map_id) + "/");
            } else {
                _local_17 = ((((Core.hostPath + Core.mapPath) + "map_image/") + this.map_id) + "/");
            };
            var _local_18:int;
            var _local_19:int = 1;
            var _local_21:Rectangle = new Rectangle(0, 0, _local_5, _local_5);
            var _local_22:Point = new Point();
            var _local_23:Rectangle = new Rectangle(0, 0, Core.stage.stageWidth, Core.stage.stageHeight);
            var _local_24:int = _local_14;
            while (_local_24 <= _local_16) {
                _local_25 = _local_13;
                while (_local_25 <= _local_15) {
                    if ((((_local_24 >= 0)) && ((_local_25 >= 0)))){
                        _local_26 = (((((_local_17 + _local_25) + "_") + _local_24) + ".jpg?version=") + Core.version);
                        if (this._bgHash[_local_25] == null){
                            this._bgHash[_local_25] = [];
                        };
                        if ((((this._bgHash[_local_25][_local_24] == null)) || (_arg_1))){
                            if ((((_local_18 <= _local_19)) || (_arg_1))){
                                _local_22.x = (_local_25 * _local_5);
                                _local_22.y = (_local_24 * _local_5);
                                _local_22 = this.localToGlobal(_local_22);
                                _local_21.x = _local_22.x;
                                _local_21.y = _local_22.y;
                                if (_local_23.intersects(_local_21)){
                                    _local_12.push((((((_local_17 + _local_25) + "_") + _local_24) + ".jpg?version=") + Core.version));
                                    log("saiman", "加载切片：", _local_26);
                                    this._bgHash[_local_25][_local_24] = _local_26;
                                    _local_27 = new Loader();
                                    _local_27.name = _local_26;
                                    _local_27.x = (_local_25 * _local_5);
                                    _local_27.y = (_local_24 * _local_5);
                                    _local_27.contentLoaderInfo.addEventListener(Event.COMPLETE, this.loadedFunc);
                                    _local_27.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.errorFunc);
                                    this._limitIndex_--;
                                    _local_28 = new LoaderContext();
                                    _local_28.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
                                    _local_27.load(new URLRequest(_local_26), _local_28);
                                    this.loadHash[((_local_25 + "_") + _local_24)] = {
                                        "i":_local_24,
                                        "j":_local_25,
                                        "loader":_local_27
                                    };
                                    _local_18++;
                                };
                            };
                        };
                    };
                    _local_25++;
                };
                _local_24++;
            };
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
                if (_local_1.intersects(_local_3) == false){
                    _local_7 = _local_5.i;
                    _local_8 = _local_5.j;
                    _local_2.unloadAndStop();
                    this._bgHash[_local_8][_local_7] = null;
                };
            };
        }

        private function prase(_arg_1:ByteArray):SquareMapData
        {
            var _local_2:SquareMapData = new SquareMapData();
            _local_2.uncode(_arg_1);
            Scene.scene.mapData = _local_2;
            return (_local_2);
        }


    }
}//package com.engine.core.view.world

