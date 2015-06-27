// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.demonsters.debugger.MonsterDebuggerData

package com.demonsters.debugger
{
    import flash.utils.ByteArray;

    public class MonsterDebuggerData 
    {

        private var _data:Object;
        private var _id:String;

        public function MonsterDebuggerData(_arg_1:String, _arg_2:Object)
        {
            _id = _arg_1;
            _data = _arg_2;
        }

        public static function read(_arg_1:ByteArray):MonsterDebuggerData
        {
            var _local_2:MonsterDebuggerData = new (MonsterDebuggerData)(null, null);
            _local_2.bytes = _arg_1;
            return (_local_2);
        }


        public function get data():Object
        {
            return (_data);
        }

        public function set bytes(value:ByteArray):void
        {
            var bytesId:ByteArray = new ByteArray();
            var bytesData:ByteArray = new ByteArray();
            try {
                value.readBytes(bytesId, 0, value.readUnsignedInt());
                value.readBytes(bytesData, 0, value.readUnsignedInt());
                _id = (bytesId.readObject() as String);
                _data = (bytesData.readObject() as Object);
            } catch(e:Error) {
                _id = null;
                _data = null;
            };
            bytesId = null;
            bytesData = null;
        }

        public function get id():String
        {
            return (_id);
        }

        public function get bytes():ByteArray
        {
            var _local_1:ByteArray = new ByteArray();
            var _local_2:ByteArray = new ByteArray();
            _local_1.writeObject(_id);
            _local_2.writeObject(_data);
            var _local_3:ByteArray = new ByteArray();
            _local_3.writeUnsignedInt(_local_1.length);
            _local_3.writeBytes(_local_1);
            _local_3.writeUnsignedInt(_local_2.length);
            _local_3.writeBytes(_local_2);
            _local_3.position = 0;
            _local_1 = null;
            _local_2 = null;
            return (_local_3);
        }


    }
}//package com.demonsters.debugger

