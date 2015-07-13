package com.engine.core.view.items.avatar
{
	import com.engine.core.Engine;
	import com.engine.core.view.scenes.Scene;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class ShoadwShape extends Sprite 
	{

		private static var recovery_point:Point = new Point();

		public var owner:Avatar;
		public var moveFunc:Function;

		public function ShoadwShape()
		{
			this.mouseChildren = this.mouseEnabled = false;
		}

		override public function set x(val:Number):void
		{
			super.x = val;
			if (val != 0) {
				if (this.moveFunc != null) {
					this.moveFunc();
				}
				if (!this.owner) {
					this.dispose();
				}
			}
			this.stageIntersects();
		}

		override public function set y(val:Number):void
		{
			super.y = val;
			if (val != 0) {
				if (this.moveFunc != null) {
					this.moveFunc();
				}
				if (!this.owner) {
					this.dispose();
				}
			}
			this.stageIntersects();
		}

		public function stageIntersects():void
		{
			if (!Engine.CORE_RECT || this.visible == false || !this.owner) {
				return;
			}
			var sw:int = Engine.char_shadow.width;
			var sh:int = Engine.char_shadow.height;
			var bounds:Rectangle = this.getBounds(this);
			var pt:Point = ShoadwShape.recovery_point;
			pt.x = bounds.x;
			pt.y = bounds.y;
			pt = this.localToGlobal(pt);
			bounds.x = pt.x;
			bounds.y = pt.y;
			if (!bounds.isEmpty() && Avatar.stageRect && !Avatar.stageRect.intersects(bounds)) {
				if (this.parent) {
					this.parent.removeChild(this);
				}
			} else {
				if (!this.parent) {
					Scene.scene.$itemLayer.addChild(this);
				}
			}
		}

		public function dispose():void
		{
			if (this.parent) {
				this.parent.removeChild(this);
			}
			this.graphics.clear();
			this.moveFunc = null;
			this.owner = null;
		}

	}
}
