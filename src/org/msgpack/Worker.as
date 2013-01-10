package org.messagepack
{
	import flash.utils.*;

	public class Worker
	{
		public static const VARIABLE:int = -1;

		public function Worker()
		{
		}

		public function checkType(byte:int):Boolean
		{
			return false;
		}

		public function getBufferLength():int
		{
			return 0;
		}

		public function encode(data:*, destination:IDataOutput):void
		{
		}

		public function decode(byte:int, source:IDataInput):*
		{
			return null;
		}
	}
}