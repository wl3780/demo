package com.engine.core.controls.wealth
{
	import com.engine.core.Engine;
	import com.engine.core.controls.wealth.loader.BingLoader;
	import com.engine.core.controls.wealth.loader.DisplayLoader;
	import com.engine.core.model.wealth.WealthVo;
	import com.engine.interfaces.display.ILoader;
	import com.engine.interfaces.system.IWealthQueue;
	import com.engine.namespaces.coder;
	import com.engine.utils.Hash;
	
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.utils.Dictionary;

	public class WealthManager 
	{
		internal static var instanceHash:Hash = new Hash();
		
		private static var _intance:WealthManager;
		private static var _loaderContext:LoaderContext;

		private var wealthSignHash:Dictionary;

		public function WealthManager()
		{
			wealthSignHash = new Dictionary();
			
			if (WealthManager._loaderContext == null) {
				var checkPolicy:Boolean = false;
				if (Security.sandboxType == Security.REMOTE) {
					checkPolicy = true;
				}
				WealthManager._loaderContext = new LoaderContext(checkPolicy, ApplicationDomain.currentDomain);
			}
		}

		public static function getInstance():WealthManager
		{
			if (_intance == null) {
				_intance = new WealthManager();
			}
			return _intance;
		}
		
		public static function getWealthQueue(id:String):IWealthQueue
		{
			return WealthManager.instanceHash.take(id) as IWealthQueue;
		}
		
		public function loadWealth(wealthVo:WealthVo, lc:LoaderContext=null):void
		{
			var url:String = wealthVo.url;
			var owner:String = wealthVo.id;
			var sign:Sign = wealthSignHash[url] as Sign;
			if (sign == null) {
				sign = new Sign();
				sign.url = url;
				wealthSignHash[url] = sign;
			}
			if (sign.wealths.indexOf(owner) == -1) {
				sign.wealths.push(owner);
			}
			
			if (!sign.isLoaded && !sign.isPended) {
				sign.lc = lc;
				sign.isPended = true;
				sign.wealth_id = owner;
				var loader:ILoader = null;
				if (wealthVo.type == WealthConst.BING_WEALTH || wealthVo.dataFormat == URLLoaderDataFormat.BINARY) {
					loader = new BingLoader();
					URLLoader(loader).dataFormat = wealthVo.dataFormat;
					loader.loadElemt(url, _callSuccess_, _callError_, _callProgress_, lc ? lc : WealthManager._loaderContext);
				} else if (wealthVo.type == WealthConst.SWF_WEALTH || wealthVo.type == WealthConst.IMG_WEALTH) {
					loader = new DisplayLoader();
					loader.loadElemt(url, _callSuccess_, _callError_, _callProgress_, lc ? lc : WealthManager._loaderContext);
				}
				this.updateWealthState(sign.wealths, "isPended", sign.isPended);
			} else if (!sign.isLoaded && sign.isPended) {
				this.updateWealthState(sign.wealths, "isPended", sign.isPended);
			} else if (sign.isLoaded) {
				this.updateWealthState(sign.wealths, "isLoaded", sign.isLoaded);
			}
		}
		
		private function updateWealthState(wealths:Vector.<String>, prop:String, value:Boolean):void
		{
			var wealthVo:WealthVo = null;
			var wealthQueue:Object = null;
			for each (var wealth_id:String in wealths) {
				wealthVo = WealthVo.takeWealthVo(wealth_id);
				if (wealthVo) {
					wealthQueue = WealthManager.getWealthQueue(wealthVo.wid);
					if (wealthQueue) {
						
						if ("isPended" == prop) {
							wealthVo.coder::isPended = value;
							wealthQueue.setStateLimitIndex();	// 减少并发线程
						} else if ("isLoaded" == prop) {
							wealthVo.coder::isLoaded = value;
							if (wealthVo.isLoaded) {
								wealthQueue._callSuccess_(wealthVo.id);
							}
						}
					}
				}
			}
		}

		protected function _callSuccess_(path:String):void
		{
			var sign:Sign = wealthSignHash[path] as Sign;
			if (sign) {
				sign.isLoaded = true;
				this.update(sign, 1);
			}
		}
		
		protected function _callError_(path:String):void
		{
			var sign:Sign = wealthSignHash[path] as Sign;
			if (sign) {
				var wealthData:WealthVo = WealthVo.takeWealthVo(sign.wealth_id);
				if (wealthData && sign.tryNum > 0) {
					WealthPool.disposeLoaderByWealth(sign.url);	// 关闭Loader重新加载
					sign.tryNum--;
					sign.isPended = false;
					this.loadWealth(wealthData, sign.lc);
				} else {
					sign.isLoaded = true;
					this.update(sign, 0);
				}
			}
		}
		
		protected function _callProgress_(path:String, bytesLoaded:Number, bytesTotal:Number):void
		{
			var sign:Sign = wealthSignHash[path] as Sign;
			if (sign) {
				sign.isPended = true;
				this.update(sign, 2, bytesLoaded, bytesTotal);
			}
		}
		
		private function update(sign:Sign, state:int, bytesLoaded:Number=0, bytesTotal:Number=0):void
		{
			var wealthData:WealthVo = null;
			var wealthQueue:Object = null;
			if (state == 0 || state == 1) {
				while (sign.wealths.length) {
					wealthData = WealthVo.takeWealthVo( sign.wealths.shift() );
					if (wealthData && wealthData.isLoaded == false && Engine.enabled) {
						wealthQueue = WealthManager.getWealthQueue(wealthData.wid);
						if (wealthQueue) {
							if (state == 0) {
								wealthQueue._callError_(wealthData.id);
							} else if (state == 1) {
								wealthQueue._callSuccess_(wealthData.id);
							}
						}
					}
				}
			} else {
				for each (var wealthId:String in sign.wealths) {
					wealthData = WealthVo.takeWealthVo(wealthId);
					if (wealthData) {
						wealthQueue = WealthManager.getWealthQueue(wealthData.wid);
						if (wealthQueue && wealthQueue.name != WealthConst.AVATAR_REQUEST_WEALTH) {
							wealthQueue._callProgress_(wealthData.id, bytesLoaded, bytesTotal);
						}
					}
				}
			}
		}

		public function cancelWealth(wealth_id:String):void
		{
			var wealthVo:WealthVo = WealthVo.takeWealthVo(wealth_id);
			if (wealthVo) {
				var url:String = wealthVo.url;
				var sign:Sign = wealthSignHash[url] as Sign;
				if (sign) {
					var index:int = sign.wealths.indexOf(wealth_id);
					if (index != -1) {
						sign.wealths.splice(index, 1);
						if (sign.isPended && !sign.isLoaded && sign.wealths.length == 0) {
							WealthPool.disposeLoaderByWealth(url);	// 关闭Loader
						}
					}
				}
			}
		}

	}
}

import com.engine.core.model.Proto;

import flash.system.LoaderContext;

class Sign extends Proto
{
	public var url:String;
	public var tryNum:int = 1;
	/**
	 * 下载WealthData的id集合
	 */	
	public var wealths:Vector.<String>;
	public var isPended:Boolean;
	public var isLoaded:Boolean;
	/**
	 * 下载标示
	 */	
	public var wealth_id:String;
	public var lc:LoaderContext;
	
	public function Sign()
	{
		super();
		wealths = new Vector.<String>();
	}
	
	override public function dispose():void
	{
		super.dispose();
		lc = null;
		url = null;
		wealths = null;
		wealth_id = null;
	}
}
