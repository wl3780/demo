package com.engine.core.view.items.avatar
{
    import com.engine.core.Core;
    import com.engine.core.model.IProto;
    import com.engine.core.model.Proto;
    import com.engine.namespaces.coder;
    
    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    import flash.net.registerClassAlias;

    public class AvatarParam extends Proto 
    {

        public var timeout:int;
        public var replay:int = -1;
        public var holdOnLastFrame:Boolean = false;
        public var currentFrame:int;
        public var depth:int;
        public var type:String;
        public var link:String;
        public var frames:int;
        public var speed:int;
        public var offset_x:int;
        public var offset_y:int;
        public var txs:Vector.<Object>;
        public var tys:Vector.<Object>;
        public var widths:Vector.<Object>;
        public var heights:Vector.<Object>;
        public var bitmapdatas:Array;
        public var startPlayTime:int = 0;
        public var counter:int;
        public var assetsPath:String;
        public var maxRects:Array;
		
        coder var assets_id:String;
        
		private var _isDisposed:Boolean = false;

        public function AvatarParam()
        {
            registerClassAlias("saiman.save.AvatarParam", AvatarParam);
            this.init();
        }

        public function get isDisposed():Boolean
        {
            return (this._isDisposed);
        }

        public function init():void
        {
            this.txs = new Vector.<Object>();
            this.tys = new Vector.<Object>();
            this.widths = new Vector.<Object>();
            this.heights = new Vector.<Object>();
            this.bitmapdatas = new Array(8);
            this.maxRects = new Array(8);
        }

        override public function clone():IProto
        {
            var _local_3:Array;
            var _local_1:AvatarParam = super.clone() as AvatarParam;
            _local_1.coder::oid = this.oid;
            var _local_2:int;
            while (_local_2 < this.heights.length) {
                _local_3 = this.heights[_local_2].slice();
                _local_1.heights[_local_2] = _local_3;
                _local_3 = this.widths[_local_2].slice();
                _local_1.widths[_local_2] = _local_3;
                _local_3 = this.txs[_local_2].slice();
                _local_1.txs[_local_2] = _local_3;
                _local_3 = this.tys[_local_2].slice();
                _local_1.tys[_local_2] = _local_3;
                _local_2++;
            };
            _local_1.assetsPath = this.assetsPath;
            return (_local_1);
        }

        public function getRect(_arg_1:int, _arg_2:int):Rectangle
        {
            return (new Rectangle((this.txs[_arg_1][_arg_2] + this.offset_x), (this.tys[_arg_1][_arg_2] + this.offset_y), this.widths[_arg_1][_arg_2], this.heights[_arg_1][_arg_2]));
        }

        public function getBitmapData(_arg_1:int, _arg_2:int):BitmapData
        {
            var _local_3:String;
            var _local_4:AvatarAssetManager;
            try {
                _local_3 = ((((this.oid + Core.SIGN) + this.link) + Core.SIGN) + this.bitmapdatas[_arg_1]);
                _local_4 = AvatarAssetManager.getInstance();
                return ((_local_4.bitmapdatas[_local_3][_arg_2] as BitmapData));
            } catch(e:Error) {
            };
            return (null);
        }

        override public function dispose():void
        {
            this.counter = 0;
            coder::assets_id = null;
            this.txs = null;
            this.tys = null;
            this.widths = null;
            this.heights = null;
            this.bitmapdatas = null;
            this.link = null;
            this._isDisposed = true;
            this.maxRects = null;
            this.assetsPath = null;
            this.type = null;
            this.startPlayTime = 0;
            this.speed = 0;
            this.frames = 0;
            super.dispose();
        }

    }
}
