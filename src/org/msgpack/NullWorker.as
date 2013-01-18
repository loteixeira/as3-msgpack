package org.msgpack
{
	import flash.utils.*;

	internal class NullWorker extends Worker
	{
		public static function checkType(byte:int):Boolean
		{
			return byte == 0xc0;
		}

		public function NullWorker(parser:Parser, byte:int = -1)
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
			destination.writeByte(0xc0);
		}

		override public function decode(source:IDataInput):*
		{
			return null;
		}
	}
}