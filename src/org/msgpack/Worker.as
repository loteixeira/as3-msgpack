package org.msgpack
{
	import flash.utils.*;

	public class Worker
	{
		public static const VARIABLE:int = -1;

		private var parser:Parser;

		public function Worker()
		{
		}

		public function checkType(byte:int):Boolean
		{
			return false;
		}

		public function getBufferLength(byte:int):int
		{
			return 0;
		}

		public function encode(data:*, destination:IDataOutput):void
		{
			if (!parser)
				throw new MsgPackError("Worker not assigned to a parser");
		}

		public function decode(byte:int, source:IDataInput):*
		{
			return null;
		}

		internal function setParser(parser:Parser):void
		{
			this.parser = parser;
		}
	}
}