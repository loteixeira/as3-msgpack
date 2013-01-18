package org.msgpack
{
	import flash.utils.*;
	
	internal class NumberWorker extends Worker
	{
		public static function checkType(byte:int):Boolean
		{
			return byte == 0xca || byte == 0xcb;
		}

		public function NumberWorker(parser:Parser, byte:int = -1)
		{
			super(parser, byte);
		}

		override public function getBufferLength():int
		{
			return byte == 0xca ? 4 : 8;
		}

		override public function encode(data:*, destination:IDataOutput):void
		{
			super.encode(data, destination);
			destination.writeByte(0xcb);
			destination.writeDouble(data);
		}

		override public function decode(source:IDataInput):*
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