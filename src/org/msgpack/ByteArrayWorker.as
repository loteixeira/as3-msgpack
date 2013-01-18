package org.msgpack
{
	import flash.utils.*;

	internal class ByteArrayWorker extends Worker
	{
		private var l:int;

		public static function checkType(byte:int):Boolean
		{
			return (byte & 0xe0) == 0xa0 || byte == 0xda || byte == 0xdb;
		}

		public function ByteArrayWorker(factory:Factory, byte:int = -1)
		{
			super(factory, byte);
			l = -1;
		}

		override public function getBufferLength(source:IDataInput):int
		{
			if (l == -1)
			{
				if ((byte & 0xe0) == 0xa0)
					l = byte & 0x1f;
				else if (byte == 0xda)
					l = source.readUnsignedShort();
				else if (byte == 0xdb)
					l = source.readUnsignedInt();
			}

			return l;
		}

		override public function assembly(data:*, destination:IDataOutput):void
		{
			if (l < 32)
			{
				// fix raw
				destination.writeByte(0xa0 | l);
			}
			else if (l < 65536)
			{
				// raw 16
				destination.writeByte(0xda);
				destination.writeShort(l);
			}
			else
			{
				// raw 32
				destination.writeByte(0xdb);
				destination.writeInt(l);
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
			cpln('a eh');
			var data:ByteArray = new ByteArray();
			source.readBytes(data, 0, l);
			l = -1;
			return data;
		}
	}
}