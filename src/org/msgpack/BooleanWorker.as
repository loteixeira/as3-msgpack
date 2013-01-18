package org.msgpack
{
	import flash.utils.*;
	
	internal class BooleanWorker extends Worker
	{
		public static function checkType(byte:int):Boolean
		{
			return byte == 0xc3 || byte == 0xc2;
		}

		public function BooleanWorker(factory:Factory, byte:int = -1)
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

			if (data)
				destination.writeByte(0xc3);
			else
				destination.writeByte(0xc2);
		}

		override public function disassembly(source:IDataInput):*
		{
			return byte == 0xc3;
		}
	}
}