# as3-msgpack v0.2.0
<p>as3-msgpack is a implementation of MessagePack specification for Actionscript3 language (Flash, Flex and AIR).</p>
<p>The decoder/encoder functions were initially based on Java implementation: https://github.com/msgpack/msgpack-java</p>

## about message pack format
<p>MessagePack specification is an efficient binary serialization format. It lets you exchange data among multiple languages like JSON but it's faster and smaller. For example, small integers (like flags or error code) are encoded into a single byte, and typical short strings only require an extra byte in addition to the strings themselves.</p>
<p>Check the website: http://msgpack.org</p>

## examples
<p>Basically you'll work with two objects: the encoder and the decoder. Each object has one method, which allows you to read/write data into a buffer. If you don't specify the buffer for the objects, a new one will be created.</p>

### basic encoding/decoding
```actionscript
var encoder:MessagePackEncoder = new MessagePackEncoder(); // create the encoder object
encoder.write(42); // encode a number
var decoder:MessagePackDecoder = new MessagePackDecoder(encoder.buffer) // create decoder object which will read from encoder ByteArray
trace(decoder.read()); // voilá!
```

### using own buffers
```actionscript
var bytes:ByteArray = new ByteArray(); // say now we want to manipulate our own ByteArray
var encoder:MessagePackEncoder = new MessagePackEncoder(bytes);
encoder.write(123.456); // encoding a double precision floating point value
var decoder:MessagePackDecoder = new MessagePackDecoder(bytes);
trace(decoder.read()); // voilá!
```

### encoding arrays
```actionscript
var encoder:MessagePackEncoder = new MessagePackEncoder(); // create the encoder object
encoder.write([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]); // encode an array
var decoder:MessagePackDecoder = new MessagePackDecoder(encoder.buffer) // create decoder object which will read from encoder ByteArray
trace(decoder.read()); // voilá! - here is the brand new array
```

### encoding objects
```actionscript
var encoder:MessagePackEncoder = new MessagePackEncoder(); // create the encoder object
encoder.write({myNumber: 42, myName: "Lucas"}); // encode an object
var decoder:MessagePackDecoder = new MessagePackDecoder(encoder.buffer) // create decoder object which will read from encoder ByteArray
var obj:Object = decoder.read();
for (var key:String in obj)
	trace(key + " = " + obj[key]); // print each element of the object
```
<p>Note that Strings are stored as raw bytes (written in UTF format). If you need to manipulate it after encoding you need to read the data into the ByteArray as a String.</p>

## generating binaries
<p>You may use this library just copying the source files to your project, so when compiling it, as3-msgpack classes will be already included. However, you may prefer to use pre-compiled binaries (which can improve the compiling time of your project). You can download the binaries straight from the repository, or download the latest tag.</p>
<p>In the case you want to recompile the project by your self, you'll need to install FlexSDK (as3-msgpack compiles for Flash Player 9 or above). See the following instructions for more details.</p>
<p>Note: FlexSDK binaries must be in your PATH to run the following commands.</p>

### compiling test application
<p>At the root folder of the project (as3-msgpack), type the following command:</p>
```
mxmlc -default-frame-rate=30 -default-size=800,600 -static-link-runtime-shared-libraries=true -source-path+=src/ -library-path+=lib/ -output=bin/MessagePackTest.swf -- src/org/msgpack/MessagePackTest.as
```
<p>The file MessagePackTest.swf will be generated in bin folder.</p>

### compiling library
<p>At the root folder of the project (as3-msgpack), type the following command:</p>
```
compc -include-sources+=src/org/msgpack/MessagePackBase.as -include-sources+=src/org/msgpack/MessagePackDecoder.as -include-sources+=src/org/msgpack/MessagePackEncoder.as -include-sources+=src/org/msgpack/TypeHandler.as -include-sources+=src/org/msgpack/TypeMap.as -output=bin/MessagePack.swc
```
<p>The file MessagePack.swc will be generated in bin folder.</p>