package com.engine.core.view.quadTree
{
	import com.engine.core.Core;
	import com.engine.core.model.Proto;
	import com.engine.namespaces.coder;
	import com.engine.utils.Hash;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	use namespace coder;

	public class Node extends Proto 
	{

		coder var _tid_:String;
		coder var _depth_:int;
		coder var _rect:Rectangle;
		
		private var _nodeA:Node;
		private var _nodeB:Node;
		private var _nodeC:Node;
		private var _nodeD:Node;
		private var _nodes:Dictionary;
		private var _length:int;
		private var _tree:NodeTree;

		public function Node()
		{
			_nodes = new Dictionary();
		}

		public function get rect():Rectangle
		{
			return this.coder::_rect;
		}

		public function setUp(tid:String, oid:String, area:Rectangle, depth:int):void
		{
			this.coder::_depth_ = depth;
			this.coder::_tid_ = tid;
			this.coder::_rect = area;
			
			var nextDepth:int = depth - 1;
			var nextRect:Rectangle;
			var rectX:int = area.x;
			var rectY:int = area.y;
			var rectW:Number = area.width;
			var rectH:Number = area.height;
			var rectHW:int = rectW / 2;
			var rectHH:int = rectH / 2;
			
			_id = (rectX + rectHW) + Core.SIGN + (rectY + rectHH);
			_oid = oid;
			_tree = NodeTreePool.getInstance().take(tid) as NodeTree;
			_tree.addNode(_id, this);
			if (nextDepth > 0) {
				if (_nodeA == null) {
					_nodeA = new Node();
					nextRect = new Rectangle(rectX, rectY, rectHW, rectHH);
					_nodeA.setUp(tid, _id, nextRect, nextDepth);
				}
				if (_nodeB == null) {
					_nodeB = new Node();
					nextRect = new Rectangle(rectX, (rectY + rectHH), rectHW, rectHH);
					_nodeB.setUp(tid, _id, nextRect, nextDepth);
				}
				if (_nodeC == null) {
					_nodeC = new Node();
					nextRect = new Rectangle((rectX + rectHW), rectY, rectHW, rectHH);
					_nodeC.setUp(tid, _id, nextRect, nextDepth);
				}
				if (_nodeD == null) {
					_nodeD = new Node();
					nextRect = new Rectangle((rectX + rectHW), (rectY + rectHH), rectHW, rectHH);
					_nodeD.setUp(tid, _id, nextRect, nextDepth);
				}
				this.project();
			}
		}

		private function project():void
		{
			if (this.coder::_depth_ > 0) {
				var subNode:INoder;
				for each (subNode in _nodes) {
					if (_nodeA.coder::_rect.contains(subNode.x, subNode.y)) {
						_nodeA.addChild(subNode.id, subNode);
					} else if (_nodeB.coder::_rect.contains(subNode.x, subNode.y)) {
						_nodeB.addChild(subNode.id, subNode);
					} else if (_nodeC.coder::_rect.contains(subNode.x, subNode.y)) {
						_nodeC.addChild(subNode.id, subNode);
					} else if (_nodeD.coder::_rect.contains(subNode.x, subNode.y)) {
						_nodeD.addChild(subNode.id, subNode);
					}
				}
			}
		}

		public function reFree():void
		{
			if (this.coder::_depth_ > 0) {
				_nodes = new Dictionary();
				if (_nodeA) {
					_nodeA.reFree();
				}
				if (_nodeB) {
					_nodeB.reFree();
				}
				if (_nodeC) {
					_nodeC.reFree();
				}
				if (_nodeD) {
					_nodeD.reFree();
				}
			}
		}

		override public function dispose():void
		{
			_nodes = null;
			_tree = null;
			super.dispose();
		}

		public function treeNodes():Hash
		{
			return _tree.nodes;
		}

		public function get parent():Node
		{
			if (this.oid == null) {
				return null;
			}
			return _tree.nodes.take(this.oid) as Node;
		}

		public function get nodeA():Node
		{
			return _nodeA;
		}

		public function get nodeB():Node
		{
			return _nodeB;
		}

		public function get nodeC():Node
		{
			return _nodeC;
		}

		public function get nodeD():Node
		{
			return _nodeD;
		}

		public function get length():int
		{
			return _length;
		}

		public function get dic():Dictionary
		{
			return _nodes;
		}

		public function addChild(id:String, node:INoder):void
		{
			if (_nodes[id] == null) {
				_nodes[id] = node;
				_length++;
			}
		}

		public function removeChild(id:String):void
		{
			if (_nodes[id]) {
				delete _nodes[id];
				_length--;
			}
		}

		public function drawBound(pen:Graphics, area:Rectangle, color:uint, alpha:Boolean=false):void
		{
			if (area && pen) {
				pen.lineStyle(1, color);
				if (alpha) {
					pen.beginFill(0, 0.2);
				}
				pen.drawRect(area.topLeft.x, area.topLeft.y, area.width, area.height);
			}
		}

	}
}
