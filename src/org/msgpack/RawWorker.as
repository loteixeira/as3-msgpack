package org.msgpack
{
	import flash.utils.*;

	internal class RawWorker extends Worker
	{
		private var count:int;

		public static function checkType(byte:int):Boolean
		{
			return (byte & 0xe0) == 0xa0 || byte == 0xda || byte == 0xdb;
		}

		public function RawWorker(factory:Factory, byte:int = -1)
		{
			super(factory, byte);
			count = -1;
		}

		override public function assembly(data:*, destination:IDataOutput):void
		{
			var bytes:ByteArray;

			if (data is ByteArray)
			{
				bytes = data;
			}
			else
			{
				bytes = new ByteArray();
				bytes.writeUTFBytes(data.toString());
			}

			if (bytes.length < 32)
			{
				// fix raw
				destination.writeByte(0xa0 | bytes.length);
			}
			else if (bytes.length < 65536)
			{
				// raw 16
				destination.writeByte(0xda);
				destination.writeShort(bytes.length);
			}
			else
			{
				// raw 32
				destination.writeByte(0xdb);
				destination.writeInt(bytes.length);
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

				return factory.checkFlag(MsgPack.READ_RAW_AS_BYTE_ARRAY) ? data : data.toString();
			}

			return incomplete;
		}
	}
}