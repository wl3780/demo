package com.engine.core.view.quadTree
{
	import com.engine.core.Core;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	import com.engine.utils.Hash;
	
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
		
		public function build(scope:Rectangle, _arg_2:int=50, subNodes:Vector.<INoder>=null):void
		{
			NodeTreePool.getInstance().put(this);
			_scopeRect = scope;
			_hash = new Hash();
			if (scope.width > scope.height) {
				_rulerValue = scope.width;
			} else {
				_rulerValue = scope.height;
			}
			_depth = NodeTree.takeDepth(_rulerValue, _arg_2);
			var _local_4:int = Math.round(Math.pow(2, _depth));
			scope.width = Math.round(scope.width / _local_4) * _local_4;
			scope.height = Math.round(scope.height / _local_4) * _local_4;
			NodeTree.minSize = (_rulerValue / _local_4);
			NodeTree.minWidth = scope.width / _local_4;
			NodeTree.minHeight = scope.height / _local_4;
			NodeTree.doubleMinWidth = (minWidth * 2);
			NodeTree.doubleMinHeight = (minHeight * 2);
			
			_topNode = new Node();
			if (subNodes) {
				var idx:int = 0;
				var len:int = subNodes.length;
				while (idx < len) {
					subNodes[idx].coder::_tid = this.id;
					_topNode.addChild(subNodes[idx].node.id, subNodes[idx]);
					idx++;
				}
			}
			_topNode.setUp(this.id, null, scope, _depth);
			_topNode.coder::id = int(scope.x + scope.width / 2) + Core.SIGN + int(scope.y + scope.height / 2);
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

		public function find(rect:Rectangle, exact:Boolean=false, definition:Number=20):Array
		{
			if (this.initialized) {
				var dict:Dictionary = new Dictionary();
				var ret:Array = [];
				if (definition <= minSize) {
					definition = minSize;
				}
				var tmpDepth:int = NodeTree.takeDepth(_rulerValue, definition);
				this.cycleFind(ret, dict, _topNode, rect, (_depth - tmpDepth + 1), exact);
				return ret;
			}
			return null;
		}

		private function cycleFind(arr:Array, dict:Dictionary, node:Node, rect:Rectangle, level:int, exact:Boolean):void
		{
			if (node) {
				if (rect.intersects(node.rect) && node.length > 0) {
					if (node.coder::_depth_ == level) {
						var tmpDict:Dictionary = node.dic;
						for each (var tmpNode:INoder in tmpDict) {
							if (tmpNode.visible) {
								if (exact) {
									if (rect.intersects(tmpNode.getBounds(Object(tmpNode).parent))) {
										if (dict[tmpNode.id] == null) {
											dict[tmpNode.id] = tmpNode;
											arr.push(tmpNode);
										}
									}
								} else {
									if (dict[tmpNode.id] == null) {
										dict[tmpNode.id] = tmpNode;
										arr.push(tmpNode);
									}
								}
							}
						}
					} else {
						if (node.nodeA) {
							this.cycleFind(arr, dict, node.nodeA, rect, level, exact);
						}
						if (node.nodeB) {
							this.cycleFind(arr, dict, node.nodeB, rect, level, exact);
						}
						if (node.nodeC) {
							this.cycleFind(arr, dict, node.nodeC, rect, level, exact);
						}
						if (node.nodeD) {
							this.cycleFind(arr, dict, node.nodeD, rect, level, exact);
						}
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
