package com.engine.core.view.quadTree
{
	import com.engine.core.Engine;
	import com.engine.core.view.DisplaySprite;
	import com.engine.interfaces.display.INoderDisplay;
	import com.engine.namespaces.coder;

	public class NoderSprite extends DisplaySprite implements INoderDisplay
	{

		coder var _tid:String;
		
		private var _node:Node;
		private var _tree:NodeTree;
		private var _initialized:Boolean;
		private var _isActivate:Boolean;

		public function NoderSprite()
		{
			super();
			this.mouseChildren = this.mouseEnabled = false;
			this.tabChildren = this.tabEnabled = false;
		}

		public function registerNodeTree(tid:String):void
		{
			this.coder::_tid = tid;
			_tree = NodeTreePool.getInstance().take(tid);
			_initialized = true;
			this.activate();
		}

		override public function set x(val:Number):void
		{
			if (val == super.x) {
				return;
			}
			super.x = Number(val.toFixed(1));
			this.updata(val, super.y, this.nodeKey);
		}

		override public function set y(val:Number):void
		{
			if (val == super.y) {
				return;
			}
			super.y = Number(val.toFixed(1));
			this.updata(super.x, val, this.nodeKey);
		}

		public function updata(tx:Number, ty:Number, tKey:String):void
		{
			if (_isActivate == false) {
				return;
			}
			if (_initialized == false) {
				return;
			}
			if (_tree.initialized) {
				if (_node == null) {
					_node = _tree.nodes.take(tKey) as Node;
				}
				if (_node.coder::_rect.contains(tx, ty) == false) {
					var newNode:Node = _tree.nodes.take(tKey) as Node;
					this.resetNode(_node, newNode);
					if (newNode != null) {
						_node = newNode;
					}
				}
			}
		}

		private function resetNode(nodeOld:Node, nodeNew:Node):void
		{
			if (nodeOld && nodeNew) {
				if (nodeOld != nodeNew) {
					nodeOld.removeChild(this.id);
					nodeNew.addChild(this.id, this);
					_node = nodeNew;
					this.resetNode(nodeOld.parent, nodeNew.parent);
				}
			}
		}

		public function get node():Node
		{
			return _node;
		}

		private function get nodeKey():String
		{
			var dx:int = (int(this.x / NodeTree.doubleMinWidth) * NodeTree.doubleMinWidth) + NodeTree.minWidth;
			var dy:int = (int(this.y / NodeTree.doubleMinHeight) * NodeTree.doubleMinHeight) + NodeTree.minHeight;
			return dx + Engine.SIGN + dy;
		}

		public function activate():void
		{
			if (_tree.initialized) {
				_isActivate = true;
				_node = _tree.nodes.take(this.nodeKey) as Node;
				this.push(_node);
			}
		}

		public function unactivate():void
		{
			_isActivate = false;
			if (_node) {
				this.remove(_node);
				_node = null;
			}
		}

		public function get isActivate():Boolean
		{
			return _isActivate;
		}

		public function get tid():String
		{
			return this.coder::_tid;
		}

		public function push(aNode:Node):void
		{
			if (aNode == null) {
				return;
			}
			aNode.addChild(this.id, this);
			var pNode:Node = aNode.parent;
			if (pNode) {
				this.push(pNode);
			}
		}

		private function remove(aNode:Node):void
		{
			if (aNode == null) {
				return;
			}
			aNode.removeChild(this.id);
			var pNode:Node = aNode.parent;
			if (pNode) {
				this.remove(pNode);
			}
		}

		override public function dispose():void
		{
			_isActivate = false;
			_initialized = false;
			this.remove(_node);
			_node = null;
			_tree = null;
			super.dispose();
		}

	}
}
