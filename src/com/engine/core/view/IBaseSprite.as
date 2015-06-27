package com.engine.core.view
{
	import com.engine.core.IOrderDispatcher;
	import com.engine.core.controls.elisor.FrameOrder;

	public interface IBaseSprite extends IOrderDispatcher 
	{

		function _setTimeOut_(_arg_1:int, _arg_2:Function, _arg_3:Array):void;
		function onTimer(_arg_1:int, _arg_2:Function, _arg_3:Array, _arg_4:Function=null):FrameOrder;
		function initialize():void;

	}
}
