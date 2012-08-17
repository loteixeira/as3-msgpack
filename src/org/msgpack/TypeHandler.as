package org.msgpack
{
	import flash.utils.ByteArray;

	internal class TypeHandler
	{
		//
		// null handlers
		//
		public static function encodeNull(data:*, destination:ByteArray, typeMap:TypeMap):void
		{
			destination.writeByte(0xc0);
		}

		public static function decodeNull(source:ByteArray, typeMap:TypeMap):*
		{
			source.position++;
			return null;
		}

		public static function checkNull(source:ByteArray):Boolean
		{
			return source[source.position] == 0xc0;
		}

		//
		// Boolean handlers
		//
		public static function encodeBoolean(data:Boolean, destination:ByteArray, typeMap:TypeMap):void
		{
			if (data == true)
				destination.writeByte(0xc3);
			else
				destination.writeByte(0xc2);
		}

		public static function decodeBoolean(source:ByteArray, typeMap:TypeMap):Boolean
		{
			var byte:uint = source.readByte() & 0xff;
			return byte == 0xc3;
		}

		public static function checkBoolean(source:ByteArray):Boolean
		{
			return source[source.position] == 0xc3 || source[source.position] == 0xc2;
		}

		//
		// Number handlers
		//
		public static function encodeNumber(data:Number, destination:ByteArray, typeMap:TypeMap):void
		{
			destination.writeByte(0xcb);
			destination.writeDouble(data);
		}

		public static function decodeNumber(source:ByteArray, typeMap:TypeMap):Number
		{
			var byte:int = source.readByte() & 0xff;
			var data:Number;

			if (byte == 0xca)
				data = source.readFloat();
			else if (byte == 0xcb)
				data = source.readDouble();

			return data;
		}

		public static function checkNumber(source:ByteArray):Boolean
		{
			return source[source.position] == 0xca || source[source.position] == 0xcb;
		}

		//
		// int handlers
		//
		public static function encodeInt(data:int, destination:ByteArray, typeMap:TypeMap):void
		{
			if (data < -(1 << 5))
			{
				if (data < -(1 << 15))
				{
					// signed 32
					destination.writeByte(0xd2);
					destination.writeInt(data);
				}
				else if (data < -(1 << 7))
				{
					// signed 16
					destination.writeByte(0xd1);
					destination.writeShort(data);
				}
				else
				{
					// signed 8
					destination.writeByte(0xd0);
					destination.writeByte(data);
				}
			}
			else if (data < (1 << 7))
			{
				// fixnum
				destination.writeByte(data);
			}
			else
			{
				if (data < (1 << 8))
				{
					// unsigned 8
					destination.writeByte(0xcc);
					destination.writeByte(data);
				}
				else if (data < (1 << 16))
				{
					// unsigned 16
					destination.writeByte(0xcd);
					destination.writeShort(data);
				}
				else
				{
					// unsigned 32
					destination.writeByte(0xce);
					destination.writeUnsignedInt(data);
				}
			}
		}

		public static function decodeInt(source:ByteArray, typeMap:TypeMap):int
		{
			var byte:int = source.readByte() & 0xff;
			var data:int = NaN;

			if ((byte & 0x80) == 0)
				data = byte;
			else if ((byte & 0xe0) == 0xe0)
				data = byte - 0xff - 1;
			else if (byte == 0xcc)
				data = source.readByte();
			else if (byte == 0xcd)
				data = source.readUnsignedShort();
			else if (byte == 0xce)
				data = source.readUnsignedInt();
			else if (byte == 0xcf)
				source.position += 8; // TODO: can't read 64 bits unsigned integers
			else if (byte == 0xd0)
				data = source.readByte();
			else if (byte == 0xd1)
				data = source.readShort();
			else if (byte == 0xd2)
				data = source.readInt();
			else if (byte == 0xd3)
				source.position += 8; // TODO: can't read 64 bits integers

			return data;
		}

		public static function checkInt(source:ByteArray):Boolean
		{
			var byte:int = source[source.position];
			return (byte & 0x80) == 0 || (byte & 0xe0) == 0xe0 || byte == 0xcc || byte == 0xcd ||
				byte == 0xce || byte == 0xcf || byte == 0xd0 || byte == 0xd1 ||
				byte == 0xd2 || byte == 0xd3;
		}

		//
		// ByteArray handlers
		//
		public static function encodeBytes(data:ByteArray, destination:ByteArray, typeMap:TypeMap):void
		{
			var length:uint = data.length;

			if (length < 32)
			{
				// fix raw
				destination.writeByte(0xa0 | length);
			}
			else if (length < 65536)
			{
				// raw 16
				destination.writeByte(0xda);
				destination.writeShort(length);
			}
			else
			{
				// raw 32
				destination.writeByte(0xdb);
				destination.writeInt(length);
			}

			destination.writeBytes(data);
		}

		public static function decodeBytes(source:ByteArray, typeMap:TypeMap):ByteArray
		{
			var byte:int = source.readByte() & 0xff;
			var length:uint;

			if ((byte & 0xe0) == 0xa0)
				length = byte & 0x1f;
			else if (byte == 0xda)
				length = source.readUnsignedShort();
			else if (byte == 0xdb)
				length = source.readUnsignedInt();

			var data:ByteArray = new ByteArray();
			data.writeBytes(source, source.position, length);
			data.position = 0;
			source.position += length;
			return data;
		}

		public static function checkBytes(source:ByteArray):Boolean
		{
			var byte:int = source[source.position];
			return (byte & 0xe0) == 0xa0 || byte == 0xda || byte == 0xdb;
		}

		//
		// String handlers
		//
		public static function encodeString(data:String, destination:ByteArray, typeMap:TypeMap):void
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(data);
			typeMap.encode(bytes, destination);
		}

		//
		// XML handlers
		//
		public static function encodeXML(data:XML, destination:ByteArray, typeMap:TypeMap):void
		{
			typeMap.encode(data.toXMLString(), destination);
		}

		//
		// Array handlers
		//
		public static function encodeArray(data:Array, destination:ByteArray, typeMap:TypeMap):void
		{
			var length:uint = data.length;

			if (length < 16)
			{
				// fix array
				destination.writeByte(0x90 | length);
			}
			else if (length < 65536)
			{
				// array 16
				destination.writeByte(0xdc);
				destination.writeShort(length);
			}
			else
			{
				// array 32
				destination.writeByte(0xdd);
				destination.writeUnsignedInt(length);
			}

			// write elements
			for (var i:uint = 0; i < length; i++)
				typeMap.encode(data[i], destination);
		}

		public static function decodeArray(source:ByteArray, typeMap:TypeMap):Array
		{
			var byte:int = source.readByte() & 0xff;
			var length:uint;

			if ((byte & 0xf0) == 0x90)
				length = byte & 0x0f
			else if (byte == 0xdc)
				length = source.readUnsignedShort();
			else if (byte == 0xdd)
				length = source.readUnsignedInt();

			var data:Array = [];

			for (var i:uint = 0; i < length; i++)
				data.push(typeMap.decode(source));

			return data;
		}

		public static function checkArray(source:ByteArray):Boolean
		{
			var byte:int = source[source.position];
			return (byte & 0xf0) == 0x90 || byte == 0xdc || byte == 0xdd;
		}

		//
		// Object handlers
		//
		public static function encodeObject(data:Object, destination:ByteArray, typeMap:TypeMap):void
		{
			var elements:Array = [];	

			for (var key:String in data)
				elements.push(key);

			var length:uint = elements.length;

			if (length < 16)
			{
				// fix map
				destination.writeByte(0x80 | length);
			}
			else if (length < 65536)
			{
				// map 16
				destination.writeByte(0xde);
				destination.writeShort(length);
			}
			else
			{
				// map 32
				destination.writeByte(0xdf);
				destination.writeUnsignedInt(length);
			}

			for (var i:uint = 0; i < length; i++)
			{
				var elemKey:String = elements[i];

				typeMap.encode(elemKey, destination);
				typeMap.encode(data[elemKey], destination);
			}
		}

		public static function decodeObject(source:ByteArray, typeMap:TypeMap):Object
		{
			var byte:int = source.readByte() & 0xff;
			var length:uint;

			if ((byte & 0xf0) == 0x80)
				length = byte & 0x0f;
			else if (byte == 0xde)
				length = source.readUnsignedShort();
			else if (byte == 0xdf)
				length = source.readUnsignedInt();

			var data:Object = {};

			for (var i:uint = 0; i < length; i++)
			{
				var rawKey:* = typeMap.decode(source);
				var value:* = typeMap.decode(source);
				var key:String;

				if (rawKey is ByteArray)
				{
					var bytes:ByteArray = rawKey as ByteArray;
					key = bytes.readUTFBytes(bytes.length);
				}
				else
				{
					key = rawKey.toString();
				}

				data[key] = value;
			}

			return data;
		}

		public static function checkObject(source:ByteArray):Boolean
		{
			var byte:int = source[source.position];
			return (byte & 0xf0) == 0x80 || byte == 0xde || byte == 0xdf;
		}
	}
}