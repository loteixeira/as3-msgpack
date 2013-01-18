package org.msgpack
{
	import flash.utils.*;

	public class Parser
	{
		private var workers:Object;
		private var root:Worker;

		public function Parser()
		{
			workers = {};
		}

		public function assign(type:Class, workerClass:Class):void
		{
			var typeName:String = getQualifiedClassName(type);
			workers[typeName] = workerClass;
		}

		public function unassign(type:Class):void
		{
			var typeName:String = getQualifiedClassName(type);
			workers[typeName] = undefined;
		}

		internal function encode(data:*, destination:IDataOutput):void
		{
			var typeName:String = data == null ? "null" : getQualifiedClassName(data);
			var workerClass:Class = workers[typeName];
			var worker:Worker = new workerClass(this);

			if (worker == null)
				throw new MsgPackError("Worker for type " + typeName + " not found");

			worker.encode(data, destination);
		}

		internal function decode(source:IDataInput):*
		{
			var result:*;
			var worker:Worker;

			// get worker stack
			if (root)
			{
				cpln("GET STORED WORKER");
				worker = root;
			}
			// find worker from next signature byte
			else if (source.bytesAvailable > 0)
			{
				cpln("GET WORKER FROM SIGNATURE");
				var byte:int = source.readByte() & 0xff;

				for each (var workerClass:Class in workers)
				{
					cpln("-> " + !workerClass["checkType"](byte));

					if (!workerClass["checkType"](byte))
						continue;

					worker = new workerClass(this, byte);
					break;
				}
             
				if (!worker)
					throw new MsgPackError("MessagePack handler for signature 0x" + byte.toString(16) + " not found");
			}

			if (worker)
			{
				if (worker.getBufferLength() <= source.bytesAvailable || worker.getBufferLength() == Worker.VARIABLE)
				{
					cpln("DECODE");
					result = worker.decode(source);
				}
				else
				{
					cpln("POSTPONE");
				}
			}

			if (result)
				root = undefined;

			// end of the history!
			return result;
		}
	}
}