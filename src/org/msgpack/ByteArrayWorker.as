package org.msgpack
{
	import flash.utils.*;

	internal class ByteArrayWorker extends Worker
	{
		private var count:int;

		public static function checkType(byte:int):Boolean
		{
			return (byte & 0xe0) == 0xa0 || byte == 0xda || byte == 0xdb;
		}

		public function ByteArrayWorker(factory:Factory, byte:int = -1)
		{
			super(factory, byte);
			count = -1;
		}

		override public function assembly(data:*, destination:IDataOutput):void
		{
			if (data.length < 32)
			{
				// fix raw
				destination.writeByte(0xa0 | data.length);
			}
			else if (data.length < 65536)
			{
				// raw 16
				destination.writeByte(0xda);
				destination.writeShort(data.length);
			}
			else
			{
				// raw 32
				destination.writeByte(0xdb);
				destination.writeInt(data.length);
			}

			var bytes:ByteArray;

			if (!(data is ByteArray))
			{
				bytes = new ByteArray();
				bytes.writeUTFBytes(data.toString());
			}

			destination.writeBytes(bytes);
		}

		override public function disassembly(source:IDataInput):*
		{
			if (count == -1)
			{
				if ((byte & 0xe0) == 0xa0)
					count = byte & 0x1f;
				else if (byte == 0xda && source.bytesAvailable >= 2)
					count = source.readUnsignedShort();
				else if (byte == 0xdb && source.bytesAvailable >= 4)
					count = source.readUnsignedInt();
			}

			if (source.bytesAvailable >= count)
			{
				var data:ByteArray = new ByteArray();

				if (count > 0)
					source.readBytes(data, 0, count);

				return data;
			}

			return incomplete;
		}
	}
}