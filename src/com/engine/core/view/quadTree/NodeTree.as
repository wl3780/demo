package com.engine.core.view.quadTree
{
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	import com.engine.utils.Hash;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class NodeTree extends Proto 
	{

		public static var minSize:int;
		public static var minWidth:int;
		public static var minHeight:int;
		public static var doubleMinWidth:int;
		public static var doubleMinHeight:int;

		public var initialized:Boolean = false;
		
		private var _scopeRect:Rectangle;
		private var _depth:int;
		private var _rulerValue:int;
		private var _topNode:Node;
		private var _hash:Hash;

		public function NodeTree(id:String)
		{
			this.coder::id = id;
		}
		
		public function build(scope:Rectangle, minSize:int=50, subNoders:Vector.<INoder>=null):void
		{
			NodeTreePool.getInstance().put(this);
			_scopeRect = scope;
			_hash = new Hash();
			if (scope.width > scope.height) {
				_rulerValue = scope.width;
			} else {
				_rulerValue = scope.height;
			}
			_depth = NodeTree.takeDepth(_rulerValue, minSize);
			var value:int = Math.round(Math.pow(2, _depth));
			scope.width = Math.round(scope.width / value) * value;
			scope.height = Math.round(scope.height / value) * value;
			NodeTree.minSize = _rulerValue / value;
			NodeTree.minWidth = scope.width / value;
			NodeTree.minHeight = scope.height / value;
			NodeTree.doubleMinWidth = (minWidth * 2);
			NodeTree.doubleMinHeight = (minHeight * 2);
			
			_topNode = new Node();
			if (subNoders) {
				var idx:int = 0;
				var len:int = subNoders.length;
				while (idx < len) {
					subNoders[idx].coder::_tid = this.id;
					_topNode.addChild(subNoders[idx].node.id, subNoders[idx]);
					idx++;
				}
			}
			_topNode.setUp(this.id, null, scope, _depth);
			this.initialized = true;
		}

		public function reset():void
		{
			_topNode.dispose();
			_topNode = null;
		}

		public function get nodes():Hash
		{
			return _hash;
		}

		public function find(area:Rectangle, exact:Boolean=false, definition:Number=20):Array
		{
			if (this.initialized) {
				var dict:Dictionary = new Dictionary();
				var ret:Array = [];
				if (definition <= minSize) {
					definition = minSize;
				}
				var tmpDepth:int = NodeTree.takeDepth(_rulerValue, definition);
				this.cycleFind(ret, dict, _topNode, area, (_depth - tmpDepth + 1), exact);
				return ret;
			}
			return null;
		}

		private function cycleFind(arr:Array, dict:Dictionary, head:Node, area:Rectangle, level:int, exact:Boolean):void
		{
			if (!head) {
				return;
			}
			if (area.intersects(head.rect) && head.length > 0) {
				if (head.coder::_depth_ == level) {
					var noderDict:Dictionary = head.dic;
					for each (var noderItem:INoder in noderDict) {
						if (noderItem.visible) {
							if (exact) {	// 精确查找
								if (area.intersects(noderItem.getBounds(DisplayObject(noderItem).parent))) {
									if (dict[noderItem.id] == null) {
										dict[noderItem.id] = noderItem;
										arr.push(noderItem);
									}
								}
							} else {
								if (dict[noderItem.id] == null) {
									dict[noderItem.id] = noderItem;
									arr.push(noderItem);
								}
							}
						}
					}
				} else {
					if (head.nodeA) {
						this.cycleFind(arr, dict, head.nodeA, area, level, exact);
					}
					if (head.nodeB) {
						this.cycleFind(arr, dict, head.nodeB, area, level, exact);
					}
					if (head.nodeC) {
						this.cycleFind(arr, dict, head.nodeC, area, level, exact);
					}
					if (head.nodeD) {
						this.cycleFind(arr, dict, head.nodeD, area, level, exact);
					}
				}
			}
		}

		private function project():void
		{
		}

		public function addNode(id:String, node:Node):void
		{
			_hash.put(id, node);
		}

		public function removeNode(id:String):void
		{
			_hash.remove(id);
		}

		public function takeNode(id:String):Node
		{
			return _hash.take(id) as Node;
		}

		private static function takeDepth(rulerValue:Number, size:int):Number
		{
			var tmp:Number;
			var dep:int = 1;
			while (true) {
				// 深度即迭代次数
				tmp = Math.round(rulerValue / Math.pow(2, dep));
				if (tmp <= size) {
					return dep;
				}
				dep++;
			}
			return -1; //dead code
		}
		
	}
}
