﻿package com.engine.core.controls.wealth.loader
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class ProtoURLLoader extends URLLoader
	{
		public var name:String;
		public var url:String;

		public function ProtoURLLoader(request:URLRequest=null)
		{
			super(request);
		}
	}
}
