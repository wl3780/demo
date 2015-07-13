package com.engine.core.controls.wealth.loader
{
	import com.engine.core.model.IProto;
	import com.engine.core.model.wealth.WealthVo;
	
	import flash.system.LoaderContext;

	public interface ILoader extends IProto 
	{

		function unloadAndStop(gc:Boolean=true):void;
		
		function loadElemt(wealthVo:WealthVo, successFunc:Function=null, errorFunc:Function=null, progressFunc:Function=null, context:LoaderContext=null):void;

	}
}
