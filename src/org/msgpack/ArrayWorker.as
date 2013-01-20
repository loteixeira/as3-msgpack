package org.msgpack
{
	import flash.utils.*;

	internal class ArrayWorker extends Worker
	{
		public static function checkType(byte:int):Boolean
		{
			return (byte & 0xf0) == 0x90 || byte == 0xdc || byte == 0xdd;
		}

		private var array:Array;
		private var workers:Array;
		private var count:int;

		public function ArrayWorker(factory:Factory, byte:int = -1)
		{
			super(factory, byte);
			array = [];
			workers = [];
			count = -1;
		}

		override public function assembly(data:*, destination:IDataOutput):void
		{
			super.assembly(data, destination);

			var l:uint = data.length;

			if (l < 16)
			{
				// fix array
				destination.writeByte(0x90 | l);
			}
			else if (l < 65536)
			{
				// array 16
				destination.writeByte(0xdc);
				destination.writeShort(l);
			}
			else
			{
				// array 32
				destination.writeByte(0xdd);
				destination.writeUnsignedInt(l);
			}

			// write elements
			for (var i:uint = 0; i < l; i++)
			{
				var worker:Worker = factory.getWorkerByType(data[i]);
				worker.assembly(data[i], destination);
			}
		}

		override public function disassembly(source:IDataInput):*
		{
			if (count == -1)
			{
				if ((byte & 0xf0) == 0x90)
					count = byte & 0x0f
				else if (byte == 0xdc && source.bytesAvailable >= 2)
					count = source.readUnsignedShort();
				else if (byte == 0xdd && source.bytesAvailable >= 4)
					count = source.readUnsignedInt();
			}

			if (array.length < count)
			{
				var first:uint = array.length;

				for (var i:uint = first; i < count; i++)
				{
					if (!workers[i])
						workers.push(factory.getWorkerByByte(source));

					var obj:* = workers[i].disassembly(source);

					if (obj != Worker.INCOMPLETE)
					{
						array.push(obj);
						continue;
					}

					break;
				}
			}

			if (array.length == count)
				return array;

			return Worker.INCOMPLETE;
		}
	}
}