package org.msgpack
{
	import flash.utils.*;
	
	internal class NumberWorker extends Worker
	{
		public function NumberWorker()
		{
			super();
		}

		override public function checkType(byte:int):Boolean
		{
			return byte == 0xca || byte == 0xcb;
		}

		override public function getBufferLength(byte:int):int
		{
			return byte == 0xca ? 4 : 8;
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