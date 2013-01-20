package org.msgpack
{
	import flash.utils.*;

	public class Worker
	{
		public static const VARIABLE:int = -1;
		public static const INCOMPLETE:Object = {};

		public static function checkType(byte:int):Boolean
		{
			return false;
		}

		protected var factory:Factory;
		protected var byte:int;

		public function Worker(factory:Factory, byte:int = -1)
		{
			this.factory = factory;
			this.byte = byte;
		}

		public function getFactory():Factory
		{
			return factory;
		}

		public function getByte():int
		{
			return byte;
		}

		public function assembly(data:*, destination:IDataOutput):void
		{
		}

		public function disassembly(source:IDataInput):*
		{
			return null;
		}
	}
}