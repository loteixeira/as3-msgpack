package org.msgpack
{
	import flash.utils.*;

	internal class MapWorker extends Worker
	{
		public static function checkType(byte:int):Boolean
		{
			return (byte & 0xf0) == 0x80 || byte == 0xde || byte == 0xdf;
		}

		private var count:int;
		private var ready:int;
		private var map:Object;
		private var keyWorker:Worker;
		private var valWorker:Worker;
		private var key:*;
		private var val:*;

		public function MapWorker(factory:Factory, byte:int = -1)
		{
			super(factory, byte);
			count = -1;
			ready = 0;
			map = {};
			key = incomplete;
			val = incomplete;
		}

		override public function assembly(data:*, destination:IDataOutput):void
		{
			var elements:Array = [];	

			for (var key:String in data)
				elements.push(key);

			var l:uint = elements.length;

			if (l < 16)
			{
				// fix map
				destination.writeByte(0x80 | l);
			}
			else if (l < 65536)
			{
				// map 16
				destination.writeByte(0xde);
				destination.writeShort(l);
			}
			else
			{
				// map 32
				destination.writeByte(0xdf);
				destination.writeUnsignedInt(l);
			}

			for (var i:uint = 0; i < l; i++)
			{
				var elemKey:String = elements[i];

				var keyWorker:Worker = factory.getWorkerByType(elemKey);
				keyWorker.assembly(elemKey, destination);

				var valWorker:Worker = factory.getWorkerByType(data[elemKey]);
				valWorker.assembly(data[elemKey], destination);
			}
		}

		override public function disassembly(source:IDataInput):*
		{
			if (count == -1)
			{
				if ((byte & 0xf0) == 0x80)
					count = byte & 0x0f;
				else if (byte == 0xde && source.bytesAvailable >= 2)
					count = source.readUnsignedShort();
				else if (byte == 0xdf && source.bytesAvailable >= 4)
					count = source.readUnsignedInt();
			}

			if (ready < count)
			{
				var first:uint = ready;

				for (var i:uint = first; i < count; i++)
				{
					if (key == incomplete)
					{
						if (!keyWorker)
							keyWorker = factory.getWorkerByByte(source);

						key = keyWorker.disassembly(source);
					}

					if (key != incomplete && val == incomplete)
					{
						if (!valWorker)
							valWorker = factory.getWorkerByByte(source);

						val = valWorker.disassembly(source);
					}

					if (key != incomplete && val != incomplete)
					{
						map[key.toString()] = val;
						keyWorker = undefined;
						valWorker = undefined;
						key = incomplete;
						val = incomplete;
						ready++;
						continue;
					}
					
					break;
				}
			}

			if (ready == count)
				return map;

			return incomplete;
		}
	}
}