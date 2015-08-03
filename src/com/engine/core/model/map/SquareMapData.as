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
		
		public function praseLayerpro(item_id:String, px:int, py:int, dir:int):ItemData
		{
			var data:ItemData = new ItemData();
			data.x = px;
			data.y = py;
			data.item_id = item_id;
			data.dir = dir;
			return data;
		}
		
		public function uncode(bytes:ByteArray, source:Hash=null):void
		{
			bytes.position = 0;
			try {
				bytes.uncompress();
			} catch(e:Error) {
			}
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
			
			this.items = [];
			var itemData:ItemData;
			var item_id:String;
			var itemX:int;
			var itemY:int;
			var dir:int;
			count = bytes.readShort();
			idx = 0;
			while (idx < count) {
				item_id = bytes.readUTF();
				itemX = bytes.readInt();
				itemY = bytes.readInt();
				dir = bytes.readByte();
				itemData = this.praseLayerpro(item_id, itemX, itemY, dir);
				this.items.push(itemData);
				idx++;
			}
		}
		
	}
}
