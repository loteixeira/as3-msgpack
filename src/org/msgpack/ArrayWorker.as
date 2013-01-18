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

		public function ArrayWorker(factory:Factory, byte:int = -1)
		{
			super(factory, byte);
		}

		override public function getBufferLength(source:IDataInput):int
		{
			return VARIABLE;
		}

		override public function assembly(data:*, destination:IDataOutput):void
		{
			super.assembly(data, destination);

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
				factory.encode(data[i], destination);
		}

		override public function disassembly(source:IDataInput):*
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
				cpln("oi");
				var first:uint = array.length;

				for (var i:uint = first; i < count; i++)
				{
					var obj:* = factory.decode(source);
					cpln(obj);

					if (obj)
					{
						cpln(array.length + "/" + count);
						array.push(obj);
					}
				}
			}

			cpln(array.length + " | " + count);

			if (array.length == count)
			{
				cpln("aa");
				var result:* = array;
				array = null;
				return result;
			}

			return null;
		}
	}
}