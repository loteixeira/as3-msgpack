package org.msgpack
{
	import flash.utils.*;
	
	internal class BooleanWorker extends Worker
	{
		public static function checkType(byte:int):Boolean
		{
			return byte == 0xc3 || byte == 0xc2;
		}

		public function BooleanWorker(parser:Parser, byte:int = -1)
		{
			super(parser, byte);
		}

		override public function getBufferLength():int
		{
			return 0;
		}

		override public function encode(data:*, destination:IDataOutput):void
		{
			super.encode(data, destination);

			if (data)
				destination.writeByte(0xc3);
			else
				destination.writeByte(0xc2);
		}

		override public function decode(source:IDataInput):*
		{
			return byte == 0xc3;
		}
	}
}