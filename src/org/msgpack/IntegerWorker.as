package org.msgpack
{
	import flash.utils.*;
	
	internal class IntegerWorker extends Worker
	{
		public function IntegerWorker()
		{
			super();
		}

		override public function checkType(byte:int):Boolean
		{
			return (byte & 0x80) == 0 || (byte & 0xe0) == 0xe0 || byte == 0xcc || byte == 0xcd ||
				byte == 0xce || byte == 0xcf || byte == 0xd0 || byte == 0xd1 ||
				byte == 0xd2 || byte == 0xd3;
		}

		override public function getBufferLength(byte:int):int
		{
			if ((byte & 0x80) == 0)
				return 0;

			if ((byte & 0xe0) == 0xe0)
				return 0;

			if (byte == 0xcc)
				return 1;

			if (byte == 0xcd)
				return 2;

			if (byte == 0xce)
				return 4;

			if (byte == 0xcf)
				return 8;

			if (byte == 0xd0)
				return 1;

			if (byte == 0xd1)
				return 2;

			if (byte == 0xd2)
				return 4;

			if (byte == 0xd3)
				return 8;

			return 0;
		}

		override public function encode(data:*, destination:IDataOutput):void
		{
			super.encode(data, destination);
			destination.writeByte(0xcb);
			destination.writeDouble(data);
		}

		override public function decode(byte:int, source:IDataInput):*
		{
			var data:Number;

			if (byte == 0xca)
				data = source.readFloat();
			else if (byte == 0xcb)
				data = source.readDouble();

			return data;
		}
	}
}