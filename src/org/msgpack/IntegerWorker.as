package org.msgpack
{
	import flash.utils.*;
	
	internal class IntegerWorker extends Worker
	{
		public static function checkType(byte:int):Boolean
		{
			return (byte & 0x80) == 0 || (byte & 0xe0) == 0xe0 || byte == 0xcc || byte == 0xcd ||
				byte == 0xce || byte == 0xcf || byte == 0xd0 || byte == 0xd1 ||
				byte == 0xd2 || byte == 0xd3;
		}

		public function IntegerWorker(factory:Factory, byte:int = -1)
		{
			super(factory, byte);
		}

		override public function assembly(data:*, destination:IDataOutput):void
		{
			super.assembly(data, destination);

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

		override public function disassembly(source:IDataInput):*
		{
			var i:uint;
			var data:*;

			if ((byte & 0x80) == 0)
			{
				// positive fixnum
				return byte;
			}
			else if ((byte & 0xe0) == 0xe0)
			{
				// negative fixnum
				return byte - 0xff - 1;
			}
			else if (byte == 0xcc && source.bytesAvailable >= 1)
			{
				// unsigned byte
				return source.readUnsignedByte();
			}
			else if (byte == 0xcd && source.bytesAvailable >= 2)
			{
				// unsigned short
				return source.readUnsignedShort();
			}
			else if (byte == 0xce && source.bytesAvailable >= 4)
			{
				// unsigned int
				return source.readUnsignedInt();
			}
			else if (byte == 0xcf && source.bytesAvailable >= 8)
			{
				// TODO: can't read 64 bits unsigned integers
				for (i = 0; i < 8; i++)
					source.readByte();

				return NaN;
			}
			else if (byte == 0xd0 && source.bytesAvailable >= 1)
			{
				// signed byte
				return source.readByte();
			}
			else if (byte == 0xd1 && source.bytesAvailable >= 2)
			{
				// signed short
				return source.readShort();
			}
			else if (byte == 0xd2 && source.bytesAvailable >= 4)
			{
				// signed int
				return source.readInt();
			}
			else if (byte == 0xd3 && source.bytesAvailable >= 8)
			{
				// TODO: can't read 64 bits integers
				for (i = 0; i < 8; i++)
					source.readByte();

				return NaN;
			}

			return Worker.INCOMPLETE;
		}
	}
}