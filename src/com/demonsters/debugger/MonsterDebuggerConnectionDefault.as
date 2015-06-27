// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.demonsters.debugger.MonsterDebuggerConnectionDefault

package com.demonsters.debugger
{
    import flash.utils.ByteArray;
    import flash.net.Socket;
    import flash.utils.Timer;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.TimerEvent;
    import com.demonsters.debugger.MonsterDebuggerData;
    import com.demonsters.debugger.MonsterDebugger;
    import flash.system.Security;

    class MonsterDebuggerConnectionDefault implements IMonsterDebuggerConnection 
    {

        private const MAX_QUEUE_LENGTH:int = 500;

        private var _length:uint;
        private var _package:ByteArray;
        private var _queue:Array;
        private var _connecting:Boolean;
        private var _socket:Socket;
        private var _timeout:Timer;
        private var _port:int;
        private var _retry:Timer;
        private var _bytes:ByteArray;
        private var _process:Boolean;
        private var _address:String;

        public function MonsterDebuggerConnectionDefault()
        {
            _queue = [];
            super();
            _socket = new Socket();
            _socket.addEventListener(Event.CONNECT, connectHandler, false, 0, false);
            _socket.addEventListener(Event.CLOSE, closeHandler, false, 0, false);
            _socket.addEventListener(IOErrorEvent.IO_ERROR, closeHandler, false, 0, false);
            _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, closeHandler, false, 0, false);
            _socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler, false, 0, false);
            _connecting = false;
            _process = false;
            _address = "127.0.0.1";
            _port = 5840;
            _timeout = new Timer(2000, 1);
            _timeout.addEventListener(TimerEvent.TIMER, closeHandler, false, 0, false);
            _retry = new Timer(1000, 1);
            _retry.addEventListener(TimerEvent.TIMER, retryHandler, false, 0, false);
        }

        private function dataHandler(_arg_1:ProgressEvent):void
        {
            _bytes = new ByteArray();
            _socket.readBytes(_bytes, 0, _socket.bytesAvailable);
            _bytes.position = 0;
            processPackage();
        }

        public function send(_arg_1:String, _arg_2:Object, _arg_3:Boolean=false):void
        {
            var _local_4:ByteArray;
            if (((((_arg_3) && ((_arg_1 == MonsterDebuggerCore.ID)))) && (_socket.connected))){
                _local_4 = new MonsterDebuggerData(_arg_1, _arg_2).bytes;
                _socket.writeUnsignedInt(_local_4.length);
                _socket.writeBytes(_local_4);
                _socket.flush();
                return;
            };
            _queue.push(new MonsterDebuggerData(_arg_1, _arg_2));
            if (_queue.length > MAX_QUEUE_LENGTH){
                _queue.shift();
            };
            if (_queue.length > 0){
                next();
            };
        }

        public function get connected():Boolean
        {
            if (_socket == null){
                return (false);
            };
            return (_socket.connected);
        }

        private function next():void
        {
            if (!MonsterDebugger.enabled){
                return;
            };
            if (!_process){
                return;
            };
            if (!_socket.connected){
                connect();
                return;
            };
            var _local_1:ByteArray = MonsterDebuggerData(_queue.shift()).bytes;
            _socket.writeUnsignedInt(_local_1.length);
            _socket.writeBytes(_local_1);
            _socket.flush();
            _local_1 = null;
            if (_queue.length > 0){
                next();
            };
        }

        private function retryHandler(_arg_1:TimerEvent):void
        {
            _retry.stop();
            connect();
        }

        private function processPackage():void
        {
            var _local_1:uint;
            var _local_2:MonsterDebuggerData;
            if (_bytes.bytesAvailable == 0){
                return;
            };
            if (_length == 0){
                _length = _bytes.readUnsignedInt();
                _package = new ByteArray();
            };
            if ((((_package.length < _length)) && ((_bytes.bytesAvailable > 0)))){
                _local_1 = _bytes.bytesAvailable;
                if (_local_1 > (_length - _package.length)){
                    _local_1 = (_length - _package.length);
                };
                _bytes.readBytes(_package, _package.length, _local_1);
            };
            if (((!((_length == 0))) && ((_package.length == _length)))){
                _local_2 = MonsterDebuggerData.read(_package);
                if (_local_2.id != null){
                    MonsterDebuggerCore.handle(_local_2);
                };
                _length = 0;
                _package = null;
            };
            if ((((_length == 0)) && ((_bytes.bytesAvailable > 0)))){
                processPackage();
            };
        }

        public function set address(_arg_1:String):void
        {
            _address = _arg_1;
        }

        private function connectHandler(_arg_1:Event):void
        {
            _timeout.stop();
            _retry.stop();
            _connecting = false;
            _bytes = new ByteArray();
            _package = new ByteArray();
            _length = 0;
            _socket.writeUTFBytes(("<hello/>" + "\n"));
            _socket.writeByte(0);
            _socket.flush();
        }

        public function processQueue():void
        {
            if (!_process){
                _process = true;
                if (_queue.length > 0){
                    next();
                };
            };
        }

        private function closeHandler(_arg_1:Event=null):void
        {
            MonsterDebuggerUtils.resume();
            if (!_retry.running){
                _connecting = false;
                _process = false;
                _timeout.stop();
                _retry.reset();
                _retry.start();
            };
        }

        public function connect():void
        {
            if (((!(_connecting)) && (MonsterDebugger.enabled))){
                try {
                    Security.loadPolicyFile(((("xmlsocket://" + _address) + ":") + _port));
                    _connecting = true;
                    _socket.connect(_address, _port);
                    _retry.stop();
                    _timeout.reset();
                    _timeout.start();
                } catch(e:Error) {
                    closeHandler();
                };
            };
        }


    }
}//package com.demonsters.debugger

