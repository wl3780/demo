package com.engine.core.model.map
{
	import com.engine.core.model.Proto;
	import com.engine.core.tile.square.Square;
	import com.engine.core.tile.square.SquareGroup;
	import com.engine.core.tile.square.SquarePt;
	import com.engine.utils.Hash;
	
	import flash.utils.ByteArray;

	public class SquareMapData extends Proto 
	{

		public var map_id:int;
		public var pixel_x:int;
		public var pixel_y:int;
		public var pixel_width:int;
		public var pixel_height:int;
		public var width:int;
		public var height:int;
		public var items:Array;

		public function prasePro(px:int, py:int, num:int):Square
		{
			var sq:Square = Square.createSquare();
			var info:String = num.toString();
			sq.type = int(info.slice(1, 2));
			sq.isSafe = Boolean(int(info.slice(2, 3)));
			sq.isSell = Boolean(int(info.slice(3, 4)));
			sq.isAlpha = Boolean(int(info.slice(4, 5)));
			sq.setIndex(new SquarePt(px, py));
			
			if (sq.type > 0) {
				sq.color = 0xFF00;
			} else {
				sq.color = 0xFF0000;
			}
			return sq;
		}

		public function praseLayerpro(itemID:int, px:int, py:int, bytes:ByteArray):ItemData
		{
			var data:ItemData = new ItemData();
			data.x = px;
			data.y = py;
			data.item_id = itemID;
			data.layer = bytes.readShort();
			data.depth = bytes.readShort();
			return data;
		}

		public function uncode(bytes:ByteArray, source:Hash=null):void
		{
			if (bytes == null) {
				return;
			}
			this.items = [];
			bytes.position = 0;
			try {
				bytes.uncompress();
			} catch(e:Error) {
			}
			bytes.position = 0;
			this.map_id = bytes.readShort();
			this.pixel_x = bytes.readShort();
			this.pixel_y = bytes.readShort();
			this.pixel_width = bytes.readShort();
			this.pixel_height = bytes.readShort();
			
			var sq:Square;
			var sqX:int;
			var sqY:int;
			var sqGroup:SquareGroup = SquareGroup.getInstance();
			var idx:int = 0;
			var count:int = bytes.readInt();
			while (idx < count) {
				sqX = bytes.readShort();
				sqY = bytes.readShort();
				sq = this.prasePro(sqX, sqY, bytes.readShort());
				if (source) {
					source.put(sq.key, sq);
				} else {
					sqGroup.put(sq);
				}
				idx++;
			}
			
			var itemData:ItemData;
			var itemID:int;
			var itemX:int;
			var itemY:int;
			count = bytes.readShort();
			idx = 0;
			while (idx < count) {
				itemID = bytes.readInt();
				itemX = bytes.readInt();
				itemY = bytes.readInt();
				itemData = this.praseLayerpro(itemID, itemX, itemY, bytes);
				this.items.push(itemData);
				idx++;
			}
		}

	}
}
