package com.engine.core.view.quadTree
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	public interface INoder 
	{

		function set x(val:Number):void;
		function get x():Number;
		
		function set y(val:Number):void;
		function get y():Number;
		
		function get id():String;
		
		function get tid():String;
		
		function get visible():Boolean;
		
		function get isActivate():Boolean;
		
		function get node():Node;
		
		function activate():void;
		
		function unactivate():void;
		
		function getBounds(targetCoordinateSpace:DisplayObject):Rectangle;

	}
}
