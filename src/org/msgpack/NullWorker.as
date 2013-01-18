package org.msgpack
{
	import flash.utils.*;

	internal class NullWorker extends Worker
	{
		public static function checkType(byte:int):Boolean
		{
			return byte == 0xc0;
		}

		public function NullWorker(factory:Factory, byte:int = -1)
		{
			super(factory, byte);
		}

		override public function getBufferLength(source:IDataInput):int
		{
			return 0;
		}

		override public function assembly(data:*, destination:IDataOutput):void
		{
			super.assembly(data, destination);
			destination.writeByte(0xc0);
		}

		override public function disassembly(source:IDataInput):*
		{
			return null;
		}
	}
}