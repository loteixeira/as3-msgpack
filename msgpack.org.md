<p><strong>MessagePack for Actionscript3 (Flash, Flex and AIR).</strong></p>
<p>as3-msgpack was designed to work with the interfaces IDataInput and IDataOutput, thus the API might be easily connected with the native classes that handle binary data (such as ByteArray, Socket, FileStream and URLStream).<br>
Moreover, as3-msgpack is capable of decoding data from binary streams.<br>
Get started: http://loteixeira.github.io/lib/2013/08/19/as3-msgpack/</p>

<strong>Basic usage (encoding/decoding):</strong>
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
