<p>MessagePack for Actionscript3 (Flash, Flex and AIR).</p>
<p>as3-msgpack was designed to work with the interfaces IDataInput and IDataOutput, thus the API might be easily connected with the native classes that handle binary data (such as ByteArray, Socket, FileStream and URLStream).</p>
<p>Moreover, as3-msgpack is capable of decoding data from binary streams.</p>

<p>Basic usage (encoding/decoding):</p>
```actionscript
// create messagepack object
var msgpack:MsgPack = new MsgPack();

// encode an array
var bytes:ByteArray = msgpack.write([1, 2, 3, 4, 5]);

// rewind the buffer
bytes.position = 0;

// print the decoded object
trace(msgpack.read(bytes));
```

<p>For downloads, source code and further information, check the project repository: https://github.com/loteixeira/as3-msgpack.</p>