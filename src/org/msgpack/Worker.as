package org.msgpack
{
	import flash.utils.*;

	public class Worker
	{
		public static const VARIABLE:int = -1;

		public static function checkType(byte:int):Boolean
		{
			return false;
		}

		protected var parser:Parser;
		protected var byte:int;

		public function Worker(parser:Parser, byte:int = -1)
		{
			this.parser = parser;
			this.byte = byte;
		}

		public function getParser():Parser
		{
			return parser;
		}

		public function getByte():int
		{
			return byte;
		}

		public function getBufferLength():int
		{
			return 0;
		}

		public function encode(data:*, destination:IDataOutput):void
		{
		}

		public function decode(source:IDataInput):*
		{
			return null;
		}
	}
}