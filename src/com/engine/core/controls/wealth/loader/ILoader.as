package com.engine.core.controls.wealth.loader
{
	import com.engine.core.model.IProto;
	import com.engine.core.model.wealth.WealthVo;
	
	import flash.system.LoaderContext;

	public interface ILoader extends IProto 
	{

		function unloadAndStop(gc:Boolean=true):void;
		function loadElemt(_arg_1:WealthVo, _arg_2:Function=null, _arg_3:Function=null, _arg_4:Function=null, context:LoaderContext=null):void;

	}
}
