package com.engine.utils
{
	import com.engine.core.RecoverUtils;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class HitTest 
	{

		private static var pixel:BitmapData = new BitmapData(1, 1, true, 0);
		private static var pixelRect:Rectangle = new Rectangle(0, 0, 1, 1);
		private static var recovery_point:Point = new Point();

		private static function replacColor(bmd:BitmapData, replaceColor:uint):BitmapData
		{
			var clone:BitmapData = new BitmapData(bmd.width, bmd.height);
			var threshold:int = 0x22000000;
			replaceColor = 0xFFFF0000;
			clone.threshold(bmd, bmd.rect, RecoverUtils.point, ">=", threshold, replaceColor, 4294967295, true);
			return clone;
		}

		public static function getChildUnderPoint(layer:DisplayObjectContainer, point:Point, childs:Array=null, target:Class=null, checkAlpha:int=10):DisplayObject
		{
			var ret:DisplayObject;
			var bounds:Rectangle;
			var bmd:BitmapData;
			var mtx:Matrix;
			var alphaVal:uint;
			if (childs) {
				childs.sortOn("y", Array.NUMERIC);
			}
			if (target == null) {
				target = DisplayObject;
			}
			var _local_7:Array = [];
			var idx:int = childs.length - 1;
			var item:*;
			while (idx >= 0) {
				item = childs[idx];
				if (item as target) {
					bounds = childs[idx].getBounds(layer);
					if (bounds.containsPoint(point)) {
						bmd = new BitmapData(1, 1, true, 0);
						mtx = new Matrix();
						mtx.tx = -int(item.mouseX);
						mtx.ty = -int(item.mouseY);
						bmd.draw(item, mtx, null, null, pixelRect);
						alphaVal = (bmd.getPixel32(0, 0) >> 24) & 0xFF;
						if (alphaVal > checkAlpha) {
							ret = item;
							break;
						}
					}
				}
				idx--;
			}
			return ret;
		}

		public static function getChildUnderPointWithDifferentLayer(parent:DisplayObjectContainer, point:Point, items:Array=null, className:Class=null):DisplayObject{
			if (items == null) {
				return null;
			}
			if (className == null) {
				className = DisplayObject;
			}
			var result:DisplayObject = null;
			var child:DisplayObject = null;
			var infos:Array = [];
			for (var i:int = 0; i < items.length; i++) {
				child = items[i];
				if (child is className) {
					var pIndex:int = child.parent.parent.getChildIndex(child.parent) * 1000000;
					infos.push({
						target:child,
						depth:pIndex + child.y
					});
				}
			}
			infos.sortOn("depth", (Array.NUMERIC | Array.DESCENDING));
			
			var tmpData:BitmapData = null;
			var mtx:Matrix = null;
			for (i = infos.length - 1; i >= 0; i--) {
				child = infos[i].target;
				tmpData = new BitmapData(1, 1, true, 0);
				mtx = new Matrix();
				mtx.tx = -(child.mouseX);
				mtx.ty = -(child.mouseY);
				tmpData.draw(child, mtx, null, null, pixelRect);
				var targetAlpha:int = (tmpData.getPixel32(0, 0) >> 24) & 0xFF;
				if (targetAlpha > 40) {
					result = child;
					break;
				}
			}
			return result;
		}
		
		public static function getChildAtPoint(targetParent:DisplayObjectContainer, point:Point, elements:Array=null):DisplayObject
		{
			if (elements == null) {
				elements = targetParent.getObjectsUnderPoint(point);
			}
			var tmpList:Array = [];
			var bounds:Rectangle = null;
			for each (var item:DisplayObject in elements) {
				bounds = item.getBounds(targetParent);
				if (bounds.containsPoint(point)) {
					tmpList.push(item);
				}
			}
			elements = tmpList;
			
			tmpList = [];
			var index:int = 0;
			var cf:ColorTransform = new ColorTransform();
			// 设置颜色，getPixel时需要使用
			for (index = 0; index < elements.length; index++) {
				cf.color = index;
				tmpList.push(elements[index].transform.colorTransform);
				elements[index].transform.colorTransform = cf;
			}
			
			var mtx:Matrix = new Matrix();
			mtx.tx = -point.x;
			mtx.ty = -point.y;
			var tmpData:BitmapData = new BitmapData(1, 1);
			var orgRect:Rectangle = new Rectangle(0, 0, tmpData.width, tmpData.height);
			tmpData.draw(targetParent, mtx, null, null, orgRect);
			var colorIndex:int = tmpData.getPixel(0, 0);
			// 颜色重置回去
			for (index = 0; index < elements.length; index++) {
				elements[index].transform.colorTransform = tmpList[index];
			}
			return elements[colorIndex];
		}

		private static function setfilter(index:int):ColorMatrixFilter
		{
			var params:Array = [];
			params = params.concat([1, 0, 0, 2, 0]);
			params = params.concat([1, 0, 0, 2, 0]);
			params = params.concat([1, 0, 0, 2, 0]);
			params = params.concat([1, 0, 0, 1, 0]);
			return new ColorMatrixFilter(params);
		}

	}
}
