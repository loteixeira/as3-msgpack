package org.msgpack
{
	import flash.utils.*;

	internal class NullWorker extends Worker
	{
		public function NullWorker()
		{
			super();
		}

		override public function checkType(byte:int):Boolean
		{
			return byte == 0xc0;
		}

		override public function getBufferLength(byte:int):int
		{
			return 0;
		}

		override public function encode(data:*, destination:IDataOutput):void
		{
			super.encode(data, destination);
			destination.writeByte(0xc0);
		}

		override public function decode(byte:int, source:IDataInput):*
		{
			return null;
		}
	}
}