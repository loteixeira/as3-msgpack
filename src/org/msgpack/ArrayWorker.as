package org.msgpack
{
	import flash.utils.*;

	internal class ArrayWorker extends Worker
	{
		public static function checkType(byte:int):Boolean
		{
			return (byte & 0xf0) == 0x90 || byte == 0xdc || byte == 0xdd;
		}

		private var array:Array;
		private var count:uint;

		public function ArrayWorker(parser:Parser, byte:int = -1)
		{
			super(parser, byte);
		}

		override public function getBufferLength():int
		{
			return VARIABLE;
		}

		override public function encode(data:*, destination:IDataOutput):void
		{
			super.encode(data, destination);

			var l:uint = data.length;

			if (l < 16)
			{
				// fix array
				destination.writeByte(0x90 | l);
			}
			else if (l < 65536)
			{
				// array 16
				destination.writeByte(0xdc);
				destination.writeShort(l);
			}
			else
			{
				// array 32
				destination.writeByte(0xdd);
				destination.writeUnsignedInt(l);
			}

			// write elements
			for (var i:uint = 0; i < l; i++)
				parser.encode(data[i], destination);
		}

		override public function decode(source:IDataInput):*
		{
			if (!array)
			{
				if ((byte & 0xf0) == 0x90)
					count = byte & 0x0f
				else if (byte == 0xdc)
					count = source.readUnsignedShort();
				else if (byte == 0xdd)
					count = source.readUnsignedInt();

				array = [];
			}

			if (array.length < count)
			{
				var first:uint = array.length;

				for (var i:uint = first; i < count; i++)
				{
					var obj:* = parser.decode(source);

					if (obj)
						array.push(obj);
				}
			}

			if (array.length == count)
			{
				var result:* = array;
				array = null;
				return result;
			}

			return null;
		}
	}
}