package org.msgpack
{
	import flash.utils.*;
	
	internal class BooleanWorker extends Worker
	{
		public function BooleanWorker()
		{
			super();
		}

		override public function checkType(byte:int):Boolean
		{
			return byte == 0xc3 || byte == 0xc2;
		}

		override public function getBufferLength(byte:int):int
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

		override public function decode(byte:int, source:IDataInput):*
		{
			return byte == 0xc3;
		}
	}
}