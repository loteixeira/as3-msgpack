package org.msgpack
{
	import flash.utils.*;
	
	internal class NumberWorker extends Worker
	{
		public static function checkType(byte:int):Boolean
		{
			return byte == 0xca || byte == 0xcb;
		}

		public function NumberWorker(factory:Factory, byte:int = -1)
		{
			super(factory, byte);
		}

		override public function assembly(data:*, destination:IDataOutput):void
		{
			super.assembly(data, destination);
			destination.writeByte(0xcb);
			destination.writeDouble(data);
		}

		override public function disassembly(source:IDataInput):*
		{
			var data:Number;

			if (byte == 0xca && source.bytesAvailable >= 4)
				return source.readFloat();
			else if (byte == 0xcb && source.bytesAvailable >= 8)
				return source.readDouble();

			return Worker.INCOMPLETE;
		}
	}
}